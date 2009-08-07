From: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Subject: Use correct NET_RX_* returns for atalk_rcv()
Date: Fri, 7 Aug 2009 18:51:22 +0930
Message-ID: <20090807185122.30f022de.lk-netdev@lk-netdev.nosense.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: acme@ghostprotocols.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.adam.net.au ([202.136.110.247]:43291 "EHLO
	smtp4.adam.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753079AbZHGJV0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2009 05:21:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


    In all rx'd SKB cases, atalk_rcv() either eventually jumps to or falls through
    to the label out:, which  returns numeric 0. Numeric 0 corresponds to
    NET_RX_SUCCESS, which is incorrect in failed SKB cases.
    
    This patch makes atalk_rcv() provide the correct returns by:
    
    o  explicitly returning NET_RX_SUCCESS in the two success cases
    o  having the out: label return NET_RX_DROP, instead of numeric 0
    o  making the failed SKB labels and processing more consistent with other
       _rcv() routines in the kernel, simplifying validation and removing a
       backwards goto

Signed-off-by: Mark Smith <markzzzsmith@yahoo.com.au>

diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index 590b839..2377ebe 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -1398,7 +1398,7 @@ static int atalk_rcv(struct sk_buff *skb, struct net_device *dev,
 	__u16 len_hops;
 
 	if (!net_eq(dev_net(dev), &init_net))
-		goto freeit;
+		goto drop;
 
 	/* Don't mangle buffer if shared */
 	if (!(skb = skb_share_check(skb, GFP_ATOMIC)))
@@ -1406,7 +1406,7 @@ static int atalk_rcv(struct sk_buff *skb, struct net_device *dev,
 
 	/* Size check and make sure header is contiguous */
 	if (!pskb_may_pull(skb, sizeof(*ddp)))
-		goto freeit;
+		goto drop;
 
 	ddp = ddp_hdr(skb);
 
@@ -1424,7 +1424,7 @@ static int atalk_rcv(struct sk_buff *skb, struct net_device *dev,
 	if (skb->len < sizeof(*ddp) || skb->len < (len_hops & 1023)) {
 		pr_debug("AppleTalk: dropping corrupted frame (deh_len=%u, "
 			 "skb->len=%u)\n", len_hops & 1023, skb->len);
-		goto freeit;
+		goto drop;
 	}
 
 	/*
@@ -1434,7 +1434,7 @@ static int atalk_rcv(struct sk_buff *skb, struct net_device *dev,
 	if (ddp->deh_sum &&
 	    atalk_checksum(skb, len_hops & 1023) != ddp->deh_sum)
 		/* Not a valid AppleTalk frame - dustbin time */
-		goto freeit;
+		goto drop;
 
 	/* Check the packet is aimed at us */
 	if (!ddp->deh_dnet)	/* Net 0 is 'this network' */
@@ -1447,7 +1447,7 @@ static int atalk_rcv(struct sk_buff *skb, struct net_device *dev,
 		 * AppleTalk iface
 		 */
 		atalk_route_packet(skb, dev, ddp, len_hops, origlen);
-		goto out;
+		return NET_RX_SUCCESS;
 	}
 
 	/* if IP over DDP is not selected this code will be optimized out */
@@ -1463,18 +1463,21 @@ static int atalk_rcv(struct sk_buff *skb, struct net_device *dev,
 
 	sock = atalk_search_socket(&tosat, atif);
 	if (!sock) /* But not one of our sockets */
-		goto freeit;
+		goto drop;
 
 	/* Queue packet (standard) */
 	skb->sk = sock;
 
 	if (sock_queue_rcv_skb(sock, skb) < 0)
-		goto freeit;
-out:
-	return 0;
-freeit:
+		goto drop;
+
+	return NET_RX_SUCCESS;
+
+drop:
 	kfree_skb(skb);
-	goto out;
+out:
+	return NET_RX_DROP;
+
 }
 
 /*
