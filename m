From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH net-next 07/14] ipv6: added net argument to ICMP6_INC_STATS_BH
Date: Wed,  8 Oct 2008 15:51:55 +0400
Message-ID: <1223466722-8169-7-git-send-email-den@openvz.org>
References: <1223466685.7184.13.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, dlezcano@fr.ibm.com,
	benjamin.thery@bull.net, xemul@openvz.org, yoshfuji@linux-ipv6.org,
	"Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:34345 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752257AbYJHLyg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Oct 2008 07:54:36 -0400
In-Reply-To: <1223466685.7184.13.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 include/net/ipv6.h    |    3 ++-
 net/dccp/ipv6.c       |    6 ++++--
 net/ipv6/icmp.c       |    4 ++--
 net/ipv6/ip6_output.c |    2 +-
 net/ipv6/mcast.c      |    2 +-
 net/ipv6/tcp_ipv6.c   |    3 ++-
 net/sctp/ipv6.c       |    2 +-
 7 files changed, 13 insertions(+), 9 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 744fe74..5107cd9 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -141,7 +141,8 @@ DECLARE_SNMP_STAT(struct icmpv6msg_mib, icmpv6msg_statistics);
 
 #define ICMP6_INC_STATS(net, idev, field)	({ (void)(net); \
 		_DEVINC(icmpv6, , idev, field); })
-#define ICMP6_INC_STATS_BH(idev, field)	_DEVINC(icmpv6, _BH, idev, field)
+#define ICMP6_INC_STATS_BH(net, idev, field)	({ (void)(net); \
+		_DEVINC(icmpv6, _BH, idev, field); })
 
 #define ICMP6MSGOUT_INC_STATS(idev, field) \
 	_DEVINC(icmpv6msg, , idev, field +256)
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index caa7f34..1106278 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -98,7 +98,8 @@ static void dccp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 
 	if (skb->len < offset + sizeof(*dh) ||
 	    skb->len < offset + __dccp_basic_hdr_len(dh)) {
-		ICMP6_INC_STATS_BH(__in6_dev_get(skb->dev), ICMP6_MIB_INERRORS);
+		ICMP6_INC_STATS_BH(net, __in6_dev_get(skb->dev),
+				   ICMP6_MIB_INERRORS);
 		return;
 	}
 
@@ -107,7 +108,8 @@ static void dccp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 			&hdr->saddr, dh->dccph_sport, inet6_iif(skb));
 
 	if (sk == NULL) {
-		ICMP6_INC_STATS_BH(__in6_dev_get(skb->dev), ICMP6_MIB_INERRORS);
+		ICMP6_INC_STATS_BH(net, __in6_dev_get(skb->dev),
+				   ICMP6_MIB_INERRORS);
 		return;
 	}
 
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 758cdd7..4c96155 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -664,7 +664,7 @@ static int icmpv6_rcv(struct sk_buff *skb)
 		skb_set_network_header(skb, nh);
 	}
 
-	ICMP6_INC_STATS_BH(idev, ICMP6_MIB_INMSGS);
+	ICMP6_INC_STATS_BH(dev_net(dev), idev, ICMP6_MIB_INMSGS);
 
 	saddr = &ipv6_hdr(skb)->saddr;
 	daddr = &ipv6_hdr(skb)->daddr;
@@ -772,7 +772,7 @@ static int icmpv6_rcv(struct sk_buff *skb)
 	return 0;
 
 discard_it:
-	ICMP6_INC_STATS_BH(idev, ICMP6_MIB_INERRORS);
+	ICMP6_INC_STATS_BH(dev_net(dev), idev, ICMP6_MIB_INERRORS);
 drop_no_count:
 	kfree_skb(skb);
 	return 0;
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index f0fded6..e7eff32 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1483,7 +1483,7 @@ int ip6_push_pending_frames(struct sock *sk)
 		struct inet6_dev *idev = ip6_dst_idev(skb->dst);
 
 		ICMP6MSGOUT_INC_STATS_BH(idev, icmp6_hdr(skb)->icmp6_type);
-		ICMP6_INC_STATS_BH(idev, ICMP6_MIB_OUTMSGS);
+		ICMP6_INC_STATS_BH(net, idev, ICMP6_MIB_OUTMSGS);
 	}
 
 	err = ip6_local_out(skb);
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index fa413af..f06ceea 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1475,7 +1475,7 @@ static void mld_sendpack(struct sk_buff *skb)
 out:
 	if (!err) {
 		ICMP6MSGOUT_INC_STATS_BH(idev, ICMPV6_MLD2_REPORT);
-		ICMP6_INC_STATS_BH(idev, ICMP6_MIB_OUTMSGS);
+		ICMP6_INC_STATS_BH(net, idev, ICMP6_MIB_OUTMSGS);
 		IP6_INC_STATS_BH(net, idev, IPSTATS_MIB_OUTMCASTPKTS);
 	} else
 		IP6_INC_STATS_BH(net, idev, IPSTATS_MIB_OUTDISCARDS);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 6268d26..424d9c4 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -330,7 +330,8 @@ static void tcp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 			th->dest, &hdr->saddr, th->source, skb->dev->ifindex);
 
 	if (sk == NULL) {
-		ICMP6_INC_STATS_BH(__in6_dev_get(skb->dev), ICMP6_MIB_INERRORS);
+		ICMP6_INC_STATS_BH(net, __in6_dev_get(skb->dev),
+				   ICMP6_MIB_INERRORS);
 		return;
 	}
 
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index c78da3c..4124bbb 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -156,7 +156,7 @@ SCTP_STATIC void sctp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	skb->network_header   = saveip;
 	skb->transport_header = savesctp;
 	if (!sk) {
-		ICMP6_INC_STATS_BH(idev, ICMP6_MIB_INERRORS);
+		ICMP6_INC_STATS_BH(dev_net(skb->dev), idev, ICMP6_MIB_INERRORS);
 		goto out;
 	}
 
-- 
1.5.3.rc5

