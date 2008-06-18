From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [RFC][PATCH] IPv6:Remove options header when setsockopt's optlen
 is 0
Date: Wed, 18 Jun 2008 14:42:05 +0800
Message-ID: <4858AE3D.6070101@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: =?GB2312?B?WU9TSElGVUpJIEhpZGVha2kgLyC8qszZ06LD9w==?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:57567 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1759566AbYFRGnL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jun 2008 02:43:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the sticky Hop-by-Hop options header by calling setsockopt() for IPV6_HOPOPTS
with a zero option length, per RFC3542.

Routing header and Destination options header does the same as Hop-by-Hop options header. 


Signed-off-by: Shan Wei<shanwei@cn.fujitsu.com>
---
 net/ipv6/ipv6_sockglue.c |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index c042ce1..86e28a7 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -345,18 +345,21 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 	case IPV6_DSTOPTS:
 	{
 		struct ipv6_txoptions *opt;
+
+		/* remove any sticky options header with a zero option
+		 * length, per RFC3542.
+		 */
 		if (optlen == 0)
 			optval = NULL;
+		else if (optlen < sizeof(struct ipv6_opt_hdr) ||
+			 optlen & 0x7 || optlen > 8 * 255)
+			goto e_inval;
 
 		/* hop-by-hop / destination options are privileged option */
 		retv = -EPERM;
 		if (optname != IPV6_RTHDR && !capable(CAP_NET_RAW))
 			break;
 
-		if (optlen < sizeof(struct ipv6_opt_hdr) ||
-		    optlen & 0x7 || optlen > 8 * 255)
-			goto e_inval;
-
 		opt = ipv6_renew_options(sk, np->opt, optname,
 					 (struct ipv6_opt_hdr __user *)optval,
 					 optlen);



