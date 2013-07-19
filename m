From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/3] rtnl: export physical port id via RT netlink
Date: Fri, 19 Jul 2013 15:55:50 +0200
Message-ID: <1374242152-10325-3-git-send-email-jiri@resnulli.us>
References: <1374242152-10325-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, stephen@networkplumber.org,
	Narendra_K@Dell.com, bhutchings@solarflare.com,
	john.r.fastabend@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f47.google.com ([74.125.83.47]:43683 "EHLO
	mail-ee0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759320Ab3GSN4D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jul 2013 09:56:03 -0400
Received: by mail-ee0-f47.google.com with SMTP id e49so2363972eek.20
        for <netdev@vger.kernel.org>; Fri, 19 Jul 2013 06:56:01 -0700 (PDT)
In-Reply-To: <1374242152-10325-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/uapi/linux/if_link.h |  1 +
 net/core/rtnetlink.c         | 25 ++++++++++++++++++++++++-
 2 files changed, 25 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 03f6170..04c0e7a 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -143,6 +143,7 @@ enum {
 	IFLA_NUM_TX_QUEUES,
 	IFLA_NUM_RX_QUEUES,
 	IFLA_CARRIER,
+	IFLA_PHYS_PORT_ID,
 	__IFLA_MAX
 };
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 3de7408..2bd0e67 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -767,7 +767,8 @@ static noinline size_t if_nlmsg_size(const struct net_device *dev,
 	       + rtnl_vfinfo_size(dev, ext_filter_mask) /* IFLA_VFINFO_LIST */
 	       + rtnl_port_size(dev) /* IFLA_VF_PORTS + IFLA_PORT_SELF */
 	       + rtnl_link_get_size(dev) /* IFLA_LINKINFO */
-	       + rtnl_link_get_af_size(dev); /* IFLA_AF_SPEC */
+	       + rtnl_link_get_af_size(dev) /* IFLA_AF_SPEC */
+	       + nla_total_size(MAX_PHYS_PORT_ID_LEN); /* IFLA_PHYS_PORT_ID */
 }
 
 static int rtnl_vf_ports_fill(struct sk_buff *skb, struct net_device *dev)
@@ -846,6 +847,24 @@ static int rtnl_port_fill(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int rtnl_phys_port_id_fill(struct sk_buff *skb, struct net_device *dev)
+{
+	int err;
+	struct netdev_phys_port_id ppid;
+
+	if (!dev->netdev_ops->ndo_get_phys_port_id)
+		return 0;
+
+	err = dev->netdev_ops->ndo_get_phys_port_id(dev, &ppid);
+	if (err)
+		return err;
+
+	if (nla_put(skb, IFLA_PHYS_PORT_ID, ppid.id_len, ppid.id))
+		return -EMSGSIZE;
+
+	return 0;
+}
+
 static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 			    int type, u32 pid, u32 seq, u32 change,
 			    unsigned int flags, u32 ext_filter_mask)
@@ -913,6 +932,9 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 			goto nla_put_failure;
 	}
 
+	if (rtnl_phys_port_id_fill(skb, dev))
+		goto nla_put_failure;
+
 	attr = nla_reserve(skb, IFLA_STATS,
 			sizeof(struct rtnl_link_stats));
 	if (attr == NULL)
@@ -1113,6 +1135,7 @@ const struct nla_policy ifla_policy[IFLA_MAX+1] = {
 	[IFLA_PROMISCUITY]	= { .type = NLA_U32 },
 	[IFLA_NUM_TX_QUEUES]	= { .type = NLA_U32 },
 	[IFLA_NUM_RX_QUEUES]	= { .type = NLA_U32 },
+	[IFLA_PHYS_PORT_ID]	= { .type = NLA_BINARY, .len = MAX_PHYS_PORT_ID_LEN },
 };
 EXPORT_SYMBOL(ifla_policy);
 
-- 
1.8.1.4
