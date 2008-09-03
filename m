From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [PATCH RESEND] ipv6: return with appropriate error code when sending
 RH0 using setsockopt()
Date: Wed, 03 Sep 2008 16:41:06 +0800
Message-ID: <48BE4DA2.20800@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:57541 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750773AbYICInH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2008 04:43:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 I'm sorry to resend the patch, for that no one replied it from Jun 27.

 The kernel had removed the RH0(Type 0 Routing Header), but we can still
 send IPv6 packet with RH0 using sendmsg() or setsockopt().

 Compare with sendmsg() that returns EINVAL, but setsockopt() return EPERM.
 The patch fix it.

Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
---
 net/ipv6/ipv6_sockglue.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 4e5eac3..7a58597 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -353,9 +353,10 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 			goto e_inval;
 
 		/* hop-by-hop / destination options are privileged option */
-		retv = -EPERM;
-		if (optname != IPV6_RTHDR && !capable(CAP_NET_RAW))
+		if (optname != IPV6_RTHDR && !capable(CAP_NET_RAW)) {
+			retv = -EPERM;
 			break;
+		}
 
 		opt = ipv6_renew_options(sk, np->opt, optname,
 					 (struct ipv6_opt_hdr __user *)optval,
@@ -365,6 +366,7 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 			break;
 		}
 
+		retv = -EINVAL;
 		/* routing header option needs extra check */
 		if (optname == IPV6_RTHDR && opt && opt->srcrt) {
 			struct ipv6_rt_hdr *rthdr = opt->srcrt;
-- 
1.6.0


