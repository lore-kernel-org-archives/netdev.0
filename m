From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] replace dst_release refcount error with standard WARN_ON
Date: Thu, 21 Oct 2004 13:34:34 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041021133434.73188fae@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Replace the dst count underflow bug message with a standard WARN message.
This makes errors noticeable and also reduces the kernel text size by 600
since we aren't doing as much to setup the printk.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


diff -Nru a/include/net/dst.h b/include/net/dst.h
--- a/include/net/dst.h	2004-10-21 13:30:02 -07:00
+++ b/include/net/dst.h	2004-10-21 13:30:02 -07:00
@@ -142,16 +142,11 @@
 	return dst;
 }
 
-extern const char dst_underflow_bug_msg[];
-
 static inline
 void dst_release(struct dst_entry * dst)
 {
 	if (dst) {
-		if (atomic_read(&dst->__refcnt) < 1)
-			printk(dst_underflow_bug_msg, 
-			       atomic_read(&dst->__refcnt), 
-			       dst, current_text_addr());
+		WARN_ON(atomic_read(&dst->__refcnt) < 1);
 		atomic_dec(&dst->__refcnt);
 	}
 }
diff -Nru a/net/core/dst.c b/net/core/dst.c
--- a/net/core/dst.c	2004-10-21 13:30:02 -07:00
+++ b/net/core/dst.c	2004-10-21 13:30:02 -07:00
@@ -19,8 +19,6 @@
 
 #include <net/dst.h>
 
-const char dst_underflow_bug_msg[] = KERN_DEBUG "BUG: dst underflow %d: %p at %p\n";
-
 /* Locking strategy:
  * 1) Garbage collection state of dead destination cache
  *    entries is protected by dst_lock.
@@ -275,7 +273,6 @@
 	register_netdevice_notifier(&dst_dev_notifier);
 }
 
-EXPORT_SYMBOL(dst_underflow_bug_msg);
 EXPORT_SYMBOL(__dst_free);
 EXPORT_SYMBOL(dst_alloc);
 EXPORT_SYMBOL(dst_destroy);
