From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [PATCH] NET: save space for dst underflow message
Date: Mon, 05 Jul 2004 17:00:53 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040705.170053.22377235.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

Save space for "dst underflow" message.

Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

===== include/net/dst.h 1.19 vs edited =====
--- 1.19/include/net/dst.h	2004-06-24 17:55:48 +09:00
+++ edited/include/net/dst.h	2004-07-05 16:44:17 +09:00
@@ -142,15 +142,14 @@
 	return dst;
 }
 
+extern const char dst_underflow_bug_msg[];
+
 static inline
 void dst_release(struct dst_entry * dst)
 {
 	if (dst) {
-		if (atomic_read(&dst->__refcnt) < 1) {
-			printk("BUG: dst underflow %d: %p\n",
-			       atomic_read(&dst->__refcnt),
-			       current_text_addr());
-		}
+		if (atomic_read(&dst->__refcnt) < 1)
+			printk(dst_underflow_bug_msg, dst, current_text_addr());
 		atomic_dec(&dst->__refcnt);
 	}
 }
===== net/core/dst.c 1.20 vs edited =====
--- 1.20/net/core/dst.c	2004-06-18 04:09:54 +09:00
+++ edited/net/core/dst.c	2004-07-05 16:43:13 +09:00
@@ -19,6 +19,8 @@
 
 #include <net/dst.h>
 
+const char dst_underflow_bug_msg[] = KERN_DEBUG "BUG: dst underflow %d: %p at %p\n";
+
 /* Locking strategy:
  * 1) Garbage collection state of dead destination cache
  *    entries is protected by dst_lock.
@@ -273,6 +275,7 @@
 	register_netdevice_notifier(&dst_dev_notifier);
 }
 
+EXPORT_SYMBOL(dst_underflow_bug_msg);
 EXPORT_SYMBOL(__dst_free);
 EXPORT_SYMBOL(dst_alloc);
 EXPORT_SYMBOL(dst_destroy);

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
