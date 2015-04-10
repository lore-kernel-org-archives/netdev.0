From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: [PATCH 1/4] ipv4: add option to drop unicast encapsulated in L2 multicast
Date: Fri, 10 Apr 2015 09:54:11 +0200
Message-ID: <1428652454-1224-1-git-send-email-johannes@sipsolutions.net>
Cc: matti.gottlieb-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

In order to solve a problem with 802.11, the so-called hole-196 attack,
add an option (sysctl) called "drop_unicast_in_l2_multicast" which, if
enabled, causes the stack to drop IPv4 unicast packets encapsulated in
link-layer multi- or broadcast frames. Such frames can (as an attack)
be created by any member of the same wireless network and transmitted
as valid encrypted frames since the symmetric key for broadcast frames
is shared between all stations.

Additionally, enabling this option provides compliance with a SHOULD
clause of RFC 1122.

Signed-off-by: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 Documentation/networking/ip-sysctl.txt |  7 +++++++
 include/uapi/linux/ip.h                |  1 +
 net/ipv4/devinet.c                     |  2 ++
 net/ipv4/route.c                       | 20 ++++++++++++++++++++
 4 files changed, 30 insertions(+)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 071fb18dc57c..f97ad76e6f82 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1165,6 +1165,13 @@ promote_secondaries - BOOLEAN
 	promote a corresponding secondary IP address instead of
 	removing all the corresponding secondary IP addresses.
 
+drop_unicast_in_l2_multicast - BOOLEAN
+	Drop any unicast IP packets that are received in link-layer
+	multicast (or broadcast) frames.
+	This behavior (for multicast) is actually a SHOULD in RFC
+	1122, but is disabled by default for compatibility reasons.
+	Default: off (0)
+
 
 tag - INTEGER
 	Allows you to write a number, which can be used as required.
diff --git a/include/uapi/linux/ip.h b/include/uapi/linux/ip.h
index 411959405ab6..c0e594b209ff 100644
--- a/include/uapi/linux/ip.h
+++ b/include/uapi/linux/ip.h
@@ -164,6 +164,7 @@ enum
 	IPV4_DEVCONF_ROUTE_LOCALNET,
 	IPV4_DEVCONF_IGMPV2_UNSOLICITED_REPORT_INTERVAL,
 	IPV4_DEVCONF_IGMPV3_UNSOLICITED_REPORT_INTERVAL,
+	IPV4_DEVCONF_DROP_UNICAST_IN_L2_MULTICAST,
 	__IPV4_DEVCONF_MAX
 };
 
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index c6473f365ad1..b608407f96e7 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -2176,6 +2176,8 @@ static struct devinet_sysctl_table {
 					      "promote_secondaries"),
 		DEVINET_SYSCTL_FLUSHING_ENTRY(ROUTE_LOCALNET,
 					      "route_localnet"),
+		DEVINET_SYSCTL_FLUSHING_ENTRY(DROP_UNICAST_IN_L2_MULTICAST,
+					      "drop_unicast_in_l2_multicast"),
 	},
 };
 
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 652b92ebd7ba..5d5e03f9697b 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1727,6 +1727,26 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	if (res.type == RTN_BROADCAST)
 		goto brd_input;
 
+	/* RFC 1122 3.3.6:
+	 *
+	 *   When a host sends a datagram to a link-layer broadcast address,
+	 *   the IP destination address MUST be a legal IP broadcast or IP
+	 *   multicast address.
+	 *
+	 *   A host SHOULD silently discard a datagram that is received via
+	 *   a link-layer broadcast (see Section 2.4) but does not specify
+	 *   an IP multicast or broadcast destination address.
+	 *
+	 * This doesn't explicitly say L2 *broadcast*, but broadcast is in a
+	 * way a form of multicast and the most common use case for this is
+	 * 802.11 protecting against cross-station spoofing (the so-called
+	 * "hole-196" attack) so do it for both.
+	 */
+	if (IN_DEV_CONF_GET(in_dev, DROP_UNICAST_IN_L2_MULTICAST) &&
+	    (skb->pkt_type == PACKET_BROADCAST ||
+	     skb->pkt_type == PACKET_MULTICAST))
+		goto e_inval;
+
 	if (res.type == RTN_LOCAL) {
 		err = fib_validate_source(skb, saddr, daddr, tos,
 					  0, dev, in_dev, &itag);
-- 
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
