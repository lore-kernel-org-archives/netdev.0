From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] skbuff: remove old NET_CALLER macro
Date: Tue, 19 Apr 2005 17:44:58 +1000
Message-ID: <20050419174458.0ae804f3@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Kill NET_CALLER it causes warnings from sparse and is no longer
necessary.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -urNp -X dontdiff ck-2.6.11/include/linux/skbuff.h net-2.6.11/include/linux/skbuff.h
--- ck-2.6.11/include/linux/skbuff.h	2005-03-02 18:38:38.000000000 +1100
+++ net-2.6.11/include/linux/skbuff.h	2005-04-19 16:59:31.000000000 +1000
@@ -83,12 +83,6 @@
  *	Any questions? No questions, good. 		--ANK
  */
 
-#ifdef __i386__
-#define NET_CALLER(arg) (*(((void **)&arg) - 1))
-#else
-#define NET_CALLER(arg) __builtin_return_address(0)
-#endif
-
 struct net_device;
 
 #ifdef CONFIG_NETFILTER
diff -urNp -X dontdiff ck-2.6.11/net/core/skbuff.c net-2.6.11/net/core/skbuff.c
--- ck-2.6.11/net/core/skbuff.c	2005-04-19 17:07:13.000000000 +1000
+++ net-2.6.11/net/core/skbuff.c	2005-04-19 17:31:38.000000000 +1000
@@ -275,9 +275,10 @@ void kfree_skbmem(struct sk_buff *skb)
 
 void __kfree_skb(struct sk_buff *skb)
 {
-	if (skb->list) {
+	if (unlikely(skb->list)) {
 	 	printk(KERN_WARNING "Warning: kfree_skb passed an skb still "
-		       "on a list (from %p).\n", NET_CALLER(skb));
+		       "on a list (from %p).\n", 
+			__builtin_return_address(0));
 		BUG();
 	}
 
@@ -285,10 +286,11 @@ void __kfree_skb(struct sk_buff *skb)
 #ifdef CONFIG_XFRM
 	secpath_put(skb->sp);
 #endif
-	if(skb->destructor) {
+	if (unlikely(skb->destructor)) {
 		if (in_irq())
 			printk(KERN_WARNING "Warning: kfree_skb on "
-					    "hard IRQ %p\n", NET_CALLER(skb));
+					    "hard IRQ %p\n",
+			__builtin_return_address(0));
 		skb->destructor(skb);
 	}
 #ifdef CONFIG_NETFILTER
