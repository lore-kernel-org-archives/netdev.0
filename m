From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH v2 1/4] ipv4: add option to drop unicast encapsulated in L2 multicast
Date: Wed,  4 Nov 2015 17:22:04 +0100
Message-ID: <1446654127-26826-1-git-send-email-johannes@sipsolutions.net>
Cc: Julian Anastasov <ja@ssi.bg>,
	Johannes Berg <johannes.berg@intel.com>
To: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:35073 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965559AbbKDQWN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Nov 2015 11:22:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

In order to solve a problem with 802.11, the so-called hole-196 attack,
add an option (sysctl) called "drop_unicast_in_l2_multicast" which, if
enabled, causes the stack to drop IPv4 unicast packets encapsulated in
link-layer multi- or broadcast frames. Such frames can (as an attack)
be created by any member of the same wireless network and transmitted
as valid encrypted frames since the symmetric key for broadcast frames
is shared between all stations.

Additionally, enabling this option provides compliance with a SHOULD
clause of RFC 1122.

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 Documentation/networking/ip-sysctl.txt |  7 +++++++
 include/uapi/linux/ip.h                |  1 +
 net/ipv4/devinet.c                     |  2 ++
 net/ipv4/ip_input.c                    | 26 +++++++++++++++++++++++++-
 4 files changed, 35 insertions(+), 1 deletion(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 05915be86235..35c4c43dd8de 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1208,6 +1208,13 @@ promote_secondaries - BOOLEAN
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
index 08f894d2ddbd..584834f7e95c 100644
--- a/include/uapi/linux/ip.h
+++ b/include/uapi/linux/ip.h
@@ -165,6 +165,7 @@ enum
 	IPV4_DEVCONF_IGMPV2_UNSOLICITED_REPORT_INTERVAL,
 	IPV4_DEVCONF_IGMPV3_UNSOLICITED_REPORT_INTERVAL,
 	IPV4_DEVCONF_IGNORE_ROUTES_WITH_LINKDOWN,
+	IPV4_DEVCONF_DROP_UNICAST_IN_L2_MULTICAST,
 	__IPV4_DEVCONF_MAX
 };
 
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index cebd9d31e65a..dbbab28a52a4 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -2192,6 +2192,8 @@ static struct devinet_sysctl_table {
 					      "promote_secondaries"),
 		DEVINET_SYSCTL_FLUSHING_ENTRY(ROUTE_LOCALNET,
 					      "route_localnet"),
+		DEVINET_SYSCTL_FLUSHING_ENTRY(DROP_UNICAST_IN_L2_MULTICAST,
+					      "drop_unicast_in_l2_multicast"),
 	},
 };
 
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index b1209b63381f..a442b6bd9441 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -359,8 +359,32 @@ static int ip_rcv_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
 	rt = skb_rtable(skb);
 	if (rt->rt_type == RTN_MULTICAST) {
 		IP_UPD_PO_STATS_BH(net, IPSTATS_MIB_INMCAST, skb->len);
-	} else if (rt->rt_type == RTN_BROADCAST)
+	} else if (rt->rt_type == RTN_BROADCAST) {
 		IP_UPD_PO_STATS_BH(net, IPSTATS_MIB_INBCAST, skb->len);
+	} else {
+		struct in_device *in_dev = __in_dev_get_rcu(skb->dev);
+
+		/* RFC 1122 3.3.6:
+		 *
+		 *   When a host sends a datagram to a link-layer broadcast
+		 *   address, the IP destination address MUST be a legal IP
+		 *   broadcast or IP multicast address.
+		 *
+		 *   A host SHOULD silently discard a datagram that is received
+		 *   via a link-layer broadcast (see Section 2.4) but does not
+		 *   specify an IP multicast or broadcast destination address.
+		 *
+		 * This doesn't explicitly say L2 *broadcast*, but broadcast is
+		 * in a way a form of multicast and the most common use case for
+		 * this is 802.11 protecting against cross-station spoofing (the
+		 * so-called "hole-196" attack) so do it for both.
+		 */
+		if (in_dev &&
+		    IN_DEV_ORCONF(in_dev, DROP_UNICAST_IN_L2_MULTICAST) &&
+		    (skb->pkt_type == PACKET_BROADCAST ||
+		     skb->pkt_type == PACKET_MULTICAST))
+			goto drop;
+	}
 
 	return dst_input(skb);
 
-- 
2.6.2
