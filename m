From: pablo@netfilter.org
Subject: [PATCH 1/4] netfilter: take care of timewait sockets
Date: Thu, 13 Sep 2012 12:54:05 +0200
Message-ID: <1347533648-3451-2-git-send-email-pablo@netfilter.org>
References: <1347533648-3451-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1347533648-3451-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <edumazet@google.com>

Sami Farin reported crashes in xt_LOG because it assumes skb->sk is a
full blown socket.

Since (41063e9 ipv4: Early TCP socket demux), we can have skb->sk
pointing to a timewait socket.

Same fix is needed in nfnetlink_log.

Diagnosed-by: Florian Westphal <fw@strlen.de>
Reported-by: Sami Farin <hvtaifwkbgefbaei@gmail.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink_log.c |   14 ++++++++------
 net/netfilter/xt_LOG.c        |   33 +++++++++++++++++----------------
 2 files changed, 25 insertions(+), 22 deletions(-)

diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index 14e2f39..5cfb5be 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -381,6 +381,7 @@ __build_packet_message(struct nfulnl_instance *inst,
 	struct nlmsghdr *nlh;
 	struct nfgenmsg *nfmsg;
 	sk_buff_data_t old_tail = inst->skb->tail;
+	struct sock *sk;
 
 	nlh = nlmsg_put(inst->skb, 0, 0,
 			NFNL_SUBSYS_ULOG << 8 | NFULNL_MSG_PACKET,
@@ -499,18 +500,19 @@ __build_packet_message(struct nfulnl_instance *inst,
 	}
 
 	/* UID */
-	if (skb->sk) {
-		read_lock_bh(&skb->sk->sk_callback_lock);
-		if (skb->sk->sk_socket && skb->sk->sk_socket->file) {
-			struct file *file = skb->sk->sk_socket->file;
+	sk = skb->sk;
+	if (sk && sk->sk_state != TCP_TIME_WAIT) {
+		read_lock_bh(&sk->sk_callback_lock);
+		if (sk->sk_socket && sk->sk_socket->file) {
+			struct file *file = sk->sk_socket->file;
 			__be32 uid = htonl(file->f_cred->fsuid);
 			__be32 gid = htonl(file->f_cred->fsgid);
-			read_unlock_bh(&skb->sk->sk_callback_lock);
+			read_unlock_bh(&sk->sk_callback_lock);
 			if (nla_put_be32(inst->skb, NFULA_UID, uid) ||
 			    nla_put_be32(inst->skb, NFULA_GID, gid))
 				goto nla_put_failure;
 		} else
-			read_unlock_bh(&skb->sk->sk_callback_lock);
+			read_unlock_bh(&sk->sk_callback_lock);
 	}
 
 	/* local sequence number */
diff --git a/net/netfilter/xt_LOG.c b/net/netfilter/xt_LOG.c
index ff5f75f..2a4f969 100644
--- a/net/netfilter/xt_LOG.c
+++ b/net/netfilter/xt_LOG.c
@@ -145,6 +145,19 @@ static int dump_tcp_header(struct sbuff *m, const struct sk_buff *skb,
 	return 0;
 }
 
+static void dump_sk_uid_gid(struct sbuff *m, struct sock *sk)
+{
+	if (!sk || sk->sk_state == TCP_TIME_WAIT)
+		return;
+
+	read_lock_bh(&sk->sk_callback_lock);
+	if (sk->sk_socket && sk->sk_socket->file)
+		sb_add(m, "UID=%u GID=%u ",
+			sk->sk_socket->file->f_cred->fsuid,
+			sk->sk_socket->file->f_cred->fsgid);
+	read_unlock_bh(&sk->sk_callback_lock);
+}
+
 /* One level of recursion won't kill us */
 static void dump_ipv4_packet(struct sbuff *m,
 			const struct nf_loginfo *info,
@@ -361,14 +374,8 @@ static void dump_ipv4_packet(struct sbuff *m,
 	}
 
 	/* Max length: 15 "UID=4294967295 " */
-	if ((logflags & XT_LOG_UID) && !iphoff && skb->sk) {
-		read_lock_bh(&skb->sk->sk_callback_lock);
-		if (skb->sk->sk_socket && skb->sk->sk_socket->file)
-			sb_add(m, "UID=%u GID=%u ",
-				skb->sk->sk_socket->file->f_cred->fsuid,
-				skb->sk->sk_socket->file->f_cred->fsgid);
-		read_unlock_bh(&skb->sk->sk_callback_lock);
-	}
+	if ((logflags & XT_LOG_UID) && !iphoff)
+		dump_sk_uid_gid(m, skb->sk);
 
 	/* Max length: 16 "MARK=0xFFFFFFFF " */
 	if (!iphoff && skb->mark)
@@ -717,14 +724,8 @@ static void dump_ipv6_packet(struct sbuff *m,
 	}
 
 	/* Max length: 15 "UID=4294967295 " */
-	if ((logflags & XT_LOG_UID) && recurse && skb->sk) {
-		read_lock_bh(&skb->sk->sk_callback_lock);
-		if (skb->sk->sk_socket && skb->sk->sk_socket->file)
-			sb_add(m, "UID=%u GID=%u ",
-				skb->sk->sk_socket->file->f_cred->fsuid,
-				skb->sk->sk_socket->file->f_cred->fsgid);
-		read_unlock_bh(&skb->sk->sk_callback_lock);
-	}
+	if ((logflags & XT_LOG_UID) && recurse)
+		dump_sk_uid_gid(m, skb->sk);
 
 	/* Max length: 16 "MARK=0xFFFFFFFF " */
 	if (!recurse && skb->mark)
-- 
1.7.10.4

