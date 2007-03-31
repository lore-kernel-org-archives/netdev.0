From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Subject: [PATCH 2/3] [SK_BUFF]: Some more conversions to skb_copy_from_linear_data
Date: Sat, 31 Mar 2007 12:14:43 -0300
Message-ID: <20070331151443.GD29188@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.225]:17621 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753154AbXCaPOr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Mar 2007 11:14:47 -0400
Received: by wx-out-0506.google.com with SMTP id h31so864822wxd
        for <netdev@vger.kernel.org>; Sat, 31 Mar 2007 08:14:47 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
---
 net/ax25/ax25_in.c              |    4 +++-
 net/decnet/netfilter/dn_rtmsg.c |    2 +-
 net/ipv4/tcp_output.c           |    4 +++-
 net/netrom/nr_in.c              |    4 +++-
 net/x25/x25_in.c                |    7 +++++--
 5 files changed, 15 insertions(+), 6 deletions(-)

diff --git a/net/ax25/ax25_in.c b/net/ax25/ax25_in.c
index 31c5938..0ddaff0 100644
--- a/net/ax25/ax25_in.c
+++ b/net/ax25/ax25_in.c
@@ -66,7 +66,9 @@ static int ax25_rx_fragment(ax25_cb *ax25, struct sk_buff *skb)
 
 					/* Copy data from the fragments */
 					while ((skbo = skb_dequeue(&ax25->frag_queue)) != NULL) {
-						memcpy(skb_put(skbn, skbo->len), skbo->data, skbo->len);
+						skb_copy_from_linear_data(skbo,
+							  skb_put(skbn, skbo->len),
+									  skbo->len);
 						kfree_skb(skbo);
 					}
 
diff --git a/net/decnet/netfilter/dn_rtmsg.c b/net/decnet/netfilter/dn_rtmsg.c
index 9e8256a..2ee47ba 100644
--- a/net/decnet/netfilter/dn_rtmsg.c
+++ b/net/decnet/netfilter/dn_rtmsg.c
@@ -48,7 +48,7 @@ static struct sk_buff *dnrmg_build_message(struct sk_buff *rt_skb, int *errp)
 	rtm = (struct nf_dn_rtmsg *)NLMSG_DATA(nlh);
 	rtm->nfdn_ifindex = rt_skb->dev->ifindex;
 	ptr = NFDN_RTMSG(rtm);
-	memcpy(ptr, rt_skb->data, rt_skb->len);
+	skb_copy_from_linear_data(rt_skb, ptr, rt_skb->len);
 	nlh->nlmsg_len = skb->tail - old_tail;
 	return skb;
 
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 9ef6dba..f2d9aa5 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1641,7 +1641,9 @@ static void tcp_retrans_try_collapse(struct sock *sk, struct sk_buff *skb, int m
 		/* Ok.	We will be able to collapse the packet. */
 		tcp_unlink_write_queue(next_skb, sk);
 
-		memcpy(skb_put(skb, next_skb_size), next_skb->data, next_skb_size);
+		skb_copy_from_linear_data(next_skb,
+					  skb_put(skb, next_skb_size),
+					  next_skb_size);
 
 		if (next_skb->ip_summed == CHECKSUM_PARTIAL)
 			skb->ip_summed = CHECKSUM_PARTIAL;
diff --git a/net/netrom/nr_in.c b/net/netrom/nr_in.c
index e6dc749..6817648 100644
--- a/net/netrom/nr_in.c
+++ b/net/netrom/nr_in.c
@@ -54,7 +54,9 @@ static int nr_queue_rx_frame(struct sock *sk, struct sk_buff *skb, int more)
 		skb_reset_transport_header(skbn);
 
 		while ((skbo = skb_dequeue(&nr->frag_queue)) != NULL) {
-			memcpy(skb_put(skbn, skbo->len), skbo->data, skbo->len);
+			skb_copy_from_linear_data(skbo,
+						  skb_put(skbn, skbo->len),
+						  skbo->len);
 			kfree_skb(skbo);
 		}
 
diff --git a/net/x25/x25_in.c b/net/x25/x25_in.c
index ba13248..1c88762 100644
--- a/net/x25/x25_in.c
+++ b/net/x25/x25_in.c
@@ -56,14 +56,17 @@ static int x25_queue_rx_frame(struct sock *sk, struct sk_buff *skb, int more)
 		skb_reset_transport_header(skbn);
 
 		skbo = skb_dequeue(&x25->fragment_queue);
-		memcpy(skb_put(skbn, skbo->len), skbo->data, skbo->len);
+		skb_copy_from_linear_data(skbo, skb_put(skbn, skbo->len),
+					  skbo->len);
 		kfree_skb(skbo);
 
 		while ((skbo =
 			skb_dequeue(&x25->fragment_queue)) != NULL) {
 			skb_pull(skbo, (x25->neighbour->extended) ?
 					X25_EXT_MIN_LEN : X25_STD_MIN_LEN);
-			memcpy(skb_put(skbn, skbo->len), skbo->data, skbo->len);
+			skb_copy_from_linear_data(skbo,
+						  skb_put(skbn, skbo->len),
+						  skbo->len);
 			kfree_skb(skbo);
 		}
 
-- 
1.5.0.5

