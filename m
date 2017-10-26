From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [PATCH next 1/2] ipvlan: introduce 'private' attribute for all existing modes.
Date: Thu, 26 Oct 2017 15:09:21 -0700
Message-ID: <20171026220921.34758-1-mahesh@bandewar.net>
Cc: Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        Changgong Li <chonggangli@google.com>,
        Mahesh Bandewar <mahesh@bandewar.net>,
        Mahesh Bandewar <maheshb@google.com>
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:43623 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932346AbdJZWJZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 18:09:25 -0400
Received: by mail-oi0-f68.google.com with SMTP id c77so8181271oig.0
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 15:09:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>

IPvlan has always operated in bridge mode. However there are scenarios
where each slave should be able to talk through the master device but
not necessarily across each other. Think of an environment where each
of a namespace is a private and independant customer. In this scenario
the machine which is hosting these namespaces neither want to tell who
their neighbor is nor the individual namespaces care to talk to neighbor
on short-circuited network path.

This patch implements the mode that is very similar to the 'private' mode
in macvlan where individual slaves can send and receive traffic through
the master device, just that they can not talk among slave devices.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 Documentation/networking/ipvlan.txt | 30 ++++++++++++++++++++++++++---
 drivers/net/ipvlan/ipvlan.h         | 16 ++++++++++++++++
 drivers/net/ipvlan/ipvlan_core.c    | 15 ++++++++++++---
 drivers/net/ipvlan/ipvlan_main.c    | 38 +++++++++++++++++++++++++++++++++++--
 include/uapi/linux/if_link.h        |  3 +++
 5 files changed, 94 insertions(+), 8 deletions(-)

diff --git a/Documentation/networking/ipvlan.txt b/Documentation/networking/ipvlan.txt
index 1fe42a874aae..bfa91c77a4c9 100644
--- a/Documentation/networking/ipvlan.txt
+++ b/Documentation/networking/ipvlan.txt
@@ -22,9 +22,19 @@ The driver can be built into the kernel (CONFIG_IPVLAN=y) or as a module
 	There are no module parameters for this driver and it can be configured
 using IProute2/ip utility.
 
-	ip link add link <master-dev> name <slave-dev> type ipvlan mode { l2 | l3 | l3s }
+    ip link add link <master> name <slave> type ipvlan [ mode MODE ] [ FLAGS ]
+       where
+         MODE: l3 (default) | l3s | l2
+         FLAGS: bridge (default) | private
 
-	e.g. ip link add link eth0 name ipvl0 type ipvlan mode l2
+    e.g.
+    (a) Following will create IPvlan link with eth0 as master in
+        L3 bridge mode
+          bash# ip link add link eth0 name ipvl0 type ipvlan
+    (b) This command will create IPvlan link in L2 bridge mode.
+          bash# ip link add link eth0 name ipvl0 type ipvlan mode l2 bridge
+    (c) This command will create an IPvlan device in L2 private mode.
+          bash# ip link add link eth0 name ipvlan type ipvlan mode l2 private
 
 
 4. Operating modes:
@@ -54,7 +64,21 @@ works in this mode and hence it is L3-symmetric (L3s). This will have slightly l
 performance but that shouldn't matter since you are choosing this mode over plain-L3
 mode to make conn-tracking work.
 
-5. What to choose (macvlan vs. ipvlan)?
+5. Mode flags:
+	At this time following mode flags are available
+
+5.1 bridge:
+	This is the default option. To configure the IPvlan port in this mode,
+user can choose to either add this option on the command-line or don't specify
+anything. This is the traditional mode where slaves can cross-talk among
+themseleves apart from talking through the master device.
+
+5.2 private:
+	If this option is added to the command-line, the port is set in private
+mode. i.e. port wont allow cross communication between slaves.
+
+
+6. What to choose (macvlan vs. ipvlan)?
 	These two devices are very similar in many regards and the specific use
 case could very well define which device to choose. if one of the following
 situations defines your use case then you can choose to use ipvlan -
diff --git a/drivers/net/ipvlan/ipvlan.h b/drivers/net/ipvlan/ipvlan.h
index ba8173a0b62e..9941851bcc13 100644
--- a/drivers/net/ipvlan/ipvlan.h
+++ b/drivers/net/ipvlan/ipvlan.h
@@ -96,6 +96,7 @@ struct ipvl_port {
 	struct hlist_head	hlhead[IPVLAN_HASH_SIZE];
 	struct list_head	ipvlans;
 	u16			mode;
+	u16			flags;
 	u16			dev_id_start;
 	struct work_struct	wq;
 	struct sk_buff_head	backlog;
@@ -123,6 +124,21 @@ static inline struct ipvl_port *ipvlan_port_get_rtnl(const struct net_device *d)
 	return rtnl_dereference(d->rx_handler_data);
 }
 
+static inline bool ipvlan_is_private(const struct ipvl_port *port)
+{
+	return !!(port->flags & IPVLAN_F_PRIVATE);
+}
+
+static inline void ipvlan_mark_private(struct ipvl_port *port)
+{
+	port->flags |= IPVLAN_F_PRIVATE;
+}
+
+static inline void ipvlan_clear_private(struct ipvl_port *port)
+{
+	port->flags &= ~IPVLAN_F_PRIVATE;
+}
+
 void ipvlan_init_secret(void);
 unsigned int ipvlan_mac_hash(const unsigned char *addr);
 rx_handler_result_t ipvlan_handle_frame(struct sk_buff **pskb);
diff --git a/drivers/net/ipvlan/ipvlan_core.c b/drivers/net/ipvlan/ipvlan_core.c
index 1f3295e274d0..72fd56de9c00 100644
--- a/drivers/net/ipvlan/ipvlan_core.c
+++ b/drivers/net/ipvlan/ipvlan_core.c
@@ -515,9 +515,13 @@ static int ipvlan_xmit_mode_l3(struct sk_buff *skb, struct net_device *dev)
 		goto out;
 
 	addr = ipvlan_addr_lookup(ipvlan->port, lyr3h, addr_type, true);
-	if (addr)
+	if (addr) {
+		if (ipvlan_is_private(ipvlan->port)) {
+			consume_skb(skb);
+			return NET_XMIT_DROP;
+		}
 		return ipvlan_rcv_frame(addr, &skb, true);
-
+	}
 out:
 	ipvlan_skb_crossing_ns(skb, ipvlan->phy_dev);
 	return ipvlan_process_outbound(skb);
@@ -535,8 +539,13 @@ static int ipvlan_xmit_mode_l2(struct sk_buff *skb, struct net_device *dev)
 		lyr3h = ipvlan_get_L3_hdr(skb, &addr_type);
 		if (lyr3h) {
 			addr = ipvlan_addr_lookup(ipvlan->port, lyr3h, addr_type, true);
-			if (addr)
+			if (addr) {
+				if (ipvlan_is_private(ipvlan->port)) {
+					consume_skb(skb);
+					return NET_XMIT_DROP;
+				}
 				return ipvlan_rcv_frame(addr, &skb, true);
+			}
 		}
 		skb = skb_share_check(skb, GFP_ATOMIC);
 		if (!skb)
diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index f0ab55df57f1..4368afb1934c 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -462,11 +462,24 @@ static int ipvlan_nl_changelink(struct net_device *dev,
 	struct ipvl_port *port = ipvlan_port_get_rtnl(ipvlan->phy_dev);
 	int err = 0;
 
-	if (data && data[IFLA_IPVLAN_MODE]) {
+	if (!data)
+		return 0;
+
+	if (data[IFLA_IPVLAN_MODE]) {
 		u16 nmode = nla_get_u16(data[IFLA_IPVLAN_MODE]);
 
 		err = ipvlan_set_port_mode(port, nmode);
 	}
+
+	if (!err && data[IFLA_IPVLAN_FLAGS]) {
+		u16 flags = nla_get_u16(data[IFLA_IPVLAN_FLAGS]);
+
+		if (flags & IPVLAN_F_PRIVATE)
+			ipvlan_mark_private(port);
+		else
+			ipvlan_clear_private(port);
+	}
+
 	return err;
 }
 
@@ -474,18 +487,30 @@ static size_t ipvlan_nl_getsize(const struct net_device *dev)
 {
 	return (0
 		+ nla_total_size(2) /* IFLA_IPVLAN_MODE */
+		+ nla_total_size(2) /* IFLA_IPVLAN_FLAGS */
 		);
 }
 
 static int ipvlan_nl_validate(struct nlattr *tb[], struct nlattr *data[],
 			      struct netlink_ext_ack *extack)
 {
-	if (data && data[IFLA_IPVLAN_MODE]) {
+	if (!data)
+		return 0;
+
+	if (data[IFLA_IPVLAN_MODE]) {
 		u16 mode = nla_get_u16(data[IFLA_IPVLAN_MODE]);
 
 		if (mode < IPVLAN_MODE_L2 || mode >= IPVLAN_MODE_MAX)
 			return -EINVAL;
 	}
+	if (data[IFLA_IPVLAN_FLAGS]) {
+		u16 flags = nla_get_u16(data[IFLA_IPVLAN_FLAGS]);
+
+		/* Only one bit is used at this moment. */
+		if (flags & ~IPVLAN_F_PRIVATE)
+			return -EINVAL;
+	}
+
 	return 0;
 }
 
@@ -502,6 +527,8 @@ static int ipvlan_nl_fillinfo(struct sk_buff *skb,
 	ret = -EMSGSIZE;
 	if (nla_put_u16(skb, IFLA_IPVLAN_MODE, port->mode))
 		goto err;
+	if (nla_put_u16(skb, IFLA_IPVLAN_FLAGS, port->flags))
+		goto err;
 
 	return 0;
 
@@ -549,6 +576,12 @@ int ipvlan_link_new(struct net *src_net, struct net_device *dev,
 	ipvlan_adjust_mtu(ipvlan, phy_dev);
 	INIT_LIST_HEAD(&ipvlan->addrs);
 
+	/* Flags are per port and latest update overrides. User has
+	 * to be consistent in setting it just like the mode attribute.
+	 */
+	if (data && data[IFLA_IPVLAN_FLAGS])
+		ipvlan->port->flags = nla_get_u16(data[IFLA_IPVLAN_FLAGS]);
+
 	/* If the port-id base is at the MAX value, then wrap it around and
 	 * begin from 0x1 again. This may be due to a busy system where lots
 	 * of slaves are getting created and deleted.
@@ -644,6 +677,7 @@ EXPORT_SYMBOL_GPL(ipvlan_link_setup);
 static const struct nla_policy ipvlan_nl_policy[IFLA_IPVLAN_MAX + 1] =
 {
 	[IFLA_IPVLAN_MODE] = { .type = NLA_U16 },
+	[IFLA_IPVLAN_FLAGS] = { .type = NLA_U16 },
 };
 
 static struct rtnl_link_ops ipvlan_link_ops = {
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index b037e0ab1975..052e32cd584c 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -465,6 +465,7 @@ enum macsec_validation_type {
 enum {
 	IFLA_IPVLAN_UNSPEC,
 	IFLA_IPVLAN_MODE,
+	IFLA_IPVLAN_FLAGS,
 	__IFLA_IPVLAN_MAX
 };
 
@@ -477,6 +478,8 @@ enum ipvlan_mode {
 	IPVLAN_MODE_MAX
 };
 
+#define IPVLAN_F_PRIVATE	0x01
+
 /* VXLAN section */
 enum {
 	IFLA_VXLAN_UNSPEC,
-- 
2.15.0.rc2.357.g7e34df9404-goog
