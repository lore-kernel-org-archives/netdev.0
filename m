From: Pablo Neira <pablo@eurodev.net>
Subject: [NETLINK] netlink_ack takes gfp flag as parameter
Date: Fri, 24 Sep 2004 03:12:19 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41537473.1090306@eurodev.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000902000507060900080103"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000902000507060900080103
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hi Davem,

AFAIK ip_queue, ip6_queue and dn_rtmsg use netlink_ack in interrupt 
context which calls alloc_skb with the GFP_KERNEL flag. This patch adds 
a new parameter to netlink_ack to set the gfp flag.

Signed-off-by: Pablo Neira Ayuso <pablo@eurodev.net>

regards,
Pablo

--------------000902000507060900080103
Content-Type: text/x-patch;
 name="netlink_ack.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="netlink_ack.patch"

===== include/linux/netlink.h 1.19 vs edited =====
--- 1.19/include/linux/netlink.h	Sat Aug 28 02:13:43 2004
+++ edited/include/linux/netlink.h	Fri Sep 24 02:02:05 2004
@@ -119,7 +119,7 @@
 extern void netlink_detach(int unit);
 extern int netlink_post(int unit, struct sk_buff *skb);
 extern struct sock *netlink_kernel_create(int unit, void (*input)(struct sock *sk, int len));
-extern void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err);
+extern void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err, int gfp_mask);
 extern int netlink_unicast(struct sock *ssk, struct sk_buff *skb, __u32 pid, int nonblock);
 extern int netlink_broadcast(struct sock *ssk, struct sk_buff *skb, __u32 pid,
 			     __u32 group, int allocation);
===== net/netlink/af_netlink.c 1.56 vs edited =====
--- 1.56/net/netlink/af_netlink.c	Fri Sep 24 02:01:00 2004
+++ edited/net/netlink/af_netlink.c	Fri Sep 24 02:02:06 2004
@@ -957,7 +957,8 @@
 	return 0;
 }
 
-void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err)
+void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err, 
+		 int gfp_mask)
 {
 	struct sk_buff *skb;
 	struct nlmsghdr *rep;
@@ -969,7 +970,7 @@
 	else
 		size = NLMSG_SPACE(4 + NLMSG_ALIGN(nlh->nlmsg_len));
 
-	skb = alloc_skb(size, GFP_KERNEL);
+	skb = alloc_skb(size, gfp_mask);
 	if (!skb) {
 		struct sock *sk;
 

--------------000902000507060900080103
Content-Type: text/x-patch;
 name="netlink_ack-audit.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="netlink_ack-audit.patch"

===== kernel/audit.c 1.3 vs edited =====
--- 1.3/kernel/audit.c	Tue Sep 14 02:23:21 2004
+++ edited/kernel/audit.c	Fri Sep 24 02:02:06 2004
@@ -419,9 +419,9 @@
 		if (rlen > skb->len)
 			rlen = skb->len;
 		if ((err = audit_receive_msg(skb, nlh))) {
-			netlink_ack(skb, nlh, -err);
+			netlink_ack(skb, nlh, -err, GFP_KERNEL);
 		} else if (nlh->nlmsg_flags & NLM_F_ACK)
-			netlink_ack(skb, nlh, 0);
+			netlink_ack(skb, nlh, 0, GFP_KERNEL);
 		skb_pull(skb, rlen);
 	}
 	return 0;

--------------000902000507060900080103
Content-Type: text/x-patch;
 name="netlink_ack-dn_rtmsg.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="netlink_ack-dn_rtmsg.patch"

===== net/decnet/netfilter/dn_rtmsg.c 1.3 vs edited =====
--- 1.3/net/decnet/netfilter/dn_rtmsg.c	Thu Jun  5 02:57:08 2003
+++ edited/net/decnet/netfilter/dn_rtmsg.c	Fri Sep 24 02:14:31 2004
@@ -99,7 +99,9 @@
 }
 
 
-#define RCV_SKB_FAIL(err) do { netlink_ack(skb, nlh, (err)); return; } while (0)
+#define RCV_SKB_FAIL(err) do {					\
+	netlink_ack(skb, nlh, (err), GFP_ATOMIC); return; 	\
+	} while (0) 						\
 
 static inline void dnrmg_receive_user_skb(struct sk_buff *skb)
 {

--------------000902000507060900080103
Content-Type: text/x-patch;
 name="netlink_ack-ip6_queue.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="netlink_ack-ip6_queue.patch"

===== net/ipv6/netfilter/ip6_queue.c 1.14 vs edited =====
--- 1.14/net/ipv6/netfilter/ip6_queue.c	Thu Jan 29 00:59:34 2004
+++ edited/net/ipv6/netfilter/ip6_queue.c	Fri Sep 24 02:19:58 2004
@@ -474,7 +474,9 @@
 		ipq_issue_verdict(entry, NF_DROP);
 }
 
-#define RCV_SKB_FAIL(err) do { netlink_ack(skb, nlh, (err)); return; } while (0)
+#define RCV_SKB_FAIL(err) do {					\
+	netlink_ack(skb, nlh, (err), GFP_ATOMIC); return; 	\
+	} while (0) 						\
 
 static inline void
 ipq_rcv_skb(struct sk_buff *skb)

--------------000902000507060900080103
Content-Type: text/x-csrc;
 name="netlink_ack-ip_queue.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="netlink_ack-ip_queue.c"

===== net/ipv4/netfilter/ip_queue.c 1.17 vs edited =====
--- 1.17/net/ipv4/netfilter/ip_queue.c	Tue Sep  7 23:18:28 2004
+++ edited/net/ipv4/netfilter/ip_queue.c	Fri Sep 24 02:15:45 2004
@@ -471,7 +471,9 @@
 		ipq_issue_verdict(entry, NF_DROP);
 }
 
-#define RCV_SKB_FAIL(err) do { netlink_ack(skb, nlh, (err)); return; } while (0)
+#define RCV_SKB_FAIL(err) do {					\
+	netlink_ack(skb, nlh, (err), GFP_ATOMIC); return; 	\
+	} while (0)						\
 
 static inline void
 ipq_rcv_skb(struct sk_buff *skb)
@@ -526,7 +528,7 @@
 		RCV_SKB_FAIL(status);
 		
 	if (flags & NLM_F_ACK)
-		netlink_ack(skb, nlh, 0);
+		netlink_ack(skb, nlh, 0, GFP_ATOMIC);
         return;
 }
 

--------------000902000507060900080103
Content-Type: text/x-patch;
 name="netlink_ack-rtnetlink.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="netlink_ack-rtnetlink.patch"

===== net/core/rtnetlink.c 1.27 vs edited =====
--- 1.27/net/core/rtnetlink.c	Mon Sep 13 02:03:08 2004
+++ edited/net/core/rtnetlink.c	Fri Sep 24 02:02:05 2004
@@ -558,9 +558,9 @@
 			 */
 			if (err == 0)
 				return -1;
-			netlink_ack(skb, nlh, err);
+			netlink_ack(skb, nlh, err, GFP_KERNEL);
 		} else if (nlh->nlmsg_flags&NLM_F_ACK)
-			netlink_ack(skb, nlh, 0);
+			netlink_ack(skb, nlh, 0, GFP_KERNEL);
 		skb_pull(skb, rlen);
 	}
 

--------------000902000507060900080103
Content-Type: text/x-patch;
 name="netlink_ack-tcp_diag.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="netlink_ack-tcp_diag.patch"

===== net/ipv4/tcp_diag.c 1.16 vs edited =====
--- 1.16/net/ipv4/tcp_diag.c	Tue Sep  7 18:18:04 2004
+++ edited/net/ipv4/tcp_diag.c	Fri Sep 24 02:02:05 2004
@@ -634,7 +634,7 @@
 			return;
 		err = tcpdiag_rcv_msg(skb, nlh);
 		if (err || nlh->nlmsg_flags & NLM_F_ACK) 
-			netlink_ack(skb, nlh, err);
+			netlink_ack(skb, nlh, err, GFP_KERNEL);
 	}
 }
 

--------------000902000507060900080103
Content-Type: text/x-patch;
 name="netlink_ack-xfrm_user.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="netlink_ack-xfrm_user.patch"

===== net/xfrm/xfrm_user.c 1.48 vs edited =====
--- 1.48/net/xfrm/xfrm_user.c	Fri Sep 10 23:35:53 2004
+++ edited/net/xfrm/xfrm_user.c	Fri Sep 24 02:02:06 2004
@@ -995,7 +995,7 @@
 		if (xfrm_user_rcv_msg(skb, nlh, &err) < 0) {
 			if (err == 0)
 				return -1;
-			netlink_ack(skb, nlh, err);
+			netlink_ack(skb, nlh, err, GFP_KERNEL);
 		} else if (nlh->nlmsg_flags & NLM_F_ACK)
 			netlink_ack(skb, nlh, 0);
 		skb_pull(skb, rlen);

--------------000902000507060900080103--
