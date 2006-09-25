From: akpm@osdl.org
Subject: [patch 10/11] fix possible NULL ptr deref in forcedeth
Date: Mon, 25 Sep 2006 16:39:24 -0700
Message-ID: <200609252339.k8PNdPVZ002657@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, jesper.juhl@gmail.com,
	aabdulla@nvidia.com, manfred@colorfullife.com, shemminger@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:20916 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751729AbWIYXjo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2006 19:39:44 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesper Juhl <jesper.juhl@gmail.com>

There seems to be a possible NULL pointer deref bug in
drivers/net/forcedeth.c::nv_loopback_test().  If dev_alloc_skb() fails, the
next line will call skb_put() with a NULL first argument which it'll then
try to deref - kaboom: a NULL pointer deref.  Found by coverity (#1337).

Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
Cc: Ayaz Abdulla <aabdulla@nvidia.com>
Cc: Manfred Spraul <manfred@colorfullife.com>
Cc: Stephen Hemminger <shemminger@osdl.org>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/forcedeth.c |    8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff -puN drivers/net/forcedeth.c~fix-possible-null-ptr-deref-in-forcedeth drivers/net/forcedeth.c
--- a/drivers/net/forcedeth.c~fix-possible-null-ptr-deref-in-forcedeth
+++ a/drivers/net/forcedeth.c
@@ -3789,6 +3789,12 @@ static int nv_loopback_test(struct net_d
 	/* setup packet for tx */
 	pkt_len = ETH_DATA_LEN;
 	tx_skb = dev_alloc_skb(pkt_len);
+	if (!tx_skb) {
+		printk(KERN_ERR "dev_alloc_skb() failed during loopback test"
+			 " of %s\n", dev->name);
+		ret = 0;
+		goto out;
+	}
 	pkt_data = skb_put(tx_skb, pkt_len);
 	for (i = 0; i < pkt_len; i++)
 		pkt_data[i] = (u8)(i & 0xff);
@@ -3853,7 +3859,7 @@ static int nv_loopback_test(struct net_d
 		       tx_skb->end-tx_skb->data,
 		       PCI_DMA_TODEVICE);
 	dev_kfree_skb_any(tx_skb);
-
+ out:
 	/* stop engines */
 	nv_stop_rx(dev);
 	nv_stop_tx(dev);
_
