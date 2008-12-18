From: James Chapman <jchapman@katalix.com>
Subject: [PATCH -next] ppp: fix segfaults introduced by netdev_priv changes
Date: Thu, 18 Dec 2008 18:38:21 GMT
Message-ID: <200812181838.mBIIcLlw019317@bert.katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:52442 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752301AbYLRSeT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Dec 2008 13:34:19 -0500
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.katalix.com (Postfix) with ESMTP id 2B201A620A1
	for <netdev@vger.kernel.org>; Thu, 18 Dec 2008 18:38:22 +0000 (GMT)
Received: from mail.katalix.com ([127.0.0.1])
	by localhost (mail.katalix.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id MGkgSfJg8+Ku for <netdev@vger.kernel.org>;
	Thu, 18 Dec 2008 18:38:22 +0000 (GMT)
Received: from bert.katalix.com (localhost.localdomain [127.0.0.1])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mail.katalix.com (Postfix) with ESMTPS id F2199A62087
	for <netdev@vger.kernel.org>; Thu, 18 Dec 2008 18:38:21 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a segfault in ppp_shutdown_interface() and
ppp_destroy_interface() when a PPP connection is closed. I bisected
the problem to the following commit:

  commit c8019bf3aff653cceb64f66489fc299ee5957b57
  Author: Wang Chen <wangchen@cn.fujitsu.com>
  Date:   Thu Nov 20 04:24:17 2008 -0800

    netdevice ppp: Convert directly reference of netdev->priv
    
    1. Use netdev_priv(dev) to replace dev->priv.
    2. Alloc netdev's private data by alloc_netdev().
    
    Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

The original ppp_generic code treated the netdev and struct ppp as
independent data structures which were freed separately. In moving the
ppp struct into the netdev, it is now possible for the private data to
be freed before the call to ppp_shutdown_interface(), which is bad.

The kfree(ppp) in ppp_destroy_interface() is also wrong; presumably
ppp hasn't worked since the above commit.

The following patch fixes both problems.

Signed-off-by: James Chapman <jchapman@katalix.com>

---

This is a respin for net-next, as requested.

 drivers/net/ppp_generic.c |   28 +++++++++++++---------------
 1 files changed, 13 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ppp_generic.c b/drivers/net/ppp_generic.c
index 3ee7830..f97f3db 100644
--- a/drivers/net/ppp_generic.c
+++ b/drivers/net/ppp_generic.c
@@ -117,6 +117,7 @@ struct ppp {
 	unsigned long	last_xmit;	/* jiffies when last pkt sent 9c */
 	unsigned long	last_recv;	/* jiffies when last pkt rcvd a0 */
 	struct net_device *dev;		/* network interface device a4 */
+	int		closing;	/* is device closing down? a8 */
 #ifdef CONFIG_PPP_MULTILINK
 	int		nxchan;		/* next channel to send something on */
 	u32		nxseq;		/* next sequence number to send */
@@ -985,7 +986,7 @@ ppp_xmit_process(struct ppp *ppp)
 	struct sk_buff *skb;
 
 	ppp_xmit_lock(ppp);
-	if (ppp->dev) {
+	if (!ppp->closing) {
 		ppp_push(ppp);
 		while (!ppp->xmit_pending
 		       && (skb = skb_dequeue(&ppp->file.xq)))
@@ -1453,8 +1454,7 @@ static inline void
 ppp_do_recv(struct ppp *ppp, struct sk_buff *skb, struct channel *pch)
 {
 	ppp_recv_lock(ppp);
-	/* ppp->dev == 0 means interface is closing down */
-	if (ppp->dev)
+	if (!ppp->closing)
 		ppp_receive_frame(ppp, skb, pch);
 	else
 		kfree_skb(skb);
@@ -2486,18 +2486,16 @@ init_ppp_file(struct ppp_file *pf, int kind)
  */
 static void ppp_shutdown_interface(struct ppp *ppp)
 {
-	struct net_device *dev;
-
 	mutex_lock(&all_ppp_mutex);
-	ppp_lock(ppp);
-	dev = ppp->dev;
-	ppp->dev = NULL;
-	ppp_unlock(ppp);
 	/* This will call dev_close() for us. */
-	if (dev) {
-		unregister_netdev(dev);
-		free_netdev(dev);
-	}
+	ppp_lock(ppp);
+	if (!ppp->closing) {
+		ppp->closing = 1;
+		ppp_unlock(ppp);
+		unregister_netdev(ppp->dev);
+	} else
+		ppp_unlock(ppp);
+
 	unit_put(&ppp_units_idr, ppp->file.index);
 	ppp->file.dead = 1;
 	ppp->owner = NULL;
@@ -2542,7 +2540,7 @@ static void ppp_destroy_interface(struct ppp *ppp)
 	if (ppp->xmit_pending)
 		kfree_skb(ppp->xmit_pending);
 
-	kfree(ppp);
+	free_netdev(ppp->dev);
 }
 
 /*
@@ -2604,7 +2602,7 @@ ppp_connect_channel(struct channel *pch, int unit)
 	if (pch->file.hdrlen > ppp->file.hdrlen)
 		ppp->file.hdrlen = pch->file.hdrlen;
 	hdrlen = pch->file.hdrlen + 2;	/* for protocol bytes */
-	if (ppp->dev && hdrlen > ppp->dev->hard_header_len)
+	if (hdrlen > ppp->dev->hard_header_len)
 		ppp->dev->hard_header_len = hdrlen;
 	list_add_tail(&pch->clist, &ppp->channels);
 	++ppp->n_channels;
