From: Ranjit Manomohan <ranjitm@google.com>
Subject: [PATCH] Traffic control cgroups subsystem
Date: Mon, 21 Jul 2008 21:08:02 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0807212100580.1760@ranjit.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: lizf@cn.fujitsu.com, kaber@trash.net, menage@google.com
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:37040 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750707AbYGVEIQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2008 00:08:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


[Take 2] - Incorporated comments from Patric McHardy & Li Zefan.

This patch provides a simple resource controller (cgroup_tc) based on the
cgroups infrastructure to manage network traffic. The cgroup_tc resource
controller can be used to schedule and shape traffic belonging to the task(s)
in a particular cgroup.

The implementation consists of two parts:

1) A resource controller (cgroup_tc) that is used to associate packets from
    a particular task belonging to a cgroup with a traffic control class id (
    tc_classid). This tc_classid is propagated to all sockets created by tasks
    in the cgroup and from there to all packets associated with those sockets.

2) A modified traffic control classifier (cls_flow) that can classify packets
    based on the tc_classid field in the packet to specific destination classes.

An example of the use of this resource controller would be to limit
the traffic from all tasks from a file_server cgroup to 100Mbps. We could
achieve this by doing:

# make a cgroup of file transfer processes and assign it a uniqe classid
# of 0x10 - this will be used lated to direct packets.
mkdir -p /dev/cgroup
mount -t cgroup tc -otc /dev/cgroup
mkdir /dev/cgroup/file_transfer
echo 0x10 > /dev/cgroup/file_transfer/tc.classid
echo $PID_OF_FILE_XFER_PROCESS > /dev/cgroup/file_transfer/tasks

# Now create a HTB class that rate limits traffic to 100mbits and attach
# a filter to direct all traffic from cgroup file_transfer to this new class.
tc qdisc add dev eth0 root handle 1: htb
tc class add dev eth0 parent 1: classid 1:10 htb rate 100mbit ceil 100mbit
tc filter add dev eth0 parent 1: handle 800 protocol ip prio 1 flow map key cgroup-classid baseclass 1:10

Signed-off-by: Ranjit Manomohan <ranjitm@google.com>

---
diff --git a/include/linux/cgroup_subsys.h b/include/linux/cgroup_subsys.h
index e287745..4b12372 100644
--- a/include/linux/cgroup_subsys.h
+++ b/include/linux/cgroup_subsys.h
@@ -48,3 +48,9 @@ SUBSYS(devices)
  #endif

  /* */
+
+#ifdef CONFIG_CGROUP_TC
+SUBSYS(tc)
+#endif
+
+/* */
diff --git a/include/linux/cgroup_tc.h b/include/linux/cgroup_tc.h
new file mode 100644
index 0000000..decef81
--- /dev/null
+++ b/include/linux/cgroup_tc.h
@@ -0,0 +1,25 @@
+#ifndef __LINUX_CGROUP_TC_H
+#define __LINUX_CGROUP_TC_H
+
+/* Interface to obtain tasks cgroup identifier. */
+
+#include <linux/cgroup.h>
+#include <linux/skbuff.h>
+#include <net/sock.h>
+
+#ifdef CONFIG_CGROUP_TC
+
+void cgroup_tc_set_sock_classid(struct sock *sk);
+
+#define cgroup_tc_set_skb_classid(sk, skb) \
+	skb->cgroup_classid = sk->sk_cgroup_classid
+
+#else
+
+#define cgroup_tc_set_sock_classid(sk)
+
+#define cgroup_tc_set_skb_classid(sk, skb)
+
+#endif /* CONFIG_CGROUP_TC */
+
+#endif /* __LINUX_CGROUP_TC_H */
diff --git a/include/linux/pkt_cls.h b/include/linux/pkt_cls.h
index 99efbed..deead80 100644
--- a/include/linux/pkt_cls.h
+++ b/include/linux/pkt_cls.h
@@ -349,6 +349,7 @@ enum
  	FLOW_KEY_SKUID,
  	FLOW_KEY_SKGID,
  	FLOW_KEY_VLAN_TAG,
+	FLOW_KEY_CGROUP_CLASSID,
  	__FLOW_KEY_MAX,
  };

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 299ec4b..e124294 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -326,6 +326,10 @@ struct sk_buff {
  	__u32			secmark;
  #endif

+#ifdef CONFIG_CGROUP_TC
+	__u32			cgroup_classid;
+#endif
+
  	__u32			mark;

  	sk_buff_data_t		transport_header;
diff --git a/include/net/sock.h b/include/net/sock.h
index dc42b44..7a4e09c 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -271,6 +271,9 @@ struct sock {
  	int			sk_write_pending;
  	void			*sk_security;
  	__u32			sk_mark;
+#ifdef CONFIG_CGROUP_TC
+	__u32			sk_cgroup_classid;
+#endif
  	/* XXX 4 bytes hole on 64 bit */
  	void			(*sk_state_change)(struct sock *sk);
  	void			(*sk_data_ready)(struct sock *sk, int bytes);
diff --git a/init/Kconfig b/init/Kconfig
index 6135d07..c28fde8 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -289,6 +289,17 @@ config CGROUP_DEBUG

  	  Say N if unsure

+config CGROUP_TC
+	bool "Traffic control cgroup subsystem"
+	depends on CGROUPS
+	default n
+	help
+	  This option enables a simple cgroup subsystem that
+	  allows network traffic to be classified based on the
+	  cgroup of the task originating the traffic.
+
+	  Say N if unsure
+
  config CGROUP_NS
          bool "Namespace cgroup subsystem"
          depends on CGROUPS
diff --git a/kernel/Makefile b/kernel/Makefile
index 1c9938a..08b217b 100644
--- a/kernel/Makefile
+++ b/kernel/Makefile
@@ -42,6 +42,7 @@ obj-$(CONFIG_CGROUPS) += cgroup.o
  obj-$(CONFIG_CGROUP_DEBUG) += cgroup_debug.o
  obj-$(CONFIG_CPUSETS) += cpuset.o
  obj-$(CONFIG_CGROUP_NS) += ns_cgroup.o
+obj-$(CONFIG_CGROUP_TC) += tc_cgroup.o
  obj-$(CONFIG_UTS_NS) += utsname.o
  obj-$(CONFIG_USER_NS) += user_namespace.o
  obj-$(CONFIG_PID_NS) += pid_namespace.o
diff --git a/kernel/tc_cgroup.c b/kernel/tc_cgroup.c
new file mode 100644
index 0000000..1c62a6c
--- /dev/null
+++ b/kernel/tc_cgroup.c
@@ -0,0 +1,108 @@
+/*
+ * tc_cgroup.c - traffic control cgroup subsystem
+ *
+ */
+
+#include <linux/module.h>
+#include <linux/cgroup.h>
+#include <linux/fs.h>
+#include <linux/slab.h>
+#include <linux/cgroup_tc.h>
+
+struct tc_cgroup {
+	struct cgroup_subsys_state css;
+	unsigned int classid;
+};
+
+struct cgroup_subsys tc_subsys;
+
+static inline struct tc_cgroup *cgroup_to_tc(
+		struct cgroup *cgroup)
+{
+	return container_of(cgroup_subsys_state(cgroup, tc_subsys_id),
+			    struct tc_cgroup, css);
+}
+
+static int cgroup_tc_classid(struct task_struct *tsk)
+{
+	int tc_classid;
+
+	rcu_read_lock();
+	tc_classid =  container_of(task_subsys_state(tsk, tc_subsys_id),
+					 struct tc_cgroup, css)->classid;
+	rcu_read_unlock();
+	return tc_classid;
+}
+
+void cgroup_tc_set_sock_classid(struct sock *sk)
+{
+	if (sk)
+		sk->sk_cgroup_classid = cgroup_tc_classid(current);
+}
+
+static struct cgroup_subsys_state *tc_create(struct cgroup_subsys *ss,
+						struct cgroup *cgroup)
+{
+	struct tc_cgroup *tc_cgroup;
+
+	tc_cgroup = kzalloc(sizeof(*tc_cgroup), GFP_KERNEL);
+
+	if (!tc_cgroup)
+		return ERR_PTR(-ENOMEM);
+
+	/* Copy parent's class id if present */
+	if (cgroup->parent)
+		tc_cgroup->classid = cgroup_to_tc(cgroup->parent)->classid;
+
+	return &tc_cgroup->css;
+}
+
+static void tc_destroy(struct cgroup_subsys *ss,
+			struct cgroup *cgroup)
+{
+	kfree(cgroup_to_tc(cgroup));
+}
+
+static int tc_write_u64(struct cgroup *cgrp, struct cftype *cft, u64 val)
+{
+	struct tc_cgroup *tc = cgroup_to_tc(cgrp);
+
+	cgroup_lock();
+	if (cgroup_is_removed(cgrp)) {
+		cgroup_unlock();
+		return -ENODEV;
+	}
+
+	tc->classid = (unsigned int) (val & 0xffffffff);
+	cgroup_unlock();
+	return 0;
+}
+
+static u64 tc_read_u64(struct cgroup *cont, struct cftype *cft)
+{
+	struct tc_cgroup *tc = cgroup_to_tc(cont);
+	return tc->classid;
+}
+
+static struct cftype tc_files[] = {
+	{
+		.name = "classid",
+		.read_u64 = tc_read_u64,
+		.write_u64 = tc_write_u64,
+	}
+};
+
+static int tc_populate(struct cgroup_subsys *ss, struct cgroup *cont)
+{
+	int err;
+	err = cgroup_add_files(cont, ss, tc_files, ARRAY_SIZE(tc_files));
+	return err;
+}
+
+struct cgroup_subsys tc_subsys = {
+	.name = "tc",
+	.create = tc_create,
+	.destroy  = tc_destroy,
+	.populate = tc_populate,
+	.subsys_id = tc_subsys_id,
+};
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index e527628..ff75d8e 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -81,6 +81,7 @@
  #include <linux/mroute.h>
  #include <linux/netlink.h>
  #include <linux/tcp.h>
+#include <linux/cgroup_tc.h>

  int sysctl_ip_default_ttl __read_mostly = IPDEFTTL;

@@ -168,6 +169,9 @@ int ip_build_and_send_pkt(struct sk_buff *skb, struct sock *sk,
  	}

  	skb->priority = sk->sk_priority;
+
+	cgroup_tc_set_skb_classid(sk, skb);
+
  	skb->mark = sk->sk_mark;

  	/* Send it out. */
@@ -386,6 +390,9 @@ packet_routed:
  			     (skb_shinfo(skb)->gso_segs ?: 1) - 1);

  	skb->priority = sk->sk_priority;
+
+	cgroup_tc_set_skb_classid(sk, skb);
+
  	skb->mark = sk->sk_mark;

  	return ip_local_out(skb);
@@ -1278,6 +1285,7 @@ int ip_push_pending_frames(struct sock *sk)
  	iph->daddr = rt->rt_dst;

  	skb->priority = sk->sk_priority;
+	cgroup_tc_set_skb_classid(sk, skb);
  	skb->mark = sk->sk_mark;
  	skb->dst = dst_clone(&rt->u.dst);

@@ -1387,6 +1395,7 @@ void ip_send_reply(struct sock *sk, struct sk_buff *skb, struct ip_reply_arg *ar
  	bh_lock_sock(sk);
  	inet->tos = ip_hdr(skb)->tos;
  	sk->sk_priority = skb->priority;
+	cgroup_tc_set_skb_classid(sk, skb);
  	sk->sk_protocol = ip_hdr(skb)->protocol;
  	sk->sk_bound_dev_if = arg->bound_dev_if;
  	ip_append_data(sk, ip_reply_glue_bits, arg->iov->iov_base, len, 0,
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 48cdce9..826b770 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -56,6 +56,7 @@
  #include <net/xfrm.h>
  #include <net/checksum.h>
  #include <linux/mroute6.h>
+#include <linux/cgroup_tc.h>

  static int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *));

@@ -257,6 +258,8 @@ int ip6_xmit(struct sock *sk, struct sk_buff *skb, struct flowi *fl,
  	ipv6_addr_copy(&hdr->daddr, first_hop);

  	skb->priority = sk->sk_priority;
+	cgroup_tc_set_skb_classid(sk, skb);
+
  	skb->mark = sk->sk_mark;

  	mtu = dst_mtu(dst);
@@ -1448,6 +1451,7 @@ int ip6_push_pending_frames(struct sock *sk)
  	ipv6_addr_copy(&hdr->daddr, final_dst);

  	skb->priority = sk->sk_priority;
+	cgroup_tc_set_skb_classid(sk, skb);
  	skb->mark = sk->sk_mark;

  	skb->dst = dst_clone(&rt->u.dst);
diff --git a/net/sched/Makefile b/net/sched/Makefile
index 1d2b0f7..91e9ee0 100644
--- a/net/sched/Makefile
+++ b/net/sched/Makefile
@@ -36,6 +36,7 @@ obj-$(CONFIG_NET_CLS_TCINDEX)	+= cls_tcindex.o
  obj-$(CONFIG_NET_CLS_RSVP6)	+= cls_rsvp6.o
  obj-$(CONFIG_NET_CLS_BASIC)	+= cls_basic.o
  obj-$(CONFIG_NET_CLS_FLOW)	+= cls_flow.o
+obj-$(CONFIG_NET_CLS_CGROUP)	+= cls_cgroup.o
  obj-$(CONFIG_NET_EMATCH)	+= ematch.o
  obj-$(CONFIG_NET_EMATCH_CMP)	+= em_cmp.o
  obj-$(CONFIG_NET_EMATCH_NBYTE)	+= em_nbyte.o
diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index 971b867..2a63ffc 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -280,6 +280,14 @@ static u32 flow_get_vlan_tag(const struct sk_buff *skb)
  	return tag & VLAN_VID_MASK;
  }

+static u32 flow_get_cgroup_classid(const struct sk_buff *skb)
+{
+#ifdef CONFIG_CGROUP_TC
+	return skb->cgroup_classid;
+#endif
+	return 0;
+}
+
  static u32 flow_key_get(const struct sk_buff *skb, int key)
  {
  	switch (key) {
@@ -317,6 +325,8 @@ static u32 flow_key_get(const struct sk_buff *skb, int key)
  		return flow_get_skgid(skb);
  	case FLOW_KEY_VLAN_TAG:
  		return flow_get_vlan_tag(skb);
+	case FLOW_KEY_CGROUP_CLASSID:
+		return flow_get_cgroup_classid(skb);
  	default:
  		WARN_ON(1);
  		return 0;
@@ -359,7 +369,12 @@ static int flow_classify(struct sk_buff *skb, struct tcf_proto *tp,
  			classid %= f->divisor;

  		res->class   = 0;
-		res->classid = TC_H_MAKE(f->baseclass, f->baseclass + classid);
+
+		if (key == FLOW_KEY_CGROUP_CLASSID)
+			res->classid = TC_H_MAKE(f->baseclass, classid);
+		else
+			res->classid = TC_H_MAKE(f->baseclass,
+						 f->baseclass + classid);

  		r = tcf_exts_exec(skb, &f->exts, res);
  		if (r < 0)
diff --git a/net/socket.c b/net/socket.c
index 66c4a8c..b7421ec 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -93,6 +93,7 @@

  #include <net/sock.h>
  #include <linux/netfilter.h>
+#include <linux/cgroup_tc.h>

  static int sock_no_open(struct inode *irrelevant, struct file *dontcare);
  static ssize_t sock_aio_read(struct kiocb *iocb, const struct iovec *iov,
@@ -1170,6 +1171,8 @@ static int __sock_create(struct net *net, int family, int type, int protocol,
  	if (err < 0)
  		goto out_module_put;

+	cgroup_tc_set_sock_classid(sock->sk);
+
  	/*
  	 * Now to bump the refcnt of the [loadable] module that owns this
  	 * socket at sock_release time we decrement its refcnt.
@@ -1444,6 +1447,8 @@ asmlinkage long sys_accept(int fd, struct sockaddr __user *upeer_sockaddr,
  	if (err < 0)
  		goto out_fd;

+	cgroup_tc_set_sock_classid(newsock->sk);
+
  	if (upeer_sockaddr) {
  		if (newsock->ops->getname(newsock, (struct sockaddr *)address,
  					  &len, 2) < 0) {
