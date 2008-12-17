From: James Chapman <jchapman@katalix.com>
Subject: [PATCH] ppp: fix segfaults introduced by netdev_priv changes
Date: Wed, 17 Dec 2008 22:02:16 GMT
Message-ID: <200812172202.mBHM2GHi012456@bert.katalix.com>
Cc: wangchen@cn.fujitsu.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:56101 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751248AbYLQV6W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Dec 2008 16:58:22 -0500
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

The original code set ppp->dev = NULL when the interface was closed to
prevent other ppp functions from trying to access the device. But we
now need the dev ptr in ppp_destroy_interface() in order to do the
free_netdev(). So ppp->dev is no longer used to tell if the interface
is down. Instead, a new flag (closing) is added to struct ppp. Can an
existing flag be used instead to avoid creating a new variable?


 drivers/net/ppp_generic.c |   28 +++++++++++++---------------
 1 files changed, 13 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ppp_generic.c b/drivers/net/ppp_generic.c
index 7e857e9..714a230 100644
--- a/drivers/net/ppp_generic.c
+++ b/drivers/net/ppp_generic.c
@@ -116,6 +116,7 @@ struct ppp {
 	unsigned long	last_xmit;	/* jiffies when last pkt sent 9c */
 	unsigned long	last_recv;	/* jiffies when last pkt rcvd a0 */
 	struct net_device *dev;		/* network interface device a4 */
+	int		closing;	/* is device closing down? a8 */
 #ifdef CONFIG_PPP_MULTILINK
 	int		nxchan;		/* next channel to send something on */
 	u32		nxseq;		/* next sequence number to send */
@@ -995,7 +996,7 @@ ppp_xmit_process(struct ppp *ppp)
 	struct sk_buff *skb;
 
 	ppp_xmit_lock(ppp);
-	if (ppp->dev) {
+	if (!ppp->closing) {
 		ppp_push(ppp);
 		while (!ppp->xmit_pending
 		       && (skb = skb_dequeue(&ppp->file.xq)))
@@ -1463,8 +1464,7 @@ static inline void
 ppp_do_recv(struct ppp *ppp, struct sk_buff *skb, struct channel *pch)
 {
 	ppp_recv_lock(ppp);
-	/* ppp->dev == 0 means interface is closing down */
-	if (ppp->dev)
+	if (!ppp->closing)
 		ppp_receive_frame(ppp, skb, pch);
 	else
 		kfree_skb(skb);
@@ -2498,18 +2498,16 @@ init_ppp_file(struct ppp_file *pf, int kind)
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
 	cardmap_set(&all_ppp_units, ppp->file.index, NULL);
 	ppp->file.dead = 1;
 	ppp->owner = NULL;
@@ -2554,7 +2552,7 @@ static void ppp_destroy_interface(struct ppp *ppp)
 	if (ppp->xmit_pending)
 		kfree_skb(ppp->xmit_pending);
 
-	kfree(ppp);
+	free_netdev(ppp->dev);
 }
 
 /*
@@ -2616,7 +2614,7 @@ ppp_connect_channel(struct channel *pch, int unit)
 	if (pch->file.hdrlen > ppp->file.hdrlen)
 		ppp->file.hdrlen = pch->file.hdrlen;
 	hdrlen = pch->file.hdrlen + 2;	/* for protocol bytes */
-	if (ppp->dev && hdrlen > ppp->dev->hard_header_len)
+	if (hdrlen > ppp->dev->hard_header_len)
 		ppp->dev->hard_header_len = hdrlen;
 	list_add_tail(&pch->clist, &ppp->channels);
 	++ppp->n_channels;
