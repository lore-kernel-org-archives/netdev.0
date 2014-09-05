From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 4/5] bridge: implement rtnl_link_ops->get_size and rtnl_link_ops->fill_info
Date: Fri,  5 Sep 2014 15:51:31 +0200
Message-ID: <1409925092-17808-5-git-send-email-jiri@resnulli.us>
References: <1409925092-17808-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, stephen@networkplumber.org,
	sfeldma@cumulusnetworks.com, arvid.brodin@alten.se,
	sucheta.chakraborty@qlogic.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:39652 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932273AbaIENvw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 09:51:52 -0400
Received: by mail-wi0-f171.google.com with SMTP id hi2so870395wib.16
        for <netdev@vger.kernel.org>; Fri, 05 Sep 2014 06:51:51 -0700 (PDT)
In-Reply-To: <1409925092-17808-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow rtnetlink users to get bridge master info in IFLA_INFO_DATA attr
This initial part implements forward_delay, hello_time, max_age options.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/uapi/linux/if_link.h | 12 ++++++++++++
 net/bridge/br_netlink.c      | 25 +++++++++++++++++++++++++
 2 files changed, 37 insertions(+)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index ff95760..c80f95f 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -215,6 +215,18 @@ enum in6_addr_gen_mode {
 	IN6_ADDR_GEN_MODE_NONE,
 };
 
+/* Bridge section */
+
+enum {
+	IFLA_BR_UNSPEC,
+	IFLA_BR_FORWARD_DELAY,
+	IFLA_BR_HELLO_TIME,
+	IFLA_BR_MAX_AGE,
+	__IFLA_BR_MAX,
+};
+
+#define IFLA_BR_MAX	(__IFLA_BR_MAX - 1)
+
 enum {
 	BRIDGE_MODE_UNSPEC,
 	BRIDGE_MODE_HAIRPIN,
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 05aeea1..bcac09f 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -484,6 +484,29 @@ static size_t br_port_get_slave_size(const struct net_device *brdev,
 	return br_port_info_size();
 }
 
+static size_t br_get_size(const struct net_device *brdev)
+{
+	return nla_total_size(sizeof(u32)) +	/* IFLA_BR_FORWARD_DELAY  */
+	       nla_total_size(sizeof(u32)) +	/* IFLA_BR_HELLO_TIME */
+	       nla_total_size(sizeof(u32)) +	/* IFLA_BR_MAX_AGE */
+	       0;
+}
+
+static int br_fill_info(struct sk_buff *skb, const struct net_device *brdev)
+{
+	struct net_bridge *br = netdev_priv(brdev);
+	u32 forward_delay = jiffies_to_clock_t(br->forward_delay);
+	u32 hello_time = jiffies_to_clock_t(br->hello_time);
+	u32 age_time = jiffies_to_clock_t(br->max_age);
+
+	if (nla_put_u32(skb, IFLA_BR_FORWARD_DELAY, forward_delay) ||
+	    nla_put_u32(skb, IFLA_BR_HELLO_TIME, hello_time) ||
+	    nla_put_u32(skb, IFLA_BR_MAX_AGE, age_time))
+		return -EMSGSIZE;
+
+	return 0;
+}
+
 static size_t br_get_link_af_size(const struct net_device *dev)
 {
 	struct net_port_vlans *pv;
@@ -514,6 +537,8 @@ struct rtnl_link_ops br_link_ops __read_mostly = {
 	.validate		= br_validate,
 	.newlink		= br_dev_newlink,
 	.dellink		= br_dev_delete,
+	.get_size		= br_get_size,
+	.fill_info		= br_fill_info,
 
 	.slave_maxtype		= IFLA_BRPORT_MAX,
 	.slave_policy		= br_port_policy,
-- 
1.9.3
