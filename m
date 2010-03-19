From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 1/3] netlink: fix NETLINK_RECV_NO_ENOBUFS in netlink_set_err()
Date: Fri, 19 Mar 2010 01:24:42 +0100
Message-ID: <4BA2C44A.1000100@netfilter.org>
References: <20100316232247.4185.19426.stgit@decadence> <20100316232957.4185.46217.stgit@decadence> <4BA0F4C0.8050901@trash.net> <4BA10095.2030905@netfilter.org> <4BA22463.6050601@trash.net> <4BA25612.3080804@netfilter.org> <4BA258F6.1050909@trash.net> <4BA25C82.7000301@netfilter.org> <4BA26138.6070709@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020006070001000908080504"
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:36055 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751145Ab0CSAYv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Mar 2010 20:24:51 -0400
In-Reply-To: <4BA26138.6070709@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020006070001000908080504
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
> Generally the logic seems inverted, you should return an error
> to conntrack if userspace wasn't notified of the error.

Indeed, thanks. Are you OK with this patch instead?


--------------020006070001000908080504
Content-Type: text/x-patch;
 name="netlink.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="netlink.patch"

netlink: fix NETLINK_RECV_NO_ENOBUFS in netlink_set_err()

Currently, ENOBUFS errors are reported to the socket via
netlink_set_err() even if NETLINK_RECV_NO_ENOBUFS is set. However,
that should not happen. This fixes this problem and it changes the
prototype of netlink_set_err() to return the number of sockets that
have set the NETLINK_RECV_NO_ENOBUFS socket option. This return
value is used in the next patch in these bugfix series.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netlink.h  |    2 +-
 net/netlink/af_netlink.c |   17 ++++++++++++++---
 2 files changed, 15 insertions(+), 4 deletions(-)

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
index 4c5972b..0052d3c 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1093,6 +1093,7 @@ static inline int do_one_set_err(struct sock *sk,
 				 struct netlink_set_err_data *p)
 {
 	struct netlink_sock *nlk = nlk_sk(sk);
+	int ret = 0;
 
 	if (sk == p->exclude_sk)
 		goto out;
@@ -1104,10 +1105,15 @@ static inline int do_one_set_err(struct sock *sk,
 	    !test_bit(p->group - 1, nlk->groups))
 		goto out;
 
+	if (p->code == ENOBUFS && nlk->flags & NETLINK_RECV_NO_ENOBUFS) {
+		ret = 1;
+		goto out;
+	}
+
 	sk->sk_err = p->code;
 	sk->sk_error_report(sk);
 out:
-	return 0;
+	return ret;
 }
 
 /**
@@ -1116,12 +1122,16 @@ out:
  * @pid: the PID of a process that we want to skip (if any)
  * @groups: the broadcast group that will notice the error
  * @code: error code, must be negative (as usual in kernelspace)
+ *
+ * This function returns the number of broadcast listeners that have set the
+ * NETLINK_RECV_NO_ENOBUFS socket option.
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
@@ -1132,9 +1142,10 @@ void netlink_set_err(struct sock *ssk, u32 pid, u32 group, int code)
 	read_lock(&nl_table_lock);
 
 	sk_for_each_bound(sk, node, &nl_table[ssk->sk_protocol].mc_list)
-		do_one_set_err(sk, &info);
+		ret += do_one_set_err(sk, &info);
 
 	read_unlock(&nl_table_lock);
+	return ret;
 }
 EXPORT_SYMBOL(netlink_set_err);
 

--------------020006070001000908080504--
