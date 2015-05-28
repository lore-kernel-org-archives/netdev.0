From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: RE: [PATCH] net: qlcnic: clean up sysfs error codes
Date: Thu, 28 May 2015 17:42:31 +0000
Message-ID: <C562D0E12CBDE44E8A0CCAB7706009670194185293@AVMB1.qlogic.org>
References: <1432601385-24582-1-git-send-email-vz@mleia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>
To: Vladimir Zapolskiy <vz@mleia.com>,
	David Miller <davem@davemloft.net>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>,
	Dept-GE Linux NIC Dev <Dept-GELinuxNICDev@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:12511 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753518AbbE1Rmh convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 May 2015 13:42:37 -0400
In-Reply-To: <1432601385-24582-1-git-send-email-vz@mleia.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: dept_hsg_linux_nic_dev-bounces@qlclistserver.qlogic.com
>[mailto:dept_hsg_linux_nic_dev-bounces@qlclistserver.qlogic.com] On
>Behalf Of Vladimir Zapolskiy
>Sent: Tuesday, May 26, 2015 6:20 AM
>To: David Miller; Shahed Shaikh; Dept-GE Linux NIC Dev
>Cc: netdev
>Subject: [PATCH] net: qlcnic: clean up sysfs error codes
>
>Replace confusing QL_STATUS_INVALID_PARAM == -1 == -EPERM with -
>EINVAL and QLC_STATUS_UNSUPPORTED_CMD == -2 == -ENOENT with -
>EOPNOTSUPP, the latter error code is arguable, but it is already used in the
>driver, so let it be here as well.
>
>Also remove always false (!buf) check on read(), the driver should not care if
>userspace gets its EFAULT or not.
>
>Signed-off-by: Vladimir Zapolskiy <vz@mleia.com>
>---
> drivers/net/ethernet/qlogic/qlcnic/qlcnic.h       |  3 -
> drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c  |  2 +-
>drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c | 77 +++++++++++-----------
>-
> 3 files changed, 36 insertions(+), 46 deletions(-)
>
>diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
>b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
>index f221126..055f376 100644
>--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
>+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
>@@ -1326,9 +1326,6 @@ struct qlcnic_eswitch {  };
>
>
>-/* Return codes for Error handling */
>-#define QL_STATUS_INVALID_PARAM	-1
>-
> #define MAX_BW			100	/* % of link speed */
> #define MIN_BW			1	/* % of link speed */
> #define MAX_VLAN_ID		4095
>diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
>b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
>index 367f397..2f6cc42 100644
>--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
>+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
>@@ -1031,7 +1031,7 @@ int qlcnic_init_pci_info(struct qlcnic_adapter
>*adapter)
> 		pfn = pci_info[i].id;
>
> 		if (pfn >= ahw->max_vnic_func) {
>-			ret = QL_STATUS_INVALID_PARAM;
>+			ret = -EINVAL;
> 			dev_err(&adapter->pdev->dev, "%s: Invalid function
>0x%x, max 0x%x\n",
> 				__func__, pfn, ahw->max_vnic_func);
> 			goto err_eswitch;
>diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
>b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
>index 59a721f..05c28f2 100644
>--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
>+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
>@@ -24,8 +24,6 @@
> #include <linux/hwmon-sysfs.h>
> #endif
>
>-#define QLC_STATUS_UNSUPPORTED_CMD	-2
>-
> int qlcnicvf_config_bridged_mode(struct qlcnic_adapter *adapter, u32
>enable)  {
> 	return -EOPNOTSUPP;
>@@ -166,7 +164,7 @@ static int qlcnic_82xx_store_beacon(struct
>qlcnic_adapter *adapter,
> 	u8 b_state, b_rate;
>
> 	if (len != sizeof(u16))
>-		return QL_STATUS_INVALID_PARAM;
>+		return -EINVAL;
>
> 	memcpy(&beacon, buf, sizeof(u16));
> 	err = qlcnic_validate_beacon(adapter, beacon, &b_state, &b_rate);
>@@ -383,17 +381,17 @@ static int validate_pm_config(struct qlcnic_adapter
>*adapter,
> 		dest_pci_func = pm_cfg[i].dest_npar;
> 		src_index = qlcnic_is_valid_nic_func(adapter, src_pci_func);
> 		if (src_index < 0)
>-			return QL_STATUS_INVALID_PARAM;
>+			return -EINVAL;
>
> 		dest_index = qlcnic_is_valid_nic_func(adapter,
>dest_pci_func);
> 		if (dest_index < 0)
>-			return QL_STATUS_INVALID_PARAM;
>+			return -EINVAL;
>
> 		s_esw_id = adapter->npars[src_index].phy_port;
> 		d_esw_id = adapter->npars[dest_index].phy_port;
>
> 		if (s_esw_id != d_esw_id)
>-			return QL_STATUS_INVALID_PARAM;
>+			return -EINVAL;
> 	}
>
> 	return 0;
>@@ -414,7 +412,7 @@ static ssize_t qlcnic_sysfs_write_pm_config(struct file
>*filp,
> 	count	= size / sizeof(struct qlcnic_pm_func_cfg);
> 	rem	= size % sizeof(struct qlcnic_pm_func_cfg);
> 	if (rem)
>-		return QL_STATUS_INVALID_PARAM;
>+		return -EINVAL;
>
> 	qlcnic_swap32_buffer((u32 *)buf, size / sizeof(u32));
> 	pm_cfg = (struct qlcnic_pm_func_cfg *)buf; @@ -427,7 +425,7 @@
>static ssize_t qlcnic_sysfs_write_pm_config(struct file *filp,
> 		action = !!pm_cfg[i].action;
> 		index = qlcnic_is_valid_nic_func(adapter, pci_func);
> 		if (index < 0)
>-			return QL_STATUS_INVALID_PARAM;
>+			return -EINVAL;
>
> 		id = adapter->npars[index].phy_port;
> 		ret = qlcnic_config_port_mirroring(adapter, id, @@ -440,7
>+438,7 @@ static ssize_t qlcnic_sysfs_write_pm_config(struct file *filp,
> 		pci_func = pm_cfg[i].pci_func;
> 		index = qlcnic_is_valid_nic_func(adapter, pci_func);
> 		if (index < 0)
>-			return QL_STATUS_INVALID_PARAM;
>+			return -EINVAL;
> 		id = adapter->npars[index].phy_port;
> 		adapter->npars[index].enable_pm = !!pm_cfg[i].action;
> 		adapter->npars[index].dest_npar = id; @@ -499,11 +497,11
>@@ static int validate_esw_config(struct qlcnic_adapter *adapter,
> 	for (i = 0; i < count; i++) {
> 		pci_func = esw_cfg[i].pci_func;
> 		if (pci_func >= ahw->max_vnic_func)
>-			return QL_STATUS_INVALID_PARAM;
>+			return -EINVAL;
>
> 		if (adapter->ahw->op_mode == QLCNIC_MGMT_FUNC)
> 			if (qlcnic_is_valid_nic_func(adapter, pci_func) < 0)
>-				return QL_STATUS_INVALID_PARAM;
>+				return -EINVAL;
>
> 		switch (esw_cfg[i].op_mode) {
> 		case QLCNIC_PORT_DEFAULTS:
>@@ -517,25 +515,25 @@ static int validate_esw_config(struct qlcnic_adapter
>*adapter,
>
> 			if (ret != QLCNIC_NON_PRIV_FUNC) {
> 				if (esw_cfg[i].mac_anti_spoof != 0)
>-					return QL_STATUS_INVALID_PARAM;
>+					return -EINVAL;
> 				if (esw_cfg[i].mac_override != 1)
>-					return QL_STATUS_INVALID_PARAM;
>+					return -EINVAL;
> 				if (esw_cfg[i].promisc_mode != 1)
>-					return QL_STATUS_INVALID_PARAM;
>+					return -EINVAL;
> 			}
> 			break;
> 		case QLCNIC_ADD_VLAN:
> 			if (!IS_VALID_VLAN(esw_cfg[i].vlan_id))
>-				return QL_STATUS_INVALID_PARAM;
>+				return -EINVAL;
> 			if (!esw_cfg[i].op_type)
>-				return QL_STATUS_INVALID_PARAM;
>+				return -EINVAL;
> 			break;
> 		case QLCNIC_DEL_VLAN:
> 			if (!esw_cfg[i].op_type)
>-				return QL_STATUS_INVALID_PARAM;
>+				return -EINVAL;
> 			break;
> 		default:
>-			return QL_STATUS_INVALID_PARAM;
>+			return -EINVAL;
> 		}
> 	}
>
>@@ -559,7 +557,7 @@ static ssize_t qlcnic_sysfs_write_esw_config(struct file
>*file,
> 	count	= size / sizeof(struct qlcnic_esw_func_cfg);
> 	rem	= size % sizeof(struct qlcnic_esw_func_cfg);
> 	if (rem)
>-		return QL_STATUS_INVALID_PARAM;
>+		return -EINVAL;
>
> 	qlcnic_swap32_buffer((u32 *)buf, size / sizeof(u32));
> 	esw_cfg = (struct qlcnic_esw_func_cfg *)buf; @@ -570,7 +568,7 @@
>static ssize_t qlcnic_sysfs_write_esw_config(struct file *file,
> 	for (i = 0; i < count; i++) {
> 		if (adapter->ahw->op_mode == QLCNIC_MGMT_FUNC)
> 			if (qlcnic_config_switch_port(adapter, &esw_cfg[i]))
>-				return QL_STATUS_INVALID_PARAM;
>+				return -EINVAL;
>
> 		if (adapter->ahw->pci_func != esw_cfg[i].pci_func)
> 			continue;
>@@ -604,7 +602,7 @@ static ssize_t qlcnic_sysfs_write_esw_config(struct file
>*file,
> 		pci_func = esw_cfg[i].pci_func;
> 		index = qlcnic_is_valid_nic_func(adapter, pci_func);
> 		if (index < 0)
>-			return QL_STATUS_INVALID_PARAM;
>+			return -EINVAL;
> 		npar = &adapter->npars[index];
> 		switch (esw_cfg[i].op_mode) {
> 		case QLCNIC_PORT_DEFAULTS:
>@@ -654,7 +652,7 @@ static ssize_t qlcnic_sysfs_read_esw_config(struct file
>*file,
>
> 		esw_cfg[pci_func].pci_func = pci_func;
> 		if (qlcnic_get_eswitch_port_config(adapter,
>&esw_cfg[pci_func]))
>-			return QL_STATUS_INVALID_PARAM;
>+			return -EINVAL;
> 	}
> 	qlcnic_swap32_buffer((u32 *)buf, size / sizeof(u32));
> 	return size;
>@@ -669,11 +667,11 @@ static int validate_npar_config(struct qlcnic_adapter
>*adapter,
> 	for (i = 0; i < count; i++) {
> 		pci_func = np_cfg[i].pci_func;
> 		if (qlcnic_is_valid_nic_func(adapter, pci_func) < 0)
>-			return QL_STATUS_INVALID_PARAM;
>+			return -EINVAL;
>
> 		if (!IS_VALID_BW(np_cfg[i].min_bw) ||
> 		    !IS_VALID_BW(np_cfg[i].max_bw))
>-			return QL_STATUS_INVALID_PARAM;
>+			return -EINVAL;
> 	}
> 	return 0;
> }
>@@ -694,7 +692,7 @@ static ssize_t qlcnic_sysfs_write_npar_config(struct file
>*file,
> 	count	= size / sizeof(struct qlcnic_npar_func_cfg);
> 	rem	= size % sizeof(struct qlcnic_npar_func_cfg);
> 	if (rem)
>-		return QL_STATUS_INVALID_PARAM;
>+		return -EINVAL;
>
> 	qlcnic_swap32_buffer((u32 *)buf, size / sizeof(u32));
> 	np_cfg = (struct qlcnic_npar_func_cfg *)buf; @@ -717,7 +715,7 @@
>static ssize_t qlcnic_sysfs_write_npar_config(struct file *file,
> 			return ret;
> 		index = qlcnic_is_valid_nic_func(adapter, pci_func);
> 		if (index < 0)
>-			return QL_STATUS_INVALID_PARAM;
>+			return -EINVAL;
> 		adapter->npars[index].min_bw = nic_info.min_tx_bw;
> 		adapter->npars[index].max_bw = nic_info.max_tx_bw;
> 	}
>@@ -784,13 +782,13 @@ static ssize_t qlcnic_sysfs_get_port_stats(struct file
>*file,
> 	int ret;
>
> 	if (qlcnic_83xx_check(adapter))
>-		return QLC_STATUS_UNSUPPORTED_CMD;
>+		return -EOPNOTSUPP;
>
> 	if (size != sizeof(struct qlcnic_esw_statistics))
>-		return QL_STATUS_INVALID_PARAM;
>+		return -EINVAL;
>
> 	if (offset >= adapter->ahw->max_vnic_func)
>-		return QL_STATUS_INVALID_PARAM;
>+		return -EINVAL;
>
> 	memset(&port_stats, 0, size);
> 	ret = qlcnic_get_port_stats(adapter, offset,
>QLCNIC_QUERY_RX_COUNTER, @@ -819,13 +817,13 @@ static ssize_t
>qlcnic_sysfs_get_esw_stats(struct file *file,
> 	int ret;
>
> 	if (qlcnic_83xx_check(adapter))
>-		return QLC_STATUS_UNSUPPORTED_CMD;
>+		return -EOPNOTSUPP;
>
> 	if (size != sizeof(struct qlcnic_esw_statistics))
>-		return QL_STATUS_INVALID_PARAM;
>+		return -EINVAL;
>
> 	if (offset >= QLCNIC_NIU_MAX_XG_PORTS)
>-		return QL_STATUS_INVALID_PARAM;
>+		return -EINVAL;
>
> 	memset(&esw_stats, 0, size);
> 	ret = qlcnic_get_eswitch_stats(adapter, offset,
>QLCNIC_QUERY_RX_COUNTER, @@ -853,10 +851,10 @@ static ssize_t
>qlcnic_sysfs_clear_esw_stats(struct file *file,
> 	int ret;
>
> 	if (qlcnic_83xx_check(adapter))
>-		return QLC_STATUS_UNSUPPORTED_CMD;
>+		return -EOPNOTSUPP;
>
> 	if (offset >= QLCNIC_NIU_MAX_XG_PORTS)
>-		return QL_STATUS_INVALID_PARAM;
>+		return -EINVAL;
>
> 	ret = qlcnic_clear_esw_stats(adapter, QLCNIC_STATS_ESWITCH,
>offset,
> 				     QLCNIC_QUERY_RX_COUNTER);
>@@ -883,10 +881,10 @@ static ssize_t qlcnic_sysfs_clear_port_stats(struct
>file *file,
> 	int ret;
>
> 	if (qlcnic_83xx_check(adapter))
>-		return QLC_STATUS_UNSUPPORTED_CMD;
>+		return -EOPNOTSUPP;
>
> 	if (offset >= adapter->ahw->max_vnic_func)
>-		return QL_STATUS_INVALID_PARAM;
>+		return -EINVAL;
>
> 	ret = qlcnic_clear_esw_stats(adapter, QLCNIC_STATS_PORT, offset,
> 				     QLCNIC_QUERY_RX_COUNTER);
>@@ -953,9 +951,7 @@ static ssize_t
>qlcnic_83xx_sysfs_flash_read_handler(struct file *filp,
> 	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
>
> 	if (!size)
>-		return QL_STATUS_INVALID_PARAM;
>-	if (!buf)
>-		return QL_STATUS_INVALID_PARAM;
>+		return -EINVAL;
>
> 	count = size / sizeof(u32);
>
>@@ -1132,9 +1128,6 @@ static ssize_t
>qlcnic_83xx_sysfs_flash_write_handler(struct file *filp,
> 	struct device *dev = container_of(kobj, struct device, kobj);
> 	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
>
>-	if (!buf)
>-		return QL_STATUS_INVALID_PARAM;
>-
> 	ret = kstrtoul(buf, 16, &data);
>
> 	switch (data) {
>--
>2.1.4

Acked-by: Rajesh Borundia <rajesh.borundia@qlogic.com>

Thanks
