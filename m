From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCHv2 net-next 1/2] bridge: Add flag to control mac
 learning.
Date: Mon, 29 Apr 2013 16:29:38 -0700
Message-ID: <20130429162938.782df114@nehalam.linuxnetplumber.net>
References: <1367256945-25923-1-git-send-email-vyasevic@redhat.com>
	<1367256945-25923-2-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org, mst@redhat.com
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1367256945-25923-2-git-send-email-vyasevic@redhat.com>
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

On Mon, 29 Apr 2013 13:35:44 -0400
Vlad Yasevich <vyasevic@redhat.com> wrote:

> Allow user to control whether mac learning is enabled on the port.
> By default, mac learning is enabled.  Disabling mac learning will
> cause new dynamic FDB entries to not be created for a particular port.
> 
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>

This looks like a good feature, thank you for doing it. It needed a couple
more changes before it is ready.

Your patch fails against current net-next, there is a new flag ADMIN_COST
that is not in your tree.

Also, it is clearer to just move the flag test back into the input side,
rather than adding wrapper functions.


Subject: [PATCHv3 net-next 1/2] bridge: Add flag to control mac learning.

Allow user to control whether mac learning is enabled on the port.
By default, mac learning is enabled.  Disabling mac learning will
cause new dynamic FDB entries to not be created for a particular port.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

---
 include/uapi/linux/if_link.h |    1 +
 net/bridge/br_if.c           |    2 +-
 net/bridge/br_input.c        |    7 +++++--
 net/bridge/br_netlink.c      |    6 +++++-
 net/bridge/br_private.h      |    1 +
 net/bridge/br_sysfs_if.c     |    2 ++
 6 files changed, 15 insertions(+), 4 deletions(-)

--- a/include/uapi/linux/if_link.h	2013-04-29 15:45:49.000000000 -0700
+++ b/include/uapi/linux/if_link.h	2013-04-29 16:16:04.246906829 -0700
@@ -221,6 +221,7 @@ enum {
 	IFLA_BRPORT_GUARD,	/* bpdu guard              */
 	IFLA_BRPORT_PROTECT,	/* root port protection    */
 	IFLA_BRPORT_FAST_LEAVE,	/* multicast fast leave    */
+	IFLA_BRPORT_LEARNING,	/* mac learning */
 	__IFLA_BRPORT_MAX
 };
 #define IFLA_BRPORT_MAX (__IFLA_BRPORT_MAX - 1)
--- a/net/bridge/br_if.c	2013-04-26 16:27:59.000000000 -0700
+++ b/net/bridge/br_if.c	2013-04-29 16:16:04.250906777 -0700
@@ -221,7 +221,7 @@ static struct net_bridge_port *new_nbp(s
 	p->path_cost = port_cost(dev);
 	p->priority = 0x8000 >> BR_PORT_BITS;
 	p->port_no = index;
-	p->flags = 0;
+	p->flags = BR_LEARNING;
 	br_init_port(p);
 	p->state = BR_STATE_DISABLED;
 	br_stp_port_timer_init(p);
--- a/net/bridge/br_netlink.c	2013-03-28 14:26:20.000000000 -0700
+++ b/net/bridge/br_netlink.c	2013-04-29 16:16:04.250906777 -0700
@@ -30,6 +30,7 @@ static inline size_t br_port_info_size(v
 		+ nla_total_size(1)	/* IFLA_BRPORT_GUARD */
 		+ nla_total_size(1)	/* IFLA_BRPORT_PROTECT */
 		+ nla_total_size(1)	/* IFLA_BRPORT_FAST_LEAVE */
+		+ nla_total_size(1)	/* IFLA_BRPORT_LEARNING */
 		+ 0;
 }
 
@@ -56,7 +57,8 @@ static int br_port_fill_attrs(struct sk_
 	    nla_put_u8(skb, IFLA_BRPORT_MODE, mode) ||
 	    nla_put_u8(skb, IFLA_BRPORT_GUARD, !!(p->flags & BR_BPDU_GUARD)) ||
 	    nla_put_u8(skb, IFLA_BRPORT_PROTECT, !!(p->flags & BR_ROOT_BLOCK)) ||
-	    nla_put_u8(skb, IFLA_BRPORT_FAST_LEAVE, !!(p->flags & BR_MULTICAST_FAST_LEAVE)))
+	    nla_put_u8(skb, IFLA_BRPORT_FAST_LEAVE, !!(p->flags & BR_MULTICAST_FAST_LEAVE)) ||
+	    nla_put_u8(skb, IFLA_BRPORT_LEARNING, !!(p->flags & BR_LEARNING)))
 		return -EMSGSIZE;
 
 	return 0;
@@ -281,6 +283,7 @@ static const struct nla_policy ifla_brpo
 	[IFLA_BRPORT_MODE]	= { .type = NLA_U8 },
 	[IFLA_BRPORT_GUARD]	= { .type = NLA_U8 },
 	[IFLA_BRPORT_PROTECT]	= { .type = NLA_U8 },
+	[IFLA_BRPORT_LEARNING]	= { .type = NLA_U8 },
 };
 
 /* Change the state of the port and notify spanning tree */
@@ -328,6 +331,7 @@ static int br_setport(struct net_bridge_
 	br_set_port_flag(p, tb, IFLA_BRPORT_GUARD, BR_BPDU_GUARD);
 	br_set_port_flag(p, tb, IFLA_BRPORT_FAST_LEAVE, BR_MULTICAST_FAST_LEAVE);
 	br_set_port_flag(p, tb, IFLA_BRPORT_PROTECT, BR_ROOT_BLOCK);
+	br_set_port_flag(p, tb, IFLA_BRPORT_LEARNING, BR_LEARNING);
 
 	if (tb[IFLA_BRPORT_COST]) {
 		err = br_stp_set_path_cost(p, nla_get_u32(tb[IFLA_BRPORT_COST]));
--- a/net/bridge/br_private.h	2013-04-26 16:27:59.000000000 -0700
+++ b/net/bridge/br_private.h	2013-04-29 16:19:16.728417454 -0700
@@ -157,6 +157,7 @@ struct net_bridge_port
 #define BR_ROOT_BLOCK		0x00000004
 #define BR_MULTICAST_FAST_LEAVE	0x00000008
 #define BR_ADMIN_COST		0x00000010
+#define BR_LEARNING		0x00000020
 
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 	u32				multicast_startup_queries_sent;
--- a/net/bridge/br_sysfs_if.c	2013-03-07 18:12:53.000000000 -0800
+++ b/net/bridge/br_sysfs_if.c	2013-04-29 16:16:04.250906777 -0700
@@ -158,6 +158,7 @@ static BRPORT_ATTR(flush, S_IWUSR, NULL,
 BRPORT_ATTR_FLAG(hairpin_mode, BR_HAIRPIN_MODE);
 BRPORT_ATTR_FLAG(bpdu_guard, BR_BPDU_GUARD);
 BRPORT_ATTR_FLAG(root_block, BR_ROOT_BLOCK);
+BRPORT_ATTR_FLAG(learning, BR_LEARNING);
 
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 static ssize_t show_multicast_router(struct net_bridge_port *p, char *buf)
@@ -195,6 +196,7 @@ static const struct brport_attribute *br
 	&brport_attr_hairpin_mode,
 	&brport_attr_bpdu_guard,
 	&brport_attr_root_block,
+	&brport_attr_learning,
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 	&brport_attr_multicast_router,
 	&brport_attr_multicast_fast_leave,
--- a/net/bridge/br_input.c	2013-03-14 14:22:58.151958077 -0700
+++ b/net/bridge/br_input.c	2013-04-29 16:25:20.467713190 -0700
@@ -75,7 +75,9 @@ int br_handle_frame_finish(struct sk_buf
 
 	/* insert into forwarding database after filtering to avoid spoofing */
 	br = p->br;
-	br_fdb_update(br, p, eth_hdr(skb)->h_source, vid);
+
+	if (p->flags & BR_LEARNING)
+		br_fdb_update(br, p, eth_hdr(skb)->h_source, vid);
 
 	if (!is_broadcast_ether_addr(dest) && is_multicast_ether_addr(dest) &&
 	    br_multicast_rcv(br, p, skb))
@@ -142,7 +144,8 @@ static int br_handle_local_finish(struct
 	u16 vid = 0;
 
 	br_vlan_get_tag(skb, &vid);
-	br_fdb_update(p->br, p, eth_hdr(skb)->h_source, vid);
+	if (p->flags & BR_LEARNING)
+		br_fdb_update(p->br, p, eth_hdr(skb)->h_source, vid);
 	return 0;	 /* process further */
 }
 
