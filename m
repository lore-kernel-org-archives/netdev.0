From: Christian Benvenuti <benve@cisco.com>
Subject: [RFC][net-next-2.6 PATCH 2/2] Update enic drv to support
	IFLA_PORT_PROTO_* attributes
Date: Tue, 07 Dec 2010 20:32:33 -0800
Message-ID: <20101208043106.16856.78100.stgit@savbu-pc100.cisco.com>
References: <20101208042925.16856.89232.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:58624 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750916Ab0LHEcd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Dec 2010 23:32:33 -0500
In-Reply-To: <20101208042925.16856.89232.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christian Benvenuti <benve@cisco.com>

NOTE: Since there are other enic patches currently waiting for
      approval on netdev, I will update and re-send this patch
      should any of the other patches get accepted in the meantime.

Signed-off-by: Christian Benvenuti <benve@cisco.com>
Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: David Wang <dwang2@cisco.com>
---
 drivers/net/enic/enic.h      |    2 +
 drivers/net/enic/enic_main.c |   73 +++++++++++++++++++++++++++++++++++-------
 2 files changed, 62 insertions(+), 13 deletions(-)


diff --git a/drivers/net/enic/enic.h b/drivers/net/enic/enic.h
index 7067254..a930fb9 100644
--- a/drivers/net/enic/enic.h
+++ b/drivers/net/enic/enic.h
@@ -32,7 +32,7 @@
 
 #define DRV_NAME		"enic"
 #define DRV_DESCRIPTION		"Cisco VIC Ethernet NIC Driver"
-#define DRV_VERSION		"1.4.1.7"
+#define DRV_VERSION		"1.4.1.7nl"
 #define DRV_COPYRIGHT		"Copyright 2008-2010 Cisco Systems, Inc"
 
 #define ENIC_BARS_MAX		6
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index 9f293fa..c15c302 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -1223,24 +1223,14 @@ static int enic_set_port_profile(struct enic *enic, u8 *mac)
 	return 0;
 }
 
-static int enic_set_vf_port(struct net_device *netdev, int vf,
+static void enic_set_vf_port_parse_global_attr(struct enic *enic,
 	struct nlattr *port[])
 {
-	struct enic *enic = netdev_priv(netdev);
-
-	memset(&enic->pp, 0, sizeof(enic->pp));
-
 	if (port[IFLA_PORT_REQUEST]) {
 		enic->pp.set |= ENIC_SET_REQUEST;
 		enic->pp.request = nla_get_u8(port[IFLA_PORT_REQUEST]);
 	}
 
-	if (port[IFLA_PORT_PROFILE]) {
-		enic->pp.set |= ENIC_SET_NAME;
-		memcpy(enic->pp.name, nla_data(port[IFLA_PORT_PROFILE]),
-			PORT_PROFILE_MAX);
-	}
-
 	if (port[IFLA_PORT_INSTANCE_UUID]) {
 		enic->pp.set |= ENIC_SET_INSTANCE;
 		memcpy(enic->pp.instance_uuid,
@@ -1252,6 +1242,57 @@ static int enic_set_vf_port(struct net_device *netdev, int vf,
 		memcpy(enic->pp.host_uuid,
 			nla_data(port[IFLA_PORT_HOST_UUID]), PORT_UUID_MAX);
 	}
+}
+
+static void enic_set_vf_port_parse_legacy_attr(struct enic *enic,
+	struct nlattr *port[])
+{
+	if (port[IFLA_PORT_PROFILE]) {
+		enic->pp.set |= ENIC_SET_NAME;
+		memcpy(enic->pp.name, nla_data(port[IFLA_PORT_PROFILE]),
+			PORT_PROFILE_MAX);
+	}
+}
+
+static int enic_set_vf_port_parse_proto_attr(struct enic *enic,
+	struct nlattr *port[])
+{
+	struct nlattr *tb_8021qbh[IFLA_PORT_8021QBH_MAX+1];
+	int err = 0;
+
+	if (!port[IFLA_PORT_PROTO_8021QBH])
+		return -1;
+
+	err = rtnl_link_parse_port_proto(PORT_PROTO_8021QBH,
+					 port[IFLA_PORT_PROTO_8021QBH],
+					 tb_8021qbh);
+	if (err < 0)
+		goto errout;
+
+	if (tb_8021qbh[IFLA_PORT_8021QBH_PROFILE]) {
+		enic->pp.set |= ENIC_SET_NAME;
+		memcpy(enic->pp.name,
+		       nla_data(tb_8021qbh[IFLA_PORT_8021QBH_PROFILE]),
+		       PORT_PROFILE_MAX);
+	}
+
+errout:
+	return err;
+}
+
+static int enic_set_vf_port(struct net_device *netdev, int vf,
+	struct nlattr *port[])
+{
+	struct enic *enic = netdev_priv(netdev);
+	int err = 0;
+
+	memset(&enic->pp, 0, sizeof(enic->pp));
+
+	enic_set_vf_port_parse_global_attr(enic, port);
+
+	err = enic_set_vf_port_parse_proto_attr(enic, port);
+	if (err < 0)
+		enic_set_vf_port_parse_legacy_attr(enic, port);
 
 	/* don't support VFs, yet */
 	if (vf != PORT_SELF_VF)
@@ -1280,6 +1321,7 @@ static int enic_get_vf_port(struct net_device *netdev, int vf,
 	struct enic *enic = netdev_priv(netdev);
 	int err, error, done;
 	u16 response = PORT_PROFILE_RESPONSE_SUCCESS;
+	struct nlattr *proto;
 
 	if (!(enic->pp.set & ENIC_SET_APPLIED))
 		return -ENODATA;
@@ -1309,7 +1351,7 @@ static int enic_get_vf_port(struct net_device *netdev, int vf,
 
 	NLA_PUT_U16(skb, IFLA_PORT_REQUEST, enic->pp.request);
 	NLA_PUT_U16(skb, IFLA_PORT_RESPONSE, response);
-	if (enic->pp.set & ENIC_SET_NAME)
+	if (enic->pp.set & ENIC_SET_NAME) /* Deprecated */
 		NLA_PUT(skb, IFLA_PORT_PROFILE, PORT_PROFILE_MAX,
 			enic->pp.name);
 	if (enic->pp.set & ENIC_SET_INSTANCE)
@@ -1319,6 +1361,13 @@ static int enic_get_vf_port(struct net_device *netdev, int vf,
 		NLA_PUT(skb, IFLA_PORT_HOST_UUID, PORT_UUID_MAX,
 			enic->pp.host_uuid);
 
+	proto = nla_nest_start(skb, IFLA_PORT_PROTO_8021QBH);
+	if (proto == NULL)
+		goto nla_put_failure;
+	NLA_PUT(skb, IFLA_PORT_8021QBH_PROFILE, PORT_PROFILE_MAX,
+		enic->pp.name);
+	nla_nest_end(skb, proto);
+
 	return 0;
 
 nla_put_failure:

