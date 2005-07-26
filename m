From: Harald Welte <laforge@gnumonks.org>
Subject: [PATCH] add new nfnetlink_queue subsystem
Date: Tue, 26 Jul 2005 23:58:02 +0200
Message-ID: <20050726215802.GA4673@rama.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ghzN8eJ9Qlbqn3iT"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org


--ghzN8eJ9Qlbqn3iT
Content-Type: multipart/mixed; boundary="oC1+HKm2/end4ao3"
Content-Disposition: inline


--oC1+HKm2/end4ao3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave!

This is the layer3 independent rewrite of ip[6]_queue on top of
nfnetlink.  The patch is incremental to my latest 'move queue rerouting
to nf_queue level' and 'multiqueue' patches I sent earlier today.

Please apply to net-2.6.14,

Thanks.

--=20
- Harald Welte <laforge@gnumonks.org>          	        http://gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)

--oC1+HKm2/end4ao3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="13-nfnetlink_queue.patch"
Content-Transfer-Encoding: quoted-printable

Add "nfnetlink_queue" netfilter queue handler over nfnetlink:
- Add new nfnetlink_queue module
- Add new ipt_NFQUEUE and ip6t_NFQUEUE modules to access queue numbers 1-65=
535
- Mark ip_queue and ip6_queue Kconfig options as OBSOLETE
- Update feature-removal-schedule to remove ip[6]_queue in December

Signed-off-by: Harald Welte <laforge@netfilter.org>

---
commit 7237f235b6bd25773b566d88ec846245c852b1ee
tree d8bf4d0e82e9f0bdd570d1678f162f6c59d2d361
parent 4557bbef246922e030176404bcf5aa05f9a81d21
author laforge <laforge@netfilter.org> Di, 26 Jul 2005 23:52:26 +0200
committer laforge <laforge@netfilter.org> Di, 26 Jul 2005 23:52:26 +0200

 Documentation/feature-removal-schedule.txt |   12=20
 include/linux/netfilter/nfnetlink_queue.h  |   85 +++
 include/linux/netfilter_ipv4/ipt_NFQUEUE.h |   16 +
 net/ipv4/netfilter/Kconfig                 |    6=20
 net/ipv4/netfilter/Makefile                |    1=20
 net/ipv4/netfilter/ipt_NFQUEUE.c           |   70 ++
 net/ipv6/netfilter/Kconfig                 |   11=20
 net/ipv6/netfilter/Makefile                |    1=20
 net/ipv6/netfilter/ip6t_NFQUEUE.c          |   70 ++
 net/netfilter/Kconfig                      |    8=20
 net/netfilter/Makefile                     |    1=20
 net/netfilter/nfnetlink_queue.c            |  877 ++++++++++++++++++++++++=
++++
 12 files changed, 1153 insertions(+), 5 deletions(-)

diff --git a/Documentation/feature-removal-schedule.txt b/Documentation/fea=
ture-removal-schedule.txt
--- a/Documentation/feature-removal-schedule.txt
+++ b/Documentation/feature-removal-schedule.txt
@@ -135,3 +135,15 @@ Why:	With the 16-bit PCMCIA subsystem no
 	pcmciautils package available at
 	http://kernel.org/pub/linux/utils/kernel/pcmcia/
 Who:	Dominik Brodowski <linux@brodo.de>
+
+---------------------------
+
+What:	ip_queue and ip6_queue (old ipv4-only and ipv6-only netfilter queue)
+When:	December 2005
+Why:	This interface has been obsoleted by the new layer3-independent
+	"nfnetlink_queue".  The Kernel interface is compatible, so the old
+	ip[6]tables "QUEUE" targets still work and will transparently handle
+	all packets into nfnetlink queue number 0.  Userspace users will have
+	to link against API-compatible library on top of libnfnetlink_queue=20
+	instead of the current 'libipq'.
+Who:	Harald Welte <laforge@netfilter.org>
diff --git a/include/linux/netfilter/nfnetlink_queue.h b/include/linux/netf=
ilter/nfnetlink_queue.h
new file mode 100644
--- /dev/null
+++ b/include/linux/netfilter/nfnetlink_queue.h
@@ -0,0 +1,85 @@
+#ifndef _NFNETLINK_QUEUE_H
+#define _NFNETLINK_QUEUE_H
+
+#include <linux/netfilter/nfnetlink.h>
+
+enum nfqnl_msg_types {
+	NFQNL_MSG_PACKET,		/* packet from kernel to userspace */
+	NFQNL_MSG_VERDICT,		/* verdict from userspace to kernel */
+	NFQNL_MSG_CONFIG,		/* connect to a particular queue */
+
+	NFQNL_MSG_MAX
+};
+
+struct nfqnl_msg_packet_hdr {
+	u_int32_t	packet_id;	/* unique ID of packet in queue */
+	u_int16_t	hw_protocol;	/* hw protocol (network order) */
+	u_int8_t	hook;		/* netfilter hook */
+} __attribute__ ((packed));
+
+struct nfqnl_msg_packet_hw {
+	u_int16_t	hw_addrlen;
+	u_int16_t	_pad;
+	u_int8_t	hw_addr[8];
+} __attribute__ ((packed));
+
+struct nfqnl_msg_packet_timestamp {
+	u_int64_t	sec;
+	u_int64_t	usec;
+} __attribute__ ((packed));
+
+enum nfqnl_attr_type {
+	NFQA_UNSPEC,
+	NFQA_PACKET_HDR,
+	NFQA_VERDICT_HDR,		/* nfqnl_msg_verdict_hrd */
+	NFQA_MARK,			/* u_int32_t nfmark */
+	NFQA_TIMESTAMP,			/* nfqnl_msg_packet_timestamp */
+	NFQA_IFINDEX_INDEV,		/* u_int32_t ifindex */
+	NFQA_IFINDEX_OUTDEV,		/* u_int32_t ifindex */
+	NFQA_HWADDR,			/* nfqnl_msg_packet_hw */
+	NFQA_PAYLOAD,			/* opaque data payload */
+
+	__NFQA_MAX
+};
+#define NFQA_MAX (__NFQA_MAX - 1)
+
+struct nfqnl_msg_verdict_hdr {
+	u_int32_t verdict;
+	u_int32_t id;
+} __attribute__ ((packed));
+
+
+enum nfqnl_msg_config_cmds {
+	NFQNL_CFG_CMD_NONE,
+	NFQNL_CFG_CMD_BIND,
+	NFQNL_CFG_CMD_UNBIND,
+	NFQNL_CFG_CMD_PF_BIND,
+	NFQNL_CFG_CMD_PF_UNBIND,
+};
+
+struct nfqnl_msg_config_cmd {
+	u_int8_t	command;	/* nfqnl_msg_config_cmds */
+	u_int8_t	_pad;
+	u_int16_t	pf;		/* AF_xxx for PF_[UN]BIND */
+} __attribute__ ((packed));
+
+enum nfqnl_config_mode {
+	NFQNL_COPY_NONE,
+	NFQNL_COPY_META,
+	NFQNL_COPY_PACKET,
+};
+
+struct nfqnl_msg_config_params {
+	u_int32_t	copy_range;
+	u_int8_t	copy_mode;	/* enum nfqnl_config_mode */
+} __attribute__ ((packed));
+
+
+enum nfqnl_attr_config {
+	NFQA_CFG_UNSPEC,
+	NFQA_CFG_CMD,			/* nfqnl_msg_config_cmd */
+	NFQA_CFG_PARAMS,		/* nfqnl_msg_config_params */
+	__NFQA_CFG_MAX
+};
+
+#endif /* _NFNETLINK_QUEUE_H */
diff --git a/include/linux/netfilter_ipv4/ipt_NFQUEUE.h b/include/linux/net=
filter_ipv4/ipt_NFQUEUE.h
new file mode 100644
--- /dev/null
+++ b/include/linux/netfilter_ipv4/ipt_NFQUEUE.h
@@ -0,0 +1,16 @@
+/* iptables module for using NFQUEUE mechanism
+ *
+ * (C) 2005 Harald Welte <laforge@netfilter.org>
+ *
+ * This software is distributed under GNU GPL v2, 1991
+ *=20
+*/
+#ifndef _IPT_NFQ_TARGET_H
+#define _IPT_NFQ_TARGET_H
+
+/* target info */
+struct ipt_NFQ_info {
+	u_int16_t queuenum;
+};
+
+#endif /* _IPT_DSCP_TARGET_H */
diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
--- a/net/ipv4/netfilter/Kconfig
+++ b/net/ipv4/netfilter/Kconfig
@@ -110,11 +110,15 @@ config IP_NF_AMANDA
 	  To compile it as a module, choose M here.  If unsure, say Y.
=20
 config IP_NF_QUEUE
-	tristate "Userspace queueing via NETLINK"
+	tristate "IP Userspace queueing via NETLINK (OBSOLETE)"
 	help
 	  Netfilter has the ability to queue packets to user space: the
 	  netlink device can be used to access them using this driver.
=20
+	  This option enables the old IPv4-only "ip_queue" implementation
+	  which has been obsoleted by the new "nfnetlink_queue" code (see
+	  CONFIG_NETFILTER_NETLINK_QUEUE).
+
 	  To compile it as a module, choose M here.  If unsure, say N.
=20
 config IP_NF_IPTABLES
diff --git a/net/ipv4/netfilter/Makefile b/net/ipv4/netfilter/Makefile
--- a/net/ipv4/netfilter/Makefile
+++ b/net/ipv4/netfilter/Makefile
@@ -91,3 +91,4 @@ obj-$(CONFIG_IP_NF_ARP_MANGLE) +=3D arpt_m
 obj-$(CONFIG_IP_NF_ARPFILTER) +=3D arptable_filter.o
=20
 obj-$(CONFIG_IP_NF_QUEUE) +=3D ip_queue.o
+obj-$(CONFIG_NETFILTER_NETLINK_QUEUE) +=3D ipt_NFQUEUE.o
diff --git a/net/ipv4/netfilter/ipt_NFQUEUE.c b/net/ipv4/netfilter/ipt_NFQU=
EUE.c
new file mode 100644
--- /dev/null
+++ b/net/ipv4/netfilter/ipt_NFQUEUE.c
@@ -0,0 +1,70 @@
+/* iptables module for using new netfilter netlink queue
+ *
+ * (C) 2005 by Harald Welte <laforge@netfilter.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as=20
+ * published by the Free Software Foundation.
+ *=20
+ */
+
+#include <linux/module.h>
+#include <linux/skbuff.h>
+
+#include <linux/netfilter.h>
+#include <linux/netfilter_ipv4/ip_tables.h>
+#include <linux/netfilter_ipv4/ipt_NFQUEUE.h>
+
+MODULE_AUTHOR("Harald Welte <laforge@netfilter.org>");
+MODULE_DESCRIPTION("iptables NFQUEUE target");
+MODULE_LICENSE("GPL");
+
+static unsigned int
+target(struct sk_buff **pskb,
+       const struct net_device *in,
+       const struct net_device *out,
+       unsigned int hooknum,
+       const void *targinfo,
+       void *userinfo)
+{
+	const struct ipt_NFQ_info *tinfo =3D targinfo;
+
+	return NF_QUEUE_NR(tinfo->queuenum);
+}
+
+static int
+checkentry(const char *tablename,
+	   const struct ipt_entry *e,
+           void *targinfo,
+           unsigned int targinfosize,
+           unsigned int hook_mask)
+{
+	if (targinfosize !=3D IPT_ALIGN(sizeof(struct ipt_NFQ_info))) {
+		printk(KERN_WARNING "NFQUEUE: targinfosize %u !=3D %Zu\n",
+		       targinfosize,
+		       IPT_ALIGN(sizeof(struct ipt_NFQ_info)));
+		return 0;
+	}
+
+	return 1;
+}
+
+static struct ipt_target ipt_NFQ_reg =3D {
+	.name		=3D "NFQUEUE",
+	.target		=3D target,
+	.checkentry	=3D checkentry,
+	.me		=3D THIS_MODULE,
+};
+
+static int __init init(void)
+{
+	return ipt_register_target(&ipt_NFQ_reg);
+}
+
+static void __exit fini(void)
+{
+	ipt_unregister_target(&ipt_NFQ_reg);
+}
+
+module_init(init);
+module_exit(fini);
diff --git a/net/ipv6/netfilter/Kconfig b/net/ipv6/netfilter/Kconfig
--- a/net/ipv6/netfilter/Kconfig
+++ b/net/ipv6/netfilter/Kconfig
@@ -10,13 +10,16 @@ menu "IPv6: Netfilter Configuration (EXP
 #  dep_tristate '  FTP protocol support' CONFIG_IP6_NF_FTP $CONFIG_IP6_NF_=
CONNTRACK
 #fi
 config IP6_NF_QUEUE
-	tristate "Userspace queueing via NETLINK"
+	tristate "IP6 Userspace queueing via NETLINK (OBSOLETE)"
 	---help---
=20
 	  This option adds a queue handler to the kernel for IPv6
-	  packets which lets us to receive the filtered packets
-	  with QUEUE target using libiptc as we can do with
-	  the IPv4 now.
+	  packets which enables users to receive the filtered packets
+	  with QUEUE target using libipq.
+
+	  THis option enables the old IPv6-only "ip6_queue" implementation
+	  which has been obsoleted by the new "nfnetlink_queue" code (see
+	  CONFIG_NETFILTER_NETLINK_QUEUE).
=20
 	  (C) Fernando Anton 2001
 	  IPv64 Project - Work based in IPv64 draft by Arturo Azcorra.
diff --git a/net/ipv6/netfilter/Makefile b/net/ipv6/netfilter/Makefile
--- a/net/ipv6/netfilter/Makefile
+++ b/net/ipv6/netfilter/Makefile
@@ -24,3 +24,4 @@ obj-$(CONFIG_IP6_NF_QUEUE) +=3D ip6_queue.
 obj-$(CONFIG_IP6_NF_TARGET_LOG) +=3D ip6t_LOG.o
 obj-$(CONFIG_IP6_NF_RAW) +=3D ip6table_raw.o
 obj-$(CONFIG_IP6_NF_MATCH_HL) +=3D ip6t_hl.o
+obj-$(CONFIG_NETFILTER_NETLINK_QUEUE) +=3D ip6t_NFQUEUE.o
diff --git a/net/ipv6/netfilter/ip6t_NFQUEUE.c b/net/ipv6/netfilter/ip6t_NF=
QUEUE.c
new file mode 100644
--- /dev/null
+++ b/net/ipv6/netfilter/ip6t_NFQUEUE.c
@@ -0,0 +1,70 @@
+/* ip6tables module for using new netfilter netlink queue
+ *
+ * (C) 2005 by Harald Welte <laforge@netfilter.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as=20
+ * published by the Free Software Foundation.
+ *=20
+ */
+
+#include <linux/module.h>
+#include <linux/skbuff.h>
+
+#include <linux/netfilter.h>
+#include <linux/netfilter_ipv6/ip6_tables.h>
+#include <linux/netfilter_ipv4/ipt_NFQUEUE.h>
+
+MODULE_AUTHOR("Harald Welte <laforge@netfilter.org>");
+MODULE_DESCRIPTION("ip6tables NFQUEUE target");
+MODULE_LICENSE("GPL");
+
+static unsigned int
+target(struct sk_buff **pskb,
+       const struct net_device *in,
+       const struct net_device *out,
+       unsigned int hooknum,
+       const void *targinfo,
+       void *userinfo)
+{
+	const struct ipt_NFQ_info *tinfo =3D targinfo;
+
+	return NF_QUEUE_NR(tinfo->queuenum);
+}
+
+static int
+checkentry(const char *tablename,
+	   const struct ip6t_entry *e,
+           void *targinfo,
+           unsigned int targinfosize,
+           unsigned int hook_mask)
+{
+	if (targinfosize !=3D IP6T_ALIGN(sizeof(struct ipt_NFQ_info))) {
+		printk(KERN_WARNING "NFQUEUE: targinfosize %u !=3D %Zu\n",
+		       targinfosize,
+		       IP6T_ALIGN(sizeof(struct ipt_NFQ_info)));
+		return 0;
+	}
+
+	return 1;
+}
+
+static struct ip6t_target ipt_NFQ_reg =3D {
+	.name		=3D "NFQUEUE",
+	.target		=3D target,
+	.checkentry	=3D checkentry,
+	.me		=3D THIS_MODULE,
+};
+
+static int __init init(void)
+{
+	return ip6t_register_target(&ipt_NFQ_reg);
+}
+
+static void __exit fini(void)
+{
+	ip6t_unregister_target(&ipt_NFQ_reg);
+}
+
+module_init(init);
+module_exit(fini);
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -3,3 +3,11 @@ config NETFILTER_NETLINK
        help
          If this option is enabled, the kernel will include support
          for the new netfilter netlink interface.
+
+config NETFILTER_NETLINK_QUEUE
+	tristate "Netfilter NFQUEUE over NFNETLINK interface"
+	depends on NETFILTER_NETLINK
+	help
+	  If this option isenabled, the kernel will include support
+	  for queueing packets via NFNETLINK.
+	 =20
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -1 +1,2 @@
 obj-$(CONFIG_NETFILTER_NETLINK) +=3D nfnetlink.o
+obj-$(CONFIG_NETFILTER_NETLINK_QUEUE) +=3D nfnetlink_queue.o
diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queu=
e.c
new file mode 100644
--- /dev/null
+++ b/net/netfilter/nfnetlink_queue.c
@@ -0,0 +1,877 @@
+/*
+ * This is a module which is used for queueing packets and communicating w=
ith
+ * userspace via nfetlink.
+ *
+ * (C) 2005 by Harald Welte <laforge@netfilter.org>
+ *
+ * Based on the old ipv4-only ip_queue.c:
+ * (C) 2000-2002 James Morris <jmorris@intercode.com.au>
+ * (C) 2003-2005 Netfilter Core Team <coreteam@netfilter.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ */
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/init.h>
+#include <linux/spinlock.h>
+#include <linux/notifier.h>
+#include <linux/netdevice.h>
+#include <linux/netfilter.h>
+#include <linux/netfilter_ipv4.h>
+#include <linux/netfilter_ipv6.h>
+#include <linux/netfilter/nfnetlink.h>
+#include <linux/netfilter/nfnetlink_queue.h>
+#include <linux/list.h>
+#include <net/sock.h>
+
+#include <asm/atomic.h>
+
+#define NFQNL_QMAX_DEFAULT 1024
+
+#if 0
+#define QDEBUG(x, args ...)	printk(KERN_DEBUG "%s(%d):%s():	" x, 	   \
+					__FILE__, __LINE__, __FUNCTION__,  \
+					## args)
+#else
+#define QDEBUG(x, ...)
+#endif
+
+struct nfqnl_queue_entry {
+	struct list_head list;
+	struct nf_info *info;
+	struct sk_buff *skb;
+	unsigned int id;
+};
+
+struct nfqnl_instance {
+	struct hlist_node hlist;		/* global list of queues */
+
+	int peer_pid;
+	unsigned int queue_maxlen;
+	unsigned int copy_range;
+	unsigned int queue_total;
+	unsigned int queue_dropped;
+	unsigned int queue_user_dropped;
+
+	atomic_t id_sequence;			/* 'sequence' of pkt ids */
+
+	u_int16_t queue_num;			/* number of this queue */
+	u_int8_t copy_mode;
+
+	spinlock_t lock;
+
+	struct list_head queue_list;		/* packets in queue */
+};
+
+typedef int (*nfqnl_cmpfn)(struct nfqnl_queue_entry *, unsigned long);
+
+static DEFINE_RWLOCK(instances_lock);
+
+u_int64_t htonll(u_int64_t in)
+{
+	u_int64_t out;
+	int i;
+
+	for (i =3D 0; i < sizeof(u_int64_t); i++)
+		((u_int8_t *)&out)[sizeof(u_int64_t)-1] =3D ((u_int8_t *)&in)[i];
+
+	return out;
+}
+
+#define INSTANCE_BUCKETS	16
+static struct hlist_head instance_table[INSTANCE_BUCKETS];
+
+static inline u_int8_t instance_hashfn(u_int16_t queue_num)
+{
+	return ((queue_num >> 8) | queue_num) % INSTANCE_BUCKETS;
+}
+
+static struct nfqnl_instance *
+__instance_lookup(u_int16_t queue_num)
+{
+	struct hlist_head *head;
+	struct hlist_node *pos;
+	struct nfqnl_instance *inst;
+
+	head =3D &instance_table[instance_hashfn(queue_num)];
+	hlist_for_each_entry(inst, pos, head, hlist) {
+		if (inst->queue_num =3D=3D queue_num)
+			return inst;
+	}
+	return NULL;
+}
+
+static struct nfqnl_instance *
+instance_lookup(u_int16_t queue_num)
+{
+	struct nfqnl_instance *inst;
+
+	read_lock_bh(&instances_lock);
+	inst =3D __instance_lookup(queue_num);
+	read_unlock_bh(&instances_lock);
+
+	return inst;
+}
+
+static struct nfqnl_instance *
+instance_create(u_int16_t queue_num, int pid)
+{
+	struct nfqnl_instance *inst;
+
+	QDEBUG("entering for queue_num=3D%u, pid=3D%d\n", queue_num, pid);
+
+	write_lock_bh(&instances_lock);=09
+	if (__instance_lookup(queue_num)) {
+		inst =3D NULL;
+		QDEBUG("aborting, instance already exists\n");
+		goto out_unlock;
+	}
+
+	inst =3D kmalloc(sizeof(*inst), GFP_ATOMIC);
+	if (!inst)
+		goto out_unlock;
+
+	memset(inst, 0, sizeof(*inst));
+	inst->queue_num =3D queue_num;
+	inst->peer_pid =3D pid;
+	inst->queue_maxlen =3D NFQNL_QMAX_DEFAULT;
+	inst->copy_range =3D 0xfffff;
+	inst->copy_mode =3D NFQNL_COPY_NONE;
+	atomic_set(&inst->id_sequence, 0);
+	inst->lock =3D SPIN_LOCK_UNLOCKED;
+	INIT_LIST_HEAD(&inst->queue_list);
+
+	if (!try_module_get(THIS_MODULE))
+		goto out_free;
+
+	hlist_add_head(&inst->hlist,=20
+		       &instance_table[instance_hashfn(queue_num)]);
+
+	write_unlock_bh(&instances_lock);
+
+	QDEBUG("successfully created new instance\n");
+
+	return inst;
+
+out_free:
+	kfree(inst);
+out_unlock:
+	write_unlock_bh(&instances_lock);
+	return NULL;
+}
+
+static void nfqnl_flush(struct nfqnl_instance *queue, int verdict);
+
+static void
+_instance_destroy2(struct nfqnl_instance *inst, int lock)
+{
+	/* first pull it out of the global list */
+	if (lock)
+		write_lock_bh(&instances_lock);
+
+	QDEBUG("removing instance %p (queuenum=3D%u) from hash\n",
+		inst, inst->queue_num);
+	hlist_del(&inst->hlist);
+
+	if (lock)
+		write_unlock_bh(&instances_lock);
+
+	/* then flush all pending skbs from the queue */
+	nfqnl_flush(inst, NF_DROP);
+
+	/* and finally free the data structure */
+	kfree(inst);
+
+	module_put(THIS_MODULE);
+}
+
+static inline void
+__instance_destroy(struct nfqnl_instance *inst)
+{
+	_instance_destroy2(inst, 0);
+}
+
+static inline void
+instance_destroy(struct nfqnl_instance *inst)
+{
+	_instance_destroy2(inst, 1);
+}
+
+
+
+static void
+issue_verdict(struct nfqnl_queue_entry *entry, int verdict)
+{
+	QDEBUG("entering for entry %p, verdict %u\n", entry, verdict);
+
+	/* TCP input path (and probably other bits) assume to be called
+	 * from softirq context, not from syscall, like issue_verdict is
+	 * called.  TCP input path deadlocks with locks taken from timer
+	 * softirq, e.g.  We therefore emulate this by local_bh_disable() */
+
+	local_bh_disable();
+	nf_reinject(entry->skb, entry->info, verdict);
+	local_bh_enable();
+
+	kfree(entry);
+}
+
+static inline void
+__enqueue_entry(struct nfqnl_instance *queue,
+		      struct nfqnl_queue_entry *entry)
+{
+       list_add(&entry->list, &queue->queue_list);
+       queue->queue_total++;
+}
+
+/*
+ * Find and return a queued entry matched by cmpfn, or return the last
+ * entry if cmpfn is NULL.
+ */
+static inline struct nfqnl_queue_entry *
+__find_entry(struct nfqnl_instance *queue, nfqnl_cmpfn cmpfn,=20
+		   unsigned long data)
+{
+	struct list_head *p;
+
+	list_for_each_prev(p, &queue->queue_list) {
+		struct nfqnl_queue_entry *entry =3D (struct nfqnl_queue_entry *)p;
+	=09
+		if (!cmpfn || cmpfn(entry, data))
+			return entry;
+	}
+	return NULL;
+}
+
+static inline void
+__dequeue_entry(struct nfqnl_instance *q, struct nfqnl_queue_entry *entry)
+{
+	list_del(&entry->list);
+	q->queue_total--;
+}
+
+static inline struct nfqnl_queue_entry *
+__find_dequeue_entry(struct nfqnl_instance *queue,
+		     nfqnl_cmpfn cmpfn, unsigned long data)
+{
+	struct nfqnl_queue_entry *entry;
+
+	entry =3D __find_entry(queue, cmpfn, data);
+	if (entry =3D=3D NULL)
+		return NULL;
+
+	__dequeue_entry(queue, entry);
+	return entry;
+}
+
+
+static inline void
+__nfqnl_flush(struct nfqnl_instance *queue, int verdict)
+{
+	struct nfqnl_queue_entry *entry;
+=09
+	while ((entry =3D __find_dequeue_entry(queue, NULL, 0)))
+		issue_verdict(entry, verdict);
+}
+
+static inline int
+__nfqnl_set_mode(struct nfqnl_instance *queue,
+		 unsigned char mode, unsigned int range)
+{
+	int status =3D 0;
+=09
+	switch (mode) {
+	case NFQNL_COPY_NONE:
+	case NFQNL_COPY_META:
+		queue->copy_mode =3D mode;
+		queue->copy_range =3D 0;
+		break;
+	=09
+	case NFQNL_COPY_PACKET:
+		queue->copy_mode =3D mode;
+		/* we're using struct nfattr which has 16bit nfa_len */
+		if (range > 0xffff)
+			queue->copy_range =3D 0xffff;
+		else
+			queue->copy_range =3D range;
+		break;
+	=09
+	default:
+		status =3D -EINVAL;
+
+	}
+	return status;
+}
+
+static struct nfqnl_queue_entry *
+find_dequeue_entry(struct nfqnl_instance *queue,
+			 nfqnl_cmpfn cmpfn, unsigned long data)
+{
+	struct nfqnl_queue_entry *entry;
+=09
+	spin_lock_bh(&queue->lock);
+	entry =3D __find_dequeue_entry(queue, cmpfn, data);
+	spin_unlock_bh(&queue->lock);
+
+	return entry;
+}
+
+static void
+nfqnl_flush(struct nfqnl_instance *queue, int verdict)
+{
+	spin_lock_bh(&queue->lock);
+	__nfqnl_flush(queue, verdict);
+	spin_unlock_bh(&queue->lock);
+}
+
+static struct sk_buff *
+nfqnl_build_packet_message(struct nfqnl_instance *queue,
+			   struct nfqnl_queue_entry *entry, int *errp)
+{
+	unsigned char *old_tail;
+	size_t size;
+	size_t data_len =3D 0;
+	struct sk_buff *skb;
+	struct nfqnl_msg_packet_hdr pmsg;
+	struct nlmsghdr *nlh;
+	struct nfgenmsg *nfmsg;
+	unsigned int tmp_uint;
+
+	QDEBUG("entered\n");
+
+	/* all macros expand to constant values at compile time */
+	size =3D    NLMSG_SPACE(sizeof(struct nfqnl_msg_packet_hdr))
+		+ NLMSG_SPACE(sizeof(u_int32_t))	/* ifindex */
+		+ NLMSG_SPACE(sizeof(u_int32_t))	/* ifindex */
+		+ NLMSG_SPACE(sizeof(u_int32_t))	/* mark */
+		+ NLMSG_SPACE(sizeof(struct nfqnl_msg_packet_hw))
+		+ NLMSG_SPACE(sizeof(struct nfqnl_msg_packet_timestamp));
+
+	spin_lock_bh(&queue->lock);
+=09
+	switch (queue->copy_mode) {
+	case NFQNL_COPY_META:
+	case NFQNL_COPY_NONE:
+		data_len =3D 0;
+		break;
+=09
+	case NFQNL_COPY_PACKET:
+		if (queue->copy_range =3D=3D 0=20
+		    || queue->copy_range > entry->skb->len)
+			data_len =3D entry->skb->len;
+		else
+			data_len =3D queue->copy_range;
+	=09
+		size +=3D NLMSG_SPACE(data_len);
+		break;
+=09
+	default:
+		*errp =3D -EINVAL;
+		spin_unlock_bh(&queue->lock);
+		return NULL;
+	}
+
+	spin_unlock_bh(&queue->lock);
+
+	skb =3D alloc_skb(size, GFP_ATOMIC);
+	if (!skb)
+		goto nlmsg_failure;
+	=09
+	old_tail=3D skb->tail;
+	nlh =3D NLMSG_PUT(skb, 0, 0,=20
+			NFNL_SUBSYS_QUEUE << 8 | NFQNL_MSG_PACKET,
+			sizeof(struct nfgenmsg));
+	nfmsg =3D NLMSG_DATA(nlh);
+	nfmsg->nfgen_family =3D entry->info->pf;
+	nfmsg->version =3D NFNETLINK_V0;
+	nfmsg->res_id =3D htons(queue->queue_num);
+
+	pmsg.packet_id 		=3D htonl(entry->id);
+	pmsg.hw_protocol	=3D htons(entry->skb->protocol);
+	pmsg.hook		=3D entry->info->hook;
+
+	NFA_PUT(skb, NFQA_PACKET_HDR, sizeof(pmsg), &pmsg);
+
+	if (entry->info->indev) {
+		tmp_uint =3D htonl(entry->info->indev->ifindex);
+		NFA_PUT(skb, NFQA_IFINDEX_INDEV, sizeof(tmp_uint), &tmp_uint);
+	}
+
+	if (entry->info->outdev) {
+		tmp_uint =3D htonl(entry->info->outdev->ifindex);
+		NFA_PUT(skb, NFQA_IFINDEX_OUTDEV, sizeof(tmp_uint), &tmp_uint);
+	}
+
+	if (entry->skb->nfmark) {
+		tmp_uint =3D htonl(entry->skb->nfmark);
+		NFA_PUT(skb, NFQA_MARK, sizeof(u_int32_t), &tmp_uint);
+	}
+
+	if (entry->info->indev && entry->skb->dev
+	    && entry->skb->dev->hard_header_parse) {
+		struct nfqnl_msg_packet_hw phw;
+
+		phw.hw_addrlen =3D
+			entry->skb->dev->hard_header_parse(entry->skb,
+			                                   phw.hw_addr);
+		phw.hw_addrlen =3D htons(phw.hw_addrlen);
+		NFA_PUT(skb, NFQA_HWADDR, sizeof(phw), &phw);
+	}
+
+	if (entry->skb->stamp.tv_sec) {
+		struct nfqnl_msg_packet_timestamp ts;
+
+		ts.sec =3D htonll(entry->skb->stamp.tv_sec);
+		ts.usec =3D htonll(entry->skb->stamp.tv_usec);
+
+		NFA_PUT(skb, NFQA_TIMESTAMP, sizeof(ts), &ts);
+	}
+
+	if (data_len) {
+		struct nfattr *nfa;
+		int size =3D NFA_LENGTH(data_len);
+
+		if (skb_tailroom(skb) < (int)NFA_SPACE(data_len)) {
+			printk(KERN_WARNING "nf_queue: no tailroom!\n");
+			goto nlmsg_failure;
+		}
+
+		nfa =3D (struct nfattr *)skb_put(skb, NFA_ALIGN(size));
+		nfa->nfa_type =3D NFQA_PAYLOAD;
+		nfa->nfa_len =3D size;
+
+		if (skb_copy_bits(entry->skb, 0, NFA_DATA(nfa), data_len))
+			BUG();
+	}
+	=09
+	nlh->nlmsg_len =3D skb->tail - old_tail;
+	return skb;
+
+nlmsg_failure:
+nfattr_failure:
+	if (skb)
+		kfree_skb(skb);
+	*errp =3D -EINVAL;
+	if (net_ratelimit())
+		printk(KERN_ERR "nf_queue: error creating packet message\n");
+	return NULL;
+}
+
+static int
+nfqnl_enqueue_packet(struct sk_buff *skb, struct nf_info *info,=20
+		     unsigned int queuenum, void *data)
+{
+	int status =3D -EINVAL;
+	struct sk_buff *nskb;
+	struct nfqnl_instance *queue;
+	struct nfqnl_queue_entry *entry;
+
+	QDEBUG("entered\n");
+
+	queue =3D instance_lookup(queuenum);
+	if (!queue) {
+		QDEBUG("no queue instance matching\n");
+		return -EINVAL;
+	}
+
+	if (queue->copy_mode =3D=3D NFQNL_COPY_NONE) {
+		QDEBUG("mode COPY_NONE, aborting\n");
+		return -EAGAIN;
+	}
+
+	entry =3D kmalloc(sizeof(*entry), GFP_ATOMIC);
+	if (entry =3D=3D NULL) {
+		if (net_ratelimit())
+			printk(KERN_ERR=20
+				"nf_queue: OOM in nfqnl_enqueue_packet()\n");
+		return -ENOMEM;
+	}
+
+	entry->info =3D info;
+	entry->skb =3D skb;
+	entry->id =3D atomic_inc_return(&queue->id_sequence);
+
+	nskb =3D nfqnl_build_packet_message(queue, entry, &status);
+	if (nskb =3D=3D NULL)
+		goto err_out_free;
+	=09
+	spin_lock_bh(&queue->lock);
+=09
+	if (!queue->peer_pid)
+		goto err_out_free_nskb;=20
+
+	if (queue->queue_total >=3D queue->queue_maxlen) {
+                queue->queue_dropped++;
+		status =3D -ENOSPC;
+		if (net_ratelimit())
+		          printk(KERN_WARNING "ip_queue: full at %d entries, "
+				 "dropping packets(s). Dropped: %d\n",=20
+				 queue->queue_total, queue->queue_dropped);
+		goto err_out_free_nskb;
+	}
+
+	/* nfnetlink_unicast will either free the nskb or add it to a socket */
+	status =3D nfnetlink_unicast(nskb, queue->peer_pid, MSG_DONTWAIT);
+	if (status < 0) {
+	        queue->queue_user_dropped++;
+		goto err_out_unlock;
+	}
+
+	__enqueue_entry(queue, entry);
+
+	spin_unlock_bh(&queue->lock);
+	return status;
+
+err_out_free_nskb:
+	kfree_skb(nskb);=20
+=09
+err_out_unlock:
+	spin_unlock_bh(&queue->lock);
+
+err_out_free:
+	kfree(entry);
+	return status;
+}
+
+static int
+nfqnl_mangle(void *data, int data_len, struct nfqnl_queue_entry *e)
+{
+	int diff;
+
+	diff =3D data_len - e->skb->len;
+	if (diff < 0)
+		skb_trim(e->skb, data_len);
+	else if (diff > 0) {
+		if (data_len > 0xFFFF)
+			return -EINVAL;
+		if (diff > skb_tailroom(e->skb)) {
+			struct sk_buff *newskb;
+		=09
+			newskb =3D skb_copy_expand(e->skb,
+			                         skb_headroom(e->skb),
+			                         diff,
+			                         GFP_ATOMIC);
+			if (newskb =3D=3D NULL) {
+				printk(KERN_WARNING "ip_queue: OOM "
+				      "in mangle, dropping packet\n");
+				return -ENOMEM;
+			}
+			if (e->skb->sk)
+				skb_set_owner_w(newskb, e->skb->sk);
+			kfree_skb(e->skb);
+			e->skb =3D newskb;
+		}
+		skb_put(e->skb, diff);
+	}
+	if (!skb_make_writable(&e->skb, data_len))
+		return -ENOMEM;
+	memcpy(e->skb->data, data, data_len);
+
+	return 0;
+}
+
+static inline int
+id_cmp(struct nfqnl_queue_entry *e, unsigned long id)
+{
+	return (id =3D=3D e->id);
+}
+
+static int
+nfqnl_set_mode(struct nfqnl_instance *queue,
+	       unsigned char mode, unsigned int range)
+{
+	int status;
+
+	spin_lock_bh(&queue->lock);
+	status =3D __nfqnl_set_mode(queue, mode, range);
+	spin_unlock_bh(&queue->lock);
+
+	return status;
+}
+
+static int
+dev_cmp(struct nfqnl_queue_entry *entry, unsigned long ifindex)
+{
+	if (entry->info->indev)
+		if (entry->info->indev->ifindex =3D=3D ifindex)
+			return 1;
+		=09
+	if (entry->info->outdev)
+		if (entry->info->outdev->ifindex =3D=3D ifindex)
+			return 1;
+
+	return 0;
+}
+
+/* drop all packets with either indev or outdev =3D=3D ifindex from all qu=
eue
+ * instances */
+static void
+nfqnl_dev_drop(int ifindex)
+{
+	int i;
+=09
+	QDEBUG("entering for ifindex %u\n", ifindex);
+
+	/* this only looks like we have to hold the readlock for a way too long
+	 * time, issue_verdict(),  nf_reinject(), ... - but we always only
+	 * issue NF_DROP, which is processed directly in nf_reinject() */
+	read_lock_bh(&instances_lock);
+
+	for  (i =3D 0; i < INSTANCE_BUCKETS; i++) {
+		struct hlist_node *tmp;
+		struct nfqnl_instance *inst;
+		struct hlist_head *head =3D &instance_table[i];
+
+		hlist_for_each_entry(inst, tmp, head, hlist) {
+			struct nfqnl_queue_entry *entry;
+			while ((entry =3D find_dequeue_entry(inst, dev_cmp,=20
+							   ifindex)) !=3D NULL)
+				issue_verdict(entry, NF_DROP);
+		}
+	}
+
+	read_unlock_bh(&instances_lock);
+}
+
+#define RCV_SKB_FAIL(err) do { netlink_ack(skb, nlh, (err)); return; } whi=
le (0)
+
+static int
+nfqnl_rcv_dev_event(struct notifier_block *this,
+		    unsigned long event, void *ptr)
+{
+	struct net_device *dev =3D ptr;
+
+	/* Drop any packets associated with the downed device */
+	if (event =3D=3D NETDEV_DOWN)
+		nfqnl_dev_drop(dev->ifindex);
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block nfqnl_dev_notifier =3D {
+	.notifier_call	=3D nfqnl_rcv_dev_event,
+};
+
+static int
+nfqnl_rcv_nl_event(struct notifier_block *this,
+		   unsigned long event, void *ptr)
+{
+	struct netlink_notify *n =3D ptr;
+
+	if (event =3D=3D NETLINK_URELEASE &&
+	    n->protocol =3D=3D NETLINK_NETFILTER && n->pid) {
+		int i;
+
+		/* destroy all instances for this pid */
+		write_lock_bh(&instances_lock);
+		for  (i =3D 0; i < INSTANCE_BUCKETS; i++) {
+			struct hlist_node *tmp, *t2;
+			struct nfqnl_instance *inst;
+			struct hlist_head *head =3D &instance_table[i];
+
+			hlist_for_each_entry_safe(inst, tmp, t2, head, hlist) {
+				if (n->pid =3D=3D inst->peer_pid)
+					__instance_destroy(inst);
+			}
+		}
+		write_unlock_bh(&instances_lock);
+	}
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block nfqnl_rtnl_notifier =3D {
+	.notifier_call	=3D nfqnl_rcv_nl_event,
+};
+
+static int
+nfqnl_recv_verdict(struct sock *ctnl, struct sk_buff *skb,
+		   struct nlmsghdr *nlh, struct nfattr *nfqa[], int *errp)
+{
+	struct nfgenmsg *nfmsg =3D NLMSG_DATA(nlh);
+	u_int16_t queue_num =3D ntohs(nfmsg->res_id);
+
+	struct nfqnl_msg_verdict_hdr *vhdr;
+	struct nfqnl_instance *queue;
+	unsigned int verdict;
+	struct nfqnl_queue_entry *entry;
+
+	queue =3D instance_lookup(queue_num);
+	if (!queue)
+		return -ENODEV;
+
+	if (queue->peer_pid !=3D NETLINK_CB(skb).pid)
+		return -EPERM;
+
+	if (!nfqa[NFQA_VERDICT_HDR-1])
+		return -EINVAL;
+
+	vhdr =3D NFA_DATA(nfqa[NFQA_VERDICT_HDR-1]);
+	verdict =3D ntohl(vhdr->verdict);
+
+	if ((verdict & NF_VERDICT_MASK) > NF_MAX_VERDICT)
+		return -EINVAL;
+
+	entry =3D find_dequeue_entry(queue, id_cmp, ntohl(vhdr->id));
+	if (entry =3D=3D NULL)
+		return -ENOENT;
+
+	if (nfqa[NFQA_PAYLOAD-1]) {
+		if (nfqnl_mangle(NFA_DATA(nfqa[NFQA_PAYLOAD-1]),
+				 NFA_PAYLOAD(nfqa[NFQA_PAYLOAD-1]), entry) < 0)
+			verdict =3D NF_DROP;
+	}
+
+	if (nfqa[NFQA_MARK-1])
+		skb->nfmark =3D ntohl(*(u_int32_t *)NFA_DATA(nfqa[NFQA_MARK-1]));
+	=09
+	issue_verdict(entry, verdict);
+	return 0;
+}
+
+static int
+nfqnl_recv_unsupp(struct sock *ctnl, struct sk_buff *skb,
+		  struct nlmsghdr *nlh, struct nfattr *nfqa[], int *errp)
+{
+	return -ENOTSUPP;
+}
+
+static int
+nfqnl_recv_config(struct sock *ctnl, struct sk_buff *skb,
+		  struct nlmsghdr *nlh, struct nfattr *nfqa[], int *errp)
+{
+	struct nfgenmsg *nfmsg =3D NLMSG_DATA(nlh);
+	u_int16_t queue_num =3D ntohs(nfmsg->res_id);
+	struct nfqnl_instance *queue;
+
+	QDEBUG("entering for msg %u\n", NFNL_MSG_TYPE(nlh->nlmsg_type));
+
+	queue =3D instance_lookup(queue_num);
+	if (nfqa[NFQA_CFG_CMD-1]) {
+		struct nfqnl_msg_config_cmd *cmd;
+		cmd =3D NFA_DATA(nfqa[NFQA_CFG_CMD-1]);
+		QDEBUG("found CFG_CMD\n");
+
+		switch (cmd->command) {
+		case NFQNL_CFG_CMD_BIND:
+			if (queue)
+				return -EBUSY;
+
+			queue =3D instance_create(queue_num, NETLINK_CB(skb).pid);
+			if (!queue)
+				return -EINVAL;
+			break;
+		case NFQNL_CFG_CMD_UNBIND:
+			if (!queue)
+				return -ENODEV;
+
+			if (queue->peer_pid !=3D NETLINK_CB(skb).pid)
+				return -EPERM;
+
+			instance_destroy(queue);
+			break;
+		case NFQNL_CFG_CMD_PF_BIND:
+			QDEBUG("registering queue handler for pf=3D%u\n",
+				ntohs(cmd->pf));
+			return nf_register_queue_handler(ntohs(cmd->pf),
+							 nfqnl_enqueue_packet,
+							 NULL);
+
+			break;
+		case NFQNL_CFG_CMD_PF_UNBIND:
+			QDEBUG("unregistering queue handler for pf=3D%u\n",
+				ntohs(cmd->pf));
+			/* This is a bug and a feature.  We can unregister
+			 * other handlers(!) */
+			return nf_unregister_queue_handler(ntohs(cmd->pf));
+			break;
+		default:
+			return -EINVAL;
+		}
+	} else {
+		if (!queue) {
+			QDEBUG("no config command, and no instance ENOENT\n");
+			return -ENOENT;
+		}
+
+		if (queue->peer_pid !=3D NETLINK_CB(skb).pid) {
+			QDEBUG("no config command, and wrong pid\n");
+			return -EPERM;
+		}
+	}
+
+	if (nfqa[NFQA_CFG_PARAMS-1]) {
+		struct nfqnl_msg_config_params *params;
+		params =3D NFA_DATA(nfqa[NFQA_CFG_PARAMS-1]);
+
+		nfqnl_set_mode(queue, params->copy_mode,
+				ntohl(params->copy_range));
+	}
+
+	return 0;
+}
+
+static struct nfnl_callback nfqnl_cb[NFQNL_MSG_MAX] =3D {
+	[NFQNL_MSG_PACKET]	=3D { .call =3D nfqnl_recv_unsupp,
+				    .cap_required =3D CAP_NET_ADMIN },
+	[NFQNL_MSG_VERDICT]	=3D { .call =3D nfqnl_recv_verdict,
+				    .cap_required =3D CAP_NET_ADMIN },
+	[NFQNL_MSG_CONFIG]	=3D { .call =3D nfqnl_recv_config,
+				    .cap_required =3D CAP_NET_ADMIN },
+};
+
+static struct nfnetlink_subsystem nfqnl_subsys =3D {
+	.name		=3D "nf_queue",
+	.subsys_id	=3D NFNL_SUBSYS_QUEUE,
+	.cb_count	=3D NFQNL_MSG_MAX,
+	.attr_count	=3D NFQA_MAX,
+	.cb		=3D nfqnl_cb,
+};
+
+static int
+init_or_cleanup(int init)
+{
+	int status =3D -ENOMEM;
+=09
+	if (!init)
+		goto cleanup;
+
+	netlink_register_notifier(&nfqnl_rtnl_notifier);
+	status =3D nfnetlink_subsys_register(&nfqnl_subsys);
+	if (status < 0) {
+		printk(KERN_ERR "nf_queue: failed to create netlink socket\n");
+		goto cleanup_netlink_notifier;
+	}
+
+	register_netdevice_notifier(&nfqnl_dev_notifier);
+	return status;
+
+cleanup:
+	nf_unregister_queue_handlers(nfqnl_enqueue_packet);
+	unregister_netdevice_notifier(&nfqnl_dev_notifier);
+	nfnetlink_subsys_unregister(&nfqnl_subsys);
+=09
+cleanup_netlink_notifier:
+	netlink_unregister_notifier(&nfqnl_rtnl_notifier);
+	return status;
+}
+
+static int __init init(void)
+{
+=09
+	return init_or_cleanup(1);
+}
+
+static void __exit fini(void)
+{
+	init_or_cleanup(0);
+}
+
+MODULE_DESCRIPTION("netfilter packet queue handler");
+MODULE_AUTHOR("Harald Welte <laforge@netfilter.org>");
+MODULE_LICENSE("GPL");
+MODULE_ALIAS_NFNL_SUBSYS(NFNL_SUBSYS_QUEUE);
+
+module_init(init);
+module_exit(fini);

--oC1+HKm2/end4ao3--

--ghzN8eJ9Qlbqn3iT
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFC5rHpXaXGVTD0i/8RAqnvAJ9xF49oU60RhnOLf25hEYK1Kiwm5gCeP6HZ
KsBlREC8AFAs+xdd5tmmnP8=
=D0Nv
-----END PGP SIGNATURE-----

--ghzN8eJ9Qlbqn3iT--
