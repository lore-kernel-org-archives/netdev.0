From: Xiaotian Feng <dfeng@redhat.com>
Subject: [PATCH] net dst: fix percpu_counter list corruption and poison overwritten
Date: Wed,  3 Nov 2010 10:11:05 +0800
Message-ID: <1288750265-17664-1-git-send-email-dfeng@redhat.com>
Cc: linux-kernel@vger.kernel.org, Xiaotian Feng <dfeng@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40039 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751193Ab0KCCMI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Nov 2010 22:12:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There're some percpu_counter list corruption and poison overwritten warnings
in recent kernel, which is resulted by fc66f95c.

commit fc66f95c switches to use percpu_counter, in ip6_route_net_init, kernel
init the percpu_counter for dst entries, but, the percpu_counter is never destroyed
in ip6_route_net_exit. So if the related data is freed by kernel, the freed percpu_counter
is still on the list, then if we insert/remove other percpu_counter, list corruption
resulted. Also, if the insert/remove option modifies the ->prev,->next pointer of
the freed value, the poison overwritten is resulted then.

With the following patch, the percpu_counter list corruption and poison overwritten
warnings disappeared.

Signed-off-by: Xiaotian Feng <dfeng@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: "Pekka Savola (ipv6)" <pekkas@netcore.fi>
Cc: James Morris <jmorris@namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>
---
 net/ipv6/route.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 25661f9..fc32833 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2741,6 +2741,7 @@ static void __net_exit ip6_route_net_exit(struct net *net)
 	kfree(net->ipv6.ip6_prohibit_entry);
 	kfree(net->ipv6.ip6_blk_hole_entry);
 #endif
+	dst_entries_destroy(&net->ipv6.ip6_dst_ops);
 }
 
 static struct pernet_operations ip6_route_net_ops = {
@@ -2832,5 +2833,6 @@ void ip6_route_cleanup(void)
 	xfrm6_fini();
 	fib6_gc_cleanup();
 	unregister_pernet_subsys(&ip6_route_net_ops);
+	dst_entries_destroy(&ip6_dst_blackhole_ops);
 	kmem_cache_destroy(ip6_dst_ops_template.kmem_cachep);
 }
-- 
1.7.3.2

