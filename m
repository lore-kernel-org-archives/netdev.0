From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 1/7] unix_diag: Do not use RTA_PUT() macros
Date: Wed, 27 Jun 2012 11:36:10 +0200
Message-ID: <296218a519c404b44427e3994c3559e0be106635.1340788373.git.tgraf@suug.ch>
References: <cover.1340788373.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3363 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756559Ab2F0JgU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jun 2012 05:36:20 -0400
In-Reply-To: <cover.1340788373.git.tgraf@suug.ch>
In-Reply-To: <cover.1340788373.git.tgraf@suug.ch>
References: <cover.1340788373.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also, no need to trim on nlmsg_put() failure, nothing has been added
yet.  We also want to use nlmsg_end(), nlmsg_new() and nlmsg_free().

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 net/unix/diag.c |   80 ++++++++++++++++++++++--------------------------------
 1 files changed, 33 insertions(+), 47 deletions(-)

diff --git a/net/unix/diag.c b/net/unix/diag.c
index 977ca31..a74864e 100644
--- a/net/unix/diag.c
+++ b/net/unix/diag.c
@@ -8,40 +8,31 @@
 #include <net/af_unix.h>
 #include <net/tcp_states.h>
 
-#define UNIX_DIAG_PUT(skb, attrtype, attrlen) \
-	RTA_DATA(__RTA_PUT(skb, attrtype, attrlen))
-
 static int sk_diag_dump_name(struct sock *sk, struct sk_buff *nlskb)
 {
 	struct unix_address *addr = unix_sk(sk)->addr;
-	char *s;
-
-	if (addr) {
-		s = UNIX_DIAG_PUT(nlskb, UNIX_DIAG_NAME, addr->len - sizeof(short));
-		memcpy(s, addr->name->sun_path, addr->len - sizeof(short));
-	}
 
-	return 0;
+	if (!addr)
+		return 0;
 
-rtattr_failure:
-	return -EMSGSIZE;
+	return nla_put(nlskb, UNIX_DIAG_NAME, addr->len - sizeof(short),
+		       addr->name->sun_path);
 }
 
 static int sk_diag_dump_vfs(struct sock *sk, struct sk_buff *nlskb)
 {
 	struct dentry *dentry = unix_sk(sk)->path.dentry;
-	struct unix_diag_vfs *uv;
 
 	if (dentry) {
-		uv = UNIX_DIAG_PUT(nlskb, UNIX_DIAG_VFS, sizeof(*uv));
-		uv->udiag_vfs_ino = dentry->d_inode->i_ino;
-		uv->udiag_vfs_dev = dentry->d_sb->s_dev;
+		struct unix_diag_vfs uv = {
+			.udiag_vfs_ino = dentry->d_inode->i_ino,
+			.udiag_vfs_dev = dentry->d_sb->s_dev,
+		};
+
+		return nla_put(nlskb, UNIX_DIAG_VFS, sizeof(uv), &uv);
 	}
 
 	return 0;
-
-rtattr_failure:
-	return -EMSGSIZE;
 }
 
 static int sk_diag_dump_peer(struct sock *sk, struct sk_buff *nlskb)
@@ -56,24 +47,28 @@ static int sk_diag_dump_peer(struct sock *sk, struct sk_buff *nlskb)
 		unix_state_unlock(peer);
 		sock_put(peer);
 
-		RTA_PUT_U32(nlskb, UNIX_DIAG_PEER, ino);
+		return nla_put_u32(nlskb, UNIX_DIAG_PEER, ino);
 	}
 
 	return 0;
-rtattr_failure:
-	return -EMSGSIZE;
 }
 
 static int sk_diag_dump_icons(struct sock *sk, struct sk_buff *nlskb)
 {
 	struct sk_buff *skb;
+	struct nlattr *attr;
 	u32 *buf;
 	int i;
 
 	if (sk->sk_state == TCP_LISTEN) {
 		spin_lock(&sk->sk_receive_queue.lock);
-		buf = UNIX_DIAG_PUT(nlskb, UNIX_DIAG_ICONS,
-				sk->sk_receive_queue.qlen * sizeof(u32));
+
+		attr = nla_reserve(nlskb, UNIX_DIAG_ICONS,
+				   sk->sk_receive_queue.qlen * sizeof(u32));
+		if (!attr)
+			goto errout;
+
+		buf = nla_data(attr);
 		i = 0;
 		skb_queue_walk(&sk->sk_receive_queue, skb) {
 			struct sock *req, *peer;
@@ -94,45 +89,38 @@ static int sk_diag_dump_icons(struct sock *sk, struct sk_buff *nlskb)
 
 	return 0;
 
-rtattr_failure:
+errout:
 	spin_unlock(&sk->sk_receive_queue.lock);
 	return -EMSGSIZE;
 }
 
 static int sk_diag_show_rqlen(struct sock *sk, struct sk_buff *nlskb)
 {
-	struct unix_diag_rqlen *rql;
-
-	rql = UNIX_DIAG_PUT(nlskb, UNIX_DIAG_RQLEN, sizeof(*rql));
+	struct unix_diag_rqlen rql;
 
 	if (sk->sk_state == TCP_LISTEN) {
-		rql->udiag_rqueue = sk->sk_receive_queue.qlen;
-		rql->udiag_wqueue = sk->sk_max_ack_backlog;
+		rql.udiag_rqueue = sk->sk_receive_queue.qlen;
+		rql.udiag_wqueue = sk->sk_max_ack_backlog;
 	} else {
-		rql->udiag_rqueue = (__u32)unix_inq_len(sk);
-		rql->udiag_wqueue = (__u32)unix_outq_len(sk);
+		rql.udiag_rqueue = (u32) unix_inq_len(sk);
+		rql.udiag_wqueue = (u32) unix_outq_len(sk);
 	}
 
-	return 0;
-
-rtattr_failure:
-	return -EMSGSIZE;
+	return nla_put(nlskb, UNIX_DIAG_RQLEN, sizeof(rql), &rql);
 }
 
 static int sk_diag_fill(struct sock *sk, struct sk_buff *skb, struct unix_diag_req *req,
 		u32 pid, u32 seq, u32 flags, int sk_ino)
 {
-	unsigned char *b = skb_tail_pointer(skb);
 	struct nlmsghdr *nlh;
 	struct unix_diag_msg *rep;
 
-	nlh = nlmsg_put(skb, pid, seq, SOCK_DIAG_BY_FAMILY, sizeof(*rep), 0);
+	nlh = nlmsg_put(skb, pid, seq, SOCK_DIAG_BY_FAMILY, sizeof(*rep),
+			flags);
 	if (!nlh)
-		goto out_nlmsg_trim;
-	nlh->nlmsg_flags = flags;
+		return -EMSGSIZE;
 
 	rep = nlmsg_data(nlh);
-
 	rep->udiag_family = AF_UNIX;
 	rep->udiag_type = sk->sk_type;
 	rep->udiag_state = sk->sk_state;
@@ -163,11 +151,10 @@ static int sk_diag_fill(struct sock *sk, struct sk_buff *skb, struct unix_diag_r
 	    sock_diag_put_meminfo(sk, skb, UNIX_DIAG_MEMINFO))
 		goto out_nlmsg_trim;
 
-	nlh->nlmsg_len = skb_tail_pointer(skb) - b;
-	return skb->len;
+	return nlmsg_end(skb, nlh);
 
 out_nlmsg_trim:
-	nlmsg_trim(skb, b);
+	nlmsg_cancel(skb, nlh);
 	return -EMSGSIZE;
 }
 
@@ -272,15 +259,14 @@ static int unix_diag_get_exact(struct sk_buff *in_skb,
 	extra_len = 256;
 again:
 	err = -ENOMEM;
-	rep = alloc_skb(NLMSG_SPACE((sizeof(struct unix_diag_msg) + extra_len)),
-			GFP_KERNEL);
+	rep = nlmsg_new(sizeof(struct unix_diag_msg) + extra_len, GFP_KERNEL);
 	if (!rep)
 		goto out;
 
 	err = sk_diag_fill(sk, rep, req, NETLINK_CB(in_skb).pid,
 			   nlh->nlmsg_seq, 0, req->udiag_ino);
 	if (err < 0) {
-		kfree_skb(rep);
+		nlmsg_free(rep);
 		extra_len += 256;
 		if (extra_len >= PAGE_SIZE)
 			goto out;
-- 
1.7.7.6
