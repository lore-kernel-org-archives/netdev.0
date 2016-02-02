From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next] net: Add support for fill_slave_info to VRF device
Date: Tue,  2 Feb 2016 07:43:45 -0800
Message-ID: <1454427826-6444-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:32810 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933315AbcBBPn7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 10:43:59 -0500
Received: by mail-pf0-f174.google.com with SMTP id w123so14382818pfb.0
        for <netdev@vger.kernel.org>; Tue, 02 Feb 2016 07:43:57 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allows userspace to have direct access to VRF table association
versus looking up master device and its table.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 drivers/net/vrf.c            | 21 +++++++++++++++++++++
 include/uapi/linux/if_link.h |  8 ++++++++
 2 files changed, 29 insertions(+)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 66addb7a7911..76e1fc9d8748 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -877,6 +877,24 @@ static int vrf_fillinfo(struct sk_buff *skb,
 	return nla_put_u32(skb, IFLA_VRF_TABLE, vrf->tb_id);
 }
 
+static size_t vrf_get_slave_size(const struct net_device *bond_dev,
+				 const struct net_device *slave_dev)
+{
+	return nla_total_size(sizeof(u32));  /* IFLA_VRF_PORT_TABLE */
+}
+
+static int vrf_fill_slave_info(struct sk_buff *skb,
+			       const struct net_device *vrf_dev,
+			       const struct net_device *slave_dev)
+{
+	struct net_vrf *vrf = netdev_priv(vrf_dev);
+
+	if (nla_put_u32(skb, IFLA_VRF_PORT_TABLE, vrf->tb_id))
+		return -EMSGSIZE;
+
+	return 0;
+}
+
 static const struct nla_policy vrf_nl_policy[IFLA_VRF_MAX + 1] = {
 	[IFLA_VRF_TABLE] = { .type = NLA_U32 },
 };
@@ -890,6 +908,9 @@ static struct rtnl_link_ops vrf_link_ops __read_mostly = {
 	.validate	= vrf_validate,
 	.fill_info	= vrf_fillinfo,
 
+	.get_slave_size  = vrf_get_slave_size,
+	.fill_slave_info = vrf_fill_slave_info,
+
 	.newlink	= vrf_newlink,
 	.dellink	= vrf_dellink,
 	.setup		= vrf_setup,
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index a30b78090594..0a5dc5647cdb 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -401,6 +401,14 @@ enum {
 
 #define IFLA_VRF_MAX (__IFLA_VRF_MAX - 1)
 
+enum {
+	IFLA_VRF_PORT_UNSPEC,
+	IFLA_VRF_PORT_TABLE,
+	__IFLA_VRF_PORT_MAX
+};
+
+#define IFLA_VRF_PORT_MAX (__IFLA_VRF_PORT_MAX - 1)
+
 /* IPVLAN section */
 enum {
 	IFLA_IPVLAN_UNSPEC,
-- 
2.1.4
