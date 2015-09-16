From: Matteo Croce <matteo@openwrt.org>
Subject: [PATCH v4] add stealth mode
Date: Wed, 16 Sep 2015 11:54:19 +0200
Message-ID: <1442397259-28894-1-git-send-email-matteo@openwrt.org>
References: <20150915.120057.1457031142615117336.davem@davemloft.net>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Matteo Croce <matteo@openwrt.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150915.120057.1457031142615117336.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add option to disable any reply not related to a listening socket,
like RST/ACK for TCP and ICMP Port-Unreachable for UDP.
Also disables ICMP replies to echo request and timestamp.
The stealth mode can be enabled selectively for a single interface.

Signed-off-by: Matteo Croce <matteo@openwrt.org>
---
rebased on 4.3-rc1

 Documentation/networking/ip-sysctl.txt | 14 ++++++++++++++
 include/linux/inetdevice.h             |  1 +
 include/linux/ipv6.h                   |  1 +
 include/uapi/linux/ip.h                |  1 +
 net/ipv4/devinet.c                     |  1 +
 net/ipv4/icmp.c                        |  6 ++++++
 net/ipv4/ip_input.c                    |  5 +++--
 net/ipv4/tcp_ipv4.c                    |  3 ++-
 net/ipv4/udp.c                         |  4 +++-
 net/ipv6/addrconf.c                    |  7 +++++++
 net/ipv6/icmp.c                        |  3 ++-
 net/ipv6/ip6_input.c                   |  5 +++--
 net/ipv6/tcp_ipv6.c                    |  2 +-
 net/ipv6/udp.c                         |  3 ++-
 14 files changed, 47 insertions(+), 9 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index ebe94f2..1d46adc 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1206,6 +1206,13 @@ igmp_link_local_mcast_reports - BOOLEAN
 	224.0.0.X range.
 	Default TRUE
 
+stealth - BOOLEAN
+	Disable any reply not related to a listening socket,
+	like RST/ACK for TCP and ICMP Port-Unreachable for UDP.
+	Also disables ICMP replies to echo requests and timestamp
+	and ICMP errors for unknown protocols.
+	Default value is 0.
+
 Alexey Kuznetsov.
 kuznet@ms2.inr.ac.ru
 
@@ -1635,6 +1642,13 @@ stable_secret - IPv6 address
 
 	By default the stable secret is unset.
 
+stealth - BOOLEAN
+	Disable any reply not related to a listening socket,
+	like RST/ACK for TCP and ICMP Port-Unreachable for UDP.
+	Also disables ICMPv6 replies to echo requests
+	and ICMP errors for unknown protocols.
+	Default value is 0.
+
 icmp/*:
 ratelimit - INTEGER
 	Limit the maximal rates for sending ICMPv6 packets.
diff --git a/include/linux/inetdevice.h b/include/linux/inetdevice.h
index a4328ce..a64c01e 100644
--- a/include/linux/inetdevice.h
+++ b/include/linux/inetdevice.h
@@ -128,6 +128,7 @@ static inline void ipv4_devconf_setall(struct in_device *in_dev)
 #define IN_DEV_ARP_ANNOUNCE(in_dev)	IN_DEV_MAXCONF((in_dev), ARP_ANNOUNCE)
 #define IN_DEV_ARP_IGNORE(in_dev)	IN_DEV_MAXCONF((in_dev), ARP_IGNORE)
 #define IN_DEV_ARP_NOTIFY(in_dev)	IN_DEV_MAXCONF((in_dev), ARP_NOTIFY)
+#define IN_DEV_STEALTH(in_dev)		IN_DEV_MAXCONF((in_dev), STEALTH)
 
 struct in_ifaddr {
 	struct hlist_node	hash;
diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index f1f32af..a9d0172 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -55,6 +55,7 @@ struct ipv6_devconf {
 	__s32           ndisc_notify;
 	__s32		suppress_frag_ndisc;
 	__s32		accept_ra_mtu;
+	__s32		stealth;
 	struct ipv6_stable_secret {
 		bool initialized;
 		struct in6_addr secret;
diff --git a/include/uapi/linux/ip.h b/include/uapi/linux/ip.h
index 08f894d..4acbf99 100644
--- a/include/uapi/linux/ip.h
+++ b/include/uapi/linux/ip.h
@@ -165,6 +165,7 @@ enum
 	IPV4_DEVCONF_IGMPV2_UNSOLICITED_REPORT_INTERVAL,
 	IPV4_DEVCONF_IGMPV3_UNSOLICITED_REPORT_INTERVAL,
 	IPV4_DEVCONF_IGNORE_ROUTES_WITH_LINKDOWN,
+	IPV4_DEVCONF_STEALTH,
 	__IPV4_DEVCONF_MAX
 };
 
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 2d9cb17..6d9c080 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -2190,6 +2190,7 @@ static struct devinet_sysctl_table {
 					      "promote_secondaries"),
 		DEVINET_SYSCTL_FLUSHING_ENTRY(ROUTE_LOCALNET,
 					      "route_localnet"),
+		DEVINET_SYSCTL_RW_ENTRY(STEALTH, "stealth"),
 	},
 };
 
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 79fe05b..4cd35b2 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -889,6 +889,9 @@ static bool icmp_echo(struct sk_buff *skb)
 {
 	struct net *net;
 
+	if (IN_DEV_STEALTH(skb->dev->ip_ptr))
+		return true;
+
 	net = dev_net(skb_dst(skb)->dev);
 	if (!net->ipv4.sysctl_icmp_echo_ignore_all) {
 		struct icmp_bxm icmp_param;
@@ -922,6 +925,9 @@ static bool icmp_timestamp(struct sk_buff *skb)
 	if (skb->len < 4)
 		goto out_err;
 
+	if (IN_DEV_STEALTH(skb->dev->ip_ptr))
+		return true;
+
 	/*
 	 *	Fill in the current time as ms since midnight UT:
 	 */
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index f4fc8a7..e75f250 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -224,8 +224,9 @@ static int ip_local_deliver_finish(struct sock *sk, struct sk_buff *skb)
 			if (!raw) {
 				if (xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb)) {
 					IP_INC_STATS_BH(net, IPSTATS_MIB_INUNKNOWNPROTOS);
-					icmp_send(skb, ICMP_DEST_UNREACH,
-						  ICMP_PROT_UNREACH, 0);
+					if (!IN_DEV_STEALTH(skb->dev->ip_ptr))
+						icmp_send(skb, ICMP_DEST_UNREACH,
+							  ICMP_PROT_UNREACH, 0);
 				}
 				kfree_skb(skb);
 			} else {
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 93898e0..fe62ae0 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -77,6 +77,7 @@
 #include <net/busy_poll.h>
 
 #include <linux/inet.h>
+#include <linux/inetdevice.h>
 #include <linux/ipv6.h>
 #include <linux/stddef.h>
 #include <linux/proc_fs.h>
@@ -1652,7 +1653,7 @@ csum_error:
 		TCP_INC_STATS_BH(net, TCP_MIB_CSUMERRORS);
 bad_packet:
 		TCP_INC_STATS_BH(net, TCP_MIB_INERRS);
-	} else {
+	} else if (!IN_DEV_STEALTH(skb->dev->ip_ptr)) {
 		tcp_v4_send_reset(NULL, skb);
 	}
 
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index c0a15e7..033a051 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -96,6 +96,7 @@
 #include <linux/timer.h>
 #include <linux/mm.h>
 #include <linux/inet.h>
+#include <linux/inetdevice.h>
 #include <linux/netdevice.h>
 #include <linux/slab.h>
 #include <net/tcp_states.h>
@@ -1843,7 +1844,8 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 		goto csum_error;
 
 	UDP_INC_STATS_BH(net, UDP_MIB_NOPORTS, proto == IPPROTO_UDPLITE);
-	icmp_send(skb, ICMP_DEST_UNREACH, ICMP_PORT_UNREACH, 0);
+	if (!IN_DEV_STEALTH(skb->dev->ip_ptr))
+		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_PORT_UNREACH, 0);
 
 	/*
 	 * Hmm.  We got an UDP packet to a port to which we
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 030fefd..09d6baa 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -5713,6 +5713,13 @@ static struct addrconf_sysctl_table
 			.proc_handler	= addrconf_sysctl_ignore_routes_with_linkdown,
 		},
 		{
+			.procname	= "stealth",
+			.data		= &ipv6_devconf.stealth,
+			.maxlen		= sizeof(int),
+			.mode		= 0644,
+			.proc_handler	= proc_dointvec,
+		},
+		{
 			/* sentinel */
 		}
 	},
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 6c2b213..dbec4d76 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -723,7 +723,8 @@ static int icmpv6_rcv(struct sk_buff *skb)
 
 	switch (type) {
 	case ICMPV6_ECHO_REQUEST:
-		icmpv6_echo_reply(skb);
+		if (!idev->cnf.stealth)
+			icmpv6_echo_reply(skb);
 		break;
 
 	case ICMPV6_ECHO_REPLY:
diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index adba03a..0955db4 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -256,8 +256,9 @@ resubmit:
 			if (xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb)) {
 				IP6_INC_STATS_BH(net, idev,
 						 IPSTATS_MIB_INUNKNOWNPROTOS);
-				icmpv6_send(skb, ICMPV6_PARAMPROB,
-					    ICMPV6_UNK_NEXTHDR, nhoff);
+				if (!idev->cnf.stealth)
+					icmpv6_send(skb, ICMPV6_PARAMPROB,
+						    ICMPV6_UNK_NEXTHDR, nhoff);
 			}
 			kfree_skb(skb);
 		} else {
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 97d9314..50178ce 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1445,7 +1445,7 @@ csum_error:
 		TCP_INC_STATS_BH(net, TCP_MIB_CSUMERRORS);
 bad_packet:
 		TCP_INC_STATS_BH(net, TCP_MIB_INERRS);
-	} else {
+	} else if (!__in6_dev_get(skb->dev)->cnf.stealth) {
 		tcp_v6_send_reset(NULL, skb);
 	}
 
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 0aba654..f865aca 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -934,7 +934,8 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 		goto csum_error;
 
 	UDP6_INC_STATS_BH(net, UDP_MIB_NOPORTS, proto == IPPROTO_UDPLITE);
-	icmpv6_send(skb, ICMPV6_DEST_UNREACH, ICMPV6_PORT_UNREACH, 0);
+	if (!__in6_dev_get(skb->dev)->cnf.stealth)
+		icmpv6_send(skb, ICMPV6_DEST_UNREACH, ICMPV6_PORT_UNREACH, 0);
 
 	kfree_skb(skb);
 	return 0;
-- 
2.1.4
