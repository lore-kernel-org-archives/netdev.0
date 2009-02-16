From: Santwona.Behera@Sun.COM
Subject: [PATCH 3/3] [NIU] Add support for RX packet classification in a
 network device
Date: Mon, 16 Feb 2009 09:17:36 -0800
Message-ID: <49999FB0.5000802@Sun.COM>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Boundary_(ID_ZK5s0ZmpWrannDcj1Jr2nQ)"
Cc: gkernel-commit@lists.sourceforge.net,
	Matheos Worku <Matheos.Worku@Sun.COM>,
	Mehdi Bonyadi <Mehdi.Bonyadi@Sun.COM>,
	Santwona Behera <Santwona.Behera@Sun.COM>
To: netdev@vger.kernel.org, davem@davemloft.net, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sca-es-mail-1.Sun.COM ([192.18.43.132]:34118 "EHLO
	sca-es-mail-1.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751041AbZBPRRn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Feb 2009 12:17:43 -0500
Received: from fe-sfbay-10.sun.com ([192.18.43.129])
	by sca-es-mail-1.sun.com (8.13.7+Sun/8.12.9) with ESMTP id n1GHHccI022493
	for <netdev@vger.kernel.org>; Mon, 16 Feb 2009 09:17:38 -0800 (PST)
Received: from conversion-daemon.fe-sfbay-10.sun.com by fe-sfbay-10.sun.com
 (Sun Java(tm) System Messaging Server 7.0-3.01 64bit (built Dec 23 2008))
 id <0KF600F0051TJJ00@fe-sfbay-10.sun.com> for netdev@vger.kernel.org; Mon,
 16 Feb 2009 09:17:38 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.

--Boundary_(ID_ZK5s0ZmpWrannDcj1Jr2nQ)
Content-type: text/plain; format=flowed; charset=ISO-8859-1
Content-transfer-encoding: 7BIT


--Boundary_(ID_ZK5s0ZmpWrannDcj1Jr2nQ)
Content-type: text/x-patch; name=niu-add-TCAM-class-config.patch
Content-transfer-encoding: 7BIT
Content-disposition: inline; filename=niu-add-TCAM-class-config.patch

From: Santwona Behera <santwona.behera@sun.com>
Subject: [PATCH 3/3] [NIU] Add TCAM classification configuration


Signed-off-by: Santwona Behera <santwona.behera@sun.com>
---
 drivers/net/niu.c |  699 +++++++++++++++++++++++++++++++++++++++++++++++++++--
 drivers/net/niu.h |   14 +-
 2 files changed, 686 insertions(+), 27 deletions(-)

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 0c0b752..4a690b3 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -2873,7 +2873,6 @@ static int tcam_user_ip_class_enable(struct niu *np, unsigned long class,
 	return 0;
 }
 
-#if 0
 static int tcam_user_ip_class_set(struct niu *np, unsigned long class,
 				  int ipv6, u64 protocol_id,
 				  u64 tos_mask, u64 tos_val)
@@ -2901,7 +2900,6 @@ static int tcam_user_ip_class_set(struct niu *np, unsigned long class,
 
 	return 0;
 }
-#endif
 
 static int tcam_early_init(struct niu *np)
 {
@@ -3168,6 +3166,27 @@ static int niu_set_tcam_key(struct niu *np, unsigned long class_code, u64 key)
 	return 0;
 }
 
+/* Entries for the ports are interleaved in the TCAM */
+static u16 tcam_get_index(struct niu *np, u16 idx)
+{
+	/* One entry reserved for IP fragment rule */
+	if (idx >= (np->clas.tcam_sz - 1))
+		idx = 0;
+	return (np->clas.tcam_top + ((idx+1) * np->parent->num_ports));
+}
+
+static u16 tcam_get_size(struct niu *np)
+{
+	/* One entry reserved for IP fragment rule */
+	return np->clas.tcam_sz - 1;
+}
+
+static u16 tcam_get_valid_entry_cnt(struct niu *np)
+{
+	/* One entry reserved for IP fragment rule */
+	return np->clas.tcam_valid_entries - 1;
+}
+
 static void niu_rx_skb_append(struct sk_buff *skb, struct page *page,
 			      u32 offset, u32 size)
 {
@@ -4890,8 +4909,7 @@ static int niu_set_ip_frag_rule(struct niu *np)
 	struct niu_tcam_entry *tp;
 	int index, err;
 
-	/* XXX fix this allocation scheme XXX */
-	index = cp->tcam_index;
+	index = cp->tcam_top;
 	tp = &parent->tcam[index];
 
 	/* Note that the noport bit is the same in both ipv4 and
@@ -4908,6 +4926,8 @@ static int niu_set_ip_frag_rule(struct niu *np)
 	err = tcam_assoc_write(np, index, tp->assoc_data);
 	if (err)
 		return err;
+	tp->valid = 1;
+	cp->tcam_valid_entries++;
 
 	return 0;
 }
@@ -6778,6 +6798,75 @@ static int niu_get_eeprom(struct net_device *dev,
 	return 0;
 }
 
+static void niu_ethflow_to_l3proto(int flow_type, u8 *pid)
+{
+	switch (flow_type) {
+	case TCP_V4_FLOW:
+	case TCP_V6_FLOW:
+		*pid = IPPROTO_TCP;
+		break;
+	case UDP_V4_FLOW:
+	case UDP_V6_FLOW:
+		*pid = IPPROTO_UDP;
+		break;
+	case SCTP_V4_FLOW:
+	case SCTP_V6_FLOW:
+		*pid = IPPROTO_SCTP;
+		break;
+	case AH_V4_FLOW:
+	case AH_V6_FLOW:
+		*pid = IPPROTO_AH;
+		break;
+	case ESP_V4_FLOW:
+	case ESP_V6_FLOW:
+		*pid = IPPROTO_ESP;
+		break;
+	default:
+		*pid = 0;
+		break;
+	}
+}
+
+static int niu_class_to_ethflow(u64 class, int *flow_type)
+{
+	switch (class) {
+	case CLASS_CODE_TCP_IPV4:
+		*flow_type = TCP_V4_FLOW;
+		break;
+	case CLASS_CODE_UDP_IPV4:
+		*flow_type = UDP_V4_FLOW;
+		break;
+	case CLASS_CODE_AH_ESP_IPV4:
+		*flow_type = AH_V4_FLOW;
+		break;
+	case CLASS_CODE_SCTP_IPV4:
+		*flow_type = SCTP_V4_FLOW;
+		break;
+	case CLASS_CODE_TCP_IPV6:
+		*flow_type = TCP_V6_FLOW;
+		break;
+	case CLASS_CODE_UDP_IPV6:
+		*flow_type = UDP_V6_FLOW;
+		break;
+	case CLASS_CODE_AH_ESP_IPV6:
+		*flow_type = AH_V6_FLOW;
+		break;
+	case CLASS_CODE_SCTP_IPV6:
+		*flow_type = SCTP_V6_FLOW;
+		break;
+	case CLASS_CODE_USER_PROG1:
+	case CLASS_CODE_USER_PROG2:
+	case CLASS_CODE_USER_PROG3:
+	case CLASS_CODE_USER_PROG4:
+		*flow_type = IP_USER_FLOW;
+		break;
+	default:
+		return 0;
+	}
+
+	return 1;
+}
+
 static int niu_ethflow_to_class(int flow_type, u64 *class)
 {
 	switch (flow_type) {
@@ -6787,7 +6876,8 @@ static int niu_ethflow_to_class(int flow_type, u64 *class)
 	case UDP_V4_FLOW:
 		*class = CLASS_CODE_UDP_IPV4;
 		break;
-	case AH_ESP_V4_FLOW:
+	case AH_V4_FLOW:
+	case ESP_V4_FLOW:
 		*class = CLASS_CODE_AH_ESP_IPV4;
 		break;
 	case SCTP_V4_FLOW:
@@ -6799,7 +6889,8 @@ static int niu_ethflow_to_class(int flow_type, u64 *class)
 	case UDP_V6_FLOW:
 		*class = CLASS_CODE_UDP_IPV6;
 		break;
-	case AH_ESP_V6_FLOW:
+	case AH_V6_FLOW:
+	case ESP_V6_FLOW:
 		*class = CLASS_CODE_AH_ESP_IPV6;
 		break;
 	case SCTP_V6_FLOW:
@@ -6816,8 +6907,6 @@ static u64 niu_flowkey_to_ethflow(u64 flow_key)
 {
 	u64 ethflow = 0;
 
-	if (flow_key & FLOW_KEY_PORT)
-		ethflow |= RXH_DEV_PORT;
 	if (flow_key & FLOW_KEY_L2DA)
 		ethflow |= RXH_L2DA;
 	if (flow_key & FLOW_KEY_VLAN)
@@ -6841,8 +6930,6 @@ static int niu_ethflow_to_flowkey(u64 ethflow, u64 *flow_key)
 {
 	u64 key = 0;
 
-	if (ethflow & RXH_DEV_PORT)
-		key |= FLOW_KEY_PORT;
 	if (ethflow & RXH_L2DA)
 		key |= FLOW_KEY_L2DA;
 	if (ethflow & RXH_VLAN)
@@ -6864,41 +6951,279 @@ static int niu_ethflow_to_flowkey(u64 ethflow, u64 *flow_key)
 
 }
 
-static int niu_get_hash_opts(struct net_device *dev, struct ethtool_rxnfc *cmd)
+static int niu_get_hash_opts(struct niu *np, struct ethtool_rxnfc *nfc)
 {
-	struct niu *np = netdev_priv(dev);
 	u64 class;
 
-	cmd->data = 0;
+	nfc->data = 0;
 
-	if (!niu_ethflow_to_class(cmd->flow_type, &class))
+	if (!niu_ethflow_to_class(nfc->flow_type, &class))
 		return -EINVAL;
 
 	if (np->parent->tcam_key[class - CLASS_CODE_USER_PROG1] &
 	    TCAM_KEY_DISC)
-		cmd->data = RXH_DISCARD;
+		nfc->data = RXH_DISCARD;
 	else
-
-		cmd->data = niu_flowkey_to_ethflow(np->parent->flow_key[class -
+		nfc->data = niu_flowkey_to_ethflow(np->parent->flow_key[class -
 						      CLASS_CODE_USER_PROG1]);
 	return 0;
 }
 
-static int niu_set_hash_opts(struct net_device *dev, struct ethtool_rxnfc *cmd)
+static void niu_get_ip4fs_from_tcam_key(struct niu_tcam_entry *tp,
+					struct ethtool_rx_flow_spec *fsp)
+{
+
+	fsp->h_u.tcp_ip4_spec.ip4src = (tp->key[3] & TCAM_V4KEY3_SADDR) >>
+		TCAM_V4KEY3_SADDR_SHIFT;
+	fsp->h_u.tcp_ip4_spec.ip4dst = (tp->key[3] & TCAM_V4KEY3_DADDR) >>
+		TCAM_V4KEY3_DADDR_SHIFT;
+	fsp->m_u.tcp_ip4_spec.ip4src = (tp->key_mask[3] & TCAM_V4KEY3_SADDR) >>
+		TCAM_V4KEY3_SADDR_SHIFT;
+	fsp->m_u.tcp_ip4_spec.ip4dst = (tp->key_mask[3] & TCAM_V4KEY3_DADDR) >>
+		TCAM_V4KEY3_DADDR_SHIFT;
+
+	fsp->h_u.tcp_ip4_spec.ip4src =
+		cpu_to_be32(fsp->h_u.tcp_ip4_spec.ip4src);
+	fsp->m_u.tcp_ip4_spec.ip4src =
+		cpu_to_be32(fsp->m_u.tcp_ip4_spec.ip4src);
+	fsp->h_u.tcp_ip4_spec.ip4dst =
+		cpu_to_be32(fsp->h_u.tcp_ip4_spec.ip4dst);
+	fsp->m_u.tcp_ip4_spec.ip4dst =
+		cpu_to_be32(fsp->m_u.tcp_ip4_spec.ip4dst);
+
+	fsp->h_u.tcp_ip4_spec.tos = (tp->key[2] & TCAM_V4KEY2_TOS) >>
+		TCAM_V4KEY2_TOS_SHIFT;
+	fsp->m_u.tcp_ip4_spec.tos = (tp->key_mask[2] & TCAM_V4KEY2_TOS) >>
+		TCAM_V4KEY2_TOS_SHIFT;
+
+	switch (fsp->flow_type) {
+	case TCP_V4_FLOW:
+	case UDP_V4_FLOW:
+	case SCTP_V4_FLOW:
+		fsp->h_u.tcp_ip4_spec.psrc =
+			((tp->key[2] & TCAM_V4KEY2_PORT_SPI) >>
+			 TCAM_V4KEY2_PORT_SPI_SHIFT) >> 16;
+		fsp->h_u.tcp_ip4_spec.pdst =
+			((tp->key[2] & TCAM_V4KEY2_PORT_SPI) >>
+			 TCAM_V4KEY2_PORT_SPI_SHIFT) & 0xffff;
+		fsp->m_u.tcp_ip4_spec.psrc =
+			((tp->key_mask[2] & TCAM_V4KEY2_PORT_SPI) >>
+			 TCAM_V4KEY2_PORT_SPI_SHIFT) >> 16;
+		fsp->m_u.tcp_ip4_spec.pdst =
+			((tp->key_mask[2] & TCAM_V4KEY2_PORT_SPI) >>
+			 TCAM_V4KEY2_PORT_SPI_SHIFT) & 0xffff;
+
+		fsp->h_u.tcp_ip4_spec.psrc =
+			cpu_to_be16(fsp->h_u.tcp_ip4_spec.psrc);
+		fsp->h_u.tcp_ip4_spec.pdst =
+			cpu_to_be16(fsp->h_u.tcp_ip4_spec.pdst);
+		fsp->m_u.tcp_ip4_spec.psrc =
+			cpu_to_be16(fsp->m_u.tcp_ip4_spec.psrc);
+		fsp->m_u.tcp_ip4_spec.pdst =
+			cpu_to_be16(fsp->m_u.tcp_ip4_spec.pdst);
+		break;
+	case AH_V4_FLOW:
+	case ESP_V4_FLOW:
+		fsp->h_u.ah_ip4_spec.spi =
+			(tp->key[2] & TCAM_V4KEY2_PORT_SPI) >>
+			TCAM_V4KEY2_PORT_SPI_SHIFT;
+		fsp->m_u.ah_ip4_spec.spi =
+			(tp->key_mask[2] & TCAM_V4KEY2_PORT_SPI) >>
+			TCAM_V4KEY2_PORT_SPI_SHIFT;
+
+		fsp->h_u.ah_ip4_spec.spi =
+			cpu_to_be32(fsp->h_u.ah_ip4_spec.spi);
+		fsp->m_u.ah_ip4_spec.spi =
+			cpu_to_be32(fsp->m_u.ah_ip4_spec.spi);
+		break;
+	case IP_USER_FLOW:
+		fsp->h_u.usr_ip4_spec.l4_4_bytes =
+			(tp->key[2] & TCAM_V4KEY2_PORT_SPI) >>
+			TCAM_V4KEY2_PORT_SPI_SHIFT;
+		fsp->m_u.usr_ip4_spec.l4_4_bytes =
+			(tp->key_mask[2] & TCAM_V4KEY2_PORT_SPI) >>
+			TCAM_V4KEY2_PORT_SPI_SHIFT;
+
+		fsp->h_u.usr_ip4_spec.l4_4_bytes =
+			cpu_to_be32(fsp->h_u.usr_ip4_spec.l4_4_bytes);
+		fsp->m_u.usr_ip4_spec.l4_4_bytes =
+			cpu_to_be32(fsp->m_u.usr_ip4_spec.l4_4_bytes);
+
+		fsp->h_u.usr_ip4_spec.proto =
+			(tp->key[2] & TCAM_V4KEY2_PROTO) >>
+			TCAM_V4KEY2_PROTO_SHIFT;
+		fsp->m_u.usr_ip4_spec.proto =
+			(tp->key_mask[2] & TCAM_V4KEY2_PROTO) >>
+			TCAM_V4KEY2_PROTO_SHIFT;
+
+		fsp->h_u.usr_ip4_spec.ip_ver = ETH_RX_NFC_IP4;
+		break;
+	default:
+		break;
+	}
+}
+
+static int niu_get_ethtool_tcam_entry(struct niu *np,
+				      struct ethtool_rxnfc *nfc)
+{
+	struct niu_parent *parent = np->parent;
+	struct niu_tcam_entry *tp;
+	struct ethtool_rx_flow_spec *fsp = &nfc->fs;
+	u16 idx;
+	u64 class;
+	int ret = 0;
+
+	idx = tcam_get_index(np, (u16)nfc->fs.location);
+
+	tp = &parent->tcam[idx];
+	if (!tp->valid) {
+		pr_info(PFX "niu%d: %s entry [%d] invalid for idx[%d]\n",
+		parent->index, np->dev->name, (u16)nfc->fs.location, idx);
+		return -EINVAL;
+	}
+
+	/* fill the flow spec entry */
+	class = (tp->key[0] & TCAM_V4KEY0_CLASS_CODE) >>
+		TCAM_V4KEY0_CLASS_CODE_SHIFT;
+	ret = niu_class_to_ethflow(class, &fsp->flow_type);
+
+	if (ret < 0) {
+		pr_info(PFX "niu%d: %s niu_class_to_ethflow failed\n",
+		parent->index, np->dev->name);
+		ret = -EINVAL;
+		goto out;
+	}
+
+	if (fsp->flow_type == AH_V4_FLOW || fsp->flow_type == AH_V6_FLOW) {
+		u32 proto = (tp->key[2] & TCAM_V4KEY2_PROTO) >>
+			TCAM_V4KEY2_PROTO_SHIFT;
+		if (proto == IPPROTO_ESP) {
+			if (fsp->flow_type == AH_V4_FLOW)
+				fsp->flow_type = ESP_V4_FLOW;
+			else
+				fsp->flow_type = ESP_V6_FLOW;
+		}
+	}
+
+	switch (fsp->flow_type) {
+	case TCP_V4_FLOW:
+	case UDP_V4_FLOW:
+	case SCTP_V4_FLOW:
+	case AH_V4_FLOW:
+	case ESP_V4_FLOW:
+		niu_get_ip4fs_from_tcam_key(tp, fsp);
+		break;
+	case TCP_V6_FLOW:
+	case UDP_V6_FLOW:
+	case SCTP_V6_FLOW:
+	case AH_V6_FLOW:
+	case ESP_V6_FLOW:
+		/* Not yet implemented */
+		ret = -EINVAL;
+		break;
+	case IP_USER_FLOW:
+		niu_get_ip4fs_from_tcam_key(tp, fsp);
+		break;
+	default:
+		ret = -EINVAL;
+		break;
+	}
+
+	if (ret < 0)
+		goto out;
+
+	if (tp->assoc_data & TCAM_ASSOCDATA_DISC)
+		fsp->ring_cookie = RX_CLS_FLOW_DISC;
+	else
+		fsp->ring_cookie = (tp->assoc_data & TCAM_ASSOCDATA_OFFSET) >>
+			TCAM_ASSOCDATA_OFFSET_SHIFT;
+
+	/* put the tcam size here */
+	nfc->data = tcam_get_size(np);
+out:
+	return ret;
+}
+
+static int niu_get_ethtool_tcam_all(struct niu *np,
+				    struct ethtool_rxnfc *nfc,
+				    u32 *rule_locs)
+{
+	struct niu_parent *parent = np->parent;
+	struct niu_tcam_entry *tp;
+	int i, idx, cnt;
+	u16 n_entries;
+	unsigned long flags;
+	
+
+	/* put the tcam size here */
+	nfc->data = tcam_get_size(np);
+
+	niu_lock_parent(np, flags);
+	n_entries = nfc->rule_cnt;
+	for (cnt = 0, i = 0; i < nfc->data; i++) {
+		idx = tcam_get_index(np, i);
+		tp = &parent->tcam[idx];
+		if (!tp->valid)
+			continue;
+		rule_locs[cnt] = i;
+		cnt++;
+	}
+	niu_unlock_parent(np, flags);
+
+	if (n_entries != cnt) {
+		/* print warning, this should not happen */
+		pr_info(PFX "niu%d: %s In niu_get_ethtool_tcam_all, "
+			"n_entries[%d] != cnt[%d]!!!\n\n",
+			np->parent->index, np->dev->name, n_entries, cnt);
+	}
+
+	return 0;
+}
+
+static int niu_get_nfc(struct net_device *dev, struct ethtool_rxnfc *cmd,
+		       void *rule_locs)
 {
 	struct niu *np = netdev_priv(dev);
+	int ret = 0;
+
+	switch (cmd->cmd) {
+	case ETHTOOL_GRXFH:
+		ret = niu_get_hash_opts(np, cmd);
+		break;
+	case ETHTOOL_GRXRINGS:
+		cmd->data = np->num_rx_rings;
+		break;
+	case ETHTOOL_GRXCLSRLCNT:
+		cmd->rule_cnt = tcam_get_valid_entry_cnt(np);
+		break;
+	case ETHTOOL_GRXCLSRULE:
+		ret = niu_get_ethtool_tcam_entry(np, cmd);
+		break;
+	case ETHTOOL_GRXCLSRLALL:
+		ret = niu_get_ethtool_tcam_all(np, cmd, (u32 *)rule_locs);
+		break;
+	default:
+		ret = -EINVAL;
+		break;
+	}
+
+	return ret;
+}
+
+static int niu_set_hash_opts(struct niu *np, struct ethtool_rxnfc *nfc)
+{
 	u64 class;
 	u64 flow_key = 0;
 	unsigned long flags;
 
-	if (!niu_ethflow_to_class(cmd->flow_type, &class))
+	if (!niu_ethflow_to_class(nfc->flow_type, &class))
 		return -EINVAL;
 
 	if (class < CLASS_CODE_USER_PROG1 ||
 	    class > CLASS_CODE_SCTP_IPV6)
 		return -EINVAL;
 
-	if (cmd->data & RXH_DISCARD) {
+	if (nfc->data & RXH_DISCARD) {
 		niu_lock_parent(np, flags);
 		flow_key = np->parent->tcam_key[class -
 					       CLASS_CODE_USER_PROG1];
@@ -6923,7 +7248,7 @@ static int niu_set_hash_opts(struct net_device *dev, struct ethtool_rxnfc *cmd)
 		}
 	}
 
-	if (!niu_ethflow_to_flowkey(cmd->data, &flow_key))
+	if (!niu_ethflow_to_flowkey(nfc->data, &flow_key))
 		return -EINVAL;
 
 	niu_lock_parent(np, flags);
@@ -6934,6 +7259,331 @@ static int niu_set_hash_opts(struct net_device *dev, struct ethtool_rxnfc *cmd)
 	return 0;
 }
 
+static void niu_get_tcamkey_from_ip4fs(struct ethtool_rx_flow_spec *fsp,
+				       struct niu_tcam_entry *tp,
+				       int l2_rdc_tab, u64 class)
+{
+	u8 pid = 0;
+	u32 sip, dip, sipm, dipm, spi, spim;
+	u16 sport, dport, spm, dpm;
+
+	sip = be32_to_cpu(fsp->h_u.tcp_ip4_spec.ip4src);
+	sipm = be32_to_cpu(fsp->m_u.tcp_ip4_spec.ip4src);
+	dip = be32_to_cpu(fsp->h_u.tcp_ip4_spec.ip4dst);
+	dipm = be32_to_cpu(fsp->m_u.tcp_ip4_spec.ip4dst);
+
+	tp->key[0] = class << TCAM_V4KEY0_CLASS_CODE_SHIFT;
+	tp->key_mask[0] = TCAM_V4KEY0_CLASS_CODE;
+	tp->key[1] = (u64)l2_rdc_tab << TCAM_V4KEY1_L2RDCNUM_SHIFT;
+	tp->key_mask[1] = TCAM_V4KEY1_L2RDCNUM;
+
+	tp->key[3] = (u64)sip << TCAM_V4KEY3_SADDR_SHIFT;
+	tp->key[3] |= dip;
+
+	tp->key_mask[3] = (u64)sipm << TCAM_V4KEY3_SADDR_SHIFT;
+	tp->key_mask[3] |= dipm;
+
+	tp->key[2] |= ((u64)fsp->h_u.tcp_ip4_spec.tos <<
+		       TCAM_V4KEY2_TOS_SHIFT);
+	tp->key_mask[2] |= ((u64)fsp->m_u.tcp_ip4_spec.tos <<
+			    TCAM_V4KEY2_TOS_SHIFT);
+	switch (fsp->flow_type) {
+	case TCP_V4_FLOW:
+	case UDP_V4_FLOW:
+	case SCTP_V4_FLOW:
+		sport = be16_to_cpu(fsp->h_u.tcp_ip4_spec.psrc);
+		spm = be16_to_cpu(fsp->m_u.tcp_ip4_spec.psrc);
+		dport = be16_to_cpu(fsp->h_u.tcp_ip4_spec.pdst);
+		dpm = be16_to_cpu(fsp->m_u.tcp_ip4_spec.pdst);
+
+		tp->key[2] |= (((u64)sport << 16) | dport);
+		tp->key_mask[2] |= (((u64)spm << 16) | dpm);
+		niu_ethflow_to_l3proto(fsp->flow_type, &pid);
+		break;
+	case AH_V4_FLOW:
+	case ESP_V4_FLOW:
+		spi = be32_to_cpu(fsp->h_u.ah_ip4_spec.spi);
+		spim = be32_to_cpu(fsp->m_u.ah_ip4_spec.spi);
+
+		tp->key[2] |= spi;
+		tp->key_mask[2] |= spim;
+		niu_ethflow_to_l3proto(fsp->flow_type, &pid);
+		break;
+	case IP_USER_FLOW:
+		spi = be32_to_cpu(fsp->h_u.usr_ip4_spec.l4_4_bytes);
+		spim = be32_to_cpu(fsp->m_u.usr_ip4_spec.l4_4_bytes);
+
+		tp->key[2] |= spi;
+		tp->key_mask[2] |= spim;
+		pid = fsp->h_u.usr_ip4_spec.proto;
+		break;
+	default:
+		break;
+	}
+
+	tp->key[2] |= ((u64)pid << TCAM_V4KEY2_PROTO_SHIFT);
+	if (pid) {
+		tp->key_mask[2] |= TCAM_V4KEY2_PROTO;
+	}
+}
+
+static int niu_add_ethtool_tcam_entry(struct niu *np,
+				      struct ethtool_rxnfc *nfc)
+{
+	struct niu_parent *parent = np->parent;
+	struct niu_tcam_entry *tp;
+	struct ethtool_rx_flow_spec *fsp = &nfc->fs;
+	struct niu_rdc_tables *rdc_table = &parent->rdc_group_cfg[np->port];
+	int l2_rdc_table = rdc_table->first_table_num;
+	u16 idx;
+	u64 class;
+	unsigned long flags;
+	int err, ret;
+
+	ret = 0;
+
+	idx = nfc->fs.location;
+	if (idx >= tcam_get_size(np))
+		return -EINVAL;
+
+	if (fsp->flow_type == IP_USER_FLOW) {
+		int i;
+		int add_usr_cls = 0;
+		int ipv6 = 0;
+		struct ethtool_usrip4_spec *uspec = &fsp->h_u.usr_ip4_spec;
+		struct ethtool_usrip4_spec *umask = &fsp->m_u.usr_ip4_spec;
+
+		niu_lock_parent(np, flags);
+
+		for (i = 0; i < NIU_L3_PROG_CLS; i++) {
+			if (parent->l3_cls[i]) {
+				if (uspec->proto == parent->l3_cls_pid[i]) {
+					class = parent->l3_cls[i];
+					parent->l3_cls_refcnt[i]++;
+					add_usr_cls = 1;
+					break;
+				}
+			} else {
+				/* Program new user IP class */
+				switch (i) {
+				case 0:
+					class = CLASS_CODE_USER_PROG1;
+					break;
+				case 1:
+					class = CLASS_CODE_USER_PROG2;
+					break;
+				case 2:
+					class = CLASS_CODE_USER_PROG3;
+					break;
+				case 3:
+					class = CLASS_CODE_USER_PROG4;
+					break;
+				default:
+					break;
+				}
+				if (uspec->ip_ver == ETH_RX_NFC_IP6)
+					ipv6 = 1;
+				ret = tcam_user_ip_class_set(np, class, ipv6,
+							     uspec->proto,
+							     uspec->tos,
+							     umask->tos);
+				if (ret)
+					goto out;
+
+				ret = tcam_user_ip_class_enable(np, class, 1);
+				if (ret)
+					goto out;
+				parent->l3_cls[i] = class;
+				parent->l3_cls_pid[i] = uspec->proto;
+				parent->l3_cls_refcnt[i]++;
+				add_usr_cls = 1;
+				break;
+			}
+		}
+		if (!add_usr_cls) {
+			pr_info(PFX "niu%d: %s niu_add_ethtool_tcam_entry: "
+				"Could not find/insert class for pid %d\n",
+				parent->index, np->dev->name, uspec->proto);
+			ret = -EINVAL;
+			goto out;
+		}
+		niu_unlock_parent(np, flags);
+	} else {
+		if (!niu_ethflow_to_class(fsp->flow_type, &class)) {
+			return -EINVAL;
+		}
+	}
+
+	niu_lock_parent(np, flags);
+
+	idx = tcam_get_index(np, idx);
+	tp = &parent->tcam[idx];
+
+	memset(tp, 0, sizeof(*tp));
+
+	/* fill in the tcam key and mask */
+	switch (fsp->flow_type) {
+	case TCP_V4_FLOW:
+	case UDP_V4_FLOW:
+	case SCTP_V4_FLOW:
+	case AH_V4_FLOW:
+	case ESP_V4_FLOW:
+		niu_get_tcamkey_from_ip4fs(fsp, tp, l2_rdc_table, class);
+		break;
+	case TCP_V6_FLOW:
+	case UDP_V6_FLOW:
+	case SCTP_V6_FLOW:
+	case AH_V6_FLOW:
+	case ESP_V6_FLOW:
+		/* Not yet implemented */
+		pr_info(PFX "niu%d: %s In niu_add_ethtool_tcam_entry: "
+			"flow %d for IPv6 not implemented\n\n",
+			parent->index, np->dev->name, fsp->flow_type);
+		ret = -EINVAL;
+		goto out;
+	case IP_USER_FLOW:
+		if (fsp->h_u.usr_ip4_spec.ip_ver == ETH_RX_NFC_IP4) {
+			niu_get_tcamkey_from_ip4fs(fsp, tp, l2_rdc_table,
+						   class);
+		} else {
+			/* Not yet implemented */
+			pr_info(PFX "niu%d: %s In niu_add_ethtool_tcam_entry: "
+			"usr flow for IPv6 not implemented\n\n",
+			parent->index, np->dev->name);
+			ret = -EINVAL;
+			goto out;
+		}
+		break;
+	default:
+		pr_info(PFX "niu%d: %s In niu_add_ethtool_tcam_entry: "
+			"Unknown flow type %d\n\n",
+			parent->index, np->dev->name, fsp->flow_type);
+		ret = -EINVAL;
+		goto out;
+	}
+
+	/* fill in the assoc data */
+	if (fsp->ring_cookie == RX_CLS_FLOW_DISC) {
+		tp->assoc_data = TCAM_ASSOCDATA_DISC;
+	} else {
+		if (fsp->ring_cookie >= np->num_rx_rings) {
+			pr_info(PFX "niu%d: %s In niu_add_ethtool_tcam_entry: "
+				"Invalid RX ring %lld\n\n",
+				parent->index, np->dev->name,
+				(long long) fsp->ring_cookie);
+			ret = -EINVAL;
+			goto out;
+		}
+		tp->assoc_data = (TCAM_ASSOCDATA_TRES_USE_OFFSET |
+				  (fsp->ring_cookie <<
+				   TCAM_ASSOCDATA_OFFSET_SHIFT));
+	}
+
+	err = tcam_write(np, idx, tp->key, tp->key_mask);
+	if (err) {
+		ret = -EINVAL;
+		goto out;
+	}
+	err = tcam_assoc_write(np, idx, tp->assoc_data);
+	if (err) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	/* validate the entry */
+	tp->valid = 1;
+	np->clas.tcam_valid_entries++;
+out:
+	niu_unlock_parent(np, flags);
+
+	return ret;
+}
+
+static int niu_del_ethtool_tcam_entry(struct niu *np, u32 loc)
+{
+	struct niu_parent *parent = np->parent;
+	struct niu_tcam_entry *tp;
+	u16 idx;
+	unsigned long flags;
+	u64 class;
+	int ret = 0;
+
+	if (loc >= tcam_get_size(np))
+		return -EINVAL;
+
+	niu_lock_parent(np, flags);
+
+	idx = tcam_get_index(np, loc);
+	tp = &parent->tcam[idx];
+
+	/* if the entry is of a user defined class, then update*/
+	class = (tp->key[0] & TCAM_V4KEY0_CLASS_CODE) >>
+		TCAM_V4KEY0_CLASS_CODE_SHIFT;
+
+	if (class >= CLASS_CODE_USER_PROG1 && class <= CLASS_CODE_USER_PROG4) {
+		int i;
+		for (i = 0; i < NIU_L3_PROG_CLS; i++) {
+			if (parent->l3_cls[i] == class) {
+				parent->l3_cls_refcnt[i]--;
+				if (!parent->l3_cls_refcnt[i]) {
+					/* disable class */
+					ret = tcam_user_ip_class_enable(np,
+									class,
+									0);
+					if (ret)
+						goto out;
+					parent->l3_cls[i] = 0;
+					parent->l3_cls_pid[i] = 0;
+				}
+				break;
+			}
+		}
+		if (i == NIU_L3_PROG_CLS) {
+			pr_info(PFX "niu%d: %s In niu_del_ethtool_tcam_entry,"
+				"Usr class 0x%llx not found \n",
+				parent->index, np->dev->name,
+				(unsigned long long) class);
+			ret = -EINVAL;
+			goto out;
+		}
+	}
+
+	ret = tcam_flush(np, idx);
+	if (ret)
+		goto out;
+
+	/* invalidate the entry */
+	tp->valid = 0;
+	np->clas.tcam_valid_entries--;
+out:
+	niu_unlock_parent(np, flags);
+
+	return ret;
+}
+
+static int niu_set_nfc(struct net_device *dev, struct ethtool_rxnfc *cmd)
+{
+	struct niu *np = netdev_priv(dev);
+	int ret = 0;
+
+	switch (cmd->cmd) {
+	case ETHTOOL_SRXFH:
+		ret = niu_set_hash_opts(np, cmd);
+		break;
+	case ETHTOOL_SRXCLSRLINS:
+		ret = niu_add_ethtool_tcam_entry(np, cmd);
+		break;
+	case ETHTOOL_SRXCLSRLDEL:
+		ret = niu_del_ethtool_tcam_entry(np, cmd->fs.location);
+		break;
+	default:
+		ret = -EINVAL;
+		break;
+	}
+
+	return ret;
+}
+
 static const struct {
 	const char string[ETH_GSTRING_LEN];
 } niu_xmac_stat_keys[] = {
@@ -7166,8 +7816,8 @@ static const struct ethtool_ops niu_ethtool_ops = {
 	.get_stats_count	= niu_get_stats_count,
 	.get_ethtool_stats	= niu_get_ethtool_stats,
 	.phys_id		= niu_phys_id,
-	.get_rxhash		= niu_get_hash_opts,
-	.set_rxhash		= niu_set_hash_opts,
+	.get_rxnfc		= niu_get_nfc,
+	.set_rxnfc		= niu_set_nfc,
 };
 
 static int niu_ldg_assign_ldn(struct niu *np, struct niu_parent *parent,
@@ -8237,7 +8887,8 @@ static int __devinit niu_classifier_swstate_init(struct niu *np)
 	niudbg(PROBE, "niu_classifier_swstate_init: num_tcam(%d)\n",
 	       np->parent->tcam_num_entries);
 
-	cp->tcam_index = (u16) np->port;
+	cp->tcam_top = (u16) np->port;
+	cp->tcam_sz = np->parent->tcam_num_entries / np->parent->num_ports;
 	cp->h1_init = 0xffffffff;
 	cp->h2_init = 0xffff;
 
diff --git a/drivers/net/niu.h b/drivers/net/niu.h
index e1a7392..f57e36d 100644
--- a/drivers/net/niu.h
+++ b/drivers/net/niu.h
@@ -3004,7 +3004,9 @@ struct niu_classifier {
 	struct niu_altmac_rdc	alt_mac_mappings[16];
 	struct niu_vlan_rdc	vlan_mappings[ENET_VLAN_TBL_NUM_ENTRIES];
 
-	u16			tcam_index;
+	u16			tcam_top;
+	u16			tcam_sz;
+	u16			tcam_valid_entries;
 	u16			num_alt_mac_mappings;
 
 	u32			h1_init;
@@ -3040,6 +3042,7 @@ struct phy_probe_info {
 };
 
 struct niu_tcam_entry {
+	u8			valid;
 	u64			key[4];
 	u64			key_mask[4];
 	u64			assoc_data;
@@ -3107,10 +3110,15 @@ struct niu_parent {
 	struct phy_probe_info	phy_probe_info;
 
 	struct niu_tcam_entry	tcam[NIU_TCAM_ENTRIES_MAX];
-	u64			l2_cls[2];
-	u64			l3_cls[4];
+
+#define	NIU_L2_PROG_CLS		2
+#define	NIU_L3_PROG_CLS		4
+	u64			l2_cls[NIU_L2_PROG_CLS];
+	u64			l3_cls[NIU_L3_PROG_CLS];
 	u64			tcam_key[12];
 	u64			flow_key[12];
+	u16			l3_cls_refcnt[NIU_L3_PROG_CLS];
+	u8			l3_cls_pid[NIU_L3_PROG_CLS];
 };
 
 struct niu_ops {
-- 
1.5.2


--Boundary_(ID_ZK5s0ZmpWrannDcj1Jr2nQ)--
