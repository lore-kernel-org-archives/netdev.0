From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: [PATCH v2 3/4] ipv4: add option to drop gratuitous ARP packets
Date: Wed,  4 Nov 2015 17:22:06 +0100
Message-ID: <1446654127-26826-3-git-send-email-johannes@sipsolutions.net>
References: <1446654127-26826-1-git-send-email-johannes@sipsolutions.net>
Cc: Julian Anastasov <ja-FgGsKACvmQM@public.gmane.org>,
	Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1446654127-26826-1-git-send-email-johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

In certain 802.11 wireless deployments, there will be ARP proxies
that use knowledge of the network to correctly answer requests.
To prevent gratuitous ARP frames on the shared medium from being
a problem, on such deployments wireless needs to drop them.

Enable this by providing an option called "drop_gratuitous_arp".

Signed-off-by: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 Documentation/networking/ip-sysctl.txt | 6 ++++++
 include/uapi/linux/ip.h                | 1 +
 net/ipv4/arp.c                         | 8 ++++++++
 net/ipv4/devinet.c                     | 2 ++
 4 files changed, 17 insertions(+)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index a2169651254e..428fb48a19fc 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1215,6 +1215,12 @@ drop_unicast_in_l2_multicast - BOOLEAN
 	1122, but is disabled by default for compatibility reasons.
 	Default: off (0)
 
+drop_gratuitous_arp - BOOLEAN
+	Drop all gratuitous ARP frames, for example if there's a known
+	good ARP proxy on the network and such frames need not be used
+	(or in the case of 802.11, must not be used to prevent attacks.)
+	Default: off (0)
+
 
 tag - INTEGER
 	Allows you to write a number, which can be used as required.
diff --git a/include/uapi/linux/ip.h b/include/uapi/linux/ip.h
index 584834f7e95c..f291569768dd 100644
--- a/include/uapi/linux/ip.h
+++ b/include/uapi/linux/ip.h
@@ -166,6 +166,7 @@ enum
 	IPV4_DEVCONF_IGMPV3_UNSOLICITED_REPORT_INTERVAL,
 	IPV4_DEVCONF_IGNORE_ROUTES_WITH_LINKDOWN,
 	IPV4_DEVCONF_DROP_UNICAST_IN_L2_MULTICAST,
+	IPV4_DEVCONF_DROP_GRATUITOUS_ARP,
 	__IPV4_DEVCONF_MAX
 };
 
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 59b3e0e8fd51..36006a59c7f0 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -735,6 +735,14 @@ static int arp_process(struct net *net, struct sock *sk, struct sk_buff *skb)
 	    (!IN_DEV_ROUTE_LOCALNET(in_dev) && ipv4_is_loopback(tip)))
 		goto out;
 
+ /*
+  *	For some 802.11 wireless deployments (and possibly other networks),
+  *	there will be an ARP proxy and gratuitous ARP frames are attacks
+  *	and thus should not be accepted.
+  */
+	if (IN_DEV_ORCONF(in_dev, DROP_GRATUITOUS_ARP) && sip == tip)
+		goto out;
+
 /*
  *     Special case: We must set Frame Relay source Q.922 address
  */
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index dbbab28a52a4..3d835313575e 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -2185,6 +2185,8 @@ static struct devinet_sysctl_table {
 					"igmpv3_unsolicited_report_interval"),
 		DEVINET_SYSCTL_RW_ENTRY(IGNORE_ROUTES_WITH_LINKDOWN,
 					"ignore_routes_with_linkdown"),
+		DEVINET_SYSCTL_RW_ENTRY(DROP_GRATUITOUS_ARP,
+					"drop_gratuitous_arp"),
 
 		DEVINET_SYSCTL_FLUSHING_ENTRY(NOXFRM, "disable_xfrm"),
 		DEVINET_SYSCTL_FLUSHING_ENTRY(NOPOLICY, "disable_policy"),
-- 
2.6.2

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
