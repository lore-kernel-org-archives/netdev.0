From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (5/6) ipvs -- use time_before/after
Date: Tue, 16 Sep 2003 14:22:27 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030916142227.6dddd19d.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: lvs-users@LinuxVirtualServer.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Wensong Zhang <wensong@linux-vs.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Use time_before/after macros when comparing times.

diff -Nru a/net/ipv4/ipvs/ip_vs_conn.c b/net/ipv4/ipvs/ip_vs_conn.c
--- a/net/ipv4/ipvs/ip_vs_conn.c	Tue Sep 16 14:09:55 2003
+++ b/net/ipv4/ipvs/ip_vs_conn.c	Tue Sep 16 14:09:55 2003
@@ -743,7 +743,7 @@
 	/* if the conn entry hasn't lasted for 60 seconds, don't drop it.
 	   This will leave enough time for normal connection to get
 	   through. */
-	if (cp->timeout+jiffies-cp->timer.expires < 60*HZ)
+	if (time_before(cp->timeout + jiffies, cp->timer.expires + 60*HZ))
 		return 0;
 
 	/* Don't drop the entry if its number of incoming packets is not
diff -Nru a/net/ipv4/ipvs/ip_vs_lblc.c b/net/ipv4/ipvs/ip_vs_lblc.c
--- a/net/ipv4/ipvs/ip_vs_lblc.c	Tue Sep 16 14:09:55 2003
+++ b/net/ipv4/ipvs/ip_vs_lblc.c	Tue Sep 16 14:09:55 2003
@@ -295,8 +295,8 @@
 
 		write_lock(&tbl->lock);
 		list_for_each_entry_safe(en, nxt, &tbl->bucket[j], list) {
-			if ((now - en->lastuse) <
-			    sysctl_ip_vs_lblc_expiration) 
+			if (time_before(now, 
+					en->lastuse + sysctl_ip_vs_lblc_expiration))
 				continue;
 
 			ip_vs_lblc_free(en);
@@ -350,7 +350,7 @@
 
 		write_lock(&tbl->lock);
 		list_for_each_entry_safe(en, nxt, &tbl->bucket[j], list) {
-			if ((now - en->lastuse) < ENTRY_TIMEOUT) 
+			if (time_before(now, en->lastuse + ENTRY_TIMEOUT))
 				continue;
 
 			ip_vs_lblc_free(en);
diff -Nru a/net/ipv4/ipvs/ip_vs_lblcr.c b/net/ipv4/ipvs/ip_vs_lblcr.c
--- a/net/ipv4/ipvs/ip_vs_lblcr.c	Tue Sep 16 14:09:55 2003
+++ b/net/ipv4/ipvs/ip_vs_lblcr.c	Tue Sep 16 14:09:55 2003
@@ -481,10 +481,10 @@
 
 		write_lock(&tbl->lock);
 		list_for_each_entry_safe(en, nxt, &tbl->bucket[j], list) {
-			if ((now - en->lastuse) <
-			    sysctl_ip_vs_lblcr_expiration) {
+			if (time_after(en->lastuse+sysctl_ip_vs_lblcr_expiration,
+				       now))
 				continue;
-			}
+
 			ip_vs_lblcr_free(en);
 			atomic_dec(&tbl->entries);
 		}
@@ -536,7 +536,7 @@
 
 		write_lock(&tbl->lock);
 		list_for_each_entry_safe(en, nxt, &tbl->bucket[j], list) {
-			if ((now - en->lastuse) < ENTRY_TIMEOUT) 
+			if (time_before(now, en->lastuse+ENTRY_TIMEOUT))
 				continue;
 
 			ip_vs_lblcr_free(en);
diff -Nru a/net/ipv4/ipvs/ip_vs_sync.c b/net/ipv4/ipvs/ip_vs_sync.c
--- a/net/ipv4/ipvs/ip_vs_sync.c	Tue Sep 16 14:09:55 2003
+++ b/net/ipv4/ipvs/ip_vs_sync.c	Tue Sep 16 14:09:55 2003
@@ -206,8 +206,8 @@
 	struct ip_vs_sync_buff *sb;
 
 	spin_lock_bh(&curr_sb_lock);
-	if (curr_sb &&
-	    (jiffies - curr_sb->firstuse > time || time == 0)) {
+	if (curr_sb && (time == 0 ||
+			time_before(jiffies - curr_sb->firstuse, time))) {
 		sb = curr_sb;
 		curr_sb = NULL;
 	} else
