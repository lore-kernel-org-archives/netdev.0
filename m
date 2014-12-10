From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 1/3] netlink: use jhash as hashfn for rhashtable
Date: Wed, 10 Dec 2014 16:33:10 +0100
Message-ID: <1418225592-29322-2-git-send-email-dborkman@redhat.com>
References: <1418225592-29322-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, tgraf@suug.ch, hannes@stressinduktion.org,
	Herbert Xu <herbert@gondor.apana.org.au>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37962 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756341AbaLJPfo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Dec 2014 10:35:44 -0500
In-Reply-To: <1418225592-29322-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For netlink, we shouldn't be using arch_fast_hash() as a hashing
discipline, but rather jhash() instead.

Since netlink sockets can be opened by any user, a local attacker
would be able to easily create collisions with the DPDK-derived
arch_fast_hash(), which trades off performance for security by
using crc32 CPU instructions on x86_64.

While it might have a legimite use case in other places, it should
be avoided in netlink context, though. As rhashtable's API is very
flexible, we could later on still decide on other hashing disciplines,
if legitimate.

Reference: http://thread.gmane.org/gmane.linux.kernel/1844123
Fixes: e341694e3eb5 ("netlink: Convert netlink_lookup() to use RCU protected hash table")
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Acked-by: Thomas Graf <tgraf@suug.ch>
Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/netlink/af_netlink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 63aa5c8..9642e52 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -3129,7 +3129,7 @@ static int __init netlink_proto_init(void)
 		.head_offset = offsetof(struct netlink_sock, node),
 		.key_offset = offsetof(struct netlink_sock, portid),
 		.key_len = sizeof(u32), /* portid */
-		.hashfn = arch_fast_hash,
+		.hashfn = jhash,
 		.max_shift = 16, /* 64K */
 		.grow_decision = rht_grow_above_75,
 		.shrink_decision = rht_shrink_below_30,
-- 
1.7.11.7
