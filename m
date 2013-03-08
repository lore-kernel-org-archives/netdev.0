From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [RFC PATCH v2 net-next 0/3] Allow bridge to function in non-promisc
 mode
Date: Fri, 08 Mar 2013 16:23:53 -0500
Message-ID: <513A56E9.2090708@redhat.com>
References: <1362691728-13289-1-git-send-email-vyasevic@redhat.com> <20130307214304.25e7784e@nehalam.linuxnetplumber.net> <513A0109.4040607@redhat.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090703030702040004030102"
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20568 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753631Ab3CHVX6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Mar 2013 16:23:58 -0500
In-Reply-To: <513A0109.4040607@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090703030702040004030102
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

On 03/08/2013 10:17 AM, Vlad Yasevich wrote:
> On 03/08/2013 12:43 AM, Stephen Hemminger wrote:
>> On Thu,  7 Mar 2013 16:28:45 -0500
>> Vlad Yasevich <vyasevic@redhat.com> wrote:
>>
>>> The series adds an ability to configure the bridge into a
>>> non-primiscuous
>>> mode.   Instead, it provides the ability to identitfy some set of bridge
>>> ports as uplinks and allows for MAC addresses to be programmed onto
>>> those ports.  In case the port hardware does not support mac filter,
>>> that port will be placed in promiscuous mode.
>>>
>>> Default bridge operation continues to remain as "promiscuous".  The new
>>> functionality has to be enabled via sysfs (similar to other bridge
>>> extensions).
>>>
>>> The uplink mode is implemented as a flag on a bridge port.  The api to
>>> change that flag follows the existing api to enable/disable other
>>> existing
>>> flags.
>>>
>>> All comments are welcome.
>>>
>>
>> Can we make this a one step process and less visible to the user.
>> If user defines an uplink device, and the uplink device is capable of
>> filtering
>> (and what ever other pre-conditions people can think of), then the
>> bridge will
>> transparently switch to uplink/non-promisc mode.  This can also be
>> used to trigger
>> edge only mode in RSTP in the future.
>>
>> Less knobs.
>>
>
> Ok.  Let me see what I can do.

So I started working through this and realized that this complicates the 
code significantly.

* I have to re-introduce the uplink-list since now I need to track
"filter capable" uplinks in addition to non-capable ones.
* The really nice and simple sysfs interface to set a flag turns into 
something that duplicates code.
* The bridge port removal can effect the promiscuity setting of the 
bridge if the last uplink is removed.
* We lose the ability to run a promisc edge bridge with uplinks.

I am really starting wonder if this is any better?  The changes
are much bigger and more complex while the functional flexibility is
reduced.  Is it really worth removing a configuration knob?

I've attached an in-progress patch to demonstrate the above.

-vlad

-vlad
>
> Thanks
> -vlad
>


--------------090703030702040004030102
Content-Type: text/x-patch;
 name="test.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="test.patch"

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index c4edfe1..b9444e9 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -220,6 +220,7 @@ enum {
 	IFLA_BRPORT_GUARD,	/* bpdu guard              */
 	IFLA_BRPORT_PROTECT,	/* root port protection    */
 	IFLA_BRPORT_FAST_LEAVE,	/* multicast fast leave    */
+	IFLA_BRPORT_UPLINK,	/* uplink port */
 	__IFLA_BRPORT_MAX
 };
 #define IFLA_BRPORT_MAX (__IFLA_BRPORT_MAX - 1)
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index d5f1d3f..df0afb2 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -356,6 +356,7 @@ void br_dev_setup(struct net_device *dev)
 	br->dev = dev;
 	spin_lock_init(&br->lock);
 	INIT_LIST_HEAD(&br->port_list);
+	INIT_LIST_HEAD(&br->uplink_list);
 	spin_lock_init(&br->hash_lock);
 
 	br->bridge_id.prio[0] = 0x80;
@@ -371,6 +372,7 @@ void br_dev_setup(struct net_device *dev)
 	br->bridge_hello_time = br->hello_time = 2 * HZ;
 	br->bridge_forward_delay = br->forward_delay = 15 * HZ;
 	br->ageing_time = 300 * HZ;
+	br->promisc_enabled = 1;
 
 	br_netfilter_rtable_init(br);
 	br_stp_timer_init(br);
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index ef1b914..8a3a085 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -60,6 +60,29 @@ static int port_cost(struct net_device *dev)
 	return 100;	/* assume old 10Mbps */
 }
 
+static void br_set_promisc(struct net_bridge *br, int val)
+{
+	struct net_bridge_port *p;
+
+	if (val) {
+		br->promisc_enabled = 1;
+		/* For each port on the bridge, turn on promisc mode and
+		 * turn off ALLMULTI to handle multicast traffic.
+		 */
+		list_for_each_entry(p, &br->port_list, list) {
+			dev_set_promiscuity(p->dev, 1);
+			dev_set_allmulti(p->dev, -1);
+		}
+
+	} else {
+		br->promisc_enabled = 0;
+		/* For each port on the bridge, turn off promisc mode */
+		list_for_each_entry(p, &br->port_list, list) {
+			dev_set_allmulti(p->dev, 1);
+			dev_set_promiscuity(p->dev, -1);
+		}
+	}
+}
 
 /* Check for port carrier transistions. */
 void br_port_carrier_check(struct net_bridge_port *p)
@@ -132,7 +155,14 @@ static void del_nbp(struct net_bridge_port *p)
 
 	sysfs_remove_link(br->ifobj, p->dev->name);
 
-	dev_set_promiscuity(dev, -1);
+	if (br->promisc_enabled)
+		dev_set_promiscuity(dev, -1);
+	else
+		dev_set_allmulti(dev, -1);
+
+	list_del_rcu(&p->uplink_list);
+	if (list_empty(&br->uplink_list))
+		br_set_promisc(br, 1);
 
 	spin_lock_bh(&br->lock);
 	br_stp_disable_port(p);
@@ -222,6 +252,7 @@ static struct net_bridge_port *new_nbp(struct net_bridge *br,
 	p->priority = 0x8000 >> BR_PORT_BITS;
 	p->port_no = index;
 	p->flags = 0;
+	INIT_LIST_HEAD(&p->uplink_list);
 	br_init_port(p);
 	p->state = BR_STATE_DISABLED;
 	br_stp_port_timer_init(p);
@@ -350,9 +381,15 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 
 	call_netdevice_notifiers(NETDEV_JOIN, dev);
 
-	err = dev_set_promiscuity(dev, 1);
-	if (err)
-		goto put_back;
+	if (br->promisc_enabled) {
+		err = dev_set_promiscuity(dev, 1);
+		if (err)
+			goto put_back;
+	} else {
+		err = dev_set_allmulti(dev, 1);
+		if (err)
+			goto put_back;
+	}
 
 	err = kobject_init_and_add(&p->kobj, &brport_ktype, &(dev->dev.kobj),
 				   SYSFS_BRIDGE_PORT_ATTR);
@@ -414,7 +451,10 @@ err2:
 	kobject_put(&p->kobj);
 	p = NULL; /* kobject_put frees */
 err1:
-	dev_set_promiscuity(dev, -1);
+	if (br->promisc_enabled)
+		dev_set_promiscuity(dev, -1);
+	else
+		dev_set_allmulti(dev, -1);
 put_back:
 	dev_put(dev);
 	kfree(p);
@@ -449,6 +489,30 @@ int br_del_if(struct net_bridge *br, struct net_device *dev)
 	return 0;
 }
 
+void br_set_uplink(struct net_bridge_port *p)
+{
+	if (p->flags & BR_UPLINK) {
+		if (p->dev->priv_flags & IFF_UNICAST_FLT) {
+			/* Turn off promisc mode if this is the first
+			 * filter capable uplink
+			 */
+			if (list_empty(&p->br->uplink_list))
+				br_set_promisc(p->br, 0);
+
+			list_add_rcu(&p->uplink_list, &p->br->uplink_list);
+		}
+	} else {
+		if (p->dev->priv_flags & IFF_UNICAST_FLT) {
+			list_del_rcu(&p->uplink_list);
+			/* Turn on promisc mode if this was the last
+			 * filter capable uplink
+			 */
+			if (list_empty(&p->br->uplink_list))
+				br_set_promisc(p->br, 1);
+		}
+	}
+}
+
 void __net_exit br_net_exit(struct net *net)
 {
 	struct net_device *dev;
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 27aa3ee..e53eb0b 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -283,6 +283,7 @@ static const struct nla_policy ifla_brport_policy[IFLA_BRPORT_MAX + 1] = {
 	[IFLA_BRPORT_MODE]	= { .type = NLA_U8 },
 	[IFLA_BRPORT_GUARD]	= { .type = NLA_U8 },
 	[IFLA_BRPORT_PROTECT]	= { .type = NLA_U8 },
+	[IFLA_BRPORT_UPLINK]	= { .type = NLA_U8 },
 };
 
 /* Change the state of the port and notify spanning tree */
@@ -325,10 +326,12 @@ static void br_set_port_flag(struct net_bridge_port *p, struct nlattr *tb[],
 static int br_setport(struct net_bridge_port *p, struct nlattr *tb[])
 {
 	int err;
+	unsigned long flags = p->flags;
 
 	br_set_port_flag(p, tb, IFLA_BRPORT_MODE, BR_HAIRPIN_MODE);
 	br_set_port_flag(p, tb, IFLA_BRPORT_GUARD, BR_BPDU_GUARD);
 	br_set_port_flag(p, tb, IFLA_BRPORT_FAST_LEAVE, BR_MULTICAST_FAST_LEAVE);
+	br_set_port_flag(p, tb, IFLA_BRPORT_UPLINK, BR_UPLINK);
 
 	if (tb[IFLA_BRPORT_COST]) {
 		err = br_stp_set_path_cost(p, nla_get_u32(tb[IFLA_BRPORT_COST]));
@@ -347,6 +350,11 @@ static int br_setport(struct net_bridge_port *p, struct nlattr *tb[])
 		if (err)
 			return err;
 	}
+
+	/* If the uplink flag has changed do additional processing */
+	if ((flags ^ p->flags) & BR_UPLINK)
+		br_set_uplink(p);
+
 	return 0;
 }
 
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 6d314c4..ab8cb1a9 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -130,6 +130,7 @@ struct net_bridge_port
 	struct net_bridge		*br;
 	struct net_device		*dev;
 	struct list_head		list;
+	struct list_head		uplink_list;
 
 	/* STP */
 	u8				priority;
@@ -156,6 +157,7 @@ struct net_bridge_port
 #define BR_BPDU_GUARD           0x00000002
 #define BR_ROOT_BLOCK		0x00000004
 #define BR_MULTICAST_FAST_LEAVE	0x00000008
+#define BR_UPLINK		0x00000010
 
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 	u32				multicast_startup_queries_sent;
@@ -277,6 +279,8 @@ struct net_bridge
 	struct timer_list		topology_change_timer;
 	struct timer_list		gc_timer;
 	struct kobject			*ifobj;
+	struct list_head		uplink_list;
+ 	u8				promisc_enabled;
 #ifdef CONFIG_BRIDGE_VLAN_FILTERING
 	u8				vlan_enabled;
 	struct net_port_vlans __rcu	*vlan_info;
@@ -426,6 +430,7 @@ extern int br_del_if(struct net_bridge *br,
 extern int br_min_mtu(const struct net_bridge *br);
 extern netdev_features_t br_features_recompute(struct net_bridge *br,
 	netdev_features_t features);
+extern void br_set_uplink(struct net_bridge_port *port);
 
 /* br_input.c */
 extern int br_handle_frame_finish(struct sk_buff *skb);
diff --git a/net/bridge/br_sysfs_if.c b/net/bridge/br_sysfs_if.c
index a1ef1b6..454a0cf 100644
--- a/net/bridge/br_sysfs_if.c
+++ b/net/bridge/br_sysfs_if.c
@@ -159,6 +159,29 @@ BRPORT_ATTR_FLAG(hairpin_mode, BR_HAIRPIN_MODE);
 BRPORT_ATTR_FLAG(bpdu_guard, BR_BPDU_GUARD);
 BRPORT_ATTR_FLAG(root_block, BR_ROOT_BLOCK);
 
+static ssize_t show_uplink(struct net_bridge_port *p, char *buf)
+{
+	return sprintf(buf, "%d\n", !!(p->flags & BR_UPLINK));
+}
+
+static int store_uplink(struct net_bridge_port *p, unsigned long v)
+{
+	unsigned long flags = p->flags;
+
+	if (v)
+		flags |= BR_UPLINK;
+	else
+		flags &= ~BR_UPLINK;
+
+	if (flags != p->flags) {
+		p->flags = flags;
+		br_set_uplink(p);
+		br_ifinfo_notify(RTM_NEWLINK, p);
+	}
+	return 0;
+}
+static BRPORT_ATTR(uplink, S_IRUGO | S_IWUSR, show_uplink, store_uplink);
+
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 static ssize_t show_multicast_router(struct net_bridge_port *p, char *buf)
 {
@@ -195,6 +218,7 @@ static const struct brport_attribute *brport_attrs[] = {
 	&brport_attr_hairpin_mode,
 	&brport_attr_bpdu_guard,
 	&brport_attr_root_block,
+	&brport_attr_uplink,
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 	&brport_attr_multicast_router,
 	&brport_attr_multicast_fast_leave,

--------------090703030702040004030102--
