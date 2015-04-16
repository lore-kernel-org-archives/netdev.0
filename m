From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 06/16] netconsole: make netconsole_target->enabled a bool
Date: Thu, 16 Apr 2015 19:03:43 -0400
Message-ID: <1429225433-11946-7-git-send-email-tj@kernel.org>
References: <1429225433-11946-1-git-send-email-tj@kernel.org>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Tejun Heo <tj@kernel.org>
To: akpm@linux-foundation.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f180.google.com ([209.85.216.180]:34128 "EHLO
	mail-qc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753522AbbDPXE1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 19:04:27 -0400
In-Reply-To: <1429225433-11946-1-git-send-email-tj@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We'll add more bool's to netconsole_target.  Let's convert ->enabled
to bool first so that things stay consistent.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: David Miller <davem@davemloft.net>
---
 drivers/net/netconsole.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index 15731d1..09d4e12 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -104,7 +104,7 @@ struct netconsole_target {
 #ifdef	CONFIG_NETCONSOLE_DYNAMIC
 	struct config_item	item;
 #endif
-	int			enabled;
+	bool			enabled;
 	struct mutex		mutex;
 	struct netpoll		np;
 };
@@ -197,7 +197,7 @@ static struct netconsole_target *alloc_param_target(char *target_config)
 	if (err)
 		goto fail;
 
-	nt->enabled = 1;
+	nt->enabled = true;
 
 	return nt;
 
@@ -322,13 +322,13 @@ static ssize_t store_enabled(struct netconsole_target *nt,
 		return err;
 	if (enabled < 0 || enabled > 1)
 		return -EINVAL;
-	if (enabled == nt->enabled) {
+	if ((bool)enabled == nt->enabled) {
 		pr_info("network logging has already %s\n",
 			nt->enabled ? "started" : "stopped");
 		return -EINVAL;
 	}
 
-	if (enabled) {	/* 1 */
+	if (enabled) {	/* true */
 		/*
 		 * Skip netpoll_parse_options() -- all the attributes are
 		 * already configured via configfs. Just print them out.
@@ -340,13 +340,13 @@ static ssize_t store_enabled(struct netconsole_target *nt,
 			return err;
 
 		pr_info("netconsole: network logging started\n");
-	} else {	/* 0 */
+	} else {	/* false */
 		/* We need to disable the netconsole before cleaning it up
 		 * otherwise we might end up in write_msg() with
-		 * nt->np.dev == NULL and nt->enabled == 1
+		 * nt->np.dev == NULL and nt->enabled == true
 		 */
 		spin_lock_irqsave(&target_list_lock, flags);
-		nt->enabled = 0;
+		nt->enabled = false;
 		spin_unlock_irqrestore(&target_list_lock, flags);
 		netpoll_cleanup(&nt->np);
 	}
@@ -594,7 +594,7 @@ static struct config_item *make_netconsole_target(struct config_group *group,
 
 	/*
 	 * Allocate and initialize with defaults.
-	 * Target is disabled at creation (enabled == 0).
+	 * Target is disabled at creation (!enabled).
 	 */
 	nt = kzalloc(sizeof(*nt), GFP_KERNEL);
 	if (!nt)
@@ -695,7 +695,7 @@ restart:
 				spin_lock_irqsave(&target_list_lock, flags);
 				dev_put(nt->np.dev);
 				nt->np.dev = NULL;
-				nt->enabled = 0;
+				nt->enabled = false;
 				stopped = true;
 				netconsole_target_put(nt);
 				goto restart;
-- 
2.1.0
