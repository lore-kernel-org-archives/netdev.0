From: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
Subject: Re: [PATCH net v2 0/8] Fixes for server entries and server filter
 entries for Chelsio T4/T5
Date: Wed, 18 Dec 2013 14:16:47 -0800
Message-ID: <20131218141647.0b0cf403@nehalam.linuxnetplumber.net>
References: <1387364906-1967-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org, dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org, leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	santosh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
To: Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1387364906-1967-1-git-send-email-hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

While running namespace checks I found several this:

Subject: cxgb4: make functions static and remove dead code

Cleanup by making local functions static.

The code to load config file is unreachable in net-next, probably came
from some out of tree driver.

Signed-off-by: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>


--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h	2013-12-05 14:47:25.792500047 -0800
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h	2013-12-18 13:53:16.348256655 -0800
@@ -919,7 +919,6 @@ int t4_seeprom_wp(struct adapter *adapte
 int get_vpd_params(struct adapter *adapter, struct vpd_params *p);
 int t4_load_fw(struct adapter *adapter, const u8 *fw_data, unsigned int size);
 unsigned int t4_flash_cfg_addr(struct adapter *adapter);
-int t4_load_cfg(struct adapter *adapter, const u8 *cfg_data, unsigned int size);
 int t4_get_fw_version(struct adapter *adapter, u32 *vers);
 int t4_get_tp_version(struct adapter *adapter, u32 *vers);
 int t4_prep_fw(struct adapter *adap, struct fw_info *fw_info,
@@ -958,13 +957,6 @@ int t4_fw_hello(struct adapter *adap, un
 int t4_fw_bye(struct adapter *adap, unsigned int mbox);
 int t4_early_init(struct adapter *adap, unsigned int mbox);
 int t4_fw_reset(struct adapter *adap, unsigned int mbox, int reset);
-int t4_fw_halt(struct adapter *adap, unsigned int mbox, int force);
-int t4_fw_restart(struct adapter *adap, unsigned int mbox, int reset);
-int t4_fw_upgrade(struct adapter *adap, unsigned int mbox,
-		  const u8 *fw_data, unsigned int size, int force);
-int t4_fw_config_file(struct adapter *adap, unsigned int mbox,
-		      unsigned int mtype, unsigned int maddr,
-		      u32 *finiver, u32 *finicsum, u32 *cfcsum);
 int t4_fixup_host_params(struct adapter *adap, unsigned int page_size,
 			  unsigned int cache_line_size);
 int t4_fw_initialize(struct adapter *adap, unsigned int mbox);
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c	2013-12-05 14:47:25.792500047 -0800
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c	2013-12-18 13:56:19.529815654 -0800
@@ -38,6 +38,8 @@
 #include "t4_regs.h"
 #include "t4fw_api.h"
 
+static int t4_fw_upgrade(struct adapter *adap, unsigned int mbox,
+			 const u8 *fw_data, unsigned int size, int force);
 /**
  *	t4_wait_op_done_val - wait until an operation is completed
  *	@adapter: the adapter performing the operation
@@ -1070,62 +1072,6 @@ unsigned int t4_flash_cfg_addr(struct ad
 }
 
 /**
- *	t4_load_cfg - download config file
- *	@adap: the adapter
- *	@cfg_data: the cfg text file to write
- *	@size: text file size
- *
- *	Write the supplied config text file to the card's serial flash.
- */
-int t4_load_cfg(struct adapter *adap, const u8 *cfg_data, unsigned int size)
-{
-	int ret, i, n;
-	unsigned int addr;
-	unsigned int flash_cfg_start_sec;
-	unsigned int sf_sec_size = adap->params.sf_size / adap->params.sf_nsec;
-
-	addr = t4_flash_cfg_addr(adap);
-	flash_cfg_start_sec = addr / SF_SEC_SIZE;
-
-	if (size > FLASH_CFG_MAX_SIZE) {
-		dev_err(adap->pdev_dev, "cfg file too large, max is %u bytes\n",
-			FLASH_CFG_MAX_SIZE);
-		return -EFBIG;
-	}
-
-	i = DIV_ROUND_UP(FLASH_CFG_MAX_SIZE,	/* # of sectors spanned */
-			 sf_sec_size);
-	ret = t4_flash_erase_sectors(adap, flash_cfg_start_sec,
-				     flash_cfg_start_sec + i - 1);
-	/*
-	 * If size == 0 then we're simply erasing the FLASH sectors associated
-	 * with the on-adapter Firmware Configuration File.
-	 */
-	if (ret || size == 0)
-		goto out;
-
-	/* this will write to the flash up to SF_PAGE_SIZE at a time */
-	for (i = 0; i < size; i += SF_PAGE_SIZE) {
-		if ((size - i) <  SF_PAGE_SIZE)
-			n = size - i;
-		else
-			n = SF_PAGE_SIZE;
-		ret = t4_write_flash(adap, addr, n, cfg_data);
-		if (ret)
-			goto out;
-
-		addr += SF_PAGE_SIZE;
-		cfg_data += SF_PAGE_SIZE;
-	}
-
-out:
-	if (ret)
-		dev_err(adap->pdev_dev, "config file %s failed %d\n",
-			(size == 0 ? "clear" : "download"), ret);
-	return ret;
-}
-
-/**
  *	t4_load_fw - download firmware
  *	@adap: the adapter
  *	@fw_data: the firmware image to write
@@ -2810,7 +2756,7 @@ int t4_fw_reset(struct adapter *adap, un
  *	be doing.  The only way out of this state is to RESTART the firmware
  *	...
  */
-int t4_fw_halt(struct adapter *adap, unsigned int mbox, int force)
+static int t4_fw_halt(struct adapter *adap, unsigned int mbox, int force)
 {
 	int ret = 0;
 
@@ -2875,7 +2821,7 @@ int t4_fw_halt(struct adapter *adap, uns
  *	    the chip since older firmware won't recognize the PCIE_FW.HALT
  *	    flag and automatically RESET itself on startup.
  */
-int t4_fw_restart(struct adapter *adap, unsigned int mbox, int reset)
+static int t4_fw_restart(struct adapter *adap, unsigned int mbox, int reset)
 {
 	if (reset) {
 		/*
@@ -2938,8 +2884,8 @@ int t4_fw_restart(struct adapter *adap,
  *	positive errno indicates that the adapter is ~probably~ intact, a
  *	negative errno indicates that things are looking bad ...
  */
-int t4_fw_upgrade(struct adapter *adap, unsigned int mbox,
-		  const u8 *fw_data, unsigned int size, int force)
+static int t4_fw_upgrade(struct adapter *adap, unsigned int mbox,
+			 const u8 *fw_data, unsigned int size, int force)
 {
 	const struct fw_hdr *fw_hdr = (const struct fw_hdr *)fw_data;
 	int reset, ret;
@@ -2964,78 +2910,6 @@ int t4_fw_upgrade(struct adapter *adap,
 	return t4_fw_restart(adap, mbox, reset);
 }
 
-
-/**
- *	t4_fw_config_file - setup an adapter via a Configuration File
- *	@adap: the adapter
- *	@mbox: mailbox to use for the FW command
- *	@mtype: the memory type where the Configuration File is located
- *	@maddr: the memory address where the Configuration File is located
- *	@finiver: return value for CF [fini] version
- *	@finicsum: return value for CF [fini] checksum
- *	@cfcsum: return value for CF computed checksum
- *
- *	Issue a command to get the firmware to process the Configuration
- *	File located at the specified mtype/maddress.  If the Configuration
- *	File is processed successfully and return value pointers are
- *	provided, the Configuration File "[fini] section version and
- *	checksum values will be returned along with the computed checksum.
- *	It's up to the caller to decide how it wants to respond to the
- *	checksums not matching but it recommended that a prominant warning
- *	be emitted in order to help people rapidly identify changed or
- *	corrupted Configuration Files.
- *
- *	Also note that it's possible to modify things like "niccaps",
- *	"toecaps",etc. between processing the Configuration File and telling
- *	the firmware to use the new configuration.  Callers which want to
- *	do this will need to "hand-roll" their own CAPS_CONFIGS commands for
- *	Configuration Files if they want to do this.
- */
-int t4_fw_config_file(struct adapter *adap, unsigned int mbox,
-		      unsigned int mtype, unsigned int maddr,
-		      u32 *finiver, u32 *finicsum, u32 *cfcsum)
-{
-	struct fw_caps_config_cmd caps_cmd;
-	int ret;
-
-	/*
-	 * Tell the firmware to process the indicated Configuration File.
-	 * If there are no errors and the caller has provided return value
-	 * pointers for the [fini] section version, checksum and computed
-	 * checksum, pass those back to the caller.
-	 */
-	memset(&caps_cmd, 0, sizeof(caps_cmd));
-	caps_cmd.op_to_write =
-		htonl(FW_CMD_OP(FW_CAPS_CONFIG_CMD) |
-		      FW_CMD_REQUEST |
-		      FW_CMD_READ);
-	caps_cmd.cfvalid_to_len16 =
-		htonl(FW_CAPS_CONFIG_CMD_CFVALID |
-		      FW_CAPS_CONFIG_CMD_MEMTYPE_CF(mtype) |
-		      FW_CAPS_CONFIG_CMD_MEMADDR64K_CF(maddr >> 16) |
-		      FW_LEN16(caps_cmd));
-	ret = t4_wr_mbox(adap, mbox, &caps_cmd, sizeof(caps_cmd), &caps_cmd);
-	if (ret < 0)
-		return ret;
-
-	if (finiver)
-		*finiver = ntohl(caps_cmd.finiver);
-	if (finicsum)
-		*finicsum = ntohl(caps_cmd.finicsum);
-	if (cfcsum)
-		*cfcsum = ntohl(caps_cmd.cfcsum);
-
-	/*
-	 * And now tell the firmware to use the configuration we just loaded.
-	 */
-	caps_cmd.op_to_write =
-		htonl(FW_CMD_OP(FW_CAPS_CONFIG_CMD) |
-		      FW_CMD_REQUEST |
-		      FW_CMD_WRITE);
-	caps_cmd.cfvalid_to_len16 = htonl(FW_LEN16(caps_cmd));
-	return t4_wr_mbox(adap, mbox, &caps_cmd, sizeof(caps_cmd), NULL);
-}
-
 /**
  *	t4_fixup_host_params - fix up host-dependent parameters
  *	@adap: the adapter
--- a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h	2013-12-05 14:47:25.796499982 -0800
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h	2013-12-18 13:53:00.328469518 -0800
@@ -268,7 +268,6 @@ int t4vf_wait_dev_ready(struct adapter *
 int t4vf_port_init(struct adapter *, int);
 
 int t4vf_fw_reset(struct adapter *);
-int t4vf_query_params(struct adapter *, unsigned int, const u32 *, u32 *);
 int t4vf_set_params(struct adapter *, unsigned int, const u32 *, const u32 *);
 
 int t4vf_get_sge_params(struct adapter *);
--- a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c	2013-12-05 14:47:25.796499982 -0800
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c	2013-12-18 13:53:08.852356269 -0800
@@ -363,8 +363,8 @@ int t4vf_fw_reset(struct adapter *adapte
  *	Reads the values of firmware or device parameters.  Up to 7 parameters
  *	can be queried at once.
  */
-int t4vf_query_params(struct adapter *adapter, unsigned int nparams,
-		      const u32 *params, u32 *vals)
+static int t4vf_query_params(struct adapter *adapter, unsigned int nparams,
+			     const u32 *params, u32 *vals)
 {
 	int i, ret;
 	struct fw_params_cmd cmd, rpl;


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
