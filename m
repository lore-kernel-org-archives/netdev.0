From: Michal Kubecek <mkubecek@suse.cz>
Subject: [PATCH net v3 1/2] ipv6: do not delete previously existing ECMP
 routes if add fails
Date: Mon, 18 May 2015 20:53:55 +0200 (CEST)
Message-ID: <424c88b76fd2470d5e8c8f74b8ea6a72b6640fab.1431974706.git.mkubecek@suse.cz>
References: <cover.1431974706.git.mkubecek@suse.cz>
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	roopa <roopa@cumulusnetworks.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:37616 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932623AbbERSx5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 May 2015 14:53:57 -0400
In-Reply-To: <cover.1431974706.git.mkubecek@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If adding a nexthop of an IPv6 multipath route fails, comment in
ip6_route_multipath() says we are going to delete all nexthops already
added. However, current implementation deletes even the routes it
hasn't even tried to add yet. For example, running

  ip route add 1234:5678::/64 \
      nexthop via fe80::aa dev dummy1 \
      nexthop via fe80::bb dev dummy1 \
      nexthop via fe80::cc dev dummy1

twice results in removing all routes first command added.

Limit the second (delete) run to nexthops that succeeded in the first
(add) run.

Fixes: 51ebd3181572 ("ipv6: add support of equal cost multipath (ECMP)")
Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/route.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index d3588885f097..3821a3517478 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2504,9 +2504,9 @@ static int ip6_route_multipath(struct fib6_config *cfg, int add)
 	int attrlen;
 	int err = 0, last_err = 0;
 
+	remaining = cfg->fc_mp_len;
 beginning:
 	rtnh = (struct rtnexthop *)cfg->fc_mp;
-	remaining = cfg->fc_mp_len;
 
 	/* Parse a Multipath Entry */
 	while (rtnh_ok(rtnh, remaining)) {
@@ -2536,6 +2536,7 @@ beginning:
 				 * next hops that have been already added.
 				 */
 				add = 0;
+				remaining = cfg->fc_mp_len - remaining;
 				goto beginning;
 			}
 		}
-- 
2.4.1
