From: roopa@cumulusnetworks.com
Subject: [RFC PATCH net-next] bridge: ability to disable forwarding on a port
Date: Fri, 16 Jan 2015 23:32:55 -0800
Message-ID: <1421479975-62049-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, wkok@cumulusnetworks.com,
	gospo@cumulusnetworks.com
To: stephen@networkplumber.org, davem@davemloft.net, jhs@mojatatu.com,
	sfeldma@gmail.com, jiri@resnulli.us, ronen.arad@intel.com,
	tgraf@suug.ch, john.fastabend@gmail.com, vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:39846 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751135AbbAQHdB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Jan 2015 02:33:01 -0500
Received: by mail-pa0-f47.google.com with SMTP id kq14so28660840pab.6
        for <netdev@vger.kernel.org>; Fri, 16 Jan 2015 23:33:00 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

On a Linux bridge with bridge forwarding offloaded to a switch ASIC,
there is a need to not re-forward the frames that come up to the
kernel in software.

Typically these are broadcast or multicast packets forwarded by the
hardware to multiple destination ports including sending a copy of
the packet to the kernel (e.g. an arp broadcast).
The bridge driver will try to forward the packet again, resulting in
two copies of the same packet.

These packets can also come up to the kernel for logging when they hit
a LOG acl in hardware.

This patch makes forwarding a flag on the port similar to
learn and flood and drops the packet just before forwarding.
(The forwarding disable on a bridge is tested to work on our boxes.
The bridge port flag addition is only compile tested.
This will need to be further refined to cover cases where a non-switch port
is bridged to a switch port etc. We will submit more patches to cover
all cases if we agree on this approach).

Other ways to solve the same problem could be to:
- use the offload feature flag on these switch ports to avoid the
re-forward:
https://www.marc.info/?l=linux-netdev&m=141820235010603&w=2

- Or the switch driver can mark or set a flag in the skb, which the bridge
driver can use to avoid a re-forward.

Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 include/linux/if_bridge.h    |    3 ++-
 include/uapi/linux/if_link.h |    1 +
 net/bridge/br_forward.c      |   13 +++++++++++++
 net/bridge/br_if.c           |    2 +-
 net/bridge/br_netlink.c      |    4 +++-
 net/bridge/br_sysfs_if.c     |    1 +
 net/core/rtnetlink.c         |    4 +++-
 7 files changed, 24 insertions(+), 4 deletions(-)

diff --git a/include/linux/if_bridge.h b/include/linux/if_bridge.h
index 0a8ce76..c79f4eb 100644
--- a/include/linux/if_bridge.h
+++ b/include/linux/if_bridge.h
@@ -40,10 +40,11 @@ struct br_ip_list {
 #define BR_ADMIN_COST		BIT(4)
 #define BR_LEARNING		BIT(5)
 #define BR_FLOOD		BIT(6)
-#define BR_AUTO_MASK		(BR_FLOOD | BR_LEARNING)
 #define BR_PROMISC		BIT(7)
 #define BR_PROXYARP		BIT(8)
 #define BR_LEARNING_SYNC	BIT(9)
+#define BR_FORWARD		BIT(10)
+#define BR_AUTO_MASK		(BR_FLOOD | BR_LEARNING | BR_FORWARD)
 
 extern void brioctl_set(int (*ioctl_hook)(struct net *, unsigned int, void __user *));
 
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index f7d0d2d..d394625 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -246,6 +246,7 @@ enum {
 	IFLA_BRPORT_UNICAST_FLOOD, /* flood unicast traffic */
 	IFLA_BRPORT_PROXYARP,	/* proxy ARP */
 	IFLA_BRPORT_LEARNING_SYNC, /* mac learning sync from device */
+	IFLA_BRPORT_FORWARD,	/* enable forwarding on a device */
 	__IFLA_BRPORT_MAX
 };
 #define IFLA_BRPORT_MAX (__IFLA_BRPORT_MAX - 1)
diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index f96933a..98c41c8 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -81,10 +81,23 @@ static void __br_deliver(const struct net_bridge_port *to, struct sk_buff *skb)
 		br_forward_finish);
 }
 
+int br_hw_forward_finish(struct sk_buff *skb)
+{
+	kfree_skb(skb);
+
+	return 0;
+}
+
 static void __br_forward(const struct net_bridge_port *to, struct sk_buff *skb)
 {
 	struct net_device *indev;
 
+	if (!(to->flags & BR_FORWARD)) {
+		NF_HOOK(NFPROTO_BRIDGE, NF_BR_FORWARD, skb, skb->dev, to->dev,
+			br_hw_forward_finish);
+		return;
+	}
+
 	if (skb_warn_if_lro(skb)) {
 		kfree_skb(skb);
 		return;
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index ed307db..c14360b 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -330,7 +330,7 @@ static struct net_bridge_port *new_nbp(struct net_bridge *br,
 	p->path_cost = port_cost(dev);
 	p->priority = 0x8000 >> BR_PORT_BITS;
 	p->port_no = index;
-	p->flags = BR_LEARNING | BR_FLOOD;
+	p->flags = BR_LEARNING | BR_FLOOD | BR_FORWARD;
 	br_init_port(p);
 	br_set_state(p, BR_STATE_DISABLED);
 	br_stp_port_timer_init(p);
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 9f5eb55..2d96033 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -61,7 +61,8 @@ static int br_port_fill_attrs(struct sk_buff *skb,
 	    nla_put_u8(skb, IFLA_BRPORT_FAST_LEAVE, !!(p->flags & BR_MULTICAST_FAST_LEAVE)) ||
 	    nla_put_u8(skb, IFLA_BRPORT_LEARNING, !!(p->flags & BR_LEARNING)) ||
 	    nla_put_u8(skb, IFLA_BRPORT_UNICAST_FLOOD, !!(p->flags & BR_FLOOD)) ||
-	    nla_put_u8(skb, IFLA_BRPORT_PROXYARP, !!(p->flags & BR_PROXYARP)))
+	    nla_put_u8(skb, IFLA_BRPORT_PROXYARP, !!(p->flags & BR_PROXYARP)) ||
+	    nla_put_u8(skb, IFLA_BRPORT_FORWARD, !!(p->flags & BR_FORWARD)))
 		return -EMSGSIZE;
 
 	return 0;
@@ -335,6 +336,7 @@ static int br_setport(struct net_bridge_port *p, struct nlattr *tb[])
 	br_set_port_flag(p, tb, IFLA_BRPORT_LEARNING, BR_LEARNING);
 	br_set_port_flag(p, tb, IFLA_BRPORT_UNICAST_FLOOD, BR_FLOOD);
 	br_set_port_flag(p, tb, IFLA_BRPORT_PROXYARP, BR_PROXYARP);
+	br_set_port_flag(p, tb, IFLA_BRPORT_FORWARD, BR_FORWARD);
 
 	if (tb[IFLA_BRPORT_COST]) {
 		err = br_stp_set_path_cost(p, nla_get_u32(tb[IFLA_BRPORT_COST]));
diff --git a/net/bridge/br_sysfs_if.c b/net/bridge/br_sysfs_if.c
index 2de5d91..271e9ab 100644
--- a/net/bridge/br_sysfs_if.c
+++ b/net/bridge/br_sysfs_if.c
@@ -171,6 +171,7 @@ BRPORT_ATTR_FLAG(root_block, BR_ROOT_BLOCK);
 BRPORT_ATTR_FLAG(learning, BR_LEARNING);
 BRPORT_ATTR_FLAG(unicast_flood, BR_FLOOD);
 BRPORT_ATTR_FLAG(proxyarp, BR_PROXYARP);
+BRPORT_ATTR_FLAG(forward, BR_FORWARD);
 
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 static ssize_t show_multicast_router(struct net_bridge_port *p, char *buf)
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index d06107d..e6a93eb 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2785,7 +2785,9 @@ int ndo_dflt_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 	    brport_nla_put_flag(skb, flags, mask,
 				IFLA_BRPORT_UNICAST_FLOOD, BR_FLOOD) ||
 	    brport_nla_put_flag(skb, flags, mask,
-				IFLA_BRPORT_PROXYARP, BR_PROXYARP)) {
+				IFLA_BRPORT_PROXYARP, BR_PROXYARP) ||
+	    brport_nla_put_flag(skb, flags, mask,
+				IFLA_BRPORT_FORWARD, BR_FORWARD)) {
 		nla_nest_cancel(skb, protinfo);
 		goto nla_put_failure;
 	}
-- 
1.7.10.4
