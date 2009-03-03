From: Neil Horman <nhorman@tuxdriver.com>
Subject: [Patch 4/5] Network Drop Monitor: Adding drop monitor
	implementation & Netlink protocol
Date: Tue, 3 Mar 2009 12:04:35 -0500
Message-ID: <20090303170435.GE1480@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nhorman@tuxdriver.com, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:52418 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752353AbZCCREq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2009 12:04:46 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Network Drop Monitor: Adding drop monitor implementation & Netlink protocol
Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


 include/linux/net_dropmon.h |   54 +++++++
 net/core/drop_monitor.c     |  307 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 361 insertions(+)

diff --git a/include/linux/net_dropmon.h b/include/linux/net_dropmon.h
new file mode 100644
index 0000000..af11d26
--- /dev/null
+++ b/include/linux/net_dropmon.h
@@ -0,0 +1,54 @@
+#ifndef __NET_DROPMON_H
+#define __NET_DROPMON_H
+
+#include <linux/netlink.h>
+
+struct net_dm_drop_point {
+	uint8_t pc[8];
+	uint32_t count;
+};
+
+typedef enum {
+	NET_DM_CFG_VERSION = 0,
+	NET_DM_CFG_ALERT_COUNT,
+	NET_DM_CFG_ALERT_DELAY,
+	NET_DM_CFG_MAX,
+} config_type_t;
+
+struct net_dm_config_entry {
+	config_type_t type;
+	uint64_t data;
+};
+
+struct net_dm_config_msg {
+	size_t entries;
+	struct net_dm_config_entry options[0];
+};
+
+struct net_dm_alert_msg {
+	size_t entries;
+	struct net_dm_drop_point points[0];
+};
+
+struct net_dm_user_msg {
+	union {
+		struct net_dm_config_msg user;
+		struct net_dm_alert_msg alert;
+	}u;
+};
+
+/*
+ * Group names
+ */
+#define NET_DM_GRP_ALERTS 1
+
+
+/* These are the netlink message types for this protocol */
+
+#define NET_DM_BASE	0x10 			/* Standard Netlink Messages below this */
+#define NET_DM_ALERT	(NET_DM_BASE + 1) 	/* Alert about dropped packets */
+#define NET_DM_CONFIG	(NET_DM_BASE + 2)	/* Configuration message */
+#define NET_DM_START	(NET_DM_BASE + 3)	/* Start monitoring */
+#define NET_DM_STOP	(NET_DM_BASE + 4)	/* Stop monitoring */
+#define NET_DM_MAX	(NET_DM_BASE + 5)
+#endif
diff --git a/net/core/drop_monitor.c b/net/core/drop_monitor.c
new file mode 100644
index 0000000..5074f2e
--- /dev/null
+++ b/net/core/drop_monitor.c
@@ -0,0 +1,307 @@
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
+#include <linux/types.h>
+#include <linux/workqueue.h>
+#include <linux/netlink.h>
+#include <linux/net_dropmon.h>
+#include <linux/percpu.h>
+#include <linux/timer.h>
+
+#include <trace/skb.h>
+
+#include <asm/unaligned.h>
+#include <asm/bitops.h>
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
+
+struct per_cpu_dm_data {
+	struct work_struct dm_alert_work;
+	struct sk_buff *skb;
+	atomic_t dm_hit_count;
+	struct timer_list send_timer;
+};
+
+DEFINE_PER_CPU(struct per_cpu_dm_data, dm_cpu_data);
+
+static spinlock_t send_lock = SPIN_LOCK_UNLOCKED;
+static int dm_hit_limit = 64;
+static int dm_delay = 1;
+
+static void send_dm_alert(struct work_struct *unused)
+{
+	size_t al, size;
+	struct net_dm_alert_msg *msg;
+	struct nlmsghdr *nlh;
+	struct sk_buff *skb, *nskb;
+	struct per_cpu_dm_data *data = &__get_cpu_var(dm_cpu_data);
+
+	al = sizeof(struct nlmsghdr);
+	al += sizeof(struct net_dm_alert_msg);
+	al += dm_hit_limit * sizeof(struct net_dm_drop_point);
+
+
+	/*
+	 * Grab the skb we're about to send
+	 */
+	skb = data->skb;
+
+	/*
+	 * Replace it with a new one
+	 */
+	nskb = alloc_skb(al, GFP_KERNEL);
+	nlh = (struct nlmsghdr *)nskb->data;
+	memset(nlh, 0, sizeof(struct nlmsghdr));
+	nlh->nlmsg_type = NET_DM_ALERT;
+	msg = NLMSG_DATA(nlh);
+	memset(msg, 0, al);
+	skb_put(nskb, sizeof(struct net_dm_alert_msg));
+	skb_put(nskb, sizeof(struct nlmsghdr));
+
+	data->skb = nskb;
+
+	/*
+	 * Make sure to fix up the length field on the nlmsghdr
+	 */
+	nlh = (struct nlmsghdr *)skb->data;
+	msg = NLMSG_DATA(nlh);
+
+	size = sizeof(struct nlmsghdr) + sizeof (struct net_dm_alert_msg);
+	size += msg->entries * sizeof(struct net_dm_drop_point);
+	nlh->nlmsg_len = NLMSG_LENGTH(size);
+
+	/*
+	 * And adjust the skb if we need to
+	 */
+	if (nlh->nlmsg_len > size)
+		skb_put(skb, (nlh->nlmsg_len-size));
+
+	/*
+	 * Ship it!
+	 */
+	NETLINK_CB(skb).dst_group =  NET_DM_GRP_ALERTS;
+	spin_lock(&send_lock);
+        netlink_broadcast(dm_sock, skb, 0, NET_DM_GRP_ALERTS, 0);
+	spin_unlock(&send_lock);
+
+	/*
+	 * Reset the per_cpu counter.  This unlocks the trace point
+	 * So that we can collect for subsequent drops
+	 */
+	atomic_set(&data->dm_hit_count, dm_hit_limit);
+	
+}
+
+static void sched_send_work(unsigned long unused)
+{
+	struct per_cpu_dm_data *data =  &__get_cpu_var(dm_cpu_data);
+
+	schedule_work(&data->dm_alert_work);
+}
+
+static void trace_kfree_skb_hit(struct sk_buff *skb, void *location)
+{
+	struct net_dm_alert_msg *msg;
+	struct nlmsghdr *nlh;
+	int i;
+	struct per_cpu_dm_data *data = &__get_cpu_var(dm_cpu_data);
+
+	
+	if (!atomic_add_unless(&data->dm_hit_count, -1, 0)) {
+		/*
+		 * we're already at zero, discard this hit
+		 */
+		goto out;
+	}
+
+	nlh = (struct nlmsghdr *)data->skb->data;
+	msg = NLMSG_DATA(nlh);
+	for (i=0; i < msg->entries; i++) {
+		if (!memcmp(&location, msg->points[i].pc, sizeof(void *))) {
+			msg->points[i].count++;
+			goto out;
+		}
+	}
+
+	/*
+	 * We need to create a new entry
+	 */
+	skb_put(data->skb, sizeof(struct net_dm_drop_point));
+	memcpy(msg->points[msg->entries].pc, &location, sizeof(void *));
+	msg->points[msg->entries].count = 1;
+	msg->entries++;
+
+	if (!timer_pending(&data->send_timer)) {
+		data->send_timer.expires = jiffies + dm_delay * HZ;
+		add_timer_on(&data->send_timer, smp_processor_id());
+	}
+
+out:
+	return;
+}
+
+static int set_all_monitor_traces(int state)
+{
+	int rc = 0;
+
+	switch (state) {
+	case TRACE_ON:
+		rc |= register_trace_kfree_skb(trace_kfree_skb_hit);
+		break;
+	case TRACE_OFF:
+		rc |= unregister_trace_kfree_skb(trace_kfree_skb_hit);
+
+		tracepoint_synchronize_unregister();
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
+static int dropmon_handle_msg(struct sk_buff *skb,
+			unsigned char type, unsigned int len)
+{
+	struct nlmsghdr *nlh = (struct nlmsghdr *)skb->data;
+	int status = 0;
+
+	switch (type) {
+		case NET_DM_START:
+			set_all_monitor_traces(TRACE_ON);
+			break;
+		case NET_DM_STOP:
+			set_all_monitor_traces(TRACE_OFF);
+			break;
+		case NET_DM_CONFIG:
+			/*
+			 * This is just a placeholder until 
+			 * this protocol has something to configure
+			 */
+			netlink_ack(skb, nlh, -ENOTSUPP);
+			break;
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
+	type = nlh->nlmsg_type;
+
+	if (pid != 0)
+		return;
+
+	if (!(flags & NLM_F_REQUEST))
+		RCV_SKB_FAIL(-ECOMM);
+
+
+	if (type <= NET_DM_BASE)
+		return;
+
+	if (type >= NET_DM_MAX)
+		RCV_SKB_FAIL(-EINVAL);
+
+
+	status = dropmon_handle_msg(skb, type,
+				  nlmsglen - NLMSG_LENGTH(0));
+	if (status < 0)
+		RCV_SKB_FAIL(status);
+
+	if (flags & NLM_F_ACK)
+		netlink_ack(skb, nlh, 0);
+	return;
+}
+
+static int __init init_net_drop_monitor(void)
+{
+	int cpu;
+	size_t al;
+	struct net_dm_alert_msg *msg;
+	struct nlmsghdr *nlh;
+	struct per_cpu_dm_data *data;
+	printk(KERN_INFO "Initalizing network drop monitor service\n");
+
+	if (sizeof(void *) > 8) {
+		printk(KERN_ERR "Unable to store program counters on this arch, Drop monitor failed\n");
+		return -ENOSPC;
+	}
+
+	dm_sock = netlink_kernel_create(&init_net, NETLINK_DRPMON, NET_DM_GRP_ALERTS,
+					drpmon_rcv, NULL, THIS_MODULE);
+
+	if (dm_sock == NULL) {
+		printk(KERN_ERR "Could not create drop monitor socket\n");
+		return -ENOMEM;
+	}
+
+	al = sizeof(struct nlmsghdr);
+	al += sizeof(struct net_dm_alert_msg);
+	al += dm_hit_limit * sizeof(struct net_dm_drop_point);
+
+	for_each_present_cpu(cpu) {
+		data = &per_cpu(dm_cpu_data, cpu);
+		data->skb = alloc_skb(al, GFP_KERNEL);	
+		skb_put(data->skb, sizeof(struct nlmsghdr));
+		skb_put(data->skb, sizeof(struct net_dm_alert_msg));
+		nlh = (struct nlmsghdr *)data->skb->data;
+		memset(nlh, 0, sizeof(struct nlmsghdr));
+		nlh->nlmsg_type = NET_DM_ALERT;
+		msg = NLMSG_DATA(nlh);
+		memset(msg, 0, al);
+		INIT_WORK(&data->dm_alert_work, send_dm_alert);
+		atomic_set(&data->dm_hit_count, dm_hit_limit);
+		init_timer(&data->send_timer);
+		data->send_timer.data = cpu;
+		data->send_timer.function = sched_send_work;
+	}
+
+	return 0;
+}
+
+subsys_initcall(init_net_drop_monitor);
