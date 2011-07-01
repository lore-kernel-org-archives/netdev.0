From: Nick Carter <ncarter100@gmail.com>
Subject: [PATCH] bridge: mask forwarding of IEEE 802 local multicast groups
Date: Fri, 1 Jul 2011 22:21:44 +0100
Message-ID: <BANLkTi=jnxBu6WzAOTxHD+e_O1qYKE2m=g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net
To: netdev@vger.kernel.org,
	=?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>,
	David Lamparter <equinox@diac24.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:36191 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755209Ab1GAVVp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2011 17:21:45 -0400
Received: by pzk9 with SMTP id 9so131766pzk.19
        for <netdev@vger.kernel.org>; Fri, 01 Jul 2011 14:21:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce sysfs ../bridge/group_fwd_mask attribute so users can
configure which group mac addresses are forwarded.

These diffs do not change the default behaviour of bridge.ko.  By
changing the group_fwd_mask value users can select any combination of
the 01-80-C2-00-00-00 - 01-80-C2-00-00-0F addresses to be forwarded.

Signed-off-by: Nick Carter <ncarter100@gmail.com>

diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index d9d1e2b..bb25e49 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -214,6 +214,7 @@ static struct net_device *new_bridge_dev(struct
net *net, const char *name)
 	br->topology_change = 0;
 	br->topology_change_detected = 0;
 	br->ageing_time = 300 * HZ;
+	br->group_fwd_mask = 0;

 	br_netfilter_rtable_init(br);

diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 90e985b..80b94f4 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -166,6 +166,9 @@ struct sk_buff *br_handle_frame(struct sk_buff *skb)
 		if (p->br->stp_enabled == BR_NO_STP && dest[5] == 0)
 			goto forward;

+		if (p->br->group_fwd_mask & (1 << dest[5]))
+			goto forward;
+
 		if (NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_IN, skb, skb->dev,
 			    NULL, br_handle_local_finish))
 			return NULL;	/* frame consumed by filter */
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 4e1b620..d5aa164 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -244,6 +244,13 @@ struct net_bridge
 	struct timer_list		multicast_query_timer;
 #endif

+	/* Each bit used to match the LSB of the IEEE 802.1D group address
+	 * 01-80-C2-00-00-00 bit 0
+	 * ..
+	 * 01-80-C2-00-00-0F bit 15
+	 */
+	u16				group_fwd_mask;
+
 	struct timer_list		hello_timer;
 	struct timer_list		tcn_timer;
 	struct timer_list		topology_change_timer;
diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
index 5c1e555..f3cced5 100644
--- a/net/bridge/br_sysfs_br.c
+++ b/net/bridge/br_sysfs_br.c
@@ -679,6 +679,28 @@ static DEVICE_ATTR(nf_call_arptables, S_IRUGO | S_IWUSR,
 		   show_nf_call_arptables, store_nf_call_arptables);
 #endif

+static ssize_t show_group_fwd_mask(struct device *d, struct
device_attribute *attr,
+				char *buf)
+{
+	struct net_bridge *br = to_bridge(d);
+	return sprintf(buf, "%d\n", br->group_fwd_mask);
+}
+
+static int set_group_fwd_mask(struct net_bridge *br, unsigned long val)
+{
+	br->group_fwd_mask = (u16)val;
+	return 0;
+}
+
+static ssize_t store_group_fwd_mask(struct device *d,
+				 struct device_attribute *attr, const char *buf,
+				 size_t len)
+{
+	return store_bridge_parm(d, buf, len, set_group_fwd_mask);
+}
+static DEVICE_ATTR(group_fwd_mask, S_IRUGO | S_IWUSR, show_group_fwd_mask,
+		   store_group_fwd_mask);
+
 static struct attribute *bridge_attrs[] = {
 	&dev_attr_forward_delay.attr,
 	&dev_attr_hello_time.attr,
@@ -698,6 +720,7 @@ static struct attribute *bridge_attrs[] = {
 	&dev_attr_gc_timer.attr,
 	&dev_attr_group_addr.attr,
 	&dev_attr_flush.attr,
+	&dev_attr_group_fwd_mask.attr,
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 	&dev_attr_multicast_router.attr,
 	&dev_attr_multicast_snooping.attr,
