From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv3 net-next 4/6] sctp: add the sctp_diag.c file
Date: Thu, 14 Apr 2016 15:35:33 +0800
Message-ID: <c48759e983ae5f9cefdd1805025abb7f57299886.1460618169.git.lucien.xin@gmail.com>
References: <cover.1460618169.git.lucien.xin@gmail.com>
 <cd6bf9c2696f125a74491e1f82b77a30bb1005dd.1460618169.git.lucien.xin@gmail.com>
 <d3fc80db41935f6b22d9fffc5854de63fb842899.1460618169.git.lucien.xin@gmail.com>
 <c771f8320e007cd5d1801a820f0cca8f7ed7235c.1460618169.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net,
	davem@davemloft.net, eric.dumazet@gmail.com
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:35085 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753796AbcDNHf7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 03:35:59 -0400
In-Reply-To: <c771f8320e007cd5d1801a820f0cca8f7ed7235c.1460618169.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1460618169.git.lucien.xin@gmail.com>
References: <cover.1460618169.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This one will implement all the interface of inet_diag, inet_diag_handler.
which includes sctp_diag_dump, sctp_diag_dump_one and sctp_diag_get_info.

It will work as a module, and register inet_diag_handler when loading.

v2->v3:
- fix the mistake in inet_assoc_attr_size().

- change inet_diag_msg_laddrs_fill() name to inet_diag_msg_sctpladdrs_fill.

- change inet_diag_msg_paddrs_fill() name to inet_diag_msg_sctpaddrs_fill.

- add inet_diag_msg_sctpinfo_fill() to make asoc/ep fill code clearer.

- add inet_diag_msg_sctpasoc_fill() to make asoc fill code clearer.

- merge inet_asoc_diag_fill() and inet_ep_diag_fill() to
  inet_sctp_diag_fill().

- call sctp_diag_get_info() directly, instead by handler, cause the caller
  is in the same file with it.

- call lock_sock in sctp_tsp_dump_one() to make sure we call get sctp info
  safely.

- after lock_sock(sk), we should check sk != assoc->base.sk.

- change mem[SK_MEMINFO_WMEM_ALLOC] to asoc->sndbuf_used for asoc dump when
  asoc->ep->sndbuf_policy is set. don't use INET_DIAG_MEMINFO attr any more.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/uapi/linux/inet_diag.h |   2 +
 net/sctp/Kconfig               |   4 +
 net/sctp/Makefile              |   1 +
 net/sctp/sctp_diag.c           | 497 +++++++++++++++++++++++++++++++++++++++++
 4 files changed, 504 insertions(+)
 create mode 100644 net/sctp/sctp_diag.c

diff --git a/include/uapi/linux/inet_diag.h b/include/uapi/linux/inet_diag.h
index 68a1f71..f5f3629 100644
--- a/include/uapi/linux/inet_diag.h
+++ b/include/uapi/linux/inet_diag.h
@@ -113,6 +113,8 @@ enum {
 	INET_DIAG_DCTCPINFO,
 	INET_DIAG_PROTOCOL,  /* response attribute only */
 	INET_DIAG_SKV6ONLY,
+	INET_DIAG_LOCALS,
+	INET_DIAG_PEERS,
 };
 
 #define INET_DIAG_MAX INET_DIAG_SKV6ONLY
diff --git a/net/sctp/Kconfig b/net/sctp/Kconfig
index 71c1a59..d9c04dc 100644
--- a/net/sctp/Kconfig
+++ b/net/sctp/Kconfig
@@ -99,5 +99,9 @@ config SCTP_COOKIE_HMAC_SHA1
 	select CRYPTO_HMAC if SCTP_COOKIE_HMAC_SHA1
 	select CRYPTO_SHA1 if SCTP_COOKIE_HMAC_SHA1
 
+config INET_SCTP_DIAG
+	depends on INET_DIAG
+	def_tristate INET_DIAG
+
 
 endif # IP_SCTP
diff --git a/net/sctp/Makefile b/net/sctp/Makefile
index 3b4ffb0..0fca582 100644
--- a/net/sctp/Makefile
+++ b/net/sctp/Makefile
@@ -4,6 +4,7 @@
 
 obj-$(CONFIG_IP_SCTP) += sctp.o
 obj-$(CONFIG_NET_SCTPPROBE) += sctp_probe.o
+obj-$(CONFIG_INET_SCTP_DIAG) += sctp_diag.o
 
 sctp-y := sm_statetable.o sm_statefuns.o sm_sideeffect.o \
 	  protocol.o endpointola.o associola.o \
diff --git a/net/sctp/sctp_diag.c b/net/sctp/sctp_diag.c
new file mode 100644
index 0000000..98ecd16
--- /dev/null
+++ b/net/sctp/sctp_diag.c
@@ -0,0 +1,497 @@
+#include <linux/module.h>
+#include <linux/inet_diag.h>
+#include <linux/sock_diag.h>
+#include <net/sctp/sctp.h>
+
+extern void inet_diag_msg_common_fill(struct inet_diag_msg *r,
+				      struct sock *sk);
+extern int inet_diag_msg_attrs_fill(struct sock *sk, struct sk_buff *skb,
+				    struct inet_diag_msg *r, int ext,
+				    struct user_namespace *user_ns);
+
+static void sctp_diag_get_info(struct sock *sk, struct inet_diag_msg *r,
+			       void *info);
+
+/* define some functions to make asoc/ep fill look clean */
+static void inet_diag_msg_sctpasoc_fill(struct inet_diag_msg *r,
+					struct sock *sk,
+					struct sctp_association *asoc)
+{
+	union sctp_addr laddr, paddr;
+	struct dst_entry *dst;
+
+	laddr = list_entry(asoc->base.bind_addr.address_list.next,
+			   struct sctp_sockaddr_entry, list)->a;
+	paddr = asoc->peer.primary_path->ipaddr;
+	dst = asoc->peer.primary_path->dst;
+
+	r->idiag_family = sk->sk_family;
+	r->id.idiag_sport = htons(asoc->base.bind_addr.port);
+	r->id.idiag_dport = htons(asoc->peer.port);
+	r->id.idiag_if = dst ? dst->dev->ifindex : 0;
+	sock_diag_save_cookie(sk, r->id.idiag_cookie);
+
+#if IS_ENABLED(CONFIG_IPV6)
+	if (sk->sk_family == AF_INET6) {
+		*(struct in6_addr *)r->id.idiag_src = laddr.v6.sin6_addr;
+		*(struct in6_addr *)r->id.idiag_dst = paddr.v6.sin6_addr;
+	} else
+#endif
+	{
+		memset(&r->id.idiag_src, 0, sizeof(r->id.idiag_src));
+		memset(&r->id.idiag_dst, 0, sizeof(r->id.idiag_dst));
+
+		r->id.idiag_src[0] = laddr.v4.sin_addr.s_addr;
+		r->id.idiag_dst[0] = paddr.v4.sin_addr.s_addr;
+	}
+
+	r->idiag_state = asoc->state;
+	r->idiag_timer = SCTP_EVENT_TIMEOUT_T3_RTX;
+	r->idiag_retrans = asoc->rtx_data_chunks;
+#define EXPIRES_IN_MS(tmo)  DIV_ROUND_UP((tmo - jiffies) * 1000, HZ)
+	r->idiag_expires =
+		EXPIRES_IN_MS(asoc->timeouts[SCTP_EVENT_TIMEOUT_T3_RTX]);
+#undef EXPIRES_IN_MS
+}
+
+static int inet_diag_msg_sctpladdrs_fill(struct sk_buff *skb,
+					 struct list_head *address_list)
+{
+	struct sctp_sockaddr_entry *laddr;
+	int addrlen = sizeof(struct sockaddr_storage);
+	int addrcnt = 0;
+	struct nlattr *attr;
+	void *info = NULL;
+
+	list_for_each_entry_rcu(laddr, address_list, list)
+		addrcnt++;
+
+	attr = nla_reserve(skb, INET_DIAG_LOCALS, addrlen * addrcnt);
+	if (!attr)
+		return -EMSGSIZE;
+
+	info = nla_data(attr);
+	list_for_each_entry_rcu(laddr, address_list, list) {
+		memcpy(info, &laddr->a, addrlen);
+		info += addrlen;
+	}
+
+	return 0;
+}
+
+static int inet_diag_msg_sctpaddrs_fill(struct sk_buff *skb,
+					struct sctp_association *asoc)
+{
+	int addrlen = sizeof(struct sockaddr_storage);
+	struct sctp_transport *from;
+	struct nlattr *attr;
+	void *info = NULL;
+
+	attr = nla_reserve(skb, INET_DIAG_PEERS,
+			   addrlen * asoc->peer.transport_count);
+	if (!attr)
+		return -EMSGSIZE;
+
+	info = nla_data(attr);
+	list_for_each_entry(from, &asoc->peer.transport_addr_list,
+			    transports) {
+		memcpy(info, &from->ipaddr, addrlen);
+		info += addrlen;
+	}
+
+	return 0;
+}
+
+/* sctp asoc/ep fill*/
+static int inet_sctp_diag_fill(struct sock *sk, struct sctp_association *asoc,
+			       struct sk_buff *skb,
+			       const struct inet_diag_req_v2 *req,
+			       struct user_namespace *user_ns,
+			       int portid, u32 seq, u16 nlmsg_flags,
+			       const struct nlmsghdr *unlh)
+{
+	struct sctp_endpoint *ep = sctp_sk(sk)->ep;
+	struct list_head *addr_list;
+	struct inet_diag_msg *r;
+	struct nlmsghdr  *nlh;
+	int ext = req->idiag_ext;
+	struct sctp_infox infox;
+	void *info = NULL;
+
+	nlh = nlmsg_put(skb, portid, seq, unlh->nlmsg_type, sizeof(*r),
+			nlmsg_flags);
+	if (!nlh)
+		return -EMSGSIZE;
+
+	r = nlmsg_data(nlh);
+	BUG_ON(!sk_fullsock(sk));
+
+	if (asoc) {
+		inet_diag_msg_sctpasoc_fill(r, sk, asoc);
+	} else {
+		inet_diag_msg_common_fill(r, sk);
+		r->idiag_state = sk->sk_state;
+		r->idiag_timer = 0;
+		r->idiag_retrans = 0;
+	}
+
+	if (inet_diag_msg_attrs_fill(sk, skb, r, ext, user_ns))
+		goto errout;
+
+	if (ext & (1 << (INET_DIAG_SKMEMINFO - 1))) {
+		u32 mem[SK_MEMINFO_VARS];
+		int amt;
+
+		if (asoc && asoc->ep->sndbuf_policy)
+			amt = asoc->sndbuf_used;
+		else
+			amt = sk_wmem_alloc_get(sk);
+		mem[SK_MEMINFO_WMEM_ALLOC] = amt;
+		mem[SK_MEMINFO_RMEM_ALLOC] = sk_rmem_alloc_get(sk);
+		mem[SK_MEMINFO_RCVBUF] = sk->sk_rcvbuf;
+		mem[SK_MEMINFO_SNDBUF] = sk->sk_sndbuf;
+		mem[SK_MEMINFO_FWD_ALLOC] = sk->sk_forward_alloc;
+		mem[SK_MEMINFO_WMEM_QUEUED] = sk->sk_wmem_queued;
+		mem[SK_MEMINFO_OPTMEM] = atomic_read(&sk->sk_omem_alloc);
+		mem[SK_MEMINFO_BACKLOG] = sk->sk_backlog.len;
+		mem[SK_MEMINFO_DROPS] = atomic_read(&sk->sk_drops);
+
+		if (nla_put(skb, INET_DIAG_SKMEMINFO, sizeof(mem), &mem) < 0)
+			goto errout;
+	}
+
+	if (ext & (1 << (INET_DIAG_INFO - 1))) {
+		struct nlattr *attr;
+
+		attr = nla_reserve(skb, INET_DIAG_INFO,
+				   sizeof(struct sctp_info));
+		if (!attr)
+			goto errout;
+
+		info = nla_data(attr);
+	}
+	infox.sctpinfo = (struct sctp_info *)info;
+	infox.asoc = asoc;
+	sctp_diag_get_info(sk, r, &infox);
+
+	addr_list = asoc ? &asoc->base.bind_addr.address_list
+			 : &ep->base.bind_addr.address_list;
+	if (inet_diag_msg_sctpladdrs_fill(skb, addr_list))
+		goto errout;
+
+	if (asoc && (ext & (1 << (INET_DIAG_CONG - 1))))
+		if (nla_put_string(skb, INET_DIAG_CONG, "reno") < 0)
+			goto errout;
+
+	if (asoc && inet_diag_msg_sctpaddrs_fill(skb, asoc))
+		goto errout;
+
+	nlmsg_end(skb, nlh);
+	return 0;
+
+errout:
+	nlmsg_cancel(skb, nlh);
+	return -EMSGSIZE;
+}
+
+/* callback and param */
+struct sctp_comm_param {
+	struct sk_buff *skb;
+	struct netlink_callback *cb;
+	const struct inet_diag_req_v2 *r;
+	const struct nlmsghdr *nlh;
+};
+
+static size_t inet_assoc_attr_size(struct sctp_association *asoc)
+{
+	int addrlen = sizeof(struct sockaddr_storage);
+	int addrcnt = 0;
+	struct sctp_sockaddr_entry *laddr;
+
+	list_for_each_entry_rcu(laddr, &asoc->base.bind_addr.address_list,
+				list)
+		addrcnt++;
+
+	return	  nla_total_size(sizeof(struct sctp_info))
+		+ nla_total_size(1) /* INET_DIAG_SHUTDOWN */
+		+ nla_total_size(1) /* INET_DIAG_TOS */
+		+ nla_total_size(1) /* INET_DIAG_TCLASS */
+		+ nla_total_size(addrlen * asoc->peer.transport_count)
+		+ nla_total_size(addrlen * addrcnt)
+		+ nla_total_size(sizeof(struct inet_diag_meminfo))
+		+ nla_total_size(sizeof(struct inet_diag_msg))
+		+ 64;
+}
+
+static int sctp_tsp_dump_one(struct sctp_transport *tsp, void *p)
+{
+	struct sctp_association *assoc = tsp->asoc;
+	struct sock *sk = tsp->asoc->base.sk;
+	struct sctp_comm_param *commp = p;
+	struct sk_buff *in_skb = commp->skb;
+	const struct inet_diag_req_v2 *req = commp->r;
+	const struct nlmsghdr *nlh = commp->nlh;
+	struct net *net = sock_net(in_skb->sk);
+	struct sk_buff *rep;
+	int err;
+
+	err = sock_diag_check_cookie(sk, req->id.idiag_cookie);
+	if (err)
+		goto out;
+
+	err = -ENOMEM;
+	rep = nlmsg_new(inet_assoc_attr_size(assoc), GFP_KERNEL);
+	if (!rep)
+		goto out;
+
+	lock_sock(sk);
+	if (sk != assoc->base.sk) {
+		release_sock(sk);
+		sk = assoc->base.sk;
+		lock_sock(sk);
+	}
+	err = inet_sctp_diag_fill(sk, assoc, rep, req,
+				  sk_user_ns(NETLINK_CB(in_skb).sk),
+				  NETLINK_CB(in_skb).portid,
+				  nlh->nlmsg_seq, 0, nlh);
+	release_sock(sk);
+	if (err < 0) {
+		WARN_ON(err == -EMSGSIZE);
+		kfree_skb(rep);
+		goto out;
+	}
+
+	err = netlink_unicast(net->diag_nlsk, rep, NETLINK_CB(in_skb).portid,
+			      MSG_DONTWAIT);
+	if (err > 0)
+		err = 0;
+out:
+	return err;
+}
+
+static int sctp_tsp_dump(struct sctp_transport *tsp, void *p)
+{
+	struct sctp_endpoint *ep = tsp->asoc->ep;
+	struct sctp_comm_param *commp = p;
+	struct sock *sk = ep->base.sk;
+	struct sk_buff *skb = commp->skb;
+	struct netlink_callback *cb = commp->cb;
+	const struct inet_diag_req_v2 *r = commp->r;
+	struct sctp_association *assoc =
+		list_entry(ep->asocs.next, struct sctp_association, asocs);
+	int err = 0;
+
+	/* find the ep only once through the transports by this condition */
+	if (tsp->asoc != assoc)
+		goto out;
+
+	if (r->sdiag_family != AF_UNSPEC && sk->sk_family != r->sdiag_family)
+		goto out;
+
+	lock_sock(sk);
+	if (sk != assoc->base.sk)
+		goto release;
+	list_for_each_entry(assoc, &ep->asocs, asocs) {
+		if (cb->args[4] < cb->args[1])
+			goto next;
+
+		if (r->id.idiag_sport != htons(assoc->base.bind_addr.port) &&
+		    r->id.idiag_sport)
+			goto next;
+		if (r->id.idiag_dport != htons(assoc->peer.port) &&
+		    r->id.idiag_dport)
+			goto next;
+
+		if (!cb->args[3] &&
+		    inet_sctp_diag_fill(sk, NULL, skb, r,
+					sk_user_ns(NETLINK_CB(cb->skb).sk),
+					NETLINK_CB(cb->skb).portid,
+					cb->nlh->nlmsg_seq,
+					NLM_F_MULTI, cb->nlh) < 0) {
+			cb->args[3] = 1;
+			err = 2;
+			goto release;
+		}
+		cb->args[3] = 1;
+
+		if (inet_sctp_diag_fill(sk, assoc, skb, r,
+					sk_user_ns(NETLINK_CB(cb->skb).sk),
+					NETLINK_CB(cb->skb).portid,
+					cb->nlh->nlmsg_seq, 0, cb->nlh) < 0) {
+			err = 2;
+			goto release;
+		}
+next:
+		cb->args[4]++;
+	}
+	cb->args[1] = 0;
+	cb->args[2]++;
+	cb->args[3] = 0;
+	cb->args[4] = 0;
+release:
+	release_sock(sk);
+	return err;
+out:
+	cb->args[2]++;
+	return err;
+}
+
+static int sctp_ep_dump(struct sctp_endpoint *ep, void *p)
+{
+	struct sctp_comm_param *commp = p;
+	struct sock *sk = ep->base.sk;
+	struct sk_buff *skb = commp->skb;
+	struct netlink_callback *cb = commp->cb;
+	const struct inet_diag_req_v2 *r = commp->r;
+	struct net *net = sock_net(skb->sk);
+	struct inet_sock *inet = inet_sk(sk);
+	int err = 0;
+
+	if (!net_eq(sock_net(sk), net))
+		goto out;
+
+	if (cb->args[4] < cb->args[1])
+		goto next;
+
+	if (r->sdiag_family != AF_UNSPEC &&
+	    sk->sk_family != r->sdiag_family)
+		goto next;
+
+	if (r->id.idiag_sport != inet->inet_sport &&
+	    r->id.idiag_sport)
+		goto next;
+
+	if (r->id.idiag_dport != inet->inet_dport &&
+	    r->id.idiag_dport)
+		goto next;
+
+	if (inet_sctp_diag_fill(sk, NULL, skb, r,
+				sk_user_ns(NETLINK_CB(cb->skb).sk),
+				NETLINK_CB(cb->skb).portid,
+				cb->nlh->nlmsg_seq, NLM_F_MULTI,
+				cb->nlh) < 0) {
+		err = 2;
+		goto out;
+	}
+next:
+	cb->args[4]++;
+out:
+	return err;
+}
+
+/* define the functions for sctp_diag_handler*/
+static void sctp_diag_get_info(struct sock *sk, struct inet_diag_msg *r,
+			       void *info)
+{
+	struct sctp_infox *infox = (struct sctp_infox *)info;
+
+	if (infox->asoc) {
+		r->idiag_rqueue = atomic_read(&infox->asoc->rmem_alloc);
+		r->idiag_wqueue = infox->asoc->sndbuf_used;
+	} else {
+		r->idiag_rqueue = sk->sk_ack_backlog;
+		r->idiag_wqueue = sk->sk_max_ack_backlog;
+	}
+	if (infox->sctpinfo)
+		sctp_get_sctp_info(sk, infox->asoc, infox->sctpinfo);
+}
+
+static int sctp_diag_dump_one(struct sk_buff *in_skb,
+			      const struct nlmsghdr *nlh,
+			      const struct inet_diag_req_v2 *req)
+{
+	struct net *net = sock_net(in_skb->sk);
+	union sctp_addr laddr, paddr;
+	struct sctp_comm_param commp = {
+		.skb = in_skb,
+		.r = req,
+		.nlh = nlh,
+	};
+
+	if (req->sdiag_family == AF_INET) {
+		laddr.v4.sin_port = req->id.idiag_sport;
+		laddr.v4.sin_addr.s_addr = req->id.idiag_src[0];
+		laddr.v4.sin_family = AF_INET;
+
+		paddr.v4.sin_port = req->id.idiag_dport;
+		paddr.v4.sin_addr.s_addr = req->id.idiag_dst[0];
+		paddr.v4.sin_family = AF_INET;
+	} else {
+		laddr.v6.sin6_port = req->id.idiag_sport;
+		memcpy(&laddr.v6.sin6_addr, req->id.idiag_src, 64);
+		laddr.v6.sin6_family = AF_INET6;
+
+		paddr.v6.sin6_port = req->id.idiag_dport;
+		memcpy(&paddr.v6.sin6_addr, req->id.idiag_dst, 64);
+		paddr.v6.sin6_family = AF_INET6;
+	}
+
+	return sctp_transport_lookup_process(sctp_tsp_dump_one,
+					     net, &laddr, &paddr, &commp);
+}
+
+static void sctp_diag_dump(struct sk_buff *skb, struct netlink_callback *cb,
+			   const struct inet_diag_req_v2 *r, struct nlattr *bc)
+{
+	u32 idiag_states = r->idiag_states;
+	struct net *net = sock_net(skb->sk);
+	struct sctp_comm_param commp = {
+		.skb = skb,
+		.cb = cb,
+		.r = r,
+	};
+
+	/* eps hashtable dumps
+	 * args:
+	 * 0 : if it will traversal listen sock
+	 * 1 : to record the sock pos of this time's traversal
+	 * 4 : to work as a temporary variable to traversal list
+	 */
+	if (cb->args[0] == 0) {
+		if (!(idiag_states & TCPF_LISTEN))
+			goto skip;
+		if (sctp_for_each_endpoint(sctp_ep_dump, &commp))
+			goto done;
+skip:
+		cb->args[0] = 1;
+		cb->args[1] = 0;
+		cb->args[4] = 0;
+	}
+
+	/* asocs by transport hashtable dump
+	 * args:
+	 * 1 : to record the assoc pos of this time's traversal
+	 * 2 : to record the transport pos of this time's traversal
+	 * 3 : to mark if we have dumped the ep info of the current asoc
+	 * 4 : to work as a temporary variable to traversal list
+	 */
+	if (!(idiag_states & ~TCPF_LISTEN))
+		goto done;
+	sctp_for_each_transport(sctp_tsp_dump, net, cb->args[2], &commp);
+done:
+	cb->args[1] = cb->args[4];
+	cb->args[4] = 0;
+}
+
+static const struct inet_diag_handler sctp_diag_handler = {
+	.dump		 = sctp_diag_dump,
+	.dump_one	 = sctp_diag_dump_one,
+	.idiag_get_info  = sctp_diag_get_info,
+	.idiag_type	 = IPPROTO_SCTP,
+	.idiag_info_size = sizeof(struct sctp_info),
+};
+
+static int __init sctp_diag_init(void)
+{
+	return inet_diag_register(&sctp_diag_handler);
+}
+
+static void __exit sctp_diag_exit(void)
+{
+	inet_diag_unregister(&sctp_diag_handler);
+}
+
+module_init(sctp_diag_init);
+module_exit(sctp_diag_exit);
+MODULE_LICENSE("GPL");
+MODULE_ALIAS_NET_PF_PROTO_TYPE(PF_NETLINK, NETLINK_SOCK_DIAG, 2-132);
-- 
2.1.0
