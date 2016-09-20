From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net v2] ipmr, ip6mr: return lastuse relative to now
Date: Tue, 20 Sep 2016 16:17:22 +0200
Message-ID: <1474381042-15344-1-git-send-email-nikolay@cumulusnetworks.com>
References: <063D6719AE5E284EB5DD2968C1650D6DB0104872@AcuExch.aculab.com>
Cc: roopa@cumulusnetworks.com, sashok@cumulusnetworks.com,
        davem@davemloft.net, David.Laight@ACULAB.COM,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:35688 "EHLO
        mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754395AbcITOSS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 10:18:18 -0400
Received: by mail-wm0-f51.google.com with SMTP id l132so211935772wmf.0
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 07:18:18 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB0104872@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When I introduced the lastuse member I made a subtle error because it was
returned as an absolute value but that is meaningless to user-space as it
doesn't allow to see how old exactly an entry is. Let's make it similar to
how the bridge returns such values and make it relative to "now" (jiffies).
This allows us to show the actual age of the entries and is much more
useful (e.g. user-space daemons can age out entries, iproute2 can display
the lastuse properly).

Fixes: 43b9e1274060 ("net: ipmr/ip6mr: add support for keeping an entry age")
Reported-by: Satish Ashok <sashok@cumulusnetworks.com>
Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
v2: make sure lastuse is before or equal to jiffies as per David Laight's
comment

I realize that this changes the way it is exported, but since it hasn't
been in a release yet and we're most probably the only users, I think it is
worth fixing. This change allows user-space daemons to age out entries and
also for the lastuse value to be shown properly via iproute2.

 net/ipv4/ipmr.c  | 7 +++++--
 net/ipv6/ip6mr.c | 7 +++++--
 2 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 26253328d227..a87bcd2d4a94 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -2076,6 +2076,7 @@ static int __ipmr_fill_mroute(struct mr_table *mrt, struct sk_buff *skb,
 	struct rta_mfc_stats mfcs;
 	struct nlattr *mp_attr;
 	struct rtnexthop *nhp;
+	unsigned long lastuse;
 	int ct;
 
 	/* If cache is unresolved, don't try to parse IIF and OIF */
@@ -2105,12 +2106,14 @@ static int __ipmr_fill_mroute(struct mr_table *mrt, struct sk_buff *skb,
 
 	nla_nest_end(skb, mp_attr);
 
+	lastuse = READ_ONCE(c->mfc_un.res.lastuse);
+	lastuse = time_after_eq(jiffies, lastuse) ? jiffies - lastuse : 0;
+
 	mfcs.mfcs_packets = c->mfc_un.res.pkt;
 	mfcs.mfcs_bytes = c->mfc_un.res.bytes;
 	mfcs.mfcs_wrong_if = c->mfc_un.res.wrong_if;
 	if (nla_put_64bit(skb, RTA_MFC_STATS, sizeof(mfcs), &mfcs, RTA_PAD) ||
-	    nla_put_u64_64bit(skb, RTA_EXPIRES,
-			      jiffies_to_clock_t(c->mfc_un.res.lastuse),
+	    nla_put_u64_64bit(skb, RTA_EXPIRES, jiffies_to_clock_t(lastuse),
 			      RTA_PAD))
 		return -EMSGSIZE;
 
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 6122f9c5cc49..fccb5dd91902 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -2239,6 +2239,7 @@ static int __ip6mr_fill_mroute(struct mr6_table *mrt, struct sk_buff *skb,
 	struct rta_mfc_stats mfcs;
 	struct nlattr *mp_attr;
 	struct rtnexthop *nhp;
+	unsigned long lastuse;
 	int ct;
 
 	/* If cache is unresolved, don't try to parse IIF and OIF */
@@ -2269,12 +2270,14 @@ static int __ip6mr_fill_mroute(struct mr6_table *mrt, struct sk_buff *skb,
 
 	nla_nest_end(skb, mp_attr);
 
+	lastuse = READ_ONCE(c->mfc_un.res.lastuse);
+	lastuse = time_after_eq(jiffies, lastuse) ? jiffies - lastuse : 0;
+
 	mfcs.mfcs_packets = c->mfc_un.res.pkt;
 	mfcs.mfcs_bytes = c->mfc_un.res.bytes;
 	mfcs.mfcs_wrong_if = c->mfc_un.res.wrong_if;
 	if (nla_put_64bit(skb, RTA_MFC_STATS, sizeof(mfcs), &mfcs, RTA_PAD) ||
-	    nla_put_u64_64bit(skb, RTA_EXPIRES,
-			      jiffies_to_clock_t(c->mfc_un.res.lastuse),
+	    nla_put_u64_64bit(skb, RTA_EXPIRES, jiffies_to_clock_t(lastuse),
 			      RTA_PAD))
 		return -EMSGSIZE;
 
-- 
2.1.4
