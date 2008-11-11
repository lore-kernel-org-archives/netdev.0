From: Brian Haley <brian.haley@hp.com>
Subject: [PATCH] ipv6: routing header fixes
Date: Tue, 11 Nov 2008 17:11:43 -0500
Message-ID: <491A031F.40901@hp.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080601040304090305060700"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Shan Wei <shanwei@cn.fujitsu.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:4618 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751006AbYKKWMI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2008 17:12:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080601040304090305060700
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch fixes two bugs:

1. setsockopt() of anything but a Type 2 routing header should return 
EINVAL instead of EPERM.  Noticed by Shan Wei (shanwei@cn.fujitsu.com).

2. setsockopt()/sendmsg() of a Type 2 routing header with invalid length 
or segments should return EINVAL.  These values are statically fixed in 
RFC 3775, unlike the variable Type 0 was.

Signed-off-by: Brian Haley <brian.haley@hp.com>

--------------080601040304090305060700
Content-Type: text/x-diff;
 name="rthdr2.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="rthdr2.patch"

diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 410046a..e44deb8 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -661,6 +661,11 @@ int datagram_send_ctl(struct net *net,
 			switch (rthdr->type) {
 #if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
 			case IPV6_SRCRT_TYPE_2:
+				if (rthdr->hdrlen != 2 ||
+				    rthdr->segments_left != 1) {
+					err = -EINVAL;
+					goto exit_f;
+				}
 				break;
 #endif
 			default:
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 4e5eac3..2aa294b 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -366,11 +366,16 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 		}
 
 		/* routing header option needs extra check */
+		retv = -EINVAL;
 		if (optname == IPV6_RTHDR && opt && opt->srcrt) {
 			struct ipv6_rt_hdr *rthdr = opt->srcrt;
 			switch (rthdr->type) {
 #if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
 			case IPV6_SRCRT_TYPE_2:
+				if (rthdr->hdrlen != 2 ||
+				    rthdr->segments_left != 1)
+					goto sticky_done;
+
 				break;
 #endif
 			default:

--------------080601040304090305060700--
