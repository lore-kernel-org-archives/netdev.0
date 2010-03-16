From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/3] netlink: fix NETLINK_RECV_NO_ENOBUFS in netlink_set_err()
Date: Wed, 17 Mar 2010 00:29:57 +0100
Message-ID: <20100316232957.4185.46217.stgit@decadence>
References: <20100316232247.4185.19426.stgit@decadence>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:58967 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751143Ab0CPXaE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Mar 2010 19:30:04 -0400
In-Reply-To: <20100316232247.4185.19426.stgit@decadence>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, ENOBUFS errors are reported to the socket via
netlink_set_err() even if NETLINK_RECV_NO_ENOBUFS is set. However,
that should not happen. This fixes this problem and it changes the
prototype of netlink_set_err() to return the number of sockets whose
error has been set. This allows to know if any error has been set.
This return value is used in the next patch in these bugfix series.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netlink.h  |    2 +-
 net/netlink/af_netlink.c |   13 +++++++++++--
 2 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index fde27c0..6eaca5e 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -188,7 +188,7 @@ extern int netlink_has_listeners(struct sock *sk, unsigned int group);
 extern int netlink_unicast(struct sock *ssk, struct sk_buff *skb, __u32 pid, int nonblock);
 extern int netlink_broadcast(struct sock *ssk, struct sk_buff *skb, __u32 pid,
 			     __u32 group, gfp_t allocation);
-extern void netlink_set_err(struct sock *ssk, __u32 pid, __u32 group, int code);
+extern int netlink_set_err(struct sock *ssk, __u32 pid, __u32 group, int code);
 extern int netlink_register_notifier(struct notifier_block *nb);
 extern int netlink_unregister_notifier(struct notifier_block *nb);
 
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 4c5972b..24ec840 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1104,8 +1104,12 @@ static inline int do_one_set_err(struct sock *sk,
 	    !test_bit(p->group - 1, nlk->groups))
 		goto out;
 
+	if (p->code == ENOBUFS && nlk->flags & NETLINK_RECV_NO_ENOBUFS) {
+		goto out;
+
 	sk->sk_err = p->code;
 	sk->sk_error_report(sk);
+	return 1;
 out:
 	return 0;
 }
@@ -1116,12 +1120,16 @@ out:
  * @pid: the PID of a process that we want to skip (if any)
  * @groups: the broadcast group that will notice the error
  * @code: error code, must be negative (as usual in kernelspace)
+ *
+ * This function returns the number of broadcast listeners whose error code
+ * has been set.
  */
-void netlink_set_err(struct sock *ssk, u32 pid, u32 group, int code)
+int netlink_set_err(struct sock *ssk, u32 pid, u32 group, int code)
 {
 	struct netlink_set_err_data info;
 	struct hlist_node *node;
 	struct sock *sk;
+	int ret = 0;
 
 	info.exclude_sk = ssk;
 	info.pid = pid;
@@ -1132,9 +1140,10 @@ void netlink_set_err(struct sock *ssk, u32 pid, u32 group, int code)
 	read_lock(&nl_table_lock);
 
 	sk_for_each_bound(sk, node, &nl_table[ssk->sk_protocol].mc_list)
-		do_one_set_err(sk, &info);
+		ret += do_one_set_err(sk, &info);
 
 	read_unlock(&nl_table_lock);
+	return ret;
 }
 EXPORT_SYMBOL(netlink_set_err);
 

