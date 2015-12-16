From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next] ipv6: add IPV6_HDRINCL option for raw sockets
Date: Wed, 16 Dec 2015 17:22:47 +0100
Message-ID: <1450282967-3184-1-git-send-email-hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:39086 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753192AbbLPQWy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2015 11:22:54 -0500
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id 9A9D620C91
	for <netdev@vger.kernel.org>; Wed, 16 Dec 2015 11:22:53 -0500 (EST)
Received: from z.localhost.localdomain (unknown [217.192.177.51])
	by mail.messagingengine.com (Postfix) with ESMTPA id 19BD4680133
	for <netdev@vger.kernel.org>; Wed, 16 Dec 2015 11:22:52 -0500 (EST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Same as in Windows, we miss IPV6_HDRINCL for SOL_IPV6 and SOL_RAW.
The SOL_IP/IP_HDRINCL is not available for IPv6 sockets.

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/uapi/linux/in6.h |  1 +
 net/ipv6/raw.c           | 20 ++++++++++++++++----
 2 files changed, 17 insertions(+), 4 deletions(-)

diff --git a/include/uapi/linux/in6.h b/include/uapi/linux/in6.h
index 79b12b004ade03..318a4828bf98c2 100644
--- a/include/uapi/linux/in6.h
+++ b/include/uapi/linux/in6.h
@@ -196,6 +196,7 @@ struct in6_flowlabel_req {
 
 #define IPV6_IPSEC_POLICY	34
 #define IPV6_XFRM_POLICY	35
+#define IPV6_HDRINCL		36
 #endif
 
 /*
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 99140986e88716..fa59dd7a427e88 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -972,6 +972,11 @@ static int do_rawv6_setsockopt(struct sock *sk, int level, int optname,
 		return -EFAULT;
 
 	switch (optname) {
+	case IPV6_HDRINCL:
+		if (sk->sk_type != SOCK_RAW)
+			return -EINVAL;
+		inet_sk(sk)->hdrincl = !!val;
+		return 0;
 	case IPV6_CHECKSUM:
 		if (inet_sk(sk)->inet_num == IPPROTO_ICMPV6 &&
 		    level == IPPROTO_IPV6) {
@@ -1016,7 +1021,8 @@ static int rawv6_setsockopt(struct sock *sk, int level, int optname,
 			return -EOPNOTSUPP;
 		return rawv6_seticmpfilter(sk, level, optname, optval, optlen);
 	case SOL_IPV6:
-		if (optname == IPV6_CHECKSUM)
+		if (optname == IPV6_CHECKSUM ||
+		    optname == IPV6_HDRINCL)
 			break;
 	default:
 		return ipv6_setsockopt(sk, level, optname, optval, optlen);
@@ -1037,7 +1043,8 @@ static int compat_rawv6_setsockopt(struct sock *sk, int level, int optname,
 			return -EOPNOTSUPP;
 		return rawv6_seticmpfilter(sk, level, optname, optval, optlen);
 	case SOL_IPV6:
-		if (optname == IPV6_CHECKSUM)
+		if (optname == IPV6_CHECKSUM ||
+		    optname == IPV6_HDRINCL)
 			break;
 	default:
 		return compat_ipv6_setsockopt(sk, level, optname,
@@ -1057,6 +1064,9 @@ static int do_rawv6_getsockopt(struct sock *sk, int level, int optname,
 		return -EFAULT;
 
 	switch (optname) {
+	case IPV6_HDRINCL:
+		val = inet_sk(sk)->hdrincl;
+		break;
 	case IPV6_CHECKSUM:
 		/*
 		 * We allow getsockopt() for IPPROTO_IPV6-level
@@ -1094,7 +1104,8 @@ static int rawv6_getsockopt(struct sock *sk, int level, int optname,
 			return -EOPNOTSUPP;
 		return rawv6_geticmpfilter(sk, level, optname, optval, optlen);
 	case SOL_IPV6:
-		if (optname == IPV6_CHECKSUM)
+		if (optname == IPV6_CHECKSUM ||
+		    optname == IPV6_HDRINCL)
 			break;
 	default:
 		return ipv6_getsockopt(sk, level, optname, optval, optlen);
@@ -1115,7 +1126,8 @@ static int compat_rawv6_getsockopt(struct sock *sk, int level, int optname,
 			return -EOPNOTSUPP;
 		return rawv6_geticmpfilter(sk, level, optname, optval, optlen);
 	case SOL_IPV6:
-		if (optname == IPV6_CHECKSUM)
+		if (optname == IPV6_CHECKSUM ||
+		    optname == IPV6_HDRINCL)
 			break;
 	default:
 		return compat_ipv6_getsockopt(sk, level, optname,
-- 
2.5.0
