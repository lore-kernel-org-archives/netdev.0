From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (3/3) rtnetlink -- ASSERT_RTNL and BUG_TRAP
Date: Mon, 22 Sep 2003 16:39:46 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030922163946.5854bb8e.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Change ASSERT_RTNL and BUG_TRAP
	- unlikely to occur
	- tag message as error
	- dump_stack in ASSERT_RTNL to aide finding code path
	- make all format's which a smart compiler can optimize

diff -Nru a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
--- a/include/linux/rtnetlink.h	Mon Sep 22 16:31:24 2003
+++ b/include/linux/rtnetlink.h	Mon Sep 22 16:31:24 2003
@@ -683,11 +683,21 @@
 extern void rtnl_unlock(void);
 extern void rtnetlink_init(void);
 
-#define ASSERT_RTNL() do { if (down_trylock(&rtnl_sem) == 0)  { up(&rtnl_sem); \
-printk("RTNL: assertion failed at " __FILE__ "(%d)\n", __LINE__); } \
-		   } while(0)
-#define BUG_TRAP(x) if (!(x)) { printk("KERNEL: assertion (" #x ") failed at " __FILE__ "(%d)\n", __LINE__); }
+#define ASSERT_RTNL() do { \
+	if (unlikely(down_trylock(&rtnl_sem) == 0)) { \
+		up(&rtnl_sem); \
+		printk(KERN_ERR "RTNL: assertion failed at %s (%d)\n", \
+		       __FILE__,  __LINE__); \
+		dump_stack(); \
+	} \
+} while(0)
 
+#define BUG_TRAP(x) do { \
+	if (unlikely(!(x))) { \
+		printk(KERN_ERR "KERNEL: assertion (%s) failed at %s (%d)\n", \
+			#x,  __FILE__ , __LINE__); \
+	} \
+} while(0)
 
 #endif /* __KERNEL__ */
 
