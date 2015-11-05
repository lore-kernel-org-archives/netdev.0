From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: [PATCH v3 4/4] ipv6: add option to drop unsolicited neighbor advertisements
Date: Thu,  5 Nov 2015 09:42:03 +0100
Message-ID: <1446712923-9136-4-git-send-email-johannes@sipsolutions.net>
References: <1446712923-9136-1-git-send-email-johannes@sipsolutions.net>
Cc: Julian Anastasov <ja-FgGsKACvmQM@public.gmane.org>,
	Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1446712923-9136-1-git-send-email-johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
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
index 428fb48a19fc..77992f1173c3 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1672,6 +1672,13 @@ drop_unicast_in_l2_multicast - BOOLEAN
 
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
index 34317cb6a6fc..9231bfdc7c92 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -56,6 +56,7 @@ struct ipv6_devconf {
 	__s32           ndisc_notify;
 	__s32		suppress_frag_ndisc;
 	__s32		accept_ra_mtu;
+	__s32		drop_unsolicited_na;
 	struct ipv6_stable_secret {
 		bool initialized;
 		struct in6_addr secret;
diff --git a/include/uapi/linux/ipv6.h b/include/uapi/linux/ipv6.h
index 4c413570efe8..ec117b65d5a5 100644
--- a/include/uapi/linux/ipv6.h
+++ b/include/uapi/linux/ipv6.h
@@ -175,6 +175,7 @@ enum {
 	DEVCONF_ACCEPT_RA_MIN_HOP_LIMIT,
 	DEVCONF_IGNORE_ROUTES_WITH_LINKDOWN,
 	DEVCONF_DROP_UNICAST_IN_L2_MULTICAST,
+	DEVCONF_DROP_UNSOLICITED_NA,
 	DEVCONF_MAX
 };
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 35f880bcf626..e7dd0a0c5126 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4673,6 +4673,7 @@ static inline void ipv6_store_devconf(struct ipv6_devconf *cnf,
 	/* we omit DEVCONF_STABLE_SECRET for now */
 	array[DEVCONF_USE_OIF_ADDRS_ONLY] = cnf->use_oif_addrs_only;
 	array[DEVCONF_DROP_UNICAST_IN_L2_MULTICAST] = cnf->drop_unicast_in_l2_multicast;
+	array[DEVCONF_DROP_UNSOLICITED_NA] = cnf->drop_unsolicited_na;
 }
 
 static inline size_t inet6_ifla6_size(void)
@@ -5742,6 +5743,13 @@ static struct addrconf_sysctl_table
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
index 3e0f855e1bea..12c84a53df4f 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -887,6 +887,7 @@ static void ndisc_recv_na(struct sk_buff *skb)
 				    offsetof(struct nd_msg, opt));
 	struct ndisc_options ndopts;
 	struct net_device *dev = skb->dev;
+	struct inet6_dev *idev = __in6_dev_get(dev);
 	struct inet6_ifaddr *ifp;
 	struct neighbour *neigh;
 
@@ -906,6 +907,14 @@ static void ndisc_recv_na(struct sk_buff *skb)
 		return;
 	}
 
+	/* For some 802.11 wireless deployments (and possibly other networks),
+	 * there will be a NA proxy and unsolicitd packets are attacks
+	 * and thus should not be accepted.
+	 */
+	if (!msg->icmph.icmp6_solicited && idev &&
+	    idev->cnf.drop_unsolicited_na)
+		return;
+
 	if (!ndisc_parse_options(msg->opt, ndoptlen, &ndopts)) {
 		ND_PRINTK(2, warn, "NS: invalid ND option\n");
 		return;
-- 
2.6.2

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
