From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/3] ixgbe: add syfs interface for to export read only driver information
Date: Thu,  5 Apr 2012 03:47:58 -0700
Message-ID: <1333622878-3855-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1333622878-3855-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com, bhutchings@solarflare.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:55758 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754193Ab2DEKsD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Apr 2012 06:48:03 -0400
In-Reply-To: <1333622878-3855-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

This patch exports non-thermal (which was done via hwmon in an earlier
patch) data to syfs.  All of the fields are read only as this interface
is to only export driver data.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c |  774 +++++++++++++++++++++++-
 1 files changed, 769 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c
index 0882fd5..ddcec9f 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c
@@ -41,6 +41,762 @@
  * This file provides a sysfs interface to export information from the
  * driver.  The information presented is READ-ONLY.
  */
+
+static struct net_device_stats *sysfs_get_stats(struct net_device *netdev)
+{
+	if (netdev == NULL)
+		return NULL;
+
+	/* only return the current stats */
+	return &netdev->stats;
+}
+
+static struct net_device *ixgbe_get_netdev(struct kobject *kobj)
+{
+	struct net_device *netdev;
+	struct kobject *parent = kobj->parent;
+	struct device *device_info_kobj;
+
+	if (kobj == NULL)
+		return NULL;
+
+	device_info_kobj = container_of(parent, struct device, kobj);
+	if (device_info_kobj == NULL)
+		return NULL;
+
+	netdev = container_of(device_info_kobj, struct net_device, dev);
+	return netdev;
+}
+
+static struct ixgbe_adapter *ixgbe_get_adapter(struct kobject *kobj)
+{
+	struct ixgbe_adapter *adapter;
+	struct net_device *netdev = ixgbe_get_netdev(kobj);
+
+	if (netdev == NULL)
+		return NULL;
+
+	adapter = netdev_priv(netdev);
+	return adapter;
+}
+
+static ssize_t ixgbe_fwbanner(struct kobject *kobj,
+			      struct kobj_attribute *attr, char *buf)
+{
+	struct ixgbe_adapter *adapter = ixgbe_get_adapter(kobj);
+	int nvm_track_id;
+
+	if (adapter == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no adapter\n");
+
+	nvm_track_id = (adapter->eeprom_verh << 16) | adapter->eeprom_verl;
+
+	return snprintf(buf, PAGE_SIZE, "0x%08x\n", nvm_track_id);
+}
+
+static ssize_t ixgbe_porttype(struct kobject *kobj,
+			      struct kobj_attribute *attr, char *buf)
+{
+	struct ixgbe_adapter *adapter = ixgbe_get_adapter(kobj);
+
+	if (adapter == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no adapter\n");
+
+	return snprintf(buf, PAGE_SIZE, "%d\n",
+			test_bit(__IXGBE_DOWN, &adapter->state));
+}
+
+static ssize_t ixgbe_portspeed(struct kobject *kobj,
+			       struct kobj_attribute *attr, char *buf)
+{
+	struct ixgbe_adapter *adapter = ixgbe_get_adapter(kobj);
+	int speed = 0;
+
+	if (adapter == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no adapter\n");
+
+	switch (adapter->link_speed) {
+	case IXGBE_LINK_SPEED_100_FULL:
+		speed = 1;
+		break;
+	case IXGBE_LINK_SPEED_1GB_FULL:
+		speed = 10;
+		break;
+	case IXGBE_LINK_SPEED_10GB_FULL:
+		speed = 100;
+		break;
+	}
+
+	return snprintf(buf, PAGE_SIZE, "%d\n", speed);
+}
+
+static ssize_t ixgbe_wqlflag(struct kobject *kobj,
+			     struct kobj_attribute *attr, char *buf)
+{
+	struct ixgbe_adapter *adapter = ixgbe_get_adapter(kobj);
+
+	if (adapter == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no adapter\n");
+
+	return snprintf(buf, PAGE_SIZE, "%d\n", adapter->wol);
+}
+
+static ssize_t ixgbe_xflowctl(struct kobject *kobj,
+			      struct kobj_attribute *attr, char *buf)
+{
+	struct ixgbe_adapter *adapter = ixgbe_get_adapter(kobj);
+	struct ixgbe_hw *hw;
+
+	if (adapter == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no adapter\n");
+
+	hw = &adapter->hw;
+	if (hw == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no hw data\n");
+
+	return snprintf(buf, PAGE_SIZE, "%d\n", hw->fc.current_mode);
+}
+
+static ssize_t ixgbe_rxdrops(struct kobject *kobj,
+			     struct kobj_attribute *attr, char *buf)
+{
+	struct net_device_stats *net_stats;
+	struct net_device *netdev = ixgbe_get_netdev(kobj);
+
+	if (netdev == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no net device\n");
+
+	net_stats  = sysfs_get_stats(netdev);
+	if (net_stats == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no net stats\n");
+
+	return snprintf(buf, PAGE_SIZE, "%lu\n",
+			net_stats->rx_dropped);
+}
+
+static ssize_t ixgbe_rxerrors(struct kobject *kobj,
+			      struct kobj_attribute *attr, char *buf)
+{
+	struct net_device_stats *net_stats;
+	struct net_device *netdev = ixgbe_get_netdev(kobj);
+
+	if (netdev == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no net device\n");
+
+	net_stats  = sysfs_get_stats(netdev);
+	if (net_stats == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no net stats\n");
+
+	return snprintf(buf, PAGE_SIZE, "%lu\n", net_stats->rx_errors);
+}
+
+static ssize_t ixgbe_rxupacks(struct kobject *kobj,
+			      struct kobj_attribute *attr, char *buf)
+{
+	struct ixgbe_hw *hw;
+	struct ixgbe_adapter *adapter = ixgbe_get_adapter(kobj);
+
+	if (adapter == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no adapter\n");
+
+	hw = &adapter->hw;
+	if (hw == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no hw data\n");
+
+	return snprintf(buf, PAGE_SIZE, "%d\n", IXGBE_READ_REG(hw, IXGBE_TPR));
+}
+
+static ssize_t ixgbe_rxmpacks(struct kobject *kobj,
+			      struct kobj_attribute *attr, char *buf)
+{
+	struct ixgbe_hw *hw;
+	struct ixgbe_adapter *adapter = ixgbe_get_adapter(kobj);
+
+	if (adapter == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no adapter\n");
+
+	hw = &adapter->hw;
+	if (hw == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no hw data\n");
+
+	return snprintf(buf, PAGE_SIZE, "%d\n", IXGBE_READ_REG(hw, IXGBE_MPRC));
+}
+
+static ssize_t ixgbe_rxbpacks(struct kobject *kobj,
+			      struct kobj_attribute *attr, char *buf)
+{
+	struct ixgbe_hw *hw;
+	struct ixgbe_adapter *adapter = ixgbe_get_adapter(kobj);
+
+	if (adapter == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no adapter\n");
+
+	hw = &adapter->hw;
+	if (hw == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no hw data\n");
+
+	return snprintf(buf, PAGE_SIZE, "%d\n", IXGBE_READ_REG(hw, IXGBE_BPRC));
+}
+
+static ssize_t ixgbe_txupacks(struct kobject *kobj,
+			      struct kobj_attribute *attr, char *buf)
+{
+	struct ixgbe_hw *hw;
+	struct ixgbe_adapter *adapter = ixgbe_get_adapter(kobj);
+
+	if (adapter == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no adapter\n");
+
+	hw = &adapter->hw;
+	if (hw == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no hw data\n");
+
+	return snprintf(buf, PAGE_SIZE, "%d\n", IXGBE_READ_REG(hw, IXGBE_TPT));
+}
+
+static ssize_t ixgbe_txmpacks(struct kobject *kobj,
+			      struct kobj_attribute *attr, char *buf)
+{
+	struct ixgbe_hw *hw;
+	struct ixgbe_adapter *adapter = ixgbe_get_adapter(kobj);
+
+	if (adapter == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no adapter\n");
+
+	hw = &adapter->hw;
+	if (hw == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no hw data\n");
+
+	return snprintf(buf, PAGE_SIZE, "%d\n", IXGBE_READ_REG(hw, IXGBE_MPTC));
+}
+
+static ssize_t ixgbe_txbpacks(struct kobject *kobj,
+			      struct kobj_attribute *attr, char *buf)
+{
+	struct ixgbe_hw *hw;
+	struct ixgbe_adapter *adapter = ixgbe_get_adapter(kobj);
+
+	if (adapter == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no adapter\n");
+
+	hw = &adapter->hw;
+	if (hw == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no hw data\n");
+
+	return snprintf(buf, PAGE_SIZE, "%d\n", IXGBE_READ_REG(hw, IXGBE_BPTC));
+}
+
+static ssize_t ixgbe_txerrors(struct kobject *kobj,
+			      struct kobj_attribute *attr, char *buf)
+{
+	struct net_device_stats *net_stats;
+	struct net_device *netdev = ixgbe_get_netdev(kobj);
+
+	if (netdev == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no net device\n");
+
+	net_stats  = sysfs_get_stats(netdev);
+	if (net_stats == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no net stats\n");
+
+	return snprintf(buf, PAGE_SIZE, "%lu\n", net_stats->tx_errors);
+}
+
+static ssize_t ixgbe_txdrops(struct kobject *kobj,
+			     struct kobj_attribute *attr, char *buf)
+{
+	struct net_device_stats *net_stats;
+	struct net_device *netdev = ixgbe_get_netdev(kobj);
+
+	if (netdev == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no net device\n");
+
+	net_stats  = sysfs_get_stats(netdev);
+	if (net_stats == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no net stats\n");
+
+	return snprintf(buf, PAGE_SIZE, "%lu\n", net_stats->tx_dropped);
+}
+
+static ssize_t ixgbe_rxframes(struct kobject *kobj,
+			      struct kobj_attribute *attr, char *buf)
+{
+	struct net_device_stats *net_stats;
+	struct net_device *netdev = ixgbe_get_netdev(kobj);
+
+	if (netdev == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no net device\n");
+
+	net_stats  = sysfs_get_stats(netdev);
+	if (net_stats == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no net stats\n");
+
+	return snprintf(buf, PAGE_SIZE, "%lu\n", net_stats->rx_packets);
+}
+
+static ssize_t ixgbe_rxbytes(struct kobject *kobj,
+			     struct kobj_attribute *attr, char *buf)
+{
+	struct net_device_stats *net_stats;
+	struct net_device *netdev = ixgbe_get_netdev(kobj);
+
+	if (netdev == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no net device\n");
+
+	net_stats  = sysfs_get_stats(netdev);
+	if (net_stats == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no net stats\n");
+
+	return snprintf(buf, PAGE_SIZE, "%lu\n", net_stats->rx_bytes);
+}
+
+static ssize_t ixgbe_txframes(struct kobject *kobj,
+			      struct kobj_attribute *attr, char *buf)
+{
+	struct net_device_stats *net_stats;
+	struct net_device *netdev = ixgbe_get_netdev(kobj);
+
+	if (netdev == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no net device\n");
+
+	net_stats  = sysfs_get_stats(netdev);
+	if (net_stats == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no net stats\n");
+
+	return snprintf(buf, PAGE_SIZE, "%lu\n", net_stats->tx_packets);
+}
+
+static ssize_t ixgbe_txbytes(struct kobject *kobj,
+			     struct kobj_attribute *attr, char *buf)
+{
+	struct net_device_stats *net_stats;
+	struct net_device *netdev = ixgbe_get_netdev(kobj);
+
+	if (netdev == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no net device\n");
+
+	net_stats  = sysfs_get_stats(netdev);
+	if (net_stats == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no net stats\n");
+
+	return snprintf(buf, PAGE_SIZE, "%lu\n", net_stats->tx_bytes);
+}
+
+static ssize_t ixgbe_linkstat(struct kobject *kobj,
+			      struct kobj_attribute *attr, char *buf)
+{
+	u32 link_speed;
+	bool link_up = false;
+	int bitmask = 0;
+	struct ixgbe_hw *hw;
+	struct ixgbe_adapter *adapter = ixgbe_get_adapter(kobj);
+
+	if (adapter == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no adapter\n");
+
+	hw = &adapter->hw;
+	if (hw == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no hw data\n");
+
+	if (test_bit(__IXGBE_DOWN, &adapter->state))
+		bitmask |= 1;
+
+	if (hw->mac.ops.check_link)
+		hw->mac.ops.check_link(hw, &link_speed, &link_up, false);
+	else
+		/* always assume link is up, if no check link function */
+		link_up = true;
+
+	if (link_up)
+		bitmask |= 2;
+
+	return snprintf(buf, PAGE_SIZE, "0x%X\n", bitmask);
+}
+
+static ssize_t ixgbe_funcid(struct kobject *kobj,
+			    struct kobj_attribute *attr, char *buf)
+{
+	struct ixgbe_adapter *adapter = ixgbe_get_adapter(kobj);
+	struct ixgbe_hw *hw;
+
+	if (adapter == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no adapter\n");
+
+	hw = &adapter->hw;
+	if (hw == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no hw data\n");
+
+	return snprintf(buf, PAGE_SIZE, "0x%X\n", hw->bus.func);
+}
+
+static ssize_t ixgbe_funcvers(struct kobject *kobj,
+			      struct kobj_attribute *attr, char *buf)
+{
+	return snprintf(buf, PAGE_SIZE, "%s\n", ixgbe_driver_version);
+}
+
+static ssize_t ixgbe_macburn(struct kobject *kobj,
+			     struct kobj_attribute *attr, char *buf)
+{
+	struct ixgbe_hw *hw;
+	struct ixgbe_adapter *adapter = ixgbe_get_adapter(kobj);
+
+	if (adapter == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no adapter\n");
+
+	hw = &adapter->hw;
+	if (hw == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no hw data\n");
+
+	return snprintf(buf, PAGE_SIZE, "0x%X%X%X%X%X%X\n",
+			(unsigned int)hw->mac.perm_addr[0],
+			(unsigned int)hw->mac.perm_addr[1],
+			(unsigned int)hw->mac.perm_addr[2],
+			(unsigned int)hw->mac.perm_addr[3],
+			(unsigned int)hw->mac.perm_addr[4],
+			(unsigned int)hw->mac.perm_addr[5]);
+}
+
+static ssize_t ixgbe_macadmn(struct kobject *kobj,
+			     struct kobj_attribute *attr, char *buf)
+{
+	struct ixgbe_hw *hw;
+	struct ixgbe_adapter *adapter = ixgbe_get_adapter(kobj);
+
+	if (adapter == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no adapter\n");
+
+	hw = &adapter->hw;
+	if (hw == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no hw data\n");
+
+	return snprintf(buf, PAGE_SIZE, "0x%X%X%X%X%X%X\n",
+			(unsigned int)hw->mac.addr[0],
+			(unsigned int)hw->mac.addr[1],
+			(unsigned int)hw->mac.addr[2],
+			(unsigned int)hw->mac.addr[3],
+			(unsigned int)hw->mac.addr[4],
+			(unsigned int)hw->mac.addr[5]);
+}
+
+static ssize_t ixgbe_maclla1(struct kobject *kobj,
+			     struct kobj_attribute *attr, char *buf)
+{
+	struct ixgbe_hw *hw;
+	u16 eeprom_buff[6];
+	int first_word = 0x37;
+	int word_count = 6;
+	int rc;
+	struct ixgbe_adapter *adapter = ixgbe_get_adapter(kobj);
+
+	if (adapter == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no adapter\n");
+
+	hw = &adapter->hw;
+	if (hw == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no hw data\n");
+
+	rc = hw->eeprom.ops.read_buffer(hw, first_word, word_count,
+					eeprom_buff);
+	if (rc)
+		return snprintf(buf, PAGE_SIZE, "error: reading buffer\n");
+
+	switch (hw->bus.func) {
+	case 0:
+		return snprintf(buf, PAGE_SIZE, "0x%04X%04X%04X\n",
+				eeprom_buff[0],
+				eeprom_buff[1],
+				eeprom_buff[2]);
+	case 1:
+		return snprintf(buf, PAGE_SIZE, "0x%04X%04X%04X\n",
+				eeprom_buff[3],
+				eeprom_buff[4],
+				eeprom_buff[5]);
+	}
+
+	return snprintf(buf, PAGE_SIZE, "unexpected port %d\n", hw->bus.func);
+}
+
+static ssize_t ixgbe_mtusize(struct kobject *kobj,
+			     struct kobj_attribute *attr, char *buf)
+{
+	struct ixgbe_adapter *adapter = ixgbe_get_adapter(kobj);
+	struct net_device *netdev = ixgbe_get_netdev(kobj);
+
+	if (netdev == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no net device\n");
+
+	if (adapter == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no adapter\n");
+
+	return snprintf(buf, PAGE_SIZE, "%d\n", netdev->mtu);
+}
+
+static ssize_t ixgbe_featflag(struct kobject *kobj,
+			      struct kobj_attribute *attr, char *buf)
+{
+	int bitmask = 0;
+	struct ixgbe_adapter *adapter = ixgbe_get_adapter(kobj);
+	struct net_device *netdev = ixgbe_get_netdev(kobj);
+
+	if (netdev == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no net device\n");
+
+	if (adapter == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no adapter\n");
+
+	if (netdev->features & NETIF_F_RXCSUM)
+		bitmask |= 1;
+
+	return snprintf(buf, PAGE_SIZE, "%d\n", bitmask);
+}
+
+static ssize_t ixgbe_lsominct(struct kobject *kobj,
+			      struct kobj_attribute *attr, char *buf)
+{
+	return snprintf(buf, PAGE_SIZE, "%d\n", 1);
+}
+
+static ssize_t ixgbe_prommode(struct kobject *kobj,
+			      struct kobj_attribute *attr, char *buf)
+{
+	struct net_device *netdev = ixgbe_get_netdev(kobj);
+
+	if (netdev == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no net device\n");
+
+	return snprintf(buf, PAGE_SIZE, "%d\n", netdev->flags & IFF_PROMISC);
+}
+
+static ssize_t ixgbe_txdscqsz(struct kobject *kobj,
+			      struct kobj_attribute *attr, char *buf)
+{
+	struct ixgbe_adapter *adapter = ixgbe_get_adapter(kobj);
+
+	if (adapter == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no adapter\n");
+
+	return snprintf(buf, PAGE_SIZE, "%d\n", adapter->tx_ring[0]->count);
+}
+
+static ssize_t ixgbe_rxdscqsz(struct kobject *kobj,
+			      struct kobj_attribute *attr, char *buf)
+{
+	struct ixgbe_adapter *adapter = ixgbe_get_adapter(kobj);
+
+	if (adapter == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no adapter\n");
+
+	return snprintf(buf, PAGE_SIZE, "%d\n", adapter->rx_ring[0]->count);
+}
+
+static ssize_t ixgbe_rxqavg(struct kobject *kobj,
+			    struct kobj_attribute *attr, char *buf)
+{
+	int index;
+	int diff = 0;
+	u16 ntc;
+	u16 ntu;
+	struct ixgbe_adapter *adapter = ixgbe_get_adapter(kobj);
+
+	if (adapter == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no adapter\n");
+
+	for (index = 0; index < adapter->num_rx_queues; index++) {
+		ntc = adapter->rx_ring[index]->next_to_clean;
+		ntu = adapter->rx_ring[index]->next_to_use;
+
+		if (ntc >= ntu)
+			diff += (ntc - ntu);
+		else
+			diff += (adapter->rx_ring[index]->count - ntu + ntc);
+	}
+
+	if (adapter->num_rx_queues <= 0)
+		return snprintf(buf, PAGE_SIZE,
+				"can't calculate, number of queues %d\n",
+				adapter->num_rx_queues);
+
+	return snprintf(buf, PAGE_SIZE, "%d\n", diff/adapter->num_rx_queues);
+}
+
+static ssize_t ixgbe_txqavg(struct kobject *kobj,
+			    struct kobj_attribute *attr, char *buf)
+{
+	int index;
+	int diff = 0;
+	u16 ntc;
+	u16 ntu;
+	struct ixgbe_adapter *adapter = ixgbe_get_adapter(kobj);
+
+	if (adapter == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no adapter\n");
+
+	for (index = 0; index < adapter->num_tx_queues; index++) {
+		ntc = adapter->tx_ring[index]->next_to_clean;
+		ntu = adapter->tx_ring[index]->next_to_use;
+
+		if (ntc >= ntu)
+			diff += (ntc - ntu);
+		else
+			diff += (adapter->tx_ring[index]->count - ntu + ntc);
+	}
+
+	if (adapter->num_tx_queues <= 0)
+		return snprintf(buf, PAGE_SIZE,
+				"can't calculate, number of queues %d\n",
+				adapter->num_tx_queues);
+
+	return snprintf(buf, PAGE_SIZE, "%d\n", diff/adapter->num_tx_queues);
+}
+
+static ssize_t ixgbe_iovotype(struct kobject *kobj,
+			      struct kobj_attribute *attr, char *buf)
+{
+	return snprintf(buf, PAGE_SIZE, "2\n");
+}
+
+static ssize_t ixgbe_funcnbr(struct kobject *kobj,
+			     struct kobj_attribute *attr, char *buf)
+{
+	struct ixgbe_adapter *adapter = ixgbe_get_adapter(kobj);
+
+	if (adapter == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no adapter\n");
+
+	return snprintf(buf, PAGE_SIZE, "%d\n", adapter->num_vfs);
+}
+
+static ssize_t ixgbe_pciebnbr(struct kobject *kobj,
+			      struct kobj_attribute *attr, char *buf)
+{
+	struct ixgbe_adapter *adapter = ixgbe_get_adapter(kobj);
+
+	if (adapter == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no adapter\n");
+
+	return snprintf(buf, PAGE_SIZE, "%d\n", adapter->pdev->bus->number);
+}
+
+/* Initialize the attributes */
+static struct kobj_attribute ixgbe_sysfs_fwbanner_attr =
+	__ATTR(fwbanner, 0444, ixgbe_fwbanner, NULL);
+static struct kobj_attribute ixgbe_sysfs_porttype_attr =
+	__ATTR(porttype, 0444, ixgbe_porttype, NULL);
+static struct kobj_attribute ixgbe_sysfs_portspeed_attr =
+	__ATTR(portspeed, 0444, ixgbe_portspeed, NULL);
+static struct kobj_attribute ixgbe_sysfs_wqlflag_attr =
+	__ATTR(wqlflag, 0444, ixgbe_wqlflag, NULL);
+static struct kobj_attribute ixgbe_sysfs_xflowctl_attr =
+	__ATTR(xflowctl, 0444, ixgbe_xflowctl, NULL);
+static struct kobj_attribute ixgbe_sysfs_rxdrops_attr =
+	__ATTR(rxdrops, 0444, ixgbe_rxdrops, NULL);
+static struct kobj_attribute ixgbe_sysfs_rxerrors_attr =
+	__ATTR(rxerrors, 0444, ixgbe_rxerrors, NULL);
+static struct kobj_attribute ixgbe_sysfs_rxupacks_attr =
+	__ATTR(rxupacks, 0444, ixgbe_rxupacks, NULL);
+static struct kobj_attribute ixgbe_sysfs_rxmpacks_attr =
+	__ATTR(rxmpacks, 0444, ixgbe_rxmpacks, NULL);
+static struct kobj_attribute ixgbe_sysfs_rxbpacks_attr =
+	__ATTR(rxbpacks, 0444, ixgbe_rxbpacks, NULL);
+static struct kobj_attribute ixgbe_sysfs_txupacks_attr =
+	__ATTR(txupacks, 0444, ixgbe_txupacks, NULL);
+static struct kobj_attribute ixgbe_sysfs_txmpacks_attr =
+	__ATTR(txmpacks, 0444, ixgbe_txmpacks, NULL);
+static struct kobj_attribute ixgbe_sysfs_txbpacks_attr =
+	__ATTR(txbpacks, 0444, ixgbe_txbpacks, NULL);
+static struct kobj_attribute ixgbe_sysfs_txerrors_attr =
+	__ATTR(txerrors, 0444, ixgbe_txerrors, NULL);
+static struct kobj_attribute ixgbe_sysfs_txdrops_attr =
+	__ATTR(txdrops, 0444, ixgbe_txdrops, NULL);
+static struct kobj_attribute ixgbe_sysfs_rxframes_attr =
+	__ATTR(rxframes, 0444, ixgbe_rxframes, NULL);
+static struct kobj_attribute ixgbe_sysfs_rxbytes_attr =
+	__ATTR(rxbytes, 0444, ixgbe_rxbytes, NULL);
+static struct kobj_attribute ixgbe_sysfs_txframes_attr =
+	__ATTR(txframes, 0444, ixgbe_txframes, NULL);
+static struct kobj_attribute ixgbe_sysfs_txbytes_attr =
+	__ATTR(txbytes, 0444, ixgbe_txbytes, NULL);
+static struct kobj_attribute ixgbe_sysfs_linkstat_attr =
+	__ATTR(linkstat, 0444, ixgbe_linkstat, NULL);
+static struct kobj_attribute ixgbe_sysfs_funcid_attr =
+	__ATTR(funcid, 0444, ixgbe_funcid, NULL);
+static struct kobj_attribute ixgbe_sysfs_funvers_attr =
+	__ATTR(funcvers, 0444, ixgbe_funcvers, NULL);
+static struct kobj_attribute ixgbe_sysfs_macburn_attr =
+	__ATTR(macburn, 0444, ixgbe_macburn, NULL);
+static struct kobj_attribute ixgbe_sysfs_macadmn_attr =
+	__ATTR(macadmn, 0444, ixgbe_macadmn, NULL);
+static struct kobj_attribute ixgbe_sysfs_maclla1_attr =
+	__ATTR(maclla1, 0444, ixgbe_maclla1, NULL);
+static struct kobj_attribute ixgbe_sysfs_mtusize_attr =
+	__ATTR(mtusize, 0444, ixgbe_mtusize, NULL);
+static struct kobj_attribute ixgbe_sysfs_featflag_attr =
+	__ATTR(featflag, 0444, ixgbe_featflag, NULL);
+static struct kobj_attribute ixgbe_sysfs_lsominct_attr =
+	__ATTR(lsominct, 0444, ixgbe_lsominct, NULL);
+static struct kobj_attribute ixgbe_sysfs_prommode_attr =
+	__ATTR(prommode, 0444, ixgbe_prommode, NULL);
+static struct kobj_attribute ixgbe_sysfs_txdscqsz_attr =
+	__ATTR(txdscqsz, 0444, ixgbe_txdscqsz, NULL);
+static struct kobj_attribute ixgbe_sysfs_rxdscqsz_attr =
+	__ATTR(rxdscqsz, 0444, ixgbe_rxdscqsz, NULL);
+static struct kobj_attribute ixgbe_sysfs_txqavg_attr =
+	__ATTR(txqavg, 0444, ixgbe_txqavg, NULL);
+static struct kobj_attribute ixgbe_sysfs_rxqavg_attr =
+	__ATTR(rxqavg, 0444, ixgbe_rxqavg, NULL);
+static struct kobj_attribute ixgbe_sysfs_iovotype_attr =
+	__ATTR(iovotype, 0444, ixgbe_iovotype, NULL);
+static struct kobj_attribute ixgbe_sysfs_funcnbr_attr =
+	__ATTR(funcnbr, 0444, ixgbe_funcnbr, NULL);
+static struct kobj_attribute ixgbe_sysfs_pciebnbr_attr =
+	__ATTR(pciebnbr, 0444, ixgbe_pciebnbr, NULL);
+
+static struct attribute *attrs[] = {
+	&ixgbe_sysfs_fwbanner_attr.attr,
+	&ixgbe_sysfs_porttype_attr.attr,
+	&ixgbe_sysfs_portspeed_attr.attr,
+	&ixgbe_sysfs_wqlflag_attr.attr,
+	&ixgbe_sysfs_xflowctl_attr.attr,
+	&ixgbe_sysfs_rxdrops_attr.attr,
+	&ixgbe_sysfs_rxerrors_attr.attr,
+	&ixgbe_sysfs_rxupacks_attr.attr,
+	&ixgbe_sysfs_rxmpacks_attr.attr,
+	&ixgbe_sysfs_rxbpacks_attr.attr,
+	&ixgbe_sysfs_txdrops_attr.attr,
+	&ixgbe_sysfs_txerrors_attr.attr,
+	&ixgbe_sysfs_txupacks_attr.attr,
+	&ixgbe_sysfs_txmpacks_attr.attr,
+	&ixgbe_sysfs_txbpacks_attr.attr,
+	&ixgbe_sysfs_rxframes_attr.attr,
+	&ixgbe_sysfs_rxbytes_attr.attr,
+	&ixgbe_sysfs_txframes_attr.attr,
+	&ixgbe_sysfs_txbytes_attr.attr,
+	&ixgbe_sysfs_linkstat_attr.attr,
+	&ixgbe_sysfs_funcid_attr.attr,
+	&ixgbe_sysfs_funvers_attr.attr,
+	&ixgbe_sysfs_macburn_attr.attr,
+	&ixgbe_sysfs_macadmn_attr.attr,
+	&ixgbe_sysfs_maclla1_attr.attr,
+	&ixgbe_sysfs_mtusize_attr.attr,
+	&ixgbe_sysfs_featflag_attr.attr,
+	&ixgbe_sysfs_lsominct_attr.attr,
+	&ixgbe_sysfs_prommode_attr.attr,
+	&ixgbe_sysfs_txdscqsz_attr.attr,
+	&ixgbe_sysfs_rxdscqsz_attr.attr,
+	&ixgbe_sysfs_txqavg_attr.attr,
+	&ixgbe_sysfs_rxqavg_attr.attr,
+	&ixgbe_sysfs_iovotype_attr.attr,
+	&ixgbe_sysfs_funcnbr_attr.attr,
+	&ixgbe_sysfs_pciebnbr_attr.attr,
+	NULL
+};
+
+/* add attributes to a group */
+static struct attribute_group attr_group = {
+	.attrs = attrs,
+};
+
 #ifdef CONFIG_IXGBE_HWMON
 
 /* hwmon callback functions */
@@ -185,8 +941,11 @@ static void ixgbe_sysfs_del_adapter(struct ixgbe_adapter *adapter)
 		hwmon_device_unregister(adapter->ixgbe_hwmon_buff.device);
 #endif /* CONFIG_IXGBE_HWMON */
 
-	if (adapter->info_kobj != NULL)
+	if (adapter->info_kobj != NULL) {
+		sysfs_remove_group(adapter->info_kobj, &attr_group);
 		kobject_put(adapter->info_kobj);
+		adapter->info_kobj = NULL;
+	}
 }
 
 /* called from ixgbe_main.c */
@@ -213,17 +972,22 @@ int ixgbe_sysfs_init(struct ixgbe_adapter *adapter)
 		goto err;
 	}
 
+	rc = sysfs_create_group(adapter->info_kobj, &attr_group);
+	if (rc)
+		goto err;
+
 #ifdef CONFIG_IXGBE_HWMON
 	/* If this method isn't defined we don't support thermals */
 	if (adapter->hw.mac.ops.init_thermal_sensor_thresh == NULL) {
-		rc = -EPERM;
-		goto err;
+		goto exit;
 	}
 
 	/* Don't create thermal hwmon interface if no sensors present */
 	rc = adapter->hw.mac.ops.init_thermal_sensor_thresh(&adapter->hw);
-	if (rc)
-		goto err;
+	if (rc) {
+		rc = 0;
+		goto exit;
+	}
 
 	/*
 	 * Allocation space for max attributs
-- 
1.7.7.6
