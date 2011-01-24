From: David Miller <davem@davemloft.net>
Subject: Re: Problems with /proc/net/tcp6 - possible bug - ipv6
Date: Mon, 24 Jan 2011 14:40:25 -0800 (PST)
Message-ID: <20110124.144025.189712500.davem@davemloft.net>
References: <115440.16148.qm@web63902.mail.re1.yahoo.com>
	<1295731235.2651.66.camel@edumazet-laptop>
	<1295732444.2651.68.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: runningdoglackey@yahoo.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1295732444.2651.68.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 22 Jan 2011 22:40:44 +0100

> In my testings, I even have crashes in cleanup_once() if I
> enable /proc/sys/net/ipv4/tcp_tw_recycle 

Luckily, this bug was easy to fix, I've just committed the
following to net-2.6

The other crash (the !RTF_CACHE WARN assertion) I'm looking
into now.

--------------------
>From 1c5642cf754939c318a0230b0f546a9e20888292 Mon Sep 17 00:00:00 2001
From: David S. Miller <davem@davemloft.net>
Date: Mon, 24 Jan 2011 14:37:46 -0800
Subject: [PATCH] inetpeer: Use correct AVL tree base pointer in inet_getpeer().

Family was hard-coded to AF_INET but should be daddr->family.

This fixes crashes when unlinking ipv6 peer entries, since the
unlink code was looking up the base pointer properly.

Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/inetpeer.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index d9bc857..a96e656 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -475,7 +475,7 @@ static int cleanup_once(unsigned long ttl)
 struct inet_peer *inet_getpeer(struct inetpeer_addr *daddr, int create)
 {
 	struct inet_peer __rcu **stack[PEER_MAXDEPTH], ***stackptr;
-	struct inet_peer_base *base = family_to_base(AF_INET);
+	struct inet_peer_base *base = family_to_base(daddr->family);
 	struct inet_peer *p;
 
 	/* Look up for the address quickly, lockless.
-- 
1.7.3.4
