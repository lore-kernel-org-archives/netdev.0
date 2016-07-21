From: Chunhui He <hchunhui@mail.ustc.edu.cn>
Subject: [PATCH] net: neigh: disallow state transition DELAY->STALE in neigh_update()
Date: Thu, 21 Jul 2016 17:58:10 +0000
Message-ID: <1469123890-2715-1-git-send-email-hchunhui@mail.ustc.edu.cn>
Cc: Chunhui He <hchunhui@mail.ustc.edu.cn>,
	David Ahern <dsa@cumulusnetworks.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Robert Shearman <rshearma@brocade.com>,
	David Barroso <dbarroso@fastly.com>,
	Martin Zhang <martinbj2008@gmail.com>,
	Rick Jones <rick.jones2@hp.com>,
	Konstantin Khlebnikov <koct9i@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Thomas Graf <tgraf@suug.ch>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.ustc.edu.cn ([202.38.64.46]:54946 "EHLO ustc.edu.cn"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750884AbcGUSHI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jul 2016 14:07:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If neigh entry was CONNECTED and address is not changed, and if new state is
STALE, entry state will not change. Because DELAY is not in CONNECTED, it's
possible to change state from DELAY to STALE.

That is bad. Consider a host in IPv4 nerwork, a neigh entry in STALE state
is referenced to send packets, so goes to DELAY state. If the entry is not
confirmed by upper layer, it goes to PROBE state, and sends ARP request.
The neigh host sends ARP reply, then the entry goes to REACHABLE state.
But the entry state may be reseted to STALE by broadcast ARP packets, before
the entry goes to PROBE state. So it's possible that the entry will never go
to REACHABLE state, without external confirmation.

In my case, the gateway refuses to send unicast packets to me, before it sees
my ARP request. So it's critical to enter REACHABLE state by sending ARP
request, but not by external confirmation.

This fixes neigh_update() not to change to STALE if old state is CONNECTED or
DELAY.

Signed-off-by: Chunhui He <hchunhui@mail.ustc.edu.cn>
---
 net/core/neighbour.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 510cd62..29429eb 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -1152,7 +1152,7 @@ int neigh_update(struct neighbour *neigh, const u8 *lladdr, u8 new,
 		} else {
 			if (lladdr == neigh->ha && new == NUD_STALE &&
 			    ((flags & NEIGH_UPDATE_F_WEAK_OVERRIDE) ||
-			     (old & NUD_CONNECTED))
+			     (old & (NUD_CONNECTED | NUD_DELAY)))
 			    )
 				new = old;
 		}
-- 
2.1.4
