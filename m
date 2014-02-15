From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: [RFC v2 1/4] bridge: enable interfaces to opt out from
	becoming the root bridge
Date: Fri, 14 Feb 2014 18:59:37 -0800
Message-ID: <1392433180-16052-2-git-send-email-mcgrof@do-not-panic.com>
References: <1392433180-16052-1-git-send-email-mcgrof@do-not-panic.com>
Cc: kvm@vger.kernel.org, "Luis R. Rodriguez" <mcgrof@suse.com>,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	xen-devel@lists.xenproject.org
To: netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1392433180-16052-1-git-send-email-mcgrof@do-not-panic.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: "Luis R. Rodriguez" <mcgrof@suse.com>

It doesn't make sense for some interfaces to become a root bridge
at any point in time. One example is virtual backend interfaces
which rely on other entities on the bridge for actual physical
connectivity. They only provide virtual access.

Device drivers that know they should never become part of the
root bridge have been using a trick of setting their MAC address
to a high broadcast MAC address such as FE:FF:FF:FF:FF:FF. Instead
of using these hacks lets the interfaces annotate its intent and
generalizes a solution for multiple drivers, while letting the
drivers use a random MAC address or one prefixed with a proper OUI.
This sort of hack is used by both qemu and xen for their backend
interfaces.

Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: bridge@lists.linux-foundation.org
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Signed-off-by: Luis R. Rodriguez <mcgrof@suse.com>
---
 include/uapi/linux/if.h | 1 +
 net/bridge/br_if.c      | 2 ++
 net/bridge/br_private.h | 1 +
 net/bridge/br_stp_if.c  | 2 ++
 4 files changed, 6 insertions(+)

diff --git a/include/uapi/linux/if.h b/include/uapi/linux/if.h
index d758163..8d10382 100644
--- a/include/uapi/linux/if.h
+++ b/include/uapi/linux/if.h
@@ -84,6 +84,7 @@
 #define IFF_LIVE_ADDR_CHANGE 0x100000	/* device supports hardware address
 					 * change when it's running */
 #define IFF_MACVLAN 0x200000		/* Macvlan device */
+#define IFF_BRIDGE_NON_ROOT 0x400000    /* Don't consider for root bridge */
 
 
 #define IF_GET_IFACE	0x0001		/* for querying only */
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 4bf02ad..a745415 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -228,6 +228,8 @@ static struct net_bridge_port *new_nbp(struct net_bridge *br,
 	br_init_port(p);
 	p->state = BR_STATE_DISABLED;
 	br_stp_port_timer_init(p);
+	if (dev->priv_flags & IFF_BRIDGE_NON_ROOT)
+		p->flags |= BR_DONT_ROOT;
 	br_multicast_add_port(p);
 
 	return p;
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 045d56e..a89e8ad 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -173,6 +173,7 @@ struct net_bridge_port
 #define BR_ADMIN_COST		0x00000010
 #define BR_LEARNING		0x00000020
 #define BR_FLOOD		0x00000040
+#define BR_DONT_ROOT		0x00000080
 
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 	struct bridge_mcast_query	ip4_query;
diff --git a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
index 656a6f3..12fd848 100644
--- a/net/bridge/br_stp_if.c
+++ b/net/bridge/br_stp_if.c
@@ -228,6 +228,8 @@ bool br_stp_recalculate_bridge_id(struct net_bridge *br)
 		return false;
 
 	list_for_each_entry(p, &br->port_list, list) {
+		if (p->flags & BR_DONT_ROOT)
+			continue;
 		if (addr == br_mac_zero ||
 		    memcmp(p->dev->dev_addr, addr, ETH_ALEN) < 0)
 			addr = p->dev->dev_addr;
-- 
1.8.5.2
