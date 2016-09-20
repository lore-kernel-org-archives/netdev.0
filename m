From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net] ipmr, ip6mr: return lastuse relative to now
Date: Tue, 20 Sep 2016 11:06:17 +0200
Message-ID: <1474362377-22627-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, sashok@cumulusnetworks.com,
        davem@davemloft.net,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:38337 "EHLO
        mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752045AbcITJIE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 05:08:04 -0400
Received: by mail-wm0-f45.google.com with SMTP id l132so23178187wmf.1
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 02:08:04 -0700 (PDT)
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
I realize that this changes the way it is exported, but since it hasn't
been in a release yet and we're most probably the only users, I think it is
worth fixing. This change allows user-space daemons to age out entries and
also for the lastuse value to be shown properly via iproute2.

 net/ipv4/ipmr.c  | 3 ++-
 net/ipv6/ip6mr.c | 3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 26253328d227..1505a0e37f44 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -2110,7 +2110,8 @@ static int __ipmr_fill_mroute(struct mr_table *mrt, struct sk_buff *skb,
 	mfcs.mfcs_wrong_if = c->mfc_un.res.wrong_if;
 	if (nla_put_64bit(skb, RTA_MFC_STATS, sizeof(mfcs), &mfcs, RTA_PAD) ||
 	    nla_put_u64_64bit(skb, RTA_EXPIRES,
-			      jiffies_to_clock_t(c->mfc_un.res.lastuse),
+			      jiffies_to_clock_t(jiffies -
+						 c->mfc_un.res.lastuse),
 			      RTA_PAD))
 		return -EMSGSIZE;
 
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 6122f9c5cc49..c35d56c5ecc9 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -2274,7 +2274,8 @@ static int __ip6mr_fill_mroute(struct mr6_table *mrt, struct sk_buff *skb,
 	mfcs.mfcs_wrong_if = c->mfc_un.res.wrong_if;
 	if (nla_put_64bit(skb, RTA_MFC_STATS, sizeof(mfcs), &mfcs, RTA_PAD) ||
 	    nla_put_u64_64bit(skb, RTA_EXPIRES,
-			      jiffies_to_clock_t(c->mfc_un.res.lastuse),
+			      jiffies_to_clock_t(jiffies -
+						 c->mfc_un.res.lastuse),
 			      RTA_PAD))
 		return -EMSGSIZE;
 
-- 
2.1.4
