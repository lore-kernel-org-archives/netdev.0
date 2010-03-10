From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/2] hv: handle skb allocation failure
Date: Tue, 9 Mar 2010 17:42:17 -0800
Message-ID: <20100309174217.00ae3f3b@nehalam>
References: <AD02C96F1FB40A4B896D24F974E9B9D42AA4787A@TK5EX14MBXC139.redmond.corp.microsoft.com>
	<20100308154549.1c62a33b@nehalam>
	<8AFC7968D54FB448A30D8F38F259C5621AF725A9@TK5EX14MBXC116.redmond.corp.microsoft.com>
	<20100309173855.7d297c44@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Hank Janssen <hjanssen@microsoft.com>, Greg KH <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:52847 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753551Ab0CJBnC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Mar 2010 20:43:02 -0500
In-Reply-To: <20100309173855.7d297c44@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some fixes to receive handling:
  * Dieing with assertion failure when running out of memory is not ok
  * Use newer alloc function to get aligned skb
  * Dropped statistic is supposed to be incremented only by
    driver it was responsible for the drop.

Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 drivers/staging/hv/netvsc_drv.c |   32 ++++++++++++--------------------
 1 file changed, 12 insertions(+), 20 deletions(-)

--- a/drivers/staging/hv/netvsc_drv.c	2010-03-09 17:27:57.263312289 -0800
+++ b/drivers/staging/hv/netvsc_drv.c	2010-03-09 17:34:45.012686682 -0800
@@ -292,7 +292,6 @@ static int netvsc_recv_callback(struct h
 	struct net_device_context *net_device_ctx;
 	struct sk_buff *skb;
 	void *data;
-	int ret;
 	int i;
 	unsigned long flags;
 
@@ -306,12 +305,12 @@ static int netvsc_recv_callback(struct h
 
 	net_device_ctx = netdev_priv(net);
 
-	/* Allocate a skb - TODO preallocate this */
-	/* Pad 2-bytes to align IP header to 16 bytes */
-	skb = dev_alloc_skb(packet->TotalDataBufferLength + 2);
-	ASSERT(skb);
-	skb_reserve(skb, 2);
-	skb->dev = net;
+	/* Allocate a skb - TODO direct I/O to pages? */
+	skb = netdev_alloc_skb_ip_align(net, packet->TotalDataBufferLength);
+	if (unlikely(!skb)) {
+		++net->stats.rx_dropped;
+		return 0;
+	}
 
 	/* for kmap_atomic */
 	local_irq_save(flags);
@@ -336,25 +335,18 @@ static int netvsc_recv_callback(struct h
 	local_irq_restore(flags);
 
 	skb->protocol = eth_type_trans(skb, net);
-
 	skb->ip_summed = CHECKSUM_NONE;
 
+	net->stats.rx_packets++;
+	net->stats.rx_bytes += skb->len;
+
 	/*
 	 * Pass the skb back up. Network stack will deallocate the skb when it
-	 * is done
+	 * is done.
+	 * TODO - use NAPI?
 	 */
-	ret = netif_rx(skb);
-
-	switch (ret) {
-	case NET_RX_DROP:
-		net->stats.rx_dropped++;
-		break;
-	default:
-		net->stats.rx_packets++;
-		net->stats.rx_bytes += skb->len;
-		break;
+	netif_rx(skb);
 
-	}
 	DPRINT_DBG(NETVSC_DRV, "# of recvs %lu total size %lu",
 		   net->stats.rx_packets, net->stats.rx_bytes);
 
