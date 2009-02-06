From: Neil Horman <nhorman@tuxdriver.com>
Subject: [RFC] addition of a dropped packet notification service
Date: Fri, 6 Feb 2009 13:20:20 -0500
Message-ID: <20090206182020.GA24399@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org,
	herbert@gondor.apana.org.au, nhorman@tuxdriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:58484 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751690AbZBFSUj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2009 13:20:39 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey all-
	A week or so ago I tried posting a tracepoint patch for net-next which
was met with some resistance, with opposing arguments circling around the lines
of not having an upstream user for those points, which I think is good
criticizm.  As such I think I've come up with a project idea here that I can
implement using a few tracepoints (not that that really matters in light of the
overall scheme of things), but I wanted to propose it here and get some feedback
from people on what they think might be good and bad about this.


Problem: 
Gathering information about packets that are dropped within the kernel
network stack.

Problem Backround: 
The Linux kernel is nominally quite good about avoid packet
drops whenever possible.  However, there are of course times when packet
processing errors, malformed frames, or other conditions result in the need to
abandon a packet during reception or transmission.  Savy system administrators
are perfectly capable of monitoring for and detecting these lost packets so that
possible corrective action can be taken.  However the sysadmins job here suffers
from three distinct shortcommings in our user space drop detection facilities:

1) Fragmentation of information: Dropped packets occur at many different layers
of the network stack, and different mechanisms are used to access information
about drops in those various layers.  Statistics at various layers may require a
simple reading of a proc file, or it may require the use of one or more tools.
At minimum, by my count, at least 6 files/tools must be queried to get a
complete picture of where in the network stack a packet is being dropped.

2) Clarity of meaning: While some statistics are clear, others may be less so.
Even if a sysadmin knows that there are several places to look for a dropped
packet, [s]he may be far less clear on which statistics in those tools/files map
to an actual lost packet.  For instance, does a TCP AttemptFail imply a dropped
packet or not?  A quick reading of the source may indicate that, but thats at
best a subpar solution

3) Ambiguity of cause:  Even if a sysadmin correctly checks all the locations
for dropped packets and gleans which are the relevant stats for that purpose,
there is still missing information that some might enjoy.  Namely, the root
cause of the problem.  For example, UDPInErrors stats are incremented in several
places in the code, and for two primary purposes (application congestion leading
to a full rcvbuf, or a udp checksum error).  While the stats presented to the
user provide information indicating that packets were dropped in the UDP code,
the root cause is still a mystery.

Solution:
To solve this problem, I would like to propose the addition of a new netlink
protocol, NETLINK_DRPMON.  The notion is that user space applications would
dynamically engage this service, which would then monitor several tracepoints
throughout the kernel (which would in aggregate cover all the possible locations
from the system call to the hardware in which a network packet might be
dropped), these tracepoints would be hooked by the "drop monitor" to catch
increments in relevant statistics at these points, and, if/when they do,
broadcast a netlink message to listening applications to inform them a drop has
taken place.  This alert would include information about the location of the
drop (class (IPV4/IPV6/arp/hardware/etc), type (InHdrErrors, etc), and specific
location (function and line number)).  Using such a method, admins could then
use an application to reliably monitor for network packet drops in one
consolidated place, while keeping performance impact to a minimum (since
tracepoints are meant to have no impact when disabled, and very little impact
otherwise).  It consolidates information, provides clarity in what does and
doesn't constitute a drop, and provide to the line number information about
where the drop occured.

I've written some of this already, but I wanted to stop and get feedback before
I went any farther.  Please bear in mind that the patch below is totally
incomplete.  Most notably its missing most of the netlink protocol
implementation, and there is far from complete coverage of all the in-kernel
drop point locations.  But the IPv4 SNMP stats are completely covered and serve
as an exemplar of how I was planning on doing drop recording.  Also notably
missing is the user space app to listen for these messages, but if there is
general consensus that this is indeed a good idea, I'll get started on the
protocol and user app straight away.

So, have at it.  Good thoughts and bad all welcome.  Thanks for the interest and
the feedback!

Thanks & Regards
Neil


diff --git a/include/linux/net_dropmon.h b/include/linux/net_dropmon.h
new file mode 100644
index 0000000..fdcd02c
--- /dev/null
+++ b/include/linux/net_dropmon.h
@@ -0,0 +1,42 @@
+#ifndef __NET_DROPMON_H
+#define __NET_DROPMON_H
+
+#include <linux/netlink.h>
+
+
+struct net_dm_config_msg {
+};
+
+struct net_dm_user_msg {
+	union {
+		struct net_dm_config_msg cmsg;
+	} u;
+};
+
+struct net_dm_drop_point {
+	char function[64];
+	unsigned int line;	
+};
+
+/*
+ * These are the classes of drops that we can have
+ * Each one corresponds to a stats file/utility
+ * you can use to gather more data on the drop
+ */
+enum {
+        DROP_CLASS_SNMP_IPV4 = 0,
+        DROP_CLASS_SNMP_IPV6,
+        DROP_CLASS_SNMP_TCP,
+        DROP_CLASS_SNMP_UDP,
+        DROP_CLASS_SNMP_LINUX,
+};
+
+/* These are the netlink message types for this protocol */
+
+#define NET_DM_BASE	0x10 			/* Standard Netlink Messages below this */
+#define NET_DM_ALERT	(NET_DM_BASE + 1) 	/* Alert about dropped packets */
+#define NET_DM_CONFIG	(NET_DM_BASE + 2)	/* Configuration message */
+#define NET_DM_START	(NET_DM_BASE + 3)	/* Start monitoring */
+#define NET_DM_STOP	(NET_DM_BASE + 4)	/* Stop monitoring */
+#define NET_DM_MAX	(NET_DM_BASE + 3)
+#endif
diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index 51b09a1..255d6ad 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -24,6 +24,7 @@
 /* leave room for NETLINK_DM (DM Events) */
 #define NETLINK_SCSITRANSPORT	18	/* SCSI Transports */
 #define NETLINK_ECRYPTFS	19
+#define NETLINK_DRPMON		20	/* Netork packet drop alerts */
 
 #define MAX_LINKS 32		
 
diff --git a/include/net/ip.h b/include/net/ip.h
index 1086813..08398f8 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -26,6 +26,7 @@
 #include <linux/ip.h>
 #include <linux/in.h>
 #include <linux/skbuff.h>
+#include <trace/snmp.h>
 
 #include <net/inet_sock.h>
 #include <net/snmp.h>
@@ -165,9 +166,24 @@ struct ipv4_config
 };
 
 extern struct ipv4_config ipv4_config;
-#define IP_INC_STATS(net, field)	SNMP_INC_STATS((net)->mib.ip_statistics, field)
-#define IP_INC_STATS_BH(net, field)	SNMP_INC_STATS_BH((net)->mib.ip_statistics, field)
-#define IP_ADD_STATS_BH(net, field, val) SNMP_ADD_STATS_BH((net)->mib.ip_statistics, field, val)
+#define IP_INC_STATS(net, field)	do {\
+	DECLARE_DROP_POINT(dp,field);\
+	SNMP_INC_STATS((net)->mib.ip_statistics, field);\
+	trace_snmp_ipv4_mib(&dp, 1);\
+} while(0)
+
+#define IP_INC_STATS_BH(net, field)	do {\
+	DECLARE_DROP_POINT(dp, field);\
+	SNMP_INC_STATS_BH((net)->mib.ip_statistics, field);\
+	trace_snmp_ipv4_mib(&dp, 1);\
+} while(0)
+
+#define IP_ADD_STATS_BH(net, field, val) do{\
+	DECLARE_DROP_POINT(dp, field);\
+	SNMP_ADD_STATS_BH((net)->mib.ip_statistics, field, val);\
+	trace_snmp_ipv4_mib(&dp, val);\
+} while(0)
+
 #define NET_INC_STATS(net, field)	SNMP_INC_STATS((net)->mib.net_statistics, field)
 #define NET_INC_STATS_BH(net, field)	SNMP_INC_STATS_BH((net)->mib.net_statistics, field)
 #define NET_INC_STATS_USER(net, field) 	SNMP_INC_STATS_USER((net)->mib.net_statistics, field)
diff --git a/include/trace/snmp.h b/include/trace/snmp.h
new file mode 100644
index 0000000..289dca9
--- /dev/null
+++ b/include/trace/snmp.h
@@ -0,0 +1,33 @@
+#ifndef _TRACE_SNMP_H
+#define _TRACE_SNMP_H
+
+#include <linux/tracepoint.h>
+#include <linux/list.h>
+
+#define DP_IN_USE 0
+
+struct snmp_drop_point {
+	const char *function;
+	unsigned int line;	
+	unsigned int type;
+	uint8_t flags;
+	struct list_head list;
+};
+
+#ifdef CONFIG_TRACEPOINTS
+#define DECLARE_DROP_POINT(name, kind) struct snmp_drop_point name = {\
+	.function = __FUNCTION__,\
+	.line = __LINE__,\
+	.type = kind,\
+	.flags = 0,\
+	.list = LIST_HEAD_INIT(name.list),\
+}
+#else
+#define DECLARE_DROP_POINT(name, type)
+#endif
+
+DECLARE_TRACE(snmp_ipv4_mib,
+	TPPROTO(struct snmp_drop_point *dp, int count),
+		TPARGS(dp, count));
+
+#endif
diff --git a/net/Kconfig b/net/Kconfig
index a12bae0..f6dc56a 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -221,6 +221,17 @@ config NET_TCPPROBE
 	To compile this code as a module, choose M here: the
 	module will be called tcp_probe.
 
+config NET_DROP_MONITOR
+	boolean "Network packet drop alerting service"
+	depends on INET && EXPERIMENTAL && TRACEPOINTS
+	---help---
+	This feature provides an alerting service to userspace in the 
+	event that packets are discarded in the network stack.  Alerts
+	are broadcast via netlink socket to any listening user space 
+	process.  If you don't need network drop alerts, or if you are ok
+	just checking the various proc files and other utilities for
+	drop statistics, say N here.
+
 endmenu
 
 endmenu
diff --git a/net/core/Makefile b/net/core/Makefile
index 26a37cb..245d7ab 100644
--- a/net/core/Makefile
+++ b/net/core/Makefile
@@ -17,3 +17,5 @@ obj-$(CONFIG_NET_PKTGEN) += pktgen.o
 obj-$(CONFIG_NETPOLL) += netpoll.o
 obj-$(CONFIG_NET_DMA) += user_dma.o
 obj-$(CONFIG_FIB_RULES) += fib_rules.o
+obj-$(CONFIG_NET_DROP_MONITOR) += drop_monitor.o
+
diff --git a/net/core/drop_monitor.c b/net/core/drop_monitor.c
new file mode 100644
index 0000000..5bd2128
--- /dev/null
+++ b/net/core/drop_monitor.c
@@ -0,0 +1,211 @@
+/*
+ * Monitoring code for network dropped packet alerts 
+ *
+ * Copyright (C) 2009 Neil Horman <nhorman@tuxdriver.com> 
+ */
+
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/string.h>
+#include <linux/if_arp.h>
+#include <linux/inetdevice.h>
+#include <linux/inet.h>
+#include <linux/interrupt.h>
+#include <linux/netpoll.h>
+#include <linux/sched.h>
+#include <linux/delay.h>
+#include <linux/rcupdate.h>
+#include <linux/types.h>
+#include <linux/workqueue.h>
+#include <linux/netlink.h>
+#include <linux/net_dropmon.h>
+
+#include <asm/unaligned.h>
+#include <asm/bitops.h>
+#include <trace/snmp.h>
+
+#define RCV_SKB_FAIL(err) do { netlink_ack(skb, nlh, (err)); return; } while (0)
+
+#define TRACE_ON 1
+#define TRACE_OFF 0
+
+static void send_dm_alert(struct work_struct *unused);
+
+
+/*
+ * Globals, our netlink socket pointer
+ * and the work handle that will send up
+ * netlink alerts
+ */
+struct sock *dm_sock;
+DECLARE_WORK(dm_alert_work, send_dm_alert);
+
+DEFINE_TRACE(snmp_ipv4_mib);
+EXPORT_TRACEPOINT_SYMBOL_GPL(snmp_ipv4_mib);
+
+/*
+ * Bitmasks for our hit classes, and one for each 
+ * class so we know which type of hit in each class
+ * we got
+ */
+static uint64_t drop_class_hits;
+
+
+/*
+ * ipv4 mib list of drop detections
+ */
+static struct list_head ipv4_drop_hits[2] = {
+	LIST_HEAD_INIT(ipv4_drop_hits[0]),
+	LIST_HEAD_INIT(ipv4_drop_hits[1]),
+};
+
+static struct list_head *ipv4_drop_hitp = &ipv4_drop_hits[0];
+static int ipv4_dh_index = 0;
+
+static void send_dm_alert(struct work_struct *unused)
+{
+	struct list_head *last_hitp;
+
+	printk(KERN_INFO "Sending netlink alert message\n");
+	drop_class_hits = 0;
+
+	last_hitp = rcu_dereference(ipv4_drop_hitp);
+	ipv4_dh_index = !ipv4_dh_index;
+	rcu_assign_pointer(ipv4_drop_hitp, &ipv4_drop_hits[ipv4_dh_index]);
+	
+}
+
+static void snmp_ipv4_mib_hit(struct snmp_drop_point *dp,  int count)
+{
+	struct list_head *hitp;
+
+	printk(KERN_CRIT "Got IPV4 MIB HIT\n");
+	switch (dp->type) {
+        case IPSTATS_MIB_INRECEIVES:
+        case IPSTATS_MIB_INTOOBIGERRORS:
+        case IPSTATS_MIB_INNOROUTES:
+        case IPSTATS_MIB_INADDRERRORS:
+        case IPSTATS_MIB_INUNKNOWNPROTOS:
+        case IPSTATS_MIB_INTRUNCATEDPKTS:
+        case IPSTATS_MIB_INDISCARDS:
+        case IPSTATS_MIB_OUTDISCARDS:
+        case IPSTATS_MIB_OUTNOROUTES:
+        case IPSTATS_MIB_REASMTIMEOUT:
+        case IPSTATS_MIB_REASMFAILS:
+        case IPSTATS_MIB_FRAGFAILS:
+		set_bit(DROP_CLASS_SNMP_IPV4, (void *)&drop_class_hits);
+		if (!test_and_set_bit(DP_IN_USE, (void *)&dp->flags)) {
+			hitp = rcu_dereference(ipv4_drop_hitp);
+			/*
+			 * we got the dp, add it to the list
+			 */
+			list_add_tail(&dp->list, hitp);
+		}
+		schedule_work(&dm_alert_work);
+		break;
+	default:
+		return;
+	};
+
+}
+
+static int set_all_monitor_traces(int state)
+{
+	int rc = 0;
+
+	switch (state) {
+	case TRACE_ON:
+		rc |= register_trace_snmp_ipv4_mib(snmp_ipv4_mib_hit);
+		break;
+	case TRACE_OFF:
+		rc |= unregister_trace_snmp_ipv4_mib(snmp_ipv4_mib_hit);
+		break;
+	default:
+		rc = 1;
+		break;
+	}
+
+	if (rc)
+		return -EFAULT;
+	return rc;
+}
+
+static int dropmon_handle_msg(struct net_dm_user_msg *pmsg,
+			unsigned char type, unsigned int len)
+{
+	int status = 0;
+
+	if (pmsg && (len < sizeof(*pmsg)))
+		return -EINVAL;
+
+	switch (type) {
+		case NET_DM_START:
+			printk(KERN_INFO "Start dropped packet monitor\n");
+			set_all_monitor_traces(TRACE_ON);
+			break;
+		case NET_DM_STOP:
+			printk(KERN_INFO "Stop dropped packet monitor\n");
+			set_all_monitor_traces(TRACE_OFF);
+			break;
+
+	default:
+		status = -EINVAL;
+	}
+	return status;
+}
+
+
+static void drpmon_rcv(struct sk_buff *skb)
+{
+	int status, type, pid, flags, nlmsglen, skblen;
+	struct nlmsghdr *nlh;
+
+	skblen = skb->len;
+	if (skblen < sizeof(*nlh))
+		return;
+
+	nlh = nlmsg_hdr(skb);
+	nlmsglen = nlh->nlmsg_len;
+	if (nlmsglen < sizeof(*nlh) || skblen < nlmsglen)
+		return;
+
+	pid = nlh->nlmsg_pid;
+	flags = nlh->nlmsg_flags;
+
+	if(pid <= 0 || !(flags & NLM_F_REQUEST) || flags & NLM_F_MULTI)
+		RCV_SKB_FAIL(-EINVAL);
+
+	if (flags & MSG_TRUNC)
+		RCV_SKB_FAIL(-ECOMM);
+
+	type = nlh->nlmsg_type;
+	if (type < NLMSG_NOOP || type >= NET_DM_MAX)
+		RCV_SKB_FAIL(-EINVAL);
+
+	if (type <= NET_DM_BASE)
+		return;
+
+	status = dropmon_handle_msg(NLMSG_DATA(nlh), type,
+				  nlmsglen - NLMSG_LENGTH(0));
+	if (status < 0)
+		RCV_SKB_FAIL(status);
+
+	if (flags & NLM_F_ACK)
+		netlink_ack(skb, nlh, 0);
+	return;
+}
+
+void __init init_net_drop_monitor(void)
+{
+
+	printk(KERN_INFO "INITIALIZING NETWORK DROP MONITOR SERVICE\n");
+
+	dm_sock = netlink_kernel_create(&init_net, NETLINK_DRPMON, 0,
+					drpmon_rcv, NULL, THIS_MODULE);
+
+	if (dm_sock == NULL) {
+		printk(KERN_ERR "Could not create drop monitor socket\n");
+		return;
+	}
+}
+
