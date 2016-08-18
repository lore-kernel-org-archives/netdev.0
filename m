From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 3/3] netlink: Use rhashtable walk interface in diag dump
Date: Thu, 18 Aug 2016 16:50:58 +0800
Message-ID: <E1baJ2Q-00031S-MH@gondolin.me.apana.org.au>
References: <20160818084854.GA11502@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:39081 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752864AbcHRIvf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2016 04:51:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch converts the diag dumping code to use the rhashtable
walk code instead of going through rhashtable by hand.  The lock
nl_table_lock is now only taken while we process the multicast
list as it's not needed for the rhashtable walk.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/netlink/diag.c |  105 +++++++++++++++++++++++++++++++++++++----------------
 1 file changed, 75 insertions(+), 30 deletions(-)

diff --git a/net/netlink/diag.c b/net/netlink/diag.c
index 8dd836a..d4e1eca 100644
--- a/net/netlink/diag.c
+++ b/net/netlink/diag.c
@@ -63,43 +63,77 @@ out_nlmsg_trim:
 static int __netlink_diag_dump(struct sk_buff *skb, struct netlink_callback *cb,
 				int protocol, int s_num)
 {
+	struct rhashtable_iter *hti = (void *)cb->args[2];
 	struct netlink_table *tbl = &nl_table[protocol];
-	struct rhashtable *ht = &tbl->hash;
-	const struct bucket_table *htbl = rht_dereference_rcu(ht->tbl, ht);
 	struct net *net = sock_net(skb->sk);
 	struct netlink_diag_req *req;
 	struct netlink_sock *nlsk;
+	struct rhash_head *obj;
 	struct sock *sk;
-	int ret = 0, num = 0, i;
+	int num = 2;
+	int ret = 0;
 
 	req = nlmsg_data(cb->nlh);
 
-	for (i = 0; i < htbl->size; i++) {
-		struct rhash_head *pos;
+	if (s_num > 1)
+		goto mc_list;
 
-		rht_for_each_entry_rcu(nlsk, pos, htbl, i, node) {
-			sk = (struct sock *)nlsk;
+	if (!hti) {
+		hti = kmalloc(sizeof(*hti), GFP_KERNEL);
+		if (!hti)
+			return -ENOMEM;
 
-			if (!net_eq(sock_net(sk), net))
-				continue;
-			if (num < s_num) {
-				num++;
+		cb->args[2] = (long)hti;
+	}
+
+	if (!s_num) {
+		rhashtable_walk_enter(&tbl->hash, hti);
+		num--;
+	}
+
+	ret = rhashtable_walk_start(hti);
+	if (ret == -EAGAIN)
+		ret = 0;
+	if (ret)
+		goto stop;
+
+	while ((obj = rhashtable_walk_next(hti))) {
+		if (IS_ERR(obj)) {
+			ret = PTR_ERR(obj);
+			if (ret == -EAGAIN) {
+				ret = 0;
 				continue;
 			}
+			break;
+		}
 
-			if (sk_diag_fill(sk, skb, req,
-					 NETLINK_CB(cb->skb).portid,
-					 cb->nlh->nlmsg_seq,
-					 NLM_F_MULTI,
-					 sock_i_ino(sk)) < 0) {
-				ret = 1;
-				goto done;
-			}
+		nlsk = container_of(obj, struct netlink_sock, node);
+		sk = (struct sock *)nlsk;
 
-			num++;
+		if (!net_eq(sock_net(sk), net))
+			continue;
+
+		if (sk_diag_fill(sk, skb, req,
+				 NETLINK_CB(cb->skb).portid,
+				 cb->nlh->nlmsg_seq,
+				 NLM_F_MULTI,
+				 sock_i_ino(sk)) < 0) {
+			ret = 1;
+			break;
 		}
 	}
 
+stop:
+	rhashtable_walk_stop(hti);
+	if (ret)
+		goto done;
+
+	rhashtable_walk_exit(hti);
+	cb->args[2] = 0;
+	num++;
+
+mc_list:
+	read_lock(&nl_table_lock);
 	sk_for_each_bound(sk, &tbl->mc_list) {
 		if (sk_hashed(sk))
 			continue;
@@ -116,13 +150,14 @@ static int __netlink_diag_dump(struct sk_buff *skb, struct netlink_callback *cb,
 				 NLM_F_MULTI,
 				 sock_i_ino(sk)) < 0) {
 			ret = 1;
-			goto done;
+			break;
 		}
 		num++;
 	}
+	read_unlock(&nl_table_lock);
+
 done:
 	cb->args[0] = num;
-	cb->args[1] = protocol;
 
 	return ret;
 }
@@ -131,20 +166,20 @@ static int netlink_diag_dump(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	struct netlink_diag_req *req;
 	int s_num = cb->args[0];
+	int err = 0;
 
 	req = nlmsg_data(cb->nlh);
 
-	rcu_read_lock();
-	read_lock(&nl_table_lock);
-
 	if (req->sdiag_protocol == NDIAG_PROTO_ALL) {
 		int i;
 
 		for (i = cb->args[1]; i < MAX_LINKS; i++) {
-			if (__netlink_diag_dump(skb, cb, i, s_num))
+			err = __netlink_diag_dump(skb, cb, i, s_num);
+			if (err)
 				break;
 			s_num = 0;
 		}
+		cb->args[1] = i;
 	} else {
 		if (req->sdiag_protocol >= MAX_LINKS) {
 			read_unlock(&nl_table_lock);
@@ -152,13 +187,22 @@ static int netlink_diag_dump(struct sk_buff *skb, struct netlink_callback *cb)
 			return -ENOENT;
 		}
 
-		__netlink_diag_dump(skb, cb, req->sdiag_protocol, s_num);
+		err = __netlink_diag_dump(skb, cb, req->sdiag_protocol, s_num);
 	}
 
-	read_unlock(&nl_table_lock);
-	rcu_read_unlock();
+	return err < 0 ? err : skb->len;
+}
+
+static int netlink_diag_dump_done(struct netlink_callback *cb)
+{
+	struct rhashtable_iter *hti = (void *)cb->args[2];
 
-	return skb->len;
+	if (cb->args[0] == 1)
+		rhashtable_walk_exit(hti);
+
+	kfree(hti);
+
+	return 0;
 }
 
 static int netlink_diag_handler_dump(struct sk_buff *skb, struct nlmsghdr *h)
@@ -172,6 +216,7 @@ static int netlink_diag_handler_dump(struct sk_buff *skb, struct nlmsghdr *h)
 	if (h->nlmsg_flags & NLM_F_DUMP) {
 		struct netlink_dump_control c = {
 			.dump = netlink_diag_dump,
+			.done = netlink_diag_dump_done,
 		};
 		return netlink_dump_start(net->diag_nlsk, skb, h, &c);
 	} else
