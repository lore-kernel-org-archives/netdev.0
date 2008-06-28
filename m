From: Santwona Behera <Santwona.Behera@Sun.COM>
Subject: [PATCH 3/3] Add support for rx flow hash configuration in a network
 device - [NIU driver]
Date: Fri, 27 Jun 2008 17:06:27 -0700
Message-ID: <48658083.1090709@Sun.COM>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Boundary_(ID_y6OLiKpsTbZR0XZl3khfpA)"
Cc: Matheos.Worku@Sun.COM, Michael.Speer@Sun.COM,
	gkernel-commit@lists.sourceforge.net, Santwona.Behera@Sun.COM
To: netdev@vger.kernel.org, davem@davemloft.net, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sca-es-mail-1.Sun.COM ([192.18.43.132]:54141 "EHLO
	sca-es-mail-1.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755903AbYF1AGa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2008 20:06:30 -0400
Received: from fe-sfbay-09.sun.com ([192.18.43.129])
	by sca-es-mail-1.sun.com (8.13.7+Sun/8.12.9) with ESMTP id m5S06TF4022030
	for <netdev@vger.kernel.org>; Fri, 27 Jun 2008 17:06:29 -0700 (PDT)
Received: from conversion-daemon.fe-sfbay-09.sun.com by fe-sfbay-09.sun.com
 (Sun Java System Messaging Server 6.2-8.04 (built Feb 28 2007))
 id <0K3500H01C5I4Z00@fe-sfbay-09.sun.com>
 (original mail from Santwona.Behera@Sun.COM) for netdev@vger.kernel.org; Fri,
 27 Jun 2008 17:06:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.

--Boundary_(ID_y6OLiKpsTbZR0XZl3khfpA)
Content-type: text/plain; format=flowed; charset=ISO-8859-1
Content-transfer-encoding: 7BIT


--Boundary_(ID_y6OLiKpsTbZR0XZl3khfpA)
Content-type: text/x-patch; name=niu_rx_flow_hash_cfg.patch
Content-transfer-encoding: 7BIT
Content-disposition: inline; filename=niu_rx_flow_hash_cfg.patch

From: Santwona Behera <santwona.behera@sun.com>

Implemented ethtool callback functions for configuring receive flow hashing in the niu driver.

Signed-off-by: Santwona Behera <santwona.behera@sun.com>
---
 drivers/net/niu.c |  158 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 158 insertions(+), 0 deletions(-)

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 918f802..f8035b1 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -6385,6 +6385,162 @@ static int niu_get_eeprom(struct net_device *dev,
 	return 0;
 }
 
+static int niu_ethflow_to_class(int flow_type, u64 *class)
+{
+	switch (flow_type) {
+	case TCP_V4_FLOW:
+		*class = CLASS_CODE_TCP_IPV4;
+		break;
+	case UDP_V4_FLOW:
+		*class = CLASS_CODE_UDP_IPV4;
+		break;
+	case AH_ESP_V4_FLOW:
+		*class = CLASS_CODE_AH_ESP_IPV4;
+		break;
+	case SCTP_V4_FLOW:
+		*class = CLASS_CODE_SCTP_IPV4;
+		break;
+	case TCP_V6_FLOW:
+		*class = CLASS_CODE_TCP_IPV6;
+		break;
+	case UDP_V6_FLOW:
+		*class = CLASS_CODE_UDP_IPV6;
+		break;
+	case AH_ESP_V6_FLOW:
+		*class = CLASS_CODE_AH_ESP_IPV6;
+		break;
+	case SCTP_V6_FLOW:
+		*class = CLASS_CODE_SCTP_IPV6;
+		break;
+	default:
+		return -1;
+	}
+
+	return 1;
+}
+
+static u64 niu_flowkey_to_ethflow(u64 flow_key)
+{
+	u64 ethflow = 0;
+
+	if (flow_key & FLOW_KEY_PORT)
+		ethflow |= RXH_DEV_PORT;
+	if (flow_key & FLOW_KEY_L2DA)
+		ethflow |= RXH_L2DA;
+	if (flow_key & FLOW_KEY_VLAN)
+		ethflow |= RXH_VLAN;
+	if (flow_key & FLOW_KEY_IPSA)
+		ethflow |= RXH_IP_SRC;
+	if (flow_key & FLOW_KEY_IPDA)
+		ethflow |= RXH_IP_DST;
+	if (flow_key & FLOW_KEY_PROTO)
+		ethflow |= RXH_L3_PROTO;
+	if (flow_key & (FLOW_KEY_L4_BYTE12 << FLOW_KEY_L4_0_SHIFT))
+		ethflow |= RXH_L4_B_0_1;
+	if (flow_key & (FLOW_KEY_L4_BYTE12 << FLOW_KEY_L4_1_SHIFT))
+		ethflow |= RXH_L4_B_2_3;
+
+	return ethflow;
+	
+}
+
+static int niu_ethflow_to_flowkey(u64 ethflow, u64 *flow_key)
+{
+	u64 key = 0;
+		
+	if (ethflow & RXH_DEV_PORT)
+		key |= FLOW_KEY_PORT;
+	if (ethflow & RXH_L2DA)
+		key |= FLOW_KEY_L2DA;
+	if (ethflow & RXH_VLAN)
+		key |= FLOW_KEY_VLAN;
+	if (ethflow & RXH_IP_SRC)
+		key |= FLOW_KEY_IPSA;
+	if (ethflow & RXH_IP_DST)
+		key |= FLOW_KEY_IPDA;
+	if (ethflow & RXH_L3_PROTO)
+		key |= FLOW_KEY_PROTO;
+	if (ethflow & RXH_L4_B_0_1)
+		key |= (FLOW_KEY_L4_BYTE12 << FLOW_KEY_L4_0_SHIFT);
+	if (ethflow & RXH_L4_B_2_3)
+		key |= (FLOW_KEY_L4_BYTE12 << FLOW_KEY_L4_1_SHIFT);
+
+	*flow_key = key;
+
+	return 1;
+	
+}
+
+static int niu_get_hash_opts(struct net_device *dev, struct ethtool_rxnfc *cmd)
+{
+	struct niu *np = netdev_priv(dev);
+	u64 class;
+
+	cmd->data = 0;
+
+	if (!niu_ethflow_to_class(cmd->flow_type, &class))
+		return -EINVAL;
+
+	if (np->parent->tcam_key[class - CLASS_CODE_USER_PROG1] &
+	    TCAM_KEY_DISC)
+		cmd->data = RXH_DISCARD;
+	else
+
+		cmd->data = niu_flowkey_to_ethflow(np->parent->flow_key[class -
+						      CLASS_CODE_USER_PROG1]);
+	return 0;
+}
+
+static int niu_set_hash_opts(struct net_device *dev, struct ethtool_rxnfc *cmd)
+{
+	struct niu *np = netdev_priv(dev);
+	u64 class;
+	u64 flow_key = 0;
+	unsigned long flags;
+
+	if (!niu_ethflow_to_class(cmd->flow_type, &class))
+		return -EINVAL;
+
+	if (class < CLASS_CODE_USER_PROG1 ||
+	    class > CLASS_CODE_SCTP_IPV6)
+		return -EINVAL;
+
+	if (cmd->data & RXH_DISCARD) {
+		niu_lock_parent(np, flags);
+		flow_key = np->parent->tcam_key[class -
+					       CLASS_CODE_USER_PROG1];
+		flow_key |= TCAM_KEY_DISC;
+		nw64(TCAM_KEY(class - CLASS_CODE_USER_PROG1), flow_key);
+		np->parent->tcam_key[class - CLASS_CODE_USER_PROG1] = flow_key;
+		niu_unlock_parent(np, flags);
+		return 0;
+	} else {
+		/* Discard was set before, but is not set now */
+		if (np->parent->tcam_key[class - CLASS_CODE_USER_PROG1] &
+		    TCAM_KEY_DISC) {
+			niu_lock_parent(np, flags);
+			flow_key = np->parent->tcam_key[class -
+					       CLASS_CODE_USER_PROG1];
+			flow_key &= ~TCAM_KEY_DISC;
+			nw64(TCAM_KEY(class - CLASS_CODE_USER_PROG1),
+			     flow_key);
+			np->parent->tcam_key[class - CLASS_CODE_USER_PROG1] =
+				flow_key;
+			niu_unlock_parent(np, flags);
+		}
+	}
+
+	if (!niu_ethflow_to_flowkey(cmd->data, &flow_key))
+		return -EINVAL;
+
+	niu_lock_parent(np, flags);
+	nw64(FLOW_KEY(class - CLASS_CODE_USER_PROG1), flow_key);
+	np->parent->flow_key[class - CLASS_CODE_USER_PROG1] = flow_key;
+	niu_unlock_parent(np, flags);
+
+	return 0;
+}
+
 static const struct {
 	const char string[ETH_GSTRING_LEN];
 } niu_xmac_stat_keys[] = {
@@ -6615,6 +6771,8 @@ static const struct ethtool_ops niu_ethtool_ops = {
 	.get_stats_count	= niu_get_stats_count,
 	.get_ethtool_stats	= niu_get_ethtool_stats,
 	.phys_id		= niu_phys_id,
+	.get_rxhash		= niu_get_hash_opts,
+	.set_rxhash		= niu_set_hash_opts,
 };
 
 static int niu_ldg_assign_ldn(struct niu *np, struct niu_parent *parent,
-- 
1.5.2


--Boundary_(ID_y6OLiKpsTbZR0XZl3khfpA)--
