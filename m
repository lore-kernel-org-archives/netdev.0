From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next] cxgb4: Ripping out old hard-wired initialization code in driver
Date: Tue, 13 Jan 2015 15:19:25 +0530
Message-ID: <1421142565-10232-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:19201 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751159AbbAMJoC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 04:44:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Removing old hard-wired initialization code in the driver, which is no longer
used. Also deprecating few module parameters.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |  480 +++--------------------
 drivers/net/ethernet/chelsio/cxgb4/sge.c        |   98 +----
 2 files changed, 58 insertions(+), 520 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 23ae0b7..082a596 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -79,99 +79,6 @@
 #define DRV_VERSION "2.0.0-ko"
 #define DRV_DESC "Chelsio T4/T5 Network Driver"
 
-/*
- * Max interrupt hold-off timer value in us.  Queues fall back to this value
- * under extreme memory pressure so it's largish to give the system time to
- * recover.
- */
-#define MAX_SGE_TIMERVAL 200U
-
-enum {
-	/*
-	 * Physical Function provisioning constants.
-	 */
-	PFRES_NVI = 4,			/* # of Virtual Interfaces */
-	PFRES_NETHCTRL = 128,		/* # of EQs used for ETH or CTRL Qs */
-	PFRES_NIQFLINT = 128,		/* # of ingress Qs/w Free List(s)/intr
-					 */
-	PFRES_NEQ = 256,		/* # of egress queues */
-	PFRES_NIQ = 0,			/* # of ingress queues */
-	PFRES_TC = 0,			/* PCI-E traffic class */
-	PFRES_NEXACTF = 128,		/* # of exact MPS filters */
-
-	PFRES_R_CAPS = FW_CMD_CAP_PF,
-	PFRES_WX_CAPS = FW_CMD_CAP_PF,
-
-#ifdef CONFIG_PCI_IOV
-	/*
-	 * Virtual Function provisioning constants.  We need two extra Ingress
-	 * Queues with Interrupt capability to serve as the VF's Firmware
-	 * Event Queue and Forwarded Interrupt Queue (when using MSI mode) --
-	 * neither will have Free Lists associated with them).  For each
-	 * Ethernet/Control Egress Queue and for each Free List, we need an
-	 * Egress Context.
-	 */
-	VFRES_NPORTS = 1,		/* # of "ports" per VF */
-	VFRES_NQSETS = 2,		/* # of "Queue Sets" per VF */
-
-	VFRES_NVI = VFRES_NPORTS,	/* # of Virtual Interfaces */
-	VFRES_NETHCTRL = VFRES_NQSETS,	/* # of EQs used for ETH or CTRL Qs */
-	VFRES_NIQFLINT = VFRES_NQSETS+2,/* # of ingress Qs/w Free List(s)/intr */
-	VFRES_NEQ = VFRES_NQSETS*2,	/* # of egress queues */
-	VFRES_NIQ = 0,			/* # of non-fl/int ingress queues */
-	VFRES_TC = 0,			/* PCI-E traffic class */
-	VFRES_NEXACTF = 16,		/* # of exact MPS filters */
-
-	VFRES_R_CAPS = FW_CMD_CAP_DMAQ|FW_CMD_CAP_VF|FW_CMD_CAP_PORT,
-	VFRES_WX_CAPS = FW_CMD_CAP_DMAQ|FW_CMD_CAP_VF,
-#endif
-};
-
-/*
- * Provide a Port Access Rights Mask for the specified PF/VF.  This is very
- * static and likely not to be useful in the long run.  We really need to
- * implement some form of persistent configuration which the firmware
- * controls.
- */
-static unsigned int pfvfres_pmask(struct adapter *adapter,
-				  unsigned int pf, unsigned int vf)
-{
-	unsigned int portn, portvec;
-
-	/*
-	 * Give PF's access to all of the ports.
-	 */
-	if (vf == 0)
-		return FW_PFVF_CMD_PMASK_M;
-
-	/*
-	 * For VFs, we'll assign them access to the ports based purely on the
-	 * PF.  We assign active ports in order, wrapping around if there are
-	 * fewer active ports than PFs: e.g. active port[pf % nports].
-	 * Unfortunately the adapter's port_info structs haven't been
-	 * initialized yet so we have to compute this.
-	 */
-	if (adapter->params.nports == 0)
-		return 0;
-
-	portn = pf % adapter->params.nports;
-	portvec = adapter->params.portvec;
-	for (;;) {
-		/*
-		 * Isolate the lowest set bit in the port vector.  If we're at
-		 * the port number that we want, return that as the pmask.
-		 * otherwise mask that bit out of the port vector and
-		 * decrement our port number ...
-		 */
-		unsigned int pmask = portvec ^ (portvec & (portvec-1));
-		if (portn == 0)
-			return pmask;
-		portn--;
-		portvec &= ~pmask;
-	}
-	/*NOTREACHED*/
-}
-
 enum {
 	MAX_TXQ_ENTRIES      = 16384,
 	MAX_CTRL_TXQ_ENTRIES = 1024,
@@ -264,7 +171,8 @@ MODULE_PARM_DESC(force_init, "Forcibly become Master PF and initialize adapter")
 static uint force_old_init;
 
 module_param(force_old_init, uint, 0644);
-MODULE_PARM_DESC(force_old_init, "Force old initialization sequence");
+MODULE_PARM_DESC(force_old_init, "Force old initialization sequence, deprecated"
+		 " parameter");
 
 static int dflt_msg_enable = DFLT_MSG_ENABLE;
 
@@ -293,13 +201,14 @@ static unsigned int intr_holdoff[SGE_NTIMERS - 1] = { 5, 10, 20, 50, 100 };
 
 module_param_array(intr_holdoff, uint, NULL, 0644);
 MODULE_PARM_DESC(intr_holdoff, "values for queue interrupt hold-off timers "
-		 "0..4 in microseconds");
+		 "0..4 in microseconds, deprecated parameter");
 
 static unsigned int intr_cnt[SGE_NCOUNTERS - 1] = { 4, 8, 16 };
 
 module_param_array(intr_cnt, uint, NULL, 0644);
 MODULE_PARM_DESC(intr_cnt,
-		 "thresholds 1..3 for queue interrupt packet counters");
+		 "thresholds 1..3 for queue interrupt packet counters, "
+		 "deprecated parameter");
 
 /*
  * Normally we tell the chip to deliver Ingress Packets into our DMA buffers
@@ -319,7 +228,8 @@ static bool vf_acls;
 
 #ifdef CONFIG_PCI_IOV
 module_param(vf_acls, bool, 0644);
-MODULE_PARM_DESC(vf_acls, "if set enable virtualization L2 ACL enforcement");
+MODULE_PARM_DESC(vf_acls, "if set enable virtualization L2 ACL enforcement, "
+		 "deprecated parameter");
 
 /* Configure the number of PCI-E Virtual Function which are to be instantiated
  * on SR-IOV Capable Physical Functions.
@@ -341,32 +251,11 @@ module_param(select_queue, int, 0644);
 MODULE_PARM_DESC(select_queue,
 		 "Select between kernel provided method of selecting or driver method of selecting TX queue. Default is kernel method.");
 
-/*
- * The filter TCAM has a fixed portion and a variable portion.  The fixed
- * portion can match on source/destination IP IPv4/IPv6 addresses and TCP/UDP
- * ports.  The variable portion is 36 bits which can include things like Exact
- * Match MAC Index (9 bits), Ether Type (16 bits), IP Protocol (8 bits),
- * [Inner] VLAN Tag (17 bits), etc. which, if all were somehow selected, would
- * far exceed the 36-bit budget for this "compressed" header portion of the
- * filter.  Thus, we have a scarce resource which must be carefully managed.
- *
- * By default we set this up to mostly match the set of filter matching
- * capabilities of T3 but with accommodations for some of T4's more
- * interesting features:
- *
- *   { IP Fragment (1), MPS Match Type (3), IP Protocol (8),
- *     [Inner] VLAN (17), Port (3), FCoE (1) }
- */
-enum {
-	TP_VLAN_PRI_MAP_DEFAULT = HW_TPL_FR_MT_PR_IV_P_FC,
-	TP_VLAN_PRI_MAP_FIRST = FCOE_S,
-	TP_VLAN_PRI_MAP_LAST = FRAGMENTATION_S,
-};
-
-static unsigned int tp_vlan_pri_map = TP_VLAN_PRI_MAP_DEFAULT;
+static unsigned int tp_vlan_pri_map = HW_TPL_FR_MT_PR_IV_P_FC;
 
 module_param(tp_vlan_pri_map, uint, 0644);
-MODULE_PARM_DESC(tp_vlan_pri_map, "global compressed filter configuration");
+MODULE_PARM_DESC(tp_vlan_pri_map, "global compressed filter configuration, "
+		 "deprecated parameter");
 
 static struct dentry *cxgb4_debugfs_root;
 
@@ -5225,12 +5114,9 @@ static int adap_init0_config(struct adapter *adapter, int reset)
 	if (ret < 0)
 		goto bye;
 
-	/*
-	 * Return successfully and note that we're operating with parameters
-	 * not supplied by the driver, rather than from hard-wired
-	 * initialization constants burried in the driver.
+	/* Emit Firmware Configuration File information and return
+	 * successfully.
 	 */
-	adapter->flags |= USING_SOFT_PARAMS;
 	dev_info(adapter->pdev_dev, "Successfully configured using Firmware "\
 		 "Configuration File \"%s\", version %#x, computed checksum %#x\n",
 		 config_name, finiver, cfcsum);
@@ -5248,248 +5134,6 @@ bye:
 	return ret;
 }
 
-/*
- * Attempt to initialize the adapter via hard-coded, driver supplied
- * parameters ...
- */
-static int adap_init0_no_config(struct adapter *adapter, int reset)
-{
-	struct sge *s = &adapter->sge;
-	struct fw_caps_config_cmd caps_cmd;
-	u32 v;
-	int i, ret;
-
-	/*
-	 * Reset device if necessary
-	 */
-	if (reset) {
-		ret = t4_fw_reset(adapter, adapter->mbox,
-				  PIORSTMODE_F | PIORST_F);
-		if (ret < 0)
-			goto bye;
-	}
-
-	/*
-	 * Get device capabilities and select which we'll be using.
-	 */
-	memset(&caps_cmd, 0, sizeof(caps_cmd));
-	caps_cmd.op_to_write = htonl(FW_CMD_OP_V(FW_CAPS_CONFIG_CMD) |
-				     FW_CMD_REQUEST_F | FW_CMD_READ_F);
-	caps_cmd.cfvalid_to_len16 = htonl(FW_LEN16(caps_cmd));
-	ret = t4_wr_mbox(adapter, adapter->mbox, &caps_cmd, sizeof(caps_cmd),
-			 &caps_cmd);
-	if (ret < 0)
-		goto bye;
-
-	if (caps_cmd.niccaps & htons(FW_CAPS_CONFIG_NIC_VM)) {
-		if (!vf_acls)
-			caps_cmd.niccaps ^= htons(FW_CAPS_CONFIG_NIC_VM);
-		else
-			caps_cmd.niccaps = htons(FW_CAPS_CONFIG_NIC_VM);
-	} else if (vf_acls) {
-		dev_err(adapter->pdev_dev, "virtualization ACLs not supported");
-		goto bye;
-	}
-	caps_cmd.op_to_write = htonl(FW_CMD_OP_V(FW_CAPS_CONFIG_CMD) |
-			      FW_CMD_REQUEST_F | FW_CMD_WRITE_F);
-	ret = t4_wr_mbox(adapter, adapter->mbox, &caps_cmd, sizeof(caps_cmd),
-			 NULL);
-	if (ret < 0)
-		goto bye;
-
-	/*
-	 * Tweak configuration based on system architecture, module
-	 * parameters, etc.
-	 */
-	ret = adap_init0_tweaks(adapter);
-	if (ret < 0)
-		goto bye;
-
-	/*
-	 * Select RSS Global Mode we want to use.  We use "Basic Virtual"
-	 * mode which maps each Virtual Interface to its own section of
-	 * the RSS Table and we turn on all map and hash enables ...
-	 */
-	adapter->flags |= RSS_TNLALLLOOKUP;
-	ret = t4_config_glbl_rss(adapter, adapter->mbox,
-				 FW_RSS_GLB_CONFIG_CMD_MODE_BASICVIRTUAL,
-				 FW_RSS_GLB_CONFIG_CMD_TNLMAPEN_F |
-				 FW_RSS_GLB_CONFIG_CMD_HASHTOEPLITZ_F |
-				 ((adapter->flags & RSS_TNLALLLOOKUP) ?
-					FW_RSS_GLB_CONFIG_CMD_TNLALLLKP_F : 0));
-	if (ret < 0)
-		goto bye;
-
-	/*
-	 * Set up our own fundamental resource provisioning ...
-	 */
-	ret = t4_cfg_pfvf(adapter, adapter->mbox, adapter->fn, 0,
-			  PFRES_NEQ, PFRES_NETHCTRL,
-			  PFRES_NIQFLINT, PFRES_NIQ,
-			  PFRES_TC, PFRES_NVI,
-			  FW_PFVF_CMD_CMASK_M,
-			  pfvfres_pmask(adapter, adapter->fn, 0),
-			  PFRES_NEXACTF,
-			  PFRES_R_CAPS, PFRES_WX_CAPS);
-	if (ret < 0)
-		goto bye;
-
-	/*
-	 * Perform low level SGE initialization.  We need to do this before we
-	 * send the firmware the INITIALIZE command because that will cause
-	 * any other PF Drivers which are waiting for the Master
-	 * Initialization to proceed forward.
-	 */
-	for (i = 0; i < SGE_NTIMERS - 1; i++)
-		s->timer_val[i] = min(intr_holdoff[i], MAX_SGE_TIMERVAL);
-	s->timer_val[SGE_NTIMERS - 1] = MAX_SGE_TIMERVAL;
-	s->counter_val[0] = 1;
-	for (i = 1; i < SGE_NCOUNTERS; i++)
-		s->counter_val[i] = min(intr_cnt[i - 1], THRESHOLD_0_M);
-	t4_sge_init(adapter);
-
-#ifdef CONFIG_PCI_IOV
-	/*
-	 * Provision resource limits for Virtual Functions.  We currently
-	 * grant them all the same static resource limits except for the Port
-	 * Access Rights Mask which we're assigning based on the PF.  All of
-	 * the static provisioning stuff for both the PF and VF really needs
-	 * to be managed in a persistent manner for each device which the
-	 * firmware controls.
-	 */
-	{
-		int pf, vf;
-
-		for (pf = 0; pf < ARRAY_SIZE(num_vf); pf++) {
-			if (num_vf[pf] <= 0)
-				continue;
-
-			/* VF numbering starts at 1! */
-			for (vf = 1; vf <= num_vf[pf]; vf++) {
-				ret = t4_cfg_pfvf(adapter, adapter->mbox,
-						  pf, vf,
-						  VFRES_NEQ, VFRES_NETHCTRL,
-						  VFRES_NIQFLINT, VFRES_NIQ,
-						  VFRES_TC, VFRES_NVI,
-						  FW_PFVF_CMD_CMASK_M,
-						  pfvfres_pmask(
-						  adapter, pf, vf),
-						  VFRES_NEXACTF,
-						  VFRES_R_CAPS, VFRES_WX_CAPS);
-				if (ret < 0)
-					dev_warn(adapter->pdev_dev,
-						 "failed to "\
-						 "provision pf/vf=%d/%d; "
-						 "err=%d\n", pf, vf, ret);
-			}
-		}
-	}
-#endif
-
-	/*
-	 * Set up the default filter mode.  Later we'll want to implement this
-	 * via a firmware command, etc. ...  This needs to be done before the
-	 * firmare initialization command ...  If the selected set of fields
-	 * isn't equal to the default value, we'll need to make sure that the
-	 * field selections will fit in the 36-bit budget.
-	 */
-	if (tp_vlan_pri_map != TP_VLAN_PRI_MAP_DEFAULT) {
-		int j, bits = 0;
-
-		for (j = TP_VLAN_PRI_MAP_FIRST; j <= TP_VLAN_PRI_MAP_LAST; j++)
-			switch (tp_vlan_pri_map & (1 << j)) {
-			case 0:
-				/* compressed filter field not enabled */
-				break;
-			case FCOE_F:
-				bits +=  1;
-				break;
-			case PORT_F:
-				bits +=  3;
-				break;
-			case VNIC_F:
-				bits += 17;
-				break;
-			case VLAN_F:
-				bits += 17;
-				break;
-			case TOS_F:
-				bits +=  8;
-				break;
-			case PROTOCOL_F:
-				bits +=  8;
-				break;
-			case ETHERTYPE_F:
-				bits += 16;
-				break;
-			case MACMATCH_F:
-				bits +=  9;
-				break;
-			case MPSHITTYPE_F:
-				bits +=  3;
-				break;
-			case FRAGMENTATION_F:
-				bits +=  1;
-				break;
-			}
-
-		if (bits > 36) {
-			dev_err(adapter->pdev_dev,
-				"tp_vlan_pri_map=%#x needs %d bits > 36;"\
-				" using %#x\n", tp_vlan_pri_map, bits,
-				TP_VLAN_PRI_MAP_DEFAULT);
-			tp_vlan_pri_map = TP_VLAN_PRI_MAP_DEFAULT;
-		}
-	}
-	v = tp_vlan_pri_map;
-	t4_write_indirect(adapter, TP_PIO_ADDR_A, TP_PIO_DATA_A,
-			  &v, 1, TP_VLAN_PRI_MAP_A);
-
-	/*
-	 * We need Five Tuple Lookup mode to be set in TP_GLOBAL_CONFIG order
-	 * to support any of the compressed filter fields above.  Newer
-	 * versions of the firmware do this automatically but it doesn't hurt
-	 * to set it here.  Meanwhile, we do _not_ need to set Lookup Every
-	 * Packet in TP_INGRESS_CONFIG to support matching non-TCP packets
-	 * since the firmware automatically turns this on and off when we have
-	 * a non-zero number of filters active (since it does have a
-	 * performance impact).
-	 */
-	if (tp_vlan_pri_map)
-		t4_set_reg_field(adapter, TP_GLOBAL_CONFIG_A,
-				 FIVETUPLELOOKUP_V(FIVETUPLELOOKUP_M),
-				 FIVETUPLELOOKUP_V(FIVETUPLELOOKUP_M));
-
-	/*
-	 * Tweak some settings.
-	 */
-	t4_write_reg(adapter, TP_SHIFT_CNT_A, SYNSHIFTMAX_V(6) |
-		     RXTSHIFTMAXR1_V(4) | RXTSHIFTMAXR2_V(15) |
-		     PERSHIFTBACKOFFMAX_V(8) | PERSHIFTMAX_V(8) |
-		     KEEPALIVEMAXR1_V(4) | KEEPALIVEMAXR2_V(9));
-
-	/*
-	 * Get basic stuff going by issuing the Firmware Initialize command.
-	 * Note that this _must_ be after all PFVF commands ...
-	 */
-	ret = t4_fw_initialize(adapter, adapter->mbox);
-	if (ret < 0)
-		goto bye;
-
-	/*
-	 * Return successfully!
-	 */
-	dev_info(adapter->pdev_dev, "Successfully configured using built-in "\
-		 "driver parameters\n");
-	return 0;
-
-	/*
-	 * Something bad happened.  Return the error ...
-	 */
-bye:
-	return ret;
-}
-
 static struct fw_info fw_info_array[] = {
 	{
 		.chip = CHELSIO_T4,
@@ -5662,88 +5306,58 @@ static int adap_init0(struct adapter *adap)
 	adap->params.nports = hweight32(port_vec);
 	adap->params.portvec = port_vec;
 
-	/*
-	 * If the firmware is initialized already (and we're not forcing a
-	 * master initialization), note that we're living with existing
-	 * adapter parameters.  Otherwise, it's time to try initializing the
-	 * adapter ...
+	/* If the firmware is initialized already, emit a simply note to that
+	 * effect. Otherwise, it's time to try initializing the adapter.
 	 */
 	if (state == DEV_STATE_INIT) {
 		dev_info(adap->pdev_dev, "Coming up as %s: "\
 			 "Adapter already initialized\n",
 			 adap->flags & MASTER_PF ? "MASTER" : "SLAVE");
-		adap->flags |= USING_SOFT_PARAMS;
 	} else {
 		dev_info(adap->pdev_dev, "Coming up as MASTER: "\
 			 "Initializing adapter\n");
-		/*
-		 * If the firmware doesn't support Configuration
-		 * Files warn user and exit,
+
+		/* Find out whether we're dealing with a version of the
+		 * firmware which has configuration file support.
 		 */
-		if (ret < 0)
-			dev_warn(adap->pdev_dev, "Firmware doesn't support "
-				 "configuration file.\n");
-		if (force_old_init)
-			ret = adap_init0_no_config(adap, reset);
-		else {
-			/*
-			 * Find out whether we're dealing with a version of
-			 * the firmware which has configuration file support.
-			 */
-			params[0] = (FW_PARAMS_MNEM_V(FW_PARAMS_MNEM_DEV) |
-				     FW_PARAMS_PARAM_X_V(
-					     FW_PARAMS_PARAM_DEV_CF));
-			ret = t4_query_params(adap, adap->mbox, adap->fn, 0, 1,
-					      params, val);
-
-			/*
-			 * If the firmware doesn't support Configuration
-			 * Files, use the old Driver-based, hard-wired
-			 * initialization.  Otherwise, try using the
-			 * Configuration File support and fall back to the
-			 * Driver-based initialization if there's no
-			 * Configuration File found.
-			 */
-			if (ret < 0)
-				ret = adap_init0_no_config(adap, reset);
-			else {
-				/*
-				 * The firmware provides us with a memory
-				 * buffer where we can load a Configuration
-				 * File from the host if we want to override
-				 * the Configuration File in flash.
-				 */
+		params[0] = (FW_PARAMS_MNEM_V(FW_PARAMS_MNEM_DEV) |
+			     FW_PARAMS_PARAM_X_V(FW_PARAMS_PARAM_DEV_CF));
+		ret = t4_query_params(adap, adap->mbox, adap->fn, 0, 1,
+				      params, val);
 
-				ret = adap_init0_config(adap, reset);
-				if (ret == -ENOENT) {
-					dev_info(adap->pdev_dev,
-					    "No Configuration File present "
-					    "on adapter. Using hard-wired "
-					    "configuration parameters.\n");
-					ret = adap_init0_no_config(adap, reset);
-				}
-			}
+		/* If the firmware doesn't support Configuration Files,
+		 * return an error.
+		 */
+		if (ret < 0) {
+			dev_err(adap->pdev_dev, "firmware doesn't support "
+				"Firmware Configuration Files\n");
+			goto bye;
+		}
+
+		/* The firmware provides us with a memory buffer where we can
+		 * load a Configuration File from the host if we want to
+		 * override the Configuration File in flash.
+		 */
+		ret = adap_init0_config(adap, reset);
+		if (ret == -ENOENT) {
+			dev_err(adap->pdev_dev, "no Configuration File "
+				"present on adapter.\n");
+			goto bye;
 		}
 		if (ret < 0) {
-			dev_err(adap->pdev_dev,
-				"could not initialize adapter, error %d\n",
-				-ret);
+			dev_err(adap->pdev_dev, "could not initialize "
+				"adapter, error %d\n", -ret);
 			goto bye;
 		}
 	}
 
-	/*
-	 * If we're living with non-hard-coded parameters (either from a
-	 * Firmware Configuration File or values programmed by a different PF
-	 * Driver), give the SGE code a chance to pull in anything that it
-	 * needs ...  Note that this must be called after we retrieve our VPD
-	 * parameters in order to know how to convert core ticks to seconds.
+	/* Give the SGE code a chance to pull in anything that it needs ...
+	 * Note that this must be called after we retrieve our VPD parameters
+	 * in order to know how to convert core ticks to seconds, etc.
 	 */
-	if (adap->flags & USING_SOFT_PARAMS) {
-		ret = t4_sge_init(adap);
-		if (ret < 0)
-			goto bye;
-	}
+	ret = t4_sge_init(adap);
+	if (ret < 0)
+		goto bye;
 
 	if (is_bypass_device(adap->pdev->device))
 		adap->params.bypass = 1;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index a79fa6a..ca42e2e 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -2742,24 +2742,11 @@ void t4_sge_stop(struct adapter *adap)
 }
 
 /**
- *	t4_sge_init - initialize SGE
+ *	t4_sge_init_soft - grab core SGE values needed by SGE code
  *	@adap: the adapter
  *
- *	Performs SGE initialization needed every time after a chip reset.
- *	We do not initialize any of the queues here, instead the driver
- *	top-level must request them individually.
- *
- *	Called in two different modes:
- *
- *	 1. Perform actual hardware initialization and record hard-coded
- *	    parameters which were used.  This gets used when we're the
- *	    Master PF and the Firmware Configuration File support didn't
- *	    work for some reason.
- *
- *	 2. We're not the Master PF or initialization was performed with
- *	    a Firmware Configuration File.  In this case we need to grab
- *	    any of the SGE operating parameters that we need to have in
- *	    order to do our job and make sure we can live with them ...
+ *	We need to grab the SGE operating parameters that we need to have
+ *	in order to do our job and make sure we can live with them.
  */
 
 static int t4_sge_init_soft(struct adapter *adap)
@@ -2852,73 +2839,13 @@ static int t4_sge_init_soft(struct adapter *adap)
 	return 0;
 }
 
-static int t4_sge_init_hard(struct adapter *adap)
-{
-	struct sge *s = &adap->sge;
-
-	/*
-	 * Set up our basic SGE mode to deliver CPL messages to our Ingress
-	 * Queue and Packet Date to the Free List.
-	 */
-	t4_set_reg_field(adap, SGE_CONTROL_A, RXPKTCPLMODE_F, RXPKTCPLMODE_F);
-
-	/*
-	 * Set up to drop DOORBELL writes when the DOORBELL FIFO overflows
-	 * and generate an interrupt when this occurs so we can recover.
-	 */
-	if (is_t4(adap->params.chip)) {
-		t4_set_reg_field(adap, SGE_DBFIFO_STATUS_A,
-				 HP_INT_THRESH_V(HP_INT_THRESH_M) |
-				 LP_INT_THRESH_V(LP_INT_THRESH_M),
-				 HP_INT_THRESH_V(dbfifo_int_thresh) |
-				 LP_INT_THRESH_V(dbfifo_int_thresh));
-	} else {
-		t4_set_reg_field(adap, SGE_DBFIFO_STATUS_A,
-				 LP_INT_THRESH_T5_V(LP_INT_THRESH_T5_M),
-				 LP_INT_THRESH_T5_V(dbfifo_int_thresh));
-		t4_set_reg_field(adap, SGE_DBFIFO_STATUS2_A,
-				 HP_INT_THRESH_T5_V(HP_INT_THRESH_T5_M),
-				 HP_INT_THRESH_T5_V(dbfifo_int_thresh));
-	}
-	t4_set_reg_field(adap, SGE_DOORBELL_CONTROL_A, ENABLE_DROP_F,
-			 ENABLE_DROP_F);
-
-	/*
-	 * SGE_FL_BUFFER_SIZE0 (RX_SMALL_PG_BUF) is set up by
-	 * t4_fixup_host_params().
-	 */
-	s->fl_pg_order = FL_PG_ORDER;
-	if (s->fl_pg_order)
-		t4_write_reg(adap,
-			     SGE_FL_BUFFER_SIZE0_A+RX_LARGE_PG_BUF*sizeof(u32),
-			     PAGE_SIZE << FL_PG_ORDER);
-	t4_write_reg(adap, SGE_FL_BUFFER_SIZE0_A+RX_SMALL_MTU_BUF*sizeof(u32),
-		     FL_MTU_SMALL_BUFSIZE(adap));
-	t4_write_reg(adap, SGE_FL_BUFFER_SIZE0_A+RX_LARGE_MTU_BUF*sizeof(u32),
-		     FL_MTU_LARGE_BUFSIZE(adap));
-
-	/*
-	 * Note that the SGE Ingress Packet Count Interrupt Threshold and
-	 * Timer Holdoff values must be supplied by our caller.
-	 */
-	t4_write_reg(adap, SGE_INGRESS_RX_THRESHOLD_A,
-		     THRESHOLD_0_V(s->counter_val[0]) |
-		     THRESHOLD_1_V(s->counter_val[1]) |
-		     THRESHOLD_2_V(s->counter_val[2]) |
-		     THRESHOLD_3_V(s->counter_val[3]));
-	t4_write_reg(adap, SGE_TIMER_VALUE_0_AND_1_A,
-		     TIMERVALUE0_V(us_to_core_ticks(adap, s->timer_val[0])) |
-		     TIMERVALUE1_V(us_to_core_ticks(adap, s->timer_val[1])));
-	t4_write_reg(adap, SGE_TIMER_VALUE_2_AND_3_A,
-		     TIMERVALUE2_V(us_to_core_ticks(adap, s->timer_val[2])) |
-		     TIMERVALUE3_V(us_to_core_ticks(adap, s->timer_val[3])));
-	t4_write_reg(adap, SGE_TIMER_VALUE_4_AND_5_A,
-		     TIMERVALUE4_V(us_to_core_ticks(adap, s->timer_val[4])) |
-		     TIMERVALUE5_V(us_to_core_ticks(adap, s->timer_val[5])));
-
-	return 0;
-}
-
+/**
+ *     t4_sge_init - initialize SGE
+ *     @adap: the adapter
+ *
+ *     Perform low-level SGE code initialization needed every time after a
+ *     chip reset.
+ */
 int t4_sge_init(struct adapter *adap)
 {
 	struct sge *s = &adap->sge;
@@ -2959,10 +2886,7 @@ int t4_sge_init(struct adapter *adap)
 		s->fl_align = max(ingpadboundary, ingpackboundary);
 	}
 
-	if (adap->flags & USING_SOFT_PARAMS)
-		ret = t4_sge_init_soft(adap);
-	else
-		ret = t4_sge_init_hard(adap);
+	ret = t4_sge_init_soft(adap);
 	if (ret < 0)
 		return ret;
 
-- 
1.7.1
