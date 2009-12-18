From: Torsten Schmidt <torsten.schmidt@s2006.tu-chemnitz.de>
Subject: Re: Still using IPTOS_TOS() in kernel? Really???
Date: Fri, 18 Dec 2009 16:20:33 +0100
Message-ID: <200912181620.33190.schmto@hrz.tu-chemnitz.de>
References: <4B298118.2000608@redfish-solutions.com> <200912171724.32711.schmto@hrz.tu-chemnitz.de> <4B2A8A5C.9070702@redfish-solutions.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_B35KLVcqj6VfM6h"
To: "Philip A. Prindeville" <philipp_subx@redfish-solutions.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from jack.hrz.tu-chemnitz.de ([134.109.132.46]:35481 "EHLO
	jack.hrz.tu-chemnitz.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754496AbZLRPUf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2009 10:20:35 -0500
In-Reply-To: <4B2A8A5C.9070702@redfish-solutions.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_B35KLVcqj6VfM6h
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit

On Thursday 17 December 2009 20:45:32 you wrote:
> On 12/17/2009 08:24 AM, Torsten Schmidt wrote:
> > Hi Philip,
> >
> > interesting .. i am on the way to implement a DSCP/CS statistic to the
> > kernel. We need this for network traffic accounting. The concept is the
> > following:
> >
> > We create a virtual file /pro/net/ipdscp , this includes several DSCP/CS
> > counters. See http://www.iana.org/assignments/dscp-registry/. Every time
> > ip_rcv_finish() is called, we take a look at the DSCP/CS (iph->tos) value
> > and increment the related counter. If you're interested in, i will send
> > you a patch ? ..
> 
> That would be great.

Here is a first PATCH, tested against 2.6.32. At the time we only support DSCP 
class: CS0 and EF PHB. All other classes are shown in /proc/net/ipdscp, but 
always referenced with 0. Please take a look at ... 

For debugging use:
  # ping -Q 0xAB localhost
  # cat /pro/net/ipdscp

in which 0xAB is:
  0x00 for CS0, ore
  0xB8 for EF PHB

Torsten

--Boundary-00=_B35KLVcqj6VfM6h
Content-Type: text/x-patch;
  charset="UTF-8";
  name="0001-ipv4-add-DSCP-statistic.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="0001-ipv4-add-DSCP-statistic.patch"

=46rom aacc531f2c3f992f3acee65d8806c2c67df348b7 Mon Sep 17 00:00:00 2001
=46rom: Torsten Schmidt <schmto@hrz.tu-chemnitz.de>
Date: Fri, 18 Dec 2009 15:18:52 +0100
Subject: [PATCH] ipv4: add DSCP statistic

This adds IPv4 DSCP statistic to the kernel. See:
  * /proc/net/ipdscp
  * IANA dscp-registry
  * RFC 2474

Signed-off-by: Torsten Schmidt <schmto@hrz.tu-chemnitz.de>
=2D--
 include/linux/snmp.h    |   28 +++++++++++
 include/net/ipdscp.h    |   65 ++++++++++++++++++++++++++
 include/net/netns/mib.h |    4 ++
 include/net/snmp.h      |    6 +++
 net/ipv4/Kconfig        |   11 +++++
 net/ipv4/Makefile       |    2 +-
 net/ipv4/af_inet.c      |    3 +
 net/ipv4/ip_input.c     |    5 ++
 net/ipv4/ipdscp.c       |  116 +++++++++++++++++++++++++++++++++++++++++++=
++++
 9 files changed, 239 insertions(+), 1 deletions(-)
 create mode 100644 include/net/ipdscp.h
 create mode 100644 net/ipv4/ipdscp.c

diff --git a/include/linux/snmp.h b/include/linux/snmp.h
index 0f953fe..9cd2d8d 100644
=2D-- a/include/linux/snmp.h
+++ b/include/linux/snmp.h
@@ -260,4 +260,32 @@ enum
 	__LINUX_MIB_XFRMMAX
 };
=20
+
+/* IPv4 DSCP */
+enum
+{
+	LINUX_MIB_IPDSCP_CS0,
+	LINUX_MIB_IPDSCP_CS1,
+	LINUX_MIB_IPDSCP_CS2,
+	LINUX_MIB_IPDSCP_CS3,
+	LINUX_MIB_IPDSCP_CS4,
+	LINUX_MIB_IPDSCP_CS5,
+	LINUX_MIB_IPDSCP_CS6,
+	LINUX_MIB_IPDSCP_CS7,
+	LINUX_MIB_IPDSCP_AF11,
+	LINUX_MIB_IPDSCP_AF12,
+	LINUX_MIB_IPDSCP_AF13,
+	LINUX_MIB_IPDSCP_AF21,
+	LINUX_MIB_IPDSCP_AF22,
+	LINUX_MIB_IPDSCP_AF23,
+	LINUX_MIB_IPDSCP_AF31,
+	LINUX_MIB_IPDSCP_AF32,
+	LINUX_MIB_IPDSCP_AF33,
+	LINUX_MIB_IPDSCP_AF41,
+	LINUX_MIB_IPDSCP_AF42,
+	LINUX_MIB_IPDSCP_AF43,
+	LINUX_MIB_IPDSCP_EF,
+	__IPDSCP_MIB_MAX
+};
+
 #endif	/* _LINUX_SNMP_H */
diff --git a/include/net/ipdscp.h b/include/net/ipdscp.h
new file mode 100644
index 0000000..d5bce81
=2D-- /dev/null
+++ b/include/net/ipdscp.h
@@ -0,0 +1,65 @@
+/*
+ * Differentiated Services Code Point Statistic
+ *
+ * Copyright (C) 2009 Torsten Schmidt
+ *
+ * Released under the GPL version 2 only.
+ *
+ */
+
+#ifndef __NET_IPDSCP_H
+#define __NET_IPDSCP_H
+
+#include <linux/types.h>
+#include <linux/ip.h>
+#include <linux/ipv6.h>
+#include <asm/byteorder.h>
+#include <net/snmp.h>
+
+#define IP_DSCP_CS0	(0x00)
+#define IP_DSCP_CS1	(0x08)
+#define IP_DSCP_CS2	(0x10)
+#define IP_DSCP_CS3	(0x18)
+#define IP_DSCP_CS4	(0x20)
+#define IP_DSCP_CS5	(0x28)
+#define IP_DSCP_CS6	(0x30)
+#define IP_DSCP_CS7	(0x38)
+#define IP_DSCP_AF11	(0x0A)
+#define IP_DSCP_AF12	(0x0C)
+#define IP_DSCP_AF13	(0x0E)
+#define IP_DSCP_AF21	(0x12)
+#define IP_DSCP_AF22	(0x14)
+#define IP_DSCP_AF23	(0x16)
+#define IP_DSCP_AF31	(0x1A)
+#define IP_DSCP_AF32	(0x1C)
+#define IP_DSCP_AF33	(0x1E)
+#define IP_DSCP_AF41	(0x22)
+#define IP_DSCP_AF42	(0x24)
+#define IP_DSCP_AF43	(0x26)
+#define IP_DSCP_EF	(0x2E)
+
+#ifdef CONFIG_IP_DSCP_STAT
+#define IP_DSCP_INC_STATS(net, field)	SNMP_INC_STATS((net)->mib.ipdscp_sta=
tistics, field)
+#define IP_DSCP_INC_STATS_BH(net, field)	SNMP_INC_STATS_BH((net)->mib.ipds=
cp_statistics, field)
+#define IP_DSCP_INC_STATS_USER(net, field)	SNMP_INC_STATS_USER((net)-mib.i=
pdscp_statistics, field)
+#else
+#define IP_DSCP_INC_STATS(net, field)	((void)(net))
+#define IP_DSCP_INC_STATS_BH(net, field)	((void)(net))
+#define IP_DSCP_INC_STATS_USER(net, field)	((void)(net))
+#endif
+
+
+int __net_init ipdscp_stat_init(struct net *net);
+void ipdscp_stat_fini(struct net *net);
+
+
+static inline void ipv4_dscp_stat(struct net *net, __u8 dsfield)
+{
+	switch (dsfield >> 2) {
+	case IP_DSCP_CS0:	IP_DSCP_INC_STATS_BH(net, LINUX_MIB_IPDSCP_CS0);break;
+	case IP_DSCP_EF:	IP_DSCP_INC_STATS_BH(net, LINUX_MIB_IPDSCP_EF);break;
+	/* add new entrys here ... */
+	}
+}
+
+#endif
diff --git a/include/net/netns/mib.h b/include/net/netns/mib.h
index 0b44112..eccbc36 100644
=2D-- a/include/net/netns/mib.h
+++ b/include/net/netns/mib.h
@@ -23,6 +23,10 @@ struct netns_mib {
 #ifdef CONFIG_XFRM_STATISTICS
 	DEFINE_SNMP_STAT(struct linux_xfrm_mib, xfrm_statistics);
 #endif
+#ifdef CONFIG_IP_DSCP_STAT
+	struct proc_dir_entry *proc_net_ipdscp;
+	DEFINE_SNMP_STAT(struct ipdscp_mib, ipdscp_statistics);
+#endif
 };
=20
 #endif
diff --git a/include/net/snmp.h b/include/net/snmp.h
index 8c842e0..fcc567e 100644
=2D-- a/include/net/snmp.h
+++ b/include/net/snmp.h
@@ -122,6 +122,12 @@ struct linux_xfrm_mib {
 	unsigned long	mibs[LINUX_MIB_XFRMMAX];
 };
=20
+/* Linux IPv4 DSCP */
+#define IPDSCP_MIB_MAX	__IPDSCP_MIB_MAX
+struct ipdscp_mib {
+	unsigned long	mibs[IPDSCP_MIB_MAX];
+};
+
 /*=20
  * FIXME: On x86 and some other CPUs the split into user and softirq parts
  * is not needed because addl $1,memory is atomic against interrupts (but=
=20
diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 70491d9..b0d3cef 100644
=2D-- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -272,6 +272,17 @@ config IP_PIMSM_V2
 	  gated-5). This routing protocol is not used widely, so say N unless
 	  you want to play with it.
=20
+config IP_DSCP_STAT
+	bool "IP: DSCP statistic"
+	help
+	  This adds IPv4 DSCP statistic to the kernel.
+	  See:
+	    * /proc/net/ipdscp
+	    * IANA dscp-registry
+	    * RFC 2474	 =20
+
+	  If unsure, say N.
+
 config ARPD
 	bool "IP: ARP daemon support"
 	---help---
diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
index 80ff87c..adcb63c 100644
=2D-- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -11,7 +11,7 @@ obj-y     :=3D route.o inetpeer.o protocol.o \
 	     datagram.o raw.o udp.o udplite.o \
 	     arp.o icmp.o devinet.o af_inet.o  igmp.o \
 	     fib_frontend.o fib_semantics.o \
=2D	     inet_fragment.o
+	     inet_fragment.o ipdscp.o
=20
 obj-$(CONFIG_SYSCTL) +=3D sysctl_net_ipv4.o
 obj-$(CONFIG_IP_FIB_HASH) +=3D fib_hash.o
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 57737b8..c633c6a 100644
=2D-- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -112,6 +112,7 @@
 #include <net/inet_common.h>
 #include <net/xfrm.h>
 #include <net/net_namespace.h>
+#include <net/ipdscp.h>
 #ifdef CONFIG_IP_MROUTE
 #include <linux/mroute.h>
 #endif
@@ -1485,6 +1486,7 @@ static __net_init int ipv4_mib_init_net(struct net *n=
et)
 		goto err_icmpmsg_mib;
=20
 	tcp_mib_init(net);
+	ipdscp_stat_init(net);
 	return 0;
=20
 err_icmpmsg_mib:
@@ -1512,6 +1514,7 @@ static __net_exit void ipv4_mib_exit_net(struct net *=
net)
 	snmp_mib_free((void **)net->mib.net_statistics);
 	snmp_mib_free((void **)net->mib.ip_statistics);
 	snmp_mib_free((void **)net->mib.tcp_statistics);
+	ipdscp_stat_fini(net);
 }
=20
 static __net_initdata struct pernet_operations ipv4_mib_ops =3D {
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index 6c98b43..ba23624 100644
=2D-- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -143,6 +143,7 @@
 #include <net/xfrm.h>
 #include <linux/mroute.h>
 #include <linux/netlink.h>
+#include <net/ipdscp.h>
=20
 /*
  *	Process Router Attention IP option
@@ -365,6 +366,10 @@ static int ip_rcv_finish(struct sk_buff *skb)
 		IP_UPD_PO_STATS_BH(dev_net(rt->u.dst.dev), IPSTATS_MIB_INBCAST,
 				skb->len);
=20
+#ifdef CONFIG_IP_DSCP_STAT
+	ipv4_dscp_stat(dev_net(rt->u.dst.dev), iph->tos);
+#endif
+
 	return dst_input(skb);
=20
 drop:
diff --git a/net/ipv4/ipdscp.c b/net/ipv4/ipdscp.c
new file mode 100644
index 0000000..90f9fd1
=2D-- /dev/null
+++ b/net/ipv4/ipdscp.c
@@ -0,0 +1,116 @@
+/*
+ * Differentiated Services Code Point Statistic
+ *
+ * Copyright (C) 2009 Torsten Schmidt
+ *
+ * Released under the GPL version 2 only.
+ *
+ */
+#include <linux/kernel.h>
+#include <linux/proc_fs.h>
+#include <linux/seq_file.h>
+#include <net/ip.h>
+#include <net/snmp.h>
+#include <net/net_namespace.h>
+
+
+#ifdef CONFIG_IP_DSCP_STAT
+static struct snmp_mib ipdscp_mib_list[] =3D {
+	SNMP_MIB_ITEM("CS0", LINUX_MIB_IPDSCP_CS0),
+	SNMP_MIB_ITEM("CS1", LINUX_MIB_IPDSCP_CS1),
+	SNMP_MIB_ITEM("CS2", LINUX_MIB_IPDSCP_CS2),
+	SNMP_MIB_ITEM("CS3", LINUX_MIB_IPDSCP_CS3),
+	SNMP_MIB_ITEM("CS4", LINUX_MIB_IPDSCP_CS4),
+	SNMP_MIB_ITEM("CS5", LINUX_MIB_IPDSCP_CS5),
+	SNMP_MIB_ITEM("CS6", LINUX_MIB_IPDSCP_CS6),
+	SNMP_MIB_ITEM("CS7", LINUX_MIB_IPDSCP_CS7),
+	SNMP_MIB_ITEM("AF11", LINUX_MIB_IPDSCP_AF11),
+	SNMP_MIB_ITEM("AF12", LINUX_MIB_IPDSCP_AF12),
+	SNMP_MIB_ITEM("AF13", LINUX_MIB_IPDSCP_AF13),
+	SNMP_MIB_ITEM("AF21", LINUX_MIB_IPDSCP_AF21),
+	SNMP_MIB_ITEM("AF22", LINUX_MIB_IPDSCP_AF22),
+	SNMP_MIB_ITEM("AF23", LINUX_MIB_IPDSCP_AF23),
+	SNMP_MIB_ITEM("AF31", LINUX_MIB_IPDSCP_AF31),
+	SNMP_MIB_ITEM("AF32", LINUX_MIB_IPDSCP_AF32),
+	SNMP_MIB_ITEM("AF33", LINUX_MIB_IPDSCP_AF33),
+	SNMP_MIB_ITEM("AF41", LINUX_MIB_IPDSCP_AF41),
+	SNMP_MIB_ITEM("AF42", LINUX_MIB_IPDSCP_AF42),
+	SNMP_MIB_ITEM("AF43", LINUX_MIB_IPDSCP_AF43),
+	SNMP_MIB_ITEM("EF", LINUX_MIB_IPDSCP_EF),
+	SNMP_MIB_SENTINEL
+};
+
+
+static int ipdscp_statistics_seq_show(struct seq_file *seq, void *v)
+{
+	struct net *net =3D seq->private;
+	int i;
+	for (i=3D0; ipdscp_mib_list[i].name; i++)
+		seq_printf(seq, "%-24s\t%lu\n", ipdscp_mib_list[i].name,
+			   snmp_fold_field((void **)net->mib.ipdscp_statistics,
+					   ipdscp_mib_list[i].entry));
+	return 0;
+}
+
+
+static int ipdscp_statistics_seq_open(struct inode *inode, struct file *fi=
le)
+{
+	return single_open_net(inode, file, ipdscp_statistics_seq_show);
+}
+
+
+static const struct file_operations ipdscp_statistics_seq_fops =3D {
+	.owner	 =3D THIS_MODULE,
+	.open	 =3D ipdscp_statistics_seq_open,
+	.read	 =3D seq_read,
+	.llseek	 =3D seq_lseek,
+	.release =3D single_release_net,
+};
+
+
+static int __net_init ipdscp_proc_init(struct net *net)
+{
+	if (!proc_net_fops_create(net, "ipdscp", S_IRUGO,
+				  &ipdscp_statistics_seq_fops))
+		return -ENOMEM;
+	return 0;
+}
+
+
+static void ipdscp_proc_fini(struct net *net)
+{
+	proc_net_remove(net, "ipdscp");
+}
+
+
+int __net_init ipdscp_stat_init(struct net *net)
+{
+	int rv;
+
+	if (snmp_mib_init((void **)net->mib.ipdscp_statistics,
+			  sizeof(struct ipdscp_mib)) < 0)
+		return -ENOMEM;
+	rv =3D ipdscp_proc_init(net);
+	if (rv < 0)
+		snmp_mib_free((void **)net->mib.ipdscp_statistics);
+	return rv;
+}
+
+void ipdscp_stat_fini(struct net *net)
+{
+	ipdscp_proc_fini(net);
+	snmp_mib_free((void **)net->mib.ipdscp_statistics);
+}
+
+
+#else /* CONFIG_IP_DSCP_STAT */
+int __net_init ipdscp_stat_init(struct net *net)
+{
+	return 0;
+}
+
+void ipdscp_stat_fini(struct net *net)
+{
+	return;
+}
+#endif
=2D-=20
1.6.3.3


--Boundary-00=_B35KLVcqj6VfM6h--
