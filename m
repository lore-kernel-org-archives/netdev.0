From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next v3 2/2] net: Allow accepted sockets to be bound to l3mdev domain
Date: Wed, 16 Dec 2015 13:20:44 -0800
Message-ID: <1450300844-11010-3-git-send-email-dsa@cumulusnetworks.com>
References: <1450300844-11010-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:32955 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966873AbbLPVUz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2015 16:20:55 -0500
Received: by mail-pf0-f177.google.com with SMTP id e66so18849540pfe.0
        for <netdev@vger.kernel.org>; Wed, 16 Dec 2015 13:20:55 -0800 (PST)
In-Reply-To: <1450300844-11010-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow accepted sockets to derive their sk_bound_dev_if setting from the
l3mdev domain in which the packets originated. A sysctl setting is added
to control the behavior which is similar to sk_mark and
sysctl_tcp_fwmark_accept.

This effectively allow a process to have a "VRF-global" listen socket,
with child sockets bound to the VRF device in which the packet originated.
A similar behavior can be achieved using sk_mark, but a solution using marks
is incomplete as it does not handle duplicate addresses in different L3
domains/VRFs. Allowing sockets to inherit the sk_bound_dev_if from l3mdev
domain provides a complete solution.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
v3
- wrap the sysctl and its use with CONFIG_NET_L3_MASTER_DEV check

v2
- added sysctl option. wrapped l3mdev lookup in helper function
  similar to marks

 Documentation/networking/ip-sysctl.txt |  8 ++++++++
 include/net/inet_sock.h                | 14 ++++++++++++++
 include/net/netns/ipv4.h               |  3 +++
 net/ipv4/syncookies.c                  |  4 ++--
 net/ipv4/sysctl_net_ipv4.c             | 11 +++++++++++
 net/ipv4/tcp_input.c                   |  2 +-
 net/ipv4/tcp_ipv4.c                    |  1 +
 net/ipv6/syncookies.c                  |  4 ++--
 8 files changed, 42 insertions(+), 5 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 2ea4c45cf1c8..d104ec6cd2e4 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -335,6 +335,14 @@ tcp_keepalive_intvl - INTEGER
 	after probes started. Default value: 75sec i.e. connection
 	will be aborted after ~11 minutes of retries.
 
+tcp_l3mdev_accept - BOOLEAN
+	Enables child sockets to inherit the L3 master device index.
+	Enabling this option allows a "global" listen socket to work
+	across L3 master domains (e.g., VRFs) with connected sockets
+	derived from the listen socket to be bound to the L3 domain in
+	which the packets originated. Only valid when the kernel was
+	compiled with CONFIG_NET_L3_MASTER_DEV.
+
 tcp_low_latency - BOOLEAN
 	If set, the TCP stack makes decisions that prefer lower
 	latency as opposed to higher throughput.  By default, this
diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index 2134e6d815bc..71c119d53b40 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -28,6 +28,7 @@
 #include <net/request_sock.h>
 #include <net/netns/hash.h>
 #include <net/tcp_states.h>
+#include <net/l3mdev.h>
 
 /** struct ip_options - IP Options
  *
@@ -113,6 +114,19 @@ static inline u32 inet_request_mark(const struct sock *sk, struct sk_buff *skb)
 	return sk->sk_mark;
 }
 
+static inline int inet_request_bound_dev_if(const struct sock *sk,
+					    struct sk_buff *skb)
+{
+#ifdef CONFIG_NET_L3_MASTER_DEV
+	struct net *net = sock_net(sk);
+
+	if (!sk->sk_bound_dev_if && net->ipv4.sysctl_tcp_l3mdev_accept)
+		return l3mdev_master_ifindex_by_index(net, skb->skb_iif);
+#endif
+
+	return sk->sk_bound_dev_if;
+}
+
 struct inet_cork {
 	unsigned int		flags;
 	__be32			addr;
diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index c68926b4899c..d75be32650ba 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -86,6 +86,9 @@ struct netns_ipv4 {
 
 	int sysctl_fwmark_reflect;
 	int sysctl_tcp_fwmark_accept;
+#ifdef CONFIG_NET_L3_MASTER_DEV
+	int sysctl_tcp_l3mdev_accept;
+#endif
 	int sysctl_tcp_mtu_probing;
 	int sysctl_tcp_base_mss;
 	int sysctl_tcp_probe_threshold;
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 4cbe9f0a4281..643a86c49020 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -351,7 +351,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb)
 	treq->snt_synack.v64	= 0;
 	treq->tfo_listener	= false;
 
-	ireq->ir_iif = sk->sk_bound_dev_if;
+	ireq->ir_iif = inet_request_bound_dev_if(sk, skb);
 
 	/* We throwed the options of the initial SYN away, so we hope
 	 * the ACK carries the same options again (see RFC1122 4.2.3.8)
@@ -371,7 +371,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb)
 	 * hasn't changed since we received the original syn, but I see
 	 * no easy way to do this.
 	 */
-	flowi4_init_output(&fl4, sk->sk_bound_dev_if, ireq->ir_mark,
+	flowi4_init_output(&fl4, ireq->ir_iif, ireq->ir_mark,
 			   RT_CONN_FLAGS(sk), RT_SCOPE_UNIVERSE, IPPROTO_TCP,
 			   inet_sk_flowi_flags(sk),
 			   opt->srr ? opt->faddr : ireq->ir_rmt_addr,
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index a0bd7a55193e..41ff1f87dfd7 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -915,6 +915,17 @@ static struct ctl_table ipv4_net_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
+#ifdef CONFIG_NET_L3_MASTER_DEV
+	{
+		.procname	= "tcp_l3mdev_accept",
+		.data		= &init_net.ipv4.sysctl_tcp_l3mdev_accept,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
+		.extra2		= &one,
+	},
+#endif
 	{
 		.procname	= "tcp_mtu_probing",
 		.data		= &init_net.ipv4.sysctl_tcp_mtu_probing,
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 2d656eef7f8e..7b1fddc47019 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -6204,7 +6204,7 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
 	tcp_openreq_init(req, &tmp_opt, skb, sk);
 
 	/* Note: tcp_v6_init_req() might override ir_iif for link locals */
-	inet_rsk(req)->ir_iif = sk->sk_bound_dev_if;
+	inet_rsk(req)->ir_iif = inet_request_bound_dev_if(sk, skb);
 
 	af_ops->init_req(req, sk, skb);
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 7aa13bd3de29..5d2a17b8cb72 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1276,6 +1276,7 @@ struct sock *tcp_v4_syn_recv_sock(const struct sock *sk, struct sk_buff *skb,
 	ireq		      = inet_rsk(req);
 	sk_daddr_set(newsk, ireq->ir_rmt_addr);
 	sk_rcv_saddr_set(newsk, ireq->ir_loc_addr);
+	newsk->sk_bound_dev_if = ireq->ir_iif;
 	newinet->inet_saddr	      = ireq->ir_loc_addr;
 	inet_opt	      = ireq->opt;
 	rcu_assign_pointer(newinet->inet_opt, inet_opt);
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index eaf7ac496d50..2906ef20795e 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -193,7 +193,7 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 		ireq->pktopts = skb;
 	}
 
-	ireq->ir_iif = sk->sk_bound_dev_if;
+	ireq->ir_iif = inet_request_bound_dev_if(sk, skb);
 	/* So that link locals have meaning */
 	if (!sk->sk_bound_dev_if &&
 	    ipv6_addr_type(&ireq->ir_v6_rmt_addr) & IPV6_ADDR_LINKLOCAL)
@@ -224,7 +224,7 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 		fl6.daddr = ireq->ir_v6_rmt_addr;
 		final_p = fl6_update_dst(&fl6, rcu_dereference(np->opt), &final);
 		fl6.saddr = ireq->ir_v6_loc_addr;
-		fl6.flowi6_oif = sk->sk_bound_dev_if;
+		fl6.flowi6_oif = ireq->ir_iif;
 		fl6.flowi6_mark = ireq->ir_mark;
 		fl6.fl6_dport = ireq->ir_rmt_port;
 		fl6.fl6_sport = inet_sk(sk)->inet_sport;
-- 
1.9.1
