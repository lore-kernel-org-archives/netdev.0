From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: [PATCH 2/4] ipv6: add option to drop unicast encapsulated in L2 multicast
Date: Fri, 10 Apr 2015 09:54:12 +0200
Message-ID: <1428652454-1224-2-git-send-email-johannes@sipsolutions.net>
References: <1428652454-1224-1-git-send-email-johannes@sipsolutions.net>
Cc: matti.gottlieb-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1428652454-1224-1-git-send-email-johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

In order to solve a problem with 802.11, the so-called hole-196 attack,
add an option (sysctl) called "drop_unicast_in_l2_multicast" which, if
enabled, causes the stack to drop IPv6 unicast packets encapsulated in
link-layer multi- or broadcast frames. Such frames can (as an attack)
be created by any member of the same wireless network and transmitted
as valid encrypted frames since the symmetric key for broadcast frames
is shared between all stations.

Signed-off-by: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 Documentation/networking/ip-sysctl.txt |  6 ++++++
 include/linux/ipv6.h                   |  1 +
 include/uapi/linux/ipv6.h              |  1 +
 net/ipv6/addrconf.c                    |  8 ++++++++
 net/ipv6/ip6_input.c                   | 10 ++++++++++
 5 files changed, 26 insertions(+)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index f97ad76e6f82..0a4715253ac2 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1572,6 +1572,12 @@ stable_secret - IPv6 address
 
 	By default the stable secret is unset.
 
+drop_unicast_in_l2_multicast - BOOLEAN
+	Drop any unicast IPv6 packets that are received in link-layer
+	multicast (or broadcast) frames.
+
+	By default this is turned off.
+
 icmp/*:
 ratelimit - INTEGER
 	Limit the maximal rates for sending ICMPv6 packets.
diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 82806c60aa42..1ec287a37e1d 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -48,6 +48,7 @@ struct ipv6_devconf {
 	__s32		mc_forwarding;
 #endif
 	__s32		disable_ipv6;
+	__s32		drop_unicast_in_l2_multicast;
 	__s32		accept_dad;
 	__s32		force_tllao;
 	__s32           ndisc_notify;
diff --git a/include/uapi/linux/ipv6.h b/include/uapi/linux/ipv6.h
index 5efa54ae567c..5a7061d690cb 100644
--- a/include/uapi/linux/ipv6.h
+++ b/include/uapi/linux/ipv6.h
@@ -171,6 +171,7 @@ enum {
 	DEVCONF_USE_OPTIMISTIC,
 	DEVCONF_ACCEPT_RA_MTU,
 	DEVCONF_STABLE_SECRET,
+	DEVCONF_DROP_UNICAST_IN_L2_MULTICAST,
 	DEVCONF_MAX
 };
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 5c9e94cb1b2c..c017edf04f30 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4584,6 +4584,7 @@ static inline void ipv6_store_devconf(struct ipv6_devconf *cnf,
 	array[DEVCONF_ACCEPT_RA_FROM_LOCAL] = cnf->accept_ra_from_local;
 	array[DEVCONF_ACCEPT_RA_MTU] = cnf->accept_ra_mtu;
 	/* we omit DEVCONF_STABLE_SECRET for now */
+	array[DEVCONF_DROP_UNICAST_IN_L2_MULTICAST] = cnf->drop_unicast_in_l2_multicast;
 }
 
 static inline size_t inet6_ifla6_size(void)
@@ -5583,6 +5584,13 @@ static struct addrconf_sysctl_table
 			.proc_handler	= addrconf_sysctl_stable_secret,
 		},
 		{
+			.procname	= "drop_unicast_in_l2_multicast",
+			.data		= &ipv6_devconf.drop_unicast_in_l2_multicast,
+			.maxlen		= sizeof(int),
+			.mode		= 0644,
+			.proc_handler	= proc_dointvec,
+		},
+		{
 			/* sentinel */
 		}
 	},
diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index fb97f7f8d4ed..70066fd2d685 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -134,6 +134,16 @@ int ipv6_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt
 	    IPV6_ADDR_MC_SCOPE(&hdr->daddr) == 1)
 		goto err;
 
+	/* If enabled, drop unicast packets that were encapsulated in link-layer
+	 * multicast or broadcast to protected against the so-called "hole-196"
+	 * attack in 802.11 wireless.
+	 */
+	if (!ipv6_addr_is_multicast(&hdr->daddr) &&
+	    (skb->pkt_type == PACKET_BROADCAST ||
+	     skb->pkt_type == PACKET_MULTICAST) &&
+	    idev->cnf.drop_unicast_in_l2_multicast)
+		goto err;
+
 	/* RFC4291 2.7
 	 * Nodes must not originate a packet to a multicast address whose scope
 	 * field contains the reserved value 0; if such a packet is received, it
-- 
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
