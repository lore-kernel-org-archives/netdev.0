From: Pablo Neira <pablo@eurodev.net>
Subject: [PATCH] [NETLINK] unify checkings for clean messages
Date: Fri, 11 Feb 2005 22:18:32 +0100
Message-ID: <420D2128.5000803@eurodev.net>
References: <420BF8C3.3050305@eurodev.net> <20050210173201.21da89e5.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070109050602080708060404"
Cc: netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050210173201.21da89e5.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070109050602080708060404
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

David S. Miller wrote:

>Why don't you bypass all the cleanup diffs and just do the functionality
>change instead?  When you mix whitespace and coding style cleanups
>with real changes, it puts your real changes at risk if we think your
>cleanups are ugly or bogus since you've created a patch dependency.
>  
>

Ok, sorry for the nuisance. I'll try to avoid such things in future. 
Thanks davem.

Back to what I wanted to introduce...

The following patches introduce a new function that check that the 
netlink messages received are clean. Actually some people performs such 
checkings, some don't and others simply do some half of them. I think 
that we must unify the behaviour of a netlink socket when it has to 
reply to malformed messages.

01process_skb.patch:
      introduces the new function called netlink_process_skb that does 
the sanity checkings for received messages.
02xfrm.patch:
      the modification to make xfrm_user use such new function.
03rtnetlink.patch:
      same thing for rtnetlink.

The 02 and 03 patches are straight forward conversions. If you are ok 
with this, I could post more patches to make other netlink sockets use 
this new function.

--
Pablo

--------------070109050602080708060404
Content-Type: text/x-patch;
 name="01process_skb.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01process_skb.patch"

===== include/linux/netlink.h 1.23 vs edited =====
--- 1.23/include/linux/netlink.h	2005-02-07 06:59:39 +01:00
+++ edited/include/linux/netlink.h	2005-02-11 21:25:38 +01:00
@@ -116,6 +116,7 @@
 #define NETLINK_CREDS(skb)	(&NETLINK_CB((skb)).creds)
 
 
+extern int netlink_process_skb(struct sk_buff *skb, int (*process_msg)(struct sk_buff *skb, struct nlmsghdr *nlh, int *err));
 extern struct sock *netlink_kernel_create(int unit, void (*input)(struct sock *sk, int len));
 extern void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err);
 extern int netlink_unicast(struct sock *ssk, struct sk_buff *skb, __u32 pid, int nonblock);
===== net/netlink/af_netlink.c 1.69 vs edited =====
--- 1.69/net/netlink/af_netlink.c	2005-01-21 21:25:32 +01:00
+++ edited/net/netlink/af_netlink.c	2005-02-11 21:30:34 +01:00
@@ -1201,6 +1201,42 @@
 	netlink_unicast(in_skb->sk, skb, NETLINK_CB(in_skb).pid, MSG_DONTWAIT);
 }
 
+/* 
+ * Process one packet of messages.
+ * Malformed skbs with wrong lengths of messages are discarded silently.
+ */
+int netlink_process_skb(struct sk_buff *skb, 
+			int (*process_msg)(struct sk_buff *skb,
+					   struct nlmsghdr *nlh,
+					   int *err))
+{
+	int err;
+	struct nlmsghdr * nlh;
+
+	while (skb->len >= NLMSG_SPACE(0)) {
+		u32 rlen;
+
+		nlh = (struct nlmsghdr *)skb->data;
+		if (nlh->nlmsg_len < sizeof(*nlh) || skb->len < nlh->nlmsg_len)
+			return 0;
+		rlen = NLMSG_ALIGN(nlh->nlmsg_len);
+		if (rlen > skb->len)
+			rlen = skb->len;
+		if (process_msg(skb, nlh, &err)) {
+			/* Not error, but we must interrupt processing here:
+			 *   Note, that in this case we do not pull message
+			 *   from skb, it will be processed later.
+			 */
+			if (err == 0)
+				return -1;
+			netlink_ack(skb, nlh, err);
+		} else if (nlh->nlmsg_flags & NLM_F_ACK)
+			netlink_ack(skb, nlh, 0);
+		skb_pull(skb, rlen);
+	}
+
+	return 0;
+}
 
 #ifdef CONFIG_PROC_FS
 struct nl_seq_iter {
@@ -1456,6 +1492,7 @@
 
 MODULE_ALIAS_NETPROTO(PF_NETLINK);
 
+EXPORT_SYMBOL(netlink_process_skb);
 EXPORT_SYMBOL(netlink_ack);
 EXPORT_SYMBOL(netlink_broadcast);
 EXPORT_SYMBOL(netlink_dump_start);

--------------070109050602080708060404
Content-Type: text/x-patch;
 name="02xfrm.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="02xfrm.patch"

===== net/xfrm/xfrm_user.c 1.52 vs edited =====
--- 1.52/net/xfrm/xfrm_user.c	2005-01-26 06:53:19 +01:00
+++ edited/net/xfrm/xfrm_user.c	2005-02-10 00:15:16 +01:00
@@ -980,33 +980,6 @@
 	return -1;
 }
 
-static int xfrm_user_rcv_skb(struct sk_buff *skb)
-{
-	int err;
-	struct nlmsghdr *nlh;
-
-	while (skb->len >= NLMSG_SPACE(0)) {
-		u32 rlen;
-
-		nlh = (struct nlmsghdr *) skb->data;
-		if (nlh->nlmsg_len < sizeof(*nlh) ||
-		    skb->len < nlh->nlmsg_len)
-			return 0;
-		rlen = NLMSG_ALIGN(nlh->nlmsg_len);
-		if (rlen > skb->len)
-			rlen = skb->len;
-		if (xfrm_user_rcv_msg(skb, nlh, &err) < 0) {
-			if (err == 0)
-				return -1;
-			netlink_ack(skb, nlh, err);
-		} else if (nlh->nlmsg_flags & NLM_F_ACK)
-			netlink_ack(skb, nlh, 0);
-		skb_pull(skb, rlen);
-	}
-
-	return 0;
-}
-
 static void xfrm_netlink_rcv(struct sock *sk, int len)
 {
 	do {
@@ -1015,7 +988,7 @@
 		down(&xfrm_cfg_sem);
 
 		while ((skb = skb_dequeue(&sk->sk_receive_queue)) != NULL) {
-			if (xfrm_user_rcv_skb(skb)) {
+			if (netlink_process_skb(skb, xfrm_user_rcv_msg)) {
 				if (skb->len)
 					skb_queue_head(&sk->sk_receive_queue,
 						       skb);

--------------070109050602080708060404
Content-Type: text/x-patch;
 name="03rtnetlink.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="03rtnetlink.patch"

===== net/core/rtnetlink.c 1.33 vs edited =====
--- 1.33/net/core/rtnetlink.c	2005-01-10 22:42:22 +01:00
+++ edited/net/core/rtnetlink.c	2005-02-10 00:14:59 +01:00
@@ -570,41 +570,6 @@
 	return -1;
 }
 
-/* 
- * Process one packet of messages.
- * Malformed skbs with wrong lengths of messages are discarded silently.
- */
-
-static inline int rtnetlink_rcv_skb(struct sk_buff *skb)
-{
-	int err;
-	struct nlmsghdr * nlh;
-
-	while (skb->len >= NLMSG_SPACE(0)) {
-		u32 rlen;
-
-		nlh = (struct nlmsghdr *)skb->data;
-		if (nlh->nlmsg_len < sizeof(*nlh) || skb->len < nlh->nlmsg_len)
-			return 0;
-		rlen = NLMSG_ALIGN(nlh->nlmsg_len);
-		if (rlen > skb->len)
-			rlen = skb->len;
-		if (rtnetlink_rcv_msg(skb, nlh, &err)) {
-			/* Not error, but we must interrupt processing here:
-			 *   Note, that in this case we do not pull message
-			 *   from skb, it will be processed later.
-			 */
-			if (err == 0)
-				return -1;
-			netlink_ack(skb, nlh, err);
-		} else if (nlh->nlmsg_flags&NLM_F_ACK)
-			netlink_ack(skb, nlh, 0);
-		skb_pull(skb, rlen);
-	}
-
-	return 0;
-}
-
 /*
  *  rtnetlink input queue processing routine:
  *	- try to acquire shared lock. If it is failed, defer processing.
@@ -622,7 +587,7 @@
 			return;
 
 		while ((skb = skb_dequeue(&sk->sk_receive_queue)) != NULL) {
-			if (rtnetlink_rcv_skb(skb)) {
+			if (netlink_process_skb(skb, rtnetlink_rcv_msg)) {
 				if (skb->len)
 					skb_queue_head(&sk->sk_receive_queue,
 						       skb);

--------------070109050602080708060404--
