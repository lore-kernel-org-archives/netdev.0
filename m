From: Prarit Bhargava <prarit@redhat.com>
Subject: [PATCH]: vxge: Fix checkstack warning in vxge_probe()
Date: Fri, 28 May 2010 14:01:49 -0400
Message-ID: <20100528175735.30903.21134.sendpatchset@prarit.bos.redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Prarit Bhargava <prarit@redhat.com>
To: netdev@vger.kernel.org, mschmidt@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22037 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753103Ab0E1SBu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 May 2010 14:01:50 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o4SI1ofb008681
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 28 May 2010 14:01:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Linux 2.6.33 reports this checkstack warning:

drivers/net/vxge/vxge-main.c: In function 'vxge_probe':
drivers/net/vxge/vxge-main.c:4409: warning: the frame size of 1028 byte=
s is larger than 1024 bytes

This warning does not occur in the latest linux-2.6 or linux-next, howe=
ver,
when I do a 'make -j32 CONFIG_FRAME_WARN=3D512' instead of 1024 I see

drivers/net/vxge/vxge-main.c: In function =E2=80=98vxge_probe=E2=80=99:
drivers/net/vxge/vxge-main.c:4423: warning: the frame size of 1024 byte=
s is larger than 512 bytes

This patch moves the large vxge_config struct off the stack.

Signed-off-by: Prarit Bhargava <prarit@redhat.com>

diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.=
c
index 2bab364..b955802 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -4016,7 +4016,7 @@ vxge_probe(struct pci_dev *pdev, const struct pci=
_device_id *pre)
 	int high_dma =3D 0;
 	u64 vpath_mask =3D 0;
 	struct vxgedev *vdev;
-	struct vxge_config ll_config;
+	struct vxge_config *ll_config =3D NULL;
 	struct vxge_hw_device_config *device_config =3D NULL;
 	struct vxge_hw_device_attr attr;
 	int i, j, no_of_vpath =3D 0, max_vpath_supported =3D 0;
@@ -4075,17 +4075,24 @@ vxge_probe(struct pci_dev *pdev, const struct p=
ci_device_id *pre)
 		goto _exit0;
 	}
=20
-	memset(&ll_config, 0, sizeof(struct vxge_config));
-	ll_config.tx_steering_type =3D TX_MULTIQ_STEERING;
-	ll_config.intr_type =3D MSI_X;
-	ll_config.napi_weight =3D NEW_NAPI_WEIGHT;
-	ll_config.rth_steering =3D RTH_STEERING;
+	ll_config =3D kzalloc(sizeof(*ll_config), GFP_KERNEL);
+	if (!ll_config) {
+		ret =3D -ENOMEM;
+		vxge_debug_init(VXGE_ERR,
+			"ll_config : malloc failed %s %d",
+			__FILE__, __LINE__);
+		goto _exit0;
+	}
+	ll_config->tx_steering_type =3D TX_MULTIQ_STEERING;
+	ll_config->intr_type =3D MSI_X;
+	ll_config->napi_weight =3D NEW_NAPI_WEIGHT;
+	ll_config->rth_steering =3D RTH_STEERING;
=20
 	/* get the default configuration parameters */
 	vxge_hw_device_config_default_get(device_config);
=20
 	/* initialize configuration parameters */
-	vxge_device_config_init(device_config, &ll_config.intr_type);
+	vxge_device_config_init(device_config, &ll_config->intr_type);
=20
 	ret =3D pci_enable_device(pdev);
 	if (ret) {
@@ -4138,7 +4145,7 @@ vxge_probe(struct pci_dev *pdev, const struct pci=
_device_id *pre)
 		(unsigned long long)pci_resource_start(pdev, 0));
=20
 	status =3D vxge_hw_device_hw_info_get(attr.bar0,
-			&ll_config.device_hw_info);
+			&ll_config->device_hw_info);
 	if (status !=3D VXGE_HW_OK) {
 		vxge_debug_init(VXGE_ERR,
 			"%s: Reading of hardware info failed."
@@ -4147,7 +4154,7 @@ vxge_probe(struct pci_dev *pdev, const struct pci=
_device_id *pre)
 		goto _exit3;
 	}
=20
-	if (ll_config.device_hw_info.fw_version.major !=3D
+	if (ll_config->device_hw_info.fw_version.major !=3D
 		VXGE_DRIVER_FW_VERSION_MAJOR) {
 		vxge_debug_init(VXGE_ERR,
 			"%s: Incorrect firmware version."
@@ -4157,7 +4164,7 @@ vxge_probe(struct pci_dev *pdev, const struct pci=
_device_id *pre)
 		goto _exit3;
 	}
=20
-	vpath_mask =3D ll_config.device_hw_info.vpath_mask;
+	vpath_mask =3D ll_config->device_hw_info.vpath_mask;
 	if (vpath_mask =3D=3D 0) {
 		vxge_debug_ll_config(VXGE_TRACE,
 			"%s: No vpaths available in device", VXGE_DRIVER_NAME);
@@ -4169,10 +4176,10 @@ vxge_probe(struct pci_dev *pdev, const struct p=
ci_device_id *pre)
 		"%s:%d  Vpath mask =3D %llx", __func__, __LINE__,
 		(unsigned long long)vpath_mask);
=20
-	function_mode =3D ll_config.device_hw_info.function_mode;
-	host_type =3D ll_config.device_hw_info.host_type;
+	function_mode =3D ll_config->device_hw_info.function_mode;
+	host_type =3D ll_config->device_hw_info.host_type;
 	is_privileged =3D __vxge_hw_device_is_privilaged(host_type,
-		ll_config.device_hw_info.func_id);
+		ll_config->device_hw_info.func_id);
=20
 	/* Check how many vpaths are available */
 	for (i =3D 0; i < VXGE_HW_MAX_VIRTUAL_PATHS; i++) {
@@ -4186,7 +4193,7 @@ vxge_probe(struct pci_dev *pdev, const struct pci=
_device_id *pre)
=20
 	/* Enable SRIOV mode, if firmware has SRIOV support and if it is a PF=
 */
 	if (is_sriov(function_mode) && (max_config_dev > 1) &&
-		(ll_config.intr_type !=3D INTA) &&
+		(ll_config->intr_type !=3D INTA) &&
 		(is_privileged =3D=3D VXGE_HW_OK)) {
 		ret =3D pci_enable_sriov(pdev, ((max_config_dev - 1) < num_vfs)
 			? (max_config_dev - 1) : num_vfs);
@@ -4199,7 +4206,7 @@ vxge_probe(struct pci_dev *pdev, const struct pci=
_device_id *pre)
 	 * Configure vpaths and get driver configured number of vpaths
 	 * which is less than or equal to the maximum vpaths per function.
 	 */
-	no_of_vpath =3D vxge_config_vpaths(device_config, vpath_mask, &ll_con=
fig);
+	no_of_vpath =3D vxge_config_vpaths(device_config, vpath_mask, ll_conf=
ig);
 	if (!no_of_vpath) {
 		vxge_debug_ll_config(VXGE_ERR,
 			"%s: No more vpaths to configure", VXGE_DRIVER_NAME);
@@ -4234,21 +4241,21 @@ vxge_probe(struct pci_dev *pdev, const struct p=
ci_device_id *pre)
 	/* set private device info */
 	pci_set_drvdata(pdev, hldev);
=20
-	ll_config.gro_enable =3D VXGE_GRO_ALWAYS_AGGREGATE;
-	ll_config.fifo_indicate_max_pkts =3D VXGE_FIFO_INDICATE_MAX_PKTS;
-	ll_config.addr_learn_en =3D addr_learn_en;
-	ll_config.rth_algorithm =3D RTH_ALG_JENKINS;
-	ll_config.rth_hash_type_tcpipv4 =3D VXGE_HW_RING_HASH_TYPE_TCP_IPV4;
-	ll_config.rth_hash_type_ipv4 =3D VXGE_HW_RING_HASH_TYPE_NONE;
-	ll_config.rth_hash_type_tcpipv6 =3D VXGE_HW_RING_HASH_TYPE_NONE;
-	ll_config.rth_hash_type_ipv6 =3D VXGE_HW_RING_HASH_TYPE_NONE;
-	ll_config.rth_hash_type_tcpipv6ex =3D VXGE_HW_RING_HASH_TYPE_NONE;
-	ll_config.rth_hash_type_ipv6ex =3D VXGE_HW_RING_HASH_TYPE_NONE;
-	ll_config.rth_bkt_sz =3D RTH_BUCKET_SIZE;
-	ll_config.tx_pause_enable =3D VXGE_PAUSE_CTRL_ENABLE;
-	ll_config.rx_pause_enable =3D VXGE_PAUSE_CTRL_ENABLE;
-
-	if (vxge_device_register(hldev, &ll_config, high_dma, no_of_vpath,
+	ll_config->gro_enable =3D VXGE_GRO_ALWAYS_AGGREGATE;
+	ll_config->fifo_indicate_max_pkts =3D VXGE_FIFO_INDICATE_MAX_PKTS;
+	ll_config->addr_learn_en =3D addr_learn_en;
+	ll_config->rth_algorithm =3D RTH_ALG_JENKINS;
+	ll_config->rth_hash_type_tcpipv4 =3D VXGE_HW_RING_HASH_TYPE_TCP_IPV4;
+	ll_config->rth_hash_type_ipv4 =3D VXGE_HW_RING_HASH_TYPE_NONE;
+	ll_config->rth_hash_type_tcpipv6 =3D VXGE_HW_RING_HASH_TYPE_NONE;
+	ll_config->rth_hash_type_ipv6 =3D VXGE_HW_RING_HASH_TYPE_NONE;
+	ll_config->rth_hash_type_tcpipv6ex =3D VXGE_HW_RING_HASH_TYPE_NONE;
+	ll_config->rth_hash_type_ipv6ex =3D VXGE_HW_RING_HASH_TYPE_NONE;
+	ll_config->rth_bkt_sz =3D RTH_BUCKET_SIZE;
+	ll_config->tx_pause_enable =3D VXGE_PAUSE_CTRL_ENABLE;
+	ll_config->rx_pause_enable =3D VXGE_PAUSE_CTRL_ENABLE;
+
+	if (vxge_device_register(hldev, ll_config, high_dma, no_of_vpath,
 		&vdev)) {
 		ret =3D -EINVAL;
 		goto _exit4;
@@ -4279,7 +4286,7 @@ vxge_probe(struct pci_dev *pdev, const struct pci=
_device_id *pre)
 		vdev->vpaths[j].vdev =3D vdev;
 		vdev->vpaths[j].max_mac_addr_cnt =3D max_mac_vpath;
 		memcpy((u8 *)vdev->vpaths[j].macaddr,
-				(u8 *)ll_config.device_hw_info.mac_addrs[i],
+				ll_config->device_hw_info.mac_addrs[i],
 				ETH_ALEN);
=20
 		/* Initialize the mac address list header */
@@ -4300,18 +4307,18 @@ vxge_probe(struct pci_dev *pdev, const struct p=
ci_device_id *pre)
=20
 	macaddr =3D (u8 *)vdev->vpaths[0].macaddr;
=20
-	ll_config.device_hw_info.serial_number[VXGE_HW_INFO_LEN - 1] =3D '\0'=
;
-	ll_config.device_hw_info.product_desc[VXGE_HW_INFO_LEN - 1] =3D '\0';
-	ll_config.device_hw_info.part_number[VXGE_HW_INFO_LEN - 1] =3D '\0';
+	ll_config->device_hw_info.serial_number[VXGE_HW_INFO_LEN - 1] =3D '\0=
';
+	ll_config->device_hw_info.product_desc[VXGE_HW_INFO_LEN - 1] =3D '\0'=
;
+	ll_config->device_hw_info.part_number[VXGE_HW_INFO_LEN - 1] =3D '\0';
=20
 	vxge_debug_init(VXGE_TRACE, "%s: SERIAL NUMBER: %s",
-		vdev->ndev->name, ll_config.device_hw_info.serial_number);
+		vdev->ndev->name, ll_config->device_hw_info.serial_number);
=20
 	vxge_debug_init(VXGE_TRACE, "%s: PART NUMBER: %s",
-		vdev->ndev->name, ll_config.device_hw_info.part_number);
+		vdev->ndev->name, ll_config->device_hw_info.part_number);
=20
 	vxge_debug_init(VXGE_TRACE, "%s: Neterion %s Server Adapter",
-		vdev->ndev->name, ll_config.device_hw_info.product_desc);
+		vdev->ndev->name, ll_config->device_hw_info.product_desc);
=20
 	vxge_debug_init(VXGE_TRACE, "%s: MAC ADDR: %pM",
 		vdev->ndev->name, macaddr);
@@ -4321,11 +4328,11 @@ vxge_probe(struct pci_dev *pdev, const struct p=
ci_device_id *pre)
=20
 	vxge_debug_init(VXGE_TRACE,
 		"%s: Firmware version : %s Date : %s", vdev->ndev->name,
-		ll_config.device_hw_info.fw_version.version,
-		ll_config.device_hw_info.fw_date.date);
+		ll_config->device_hw_info.fw_version.version,
+		ll_config->device_hw_info.fw_date.date);
=20
 	if (new_device) {
-		switch (ll_config.device_hw_info.function_mode) {
+		switch (ll_config->device_hw_info.function_mode) {
 		case VXGE_HW_FUNCTION_MODE_SINGLE_FUNCTION:
 			vxge_debug_init(VXGE_TRACE,
 			"%s: Single Function Mode Enabled", vdev->ndev->name);
@@ -4348,7 +4355,7 @@ vxge_probe(struct pci_dev *pdev, const struct pci=
_device_id *pre)
 	vxge_print_parm(vdev, vpath_mask);
=20
 	/* Store the fw version for ethttool option */
-	strcpy(vdev->fw_version, ll_config.device_hw_info.fw_version.version)=
;
+	strcpy(vdev->fw_version, ll_config->device_hw_info.fw_version.version=
);
 	memcpy(vdev->ndev->dev_addr, (u8 *)vdev->vpaths[0].macaddr, ETH_ALEN)=
;
 	memcpy(vdev->ndev->perm_addr, vdev->ndev->dev_addr, ETH_ALEN);
=20
@@ -4387,7 +4394,7 @@ vxge_probe(struct pci_dev *pdev, const struct pci=
_device_id *pre)
 	 * present to prevent such a failure.
 	 */
=20
-	if (ll_config.device_hw_info.function_mode =3D=3D
+	if (ll_config->device_hw_info.function_mode =3D=3D
 		VXGE_HW_FUNCTION_MODE_MULTI_FUNCTION)
 		if (vdev->config.intr_type =3D=3D INTA)
 			vxge_hw_device_unmask_all(hldev);
@@ -4399,6 +4406,7 @@ vxge_probe(struct pci_dev *pdev, const struct pci=
_device_id *pre)
 	VXGE_COPY_DEBUG_INFO_TO_LL(vdev, vxge_hw_device_error_level_get(hldev=
),
 		vxge_hw_device_trace_level_get(hldev));
=20
+	kfree(ll_config);
 	return 0;
=20
 _exit5:
@@ -4416,6 +4424,7 @@ _exit2:
 _exit1:
 	pci_disable_device(pdev);
 _exit0:
+	kfree(ll_config);
 	kfree(device_config);
 	driver_config->config_dev_cnt--;
 	pci_set_drvdata(pdev, NULL);
