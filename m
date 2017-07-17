From: gfree.wind@vip.163.com
Subject: [PATCH] ppp: Fix false xmit recursion detect with two ppp devices
Date: Mon, 17 Jul 2017 18:34:42 +0800
Message-ID: <1500287682-18872-1-git-send-email-gfree.wind@vip.163.com>
Cc: Gao Feng <gfree.wind@vip.163.com>
To: paulus@samba.org, g.nault@alphalink.fr, davem@davemloft.net,
        linux-ppp@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from m181-177.vip.163.com ([123.58.177.181]:57185 "EHLO
        m181-177.vip.163.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751493AbdGQKfX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2017 06:35:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <gfree.wind@vip.163.com>

The global percpu variable ppp_xmit_recursion is used to detect the ppp
xmit recursion to avoid the deadlock, which is caused by one CPU tries to
lock the xmit lock twice. But it would report false recursion when one CPU
wants to send the skb from two different PPP devices, like one L2TP on the
PPPoE. It is a normal case actually.

Now use one percpu member of struct ppp instead of the gloable variable to
detect the xmit recursion of one ppp device.

Fixes: 55454a565836 ("ppp: avoid dealock on recursive xmit")
Signed-off-by: Gao Feng <gfree.wind@vip.163.com>
Signed-off-by: Liu Jianying <jianying.liu@ikuai8.com>
---
 drivers/net/ppp/ppp_generic.c | 30 +++++++++++++++++++++---------
 1 file changed, 21 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index 1302883..bd43039 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -120,6 +120,7 @@ struct ppp {
 	int		n_channels;	/* how many channels are attached 54 */
 	spinlock_t	rlock;		/* lock for receive side 58 */
 	spinlock_t	wlock;		/* lock for transmit side 5c */
+	int		*xmit_recursion __percpu; /* xmit recursion detect */
 	int		mru;		/* max receive unit 60 */
 	unsigned int	flags;		/* control bits 64 */
 	unsigned int	xstate;		/* transmit state bits 68 */
@@ -1025,6 +1026,7 @@ static int ppp_dev_configure(struct net *src_net, struct net_device *dev,
 	struct ppp *ppp = netdev_priv(dev);
 	int indx;
 	int err;
+	int cpu;
 
 	ppp->dev = dev;
 	ppp->ppp_net = src_net;
@@ -1039,6 +1041,15 @@ static int ppp_dev_configure(struct net *src_net, struct net_device *dev,
 	INIT_LIST_HEAD(&ppp->channels);
 	spin_lock_init(&ppp->rlock);
 	spin_lock_init(&ppp->wlock);
+
+	ppp->xmit_recursion = alloc_percpu(int);
+	if (!ppp->xmit_recursion) {
+		err = -ENOMEM;
+		goto err1;
+	}
+	for_each_possible_cpu(cpu)
+		(*per_cpu_ptr(ppp->xmit_recursion, cpu)) = 0;
+
 #ifdef CONFIG_PPP_MULTILINK
 	ppp->minseq = -1;
 	skb_queue_head_init(&ppp->mrq);
@@ -1050,11 +1061,15 @@ static int ppp_dev_configure(struct net *src_net, struct net_device *dev,
 
 	err = ppp_unit_register(ppp, conf->unit, conf->ifname_is_set);
 	if (err < 0)
-		return err;
+		goto err2;
 
 	conf->file->private_data = &ppp->file;
 
 	return 0;
+err2:
+	free_percpu(ppp->xmit_recursion);
+err1:
+	return err;
 }
 
 static const struct nla_policy ppp_nl_policy[IFLA_PPP_MAX + 1] = {
@@ -1400,18 +1415,16 @@ static void __ppp_xmit_process(struct ppp *ppp)
 	ppp_xmit_unlock(ppp);
 }
 
-static DEFINE_PER_CPU(int, ppp_xmit_recursion);
-
 static void ppp_xmit_process(struct ppp *ppp)
 {
 	local_bh_disable();
 
-	if (unlikely(__this_cpu_read(ppp_xmit_recursion)))
+	if (unlikely(*this_cpu_ptr(ppp->xmit_recursion)))
 		goto err;
 
-	__this_cpu_inc(ppp_xmit_recursion);
+	(*this_cpu_ptr(ppp->xmit_recursion))++;
 	__ppp_xmit_process(ppp);
-	__this_cpu_dec(ppp_xmit_recursion);
+	(*this_cpu_ptr(ppp->xmit_recursion))--;
 
 	local_bh_enable();
 
@@ -1905,7 +1918,7 @@ static void __ppp_channel_push(struct channel *pch)
 		read_lock(&pch->upl);
 		ppp = pch->ppp;
 		if (ppp)
-			__ppp_xmit_process(ppp);
+			ppp_xmit_process(ppp);
 		read_unlock(&pch->upl);
 	}
 }
@@ -1914,9 +1927,7 @@ static void ppp_channel_push(struct channel *pch)
 {
 	local_bh_disable();
 
-	__this_cpu_inc(ppp_xmit_recursion);
 	__ppp_channel_push(pch);
-	__this_cpu_dec(ppp_xmit_recursion);
 
 	local_bh_enable();
 }
@@ -3057,6 +3068,7 @@ static void ppp_destroy_interface(struct ppp *ppp)
 #endif /* CONFIG_PPP_FILTER */
 
 	kfree_skb(ppp->xmit_pending);
+	free_percpu(ppp->xmit_recursion);
 
 	free_netdev(ppp->dev);
 }
-- 
1.9.1
