From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: [PATCH 4/4] ipv6: add option to drop unsolicited neighbor advertisements
Date: Fri, 10 Apr 2015 09:54:14 +0200
Message-ID: <1428652454-1224-4-git-send-email-johannes@sipsolutions.net>
References: <1428652454-1224-1-git-send-email-johannes@sipsolutions.net>
Cc: matti.gottlieb-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1428652454-1224-1-git-send-email-johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

In certain 802.11 wireless deployments, there will be NA proxies
that use knowledge of the network to correctly answer requests.
To prevent unsolicitd advertisements on the shared medium from
being a problem, on such deployments wireless needs to drop them.

Enable this by providing an option called "drop_unsolicited_na".

Signed-off-by: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 Documentation/networking/ip-sysctl.txt | 7 +++++++
 include/linux/ipv6.h                   | 1 +
 include/uapi/linux/ipv6.h              | 1 +
 net/ipv6/addrconf.c                    | 8 ++++++++
 net/ipv6/ndisc.c                       | 9 +++++++++
 5 files changed, 26 insertions(+)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index f6f32c21edaf..b0981c586fc4 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1584,6 +1584,13 @@ drop_unicast_in_l2_multicast - BOOLEAN
 
 	By default this is turned off.
 
+drop_unsolicited_na - BOOLEAN
+	Drop all unsolicited neighbor advertisements, for example if there's
+	a known good NA proxy on the network and such frames need not be used
+	(or in the case of 802.11, must not be used to prevent attacks.)
+
+	By default this is turned off.
+
 icmp/*:
 ratelimit - INTEGER
 	Limit the maximal rates for sending ICMPv6 packets.
diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 1ec287a37e1d..cef258173a9d 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -54,6 +54,7 @@ struct ipv6_devconf {
 	__s32           ndisc_notify;
 	__s32		suppress_frag_ndisc;
 	__s32		accept_ra_mtu;
+	__s32		drop_unsolicited_na;
 	struct ipv6_stable_secret {
 		bool initialized;
 		struct in6_addr secret;
diff --git a/include/uapi/linux/ipv6.h b/include/uapi/linux/ipv6.h
index 5a7061d690cb..73d7f1df6fe1 100644
--- a/include/uapi/linux/ipv6.h
+++ b/include/uapi/linux/ipv6.h
@@ -172,6 +172,7 @@ enum {
 	DEVCONF_ACCEPT_RA_MTU,
 	DEVCONF_STABLE_SECRET,
 	DEVCONF_DROP_UNICAST_IN_L2_MULTICAST,
+	DEVCONF_DROP_UNSOLICITED_NA,
 	DEVCONF_MAX
 };
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index c017edf04f30..6d5a680085e8 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4585,6 +4585,7 @@ static inline void ipv6_store_devconf(struct ipv6_devconf *cnf,
 	array[DEVCONF_ACCEPT_RA_MTU] = cnf->accept_ra_mtu;
 	/* we omit DEVCONF_STABLE_SECRET for now */
 	array[DEVCONF_DROP_UNICAST_IN_L2_MULTICAST] = cnf->drop_unicast_in_l2_multicast;
+	array[DEVCONF_DROP_UNSOLICITED_NA] = cnf->drop_unsolicited_na;
 }
 
 static inline size_t inet6_ifla6_size(void)
@@ -5591,6 +5592,13 @@ static struct addrconf_sysctl_table
 			.proc_handler	= proc_dointvec,
 		},
 		{
+			.procname	= "drop_unsolicited_na",
+			.data		= &ipv6_devconf.drop_unsolicited_na,
+			.maxlen		= sizeof(int),
+			.mode		= 0644,
+			.proc_handler	= proc_dointvec,
+		},
+		{
 			/* sentinel */
 		}
 	},
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index c283827d60e2..7291b91e359b 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -868,6 +868,7 @@ static void ndisc_recv_na(struct sk_buff *skb)
 				    offsetof(struct nd_msg, opt));
 	struct ndisc_options ndopts;
 	struct net_device *dev = skb->dev;
+	struct inet6_dev *idev = __in6_dev_get(dev);
 	struct inet6_ifaddr *ifp;
 	struct neighbour *neigh;
 
@@ -887,6 +888,14 @@ static void ndisc_recv_na(struct sk_buff *skb)
 		return;
 	}
 
+	/* For some 802.11 wireless deployments (and possibly other networks),
+	 * there will be a NA proxy and unsolicitd packets are attacks
+	 * and thus should not be accepted.
+	 */
+	if (idev && idev->cnf.drop_unsolicited_na &&
+	    !msg->icmph.icmp6_solicited)
+		return;
+
 	if (!ndisc_parse_options(msg->opt, ndoptlen, &ndopts)) {
 		ND_PRINTK(2, warn, "NS: invalid ND option\n");
 		return;
-- 
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
