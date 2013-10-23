From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next 1/3] ipv4: initialize ip4_frags hash secret as late as possible
Date: Wed, 23 Oct 2013 11:06:55 +0200
Message-ID: <1382519217-750-2-git-send-email-hannes@stressinduktion.org>
References: <1382519217-750-1-git-send-email-hannes@stressinduktion.org>
Cc: netfilter-devel@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:52241 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751568Ab3JWJHO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 05:07:14 -0400
In-Reply-To: <1382519217-750-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Defer the generation of the first hash secret for the ipv4 fragmentation
cache as late as possible.

ip4_frags.rnd gets initial seeded by inet_frags_init and regulary
reseeded by inet_frag_secret_rebuild. Either we call ipqhashfn directly
from ip_fragment.c in which case we initialize the secret directly.

If we first get called by inet_frag_secret_rebuild we install a new secret
by a manual call to get_random_bytes. This secret will be overwritten
as soon as the first call to ipqhashfn happens. This is safe because we
won't race while publishing the new secrets with anyone else.

Cc: Eric Dumazet <edumazet@google.com>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv4/ip_fragment.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index b66910a..2481993 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -106,6 +106,7 @@ struct ip4_create_arg {
 
 static unsigned int ipqhashfn(__be16 id, __be32 saddr, __be32 daddr, u8 prot)
 {
+	net_get_random_once(&ip4_frags.rnd, sizeof(ip4_frags.rnd));
 	return jhash_3words((__force u32)id << 16 | prot,
 			    (__force u32)saddr, (__force u32)daddr,
 			    ip4_frags.rnd) & (INETFRAGS_HASHSZ - 1);
-- 
1.8.3.1
