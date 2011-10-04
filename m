From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/2] bridge: allow forwarding some link local frames
Date: Mon, 03 Oct 2011 21:14:46 -0700
Message-ID: <20111004041509.292932641@vyatta.com>
References: <20111004041444.793960297@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sfca-50.vyatta.com ([76.74.103.50]:33110 "EHLO fiji.vyatta.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751075Ab1JDEQw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Oct 2011 00:16:52 -0400
Content-Disposition: inline; filename=bridge-multicast-filter.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is based on an earlier patch by Nick Carter with comments
by David Lamparter but with some refinements. Thanks for their patience
this is a confusing area with overlap of standards, user requirements,
and compatibility with earlier releases.

It adds a new sysfs attribute 
   /sys/class/net/brX/bridge/group_fwd_mask
that controls forwarding of frames with address of: 01-80-C2-00-00-0X
The default setting has no forwarding to retain compatibility.

One change from earlier releases is that forwarding of group
addresses is not dependent on STP being enabled or disabled. This
choice was made based on interpretation of tie 802.1 standards.
I expect complaints will arise because of this, but better to follow
the standard than continue acting incorrectly by default.

The filtering mask is writeable, but only values that don't forward
known control frames are allowed. It intentionally blocks attempts
to filter control protocols. For example: writing a 8 allows
forwarding 802.1X PAE addresses which is the most common request.

Reported-by: David Lamparter <equinox@diac24.net>
Original-patch-by: Nick Carter <ncarter100@gmail.com>
Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 net/bridge/br_device.c   |    2 ++
 net/bridge/br_input.c    |   12 ++++++------
 net/bridge/br_private.h  |   11 +++++++++++
 net/bridge/br_sysfs_br.c |   34 ++++++++++++++++++++++++++++++++++
 4 files changed, 53 insertions(+), 6 deletions(-)

--- a/net/bridge/br_device.c	2011-10-03 11:08:42.648254251 -0700
+++ b/net/bridge/br_device.c	2011-10-03 11:08:43.932271613 -0700
@@ -358,6 +358,8 @@ void br_dev_setup(struct net_device *dev
 	memcpy(br->group_addr, br_group_address, ETH_ALEN);
 
 	br->stp_enabled = BR_NO_STP;
+	br->group_fwd_mask = BR_GROUPFWD_DEFAULT;
+
 	br->designated_root = br->bridge_id;
 	br->bridge_max_age = br->max_age = 20 * HZ;
 	br->bridge_hello_time = br->hello_time = 2 * HZ;
--- a/net/bridge/br_input.c	2011-10-03 11:08:32.944122866 -0700
+++ b/net/bridge/br_input.c	2011-10-03 11:18:31.063811030 -0700
@@ -162,14 +162,37 @@ rx_handler_result_t br_handle_frame(stru
 	p = br_port_get_rcu(skb->dev);
 
 	if (unlikely(is_link_local(dest))) {
-		/* Pause frames shouldn't be passed up by driver anyway */
-		if (skb->protocol == htons(ETH_P_PAUSE))
+		/*
+		 * See IEEE 802.1D Table 7-10 Reserved addresses
+		 *
+		 * Assignment		 		Value
+		 * Bridge Group Address		01-80-C2-00-00-00
+		 * (MAC Control) 802.3		01-80-C2-00-00-01
+		 * (Link Aggregation) 802.3	01-80-C2-00-00-02
+		 * 802.1X PAE address		01-80-C2-00-00-03
+		 *
+		 * 802.1AB LLDP 		01-80-C2-00-00-0E
+		 *
+		 * Others reserved for future standardization
+		 */
+		switch (dest[5]) {
+		case 0x00:	/* Bridge Group Address */
+			/* If STP is turned off,
+			   then must forward to keep loop detection */
+			if (p->br->stp_enabled == BR_NO_STP)
+				goto forward;
+			break;
+
+		case 0x01:	/* IEEE MAC (Pause) */
 			goto drop;
 
-		/* If STP is turned off, then forward */
-		if (p->br->stp_enabled == BR_NO_STP && dest[5] == 0)
-			goto forward;
+		default:
+			/* Allow selective forwarding for most other protocols */
+			if (p->br->group_fwd_mask & (1u << dest[5]))
+				goto forward;
+		}
 
+		/* Deliver packet to local host only */
 		if (NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_IN, skb, skb->dev,
 			    NULL, br_handle_local_finish)) {
 			return RX_HANDLER_CONSUMED; /* consumed by filter */
--- a/net/bridge/br_private.h	2011-10-03 11:08:32.888122106 -0700
+++ b/net/bridge/br_private.h	2011-10-03 11:18:22.967713859 -0700
@@ -29,6 +29,11 @@
 
 #define BR_VERSION	"2.3"
 
+/* Control of forwarding link local multicast */
+#define BR_GROUPFWD_DEFAULT	0
+/* Don't allow forwarding control protocols like STP and LLDP */
+#define BR_GROUPFWD_RESTRICTED	0x4007u
+
 /* Path to usermode spanning tree program */
 #define BR_STP_PROG	"/sbin/bridge-stp"
 
@@ -193,6 +198,8 @@ struct net_bridge
 	unsigned long			flags;
 #define BR_SET_MAC_ADDR		0x00000001
 
+	u16				group_fwd_mask;
+
 	/* STP */
 	bridge_id			designated_root;
 	bridge_id			bridge_id;
--- a/net/bridge/br_sysfs_br.c	2011-10-03 11:08:32.920122541 -0700
+++ b/net/bridge/br_sysfs_br.c	2011-10-03 11:08:43.932271613 -0700
@@ -149,6 +149,39 @@ static ssize_t store_stp_state(struct de
 static DEVICE_ATTR(stp_state, S_IRUGO | S_IWUSR, show_stp_state,
 		   store_stp_state);
 
+static ssize_t show_group_fwd_mask(struct device *d,
+			      struct device_attribute *attr, char *buf)
+{
+	struct net_bridge *br = to_bridge(d);
+	return sprintf(buf, "%#x\n", br->group_fwd_mask);
+}
+
+
+static ssize_t store_group_fwd_mask(struct device *d,
+			       struct device_attribute *attr, const char *buf,
+			       size_t len)
+{
+	struct net_bridge *br = to_bridge(d);
+	char *endp;
+	unsigned long val;
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	val = simple_strtoul(buf, &endp, 0);
+	if (endp == buf)
+		return -EINVAL;
+
+	if (val & BR_GROUPFWD_RESTRICTED)
+		return -EINVAL;
+
+	br->group_fwd_mask = val;
+
+	return len;
+}
+static DEVICE_ATTR(group_fwd_mask, S_IRUGO | S_IWUSR, show_group_fwd_mask,
+		   store_group_fwd_mask);
+
 static ssize_t show_priority(struct device *d, struct device_attribute *attr,
 			     char *buf)
 {
@@ -652,6 +685,7 @@ static struct attribute *bridge_attrs[]
 	&dev_attr_max_age.attr,
 	&dev_attr_ageing_time.attr,
 	&dev_attr_stp_state.attr,
+	&dev_attr_group_fwd_mask.attr,
 	&dev_attr_priority.attr,
 	&dev_attr_bridge_id.attr,
 	&dev_attr_root_id.attr,
