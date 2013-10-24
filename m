From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net] netconsole: fix multiple race conditions
Date: Thu, 24 Oct 2013 12:09:24 +0200
Message-ID: <1382609364-10716-1-git-send-email-nikolay@redhat.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10537 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754108Ab3JXKMr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Oct 2013 06:12:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In every netconsole option that can be set through configfs there's a
race when checking for nt->enabled since it can be modified at the same
time. Probably the most damage can be done by store_enabled when racing
with another instance of itself. Fix all the races with one stone by
moving the mutex lock around the ->store call for all options.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
Note: this patch is on top of netconsole: fix NULL pointer dereference
that I posted yesterday.

 drivers/net/netconsole.c | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index 1505dcb..c9a1592 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -325,9 +325,7 @@ static ssize_t store_enabled(struct netconsole_target *nt,
 		return -EINVAL;
 	}
 
-	mutex_lock(&nt->mutex);
 	if (enabled) {	/* 1 */
-
 		/*
 		 * Skip netpoll_parse_options() -- all the attributes are
 		 * already configured via configfs. Just print them out.
@@ -335,13 +333,10 @@ static ssize_t store_enabled(struct netconsole_target *nt,
 		netpoll_print_options(&nt->np);
 
 		err = netpoll_setup(&nt->np);
-		if (err) {
-			mutex_unlock(&nt->mutex);
+		if (err)
 			return err;
-		}
 
 		printk(KERN_INFO "netconsole: network logging started\n");
-
 	} else {	/* 0 */
 		/* We need to disable the netconsole before cleaning it up
 		 * otherwise we might end up in write_msg() with
@@ -354,7 +349,6 @@ static ssize_t store_enabled(struct netconsole_target *nt,
 	}
 
 	nt->enabled = enabled;
-	mutex_unlock(&nt->mutex);
 
 	return strnlen(buf, count);
 }
@@ -571,8 +565,10 @@ static ssize_t netconsole_target_attr_store(struct config_item *item,
 	struct netconsole_target_attr *na =
 		container_of(attr, struct netconsole_target_attr, attr);
 
+	mutex_lock(&nt->mutex);
 	if (na->store)
 		ret = na->store(nt, buf, count);
+	mutex_unlock(&nt->mutex);
 
 	return ret;
 }
-- 
1.8.1.4
