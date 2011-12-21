From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/3] netlink: af_netlink cleanup
Date: Wed, 21 Dec 2011 13:47:29 -0800
Message-ID: <20111221134729.3d652e24@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50863 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751848Ab1LUVtz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Dec 2011 16:49:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't inline functions that cover several lines, and do inline
the trivial ones. Also make some arguments const.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/netlink/af_netlink.c	2011-12-19 13:35:37.927992632 -0800
+++ b/net/netlink/af_netlink.c	2011-12-20 10:20:33.356914405 -0800
@@ -98,7 +98,7 @@ static inline struct netlink_sock *nlk_s
 	return container_of(sk, struct netlink_sock, sk);
 }
 
-static inline int netlink_is_kernel(struct sock *sk)
+static inline int netlink_is_kernel(const struct sock *sk)
 {
 	return nlk_sk(sk)->flags & NETLINK_KERNEL_SOCKET;
 }
@@ -139,12 +139,12 @@ static atomic_t nl_table_users = ATOMIC_
 
 static ATOMIC_NOTIFIER_HEAD(netlink_chain);
 
-static u32 netlink_group_mask(u32 group)
+static inline u32 netlink_group_mask(u32 group)
 {
 	return group ? 1 << (group - 1) : 0;
 }
 
-static struct hlist_head *nl_pid_hashfn(struct nl_pid_hash *hash, u32 pid)
+static inline struct hlist_head *nl_pid_hashfn(struct nl_pid_hash *hash, u32 pid)
 {
 	return &hash->table[jhash_1word(pid, hash->rnd) & hash->mask];
 }
@@ -226,7 +226,7 @@ netlink_unlock_table(void)
 		wake_up(&nl_table_wait);
 }
 
-static inline struct sock *netlink_lookup(struct net *net, int protocol,
+static struct sock *netlink_lookup(struct net *net, int protocol,
 					  u32 pid)
 {
 	struct nl_pid_hash *hash = &nl_table[protocol].hash;
@@ -248,7 +248,7 @@ found:
 	return sk;
 }
 
-static inline struct hlist_head *nl_pid_hash_zalloc(size_t size)
+static struct hlist_head *nl_pid_hash_zalloc(size_t size)
 {
 	if (size <= PAGE_SIZE)
 		return kzalloc(size, GFP_ATOMIC);
@@ -258,7 +258,7 @@ static inline struct hlist_head *nl_pid_
 					 get_order(size));
 }
 
-static inline void nl_pid_hash_free(struct hlist_head *table, size_t size)
+static void nl_pid_hash_free(struct hlist_head *table, size_t size)
 {
 	if (size <= PAGE_SIZE)
 		kfree(table);
@@ -578,7 +578,7 @@ retry:
 	return err;
 }
 
-static inline int netlink_capable(struct socket *sock, unsigned int flag)
+static inline int netlink_capable(const struct socket *sock, unsigned int flag)
 {
 	return (nl_table[sock->sk->sk_protocol].nl_nonroot & flag) ||
 	       capable(CAP_NET_ADMIN);
@@ -846,7 +846,7 @@ void netlink_detachskb(struct sock *sk,
 	sock_put(sk);
 }
 
-static inline struct sk_buff *netlink_trim(struct sk_buff *skb,
+static struct sk_buff *netlink_trim(struct sk_buff *skb,
 					   gfp_t allocation)
 {
 	int delta;
@@ -871,7 +871,7 @@ static inline struct sk_buff *netlink_tr
 	return skb;
 }
 
-static inline void netlink_rcv_wake(struct sock *sk)
+static void netlink_rcv_wake(struct sock *sk)
 {
 	struct netlink_sock *nlk = nlk_sk(sk);
 
@@ -881,7 +881,7 @@ static inline void netlink_rcv_wake(stru
 		wake_up_interruptible(&nlk->wait);
 }
 
-static inline int netlink_unicast_kernel(struct sock *sk, struct sk_buff *skb)
+static int netlink_unicast_kernel(struct sock *sk, struct sk_buff *skb)
 {
 	int ret;
 	struct netlink_sock *nlk = nlk_sk(sk);
@@ -952,7 +952,7 @@ int netlink_has_listeners(struct sock *s
 }
 EXPORT_SYMBOL_GPL(netlink_has_listeners);
 
-static inline int netlink_broadcast_deliver(struct sock *sk,
+static int netlink_broadcast_deliver(struct sock *sk,
 					    struct sk_buff *skb)
 {
 	struct netlink_sock *nlk = nlk_sk(sk);
@@ -982,7 +982,7 @@ struct netlink_broadcast_data {
 	void *tx_data;
 };
 
-static inline int do_one_broadcast(struct sock *sk,
+static int do_one_broadcast(struct sock *sk,
 				   struct netlink_broadcast_data *p)
 {
 	struct netlink_sock *nlk = nlk_sk(sk);
@@ -1110,7 +1110,7 @@ struct netlink_set_err_data {
 	int code;
 };
 
-static inline int do_one_set_err(struct sock *sk,
+static int do_one_set_err(struct sock *sk,
 				 struct netlink_set_err_data *p)
 {
 	struct netlink_sock *nlk = nlk_sk(sk);
--- a/net/netlink/genetlink.c	2011-12-07 10:54:21.808303161 -0800
+++ b/net/netlink/genetlink.c	2011-12-20 10:19:23.104114471 -0800
@@ -106,7 +106,7 @@ static struct genl_ops *genl_get_cmd(u8
 /* Of course we are going to have problems once we hit
  * 2^16 alive types, but that can only happen by year 2K
 */
-static inline u16 genl_generate_id(void)
+static u16 genl_generate_id(void)
 {
 	static u16 id_gen_idx = GENL_MIN_ID;
 	int i;
