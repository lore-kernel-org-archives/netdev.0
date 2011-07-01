From: David Lamparter <equinox@diac24.net>
Subject: [PATCH] bridge: revisit IEEE 802 local multicast groups
Date: Fri,  1 Jul 2011 13:12:50 +0200
Message-ID: <1309518770-8547-1-git-send-email-equinox@diac24.net>
Cc: netdev@vger.kernel.org, Nick Carter <ncarter100@gmail.com>,
	David Lamparter <equinox@diac24.net>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:57755 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754793Ab1GALNX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Jul 2011 07:13:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

this first and foremost fixes handling of bonding frames, which were
incorrectly forwarded until now. they need to never cross a bridge.

it also introduces a new switch to control handling of the other
not-that-special groups; if you want them forwarded despite having
STP running, there's a sysfs knob for that. you can implement your
local policy with ebtables then.

in the end, we now match hardware switch behaviour rather closely, but
still additionally allow playing tricks on things like 802.1X.

Signed-off-by: David Lamparter <equinox@diac24.net>
Cc: Stephen Hemminger <shemminger@linux-foundation.org>
Cc: Nick Carter <ncarter100@gmail.com>
---
 net/bridge/br_device.c   |    1 +
 net/bridge/br_input.c    |   25 ++++++++++++++++++-------
 net/bridge/br_private.h  |    2 ++
 net/bridge/br_sysfs_br.c |   24 ++++++++++++++++++++++++
 4 files changed, 45 insertions(+), 7 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index c188c80..4a01a3e 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -359,6 +359,7 @@ void br_dev_setup(struct net_device *dev)
 	memcpy(br->group_addr, br_group_address, ETH_ALEN);
 
 	br->stp_enabled = BR_NO_STP;
+	br->stp_forward_802local = 0;
 	br->designated_root = br->bridge_id;
 	br->bridge_max_age = br->max_age = 20 * HZ;
 	br->bridge_hello_time = br->hello_time = 2 * HZ;
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index f3ac1e8..0060b10 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -160,13 +160,24 @@ rx_handler_result_t br_handle_frame(struct sk_buff **pskb)
 	p = br_port_get_rcu(skb->dev);
 
 	if (unlikely(is_link_local(dest))) {
-		/* Pause frames shouldn't be passed up by driver anyway */
-		if (skb->protocol == htons(ETH_P_PAUSE))
-			goto drop;
-
-		/* If STP is turned off, then forward */
-		if (p->br->stp_enabled == BR_NO_STP && dest[5] == 0)
-			goto forward;
+		switch (dest[5]) {
+		/* Pause/3x frames shouldn't be passed up by driver anyway
+		 * LACP/3ad can never be allowed to cross even a dumb hub
+		 */
+		case 0x01:	/* pause */
+		case 0x02:	/* bonding */
+			break;
+
+		case 0x00:	/* STP */
+			if (p->br->stp_enabled == BR_NO_STP)
+				goto forward;
+			break;
+
+		default:
+			if (p->br->stp_enabled == BR_NO_STP
+					|| p->br->stp_forward_802local)
+				goto forward;
+		}
 
 		if (NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_IN, skb, skb->dev,
 			    NULL, br_handle_local_finish)) {
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 54578f2..909814f 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -213,6 +213,8 @@ struct net_bridge
 		BR_USER_STP,		/* new RSTP in userspace */
 	} stp_enabled;
 
+	bool				stp_forward_802local;
+
 	unsigned char			topology_change;
 	unsigned char			topology_change_detected;
 
diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
index 68b893e..8004bf7 100644
--- a/net/bridge/br_sysfs_br.c
+++ b/net/bridge/br_sysfs_br.c
@@ -149,6 +149,29 @@ static ssize_t store_stp_state(struct device *d,
 static DEVICE_ATTR(stp_state, S_IRUGO | S_IWUSR, show_stp_state,
 		   store_stp_state);
 
+static ssize_t show_stp_forward_802local(struct device *d,
+					 struct device_attribute *attr,
+					 char *buf)
+{
+	struct net_bridge *br = to_bridge(d);
+	return sprintf(buf, "%d\n", br->stp_forward_802local);
+}
+
+static int set_stp_forward_802local(struct net_bridge *br, unsigned long val)
+{
+	br->stp_forward_802local = !!val;
+	return 0;
+}
+
+static ssize_t store_stp_forward_802local(struct device *d,
+					  struct device_attribute *attr,
+					  const char *buf, size_t len)
+{
+	return store_bridge_parm(d, buf, len, set_stp_forward_802local);
+}
+static DEVICE_ATTR(stp_forward_802local, S_IRUGO | S_IWUSR,
+		   show_stp_forward_802local, store_stp_forward_802local);
+
 static ssize_t show_priority(struct device *d, struct device_attribute *attr,
 			     char *buf)
 {
@@ -652,6 +675,7 @@ static struct attribute *bridge_attrs[] = {
 	&dev_attr_max_age.attr,
 	&dev_attr_ageing_time.attr,
 	&dev_attr_stp_state.attr,
+	&dev_attr_stp_forward_802local.attr,
 	&dev_attr_priority.attr,
 	&dev_attr_bridge_id.attr,
 	&dev_attr_root_id.attr,
-- 
1.7.5.3

