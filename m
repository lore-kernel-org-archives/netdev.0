From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH 1/2] [IPV6]: Return correct result for sticky options.
Date: Fri, 09 Mar 2007 10:11:52 +0900 (JST)
Message-ID: <20070309.101152.77796563.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:34450 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2992856AbXCIBL0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Mar 2007 20:11:26 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We returned incorrect result with IPV6_RTHDRDSTOPTS, IPV6_RTHDR and
IPV6_DSTOPTS.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/ipv6_sockglue.c |   27 +++++++++++++++++++++++----
 1 files changed, 23 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 4e0561a..44ccdf0 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -796,13 +796,32 @@ EXPORT_SYMBOL(compat_ipv6_setsockopt);
 #endif
 
 static int ipv6_getsockopt_sticky(struct sock *sk, struct ipv6_txoptions *opt,
-				  char __user *optval, int len)
+				  int optname, char __user *optval, int len)
 {
 	struct ipv6_opt_hdr *hdr;
 
-	if (!opt || !opt->hopopt)
+	if (!opt)
+		return 0;
+
+	switch(optname) {
+	case IPV6_HOPOPTS:
+		hdr = opt->hopopt;
+		break;
+	case IPV6_RTHDRDSTOPTS:
+		hdr = opt->dst0opt;
+		break;
+	case IPV6_RTHDR:
+		hdr = (struct ipv6_opt_hdr *)opt->srcrt;
+		break;
+	case IPV6_DSTOPTS:
+		hdr = opt->dst1opt;
+		break;
+	default:
+		return -EINVAL;	/* should not happen */
+	}
+
+	if (!hdr)
 		return 0;
-	hdr = opt->hopopt;
 
 	len = min_t(int, len, ipv6_optlen(hdr));
 	if (copy_to_user(optval, hdr, ipv6_optlen(hdr)))
@@ -945,7 +964,7 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 
 		lock_sock(sk);
 		len = ipv6_getsockopt_sticky(sk, np->opt,
-					     optval, len);
+					     optname, optval, len);
 		release_sock(sk);
 		return put_user(len, optlen);
 	}
-- 
1.4.4.1.g562ce

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
