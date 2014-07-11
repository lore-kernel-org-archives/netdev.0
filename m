From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] ipv6: addrconf: implement address generation modes
Date: Fri, 11 Jul 2014 10:19:34 +0200
Message-ID: <1405066774-11740-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	sfeldma@cumulusnetworks.com, arvid.brodin@alten.se,
	sucheta.chakraborty@qlogic.com, hannes@stressinduktion.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f180.google.com ([74.125.82.180]:34404 "EHLO
	mail-we0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752291AbaGKIUd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jul 2014 04:20:33 -0400
Received: by mail-we0-f180.google.com with SMTP id x48so695384wes.25
        for <netdev@vger.kernel.org>; Fri, 11 Jul 2014 01:20:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch introduces a possibility for userspace to set various (so far
two) modes of generating addresses. This is useful for example for
NetworkManager because it can set the mode to NONE and take care of link
local addresses itself. That allow it to have the interface up,
monitoring carrier but still don't have any addresses on it.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/net/if_inet6.h       |  1 +
 include/uapi/linux/if_link.h |  6 +++++
 net/ipv6/addrconf.c          | 56 ++++++++++++++++++++++++++++++--------------
 3 files changed, 45 insertions(+), 18 deletions(-)

diff --git a/include/net/if_inet6.h b/include/net/if_inet6.h
index b4956a5..f82b281 100644
--- a/include/net/if_inet6.h
+++ b/include/net/if_inet6.h
@@ -206,6 +206,7 @@ struct inet6_dev {
 	__u8			rs_probes;
 
 	unsigned long		tstamp; /* ipv6InterfaceTable update timestamp */
+	enum in6_addr_gen_mode	addr_gen_mode;
 	struct rcu_head		rcu;
 };
 
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index b385348..ff95760 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -204,11 +204,17 @@ enum {
 	IFLA_INET6_CACHEINFO,	/* time values and max reasm size */
 	IFLA_INET6_ICMP6STATS,	/* statistics (icmpv6)		*/
 	IFLA_INET6_TOKEN,	/* device token			*/
+	IFLA_INET6_ADDR_GEN_MODE, /* implicit address generator mode */
 	__IFLA_INET6_MAX
 };
 
 #define IFLA_INET6_MAX	(__IFLA_INET6_MAX - 1)
 
+enum in6_addr_gen_mode {
+	IN6_ADDR_GEN_MODE_EUI64,
+	IN6_ADDR_GEN_MODE_NONE,
+};
+
 enum {
 	BRIDGE_MODE_UNSPEC,
 	BRIDGE_MODE_HAIRPIN,
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 358edd2..2c75ec1 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2730,9 +2730,25 @@ static void addrconf_add_linklocal(struct inet6_dev *idev, const struct in6_addr
 	}
 }
 
+static void addr_conf_addr_gen(struct inet6_dev *idev, bool prefix_route)
+{
+	if (idev->addr_gen_mode == IN6_ADDR_GEN_MODE_EUI64) {
+		struct in6_addr addr;
+
+		ipv6_addr_set(&addr,  htonl(0xFE800000), 0, 0, 0);
+		/* addrconf_add_linklocal also adds a prefix_route and we
+		 * only need to care about prefix routes if ipv6_generate_eui64
+		 * couldn't generate one.
+		 */
+		if (ipv6_generate_eui64(addr.s6_addr + 8, idev->dev) == 0)
+			addrconf_add_linklocal(idev, &addr);
+		else if (prefix_route)
+			addrconf_prefix_route(&addr, 64, idev->dev, 0, 0);
+	}
+}
+
 static void addrconf_dev_config(struct net_device *dev)
 {
-	struct in6_addr addr;
 	struct inet6_dev *idev;
 
 	ASSERT_RTNL();
@@ -2753,11 +2769,7 @@ static void addrconf_dev_config(struct net_device *dev)
 	if (IS_ERR(idev))
 		return;
 
-	memset(&addr, 0, sizeof(struct in6_addr));
-	addr.s6_addr32[0] = htonl(0xFE800000);
-
-	if (ipv6_generate_eui64(addr.s6_addr + 8, dev) == 0)
-		addrconf_add_linklocal(idev, &addr);
+	addr_conf_addr_gen(idev, false);
 }
 
 #if IS_ENABLED(CONFIG_IPV6_SIT)
@@ -2779,11 +2791,7 @@ static void addrconf_sit_config(struct net_device *dev)
 	}
 
 	if (dev->priv_flags & IFF_ISATAP) {
-		struct in6_addr addr;
-
-		ipv6_addr_set(&addr,  htonl(0xFE800000), 0, 0, 0);
-		if (!ipv6_generate_eui64(addr.s6_addr + 8, dev))
-			addrconf_add_linklocal(idev, &addr);
+		addr_conf_addr_gen(idev, false);
 		return;
 	}
 
@@ -2798,7 +2806,6 @@ static void addrconf_sit_config(struct net_device *dev)
 static void addrconf_gre_config(struct net_device *dev)
 {
 	struct inet6_dev *idev;
-	struct in6_addr addr;
 
 	ASSERT_RTNL();
 
@@ -2807,11 +2814,7 @@ static void addrconf_gre_config(struct net_device *dev)
 		return;
 	}
 
-	ipv6_addr_set(&addr,  htonl(0xFE800000), 0, 0, 0);
-	if (!ipv6_generate_eui64(addr.s6_addr + 8, dev))
-		addrconf_add_linklocal(idev, &addr);
-	else
-		addrconf_prefix_route(&addr, 64, dev, 0, 0);
+	addr_conf_addr_gen(idev, true);
 }
 #endif
 
@@ -4423,6 +4426,10 @@ static int inet6_fill_ifla6_attrs(struct sk_buff *skb, struct inet6_dev *idev)
 	nla = nla_reserve(skb, IFLA_INET6_TOKEN, sizeof(struct in6_addr));
 	if (nla == NULL)
 		goto nla_put_failure;
+
+	if (nla_put_u8(skb, IFLA_INET6_ADDR_GEN_MODE, idev->addr_gen_mode))
+		goto nla_put_failure;
+
 	read_lock_bh(&idev->lock);
 	memcpy(nla_data(nla), idev->token.s6_addr, nla_len(nla));
 	read_unlock_bh(&idev->lock);
@@ -4527,8 +4534,21 @@ static int inet6_set_link_af(struct net_device *dev, const struct nlattr *nla)
 	if (nla_parse_nested(tb, IFLA_INET6_MAX, nla, NULL) < 0)
 		BUG();
 
-	if (tb[IFLA_INET6_TOKEN])
+	if (tb[IFLA_INET6_TOKEN]) {
 		err = inet6_set_iftoken(idev, nla_data(tb[IFLA_INET6_TOKEN]));
+		if (err)
+			return err;
+	}
+
+	if (tb[IFLA_INET6_ADDR_GEN_MODE]) {
+		u8 mode = nla_get_u8(tb[IFLA_INET6_ADDR_GEN_MODE]);
+
+		if (mode != IN6_ADDR_GEN_MODE_EUI64 &&
+		    mode != IN6_ADDR_GEN_MODE_NONE)
+			return -EINVAL;
+		idev->addr_gen_mode = mode;
+		err = 0;
+	}
 
 	return err;
 }
-- 
1.9.0
