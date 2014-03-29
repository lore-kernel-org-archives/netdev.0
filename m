From: David Decotigny <decot@googlers.com>
Subject: [PATCH net-next v2] net-sysfs: expose number of carrier on/off changes
Date: Sat, 29 Mar 2014 09:48:35 -0700
Message-ID: <2fd338e34d809af14353a03bc1edd0935f332faf.1396111568.git.decot@googlers.com>
References: <cover.1396111568.git.decot@googlers.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Eric Dumazet <edumazet@google.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Weilong Chen <chenweilong@huawei.com>,
	Jiri Pirko <jiri@resnulli.us>, Amir Vadai <amirv@mellanox.com>,
	Michael Dalton <mwdalton@google.com>,
	David Decotigny <decot@googlers.com>,
	Al Viro <viro@ZenIV.linux.org.uk>, Tejun Heo <tj@kernel.org>
To: "David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f74.google.com ([209.85.213.74]:48262 "EHLO
	mail-yh0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751810AbaC2QyP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Mar 2014 12:54:15 -0400
Received: by mail-yh0-f74.google.com with SMTP id f10so875829yha.5
        for <netdev@vger.kernel.org>; Sat, 29 Mar 2014 09:54:15 -0700 (PDT)
In-Reply-To: <cover.1396111568.git.decot@googlers.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This allows to monitor carrier on/off transitions and detect link
flapping issues:
 - new /sys/class/net/X/carrier_changes
 - new rtnetlink IFLA_CARRIER_CHANGES (getlink)

Tested:
  - grep . /sys/class/net/*/carrier_changes
    + ip link set dev X down/up
    + plug/unplug cable
  - updated iproute2: prints IFLA_CARRIER_CHANGES
  - iproute2 20121211-2 (debian): unchanged behavior

Signed-off-by: David Decotigny <decot@googlers.com>
---
 include/linux/netdevice.h    |  3 +++
 include/uapi/linux/if_link.h |  1 +
 net/core/net-sysfs.c         | 11 +++++++++++
 net/core/rtnetlink.c         |  6 +++++-
 net/sched/sch_generic.c      |  2 ++
 5 files changed, 22 insertions(+), 1 deletion(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 159c7e7..feb60c0 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1316,6 +1316,9 @@ struct net_device {
 	atomic_long_t		rx_dropped;
 	atomic_long_t		tx_dropped;
 
+	/* Stats to monitor carrier on<->off transitions */
+	atomic_t		carrier_changes;
+
 #ifdef CONFIG_WIRELESS_EXT
 	/* List of functions to handle Wireless Extensions (instead of ioctl).
 	 * See <net/iw_handler.h> for details. Jean II */
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 16410b6..9a7f7ac 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -144,6 +144,7 @@ enum {
 	IFLA_NUM_RX_QUEUES,
 	IFLA_CARRIER,
 	IFLA_PHYS_PORT_ID,
+	IFLA_CARRIER_CHANGES,
 	__IFLA_MAX
 };
 
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index daed9a6..4623962 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -253,6 +253,16 @@ static ssize_t operstate_show(struct device *dev,
 }
 static DEVICE_ATTR_RO(operstate);
 
+static ssize_t carrier_changes_show(struct device *dev,
+				    struct device_attribute *attr,
+				    char *buf)
+{
+	struct net_device *netdev = to_net_dev(dev);
+	return sprintf(buf, fmt_dec,
+		       atomic_read(&netdev->carrier_changes));
+}
+static DEVICE_ATTR_RO(carrier_changes);
+
 /* read-write attributes */
 
 static int change_mtu(struct net_device *net, unsigned long new_mtu)
@@ -386,6 +396,7 @@ static struct attribute *net_class_attrs[] = {
 	&dev_attr_duplex.attr,
 	&dev_attr_dormant.attr,
 	&dev_attr_operstate.attr,
+	&dev_attr_carrier_changes.attr,
 	&dev_attr_ifalias.attr,
 	&dev_attr_carrier.attr,
 	&dev_attr_mtu.attr,
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index e7c6006..d4ff417 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -822,6 +822,7 @@ static noinline size_t if_nlmsg_size(const struct net_device *dev,
 	       + nla_total_size(4) /* IFLA_NUM_RX_QUEUES */
 	       + nla_total_size(1) /* IFLA_OPERSTATE */
 	       + nla_total_size(1) /* IFLA_LINKMODE */
+	       + nla_total_size(4) /* IFLA_CARRIER_CHANGES */
 	       + nla_total_size(ext_filter_mask
 			        & RTEXT_FILTER_VF ? 4 : 0) /* IFLA_NUM_VF */
 	       + rtnl_vfinfo_size(dev, ext_filter_mask) /* IFLA_VFINFO_LIST */
@@ -970,7 +971,9 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 	    (dev->qdisc &&
 	     nla_put_string(skb, IFLA_QDISC, dev->qdisc->ops->id)) ||
 	    (dev->ifalias &&
-	     nla_put_string(skb, IFLA_IFALIAS, dev->ifalias)))
+	     nla_put_string(skb, IFLA_IFALIAS, dev->ifalias)) ||
+	    nla_put_u32(skb, IFLA_CARRIER_CHANGES,
+			atomic_read(&dev->carrier_changes)))
 		goto nla_put_failure;
 
 	if (1) {
@@ -1147,6 +1150,7 @@ static const struct nla_policy ifla_policy[IFLA_MAX+1] = {
 	[IFLA_NUM_TX_QUEUES]	= { .type = NLA_U32 },
 	[IFLA_NUM_RX_QUEUES]	= { .type = NLA_U32 },
 	[IFLA_PHYS_PORT_ID]	= { .type = NLA_BINARY, .len = MAX_PHYS_PORT_ID_LEN },
+	[IFLA_CARRIER_CHANGES]	= { .type = NLA_U32 },  /* ignored */
 };
 
 static const struct nla_policy ifla_info_policy[IFLA_INFO_MAX+1] = {
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index e82e43b..e1543b0 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -310,6 +310,7 @@ void netif_carrier_on(struct net_device *dev)
 	if (test_and_clear_bit(__LINK_STATE_NOCARRIER, &dev->state)) {
 		if (dev->reg_state == NETREG_UNINITIALIZED)
 			return;
+		atomic_inc(&dev->carrier_changes);
 		linkwatch_fire_event(dev);
 		if (netif_running(dev))
 			__netdev_watchdog_up(dev);
@@ -328,6 +329,7 @@ void netif_carrier_off(struct net_device *dev)
 	if (!test_and_set_bit(__LINK_STATE_NOCARRIER, &dev->state)) {
 		if (dev->reg_state == NETREG_UNINITIALIZED)
 			return;
+		atomic_inc(&dev->carrier_changes);
 		linkwatch_fire_event(dev);
 	}
 }
-- 
1.9.1.423.g4596e3a
