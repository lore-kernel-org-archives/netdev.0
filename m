From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: [PATCH 3/4] ipv4: add option to drop gratuitous ARP packets
Date: Fri, 10 Apr 2015 09:54:13 +0200
Message-ID: <1428652454-1224-3-git-send-email-johannes@sipsolutions.net>
References: <1428652454-1224-1-git-send-email-johannes@sipsolutions.net>
Cc: matti.gottlieb-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1428652454-1224-1-git-send-email-johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
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
index 0a4715253ac2..f6f32c21edaf 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1172,6 +1172,12 @@ drop_unicast_in_l2_multicast - BOOLEAN
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
index c0e594b209ff..fa0dd3a7e0f1 100644
--- a/include/uapi/linux/ip.h
+++ b/include/uapi/linux/ip.h
@@ -165,6 +165,7 @@ enum
 	IPV4_DEVCONF_IGMPV2_UNSOLICITED_REPORT_INTERVAL,
 	IPV4_DEVCONF_IGMPV3_UNSOLICITED_REPORT_INTERVAL,
 	IPV4_DEVCONF_DROP_UNICAST_IN_L2_MULTICAST,
+	IPV4_DEVCONF_DROP_GRATUITOUS_ARP,
 	__IPV4_DEVCONF_MAX
 };
 
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 5f5c674e130a..5487d5e5191e 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -715,6 +715,14 @@ static int arp_process(struct sk_buff *skb)
 	    (!IN_DEV_ROUTE_LOCALNET(in_dev) && ipv4_is_loopback(tip)))
 		goto out;
 
+ /*
+  *	For some 802.11 wireless deployments (and possibly other networks),
+  *	there will be an ARP proxy and gratuitous ARP frames are attacks
+  *	and thus should not be accepted.
+  */
+	if (IN_DEV_CONF_GET(in_dev, DROP_GRATUITOUS_ARP) && sip == tip)
+		goto out;
+
 /*
  *     Special case: We must set Frame Relay source Q.922 address
  */
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index b608407f96e7..3f2bd37e3d7e 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -2169,6 +2169,8 @@ static struct devinet_sysctl_table {
 					"igmpv2_unsolicited_report_interval"),
 		DEVINET_SYSCTL_RW_ENTRY(IGMPV3_UNSOLICITED_REPORT_INTERVAL,
 					"igmpv3_unsolicited_report_interval"),
+		DEVINET_SYSCTL_RW_ENTRY(DROP_GRATUITOUS_ARP,
+					"drop_gratuitous_arp"),
 
 		DEVINET_SYSCTL_FLUSHING_ENTRY(NOXFRM, "disable_xfrm"),
 		DEVINET_SYSCTL_FLUSHING_ENTRY(NOPOLICY, "disable_policy"),
-- 
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
