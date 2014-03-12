From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/13] igb: Add debugfs command/register read and write functionality
Date: Tue, 11 Mar 2014 22:53:31 -0700
Message-ID: <1394603618-1044-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1394603618-1044-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Josh Hay <hayja@mail.uc.edu>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:20667 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755103AbaCLFxn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Mar 2014 01:53:43 -0400
In-Reply-To: <1394603618-1044-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch adds the functions to implement custom commands for debugfs.

Signed-off-by: Josh Hay <hayja@mail.uc.edu>
Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Jeff Pieper  <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_debugfs.c | 647 ++++++++++++++++++++++++++-
 1 file changed, 645 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_debugfs.c b/drivers/net/ethernet/intel/igb/igb_debugfs.c
index c38dd13..21e1879 100644
--- a/drivers/net/ethernet/intel/igb/igb_debugfs.c
+++ b/drivers/net/ethernet/intel/igb/igb_debugfs.c
@@ -31,6 +31,631 @@
 
 static struct dentry *igb_dbg_root;
 
+#define BUF_SIZE 256
+
+#define ASPMS_L1    2
+#define ASPMS_L0S   1
+#define ASPMS_NONE  0
+#define ASPMS_L1L0S (ASPMS_L1 | ASPMS_L0S)
+
+static char igb_dbg_reg_ops_buf[BUF_SIZE];
+static char igb_dbg_cmd_buf[BUF_SIZE];
+u32 txlpic;
+u32 rxlpic;
+
+/**
+ * igb_dbg_reg_ops_read - read from reg_ops datum
+ * @filep: the opened file
+ * @buffer: where to write the data for the user to read
+ * @count: size of the user's buffer
+ * @ppos: file position offset
+ **/
+static ssize_t igb_dbg_reg_ops_read(struct file *filep, char __user *buffer,
+				    size_t count, loff_t *ppos)
+{
+	struct igb_adapter *adapter = filep->private_data;
+	char *buf;
+	int len;
+
+	/* don't allow partial reads */
+	if (*ppos != 0)
+		return 0;
+
+	buf = kasprintf(GFP_KERNEL, "%s: %s\n", adapter->netdev->name,
+			igb_dbg_reg_ops_buf);
+	if (!buf)
+		return -ENOMEM;
+
+	if (count < strlen(buf)) {
+		kfree(buf);
+		return -ENOSPC;
+	}
+
+	len = simple_read_from_buffer(buffer, count, ppos, buf, strlen(buf));
+
+	kfree(buf);
+	return len;
+}
+
+/**
+ * igb_dbg_reg_ops write - write into reg_ops datum
+ * @filep: the opened file
+ * @buffer: where to write the data for the user to read
+ * @count: size of the user's buffer
+ * @ppos: file position offset
+ **/
+static ssize_t igb_dbg_reg_ops_write(struct file *filep,
+				     const char __user *buffer,
+				     size_t count, loff_t *ppos)
+{
+	struct igb_adapter *adapter = filep->private_data;
+	struct e1000_hw *hw = &adapter->hw;
+	int len;
+
+	/* don't allow partial writes */
+	if (*ppos != 0)
+		return 0;
+
+	if (count >= sizeof(igb_dbg_reg_ops_buf))
+		return -ENOSPC;
+
+	len = simple_write_to_buffer(igb_dbg_reg_ops_buf,
+				     sizeof(igb_dbg_reg_ops_buf) - 1,
+				     ppos, buffer, count);
+	if (len < 0)
+		return len;
+
+	igb_dbg_reg_ops_buf[len] = '\0';
+
+	if (strncmp(igb_dbg_reg_ops_buf, "write", 5) == 0) {
+		u32 reg, value;
+		int cnt;
+
+		cnt = sscanf(&igb_dbg_reg_ops_buf[5], "%x %x", &reg, &value);
+		if (cnt == 2) {
+			wr32(reg, value);
+			value = rd32(reg);
+			dev_info(&adapter->pdev->dev,
+				 "write: 0x%08x = 0x%08x\n",
+				 reg, value);
+		} else {
+			dev_info(&adapter->pdev->dev,
+				 "write: <reg> <value>\n");
+		}
+	} else if (strncmp(igb_dbg_reg_ops_buf, "read", 4) == 0) {
+		u32 reg, value;
+		int cnt;
+
+		cnt = sscanf(&igb_dbg_reg_ops_buf[4], "%x", &reg);
+		if (cnt == 1) {
+			value = rd32(reg);
+			dev_info(&adapter->pdev->dev,
+				 "read 0x%08x = 0x%08x\n",
+				 reg, value);
+		} else {
+			dev_info(&adapter->pdev->dev, "read <reg>\n");
+		}
+	} else {
+		dev_info(&adapter->pdev->dev, "Unknown command %s\n",
+			 igb_dbg_reg_ops_buf);
+		dev_info(&adapter->pdev->dev,
+			 "Available commands:\n");
+		dev_info(&adapter->pdev->dev, "\tread <reg>\n");
+		dev_info(&adapter->pdev->dev,
+			 "\twrite <reg> <value>\n");
+	}
+
+	return count;
+}
+
+static const struct file_operations igb_dbg_reg_ops_fops = {
+	.owner = THIS_MODULE,
+	.open = simple_open,
+	.read = igb_dbg_reg_ops_read,
+	.write = igb_dbg_reg_ops_write,
+};
+
+/**
+ * igb_dbg_show_usage - print list of available commands
+ * @pdev - pci_dev associated with
+ **/
+static void igb_dbg_show_usage(struct pci_dev *pdev)
+{
+	dev_info(&pdev->dev,
+		 "unknown command '%s'\n", igb_dbg_cmd_buf);
+	dev_info(&pdev->dev, "available commands:\n");
+	dev_info(&pdev->dev, "  query aspm support\n");
+	dev_info(&pdev->dev, "  query aspm status\n");
+	dev_info(&pdev->dev, "  aspm set <disable|L1|L0sL1>\n");
+	dev_info(&pdev->dev, "  query rx csum ofls\n");
+	dev_info(&pdev->dev, "  %s %s\n",
+		 "rx csum ofls <enable|disable>",
+		 "<all|[IPV4] [TCPUDP] [SCTP]>");
+	dev_info(&pdev->dev, "  dump rx packet stats\n");
+	dev_info(&pdev->dev, "  query eee\n");
+	dev_info(&pdev->dev, "  dump eee stats\n");
+	dev_info(&pdev->dev, "  dump itr\n");
+	dev_info(&pdev->dev, "  dump reset stats\n");
+	dev_info(&pdev->dev, "  reset stats\n");
+}
+
+/**
+ * igb_dbg_find_pcicap_reg - find the offset of the PCIe configuration
+ * register in the PCIe configuration header capabilities linked list
+ * @adapter - the igb_adapter created in command write
+ * @reg_name - name of the capability register in the PCIe config header
+ **/
+static u8 igb_dbg_find_pcicap_reg(struct igb_adapter *adapter, u8 reg_name)
+{
+	u8 cap_ptr = PCI_CAPABILITY_LIST;
+	u8 cap_id;
+	int ret;
+
+	ret = pci_read_config_byte(adapter->pdev, cap_ptr, &cap_ptr);
+	if (ret < 0) {
+		dev_err(&adapter->pdev->dev,
+			"Failed to read PCI capabilities list register.\n");
+		return ret;
+	}
+
+	while (cap_ptr != 0x00) {
+		ret = pci_read_config_byte(adapter->pdev, cap_ptr, &cap_id);
+		if (ret < 0) {
+			dev_err(&adapter->pdev->dev,
+				"Failed to read PCI capabilities ID reg.\n");
+			return ret;
+		}
+
+		if (cap_id == reg_name)
+			return cap_ptr;
+
+		ret = pci_read_config_byte(adapter->pdev,
+					   cap_ptr+PCI_CAP_LIST_NEXT, &cap_ptr);
+		if (ret < 0) {
+			dev_err(&adapter->pdev->dev,
+				"Failed to read PCI capabilities next reg\n");
+			return ret;
+		}
+	}
+
+	dev_err(&adapter->pdev->dev,
+		"PCI capability not supported.\n");
+
+	return 0;
+}
+
+static u8 igb_dbg_get_aspm_support(struct igb_adapter *adapter)
+{
+	u8 support;
+	u8 cap_offset;
+	u32 link_cap;
+	int ret;
+
+	cap_offset = igb_dbg_find_pcicap_reg(adapter, PCI_CAP_ID_EXP);
+
+	if (cap_offset <= 0)
+		return 0;
+
+	ret = pci_read_config_dword(adapter->pdev,
+				    cap_offset + PCI_EXP_LNKCAP,
+				    &link_cap);
+	if (ret < 0) {
+		dev_err(&adapter->pdev->dev,
+			"Failed to read PCI LinkCap register.\n");
+		return 0;
+	}
+
+	switch (link_cap & PCI_EXP_LNKCAP_ASPMS) {
+	case PCI_EXP_LNKCAP_ASPMS:
+		support = ASPMS_L1L0S;
+		break;
+	case (PCI_EXP_LNKCAP_ASPMS - ASPMS_L0S):
+		support = ASPMS_L1;
+		break;
+	case (PCI_EXP_LNKCAP_ASPMS - ASPMS_L1):
+		dev_err(&adapter->pdev->dev,
+			"Unable to set L0s support alone.\n");
+		support = ASPMS_L1L0S;
+		break;
+	case (PCI_EXP_LNKCAP_ASPMS - ASPMS_L1L0S):
+	default:
+		support = ASPMS_NONE;
+		break;
+	}
+
+	return support;
+}
+
+static void igb_dbg_parse_aspm_cmd(struct igb_adapter *adapter)
+{
+	struct pci_dev *pdev = adapter->pdev;
+	u8 cap_offset;
+	int ret;
+	u8 aspm_support;
+	u16 val;
+
+	cap_offset = igb_dbg_find_pcicap_reg(adapter, PCI_CAP_ID_EXP);
+	if (cap_offset <= 0)
+		return;
+
+	if (strncmp(&igb_dbg_cmd_buf[11], "support", 7) == 0) {
+		aspm_support = igb_dbg_get_aspm_support(adapter);
+		switch (aspm_support) {
+		case ASPMS_L1L0S:
+			dev_info(&adapter->pdev->dev,
+				 "ASPM Support: L0s/L1\n");
+			break;
+		case ASPMS_L1:
+			dev_info(&adapter->pdev->dev, "ASPM Support: L1\n");
+			break;
+		case ASPMS_L0S:
+			dev_info(&adapter->pdev->dev, "ASPM Support: Invalid\n");
+			break;
+		case ASPMS_NONE:
+		default:
+			dev_info(&adapter->pdev->dev, "ASPM Support: Unknown\n");
+			break;
+		}
+	} else if (strncmp(&igb_dbg_cmd_buf[11], "status", 6) == 0) {
+		ret = pci_read_config_word(pdev, cap_offset + PCI_EXP_LNKCTL,
+					   &val);
+		if (ret < 0) {
+			dev_err(&adapter->pdev->dev,
+				"Failed to read PCI config header\n");
+			return;
+		}
+		switch (val) {
+		case ASPMS_L1L0S:
+			dev_info(&adapter->pdev->dev,
+				 "ASPM Status: L0s/L1\n");
+			break;
+		case ASPMS_L1:
+			dev_info(&adapter->pdev->dev, "ASPM Status: L1\n");
+			break;
+		case ASPMS_L0S:
+			dev_info(&adapter->pdev->dev, "ASPM Status: Invalid\n");
+			break;
+		case ASPMS_NONE:
+		default:
+			dev_info(&adapter->pdev->dev, "ASPM Status: Disabled\n");
+			break;
+		}
+	} else if (strncmp(&igb_dbg_cmd_buf[5], "set", 3) == 0) {
+		aspm_support = igb_dbg_get_aspm_support(adapter);
+		if (strncmp(&igb_dbg_cmd_buf[9], "L0sL1", 5) == 0) {
+			if (!(aspm_support & ASPMS_L1L0S)) {
+				dev_info(&adapter->pdev->dev,
+					 "L0sL1 ASPM not supported\n");
+				return;
+			}
+			val = ASPMS_L1L0S;
+			dev_info(&adapter->pdev->dev, "Enabling ASPM L0sL1\n");
+		} else if (strncmp(&igb_dbg_cmd_buf[9], "L1", 2) == 0) {
+			if (!(aspm_support & ASPMS_L1)) {
+				dev_info(&adapter->pdev->dev,
+					 "ASPM L1 not supported\n");
+				return;
+			}
+			val = ASPMS_L1;
+			dev_info(&adapter->pdev->dev, "Enabling L1 ASPM\n");
+		} else if (strncmp(&igb_dbg_cmd_buf[9], "disable", 7) == 0) {
+			val = (PCI_EXP_LNKCTL_ASPMC - ASPMS_L1L0S);
+			dev_info(&adapter->pdev->dev, "Disabling ASPM\n");
+		} else {
+			igb_dbg_show_usage(pdev);
+			return;
+		}
+		ret = pci_write_config_word(pdev, cap_offset + PCI_EXP_LNKCTL,
+					    val);
+		if (ret < 0)
+			dev_err(&adapter->pdev->dev,
+				"Error writing PCI config header\n");
+	} else {
+		igb_dbg_show_usage(pdev);
+	}
+}
+
+static void igb_dbg_set_rx_csum(struct igb_adapter *adapter)
+{
+	struct e1000_hw *hw = &adapter->hw;
+	u32 rxcsum = 0;
+	int cnt, i, cmd_ind;
+	char buf[5][6];
+	bool enable;
+
+	if (strncmp(&igb_dbg_cmd_buf[13], "enable", 6) == 0) {
+		enable = 1;
+		cmd_ind = 17;
+	} else if (strncmp(&igb_dbg_cmd_buf[13], "disable", 7) == 0) {
+		enable = 0;
+		cmd_ind = 18;
+	} else {
+		goto invalid_cmd;
+	}
+
+	cnt = sscanf(&igb_dbg_cmd_buf[cmd_ind], "%s %s %s %s %s",
+		     buf[0], buf[1], buf[2], buf[3], buf[4]);
+
+	if (cnt == 0)
+		goto invalid_cmd;
+
+	rxcsum = rd32(E1000_RXCSUM);
+	for (i = 0; i < cnt; i++) {
+		if (strncmp(buf[i], "IPV4", 4) == 0) {
+			if (enable)
+				rxcsum |= E1000_RXCSUM_IPOFL;
+			else
+				rxcsum &= ~E1000_RXCSUM_IPOFL;
+		} else if (strncmp(buf[i], "TCPUDP", 6) == 0) {
+			if (enable)
+				rxcsum |= E1000_RXCSUM_TUOFL;
+			else
+				rxcsum &= ~E1000_RXCSUM_TUOFL;
+		} else if (strncmp(buf[i], "SCTP", 4) == 0) {
+			if (enable)
+				rxcsum |= E1000_RXCSUM_CRCOFL;
+			else
+				rxcsum &= ~E1000_RXCSUM_CRCOFL;
+		} else if (strncmp(buf[i], "all", 3) == 0) {
+			if (enable) {
+				rxcsum |= (E1000_RXCSUM_IPOFL |
+					   E1000_RXCSUM_TUOFL |
+					   E1000_RXCSUM_CRCOFL);
+			} else {
+				rxcsum &= ~(E1000_RXCSUM_IPOFL |
+					    E1000_RXCSUM_TUOFL |
+					    E1000_RXCSUM_CRCOFL);
+			}
+
+			break;
+		}
+	}
+	dev_info(&adapter->pdev->dev,
+		 "Setting checksum offloads: 0x%08X\n", rxcsum);
+	wr32(E1000_RXCSUM, rxcsum);
+
+	return;
+
+invalid_cmd:
+	igb_dbg_show_usage(adapter->pdev);
+}
+
+/**
+ * igb_dbg_command_read - read for command datum
+ * @filep: the opened file
+ * @buffer: where to write the data for the user to read
+ * @count: the size of the user's buffer
+ * @ppos: file position offset
+ **/
+static ssize_t igb_dbg_command_read(struct file *filep, char __user *buffer,
+				    size_t count, loff_t *ppos)
+{
+	struct igb_adapter *adapter = filep->private_data;
+	char *buf;
+	int len;
+
+	memset(igb_dbg_cmd_buf, 0, BUF_SIZE);
+
+	/* don't allow partial reads */
+	if (*ppos != 0)
+		return 0;
+
+	buf = kasprintf(GFP_KERNEL, "%s: %s\n", adapter->netdev->name,
+			igb_dbg_cmd_buf);
+	if (!buf)
+		return -ENOMEM;
+
+	if (count < strlen(buf)) {
+		kfree(buf);
+		return -ENOSPC;
+	}
+
+	len = simple_read_from_buffer(buffer, count, ppos, buf, strlen(buf));
+
+	kfree(buf);
+
+	return len;
+}
+
+/**
+ * igb_dbg_command_write - write into command datum
+ * @filep: the opened file
+ * @buffer: where to find the user's data
+ * @count: the length of the user's data
+ * @ppos: file position offset
+**/
+static ssize_t igb_dbg_command_write(struct file *filep,
+				     const char __user *buffer,
+				     size_t count, loff_t *ppos)
+{
+	struct igb_adapter *adapter = filep->private_data;
+	struct pci_dev *pdev = adapter->pdev;
+	int len;
+
+	memset(igb_dbg_cmd_buf, 0, BUF_SIZE);
+
+	/* don't allow partial writes */
+	if (*ppos != 0)
+		return 0;
+
+	if (count >= sizeof(igb_dbg_cmd_buf))
+		return -ENOSPC;
+
+	len = simple_write_to_buffer(igb_dbg_cmd_buf,
+				     sizeof(igb_dbg_cmd_buf) - 1,
+				     ppos, buffer, count);
+
+	if (len < 0)
+		return len;
+
+	igb_dbg_cmd_buf[len-1] = '\0';
+
+	if ((strncmp(igb_dbg_cmd_buf, "query aspm", 10) == 0) ||
+	    (strncmp(igb_dbg_cmd_buf, "aspm set", 8) == 0)) {
+		igb_dbg_parse_aspm_cmd(adapter);
+	} else if (strncmp(igb_dbg_cmd_buf, "query rx csum ofls", 18) == 0) {
+		u32 rxcsum;
+		struct e1000_hw *hw = &adapter->hw;
+		char *status[2] = {"disabled", "enabled"};
+
+		rxcsum = rd32(E1000_RXCSUM);
+		dev_info(&adapter->pdev->dev,
+			 "RX Checksum Offloading Status:\n");
+		dev_info(&adapter->pdev->dev, "  IPv4: %s\n",
+			 status[(bool)(rxcsum & E1000_RXCSUM_IPOFL)]);
+		dev_info(&adapter->pdev->dev, "  TCP/UDP: %s\n",
+			 status[(bool)(rxcsum & E1000_RXCSUM_TUOFL)]);
+		dev_info(&adapter->pdev->dev, "  SCTP CRC32: %s\n",
+			 status[(bool)(rxcsum & E1000_RXCSUM_CRCOFL)]);
+	} else if (strncmp(igb_dbg_cmd_buf, "rx csum ofls", 12) == 0) {
+		igb_dbg_set_rx_csum(adapter);
+	} else if (strncmp(igb_dbg_cmd_buf, "dump rx packet stats", 17) == 0) {
+		int i;
+		int ipv4 = 0;
+		int ipv4e = 0;
+		int ipv6 = 0;
+		int ipv6e = 0;
+		int tcp = 0;
+		int udp = 0;
+		int sctp = 0;
+		int nfs = 0;
+		int other = 0;
+
+		for (i = 0; i < adapter->num_rx_queues; i++) {
+			struct igb_ring *ring = adapter->rx_ring[i];
+
+			ipv4 += ring->pkt_stats.ipv4_packets;
+			ipv4e += ring->pkt_stats.ipv4e_packets;
+			ipv6 += ring->pkt_stats.ipv6_packets;
+			ipv6e += ring->pkt_stats.ipv6e_packets;
+			tcp += ring->pkt_stats.tcp_packets;
+			udp += ring->pkt_stats.udp_packets;
+			sctp += ring->pkt_stats.sctp_packets;
+			nfs += ring->pkt_stats.nfs_packets;
+			other += ring->pkt_stats.other_packets;
+		}
+
+		dev_info(&adapter->pdev->dev, "RX Packet Type Stats:\n");
+		dev_info(&adapter->pdev->dev, "  IPv4  = %i\n", ipv4);
+		dev_info(&adapter->pdev->dev, "  IPv4E = %i\n", ipv4e);
+		dev_info(&adapter->pdev->dev, "  IPv6  = %i\n", ipv6);
+		dev_info(&adapter->pdev->dev, "  IPv6E = %i\n", ipv6e);
+		dev_info(&adapter->pdev->dev, "  TCP   = %i\n", tcp);
+		dev_info(&adapter->pdev->dev, "  UDP   = %i\n", udp);
+		dev_info(&adapter->pdev->dev, "  SCTP  = %i\n", sctp);
+		dev_info(&adapter->pdev->dev, "  NFS   = %i\n", nfs);
+		dev_info(&adapter->pdev->dev, "  OTHER = %i\n", other);
+	} else if (strncmp(igb_dbg_cmd_buf, "dump eee stats", 14) == 0) {
+		struct e1000_hw *hw = &adapter->hw;
+
+		txlpic += rd32(E1000_TLPIC);
+		rxlpic += rd32(E1000_RLPIC);
+
+		dev_info(&adapter->pdev->dev, "EEE TX LPIC = %i", txlpic);
+		dev_info(&adapter->pdev->dev, "EEE RX LPIC = %i", rxlpic);
+	} else if (strncmp(igb_dbg_cmd_buf, "query eee", 9) == 0) {
+		struct e1000_hw *hw = &adapter->hw;
+
+		if (hw->mac.type != e1000_i354) {
+			u32 eeer, ipcnfg;
+
+			eeer = rd32(E1000_EEER);
+			ipcnfg = rd32(E1000_IPCNFG);
+
+			if (eeer & E1000_EEER_EEE_NEG) {
+				dev_info(&adapter->pdev->dev, "EEE Link:\n");
+				if (eeer & E1000_EEER_RX_LPI_STATUS)
+					dev_info(&adapter->pdev->dev,
+						 "  RX Link State: LPI\n");
+				else
+					dev_info(&adapter->pdev->dev,
+						 "  RX Link State: Active\n");
+
+				if (eeer & E1000_EEER_TX_LPI_STATUS)
+					dev_info(&adapter->pdev->dev,
+						 "  TX Link State: LPI\n");
+				else
+					dev_info(&adapter->pdev->dev,
+						 "  TX Link State: Active\n");
+			} else {
+				dev_info(&adapter->pdev->dev,
+					 "EEE not negotiated on link\n");
+			}
+		} else {
+			bool status = false;
+
+			igb_get_eee_status_i354(hw, &status);
+			if (status)
+				dev_info(&adapter->pdev->dev,
+					 "  TX or RX Link State: Active\n");
+			else
+				dev_info(&adapter->pdev->dev,
+					 "EEE not negotiated on link\n");
+		}
+	} else if (strncmp(igb_dbg_cmd_buf, "dump reset stats", 16) == 0) {
+		dev_info(&adapter->pdev->dev, "Num device resets: %i",
+			 adapter->devrc);
+	} else if (strncmp(igb_dbg_cmd_buf, "dump itr", 8) == 0) {
+		struct e1000_hw *hw = &adapter->hw;
+		int i, interval;
+		u32 eitr;
+
+		dev_info(&adapter->pdev->dev,
+			 "Vector inter-interrupt interval (usec):\n");
+		for (i = 0; i < adapter->num_q_vectors; i++) {
+			eitr = rd32(E1000_EITR(i));
+
+			interval = eitr & E1000_EITR_INTERVAL;
+			if (interval) {
+				dev_info(&adapter->pdev->dev,
+					 "  Vector[%i]: %i\n", i, interval);
+			} else {
+				dev_info(&adapter->pdev->dev,
+					 "  Vector[%i]: NA\n", i);
+			}
+		}
+	} else if (strncmp(igb_dbg_cmd_buf, "reset stats", 11) == 0) {
+		int i;
+
+		txlpic = 0;
+		rxlpic = 0;
+
+		memset(&adapter->stats, 0, sizeof(struct e1000_hw_stats));
+
+		for (i = 0; i < adapter->num_q_vectors; i++) {
+			adapter->q_vector[i]->rx.total_bytes = 0;
+			adapter->q_vector[i]->rx.total_packets = 0;
+			adapter->q_vector[i]->tx.total_bytes = 0;
+			adapter->q_vector[i]->tx.total_packets = 0;
+		}
+		for (i = 0; i < adapter->num_rx_queues; i++) {
+			memset(&adapter->rx_ring[i]->rx_stats, 0,
+				   sizeof(struct igb_rx_queue_stats));
+		}
+		for (i = 0; i < adapter->num_tx_queues; i++) {
+			memset(&adapter->tx_ring[i]->tx_stats, 0,
+				   sizeof(struct igb_tx_queue_stats));
+		}
+		for (i = 0; i < adapter->num_rx_queues; i++) {
+			memset(&adapter->rx_ring[i]->pkt_stats, 0,
+				sizeof(struct igb_rx_pkt_stats));
+		}
+
+		dev_info(&adapter->pdev->dev, "Stats reset.\n");
+	} else {
+		igb_dbg_show_usage(pdev);
+	}
+
+	return count;
+}
+
+static const struct file_operations igb_dbg_command_fops = {
+	.owner = THIS_MODULE,
+	.open = simple_open,
+	.read = igb_dbg_command_read,
+	.write = igb_dbg_command_write,
+};
+
 /**
  * igb_dbp_adapter_init - setup the debugfs directory for the adapter
  * @adapter: the adapter that is starting up
@@ -38,11 +663,29 @@ static struct dentry *igb_dbg_root;
 void igb_dbg_adapter_init(struct igb_adapter *adapter)
 {
 	const char *name = pci_name(adapter->pdev);
+	struct dentry *pfile;
 
 	adapter->igb_dbg_adapter = debugfs_create_dir(name, igb_dbg_root);
-	if (!adapter->igb_dbg_adapter)
+	if (adapter->igb_dbg_adapter) {
+		pfile = debugfs_create_file("reg_ops", 0600,
+					    adapter->igb_dbg_adapter, adapter,
+					    &igb_dbg_reg_ops_fops);
+		if (!pfile) {
+			dev_err(&adapter->pdev->dev,
+				"debugfs reg_ops for %s failed\n", name);
+		}
+
+		pfile = debugfs_create_file("command", 0600,
+					    adapter->igb_dbg_adapter, adapter,
+					    &igb_dbg_command_fops);
+		if (!pfile) {
+			dev_err(&adapter->pdev->dev,
+				"debugfs command for %s failed\n", name);
+		}
+	} else {
 		dev_err(&adapter->pdev->dev,
-			"debugfs entry for %s failed\n", name);
+				"debugfs entry for %s failed\n", name);
+	}
 }
 
 /**
-- 
1.8.3.1
