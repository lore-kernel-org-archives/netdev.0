From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] kill rtnl_exlock stubs
Date: Tue, 27 Jul 2004 09:50:57 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040727095057.78c7419c@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Jamal Hadi Salim <hadi@znyx.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Rtnetlink has some macro's that are relics from earlier locking.
They are only used a couple of places so are easy to kill.

diff -Nru a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
--- a/include/linux/rtnetlink.h	2004-07-27 09:40:03 -07:00
+++ b/include/linux/rtnetlink.h	2004-07-27 09:40:03 -07:00
@@ -746,10 +746,6 @@
 
 extern struct semaphore rtnl_sem;
 
-#define rtnl_exlock()		do { } while(0)
-#define rtnl_exunlock()		do { } while(0)
-#define rtnl_exlock_nowait()	(0)
-
 #define rtnl_shlock()		down(&rtnl_sem)
 #define rtnl_shlock_nowait()	down_trylock(&rtnl_sem)
 
diff -Nru a/net/core/dev.c b/net/core/dev.c
--- a/net/core/dev.c	2004-07-27 09:40:03 -07:00
+++ b/net/core/dev.c	2004-07-27 09:40:03 -07:00
@@ -3041,7 +3041,6 @@
 	while (atomic_read(&dev->refcnt) != 0) {
 		if (time_after(jiffies, rebroadcast_time + 1 * HZ)) {
 			rtnl_shlock();
-			rtnl_exlock();
 
 			/* Rebroadcast unregister notification */
 			notifier_call_chain(&netdev_chain,
@@ -3058,7 +3057,6 @@
 				linkwatch_run_queue();
 			}
 
-			rtnl_exunlock();
 			rtnl_shunlock();
 
 			rebroadcast_time = jiffies;
diff -Nru a/net/core/link_watch.c b/net/core/link_watch.c
--- a/net/core/link_watch.c	2004-07-27 09:40:03 -07:00
+++ b/net/core/link_watch.c	2004-07-27 09:40:03 -07:00
@@ -93,9 +93,7 @@
 	clear_bit(LW_RUNNING, &linkwatch_flags);
 
 	rtnl_shlock();
-	rtnl_exlock();
 	linkwatch_run_queue();
-	rtnl_exunlock();
 	rtnl_shunlock();
 }
 
diff -Nru a/net/core/rtnetlink.c b/net/core/rtnetlink.c
--- a/net/core/rtnetlink.c	2004-07-27 09:40:03 -07:00
+++ b/net/core/rtnetlink.c	2004-07-27 09:40:03 -07:00
@@ -56,12 +56,10 @@
 void rtnl_lock(void)
 {
 	rtnl_shlock();
-	rtnl_exlock();
 }
  
 void rtnl_unlock(void)
 {
-	rtnl_exunlock();
 	rtnl_shunlock();
 
 	netdev_run_todo();
@@ -404,13 +402,8 @@
 		return -1;
 	}
 
-	if (kind != 2) {
-		if (rtnl_exlock_nowait()) {
-			*errp = 0;
-			return -1;
-		}
+	if (kind != 2) 
 		exclusive = 1;
-	}
 
 	memset(&rta, 0, sizeof(rta));
 
@@ -439,14 +432,10 @@
 		goto err_inval;
 	err = link->doit(skb, nlh, (void *)&rta);
 
-	if (exclusive)
-		rtnl_exunlock();
 	*errp = err;
 	return err;
 
 err_inval:
-	if (exclusive)
-		rtnl_exunlock();
 	*errp = -EINVAL;
 	return -1;
 }
