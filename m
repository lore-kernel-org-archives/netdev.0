From: Pablo Neira <pablo@eurodev.net>
Subject: [PATCH 2/4] [NETLINK] introduce netlink_check_skb function
Date: Fri, 11 Feb 2005 01:14:03 +0100
Message-ID: <420BF8CB.6080005@eurodev.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070807090606050805050302"
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070807090606050805050302
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

This patch introduces a new function called netlink_check_skb that does 
the sanity checkings for received messages.

--
Pablo

--------------070807090606050805050302
Content-Type: text/x-patch;
 name="01process_skb.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01process_skb.patch"

===== net/netlink/af_netlink.c 1.69 vs edited =====
--- 1.69/net/netlink/af_netlink.c	2005-01-21 21:25:32 +01:00
+++ edited/net/netlink/af_netlink.c	2005-02-10 00:37:57 +01:00
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
+		} else if (nlh->nlmsg_flags&NLM_F_ACK)
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
--- linux-2.5/include/linux/netlink.h.orig	2005-02-10 00:48:55.000000000 +0100
+++ linux-2.5/include/linux/netlink.h	2005-02-10 00:49:40.000000000 +0100
@@ -119,6 +119,9 @@
 #define NETLINK_CREDS(skb)	(&NETLINK_CB((skb)).creds)
 
 
+extern int 
+netlink_process_skb(struct sk_buff *skb, int (*process_msg)(struct sk_buff *skb,
+					 struct nlmsghdr *nlh, int *err));
 extern struct sock *
 netlink_kernel_create(int unit, void (*input)(struct sock *sk, int len));
 extern void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err);

--------------070807090606050805050302--
