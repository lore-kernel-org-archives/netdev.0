From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH] Revert "bridge: Allow forward delay to be cfgd when STP enabled"
Date: Tue, 10 Nov 2015 06:15:32 -0500
Message-ID: <1447154132-13879-1-git-send-email-vyasevich@gmail.com>
Cc: stephen@networkplumber.org,
	Vladislav Yasevich <vyasevich@gmail.com>,
	Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f180.google.com ([209.85.220.180]:32953 "EHLO
	mail-qk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752235AbbKJLPs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2015 06:15:48 -0500
Received: by qkas77 with SMTP id s77so80145669qka.0
        for <netdev@vger.kernel.org>; Tue, 10 Nov 2015 03:15:47 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit 34c2d9fb0498c066afbe610b15e18995fd8be792.

There are 2 reasons for this revert:
 1)  The commit in question doesn't do what it says it does.  The
     description reads: "Allow bridge forward delay to be configured
     when Spanning Tree is enabled."  This was already the case before
     the commit was made.  What the commit actually do was disallow
     invalid values or 'forward_delay' when STP was turned off.

 2)  The above change was actually a change in the user observed
     behavior and broke things like libvirt and other network configs
     that set 'forward_delay' to 0 without enabling STP.  The value
     of 0 is actually used when STP is turned off to immediately mark
     the bridge as forwarding.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/bridge/br_stp.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
index 80c34d7..f7e8dee 100644
--- a/net/bridge/br_stp.c
+++ b/net/bridge/br_stp.c
@@ -600,12 +600,17 @@ void __br_set_forward_delay(struct net_bridge *br, unsigned long t)
 int br_set_forward_delay(struct net_bridge *br, unsigned long val)
 {
 	unsigned long t = clock_t_to_jiffies(val);
-
-	if (t < BR_MIN_FORWARD_DELAY || t > BR_MAX_FORWARD_DELAY)
-		return -ERANGE;
+	int err = -ERANGE;
 
 	spin_lock_bh(&br->lock);
+	if (br->stp_enabled != BR_NO_STP &&
+	    (t < BR_MIN_FORWARD_DELAY || t > BR_MAX_FORWARD_DELAY))
+		goto unlock;
+
 	__br_set_forward_delay(br, t);
+	err = 0;
+
+unlock:
 	spin_unlock_bh(&br->lock);
-	return 0;
+	return err;
 }
-- 
1.9.3
