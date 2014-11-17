From: raj@tardy.usa.hp.com (Rick Jones)
Subject: [PATCH v2 net-next] icmp: Remove some spurious dropped packet profile hits from the ICMP path
Date: Mon, 17 Nov 2014 14:04:29 -0800 (PST)
Message-ID: <20141117220429.B000D29003AD@tardy>
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g2t1383g.austin.hp.com ([15.217.136.92]:53280 "EHLO
	g2t1383g.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751499AbaKQWEd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2014 17:04:33 -0500
Received: from g5t1626.atlanta.hp.com (g5t1626.atlanta.hp.com [15.192.137.9])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by g2t1383g.austin.hp.com (Postfix) with ESMTPS id 74F8A3928
	for <netdev@vger.kernel.org>; Mon, 17 Nov 2014 22:04:32 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Jones <rick.jones2@hp.com>

If icmp_rcv() has successfully processed the incoming ICMP datagram, we
should use consume_skb() rather than kfree_skb() because a hit on the likes
of perf -e skb:kfree_skb is not called-for.

Signed-off-by: Rick Jones <rick.jones2@hp.com>

---

A test system hit with a flood ping hits on perf top -e ksb:kfre_skb before
the change and none after for the normal/success path.  The IPv6 path would
be somewhat more ugly.  For the time being, just deal with the overlap on
ping_rcv() between the two to avoid a possible double free of an skb.


diff --git a/include/net/ping.h b/include/net/ping.h
index 026479b..f074060 100644
--- a/include/net/ping.h
+++ b/include/net/ping.h
@@ -82,7 +82,7 @@ int  ping_common_sendmsg(int family, struct msghdr *msg, size_t len,
 int  ping_v6_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		     size_t len);
 int  ping_queue_rcv_skb(struct sock *sk, struct sk_buff *skb);
-void ping_rcv(struct sk_buff *skb);
+bool ping_rcv(struct sk_buff *skb);
 
 #ifdef CONFIG_PROC_FS
 struct ping_seq_afinfo {
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 36b7bfa..36f5584 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -190,7 +190,7 @@ EXPORT_SYMBOL(icmp_err_convert);
  */
 
 struct icmp_control {
-	void (*handler)(struct sk_buff *skb);
+	bool (*handler)(struct sk_buff *skb);
 	short   error;		/* This ICMP is classed as an error message */
 };
 
@@ -746,7 +746,7 @@ static bool icmp_tag_validation(int proto)
  *	ICMP_PARAMETERPROB.
  */
 
-static void icmp_unreach(struct sk_buff *skb)
+static bool icmp_unreach(struct sk_buff *skb)
 {
 	const struct iphdr *iph;
 	struct icmphdr *icmph;
@@ -839,10 +839,10 @@ static void icmp_unreach(struct sk_buff *skb)
 	icmp_socket_deliver(skb, info);
 
 out:
-	return;
+	return true;
 out_err:
 	ICMP_INC_STATS_BH(net, ICMP_MIB_INERRORS);
-	goto out;
+	return false;
 }
 
 
@@ -850,17 +850,20 @@ out_err:
  *	Handle ICMP_REDIRECT.
  */
 
-static void icmp_redirect(struct sk_buff *skb)
+static bool icmp_redirect(struct sk_buff *skb)
 {
 	if (skb->len < sizeof(struct iphdr)) {
 		ICMP_INC_STATS_BH(dev_net(skb->dev), ICMP_MIB_INERRORS);
-		return;
+		return false;
 	}
 
-	if (!pskb_may_pull(skb, sizeof(struct iphdr)))
-		return;
+	if (!pskb_may_pull(skb, sizeof(struct iphdr))) {
+		/* there aught to be a stat */
+		return false;
+	}
 
 	icmp_socket_deliver(skb, icmp_hdr(skb)->un.gateway);
+	return true;
 }
 
 /*
@@ -875,7 +878,7 @@ static void icmp_redirect(struct sk_buff *skb)
  *	See also WRT handling of options once they are done and working.
  */
 
-static void icmp_echo(struct sk_buff *skb)
+static bool icmp_echo(struct sk_buff *skb)
 {
 	struct net *net;
 
@@ -891,6 +894,8 @@ static void icmp_echo(struct sk_buff *skb)
 		icmp_param.head_len	   = sizeof(struct icmphdr);
 		icmp_reply(&icmp_param, skb);
 	}
+	/* should there be an ICMP stat for ignored echos? */
+	return true;
 }
 
 /*
@@ -900,7 +905,7 @@ static void icmp_echo(struct sk_buff *skb)
  *		  MUST be accurate to a few minutes.
  *		  MUST be updated at least at 15Hz.
  */
-static void icmp_timestamp(struct sk_buff *skb)
+static bool icmp_timestamp(struct sk_buff *skb)
 {
 	struct timespec tv;
 	struct icmp_bxm icmp_param;
@@ -927,15 +932,17 @@ static void icmp_timestamp(struct sk_buff *skb)
 	icmp_param.data_len	   = 0;
 	icmp_param.head_len	   = sizeof(struct icmphdr) + 12;
 	icmp_reply(&icmp_param, skb);
-out:
-	return;
+	return true;
+
 out_err:
 	ICMP_INC_STATS_BH(dev_net(skb_dst(skb)->dev), ICMP_MIB_INERRORS);
-	goto out;
+	return false;
 }
 
-static void icmp_discard(struct sk_buff *skb)
+static bool icmp_discard(struct sk_buff *skb)
 {
+	/* pretend it was a success */
+	return true;
 }
 
 /*
@@ -946,6 +953,7 @@ int icmp_rcv(struct sk_buff *skb)
 	struct icmphdr *icmph;
 	struct rtable *rt = skb_rtable(skb);
 	struct net *net = dev_net(rt->dst.dev);
+	bool success;
 
 	if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb)) {
 		struct sec_path *sp = skb_sec_path(skb);
@@ -1012,7 +1020,12 @@ int icmp_rcv(struct sk_buff *skb)
 		}
 	}
 
-	icmp_pointers[icmph->type].handler(skb);
+	success = icmp_pointers[icmph->type].handler(skb);
+
+	if (success)  {
+		consume_skb(skb);
+		return 0;
+	}
 
 drop:
 	kfree_skb(skb);
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index 736236c..ce2920f 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -955,7 +955,7 @@ EXPORT_SYMBOL_GPL(ping_queue_rcv_skb);
  *	All we need to do is get the socket.
  */
 
-void ping_rcv(struct sk_buff *skb)
+bool ping_rcv(struct sk_buff *skb)
 {
 	struct sock *sk;
 	struct net *net = dev_net(skb->dev);
@@ -974,11 +974,11 @@ void ping_rcv(struct sk_buff *skb)
 		pr_debug("rcv on socket %p\n", sk);
 		ping_queue_rcv_skb(sk, skb_get(skb));
 		sock_put(sk);
-		return;
+		return true;
 	}
 	pr_debug("no socket, dropping\n");
 
-	/* We're called from icmp_rcv(). kfree_skb() is done there. */
+	return false;
 }
 EXPORT_SYMBOL_GPL(ping_rcv);
 
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 0929340..39b3ff9 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -679,6 +679,7 @@ static int icmpv6_rcv(struct sk_buff *skb)
 	const struct in6_addr *saddr, *daddr;
 	struct icmp6hdr *hdr;
 	u8 type;
+	bool success = false;
 
 	if (!xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb)) {
 		struct sec_path *sp = skb_sec_path(skb);
@@ -726,7 +727,7 @@ static int icmpv6_rcv(struct sk_buff *skb)
 		break;
 
 	case ICMPV6_ECHO_REPLY:
-		ping_rcv(skb);
+		success = ping_rcv(skb);
 		break;
 
 	case ICMPV6_PKT_TOOBIG:
@@ -790,7 +791,14 @@ static int icmpv6_rcv(struct sk_buff *skb)
 		icmpv6_notify(skb, type, hdr->icmp6_code, hdr->icmp6_mtu);
 	}
 
-	kfree_skb(skb);
+	/* until the v6 path can be better sorted assume failure and
+	 * preserve the status quo behaviour for the rest of the paths to here
+	 */
+	if (success)
+		consume_skb(skb);
+	else
+		kfree_skb(skb);
+
 	return 0;
 
 csum_error:
