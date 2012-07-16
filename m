From: Andrew Vagin <avagin@openvz.org>
Subject: [PATCH] net-next: make sock diag per-namespace
Date: Mon, 16 Jul 2012 16:14:09 +0400
Message-ID: <1342440849-1757320-1-git-send-email-avagin@openvz.org>
Cc: Andrew Vagin <avagin@openvz.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Pavel Emelyanov <xemul@parallels.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:16645 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751182Ab2GPMOq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jul 2012 08:14:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before this patch sock_diag works for init_net only and dumps
information about sockets from all namespaces.

This patch expands sock_diag for all name-spaces.
It creates a netlink kernel socket for each netns and filters
data during dumping.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: James Morris <jmorris@namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>
Cc: Pavel Emelyanov <xemul@parallels.com>
Cc: linux-kernel@vger.kernel.org
Cc: netdev@vger.kernel.org
Signed-off-by: Andrew Vagin <avagin@openvz.org>
---
 include/linux/sock_diag.h   |    1 -
 include/net/net_namespace.h |    1 +
 net/core/sock_diag.c        |   28 ++++++++++++++++++++++------
 net/ipv4/inet_diag.c        |   13 ++++++++++---
 net/ipv4/udp_diag.c         |    3 ++-
 net/unix/diag.c             |    9 +++++++--
 6 files changed, 42 insertions(+), 13 deletions(-)

diff --git a/include/linux/sock_diag.h b/include/linux/sock_diag.h
index 6793fac..e3e395a 100644
--- a/include/linux/sock_diag.h
+++ b/include/linux/sock_diag.h
@@ -44,6 +44,5 @@ void sock_diag_save_cookie(void *sk, __u32 *cookie);
 
 int sock_diag_put_meminfo(struct sock *sk, struct sk_buff *skb, int attr);
 
-extern struct sock *sock_diag_nlsk;
 #endif /* KERNEL */
 #endif
diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index ac9195e..ae1cd6c 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -101,6 +101,7 @@ struct net {
 	struct netns_xfrm	xfrm;
 #endif
 	struct netns_ipvs	*ipvs;
+	struct sock		*diag_nlsk;
 };
 
 
diff --git a/net/core/sock_diag.c b/net/core/sock_diag.c
index 07a29eb..d060251 100644
--- a/net/core/sock_diag.c
+++ b/net/core/sock_diag.c
@@ -166,23 +166,39 @@ static void sock_diag_rcv(struct sk_buff *skb)
 	mutex_unlock(&sock_diag_mutex);
 }
 
-struct sock *sock_diag_nlsk;
-EXPORT_SYMBOL_GPL(sock_diag_nlsk);
+struct sock *diag_nlsk;
+EXPORT_SYMBOL_GPL(diag_nlsk);
 
-static int __init sock_diag_init(void)
+static int __net_init diag_net_init(struct net *net)
 {
 	struct netlink_kernel_cfg cfg = {
 		.input	= sock_diag_rcv,
 	};
 
-	sock_diag_nlsk = netlink_kernel_create(&init_net, NETLINK_SOCK_DIAG,
+	net->diag_nlsk = netlink_kernel_create(net, NETLINK_SOCK_DIAG,
 					       THIS_MODULE, &cfg);
-	return sock_diag_nlsk == NULL ? -ENOMEM : 0;
+	return net->diag_nlsk == NULL ? -ENOMEM : 0;
+}
+
+static void __net_exit diag_net_exit(struct net *net)
+{
+	netlink_kernel_release(net->diag_nlsk);
+	net->diag_nlsk = NULL;
+}
+
+static struct pernet_operations diag_net_ops = {
+	.init = diag_net_init,
+	.exit = diag_net_exit,
+};
+
+static int __init sock_diag_init(void)
+{
+	return register_pernet_subsys(&diag_net_ops);
 }
 
 static void __exit sock_diag_exit(void)
 {
-	netlink_kernel_release(sock_diag_nlsk);
+	unregister_pernet_subsys(&diag_net_ops);
 }
 
 module_init(sock_diag_init);
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 38064a2..4703c58 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -272,6 +272,7 @@ int inet_diag_dump_one_icsk(struct inet_hashinfo *hashinfo, struct sk_buff *in_s
 	int err;
 	struct sock *sk;
 	struct sk_buff *rep;
+	struct net *net = sock_net(in_skb->sk);
 
 	err = -EINVAL;
 	if (req->sdiag_family == AF_INET) {
@@ -317,7 +318,7 @@ int inet_diag_dump_one_icsk(struct inet_hashinfo *hashinfo, struct sk_buff *in_s
 		nlmsg_free(rep);
 		goto out;
 	}
-	err = netlink_unicast(sock_diag_nlsk, rep, NETLINK_CB(in_skb).pid,
+	err = netlink_unicast(net->diag_nlsk, rep, NETLINK_CB(in_skb).pid,
 			      MSG_DONTWAIT);
 	if (err > 0)
 		err = 0;
@@ -724,6 +725,7 @@ void inet_diag_dump_icsk(struct inet_hashinfo *hashinfo, struct sk_buff *skb,
 {
 	int i, num;
 	int s_i, s_num;
+	struct net *net = sock_net(skb->sk);
 
 	s_i = cb->args[1];
 	s_num = num = cb->args[2];
@@ -743,6 +745,9 @@ void inet_diag_dump_icsk(struct inet_hashinfo *hashinfo, struct sk_buff *skb,
 			sk_nulls_for_each(sk, node, &ilb->head) {
 				struct inet_sock *inet = inet_sk(sk);
 
+				if (!net_eq(sock_net(sk), net))
+					continue;
+
 				if (num < s_num) {
 					num++;
 					continue;
@@ -943,6 +948,7 @@ static int inet_diag_get_exact_compat(struct sk_buff *in_skb,
 static int inet_diag_rcv_msg_compat(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	int hdrlen = sizeof(struct inet_diag_req);
+	struct net *net = sock_net(skb->sk);
 
 	if (nlh->nlmsg_type >= INET_DIAG_GETSOCK_MAX ||
 	    nlmsg_len(nlh) < hdrlen)
@@ -963,7 +969,7 @@ static int inet_diag_rcv_msg_compat(struct sk_buff *skb, struct nlmsghdr *nlh)
 			struct netlink_dump_control c = {
 				.dump = inet_diag_dump_compat,
 			};
-			return netlink_dump_start(sock_diag_nlsk, skb, nlh, &c);
+			return netlink_dump_start(net->diag_nlsk, skb, nlh, &c);
 		}
 	}
 
@@ -973,6 +979,7 @@ static int inet_diag_rcv_msg_compat(struct sk_buff *skb, struct nlmsghdr *nlh)
 static int inet_diag_handler_dump(struct sk_buff *skb, struct nlmsghdr *h)
 {
 	int hdrlen = sizeof(struct inet_diag_req_v2);
+	struct net *net = sock_net(skb->sk);
 
 	if (nlmsg_len(h) < hdrlen)
 		return -EINVAL;
@@ -991,7 +998,7 @@ static int inet_diag_handler_dump(struct sk_buff *skb, struct nlmsghdr *h)
 			struct netlink_dump_control c = {
 				.dump = inet_diag_dump,
 			};
-			return netlink_dump_start(sock_diag_nlsk, skb, h, &c);
+			return netlink_dump_start(net->diag_nlsk, skb, h, &c);
 		}
 	}
 
diff --git a/net/ipv4/udp_diag.c b/net/ipv4/udp_diag.c
index a7f86a3..52f42f9 100644
--- a/net/ipv4/udp_diag.c
+++ b/net/ipv4/udp_diag.c
@@ -34,6 +34,7 @@ static int udp_dump_one(struct udp_table *tbl, struct sk_buff *in_skb,
 	int err = -EINVAL;
 	struct sock *sk;
 	struct sk_buff *rep;
+	struct net *net = sock_net(in_skb->sk);
 
 	if (req->sdiag_family == AF_INET)
 		sk = __udp4_lib_lookup(&init_net,
@@ -75,7 +76,7 @@ static int udp_dump_one(struct udp_table *tbl, struct sk_buff *in_skb,
 		kfree_skb(rep);
 		goto out;
 	}
-	err = netlink_unicast(sock_diag_nlsk, rep, NETLINK_CB(in_skb).pid,
+	err = netlink_unicast(net->diag_nlsk, rep, NETLINK_CB(in_skb).pid,
 			      MSG_DONTWAIT);
 	if (err > 0)
 		err = 0;
diff --git a/net/unix/diag.c b/net/unix/diag.c
index a74864e..750b134 100644
--- a/net/unix/diag.c
+++ b/net/unix/diag.c
@@ -177,6 +177,7 @@ static int unix_diag_dump(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	struct unix_diag_req *req;
 	int num, s_num, slot, s_slot;
+	struct net *net = sock_net(skb->sk);
 
 	req = nlmsg_data(cb->nlh);
 
@@ -192,6 +193,8 @@ static int unix_diag_dump(struct sk_buff *skb, struct netlink_callback *cb)
 
 		num = 0;
 		sk_for_each(sk, node, &unix_socket_table[slot]) {
+			if (!net_eq(sock_net(sk), net))
+				continue;
 			if (num < s_num)
 				goto next;
 			if (!(req->udiag_states & (1 << sk->sk_state)))
@@ -243,6 +246,7 @@ static int unix_diag_get_exact(struct sk_buff *in_skb,
 	struct sock *sk;
 	struct sk_buff *rep;
 	unsigned int extra_len;
+	struct net *net = sock_net(in_skb->sk);
 
 	if (req->udiag_ino == 0)
 		goto out_nosk;
@@ -273,7 +277,7 @@ again:
 
 		goto again;
 	}
-	err = netlink_unicast(sock_diag_nlsk, rep, NETLINK_CB(in_skb).pid,
+	err = netlink_unicast(net->diag_nlsk, rep, NETLINK_CB(in_skb).pid,
 			      MSG_DONTWAIT);
 	if (err > 0)
 		err = 0;
@@ -287,6 +291,7 @@ out_nosk:
 static int unix_diag_handler_dump(struct sk_buff *skb, struct nlmsghdr *h)
 {
 	int hdrlen = sizeof(struct unix_diag_req);
+	struct net *net = sock_net(skb->sk);
 
 	if (nlmsg_len(h) < hdrlen)
 		return -EINVAL;
@@ -295,7 +300,7 @@ static int unix_diag_handler_dump(struct sk_buff *skb, struct nlmsghdr *h)
 		struct netlink_dump_control c = {
 			.dump = unix_diag_dump,
 		};
-		return netlink_dump_start(sock_diag_nlsk, skb, h, &c);
+		return netlink_dump_start(net->diag_nlsk, skb, h, &c);
 	} else
 		return unix_diag_get_exact(skb, h, nlmsg_data(h));
 }
-- 
1.7.1
