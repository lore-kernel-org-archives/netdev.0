From: nakam@linux-ipv6.org
Subject: [PATCH 1/2] [IPV6] MIP6: Kill unnecessary ifdefs.
Date: Wed, 23 May 2007 16:50:18 +0900
Message-ID: <1179906618559-git-send-email-nakam@linux-ipv6.org>
Cc: netdev@vger.kernel.org, Masahide NAKAMURA <nakam@linux-ipv6.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi025.linux-ipv6.org ([203.178.140.25]:38370 "EHLO
	triton.linux-ipv6.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1755935AbXEWIPk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 May 2007 04:15:40 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>

Kill unnecessary CONFIG_IPV6_MIP6.

o It is redundant for RAW socket to keep MH out with the config then
  it can handle any protocol.
o Clean-up at AH.

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
---
 include/net/flow.h |    4 ----
 include/net/xfrm.h |    2 --
 net/ipv6/ah6.c     |    4 ++--
 net/ipv6/raw.c     |    4 ----
 4 files changed, 2 insertions(+), 12 deletions(-)

diff --git a/include/net/flow.h b/include/net/flow.h
index f3cc1f8..af59fa5 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -67,20 +67,16 @@ struct flowi {
 
 		__be32		spi;
 
-#ifdef CONFIG_IPV6_MIP6
 		struct {
 			__u8	type;
 		} mht;
-#endif
 	} uli_u;
 #define fl_ip_sport	uli_u.ports.sport
 #define fl_ip_dport	uli_u.ports.dport
 #define fl_icmp_type	uli_u.icmpt.type
 #define fl_icmp_code	uli_u.icmpt.code
 #define fl_ipsec_spi	uli_u.spi
-#ifdef CONFIG_IPV6_MIP6
 #define fl_mh_type	uli_u.mht.type
-#endif
 	__u32           secid;	/* used by xfrm; see secid.txt */
 } __attribute__((__aligned__(BITS_PER_LONG/8)));
 
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 39ef925..1e53520 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -510,11 +510,9 @@ __be16 xfrm_flowi_sport(struct flowi *fl)
 	case IPPROTO_ICMPV6:
 		port = htons(fl->fl_icmp_type);
 		break;
-#ifdef CONFIG_IPV6_MIP6
 	case IPPROTO_MH:
 		port = htons(fl->fl_mh_type);
 		break;
-#endif
 	default:
 		port = 0;	/*XXX*/
 	}
diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index b696c84..17b8771 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -132,6 +132,8 @@ static void ipv6_rearrange_destopt(struct ipv6hdr *iph, struct ipv6_opt_hdr *des
 bad:
 	return;
 }
+#else
+static void ipv6_rearrange_destopt(struct ipv6hdr *iph, struct ipv6_opt_hdr *destopt) {}
 #endif
 
 /**
@@ -189,10 +191,8 @@ static int ipv6_clear_mutable_options(struct ipv6hdr *iph, int len, int dir)
 	while (exthdr.raw < end) {
 		switch (nexthdr) {
 		case NEXTHDR_DEST:
-#ifdef CONFIG_IPV6_MIP6
 			if (dir == XFRM_POLICY_OUT)
 				ipv6_rearrange_destopt(iph, exthdr.opth);
-#endif
 		case NEXTHDR_HOP:
 			if (!zero_out_mutable_opts(exthdr.opth)) {
 				LIMIT_NETDEBUG(
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 009a104..71a656d 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -611,9 +611,7 @@ static int rawv6_probe_proto_opt(struct flowi *fl, struct msghdr *msg)
 	struct iovec *iov;
 	u8 __user *type = NULL;
 	u8 __user *code = NULL;
-#ifdef CONFIG_IPV6_MIP6
 	u8 len = 0;
-#endif
 	int probed = 0;
 	int i;
 
@@ -646,7 +644,6 @@ static int rawv6_probe_proto_opt(struct flowi *fl, struct msghdr *msg)
 				probed = 1;
 			}
 			break;
-#ifdef CONFIG_IPV6_MIP6
 		case IPPROTO_MH:
 			if (iov->iov_base && iov->iov_len < 1)
 				break;
@@ -660,7 +657,6 @@ static int rawv6_probe_proto_opt(struct flowi *fl, struct msghdr *msg)
 				len += iov->iov_len;
 
 			break;
-#endif
 		default:
 			probed = 1;
 			break;
-- 
1.4.4.2

