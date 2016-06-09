From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next] nfnetlink_queue: enable PID info retrieval
Date: Thu,  9 Jun 2016 23:50:08 +0300
Message-ID: <1465505409-1232-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Andre Melkoumian <andre@mellanox.com>,
	Matthew Finlay <matt@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:32808 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750796AbcFIUvI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jun 2016 16:51:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Finlay <matt@mellanox.com>

Allow the netlink_queue_module to get the PID associated with an outgoing
connection. Finding the PID based on the tuple in userspace is expensive.
This additional attribute makes it convenient and efficient to get the PID
associated with the outgoing connection in userspace, without the need to
parse procfs.

Signed-off-by: Matthew Finlay <matt@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
CC: Pablo Neira Ayuso <pablo@netfilter.org>
CC: Patrick McHardy <kaber@trash.net>
CC: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 include/linux/fs.h                             |  1 +
 include/uapi/linux/netfilter/nfnetlink_queue.h |  4 +++-
 net/netfilter/nfnetlink_queue.c                | 25 +++++++++++++++++++++++++
 net/socket.c                                   |  1 +
 4 files changed, 30 insertions(+), 1 deletion(-)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index dd28814..f6e0ae3 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -871,6 +871,7 @@ extern struct block_device *I_BDEV(struct inode *inode);
 struct fown_struct {
 	rwlock_t lock;          /* protects pid, uid, euid fields */
 	struct pid *pid;	/* pid or -pgrp where SIGIO should be sent */
+	struct pid *sock_pid;	/* pid of the process that created the socket */
 	enum pid_type pid_type;	/* Kind of process group SIGIO should be sent to */
 	kuid_t uid, euid;	/* uid/euid of process setting the owner */
 	int signum;		/* posix.1b rt signal to be delivered on IO */
diff --git a/include/uapi/linux/netfilter/nfnetlink_queue.h b/include/uapi/linux/netfilter/nfnetlink_queue.h
index ae30841..87379ae 100644
--- a/include/uapi/linux/netfilter/nfnetlink_queue.h
+++ b/include/uapi/linux/netfilter/nfnetlink_queue.h
@@ -60,6 +60,7 @@ enum nfqnl_attr_type {
 	NFQA_SECCTX,			/* security context string */
 	NFQA_VLAN,			/* nested attribute: packet vlan info */
 	NFQA_L2HDR,			/* full L2 header */
+	NFQA_PID,			/* __s32 sk pid */
 
 	__NFQA_MAX
 };
@@ -114,7 +115,8 @@ enum nfqnl_attr_config {
 #define NFQA_CFG_F_GSO				(1 << 2)
 #define NFQA_CFG_F_UID_GID			(1 << 3)
 #define NFQA_CFG_F_SECCTX			(1 << 4)
-#define NFQA_CFG_F_MAX				(1 << 5)
+#define NFQA_CFG_F_PID				(1 << 5)
+#define NFQA_CFG_F_MAX				(1 << 6)
 
 /* flags for NFQA_SKB_INFO */
 /* packet appears to have wrong checksums, but they are ok */
diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index aa93877..b7a7f5a3 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -278,6 +278,24 @@ nla_put_failure:
 	return -1;
 }
 
+static int nfqnl_put_sk_pid(struct sk_buff *skb, struct sock *sk)
+{
+	struct pid *sk_pid;
+	int err = 0;
+
+	if (!sk_fullsock(sk))
+		return 0;
+
+	read_lock_bh(&sk->sk_callback_lock);
+	if (sk->sk_socket && sk->sk_socket->file) {
+		sk_pid = sk->sk_socket->file->f_owner.sock_pid;
+		if (sk_pid)
+			err = nla_put_be32(skb, NFQA_PID, htonl(pid_nr(sk_pid)));
+	}
+	read_unlock_bh(&sk->sk_callback_lock);
+	return err;
+}
+
 static u32 nfqnl_get_sk_secctx(struct sk_buff *skb, char **secdata)
 {
 	u32 seclen = 0;
@@ -440,6 +458,9 @@ nfqnl_build_packet_message(struct net *net, struct nfqnl_instance *queue,
 			size += nla_total_size(seclen);
 	}
 
+	if (queue->flags & NFQA_CFG_F_PID)
+		size += nla_total_size(sizeof(int32_t)); /* pid */
+
 	skb = alloc_skb(size, GFP_ATOMIC);
 	if (!skb) {
 		skb_tx_error(entskb);
@@ -570,6 +591,10 @@ nfqnl_build_packet_message(struct net *net, struct nfqnl_instance *queue,
 	    nfqnl_put_sk_uidgid(skb, entskb->sk) < 0)
 		goto nla_put_failure;
 
+	if ((queue->flags & NFQA_CFG_F_PID) && entskb->sk &&
+	    nfqnl_put_sk_pid(skb, entskb->sk) < 0)
+		goto nla_put_failure;
+
 	if (seclen && nla_put(skb, NFQA_SECCTX, seclen, secdata))
 		goto nla_put_failure;
 
diff --git a/net/socket.c b/net/socket.c
index a1bd161..67de200 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -382,6 +382,7 @@ struct file *sock_alloc_file(struct socket *sock, int flags, const char *dname)
 	}
 
 	sock->file = file;
+	file->f_owner.sock_pid  = find_get_pid(task_pid_nr(current));
 	file->f_flags = O_RDWR | (flags & O_NONBLOCK);
 	file->private_data = sock;
 	return file;
-- 
2.8.0
