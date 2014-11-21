From: roopa@cumulusnetworks.com
Subject: [RFC PATCH 4/4] bridge: make hw offload conditional on bridge and bridge port offload flags
Date: Fri, 21 Nov 2014 14:49:30 -0800
Message-ID: <1416610170-21224-5-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shrijeet@cumulusnetworks.com, gospo@cumulusnetworks.com,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: jiri@resnulli.us, sfeldma@gmail.com, jhs@mojatatu.com,
	bcrl@kvack.org, tgraf@suug.ch, john.fastabend@gmail.com,
	stephen@networkplumber.org, linville@tuxdriver.com,
	nhorman@tuxdriver.com, nicolas.dichtel@6wind.com,
	vyasevic@redhat.com, f.fainelli@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:36892 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752050AbaKUWtm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 17:49:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

If bridge has NETIF_F_HW_OFFLOAD feature flag set, offload all bridge and
bridge port attributes to hardware.

Two new flags BRPORT_KERNEL and BRPORT_HW_OFFLOAD to control offloading of
a few bridge port flags to hardware. These can be encoded in the upper bits
of all bridge port flag netlink attributes.

Control/Override bridge port flag (learning, flooding etc) offloading
with BRPORT_KERNEL and BRPORT_HW_OFFLOAD flags:
    If the brport offload flags are not present (current default)
	    - set bridge port flag attribute only in the kernel
    else:
        if BRPORT_KERNEL and BRPORT_HW_OFFLOAD:
            - set bridge port flag both in kernel and hw
        elif BRPORT_KERNEL:
            - set bridge port flag attribute only in kernel
        elif BRPORT_HW_OFFLOAD:
            - set bridge port flag attribute only in hw

The 'gets' needs more work. The idea is that the gets can also be controlled
by the KERNEL or HW_OFFLOAD flags.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 net/bridge/br_netlink.c |   50 +++++++++++++++++++++++++++++++++++++----------
 net/bridge/br_private.h |    2 ++
 net/bridge/br_stp.c     |    9 ++++++---
 net/bridge/br_stp_if.c  |    8 ++++++--
 4 files changed, 54 insertions(+), 15 deletions(-)

diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 13fecf1..e92e810 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -57,12 +57,19 @@ static int br_port_fill_attrs(struct sk_buff *skb,
 	    nla_put_u16(skb, IFLA_BRPORT_PRIORITY, p->priority) ||
 	    nla_put_u32(skb, IFLA_BRPORT_COST, p->path_cost) ||
 	    nla_put_u8(skb, IFLA_BRPORT_MODE, mode) ||
-	    nla_put_u8(skb, IFLA_BRPORT_GUARD, !!(p->flags & BR_BPDU_GUARD)) ||
-	    nla_put_u8(skb, IFLA_BRPORT_PROTECT, !!(p->flags & BR_ROOT_BLOCK)) ||
-	    nla_put_u8(skb, IFLA_BRPORT_FAST_LEAVE, !!(p->flags & BR_MULTICAST_FAST_LEAVE)) ||
-	    nla_put_u8(skb, IFLA_BRPORT_LEARNING, !!(p->flags & BR_LEARNING)) ||
-	    nla_put_u8(skb, IFLA_BRPORT_UNICAST_FLOOD, !!(p->flags & BR_FLOOD)) ||
-	    nla_put_u8(skb, IFLA_BRPORT_PROXYARP, !!(p->flags & BR_PROXYARP)))
+	    nla_put_u8(skb, IFLA_BRPORT_GUARD,
+		           br_get_port_flag(p, IFLA_BRPORT_GUARD, BR_BPDU_GUARD)) ||
+	    nla_put_u8(skb, IFLA_BRPORT_PROTECT,
+	               br_get_port_flag(p, IFLA_BRPORT_PROTECT, BR_ROOT_BLOCK)) ||
+	    nla_put_u8(skb, IFLA_BRPORT_FAST_LEAVE,
+	               br_get_port_flag(p, IFLA_BRPORT_FAST_LEAVE,
+	               BR_MULTICAST_FAST_LEAVE)) ||
+	    nla_put_u8(skb, IFLA_BRPORT_LEARNING,
+	               br_get_port_flag(p, IFLA_BRPORT_LEARNING, BR_LEARNING)) ||
+	    nla_put_u8(skb, IFLA_BRPORT_UNICAST_FLOOD,
+			       br_get_port_flag(p, IFLA_UNICAST_FLOOD, BR_FLOOD)) ||
+	    nla_put_u8(skb, IFLA_BRPORT_PROXYARP, 
+	               br_get_port_flag(p, IFLA_UNICAST_FLOOD, BR_PROXYARP)))
 		return -EMSGSIZE;
 
 	return 0;
@@ -305,7 +312,9 @@ static int br_set_port_state(struct net_bridge_port *p, u8 state)
 
 	br_set_state(p, state);
 	br_log_state(p);
-	netdev_sw_port_stp_update(p->dev, p->state);
+
+	if (BR_HW_OFFLOAD(p->br))
+	    netdev_sw_port_set_attr(p->dev, IFLA_BRPORT_STATE, &p->state);
 	br_port_state_selection(p->br);
 	return 0;
 }
@@ -316,13 +325,34 @@ static void br_set_port_flag(struct net_bridge_port *p, struct nlattr *tb[],
 {
 	if (tb[attrtype]) {
 		u8 flag = nla_get_u8(tb[attrtype]);
-		if (flag)
-			p->flags |= mask;
-		else
+		if (flag) {
+			flag_upper = flag & 0xf0
+			if (!flag_upper || (flag_upper & BRPORT_KERNEL))
+				p->flags |= mask;
+			if ((flag_upper & BRPORT_HW_OFFLOAD) ||
+				(BR_HW_OFFLOAD(p->br)))
+				/* Also set the port flag in hw */
+			netdev_sw_port_set_attr(p->dev, attrtype, 1);
+		} else {
 			p->flags &= ~mask;
+			if (BR_HW_OFFLOAD(p->br))
+				netdev_sw_port_set_attr(p->dev, attrtype, 0);
+		}
 	}
 }
 
+/* Set/clear or port flags based on attribute */
+static u8 br_get_port_flag(struct net_bridge_port *p,
+			   int attrtype, u8 flag)
+{
+	attrvalue = !!(p->flags & flag)
+	if (attrvalue)
+		attrvalue |= BRPORT_KERNEL
+	if (netdev_sw_port_get_flag(p->dev, attrtype))
+		attrvalue |= BRPORT_HW_OFFLOAD
+	return attrvalue;
+}
+
 /* Process bridge protocol info on port */
 static int br_setport(struct net_bridge_port *p, struct nlattr *tb[])
 {
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 8f3f081..3ebd196 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -41,6 +41,8 @@
 /* Path to usermode spanning tree program */
 #define BR_STP_PROG	"/sbin/bridge-stp"
 
+#define BR_HW_OFFLOAD(br) !!(br->dev->features & NETIF_F_HW_OFFLOAD)
+
 typedef struct bridge_id bridge_id;
 typedef struct mac_addr mac_addr;
 typedef __u16 port_id;
diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
index c00139b..bb61dc0 100644
--- a/net/bridge/br_stp.c
+++ b/net/bridge/br_stp.c
@@ -115,7 +115,8 @@ static void br_root_port_block(const struct net_bridge *br,
 
 	br_set_state(p, BR_STATE_LISTENING);
 	br_log_state(p);
-	netdev_sw_port_stp_update(p->dev, p->state);
+	if (BR_HW_OFFLOAD(p->br))
+	    netdev_sw_port_set_attr(p->dev, IFLA_BRPORT_STATE, &p->state);
 	br_ifinfo_notify(RTM_NEWLINK, p);
 
 	if (br->forward_delay > 0)
@@ -396,7 +397,8 @@ static void br_make_blocking(struct net_bridge_port *p)
 
 		br_set_state(p, BR_STATE_BLOCKING);
 		br_log_state(p);
-		netdev_sw_port_stp_update(p->dev, p->state);
+		if (BR__HW_OFFLOAD(p->br))
+	        netdev_sw_port_set_attr(p->dev, IFLA_BRPORT_STATE, &p->state);
 		br_ifinfo_notify(RTM_NEWLINK, p);
 
 		del_timer(&p->forward_delay_timer);
@@ -422,7 +424,8 @@ static void br_make_forwarding(struct net_bridge_port *p)
 
 	br_multicast_enable_port(p);
 	br_log_state(p);
-	netdev_sw_port_stp_update(p->dev, p->state);
+	if (BR_OFFLOAD(p->br))
+	    netdev_sw_port_set_attr(p->dev, IFLA_BRPORT_STATE, &p->state);
 	br_ifinfo_notify(RTM_NEWLINK, p);
 
 	if (br->forward_delay != 0)
diff --git a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
index 91279f8..8435b4d 100644
--- a/net/bridge/br_stp_if.c
+++ b/net/bridge/br_stp_if.c
@@ -90,7 +90,8 @@ void br_stp_enable_port(struct net_bridge_port *p)
 	br_init_port(p);
 	br_port_state_selection(p->br);
 	br_log_state(p);
-	netdev_sw_port_stp_update(p->dev, p->state);
+	if (BR_HW_OFFLOAD(p->br))
+	    netdev_sw_port_set_attr(p->dev, IFLA_BRPORT_STATE, &p->state);
 	br_ifinfo_notify(RTM_NEWLINK, p);
 }
 
@@ -107,7 +108,8 @@ void br_stp_disable_port(struct net_bridge_port *p)
 	p->config_pending = 0;
 
 	br_log_state(p);
-	netdev_sw_port_stp_update(p->dev, p->state);
+	if (BR_HW_OFFLOAD(p->br))
+	    netdev_sw_port_set_attr(p->dev, IFLA_BRPORT_STATE, &p->state);
 	br_ifinfo_notify(RTM_NEWLINK, p);
 
 	del_timer(&p->message_age_timer);
@@ -290,6 +292,8 @@ int br_stp_set_port_priority(struct net_bridge_port *p, unsigned long newprio)
 		br_become_designated_port(p);
 		br_port_state_selection(p->br);
 	}
+	if (BR_HW_OFFLOAD(p->br))
+	    netdev_sw_port_set_attr(p->dev, IFLA_BRPORT_PRIORITY, &newprio)
 
 	return 0;
 }
-- 
1.7.10.4
