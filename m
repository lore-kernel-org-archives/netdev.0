From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] Question about potential problem in net/ipv4/route.c
Date: Wed, 11 Oct 2006 23:25:16 -0700 (PDT)
Message-ID: <20061011.232516.81465088.davem@davemloft.net>
References: <452DD724.4030502@cosmosbay.com>
	<20061011.230233.122062793.davem@davemloft.net>
	<452DDC63.2030707@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:33460
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932496AbWJLGZJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Oct 2006 02:25:09 -0400
To: kaber@trash.net
In-Reply-To: <452DDC63.2030707@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 12 Oct 2006 08:10:43 +0200

> David Miller wrote:
> > Indeed, numbers talk bullshit walks :)
> 
> :)
> 
> > How about something like this as a start?
> > 
> > diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> 
> The same problem is also present in dn_route.c (3 uninitialized
> bytes in dn_u).

This should take care of that case too:

diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index dd0761e..33ccc56 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -267,9 +267,12 @@ static void dn_dst_link_failure(struct s
 
 static inline int compare_keys(struct flowi *fl1, struct flowi *fl2)
 {
-	return memcmp(&fl1->nl_u.dn_u, &fl2->nl_u.dn_u, sizeof(fl1->nl_u.dn_u)) == 0 &&
-		fl1->oif == fl2->oif &&
-		fl1->iif == fl2->iif;
+	return ((fl1->nl_u.dn_u.daddr ^ fl2->nl_u.dn_u.daddr) |
+		(fl1->nl_u.dn_u.saddr ^ fl2->nl_u.dn_u.saddr) |
+		(fl1->nl_u.dn_u.fwmark ^ fl2->nl_u.dn_u.fwmark) |
+		(fl1->nl_u.dn_u.scope ^ fl2->nl_u.dn_u.scope) |
+		(fl1->oif ^ fl2->oif) |
+		(fl1->iif ^ fl2->iif)) == 0;
 }
 
 static int dn_insert_route(struct dn_route *rt, unsigned hash, struct dn_route **rp)
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
