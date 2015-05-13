From: Michal Kubecek <mkubecek@suse.cz>
Subject: [PATCH net 1/2] ipv6: do not delete previously existing ECMP routes
 if add fails
Date: Wed, 13 May 2015 11:50:35 +0200 (CEST)
Message-ID: <4e3d075f2be93d9655bc1372a107584368a29eab.1431500953.git.mkubecek@suse.cz>
References: <cover.1431500953.git.mkubecek@suse.cz>
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:37794 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933700AbbEMJuh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 May 2015 05:50:37 -0400
In-Reply-To: <cover.1431500953.git.mkubecek@suse.cz>
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
---
 net/ipv6/route.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index d3588885f097..18b92c05b541 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2536,6 +2536,7 @@ beginning:
 				 * next hops that have been already added.
 				 */
 				add = 0;
+				remaining = cfg->fc_mp_len - remaining;
 				goto beginning;
 			}
 		}
-- 
2.3.7
