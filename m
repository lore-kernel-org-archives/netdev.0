From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 02/16] [NETLINK]: Add notification message sending interface
Date: Mon, 14 Aug 2006 00:00:02 +0200
Message-ID: <20060814214339.439998107@postel.suug.ch>
References: <20060814213718.580598840@postel.suug.ch>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:13774 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S964974AbWHNVo0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2006 17:44:26 -0400
To: davem@davemloft.net
Content-Disposition: inline; filename=nlmsg_notify
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adds nlmsg_notify() implementing proper notification logic. The
message is multicasted to all listeners in the group. The
applications the requests orignates from can request a unicast
back report in which case said socket will be excluded from the
multicast to avoid duplicated notifications.

nlmsg_multicast() is extended to take allocation flags to
allow notification in atomic contexts.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.19.git/include/net/netlink.h
===================================================================
--- net-2.6.19.git.orig/include/net/netlink.h
+++ net-2.6.19.git/include/net/netlink.h
@@ -43,6 +43,7 @@
  * Message Sending:
  *   nlmsg_multicast()			multicast message to several groups
  *   nlmsg_unicast()			unicast a message to a single socket
+ *   nlmsg_notify()			send notification message
  *
  * Message Length Calculations:
  *   nlmsg_msg_size(payload)		length of message w/o padding
@@ -545,15 +546,16 @@ static inline void nlmsg_free(struct sk_
  * @skb: netlink message as socket buffer
  * @pid: own netlink pid to avoid sending to yourself
  * @group: multicast group id
+ * @flags: allocation flags
  */
 static inline int nlmsg_multicast(struct sock *sk, struct sk_buff *skb,
-				  u32 pid, unsigned int group)
+				  u32 pid, unsigned int group, gfp_t flags)
 {
 	int err;
 
 	NETLINK_CB(skb).dst_group = group;
 
-	err = netlink_broadcast(sk, skb, pid, group, GFP_KERNEL);
+	err = netlink_broadcast(sk, skb, pid, group, flags);
 	if (err > 0)
 		err = 0;
 
Index: net-2.6.19.git/net/netlink/af_netlink.c
===================================================================
--- net-2.6.19.git.orig/net/netlink/af_netlink.c
+++ net-2.6.19.git/net/netlink/af_netlink.c
@@ -1550,6 +1550,38 @@ void netlink_queue_skip(struct nlmsghdr 
 	skb_pull(skb, msglen);
 }
 
+/**
+ * nlmsg_notify - send a notification netlink message
+ * @sk: netlink socket to use
+ * @skb: notification message
+ * @pid: destination netlink pid for reports or 0
+ * @group: destination multicast group or 0
+ * @report: 1 to report back, 0 to disable
+ * @flags: allocation flags
+ */
+int nlmsg_notify(struct sock *sk, struct sk_buff *skb, u32 pid,
+		 unsigned int group, int report, gfp_t flags)
+{
+	int err = 0;
+
+	if (group) {
+		int exclude_pid = 0;
+
+		if (report) {
+			atomic_inc(&skb->users);
+			exclude_pid = pid;
+		}
+
+		/* errors reported via destination sk->sk_err */
+		nlmsg_multicast(sk, skb, exclude_pid, group, flags);
+	}
+
+	if (report)
+		err = nlmsg_unicast(sk, skb, pid);
+
+	return err;
+}
+
 #ifdef CONFIG_PROC_FS
 struct nl_seq_iter {
 	int link;
@@ -1804,4 +1836,4 @@ EXPORT_SYMBOL(netlink_set_err);
 EXPORT_SYMBOL(netlink_set_nonroot);
 EXPORT_SYMBOL(netlink_unicast);
 EXPORT_SYMBOL(netlink_unregister_notifier);
-
+EXPORT_SYMBOL(nlmsg_notify);
Index: net-2.6.19.git/include/net/genetlink.h
===================================================================
--- net-2.6.19.git.orig/include/net/genetlink.h
+++ net-2.6.19.git/include/net/genetlink.h
@@ -133,11 +133,12 @@ static inline int genlmsg_cancel(struct 
  * @skb: netlink message as socket buffer
  * @pid: own netlink pid to avoid sending to yourself
  * @group: multicast group id
+ * @flags: allocation flags
  */
 static inline int genlmsg_multicast(struct sk_buff *skb, u32 pid,
-				    unsigned int group)
+				    unsigned int group, gfp_t flags)
 {
-	return nlmsg_multicast(genl_sock, skb, pid, group);
+	return nlmsg_multicast(genl_sock, skb, pid, group, flags);
 }
 
 /**
Index: net-2.6.19.git/net/netlabel/netlabel_user.c
===================================================================
--- net-2.6.19.git.orig/net/netlabel/netlabel_user.c
+++ net-2.6.19.git/net/netlabel/netlabel_user.c
@@ -154,5 +154,5 @@ int netlbl_netlink_snd(struct sk_buff *s
  */
 int netlbl_netlink_snd_multicast(struct sk_buff *skb, u32 pid, u32 group)
 {
-	return genlmsg_multicast(skb, pid, group);
+	return genlmsg_multicast(skb, pid, group, GFP_KERNEL);
 }
Index: net-2.6.19.git/net/netlink/genetlink.c
===================================================================
--- net-2.6.19.git.orig/net/netlink/genetlink.c
+++ net-2.6.19.git/net/netlink/genetlink.c
@@ -510,7 +510,7 @@ static int genl_ctrl_event(int event, vo
 		if (IS_ERR(msg))
 			return PTR_ERR(msg);
 
-		genlmsg_multicast(msg, 0, GENL_ID_CTRL);
+		genlmsg_multicast(msg, 0, GENL_ID_CTRL, GFP_KERNEL);
 		break;
 	}
 

