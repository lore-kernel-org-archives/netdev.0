From: chas williams <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM]: [clip] fix race between modifying entry->vccs and clip_start_xmit()
Date: Mon, 15 Sep 2003 15:11:21 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309151911.h8FJBKSa003299@ginger.cmf.nrl.navy.mil>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.6 and 2.4 -- thanks

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1315  -> 1.1316 
#	      net/atm/clip.c	1.22    -> 1.23   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/09/15	chas@relax.cmf.nrl.navy.mil	1.1316
# [ATM]: [clip] fix race between modifying entry->vccs and clip_start_xmit()
# --------------------------------------------
#
diff -Nru a/net/atm/clip.c b/net/atm/clip.c
--- a/net/atm/clip.c	Mon Sep 15 15:08:57 2003
+++ b/net/atm/clip.c	Mon Sep 15 15:08:57 2003
@@ -93,6 +93,7 @@
 		printk(KERN_CRIT "!clip_vcc->entry (clip_vcc %p)\n",clip_vcc);
 		return;
 	}
+	spin_lock_bh(&entry->neigh->dev->xmit_lock);	/* block clip_start_xmit() */
 	entry->neigh->used = jiffies;
 	for (walk = &entry->vccs; *walk; walk = &(*walk)->next)
 		if (*walk == clip_vcc) {
@@ -102,17 +103,20 @@
 			clip_vcc->entry = NULL;
 			if (clip_vcc->xoff)
 				netif_wake_queue(entry->neigh->dev);
-			if (entry->vccs) return;
+			if (entry->vccs)
+				goto out;
 			entry->expires = jiffies-1;
 				/* force resolution or expiration */
 			error = neigh_update(entry->neigh,NULL,NUD_NONE,0,0);
 			if (error)
 				printk(KERN_CRIT "unlink_clip_vcc: "
 				    "neigh_update failed with %d\n",error);
-			return;
+			goto out;
 		}
 	printk(KERN_CRIT "ATMARP: unlink_clip_vcc failed (entry %p, vcc "
 	  "0x%p)\n",entry,clip_vcc);
+out:
+	spin_unlock_bh(&entry->neigh->dev->xmit_lock);
 }
 
 
