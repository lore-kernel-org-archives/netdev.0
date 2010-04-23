From: Brian Haley <brian.haley@hp.com>
Subject: [PATCH 1/3] IPv6: data structure changes for new socket options
Date: Fri, 23 Apr 2010 17:26:07 -0400
Message-ID: <1272057969-6526-2-git-send-email-brian.haley@hp.com>
References: <>
 <1272057969-6526-1-git-send-email-brian.haley@hp.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0185.atlanta.hp.com ([15.193.32.62]:42503 "EHLO
	g6t0185.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752370Ab0DWVei (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Apr 2010 17:34:38 -0400
In-Reply-To: <1272057969-6526-1-git-send-email-brian.haley@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add underlying data structure changes and basic setsockopt()
and getsockopt() support for IPV6_RECVPATHMTU, IPV6_PATHMTU,
and IPV6_DONTFRAG.  IPV6_PATHMTU is actually fully functional
at this point.

Signed-off-by: Brian Haley <brian.haley@hp.com>
---
 include/linux/in6.h      |    2 +-
 include/linux/ipv6.h     |   13 ++++++++++---
 net/ipv6/ipv6_sockglue.c |   46 ++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 57 insertions(+), 4 deletions(-)

diff --git a/include/linux/in6.h b/include/linux/in6.h
index 9b90cb2..c4bf46f 100644
--- a/include/linux/in6.h
+++ b/include/linux/in6.h
@@ -221,10 +221,10 @@ struct in6_flowlabel_req {
 #define IPV6_RTHDR		57
 #define IPV6_RECVDSTOPTS	58
 #define IPV6_DSTOPTS		59
-#if 0	/* not yet */
 #define IPV6_RECVPATHMTU	60
 #define IPV6_PATHMTU		61
 #define IPV6_DONTFRAG		62
+#if 0	/* not yet */
 #define IPV6_USE_MIN_MTU	63
 #endif
 
diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 1bdbebf..1976942 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -21,6 +21,10 @@ struct in6_pktinfo {
 	int		ipi6_ifindex;
 };
 
+struct ip6_mtuinfo {
+	struct sockaddr_in6	ip6m_addr;
+	__u32			ip6m_mtu;
+};
 
 struct in6_ifreq {
 	struct in6_addr	ifr6_addr;
@@ -334,22 +338,25 @@ struct ipv6_pinfo {
 				dstopts:1,
 				odstopts:1,
                                 rxflow:1,
-				rxtclass:1;
+				rxtclass:1,
+				rxpmtu:1;
 		} bits;
 		__u16		all;
 	} rxopt;
 
 	/* sockopt flags */
-	__u8			recverr:1,
+	__u16			recverr:1,
 	                        sndflow:1,
 				pmtudisc:2,
 				ipv6only:1,
-				srcprefs:3;	/* 001: prefer temporary address
+				srcprefs:3,	/* 001: prefer temporary address
 						 * 010: prefer public address
 						 * 100: prefer care-of address
 						 */
+				dontfrag:1;
 	__u8			min_hopcount;
 	__u8			tclass;
+	__u8			padding;
 
 	__u32			dst_cookie;
 
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 92295ad..2bf9eda 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -337,6 +337,13 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 		retv = 0;
 		break;
 
+	case IPV6_RECVPATHMTU:
+		if (optlen < sizeof(int))
+			goto e_inval;
+		np->rxopt.bits.rxpmtu = valbool;
+		retv = 0;
+		break;
+
 	case IPV6_HOPOPTS:
 	case IPV6_RTHDRDSTOPTS:
 	case IPV6_RTHDR:
@@ -773,6 +780,9 @@ pref_skip_coa:
 		if (val < 0 || val > 255)
 			goto e_inval;
 		np->min_hopcount = val;
+		break;
+	case IPV6_DONTFRAG:
+		np->dontfrag = valbool;
 		retv = 0;
 		break;
 	}
@@ -1063,6 +1073,38 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 		val = np->rxopt.bits.rxflow;
 		break;
 
+	case IPV6_RECVPATHMTU:
+		val = np->rxopt.bits.rxpmtu;
+		break;
+
+	case IPV6_PATHMTU:
+	{
+		struct dst_entry *dst;
+		struct ip6_mtuinfo mtuinfo;
+
+		if (len < sizeof(mtuinfo))
+			return -EINVAL;
+
+		len = sizeof(mtuinfo);
+		memset(&mtuinfo, 0, sizeof(mtuinfo));
+
+		rcu_read_lock();
+		dst = __sk_dst_get(sk);
+		if (dst)
+			mtuinfo.ip6m_mtu = dst_mtu(dst);
+		rcu_read_unlock();
+		if (!mtuinfo.ip6m_mtu)
+			return -ENOTCONN;
+
+		if (put_user(len, optlen))
+			return -EFAULT;
+		if (copy_to_user(optval, &mtuinfo, len))
+			return -EFAULT;
+
+		return 0;
+		break;
+	}
+
 	case IPV6_UNICAST_HOPS:
 	case IPV6_MULTICAST_HOPS:
 	{
@@ -1128,6 +1170,10 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 		val = np->min_hopcount;
 		break;
 
+	case IPV6_DONTFRAG:
+		val = np->dontfrag;
+		break;
+
 	default:
 		return -ENOPROTOOPT;
 	}
-- 
1.5.4.3

