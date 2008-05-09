From: David Miller <davem@davemloft.net>
Subject: Re: When should kfree_skb be used?
Date: Thu, 08 May 2008 23:41:22 -0700 (PDT)
Message-ID: <20080508.234122.20422788.davem@davemloft.net>
References: <8e5b27790805082149y6d9f604ds7feefe2804f3823c@mail.gmail.com>
	<8e5b27790805082334g6c5a1752pd42ab291ac6b33af@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: paul@pmarks.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42951
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750708AbYEIGl3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2008 02:41:29 -0400
In-Reply-To: <8e5b27790805082334g6c5a1752pd42ab291ac6b33af@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Paul Marks" <paul@pmarks.net>
Date: Thu, 8 May 2008 23:34:59 -0700

> I've been looking at more uses of pskb_may_pull(), and almost all of
> them seem to kfree_skb() after a failure.  Could this occurence in
> sit.c be a bug?  It looks like this line was added by davem for linux
> 2.4.4 in 2001, and hasn't changed since.

Yep, looks like a leak.  The following should fix it, thanks
for the report:

>From 36ca34cc3b8335eb1fe8bd9a1d0a2592980c3f02 Mon Sep 17 00:00:00 2001
From: David S. Miller <davem@davemloft.net>
Date: Thu, 8 May 2008 23:40:26 -0700
Subject: [PATCH] sit: Add missing kfree_skb() on pskb_may_pull() failure.

Noticed by Paul Marks <paul@pmarks.net>.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv6/sit.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 4b2f103..5a6fab9 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -596,9 +596,9 @@ static int ipip6_rcv(struct sk_buff *skb)
 	}
 
 	icmp_send(skb, ICMP_DEST_UNREACH, ICMP_PORT_UNREACH, 0);
-	kfree_skb(skb);
 	read_unlock(&ipip6_lock);
 out:
+	kfree_skb(skb);
 	return 0;
 }
 
-- 
1.5.5.1.57.g5909c

