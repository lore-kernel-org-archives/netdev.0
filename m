From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH v4 net-next 05/10] net/ncsi: Ethtool operation to get NCSI channel info
Date: Wed,  3 May 2017 14:44:36 +1000
Message-ID: <1493786681-27468-6-git-send-email-gwshan@linux.vnet.ibm.com>
References: <1493786681-27468-1-git-send-email-gwshan@linux.vnet.ibm.com>
Cc: joe@perches.com, kubakici@wp.pl, f.fainelli@gmail.com,
        davem@davemloft.net, Gavin Shan <gwshan@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:55027 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751606AbdECEqS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 00:46:18 -0400
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v434iGZW045396
        for <netdev@vger.kernel.org>; Wed, 3 May 2017 00:46:12 -0400
Received: from e23smtp02.au.ibm.com (e23smtp02.au.ibm.com [202.81.31.144])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2a77pg1hhk-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 03 May 2017 00:46:12 -0400
Received: from localhost
        by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
        Wed, 3 May 2017 14:46:09 +1000
Received: from d23av06.au.ibm.com (d23av06.au.ibm.com [9.190.235.151])
        by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v434jw7d46334020
        for <netdev@vger.kernel.org>; Wed, 3 May 2017 14:46:06 +1000
Received: from d23av06.au.ibm.com (localhost [127.0.0.1])
        by d23av06.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v434jXef024748
        for <netdev@vger.kernel.org>; Wed, 3 May 2017 14:45:33 +1000
In-Reply-To: <1493786681-27468-1-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds ethtool command (ETHTOOL_GNCSICINFO) to retrieve the
NCSI channel information for the specified one. The simplified
output of this command is shown as follows from the modified
(private) ethtool:

 # ethtool --ncsi eth0 info
 NCSI channel 0:0 version:
   version:        00000000
   alpha2:         00000000
   f/w name:
   f/w version:    00000000
   PCI IDs:        0000 0000 0000 0000
   Manufacture ID: 00000000

   Generic capability:   0000000f (0000000f)
   Multicast capability: 00000007 (00000000)
   Buffer capability:    00004000
   AEN capability:       00000007 (00000000)
   VLAN capability:      00000007 (00000000)
   Filters:              VLAN (2), Mixed (0), MC (2), UC (4)

   Link status:             000ff66b 00000000 00000000
   MAC filter entries:
   00:00:00:00:00:00
   48:c4:b6:f0:a6:d4
   b6:fa:8f:70:00:00
   00:00:00:01:07:34
   VLAN filter entries:
   0004
   bc84

Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
---
 include/linux/ethtool.h      |   2 +
 include/uapi/linux/ethtool.h | 151 +++++++++++++++++++++++++++++++++++++++++++
 net/core/ethtool.c           |  22 +++++++
 net/ncsi/ncsi-ethtool.c      | 120 ++++++++++++++++++++++++++++++++++
 4 files changed, 295 insertions(+)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 720bb4d..5704b8b 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -376,5 +376,7 @@ struct ethtool_ops {
 				      const struct ethtool_link_ksettings *);
 	int	(*get_ncsi_channels)(struct net_device *,
 				     struct ethtool_ncsi_channels *);
+	int	(*get_ncsi_channel_info)(struct net_device *,
+					 struct ethtool_ncsi_channel_info *);
 };
 #endif /* _LINUX_ETHTOOL_H */
diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index e43aacf..81fbd51 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -1332,6 +1332,7 @@ struct ethtool_per_queue_op {
 #define ETHTOOL_PHY_STUNABLE	0x0000004f /* Set PHY tunable configuration */
 
 #define ETHTOOL_GNCSICHANNELS	0x00000050 /* Get NCSI channels */
+#define ETHTOOL_GNCSICINFO	0x00000051 /* Get NCSI channel information */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
@@ -1780,4 +1781,154 @@ struct ethtool_ncsi_channels {
 #define ETHTOOL_NCSI_CHANNEL_ACTIVE	(1 << 8)
 #define ETHTOOL_NCSI_CHANNEL_FLAGS	0x100
 };
+
+/**
+ * struct ethtool_ncsi_channel_info - NCSI channel information
+ *
+ * @cmd: Command number = %ETHTOOL_GNCSICINFO
+ * @id:  NCSI channel identifier
+ * @version: BCD encoded NCSI version
+ * @alpha2: BCD encoded NCSI version
+ * @fw_name: Firmware name string
+ * @fw_version: Firmware version
+ * @pci_ids: PCI identifier
+ * @mf_id: Manufacture identifier
+ * @cap_generic: Generic capability list
+ * @cap_bc: Broadcast capability list
+ * @setting_bc: Broadcast filtering setting
+ * @cap_mc: Multicast capability list
+ * @setting_mc: Multicast filtering setting
+ * @cap_buf: Length of receive buffer
+ * @cap_aen: AEN capability list
+ * @setting_aen: AEN setting
+ * @cap_vlan: VLAN filtering capability list
+ * @setting_vlan: VLAN filltering setting
+ * @cap_vlan_filter: Number of VLAN filtering entries
+ * @cap_mixed_filter: Number of mixed filtering entries
+ * @cap_mc_filter: Number of multicast filtering entries
+ * @cap_uc_filter: Number of unicast filtering entries
+ * @link_status: Link status
+ * @link_other_ind: Link other indication
+ * @link_oem: Link OEM information
+ * @mac_valid_bits: Bitmap for valid MAC filtering entries
+ * @mac: MAC filtering entries
+ * @vlan_valid_bits: Bitmap for valid VLAN filtering entries
+ * @vlan: VLAN filtering entries
+ */
+struct ethtool_ncsi_channel_info {
+	__u32	cmd;
+	__u32	id;
+	__u32	version;
+	__u32	alpha2;
+	__u8	fw_name[12];
+	__u32	fw_version;
+	__u16	pci_ids[4];
+	__u32	mf_id;
+	__u32	cap_generic;
+#define ETHTOOL_NCSI_G_HWA             (1 << 0) /* HW arbitration           */
+#define ETHTOOL_NCSI_G_HDS             (1 << 1) /* HNC driver status change */
+#define ETHTOOL_NCSI_G_FC              (1 << 2) /* HNC to MC flow control   */
+#define ETHTOOL_NCSI_G_FC1             (1 << 3) /* MC to HNC flow control   */
+#define ETHTOOL_NCSI_G_MC              (1 << 4) /* Global MC filtering      */
+#define ETHTOOL_NCSI_G_HWA_MASK        0x60
+#define ETHTOOL_NCSI_G_HWA_UNKNOWN     0x00     /* Unknown HW arbitration   */
+#define ETHTOOL_NCSI_G_HWA_SUPPORT     0x20     /* Supported HW arbitration */
+#define ETHTOOL_NCSI_G_HWA_NOT_SUPPORT 0x40     /* No HW arbitration        */
+#define ETHTOOL_NCSI_G_HWA_RESERVED    0x60     /* Reserved HW arbitration  */
+#define ETHTOOL_NCSI_G_MASK            0x7f
+	__u32	cap_bc;
+	__u32	setting_bc;
+#define ETHTOOL_NCSI_BC_ARP            (1 << 0) /* ARP packet filtering     */
+#define ETHTOOL_NCSI_BC_DHCPC          (1 << 1) /* DHCP client filtering    */
+#define ETHTOOL_NCSI_BC_DHCPS          (1 << 2) /* DHCP server filtering    */
+#define ETHTOOL_NCSI_BC_NETBIOS        (1 << 3) /* NetBIOS packet filtering */
+#define ETHTOOL_NCSI_BC_MASK           0xf
+	__u32	cap_mc;
+	__u32	setting_mc;
+#define ETHTOOL_NCSI_MC_IPV6_NEIGHBOR     (1 << 0) /* IPv6 neighbor filter  */
+#define ETHTOOL_NCSI_MC_IPV6_ROUTER       (1 << 1) /* IPv6 router filter    */
+#define ETHTOOL_NCSI_MC_DHCPV6_RELAY      (1 << 2) /* DHCPv6 relay/server   */
+#define ETHTOOL_NCSI_MC_DHCPV6_WELL_KNOWN (1 << 3) /* DHCPv6 well-known MC  */
+#define ETHTOOL_NCSI_MC_IPV6_MLD          (1 << 4) /* IPv6 MLD filtering    */
+#define ETHTOOL_NCSI_MC_IPV6_NEIGHBOR_S   (1 << 5) /* IPv6 neighbour filter */
+#define ETHTOOL_NCSI_MC_MASK              0x3f
+	__u32	cap_buf;
+	__u32	cap_aen;
+	__u32	setting_aen;
+#define ETHTOOL_NCSI_AEN_LSC           (1 << 0) /* Link status change       */
+#define ETHTOOL_NCSI_AEN_CR            (1 << 1) /* Configuration required   */
+#define ETHTOOL_NCSI_AEN_HDS           (1 << 2) /* HNC driver status        */
+#define ETHTOOL_NCSI_AEN_MASK          0x07
+	__u32	cap_vlan;
+	__u32	setting_vlan;
+#define ETHTOOL_NCSI_VLAN_ONLY         (1 << 0) /* Filter VLAN packet only  */
+#define ETHTOOL_NCSI_VLAN_NO           (1 << 1) /* Filter VLAN and non-VLAN */
+#define ETHTOOL_NCSI_VLAN_ANY          (1 << 2) /* Filter Any-and-non-VLAN  */
+#define ETHTOOL_NCSI_VLAN_MASK         0x07
+	__u8	cap_vlan_filter;
+	__u8	cap_mixed_filter;
+	__u8	cap_mc_filter;
+	__u8	cap_uc_filter;
+	__u32	link_status;
+#define ETHTOOL_NCSI_LINK_UP               (1 << 0)  /* Link up or down       */
+#define ETHTOOL_NCSI_LINK_SPEED_MASK       0x1e      /* Link speed            */
+#define ETHTOOL_NCSI_LINK_SPEED_INVALID         0x0
+#define ETHTOOL_NCSI_LINK_SPEED_10BASE_T_H      0x2
+#define ETHTOOL_NCSI_LINK_SPEED_10BASE_T_F      0x4
+#define ETHTOOL_NCSI_LINK_SPEED_100BASE_TX_H    0x6
+#define ETHTOOL_NCSI_LINK_SPEED_100BASE_T4      0x8
+#define ETHTOOL_NCSI_LINK_SPEED_100BASE_TX_F    0xa
+#define ETHTOOL_NCSI_LINK_SPEED_1000BASE_T_H    0xc
+#define ETHTOOL_NCSI_LINK_SPEED_1000BASE_T_F    0xe
+#define ETHTOOL_NCSI_LINK_SPEED_10GBASE_T       0x10
+#define ETHTOOL_NCSI_LINK_SPEED_20G             0x12
+#define ETHTOOL_NCSI_LINK_SPEED_25G             0x14
+#define ETHTOOL_NCSI_LINK_SPEED_40G             0x16
+#define ETHTOOL_NCSI_LINK_SPEED_50G             0x18
+#define ETHTOOL_NCSI_LINK_SPEED_100G            0x1a
+#define ETHTOOL_NCSI_LINK_SPEED_2_5G            0x1c
+#define ETHTOOL_NCSI_LINK_SPEED_OPTIONAL        0x1e
+#define ETHTOOL_NCSI_LINK_AUTONEG_ENABLED  (1 << 5)  /* Enabled auto-neg      */
+#define ETHTOOL_NCSI_LINK_AUTONEG_DONE     (1 << 6)  /* Auto-neg is done      */
+#define ETHTOOL_NCSI_LINK_PARALLEL         (1 << 7)  /* Parallel detection    */
+#define ETHTOOL_NCSI_LINK_LPA_1000BASE_T_F (1 << 9)  /* LPA: 1000BASE_T_Full  */
+#define ETHTOOL_NCSI_LINK_LPA_1000BASE_T_H (1 << 10) /* LPA: 1000BASE_T_Half  */
+#define ETHTOOL_NCSI_LINK_LPA_100_T4       (1 << 11) /* LPA: 100T4            */
+#define ETHTOOL_NCSI_LINK_LPA_100BASE_TX_F (1 << 12) /* LPA: 100BASE_TX_Full  */
+#define ETHTOOL_NCSI_LINK_LPA_100BASE_TX_H (1 << 13) /* LPA: 100BASE_TX_Half  */
+#define ETHTOOL_NCSI_LINK_LPA_10BASE_T_F   (1 << 14) /* LPA: 10BASE_T_Full    */
+#define ETHTOOL_NCSI_LINK_LPA_10BASE_T_H   (1 << 15) /* LPA: 10BASE_T_Half    */
+#define ETHTOOL_NCSI_LINK_TX_FC            (1 << 16) /* Tx flow control       */
+#define ETHTOOL_NCSI_LINK_RX_FC            (1 << 17) /* Rx flow control       */
+#define ETHTOOL_NCSI_LINK_LPA_FC_MASK      0xc0000
+#define ETHTOOL_NCSI_LINK_LPA_FC_NONE      0x0
+#define ETHTOOL_NCSI_LINK_LPA_FC_SYNC      0x40000
+#define ETHTOOL_NCSI_LINK_LPA_FC_ASYNC     0x80000
+#define ETHTOOL_NCSI_LINK_SERDES           (1 << 20) /* SerDes used or not    */
+#define ETHTOOL_NCSI_LINK_OEM_VALID        (1 << 21)
+#define ETHTOOL_NCSI_LINK_ESPEED_MASK      0xff000000
+#define ETHTOOL_NCSI_LINK_ESPEED_INVALID          0x0
+#define ETHTOOL_NCSI_LINK_ESPEED_10BASE_T_H       0x01000000
+#define ETHTOOL_NCSI_LINK_ESPEED_10BASE_T_F       0x02000000
+#define ETHTOOL_NCSI_LINK_ESPEED_100BASE_TX_H     0x03000000
+#define ETHTOOL_NCSI_LINK_ESPEED_100BASE_T4       0x04000000
+#define ETHTOOL_NCSI_LINK_ESPEED_100BASE_TX_F     0x05000000
+#define ETHTOOL_NCSI_LINK_ESPEED_1000BASE_T_H     0x06000000
+#define ETHTOOL_NCSI_LINK_ESPEED_1000BASE_T_F     0x07000000
+#define ETHTOOL_NCSI_LINK_ESPEED_10GBASE_T        0x08000000
+#define ETHTOOL_NCSI_LINK_ESPEED_20G              0x09000000
+#define ETHTOOL_NCSI_LINK_ESPEED_25G              0x0a000000
+#define ETHTOOL_NCSI_LINK_ESPEED_40G              0x0b000000
+#define ETHTOOL_NCSI_LINK_ESPEED_50G              0x0c000000
+#define ETHTOOL_NCSI_LINK_ESPEED_100G             0x0d000000
+#define ETHTOOL_NCSI_LINK_ESPEED_2_5G             0x0e000000
+#define ETHTOOL_NCSI_LINK_ESPEED_OPTIONAL         0x0f000000
+	__u32	link_other_ind;
+#define ETHTOOL_NCSI_LINK_HNC_DRV_STATUS   (1 << 0)
+	__u32	link_oem;
+	__u32	mac_valid_bits;
+	__u8	mac[8][6];
+	__u32	vlan_valid_bits;
+	__u16	vlan[16];
+};
 #endif /* _UAPI_LINUX_ETHTOOL_H */
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 7644765..116ef10 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -793,6 +793,25 @@ static int ethtool_get_ncsi_channels(struct net_device *dev,
 	return ret;
 }
 
+static int ethtool_get_ncsi_channel_info(struct net_device *dev,
+					 void __user *useraddr)
+{
+	struct ethtool_ncsi_channel_info enci;
+	int ret;
+
+	if (!dev->ethtool_ops->get_ncsi_channel_info)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&enci, useraddr, sizeof(enci)))
+		return -EFAULT;
+
+	ret = dev->ethtool_ops->get_ncsi_channel_info(dev, &enci);
+	if (!ret && copy_to_user(useraddr, &enci, sizeof(enci)))
+		return -EFAULT;
+
+	return ret;
+}
+
 static void
 warn_incomplete_ethtool_legacy_settings_conversion(const char *details)
 {
@@ -2833,6 +2852,9 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_GNCSICHANNELS:
 		rc = ethtool_get_ncsi_channels(dev, useraddr);
 		break;
+	case ETHTOOL_GNCSICINFO:
+		rc = ethtool_get_ncsi_channel_info(dev, useraddr);
+		break;
 	default:
 		rc = -EOPNOTSUPP;
 	}
diff --git a/net/ncsi/ncsi-ethtool.c b/net/ncsi/ncsi-ethtool.c
index 747aab6..9eee5fb 100644
--- a/net/ncsi/ncsi-ethtool.c
+++ b/net/ncsi/ncsi-ethtool.c
@@ -57,6 +57,124 @@ static int ncsi_get_channels(struct net_device *dev,
 	return 0;
 }
 
+static int ncsi_get_channel_info(struct net_device *dev,
+				 struct ethtool_ncsi_channel_info *enci)
+{
+	struct ncsi_dev *nd;
+	struct ncsi_dev_priv *ndp;
+	struct ncsi_channel *nc;
+	unsigned long flags;
+	int i;
+
+	nd = ncsi_find_dev(dev);
+	if (!nd)
+		return -ENXIO;
+
+	ndp = TO_NCSI_DEV_PRIV(nd);
+	ncsi_find_package_and_channel(ndp, enci->id, NULL, &nc);
+	if (!nc)
+		return -ENXIO;
+
+	spin_lock_irqsave(&nc->lock, flags);
+
+	/* NCSI channel's version */
+	enci->version = nc->version.version;
+	enci->alpha2 = nc->version.alpha2;
+	memcpy(enci->fw_name, nc->version.fw_name, 12);
+	enci->fw_version = nc->version.fw_version;
+	memcpy(enci->pci_ids, nc->version.pci_ids,
+	       4 * sizeof(enci->pci_ids[0]));
+	enci->mf_id = nc->version.mf_id;
+
+	/* NCSI channel's capabilities */
+	enci->cap_generic = (nc->caps[NCSI_CAP_GENERIC].cap &
+			     ETHTOOL_NCSI_G_MASK);
+	enci->cap_bc = (nc->caps[NCSI_CAP_BC].cap &
+			ETHTOOL_NCSI_BC_MASK);
+	enci->cap_mc = (nc->caps[NCSI_CAP_MC].cap &
+			ETHTOOL_NCSI_MC_MASK);
+	enci->cap_buf = nc->caps[NCSI_CAP_BUFFER].cap;
+	enci->cap_aen = (nc->caps[NCSI_CAP_AEN].cap &
+			 ETHTOOL_NCSI_AEN_MASK);
+	enci->cap_vlan = (nc->caps[NCSI_CAP_VLAN].cap &
+			  ETHTOOL_NCSI_VLAN_MASK);
+	for (i = NCSI_FILTER_BASE; i < NCSI_FILTER_MAX; i++) {
+		struct ncsi_channel_filter *ncf;
+		unsigned char *p_cap_filter;
+		unsigned int *p_valid_bits;
+		int entry_size, s_idx, d_idx;
+		void *dest;
+
+		switch (i) {
+		case NCSI_FILTER_VLAN:
+			p_cap_filter = &enci->cap_vlan_filter;
+			entry_size = 2;
+			p_valid_bits = &enci->vlan_valid_bits;
+			dest = enci->vlan;
+			d_idx = 0;
+			break;
+		case NCSI_FILTER_UC:
+			p_cap_filter = &enci->cap_uc_filter;
+			entry_size = 6;
+			p_valid_bits = &enci->mac_valid_bits;
+			dest = enci->mac;
+			d_idx = 0;
+			break;
+		case NCSI_FILTER_MC:
+			p_cap_filter = &enci->cap_mc_filter;
+			entry_size = 6;
+			break;
+		case NCSI_FILTER_MIXED:
+			p_cap_filter = &enci->cap_mixed_filter;
+			entry_size = 6;
+			break;
+		default:
+			continue;
+		}
+
+		*p_cap_filter = 0;
+		ncf = nc->filters[i];
+		if (!ncf)
+			continue;
+
+		*p_cap_filter = ncf->total;
+		s_idx = -1;
+		while ((s_idx = find_next_bit((void *)&ncf->bitmap,
+					      ncf->total, s_idx + 1))
+			< ncf->total) {
+			memcpy(dest + (d_idx * entry_size),
+			       ((void *)(ncf->data)) + (s_idx * entry_size),
+			       entry_size);
+			*p_valid_bits |= (1 << d_idx);
+
+			d_idx++;
+		}
+	}
+
+	/* NCSI channel's settings */
+	enci->setting_bc = nc->modes[NCSI_MODE_BC].enable ?
+			   nc->modes[NCSI_MODE_BC].data[0] : 0;
+	enci->setting_bc &= ETHTOOL_NCSI_BC_MASK;
+	enci->setting_mc = nc->modes[NCSI_MODE_MC].enable ?
+			   nc->modes[NCSI_MODE_MC].data[0] : 0;
+	enci->setting_mc &= ETHTOOL_NCSI_MC_MASK;
+	enci->setting_aen = nc->modes[NCSI_MODE_AEN].enable ?
+			    nc->modes[NCSI_MODE_AEN].data[0] : 0;
+	enci->setting_aen &= ETHTOOL_NCSI_AEN_MASK;
+	enci->setting_vlan = nc->modes[NCSI_MODE_VLAN].enable ?
+			     nc->modes[NCSI_MODE_VLAN].data[0] : 0;
+	enci->setting_vlan &= ETHTOOL_NCSI_VLAN_MASK;
+
+	/* NCSI channel's link status */
+	enci->link_status = nc->modes[NCSI_MODE_LINK].data[2];
+	enci->link_other_ind = nc->modes[NCSI_MODE_LINK].data[3];
+	enci->link_oem = nc->modes[NCSI_MODE_LINK].data[4];
+
+	spin_unlock_irqrestore(&nc->lock, flags);
+
+	return 0;
+}
+
 void ncsi_ethtool_register_dev(struct net_device *dev)
 {
 	struct ethtool_ops *ops;
@@ -66,6 +184,7 @@ void ncsi_ethtool_register_dev(struct net_device *dev)
 		return;
 
 	ops->get_ncsi_channels = ncsi_get_channels;
+	ops->get_ncsi_channel_info = ncsi_get_channel_info;
 }
 
 void ncsi_ethtool_unregister_dev(struct net_device *dev)
@@ -77,4 +196,5 @@ void ncsi_ethtool_unregister_dev(struct net_device *dev)
 		return;
 
 	ops->get_ncsi_channels = NULL;
+	ops->get_ncsi_channel_info = NULL;
 }
-- 
2.7.4
