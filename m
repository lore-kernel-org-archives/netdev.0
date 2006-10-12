From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] Question about potential problem in net/ipv4/route.c
Date: Wed, 11 Oct 2006 23:02:33 -0700 (PDT)
Message-ID: <20061011.230233.122062793.davem@davemloft.net>
References: <200610111511.19028.dada1@cosmosbay.com>
	<20061011.220506.76273501.davem@davemloft.net>
	<452DD724.4030502@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:51347
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1161250AbWJLGCk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Oct 2006 02:02:40 -0400
To: dada1@cosmosbay.com
In-Reply-To: <452DD724.4030502@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Thu, 12 Oct 2006 07:48:20 +0200

> Not on my gcc here (gcc version 3.4.4) : It wont zeros out the padding bytes

Patrick just proved this too :)

> Well, on this machine I have these oprofile numbers :
> 
> <rt_intern_hash>: /* rt_intern_hash total: 993464  0.3619 */
> 
>   31751  0.0116 :ffffffff803e8d26:   repz cmpsb %es:(%rdi),%ds:(%rsi)
> 433438  0.1579 :ffffffff803e8d28:   jne    ffffffff803e8f80 <rt_intern_hash+0x310>

Indeed, numbers talk bullshit walks :)

How about something like this as a start?

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index c41ddba..4d4b1bd 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -566,9 +566,13 @@ static inline u32 rt_score(struct rtable
 
 static inline int compare_keys(struct flowi *fl1, struct flowi *fl2)
 {
-	return memcmp(&fl1->nl_u.ip4_u, &fl2->nl_u.ip4_u, sizeof(fl1->nl_u.ip4_u)) == 0 &&
-	       fl1->oif     == fl2->oif &&
-	       fl1->iif     == fl2->iif;
+	return ((fl1->nl_u.ip4_u.daddr ^ fl2->nl_u.ip4_u.daddr) |
+		(fl1->nl_u.ip4_u.saddr ^ fl2->nl_u.ip4_u.saddr) |
+		(fl1->nl_u.ip4_u.fwmark ^ fl2->nl_u.ip4_u.fwmark) |
+		(*(u16 *)&fl1->nl_u.ip4_u.tos ^
+		 *(u16 *)&fl2->nl_u.ip4_u.tos) |
+		(fl1->oif ^ fl2->oif) |
+		(fl1->iif ^ fl2->iif)) == 0;
 }
 
 #ifdef CONFIG_IP_ROUTE_MULTIPATH_CACHED
