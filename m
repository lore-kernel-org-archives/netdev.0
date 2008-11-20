From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH net-next] netdevice ppp: Convert directly reference of netdev->priv
Date: Thu, 20 Nov 2008 17:16:13 +0800
Message-ID: <49252ADD.9020104@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>,
	NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:53101 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752607AbYKTJQ3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Nov 2008 04:16:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1. Use netdev_priv(dev) to replace dev->priv.
2. Alloc netdev's private data by alloc_netdev().

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 drivers/net/ppp_generic.c |   15 +++++----------
 1 files changed, 5 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ppp_generic.c b/drivers/net/ppp_generic.c
index 274d495..9888b2a 100644
--- a/drivers/net/ppp_generic.c
+++ b/drivers/net/ppp_generic.c
@@ -886,7 +886,7 @@ out_chrdev:
 static int
 ppp_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct ppp *ppp = (struct ppp *) dev->priv;
+	struct ppp *ppp = netdev_priv(dev);
 	int npi, proto;
 	unsigned char *pp;
 
@@ -931,7 +931,7 @@ ppp_start_xmit(struct sk_buff *skb, struct net_device *dev)
 static int
 ppp_net_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
-	struct ppp *ppp = dev->priv;
+	struct ppp *ppp = netdev_priv(dev);
 	int err = -EFAULT;
 	void __user *addr = (void __user *) ifr->ifr_ifru.ifru_data;
 	struct ppp_stats stats;
@@ -2413,13 +2413,12 @@ ppp_create_interface(int unit, int *retp)
 	int ret = -ENOMEM;
 	int i;
 
-	ppp = kzalloc(sizeof(struct ppp), GFP_KERNEL);
-	if (!ppp)
-		goto out;
-	dev = alloc_netdev(0, "", ppp_setup);
+	dev = alloc_netdev(sizeof(struct ppp), "", ppp_setup);
 	if (!dev)
 		goto out1;
 
+	ppp = netdev_priv(dev);
+	ppp->dev = dev;
 	ppp->mru = PPP_MRU;
 	init_ppp_file(&ppp->file, INTERFACE);
 	ppp->file.hdrlen = PPP_HDRLEN - 2;	/* don't count proto bytes */
@@ -2432,8 +2431,6 @@ ppp_create_interface(int unit, int *retp)
 	ppp->minseq = -1;
 	skb_queue_head_init(&ppp->mrq);
 #endif /* CONFIG_PPP_MULTILINK */
-	ppp->dev = dev;
-	dev->priv = ppp;
 
 	dev->hard_start_xmit = ppp_start_xmit;
 	dev->do_ioctl = ppp_net_ioctl;
@@ -2472,8 +2469,6 @@ out2:
 	mutex_unlock(&all_ppp_mutex);
 	free_netdev(dev);
 out1:
-	kfree(ppp);
-out:
 	*retp = ret;
 	return NULL;
 }
-- 
1.5.3.4


