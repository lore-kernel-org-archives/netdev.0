From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2 2/3] net: Save software checksum complete
Date: Tue, 10 Jun 2014 18:54:19 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1406101848580.5805@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f73.google.com ([209.85.160.73]:40697 "EHLO
	mail-pb0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753735AbaFKByU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2014 21:54:20 -0400
Received: by mail-pb0-f73.google.com with SMTP id md12so229889pbc.2
        for <netdev@vger.kernel.org>; Tue, 10 Jun 2014 18:54:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In skb_checksum complete, if we need to compute the checksum for the
packet (via skb_checksum) save the result as CHECKSUM_COMPLETE.
Subsequent checksum verification can use this.

Also, added csum_complete_sw flag to distinguish between software and
hardware generated checksum complete, we should always be able to trust
the software computation.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/skbuff.h |  3 ++-
 net/core/datagram.c    | 14 +++++++++-----
 net/ipv4/gre_offload.c |  6 ++++--
 net/sunrpc/socklib.c   |  3 ++-
 4 files changed, 17 insertions(+), 9 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index fb44d5f..b373988 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -573,7 +573,8 @@ struct sk_buff {
 	__u8			encapsulation:1;
 	__u8			encap_hdr_csum:1;
 	__u8			csum_valid:1;
-	/* 4/6 bit hole (depending on ndisc_nodetype presence) */
+	__u8			csum_complete_sw:1;
+	/* 3/5 bit hole (depending on ndisc_nodetype presence) */
 	kmemcheck_bitfield_end(flags2);
 
 #if defined CONFIG_NET_DMA || defined CONFIG_NET_RX_BUSY_POLL
diff --git a/net/core/datagram.c b/net/core/datagram.c
index a16ed7b..6b1c04c 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -739,11 +739,15 @@ __sum16 __skb_checksum_complete_head(struct sk_buff *skb, int len)
 	__sum16 sum;
 
 	sum = csum_fold(skb_checksum(skb, 0, len, skb->csum));
-	if (likely(!sum)) {
-		if (unlikely(skb->ip_summed == CHECKSUM_COMPLETE))
-			netdev_rx_csum_fault(skb->dev);
-		skb->ip_summed = CHECKSUM_UNNECESSARY;
-	}
+	if (unlikely(skb->ip_summed == CHECKSUM_COMPLETE) && !sum &&
+	    !skb->csum_complete_sw)
+		netdev_rx_csum_fault(skb->dev);
+
+	/* Save checksum complete for later use */
+	skb->csum = sum;
+	skb->ip_summed = CHECKSUM_COMPLETE;
+	skb->csum_complete_sw = 1;
+
 	return sum;
 }
 EXPORT_SYMBOL(__skb_checksum_complete_head);
diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
index 24deb39..eb92deb 100644
--- a/net/ipv4/gre_offload.c
+++ b/net/ipv4/gre_offload.c
@@ -131,10 +131,12 @@ static __sum16 gro_skb_checksum(struct sk_buff *skb)
 		csum_partial(skb->data, skb_gro_offset(skb), 0));
 	sum = csum_fold(NAPI_GRO_CB(skb)->csum);
 	if (unlikely(skb->ip_summed == CHECKSUM_COMPLETE)) {
-		if (unlikely(!sum))
+		if (unlikely(!sum) && !skb->csum_complete_sw)
 			netdev_rx_csum_fault(skb->dev);
-	} else
+	} else {
 		skb->ip_summed = CHECKSUM_COMPLETE;
+		skb->csum_complete_sw = 1;
+	}
 
 	return sum;
 }
diff --git a/net/sunrpc/socklib.c b/net/sunrpc/socklib.c
index 0a648c5..2df87f7 100644
--- a/net/sunrpc/socklib.c
+++ b/net/sunrpc/socklib.c
@@ -173,7 +173,8 @@ int csum_partial_copy_to_xdr(struct xdr_buf *xdr, struct sk_buff *skb)
 		return -1;
 	if (csum_fold(desc.csum))
 		return -1;
-	if (unlikely(skb->ip_summed == CHECKSUM_COMPLETE))
+	if (unlikely(skb->ip_summed == CHECKSUM_COMPLETE) &&
+	    !skb->csum_complete_sw)
 		netdev_rx_csum_fault(skb->dev);
 	return 0;
 no_checksum:
-- 
2.0.0.526.g5318336
