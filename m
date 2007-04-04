From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [NET]: Use csum_start offset instead of skb_transport_header
Date: Wed, 4 Apr 2007 12:05:30 +1000
Message-ID: <20070404020530.GA30050@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2097 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S966281AbXDDCFl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2007 22:05:41 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave:

I've finally managed to kill the Xen csum_blank/proto_data_valid hack.
In the process I needed to make two more changes to Linux.  Here are
the patches against net-2.6.22.

[NET]: Use csum_start offset instead of skb_transport_header

The skb transport pointer is currently used to specify the start
of the checksum region for transmit checksum offload.  Unfortunately,
the same pointer is also used during receive side processing.

This creates a problem when we want to retransmit a received
packet with partial checksums since the skb transport pointer
would be overwritten.

This patch solves this problem by creating a new 16-bit csum_start
offset value to replace the skb transport header for the purpose
of checksums.  This offset is calculated from skb->head so that
it does not have to change when skb->data changes.

No extra space is required since csum_offset itself fits within
a 16-bit word so we can use the other 16 bits for csum_start.

For backwards compatibility, just before we push a packet with
partial checksums off into the device driver, we set the skb
transport header to what it would have been under the old scheme.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -205,7 +205,9 @@ typedef unsigned char *sk_buff_data_t;
  *	@len: Length of actual data
  *	@data_len: Data length
  *	@mac_len: Length of link layer header
- *	@csum: Checksum
+ *	@csum: Checksum (must include start/offset pair)
+ *	@csum_start: Offset from skb->head where checksumming should start
+ *	@csum_offset: Offset from csum_start where checksum should be stored
  *	@local_df: allow local fragmentation
  *	@cloned: Head may be cloned (check refcnt to be sure)
  *	@nohdr: Payload reference only, must not modify header
@@ -262,7 +264,10 @@ struct sk_buff {
 				mac_len;
 	union {
 		__wsum		csum;
-		__u32		csum_offset;
+		struct {
+			__u16	csum_start;
+			__u16	csum_offset;
+		};
 	};
 	__u32			priority;
 	__u8			local_df:1,
diff --git a/net/core/dev.c b/net/core/dev.c
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1158,7 +1158,7 @@ EXPORT_SYMBOL(netif_device_attach);
 int skb_checksum_help(struct sk_buff *skb)
 {
 	__wsum csum;
-	int ret = 0, offset = skb_transport_offset(skb);
+	int ret = 0, offset;
 
 	if (skb->ip_summed == CHECKSUM_COMPLETE)
 		goto out_set_summed;
@@ -1174,15 +1174,16 @@ int skb_checksum_help(struct sk_buff *sk
 			goto out;
 	}
 
+	offset = skb->csum_start - skb_headroom(skb);
 	BUG_ON(offset > (int)skb->len);
 	csum = skb_checksum(skb, offset, skb->len-offset, 0);
 
-	offset = skb->tail - skb->transport_header;
+	offset = skb_headlen(skb) - offset;
 	BUG_ON(offset <= 0);
 	BUG_ON(skb->csum_offset + 2 > offset);
 
-	*(__sum16 *)(skb_transport_header(skb) +
-		     skb->csum_offset) = csum_fold(csum);
+	*(__sum16 *)(skb->head + skb->csum_start + skb->csum_offset) =
+		csum_fold(csum);
 out_set_summed:
 	skb->ip_summed = CHECKSUM_NONE;
 out:
@@ -1434,12 +1435,16 @@ int dev_queue_xmit(struct sk_buff *skb)
 	/* If packet is not checksummed and device does not support
 	 * checksumming for this protocol, complete checksumming here.
 	 */
-	if (skb->ip_summed == CHECKSUM_PARTIAL &&
-	    (!(dev->features & NETIF_F_GEN_CSUM) &&
-	     (!(dev->features & NETIF_F_IP_CSUM) ||
-	      skb->protocol != htons(ETH_P_IP))))
-		if (skb_checksum_help(skb))
-			goto out_kfree_skb;
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
+		skb_set_transport_header(skb, skb->csum_start -
+					      skb_headroom(skb));
+
+		if (!(dev->features & NETIF_F_GEN_CSUM) &&
+		    (!(dev->features & NETIF_F_IP_CSUM) ||
+		     skb->protocol != htons(ETH_P_IP)))
+			if (skb_checksum_help(skb))
+				goto out_kfree_skb;
+	}
 
 gso:
 	spin_lock_prefetch(&dev->queue_lock);
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1415,7 +1415,7 @@ void skb_copy_and_csum_dev(const struct 
 	long csstart;
 
 	if (skb->ip_summed == CHECKSUM_PARTIAL)
-		csstart = skb_transport_offset(skb);
+		csstart = skb->csum_start - skb_headroom(skb);
 	else
 		csstart = skb_headlen(skb);
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -504,6 +504,7 @@ void tcp_v4_send_check(struct sock *sk, 
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		th->check = ~tcp_v4_check(len, inet->saddr,
 					  inet->daddr, 0);
+		skb->csum_start = skb_transport_header(skb) - skb->head;
 		skb->csum_offset = offsetof(struct tcphdr, check);
 	} else {
 		th->check = tcp_v4_check(len, inet->saddr, inet->daddr,
@@ -526,6 +527,7 @@ int tcp_v4_gso_send_check(struct sk_buff
 
 	th->check = 0;
 	th->check = ~tcp_v4_check(skb->len, iph->saddr, iph->daddr, 0);
+	skb->csum_start = skb_transport_header(skb) - skb->head;
 	skb->csum_offset = offsetof(struct tcphdr, check);
 	skb->ip_summed = CHECKSUM_PARTIAL;
 	return 0;
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -427,6 +427,7 @@ static void udp4_hwcsum_outgoing(struct 
 		/*
 		 * Only one fragment on the socket.
 		 */
+		skb->csum_start = skb_transport_header(skb) - skb->head;
 		skb->csum_offset = offsetof(struct udphdr, check);
 		uh->check = ~csum_tcpudp_magic(src, dst, len, IPPROTO_UDP, 0);
 	} else {
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -950,6 +950,7 @@ static void tcp_v6_send_check(struct soc
 
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		th->check = ~csum_ipv6_magic(&np->saddr, &np->daddr, len, IPPROTO_TCP,  0);
+		skb->csum_start = skb_transport_header(skb) - skb->head;
 		skb->csum_offset = offsetof(struct tcphdr, check);
 	} else {
 		th->check = csum_ipv6_magic(&np->saddr, &np->daddr, len, IPPROTO_TCP,
@@ -972,6 +973,7 @@ static int tcp_v6_gso_send_check(struct 
 	th->check = 0;
 	th->check = ~csum_ipv6_magic(&ipv6h->saddr, &ipv6h->daddr, skb->len,
 				     IPPROTO_TCP, 0);
+	skb->csum_start = skb_transport_header(skb) - skb->head;
 	skb->csum_offset = offsetof(struct tcphdr, check);
 	skb->ip_summed = CHECKSUM_PARTIAL;
 	return 0;
