From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: [PATCH net-next v2 3/5] bonding: add ad_info attribute netlink support
Date: Fri, 03 Jan 2014 14:18:56 -0800
Message-ID: <20140103221856.1659.68744.stgit@monster-03.cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	shm@cumulusnetworks.com, jiri@resnulli.us, dingtianhong@huawei.com
To: vfalico@redhat.com, fubar@us.ibm.com, andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:40101 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753392AbaACWZV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jan 2014 17:25:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add nested IFLA_BOND_AD_INFO for bonding 802.3ad info.

Signed-off-by: Scott Feldman <sfeldma@cumulusnetworks.com>
---
 drivers/net/bonding/bond_netlink.c |   38 ++++++++++++++++++++++++++++++++++++
 include/uapi/linux/if_link.h       |   12 +++++++++++
 2 files changed, 50 insertions(+)

diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index df66dd8..1b4013b 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -45,6 +45,7 @@ static const struct nla_policy bond_policy[IFLA_BOND_MAX + 1] = {
 	[IFLA_BOND_PACKETS_PER_SLAVE]	= { .type = NLA_U32 },
 	[IFLA_BOND_AD_LACP_RATE]	= { .type = NLA_U8 },
 	[IFLA_BOND_AD_SELECT]		= { .type = NLA_U8 },
+	[IFLA_BOND_AD_INFO]		= { .type = NLA_NESTED },
 };
 
 static int bond_validate(struct nlattr *tb[], struct nlattr *data[])
@@ -310,6 +311,12 @@ static size_t bond_get_size(const struct net_device *bond_dev)
 		nla_total_size(sizeof(u32)) +  /* IFLA_BOND_PACKETS_PER_SLAVE */
 		nla_total_size(sizeof(u8)) +	/* IFLA_BOND_AD_LACP_RATE */
 		nla_total_size(sizeof(u8)) +	/* IFLA_BOND_AD_SELECT */
+		nla_total_size(sizeof(struct nlattr)) + /* IFLA_BOND_AD_INFO */
+		nla_total_size(sizeof(u16)) + /* IFLA_BOND_AD_INFO_AGGREGATOR */
+		nla_total_size(sizeof(u16)) + /* IFLA_BOND_AD_INFO_NUM_PORTS */
+		nla_total_size(sizeof(u16)) + /* IFLA_BOND_AD_INFO_ACTOR_KEY */
+		nla_total_size(sizeof(u16)) + /* IFLA_BOND_AD_INFO_PARTNER_KEY*/
+		nla_total_size(ETH_ALEN) +    /* IFLA_BOND_AD_INFO_PARTNER_MAC*/
 		0;
 }
 
@@ -423,6 +430,37 @@ static int bond_fill_info(struct sk_buff *skb,
 		       bond->params.ad_select))
 		goto nla_put_failure;
 
+	if (bond->params.mode == BOND_MODE_8023AD) {
+		struct ad_info info;
+
+		if (!bond_3ad_get_active_agg_info(bond, &info)) {
+			struct nlattr *nest;
+
+			nest = nla_nest_start(skb, IFLA_BOND_AD_INFO);
+			if (!nest)
+				goto nla_put_failure;
+
+			if (nla_put_u16(skb, IFLA_BOND_AD_INFO_AGGREGATOR,
+					info.aggregator_id))
+				goto nla_put_failure;
+			if (nla_put_u16(skb, IFLA_BOND_AD_INFO_NUM_PORTS,
+					info.ports))
+				goto nla_put_failure;
+			if (nla_put_u16(skb, IFLA_BOND_AD_INFO_ACTOR_KEY,
+					info.actor_key))
+				goto nla_put_failure;
+			if (nla_put_u16(skb, IFLA_BOND_AD_INFO_PARTNER_KEY,
+					info.partner_key))
+				goto nla_put_failure;
+			if (nla_put(skb, IFLA_BOND_AD_INFO_PARTNER_MAC,
+				    sizeof(info.partner_system),
+				    &info.partner_system))
+				goto nla_put_failure;
+
+			nla_nest_end(skb, nest);
+		}
+	}
+
 	return 0;
 
 nla_put_failure:
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 0fbb018..3e6bd3c 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -351,11 +351,23 @@ enum {
 	IFLA_BOND_PACKETS_PER_SLAVE,
 	IFLA_BOND_AD_LACP_RATE,
 	IFLA_BOND_AD_SELECT,
+	IFLA_BOND_AD_INFO,
 	__IFLA_BOND_MAX,
 };
 
 #define IFLA_BOND_MAX	(__IFLA_BOND_MAX - 1)
 
+enum {
+	IFLA_BOND_AD_INFO_AGGREGATOR,
+	IFLA_BOND_AD_INFO_NUM_PORTS,
+	IFLA_BOND_AD_INFO_ACTOR_KEY,
+	IFLA_BOND_AD_INFO_PARTNER_KEY,
+	IFLA_BOND_AD_INFO_PARTNER_MAC,
+	__IFLA_BOND_AD_INFO_MAX,
+};
+
+#define IFLA_BOND_AD_INFO_MAX	(__IFLA_BOND_AD_INFO_MAX - 1)
+
 /* SR-IOV virtual function management section */
 
 enum {
