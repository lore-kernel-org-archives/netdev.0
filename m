From: Lorenzo Colitti <lorenzo@google.com>
Subject: [PATCH v7 2/4] net: diag: Add the ability to destroy a socket.
Date: Wed, 16 Dec 2015 12:30:03 +0900
Message-ID: <1450236605-87170-3-git-send-email-lorenzo@google.com>
References: <1450236605-87170-1-git-send-email-lorenzo@google.com>
Cc: davem@davemloft.net, hannes@stressinduktion.org,
	eric.dumazet@gmail.com, ek@google.com, tom@herbertland.com,
	zenczykowski@gmail.com, Lorenzo Colitti <lorenzo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:36614 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754299AbbLPDa3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2015 22:30:29 -0500
Received: by mail-pa0-f53.google.com with SMTP id nt2so6219157pab.3
        for <netdev@vger.kernel.org>; Tue, 15 Dec 2015 19:30:28 -0800 (PST)
In-Reply-To: <1450236605-87170-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a SOCK_DESTROY operation, a destroy function
pointer to sock_diag_handler, and a diag_destroy function
pointer.  It does not include any implementation code.

Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
Acked-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/sock_diag.h      |  2 ++
 include/net/sock.h             |  1 +
 include/uapi/linux/sock_diag.h |  1 +
 net/core/sock_diag.c           | 23 ++++++++++++++++++++---
 4 files changed, 24 insertions(+), 3 deletions(-)

diff --git a/include/linux/sock_diag.h b/include/linux/sock_diag.h
index fddebc6..4018b48 100644
--- a/include/linux/sock_diag.h
+++ b/include/linux/sock_diag.h
@@ -15,6 +15,7 @@ struct sock_diag_handler {
 	__u8 family;
 	int (*dump)(struct sk_buff *skb, struct nlmsghdr *nlh);
 	int (*get_info)(struct sk_buff *skb, struct sock *sk);
+	int (*destroy)(struct sk_buff *skb, struct nlmsghdr *nlh);
 };
 
 int sock_diag_register(const struct sock_diag_handler *h);
@@ -68,4 +69,5 @@ bool sock_diag_has_destroy_listeners(const struct sock *sk)
 }
 void sock_diag_broadcast_destroy(struct sock *sk);
 
+int sock_diag_destroy(struct sock *sk, int err);
 #endif
diff --git a/include/net/sock.h b/include/net/sock.h
index 0ca22b0..c9218f5 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1060,6 +1060,7 @@ struct proto {
 	void			(*destroy_cgroup)(struct mem_cgroup *memcg);
 	struct cg_proto		*(*proto_cgroup)(struct mem_cgroup *memcg);
 #endif
+	int			(*diag_destroy)(struct sock *sk, int err);
 };
 
 int proto_register(struct proto *prot, int alloc_slab);
diff --git a/include/uapi/linux/sock_diag.h b/include/uapi/linux/sock_diag.h
index 49230d3..bae2d80 100644
--- a/include/uapi/linux/sock_diag.h
+++ b/include/uapi/linux/sock_diag.h
@@ -4,6 +4,7 @@
 #include <linux/types.h>
 
 #define SOCK_DIAG_BY_FAMILY 20
+#define SOCK_DESTROY 21
 
 struct sock_diag_req {
 	__u8	sdiag_family;
diff --git a/net/core/sock_diag.c b/net/core/sock_diag.c
index 0c1d58d..a996ce8 100644
--- a/net/core/sock_diag.c
+++ b/net/core/sock_diag.c
@@ -214,7 +214,7 @@ void sock_diag_unregister(const struct sock_diag_handler *hnld)
 }
 EXPORT_SYMBOL_GPL(sock_diag_unregister);
 
-static int __sock_diag_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
+static int __sock_diag_cmd(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	int err;
 	struct sock_diag_req *req = nlmsg_data(nlh);
@@ -234,8 +234,12 @@ static int __sock_diag_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 	hndl = sock_diag_handlers[req->sdiag_family];
 	if (hndl == NULL)
 		err = -ENOENT;
-	else
+	else if (nlh->nlmsg_type == SOCK_DIAG_BY_FAMILY)
 		err = hndl->dump(skb, nlh);
+	else if (nlh->nlmsg_type == SOCK_DESTROY && hndl->destroy)
+		err = hndl->destroy(skb, nlh);
+	else
+		err = -EOPNOTSUPP;
 	mutex_unlock(&sock_diag_table_mutex);
 
 	return err;
@@ -261,7 +265,8 @@ static int sock_diag_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 
 		return ret;
 	case SOCK_DIAG_BY_FAMILY:
-		return __sock_diag_rcv_msg(skb, nlh);
+	case SOCK_DESTROY:
+		return __sock_diag_cmd(skb, nlh);
 	default:
 		return -EINVAL;
 	}
@@ -295,6 +300,18 @@ static int sock_diag_bind(struct net *net, int group)
 	return 0;
 }
 
+int sock_diag_destroy(struct sock *sk, int err)
+{
+	if (!ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN))
+		return -EPERM;
+
+	if (!sk->sk_prot->diag_destroy)
+		return -EOPNOTSUPP;
+
+	return sk->sk_prot->diag_destroy(sk, err);
+}
+EXPORT_SYMBOL_GPL(sock_diag_destroy);
+
 static int __net_init diag_net_init(struct net *net)
 {
 	struct netlink_kernel_cfg cfg = {
-- 
2.6.0.rc2.230.g3dd15c0
