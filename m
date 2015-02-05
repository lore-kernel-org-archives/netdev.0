From: David Ahern <dsahern@gmail.com>
Subject: [RFC PATCH 24/29] net: vrf: Add support to get/set vrf context on a device
Date: Wed,  4 Feb 2015 18:34:25 -0700
Message-ID: <1423100070-31848-25-git-send-email-dsahern@gmail.com>
References: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
Cc: ebiederm@xmission.com, David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:56189 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756373AbbBEBgO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 20:36:14 -0500
Received: by mail-ig0-f177.google.com with SMTP id z20so8375917igj.4
        for <netdev@vger.kernel.org>; Wed, 04 Feb 2015 17:36:13 -0800 (PST)
In-Reply-To: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 include/linux/netdevice.h    |  1 +
 include/uapi/linux/if_link.h |  1 +
 net/core/dev.c               | 28 ++++++++++++++++++++++++++++
 net/core/rtnetlink.c         | 12 ++++++++++++
 4 files changed, 42 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index f4a707263446..7d983f005622 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2922,6 +2922,7 @@ int dev_change_name(struct net_device *, const char *);
 int dev_set_alias(struct net_device *, const char *, size_t);
 int dev_change_net_namespace(struct net_device *, struct net *, const char *);
 int dev_set_mtu(struct net_device *, int);
+int dev_set_vrf(struct net_device *, __u32);
 void dev_set_group(struct net_device *, int);
 int dev_set_mac_address(struct net_device *, struct sockaddr *);
 int dev_change_carrier(struct net_device *, bool new_carrier);
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 0deee3eeddbf..0afdb50ee75c 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -147,6 +147,7 @@ enum {
 	IFLA_CARRIER_CHANGES,
 	IFLA_PHYS_SWITCH_ID,
 	IFLA_LINK_NETNSID,
+	IFLA_VRF,
 	__IFLA_MAX
 };
 
diff --git a/net/core/dev.c b/net/core/dev.c
index adf575d6d267..d96d0d46dc6e 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5882,6 +5882,34 @@ int dev_set_mtu(struct net_device *dev, int new_mtu)
 }
 EXPORT_SYMBOL(dev_set_mtu);
 
+ /**
+  *     dev_set_vrf - Change VRF
+  *     @dev: device
+  *     @new_vrf: new VRF
+  *
+  *     Change the VRF association for the network device.
+  */
+int dev_set_vrf(struct net_device *dev, __u32 new_vrf)
+{
+	if (!netif_device_present(dev))
+		return -ENODEV;
+
+	/* device needs to be taken down to drop routes */
+	if (dev->flags & IFF_UP)
+		return -EINVAL;
+
+	if (!vrf_is_valid(new_vrf))
+		return -EINVAL;
+
+	if (new_vrf == dev->nd_vrf)
+		return 0;
+
+	dev->nd_vrf = new_vrf;
+
+	return 0;
+}
+EXPORT_SYMBOL(dev_set_vrf);
+
 /**
  *	dev_set_group - Change group this device belongs to
  *	@dev: device
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 673cb4c6f391..bf41e63f87ae 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -866,6 +866,7 @@ static noinline size_t if_nlmsg_size(const struct net_device *dev,
 	       + nla_total_size(4) /* IFLA_TXQLEN */
 	       + nla_total_size(4) /* IFLA_WEIGHT */
 	       + nla_total_size(4) /* IFLA_MTU */
+	       + nla_total_size(4) /* IFLA_VRF */
 	       + nla_total_size(4) /* IFLA_LINK */
 	       + nla_total_size(4) /* IFLA_MASTER */
 	       + nla_total_size(1) /* IFLA_CARRIER */
@@ -1031,6 +1032,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 		       netif_running(dev) ? dev->operstate : IF_OPER_DOWN) ||
 	    nla_put_u8(skb, IFLA_LINKMODE, dev->link_mode) ||
 	    nla_put_u32(skb, IFLA_MTU, dev->mtu) ||
+	    nla_put_u32(skb, IFLA_VRF, dev->nd_vrf) ||
 	    nla_put_u32(skb, IFLA_GROUP, dev->group) ||
 	    nla_put_u32(skb, IFLA_PROMISCUITY, dev->promiscuity) ||
 	    nla_put_u32(skb, IFLA_NUM_TX_QUEUES, dev->num_tx_queues) ||
@@ -1249,6 +1251,7 @@ static const struct nla_policy ifla_policy[IFLA_MAX+1] = {
 	[IFLA_CARRIER_CHANGES]	= { .type = NLA_U32 },  /* ignored */
 	[IFLA_PHYS_SWITCH_ID]	= { .type = NLA_BINARY, .len = MAX_PHYS_ITEM_ID_LEN },
 	[IFLA_LINK_NETNSID]	= { .type = NLA_S32 },
+	[IFLA_VRF]		= { .type = NLA_U32 },
 };
 
 static const struct nla_policy ifla_info_policy[IFLA_INFO_MAX+1] = {
@@ -1616,6 +1619,13 @@ static int do_setlink(const struct sk_buff *skb,
 		status |= DO_SETLINK_MODIFIED;
 	}
 
+	if (tb[IFLA_VRF]) {
+		err = dev_set_vrf(dev, nla_get_u32(tb[IFLA_VRF]));
+		if (err < 0)
+			goto errout;
+		status |= DO_SETLINK_MODIFIED;
+	}
+
 	if (tb[IFLA_GROUP]) {
 		dev_set_group(dev, nla_get_u32(tb[IFLA_GROUP]));
 		status |= DO_SETLINK_NOTIFY;
@@ -1911,6 +1921,8 @@ struct net_device *rtnl_create_link(struct net *net,
 
 	if (tb[IFLA_MTU])
 		dev->mtu = nla_get_u32(tb[IFLA_MTU]);
+	if (tb[IFLA_VRF])
+		dev->nd_vrf = nla_get_u32(tb[IFLA_VRF]);
 	if (tb[IFLA_ADDRESS]) {
 		memcpy(dev->dev_addr, nla_data(tb[IFLA_ADDRESS]),
 				nla_len(tb[IFLA_ADDRESS]));
-- 
1.9.3 (Apple Git-50)
