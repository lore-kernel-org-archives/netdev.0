From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: [PATCH 3/3] bridge: fix bridge root block on designated port
Date: Wed, 12 Mar 2014 20:15:27 -0700
Message-ID: <1394680527-28970-4-git-send-email-mcgrof@do-not-panic.com>
References: <1394680527-28970-1-git-send-email-mcgrof@do-not-panic.com>
Cc: linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	xen-devel@lists.xenproject.org, mcgrof@suse.com,
	Stephen Hemminger <stephen@networkplumber.org>,
	bridge@lists.linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394680527-28970-1-git-send-email-mcgrof@do-not-panic.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Luis R. Rodriguez" <mcgrof@suse.com>

Root port blocking was designed so that a bridge port can opt
out of becoming the designated root port for a bridge. If a port
however first becomes the designated root port and we then toggle
the root port block on it we currently don't kick that port out of
the designated root port. This fixes that. This is particularly
important for net_devices that would wish to never become a root
port from the start, currently toggling that off will enable root
port flag but it won't really kick the bridge and do what you'd
expect, the MAC address is kept on the bridge of the toggled port
for root_block if it was the designated port.

In order to catch if a port with root port block preference is set
we need to move our check for root block prior to the root selection
so check for root blocked ports upon eveyr br_configuration_update().
We also simply just prevent the root-blocked ports from consideration
as root port candidates on br_should_become_root_port() and
br_stp_recalculate_bridge_id().

The issue that this patch is trying to address and fix can be tested
easily before and after this patch is applied using 2 TAP net_devices
and then toggling at will with the root_block knob.

ip tuntap add dev tap0 mode tap
ip tuntap add dev tap1 mode tap
ip link add dev br0 type bridge
ip link show br0
echo -------------------------------------------
ip link set dev tap0 master br0
ip link
echo -------------------------------------------
ip link set dev tap1 master br0
ip link
echo -------------------------------------------

Upon review at the above results you can toggle root_block
on each port to see if you see the results you expect.

bridge link set dev tap0 root_block on
ip link
bridge link set dev tap1 root_block on
ip link

Toggling off root_block on any port should will bring back the
port to be a candidate for designated root port:

bridge link set dev tap1 root_block off
ip link
bridge link set dev tap0 root_block off
ip link

To nuke:

ip tuntap del tap0 mode tap
ip tuntap del tap0 mode tap

Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: bridge@lists.linux-foundation.org
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: xen-devel@lists.xenproject.org
Cc: kvm@vger.kernel.org
Signed-off-by: Luis R. Rodriguez <mcgrof@suse.com>
---
 net/bridge/br_netlink.c | 18 ++++++++++++
 net/bridge/br_private.h |  1 +
 net/bridge/br_stp.c     | 73 +++++++++++++++++++++++++++++++++++++++++++++----
 net/bridge/br_stp_if.c  |  3 +-
 4 files changed, 88 insertions(+), 7 deletions(-)

diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 6f1b26d..fbec354 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -324,6 +324,21 @@ static void br_set_port_flag(struct net_bridge_port *p, struct nlattr *tb[],
 	}
 }
 
+static void br_kick_bridge_port(struct net_bridge_port *p)
+{
+	struct net_bridge *br = p->br;
+	bool wasroot;
+
+	wasroot = br_is_root_bridge(br);
+	br_become_designated_port(p);
+
+	br_configuration_update(br);
+	br_port_state_selection(br);
+
+	if (br_is_root_bridge(br) && !wasroot)
+		br_become_root_bridge(br);
+}
+
 /* Process bridge protocol info on port */
 static int br_setport(struct net_bridge_port *p, struct nlattr *tb[])
 {
@@ -353,6 +368,9 @@ static int br_setport(struct net_bridge_port *p, struct nlattr *tb[])
 		if (err)
 			return err;
 	}
+
+	br_kick_bridge_port(p);
+
 	return 0;
 }
 
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 32a06da..45d7917 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -150,6 +150,7 @@ struct net_bridge_port
 	u8				priority;
 	u8				state;
 	u16				port_no;
+	bool				root_block_enabled;
 	unsigned char			topology_change_ack;
 	unsigned char			config_pending;
 	port_id				port_id;
diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
index 3c86f05..f5741f3 100644
--- a/net/bridge/br_stp.c
+++ b/net/bridge/br_stp.c
@@ -59,6 +59,7 @@ static int br_should_become_root_port(const struct net_bridge_port *p,
 
 	br = p->br;
 	if (p->state == BR_STATE_DISABLED ||
+	   (p->flags & BR_ROOT_BLOCK) ||
 	    br_is_designated_port(p))
 		return 0;
 
@@ -104,7 +105,7 @@ static void br_root_port_block(const struct net_bridge *br,
 			       struct net_bridge_port *p)
 {
 
-	br_notice(br, "port %u(%s) tried to become root port (blocked)",
+	br_notice(br, "port %u (%s) is now root blocked",
 		  (unsigned int) p->port_no, p->dev->name);
 
 	p->state = BR_STATE_LISTENING;
@@ -124,11 +125,7 @@ static void br_root_selection(struct net_bridge *br)
 	list_for_each_entry(p, &br->port_list, list) {
 		if (!br_should_become_root_port(p, root_port))
 			continue;
-
-		if (p->flags & BR_ROOT_BLOCK)
-			br_root_port_block(br, p);
-		else
-			root_port = p->port_no;
+		root_port = p->port_no;
 	}
 
 	br->root_port = root_port;
@@ -358,10 +355,74 @@ static void br_reply(struct net_bridge_port *p)
 	br_transmit_config(p);
 }
 
+static bool br_root_port_block_check(struct net_bridge_port *p)
+{
+	bool designated = false;
+
+	if (p->root_block_enabled &&
+	    !(p->flags & BR_ROOT_BLOCK)) {
+		br_notice(p->br, "port %u (%s) is root block toggled off",
+			  (unsigned int) p->port_no, p->dev->name);
+		return false;
+	}
+
+	if (p->flags & BR_ROOT_BLOCK &&
+	    (p->root_block_enabled))
+		return false;
+
+	if (!(p->flags & BR_ROOT_BLOCK))
+		return false;
+
+	if (br_is_designated_port(p)) {
+		designated = true;
+		p->flags = BR_ROOT_BLOCK |
+			   BR_LEARNING |
+			   BR_FLOOD;
+		p->priority = 0x8000 >> BR_PORT_BITS;
+		br_init_port(p);
+	}
+
+	br_root_port_block(p->br, p);
+	p->root_block_enabled = true;
+
+	return designated;
+}
+
+/* Updates block ports as required and returns true if one was designated */
+static bool br_update_block_ports(struct net_bridge *br)
+{
+	struct net_bridge_port *p;
+	bool designated = false;
+
+	list_for_each_entry(p, &br->port_list, list) {
+		designated = br_root_port_block_check(p);
+		if (designated)
+			return designated;
+	}
+
+	return false;
+}
+
+static void br_update_designated_port(struct net_bridge *br)
+{
+	struct net_bridge_port *p;
+
+	list_for_each_entry(p, &br->port_list, list)
+		br_become_designated_port(p);
+}
+
 /* called under bridge lock */
 void br_configuration_update(struct net_bridge *br)
 {
+	bool designated_was_blocked = false;
+
+	designated_was_blocked = br_update_block_ports(br);
+
 	br_root_selection(br);
+
+	if (designated_was_blocked)
+		br_update_designated_port(br);
+
 	br_designated_port_selection(br);
 }
 
diff --git a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
index 4c9ad45..62b84af 100644
--- a/net/bridge/br_stp_if.c
+++ b/net/bridge/br_stp_if.c
@@ -230,10 +230,11 @@ bool br_stp_recalculate_bridge_id(struct net_bridge *br)
 		return false;
 
 	list_for_each_entry(p, &br->port_list, list) {
+		if (p->flags & BR_ROOT_BLOCK)
+			continue;
 		if (addr == br_mac_zero ||
 		    memcmp(p->dev->dev_addr, addr, ETH_ALEN) < 0)
 			addr = p->dev->dev_addr;
-
 	}
 
 	if (ether_addr_equal(br->bridge_id.addr, addr))
-- 
1.8.5.3
