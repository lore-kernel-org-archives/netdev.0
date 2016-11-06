From: Lorenzo Colitti <lorenzo@google.com>
Subject: [PATCH net-next] net: core: add missing check for uid_range in rule_exists.
Date: Mon,  7 Nov 2016 00:16:25 +0900
Message-ID: <1478445385-94937-1-git-send-email-lorenzo@google.com>
Cc: davem@davemloft.net, ek@google.com, eric.dumazet@gmail.com,
        zenczykowski@gmail.com, Lorenzo Colitti <lorenzo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:34654 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752144AbcKFPQc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 6 Nov 2016 10:16:32 -0500
Received: by mail-pf0-f172.google.com with SMTP id n85so77903148pfi.1
        for <netdev@vger.kernel.org>; Sun, 06 Nov 2016 07:16:32 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Without this check, it is not possible to create two rules that
are identical except for their UID ranges. For example:

root@net-test:/# ip rule add prio 1000 lookup 300
root@net-test:/# ip rule add prio 1000 uidrange 100-200 lookup 300
RTNETLINK answers: File exists
root@net-test:/# ip rule add prio 1000 uidrange 100-199 lookup 100
root@net-test:/# ip rule add prio 1000 uidrange 200-299 lookup 200
root@net-test:/# ip rule add prio 1000 uidrange 300-399 lookup 100
RTNETLINK answers: File exists

Tested: https://android-review.googlesource.com/#/c/299980/
Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
---
 net/core/fib_rules.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index 5de436a..b6791d9 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -343,6 +343,10 @@ static int rule_exists(struct fib_rules_ops *ops, struct fib_rule_hdr *frh,
 		if (r->l3mdev != rule->l3mdev)
 			continue;
 
+		if (!uid_eq(r->uid_range.start, rule->uid_range.start) ||
+		    !uid_eq(r->uid_range.end, rule->uid_range.end))
+			continue;
+
 		if (!ops->compare(r, frh, tb))
 			continue;
 		return 1;
-- 
2.8.0.rc3.226.g39d4020
