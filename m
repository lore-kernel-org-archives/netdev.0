From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next v2 4/5] sock_diag: notify packet socket creation/deletion
Date: Wed, 24 Apr 2013 17:52:35 +0200
Message-ID: <1366818756-4234-5-git-send-email-nicolas.dichtel@6wind.com>
References: <51779426.7020800@6wind.com>
 <1366818756-4234-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: xiyou.wangcong@gmail.com, eric.dumazet@gmail.com,
	davem@davemloft.net, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:54886 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757378Ab3DXPxQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Apr 2013 11:53:16 -0400
In-Reply-To: <1366818756-4234-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With this patch, a netlink message is sent each time a packet socket is created
or deleted.
The framework is generic, so it's easy to add the notification for other kind of
sockets.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/linux/sock_diag.h      |  4 ++++
 include/uapi/linux/sock_diag.h | 13 ++++++++++++-
 net/core/sock_diag.c           | 41 +++++++++++++++++++++++++++++++++++++++++
 net/packet/af_packet.c         |  4 ++++
 net/packet/diag.c              | 28 ++++++++++++++++++++++++----
 5 files changed, 85 insertions(+), 5 deletions(-)

diff --git a/include/linux/sock_diag.h b/include/linux/sock_diag.h
index 3957c14..fc580ea 100644
--- a/include/linux/sock_diag.h
+++ b/include/linux/sock_diag.h
@@ -10,6 +10,7 @@ struct sock;
 struct sock_diag_handler {
 	__u8 family;
 	int (*dump)(struct sk_buff *skb, struct nlmsghdr *nlh);
+	int (*notify)(struct sk_buff *skb, struct sock *sk, bool create);
 };
 
 int sock_diag_register(const struct sock_diag_handler *h);
@@ -24,5 +25,8 @@ void sock_diag_save_cookie(void *sk, __u32 *cookie);
 int sock_diag_put_meminfo(struct sock *sk, struct sk_buff *skb, int attr);
 int sock_diag_put_filterinfo(struct sock *sk, struct sk_buff *skb,
 			     int attrtype);
+int __sock_diag_notify(struct sock *sk, bool create);
+#define sock_diag_notify(sk)		__sock_diag_notify(sk, true)
+#define sock_diag_notify_del(sk)	__sock_diag_notify(sk, false)
 
 #endif
diff --git a/include/uapi/linux/sock_diag.h b/include/uapi/linux/sock_diag.h
index b00e29e..9e9ffa0 100644
--- a/include/uapi/linux/sock_diag.h
+++ b/include/uapi/linux/sock_diag.h
@@ -3,7 +3,18 @@
 
 #include <linux/types.h>
 
-#define SOCK_DIAG_BY_FAMILY 20
+#define SOCK_DIAG_BY_FAMILY	20
+#define SOCK_DIAG_BY_FAMILY_DEL	21
+
+/* SOCK_DIAG multicast groups */
+enum nldiag_groups {
+	NLDIAGGRP_NONE,
+#define NLDIAGGRP_NONE		NLDIAGGRP_NONE
+	NLDIAGGRP_NOTIFY,
+#define NLDIAGGRP_NOTIFY	NLDIAGGRP_NOTIFY
+	__NLDIAGGRP_MAX
+};
+#define NLDIAGGRP_MAX	(__NLDIAGGRP_MAX - 1)
 
 struct sock_diag_req {
 	__u8	sdiag_family;
diff --git a/net/core/sock_diag.c b/net/core/sock_diag.c
index 51e75f4..24f36c0 100644
--- a/net/core/sock_diag.c
+++ b/net/core/sock_diag.c
@@ -186,6 +186,47 @@ static void sock_diag_rcv(struct sk_buff *skb)
 	mutex_unlock(&sock_diag_mutex);
 }
 
+int __sock_diag_notify(struct sock *sk, bool create)
+{
+	const struct sock_diag_handler *hndl;
+	int err;
+
+	if (sock_diag_handlers[sk->sk_family] == NULL)
+		request_module("net-pf-%d-proto-%d-type-%d", PF_NETLINK,
+				NETLINK_SOCK_DIAG, sk->sk_family);
+
+	mutex_lock(&sock_diag_table_mutex);
+	hndl = sock_diag_handlers[sk->sk_family];
+	if (hndl == NULL)
+		err = -ENOENT;
+	else if (hndl->notify == NULL)
+		err = -ENOSYS;
+	else {
+		struct net *net = sock_net(sk);
+		struct sock *nlsk = net->diag_nlsk;
+		struct sk_buff *skb;
+
+		skb = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
+		if (skb == NULL) {
+			err = -ENOBUFS;
+			goto out;
+		}
+
+		err = hndl->notify(skb, sk, create);
+		if (err) {
+			nlmsg_free(skb);
+			goto out;
+		}
+
+		err = nlmsg_notify(nlsk, skb, 0, NLDIAGGRP_NOTIFY, 0,
+				   GFP_KERNEL);
+	}
+out:
+	mutex_unlock(&sock_diag_table_mutex);
+
+	return err;
+}
+
 static int __net_init diag_net_init(struct net *net)
 {
 	struct netlink_kernel_cfg cfg = {
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 7e387ff..bb32d64 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -88,6 +88,7 @@
 #include <linux/virtio_net.h>
 #include <linux/errqueue.h>
 #include <linux/net_tstamp.h>
+#include <linux/sock_diag.h>
 
 #ifdef CONFIG_INET
 #include <net/inet_common.h>
@@ -2379,6 +2380,8 @@ static int packet_release(struct socket *sock)
 	if (!sk)
 		return 0;
 
+	sock_diag_notify_del(sk);
+
 	net = sock_net(sk);
 	po = pkt_sk(sk);
 
@@ -2597,6 +2600,7 @@ static int packet_create(struct net *net, struct socket *sock, int protocol,
 	sock_prot_inuse_add(net, &packet_proto, 1);
 	preempt_enable();
 
+	sock_diag_notify(sk);
 	return 0;
 out:
 	return err;
diff --git a/net/packet/diag.c b/net/packet/diag.c
index ec8b6e8..377a45b 100644
--- a/net/packet/diag.c
+++ b/net/packet/diag.c
@@ -128,13 +128,13 @@ static int pdiag_put_fanout(struct packet_sock *po, struct sk_buff *nlskb)
 static int sk_diag_fill(struct sock *sk, struct sk_buff *skb,
 			struct packet_diag_req *req,
 			struct user_namespace *user_ns,
-			u32 portid, u32 seq, u32 flags, int sk_ino)
+			u32 portid, u32 seq, u32 flags, int sk_ino, int cmd)
 {
 	struct nlmsghdr *nlh;
 	struct packet_diag_msg *rp;
 	struct packet_sock *po = pkt_sk(sk);
 
-	nlh = nlmsg_put(skb, portid, seq, SOCK_DIAG_BY_FAMILY, sizeof(*rp), flags);
+	nlh = nlmsg_put(skb, portid, seq, cmd, sizeof(*rp), flags);
 	if (!nlh)
 		return -EMSGSIZE;
 
@@ -149,7 +149,7 @@ static int sk_diag_fill(struct sock *sk, struct sk_buff *skb,
 			pdiag_put_info(po, skb))
 		goto out_nlmsg_trim;
 
-	if ((req->pdiag_show & PACKET_SHOW_INFO) &&
+	if ((req->pdiag_show & PACKET_SHOW_INFO) && user_ns &&
 	    nla_put_u32(skb, PACKET_DIAG_UID,
 			from_kuid_munged(user_ns, sock_i_uid(sk))))
 		goto out_nlmsg_trim;
@@ -202,7 +202,7 @@ static int packet_diag_dump(struct sk_buff *skb, struct netlink_callback *cb)
 				 sk_user_ns(NETLINK_CB(cb->skb).sk),
 				 NETLINK_CB(cb->skb).portid,
 				 cb->nlh->nlmsg_seq, NLM_F_MULTI,
-				 sock_i_ino(sk)) < 0)
+				 sock_i_ino(sk), SOCK_DIAG_BY_FAMILY) < 0)
 			goto done;
 next:
 		num++;
@@ -237,9 +237,29 @@ static int packet_diag_handler_dump(struct sk_buff *skb, struct nlmsghdr *h)
 		return -EOPNOTSUPP;
 }
 
+static int packet_diag_handler_notify(struct sk_buff *skb, struct sock *sk,
+				      bool create)
+{
+	struct packet_diag_req req;
+	int err, cmd;
+
+	memset(&req, 0, sizeof(struct packet_diag_req));
+	if (create) {
+		req.pdiag_show |= PACKET_SHOW_INFO | PACKET_SHOW_MCLIST;
+		req.pdiag_show |= PACKET_SHOW_RING_CFG | PACKET_SHOW_FANOUT;
+		req.pdiag_show |= PACKET_SHOW_MEMINFO | PACKET_SHOW_FILTER;
+		cmd = SOCK_DIAG_BY_FAMILY;
+	} else
+		cmd = SOCK_DIAG_BY_FAMILY_DEL;
+
+	err = sk_diag_fill(sk, skb, &req, NULL, 0, 0, 0, sock_i_ino(sk), cmd);
+	return err > 0 ? 0 : err;
+}
+
 static const struct sock_diag_handler packet_diag_handler = {
 	.family = AF_PACKET,
 	.dump = packet_diag_handler_dump,
+	.notify = packet_diag_handler_notify,
 };
 
 static int __init packet_diag_init(void)
-- 
1.8.2.1
