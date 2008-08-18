From: Yang Hongyang <yanghy@cn.fujitsu.com>
Subject: [PATCH] IPv6:fix the return interface index when get it while no
 message is received
Date: Mon, 18 Aug 2008 14:07:41 +0800
Message-ID: <48A911AD.7060102@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52481 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750829AbYHRGIQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Aug 2008 02:08:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When get receiving interface index while no message is received,
the bounded device's index of the socket should be returned.

RFC 3542:
   Issuing getsockopt() for the above options will return the sticky
   option value i.e., the value set with setsockopt().  If no sticky
   option value has been set getsockopt() will return the following
   values:

   -  For the IPV6_PKTINFO option, it will return an in6_pktinfo
      structure with ipi6_addr being in6addr_any and ipi6_ifindex being
      zero.


Signed-off-by: Yang Hongyang<yanghy@cn.fujitsu.com>

---
 ipv6_sockglue.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 2cabac9..e4f8d29 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -911,7 +911,7 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 		} else {
 			if (np->rxopt.bits.rxinfo) {
 				struct in6_pktinfo src_info;
-				src_info.ipi6_ifindex = np->mcast_oif;
+				src_info.ipi6_ifindex = np->mcast_oif ? np->mcast_oif : sk->sk_bound_dev_if;
 				ipv6_addr_copy(&src_info.ipi6_addr, &np->daddr);
 				put_cmsg(&msg, SOL_IPV6, IPV6_PKTINFO, sizeof(src_info), &src_info);
 			}
@@ -921,7 +921,7 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 			}
 			if (np->rxopt.bits.rxoinfo) {
 				struct in6_pktinfo src_info;
-				src_info.ipi6_ifindex = np->mcast_oif;
+				src_info.ipi6_ifindex = np->mcast_oif ? np->mcast_oif : sk->sk_bound_dev_if;
 				ipv6_addr_copy(&src_info.ipi6_addr, &np->daddr);
 				put_cmsg(&msg, SOL_IPV6, IPV6_2292PKTINFO, sizeof(src_info), &src_info);
 			}
-- 
1.5.3.8
