From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Please pull 'libertas-fixes' branch of wireless-2.6
Date: Wed, 27 Jun 2007 16:55:39 -0400
Message-ID: <20070627205539.GB13617@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The following changes since commit 189548642c5962e60c3667bdb3a703fe0bed12a6:
  Linus Torvalds (1):
        Linus 2.6.22-rc6

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git libertas-fixes

Dan Williams (4):
      libertas: style fixes
      libertas: kill wlan_scan_process_results
      libertas: fix WPA associations by handling ENABLE_RSN correctly
      libertas: remove private ioctls

 drivers/net/wireless/libertas/Makefile  |    2 +-
 drivers/net/wireless/libertas/README    |  275 --------
 drivers/net/wireless/libertas/assoc.c   |   28 +-
 drivers/net/wireless/libertas/cmd.c     |   12 +-
 drivers/net/wireless/libertas/cmdresp.c |   21 +
 drivers/net/wireless/libertas/hostcmd.h |    2 +-
 drivers/net/wireless/libertas/ioctl.c   | 1081 -------------------------------
 drivers/net/wireless/libertas/main.c    |    8 +-
 drivers/net/wireless/libertas/scan.c    |   51 +--
 drivers/net/wireless/libertas/wext.c    |  152 -----
 drivers/net/wireless/libertas/wext.h    |   45 +--
 11 files changed, 79 insertions(+), 1598 deletions(-)
 delete mode 100644 drivers/net/wireless/libertas/ioctl.c

diff --git a/drivers/net/wireless/libertas/Makefile b/drivers/net/wireless/libertas/Makefile
index a1097f5..32ed413 100644
--- a/drivers/net/wireless/libertas/Makefile
+++ b/drivers/net/wireless/libertas/Makefile
@@ -2,7 +2,7 @@ libertas-objs := main.o fw.o wext.o \
 		rx.o tx.o cmd.o 	  \
 		cmdresp.o scan.o	  \
 		join.o 11d.o 		  \
-		ioctl.o debugfs.o	  \
+		debugfs.o	  \
 		ethtool.o assoc.o
 
 usb8xxx-objs += if_bootcmd.o
diff --git a/drivers/net/wireless/libertas/README b/drivers/net/wireless/libertas/README
index 1f92f50..0b133ce 100644
--- a/drivers/net/wireless/libertas/README
+++ b/drivers/net/wireless/libertas/README
@@ -28,281 +28,6 @@ DRIVER LOADING
 
 		insmod usb8388.ko [fw_name=usb8388.bin]
 
-=====================
-IWPRIV COMMAND
-=====================
-
-NAME
-	This manual describes the usage of private commands used in Marvell WLAN
-	Linux Driver. All the commands available in Wlanconfig will not be available
-	in the iwpriv.
-
-SYNOPSIS
-	iwpriv <ethX> <command> [sub-command] ...
-
-	iwpriv ethX setregioncode <n>
-	iwpriv ethX getregioncode
-
-Version 5 Command:
-	iwpriv ethX ledgpio <n>
-
-BT Commands:
-	The blinding table (BT) contains a list of mac addresses that will be,
-	by default, ignored by the firmware. It is also possible to invert this
-	behavior so that we will ignore all traffic except for the portion
-	coming from mac addresess in the list. It is primarily used for
-	debugging and testing networks.  It can be edited and inspected with
-	the following commands:
-
-	iwpriv ethX bt_reset
-	iwpriv ethX bt_add <mac_address>
-	iwpriv ethX bt_del <mac_address>
-	iwpriv ethX bt_list <id>
-	iwpriv ethX bt_get_invert <n>
-	iwpriv ethX bt_set_invert <n>
-
-FWT Commands:
-	The forwarding table (FWT) is a feature used to manage mesh network
-	routing in the firmware.  The FWT is essentially a routing table that
-	associates a destination mac address (da) with a next hop receiver
-	address (ra).  The FWT can be inspected and edited with the following
-	iwpriv commands, which are described in greater detail below.
-	Eventually, the table will be automatically maintained by a custom
-	routing protocol.
-
-	NOTE: FWT commands replace the previous DFT commands.  What were the DFT
-	commands?, you might ask.  They were an earlier API to the firmware that
-	implemented a simple MAC-layer forwarding mechanism.  In the unlikely
-	event that you were using these commands, you must migrate to the new
-	FWT commands which can be used to achieve the same functionality.
-
-	iwpriv ethX fwt_add [parameters]
-	iwpriv ethX fwt_del [parameters]
-	iwpriv ethX fwt_lookup [parameters]
-	iwpriv ethX fwt_list [parameters]
-	iwpriv ethX fwt_list_route [parameters]
-	iwpriv ethX fwt_list_neigh [parameters]
-	iwpriv ethX fwt_reset [parameters]
-	iwpriv ethX fwt_cleanup
-	iwpriv ethX fwt_time
-
-MESH Commands:
-
-	The MESH commands are used to configure various features of the mesh
-	routing protocol.  The following commands are supported:
-
-	iwpriv ethX mesh_get_ttl
-	iwpriv ethX mesh_set_ttl ttl
-
-DESCRIPTION
-	Those commands are used to send additional commands to the Marvell WLAN
-	card via the Linux device driver.
-
-	The ethX parameter specifies the network device that is to be used to
-		perform this command on. it could be eth0, eth1 etc.
-
-setregioncode
-	This command is used to set the region code in the station.
-	where value is 'region code' for various regions like
-	USA FCC, Canada IC, Spain, France, Europe ETSI,	Japan ...
-
-	Usage:
-		iwpriv ethX setregioncode 0x10: set region code to USA (0x10).
-
-getregioncode
-	This command is used to get the region code information set in the
-	station.
-
-ledgpio
-	This command is used to set/get LEDs.
-
-	iwpriv ethX ledgpio <LEDs>
-		will set the corresponding LED for the GPIO Line.
-
-	iwpriv ethX ledgpio
-		will give u which LEDs are Enabled.
-
-	Usage:
-		iwpriv eth1 ledgpio 1 0 2 1 3 4
-			will enable
-			LED 1 -> GPIO 0
-			LED 2 -> GPIO 1
-			LED 3 -> GPIO 4
-
-		iwpriv eth1 ledgpio
-			shows LED information in the format as mentioned above.
-
-	Note: LED0 is invalid
-	Note: Maximum Number of LEDs are 16.
-
-fwt_add
-	This command is used to insert an entry into the FWT table. The list of
-	parameters must follow the following structure:
-
-	iwpriv ethX fwt_add da ra [metric dir rate ssn dsn hopcount ttl expiration sleepmode snr]
-
-	The parameters between brackets are optional, but they must appear in
-	the order specified.  For example, if you want to specify the metric,
-	you must also specify the dir, ssn, and dsn but you need not specify the
-	hopcount, expiration, sleepmode, or snr.  Any unspecified parameters
-	will be assigned the defaults specified below.
-
-	The different parameters are:-
-		da		-- DA MAC address in the form 00:11:22:33:44:55
-		ra		-- RA MAC address in the form 00:11:22:33:44:55
-		metric		-- route metric (cost: smaller-metric routes are
-				   preferred, default is 0)
-		dir		-- direction (1 for direct, 0 for reverse,
-				   default is 1)
-		rate		-- data rate used for transmission to the RA,
-				   as specified for the rateadapt command,
-				   default is 3 (11Mbps)
-		ssn		-- Source Sequence Number (time at the RA for
-				   reverse routes.  Default is 0)
-		dsn		-- Destination Sequence Number (time at the DA
-				   for direct routes.  Default is 0)
-		hopcount	-- hop count (currently unused, default is 0)
-		ttl		-- TTL (Only used in reverse entries)
-		expiration	-- entry expiration (in ticks, where a tick is
-				   1024us, or ~ 1ms. Use 0 for an indefinite
-				   entry, default is 0)
-		sleepmode	-- RA's sleep mode (currently unused, default is
-				   0)
-		snr		-- SNR in the link to RA (currently unused,
-				   default is 0)
-
-	The command does not return anything.
-
-fwt_del
-	This command is used to remove an entry to the FWT table. The list of
-	parameters must follow the following structure:
-
-		iwpriv ethX fwt_del da ra [dir]
-
-	where the different parameters are:-
-		da		-- DA MAC address (in the form "00:11:22:33:44:55")
-		ra		-- RA MAC address (in the form "00:11:22:33:44:55")
-		dir		-- direction (1 for direct, 0 for reverse,
-				   default is 1)
-
-	The command does not return anything.
-
-fwt_lookup
-	This command is used to get the best route in the FWT table to a given
-	host. The only parameter is the MAC address of the host that is being
-	looked for.
-
-		iwpriv ethX fwt_lookup da
-
-	where:-
-		da		-- DA MAC address (in the form "00:11:22:33:44:55")
-
-	The command returns an output string identical to the one returned by
-	fwt_list described below.
-
-
-fwt_list
-	This command is used to list a route from the FWT table. The only
-	parameter is the index into the table. If you want to list all the
-	routes in a table, start with index=0, and keep listing until you get a
-	"(null)" string.  Note that the indicies may change as the fwt is
-	updated.  It is expected that most users will not use fwt_list directly,
-	but that a utility similar to the traditional route command will be used
-	to invoke fwt_list over and over.
-
-		iwpriv ethX fwt_list index
-
-	The output is a string of the following form:
-
-		da ra valid metric dir rate ssn dsn hopcount ttl expiration
-		sleepmode snr precursor
-
-	where the different fields are:-
-		da		-- DA MAC address (in the form "00:11:22:33:44:55")
-		ra		-- RA MAC address (in the form "00:11:22:33:44:55")
-		valid		-- whether the route is valid (0 if not valid)
-		metric		-- route metric (cost: smaller-metric routes are preferred)
-		dir		-- direction (1 for direct, 0 for reverse)
-		rate		-- data rate used for transmission to the RA,
-				   as specified for the rateadapt command
-		ssn		-- Source Sequence Number (time at the RA for reverse routes)
-		dsn		-- Destination Sequence Number (time at the DA for direct routes)
-		hopcount	-- hop count (currently unused)
-		ttl		-- TTL (only used in reverse entries)
-		expiration	-- entry expiration (in ticks, where a tick is 1024us, or ~ 1ms. Use 0 for an indefinite entry)
-		sleepmode	-- RA's sleep mode (currently unused)
-		snr		-- SNR in the link to RA (currently unused)
-		precursor	-- predecessor in direct routes
-
-fwt_list_route
-	This command is equivalent to fwt_list.
-
-fwt_list_neigh
-	This command is used to list a neighbor from the FWT table. The only
-	parameter is the neighbor ID. If you want to list all the neighbors in a
-	table, start with nid=0, and keep incrementing nid until you get a
-	"(null)" string.  Note that the nid from a fwt_list_route command can be
-	used as an input to this command.  Also note that this command is meant
-	mostly for debugging.  It is expected that users will use fwt_lookup.
-	One important reason for this is that the neighbor id may change as the
-	neighbor table is altered.
-
-		iwpriv ethX fwt_list_neigh nid
-
-	The output is a string of the following form:
-
-		ra sleepmode snr references
-
-	where the different fields are:-
-		ra		-- RA MAC address (in the form "00:11:22:33:44:55")
-		sleepmode	-- RA's sleep mode (currently unused)
-		snr		-- SNR in the link to RA (currently unused)
-		references	-- RA's reference counter
-
-fwt_reset
-	This command is used to reset the FWT table, getting rid of all the
-	entries. There are no input parameters.
-
-		iwpriv ethX fwt_reset
-
-	The command does not return anything.
-
-fwt_cleanup
-	This command is used to perform user-based garbage recollection. The
-	FWT table is checked, and all the entries that are expired or invalid
-	are cleaned. Note that this is exported to the driver for debugging
-	purposes, as garbage collection is also fired by the firmware when in
-	space problems. There are no input parameters.
-
-		iwpriv ethX fwt_cleanup
-
-	The command does returns the number of invalid/expired routes deleted.
-
-fwt_time
-	This command returns a card's internal time representation.  It is this
-	time that is used to represent the expiration times of FWT entries.  The
-	number is not consistent from card to card; it is simply a timer count.
-	The fwt_time command is used to inspect the timer so that expiration
-	times reported by fwt_list can be properly interpreted.
-
-		iwpriv ethX fwt_time
-
-mesh_get_ttl
-
-	The mesh ttl is the number of hops a mesh packet can traverse before it
-	is dropped.  This parameter is used to prevent infinite loops in the
-	mesh network.  The value returned by this function is the ttl assigned
-	to all mesh packets.  Currently there is no way to control the ttl on a
-	per packet or per socket basis.
-
-	iwpriv ethX mesh_get_ttl
-
-mesh_set_ttl ttl
-
-	Set the ttl.  The argument must be between 0 and 255.
-
-	iwpriv ethX mesh_set_ttl <ttl>
-
 =========================
 ETHTOOL
 =========================
diff --git a/drivers/net/wireless/libertas/assoc.c b/drivers/net/wireless/libertas/assoc.c
index f67efa0..afd5617 100644
--- a/drivers/net/wireless/libertas/assoc.c
+++ b/drivers/net/wireless/libertas/assoc.c
@@ -323,6 +323,8 @@ static int assoc_helper_secinfo(wlan_private *priv,
 {
 	wlan_adapter *adapter = priv->adapter;
 	int ret = 0;
+	u32 do_wpa;
+	u32 rsn = 0;
 
 	lbs_deb_enter(LBS_DEB_ASSOC);
 
@@ -333,12 +335,34 @@ static int assoc_helper_secinfo(wlan_private *priv,
 	if (ret)
 		goto out;
 
-	/* enable/disable RSN */
+	/* If RSN is already enabled, don't try to enable it again, since
+	 * ENABLE_RSN resets internal state machines and will clobber the
+	 * 4-way WPA handshake.
+	 */
+
+	/* Get RSN enabled/disabled */
 	ret = libertas_prepare_and_send_command(priv,
 				    cmd_802_11_enable_rsn,
 				    cmd_act_set,
 				    cmd_option_waitforrsp,
-				    0, assoc_req);
+				    0, &rsn);
+	if (ret) {
+		lbs_deb_assoc("Failed to get RSN status: %d", ret);
+		goto out;
+	}
+
+	/* Don't re-enable RSN if it's already enabled */
+	do_wpa = (assoc_req->secinfo.WPAenabled || assoc_req->secinfo.WPA2enabled);
+	if (do_wpa == rsn)
+		goto out;
+
+	/* Set RSN enabled/disabled */
+	rsn = do_wpa;
+	ret = libertas_prepare_and_send_command(priv,
+				    cmd_802_11_enable_rsn,
+				    cmd_act_set,
+				    cmd_option_waitforrsp,
+				    0, &rsn);
 
 out:
 	lbs_deb_leave_args(LBS_DEB_ASSOC, "ret %d", ret);
diff --git a/drivers/net/wireless/libertas/cmd.c b/drivers/net/wireless/libertas/cmd.c
index 124e029..13f6528 100644
--- a/drivers/net/wireless/libertas/cmd.c
+++ b/drivers/net/wireless/libertas/cmd.c
@@ -228,17 +228,19 @@ static int wlan_cmd_802_11_enable_rsn(wlan_private * priv,
 				      void * pdata_buf)
 {
 	struct cmd_ds_802_11_enable_rsn *penableRSN = &cmd->params.enbrsn;
-	struct assoc_request * assoc_req = pdata_buf;
+	u32 * enable = pdata_buf;
 
 	lbs_deb_enter(LBS_DEB_CMD);
 
 	cmd->command = cpu_to_le16(cmd_802_11_enable_rsn);
 	cmd->size = cpu_to_le16(sizeof(*penableRSN) + S_DS_GEN);
 	penableRSN->action = cpu_to_le16(cmd_action);
-	if (assoc_req->secinfo.WPAenabled || assoc_req->secinfo.WPA2enabled) {
-		penableRSN->enable = cpu_to_le16(cmd_enable_rsn);
-	} else {
-		penableRSN->enable = cpu_to_le16(cmd_disable_rsn);
+
+	if (cmd_action == cmd_act_set) {
+		if (*enable)
+			penableRSN->enable = cpu_to_le16(cmd_enable_rsn);
+		else
+			penableRSN->enable = cpu_to_le16(cmd_enable_rsn);
 	}
 
 	lbs_deb_leave(LBS_DEB_CMD);
diff --git a/drivers/net/wireless/libertas/cmdresp.c b/drivers/net/wireless/libertas/cmdresp.c
index 0c3b9a5..6ac0d47 100644
--- a/drivers/net/wireless/libertas/cmdresp.c
+++ b/drivers/net/wireless/libertas/cmdresp.c
@@ -537,6 +537,24 @@ static int wlan_ret_get_log(wlan_private * priv,
 	return 0;
 }
 
+static int libertas_ret_802_11_enable_rsn(wlan_private * priv,
+                                          struct cmd_ds_command *resp)
+{
+	struct cmd_ds_802_11_enable_rsn *enable_rsn = &resp->params.enbrsn;
+	wlan_adapter *adapter = priv->adapter;
+	u32 * pdata_buf = adapter->cur_cmd->pdata_buf;
+
+	lbs_deb_enter(LBS_DEB_CMD);
+
+	if (enable_rsn->action == cpu_to_le16(cmd_act_get)) {
+		if (pdata_buf)
+			*pdata_buf = (u32) le16_to_cpu(enable_rsn->enable);
+	}
+
+	lbs_deb_enter(LBS_DEB_CMD);
+	return 0;
+}
+
 static inline int handle_cmd_response(u16 respcmd,
 				      struct cmd_ds_command *resp,
 				      wlan_private *priv)
@@ -610,7 +628,10 @@ static inline int handle_cmd_response(u16 respcmd,
 	case cmd_ret_802_11_authenticate:
 	case cmd_ret_802_11_radio_control:
 	case cmd_ret_802_11_beacon_stop:
+		break;
+
 	case cmd_ret_802_11_enable_rsn:
+		ret = libertas_ret_802_11_enable_rsn(priv, resp);
 		break;
 
 	case cmd_ret_802_11_data_rate:
diff --git a/drivers/net/wireless/libertas/hostcmd.h b/drivers/net/wireless/libertas/hostcmd.h
index 3acf939..09b898f 100644
--- a/drivers/net/wireless/libertas/hostcmd.h
+++ b/drivers/net/wireless/libertas/hostcmd.h
@@ -503,7 +503,7 @@ struct cmd_ds_802_11_ad_hoc_join {
 struct cmd_ds_802_11_enable_rsn {
 	__le16 action;
 	__le16 enable;
-};
+} __attribute__ ((packed));
 
 struct MrvlIEtype_keyParamSet {
 	/* type ID */
diff --git a/drivers/net/wireless/libertas/ioctl.c b/drivers/net/wireless/libertas/ioctl.c
deleted file mode 100644
index f410815..0000000
--- a/drivers/net/wireless/libertas/ioctl.c
+++ /dev/null
@@ -1,1081 +0,0 @@
-/**
-  * This file contains ioctl functions
-  */
-
-#include <linux/ctype.h>
-#include <linux/delay.h>
-#include <linux/if.h>
-#include <linux/if_arp.h>
-#include <linux/wireless.h>
-
-#include <net/iw_handler.h>
-#include <net/ieee80211.h>
-
-#include "host.h"
-#include "radiotap.h"
-#include "decl.h"
-#include "defs.h"
-#include "dev.h"
-#include "join.h"
-#include "wext.h"
-
-#define MAX_SCAN_CELL_SIZE      (IW_EV_ADDR_LEN + \
-				IW_ESSID_MAX_SIZE + \
-				IW_EV_UINT_LEN + IW_EV_FREQ_LEN + \
-				IW_EV_QUAL_LEN + IW_ESSID_MAX_SIZE + \
-				IW_EV_PARAM_LEN + 40)	/* 40 for WPAIE */
-
-#define WAIT_FOR_SCAN_RRESULT_MAX_TIME (10 * HZ)
-
-static int wlan_set_region(wlan_private * priv, u16 region_code)
-{
-	int i;
-	int ret = 0;
-
-	for (i = 0; i < MRVDRV_MAX_REGION_CODE; i++) {
-		// use the region code to search for the index
-		if (region_code == libertas_region_code_to_index[i]) {
-			priv->adapter->regiontableindex = (u16) i;
-			priv->adapter->regioncode = region_code;
-			break;
-		}
-	}
-
-	// if it's unidentified region code
-	if (i >= MRVDRV_MAX_REGION_CODE) {
-		lbs_deb_ioctl("region Code not identified\n");
-		ret = -1;
-		goto done;
-	}
-
-	if (libertas_set_regiontable(priv, priv->adapter->regioncode, 0)) {
-		ret = -EINVAL;
-	}
-
-done:
-	lbs_deb_leave_args(LBS_DEB_IOCTL, "ret %d", ret);
-	return ret;
-}
-
-static inline int hex2int(char c)
-{
-	if (c >= '0' && c <= '9')
-		return (c - '0');
-	if (c >= 'a' && c <= 'f')
-		return (c - 'a' + 10);
-	if (c >= 'A' && c <= 'F')
-		return (c - 'A' + 10);
-	return -1;
-}
-
-/* Convert a string representation of a MAC address ("xx:xx:xx:xx:xx:xx")
-   into binary format (6 bytes).
-
-   This function expects that each byte is represented with 2 characters
-   (e.g., 11:2:11:11:11:11 is invalid)
-
- */
-static char *eth_str2addr(char *ethstr, u8 * addr)
-{
-	int i, val, val2;
-	char *pos = ethstr;
-
-	/* get rid of initial blanks */
-	while (*pos == ' ' || *pos == '\t')
-		++pos;
-
-	for (i = 0; i < 6; i++) {
-		val = hex2int(*pos++);
-		if (val < 0)
-			return NULL;
-		val2 = hex2int(*pos++);
-		if (val2 < 0)
-			return NULL;
-		addr[i] = (val * 16 + val2) & 0xff;
-
-		if (i < 5 && *pos++ != ':')
-			return NULL;
-	}
-	return pos;
-}
-
-/* this writes xx:xx:xx:xx:xx:xx into ethstr
-   (ethstr must have space for 18 chars) */
-static int eth_addr2str(u8 * addr, char *ethstr)
-{
-	int i;
-	char *pos = ethstr;
-
-	for (i = 0; i < 6; i++) {
-		sprintf(pos, "%02x", addr[i] & 0xff);
-		pos += 2;
-		if (i < 5)
-			*pos++ = ':';
-	}
-	return 17;
-}
-
-/**
- *  @brief          Add an entry to the BT table
- *  @param priv     A pointer to wlan_private structure
- *  @param req      A pointer to ifreq structure
- *  @return         0 --success, otherwise fail
- */
-static int wlan_bt_add_ioctl(wlan_private * priv, struct ifreq *req)
-{
-	struct iwreq *wrq = (struct iwreq *)req;
-	char ethaddrs_str[18];
-	char *pos;
-	u8 ethaddr[ETH_ALEN];
-	int ret;
-
-	lbs_deb_enter(LBS_DEB_IOCTL);
-
-	if (copy_from_user(ethaddrs_str, wrq->u.data.pointer,
-			   sizeof(ethaddrs_str)))
-		return -EFAULT;
-
-	if ((pos = eth_str2addr(ethaddrs_str, ethaddr)) == NULL) {
-		lbs_pr_info("BT_ADD: Invalid MAC address\n");
-		return -EINVAL;
-	}
-
-	lbs_deb_ioctl("BT: adding %s\n", ethaddrs_str);
-	ret = libertas_prepare_and_send_command(priv, cmd_bt_access,
-				      cmd_act_bt_access_add,
-				      cmd_option_waitforrsp, 0, ethaddr);
-	lbs_deb_leave_args(LBS_DEB_IOCTL, "ret %d", ret);
-	return ret;
-}
-
-/**
- *  @brief          Delete an entry from the BT table
- *  @param priv     A pointer to wlan_private structure
- *  @param req      A pointer to ifreq structure
- *  @return         0 --success, otherwise fail
- */
-static int wlan_bt_del_ioctl(wlan_private * priv, struct ifreq *req)
-{
-	struct iwreq *wrq = (struct iwreq *)req;
-	char ethaddrs_str[18];
-	u8 ethaddr[ETH_ALEN];
-	char *pos;
-
-	lbs_deb_enter(LBS_DEB_IOCTL);
-
-	if (copy_from_user(ethaddrs_str, wrq->u.data.pointer,
-			   sizeof(ethaddrs_str)))
-		return -EFAULT;
-
-	if ((pos = eth_str2addr(ethaddrs_str, ethaddr)) == NULL) {
-		lbs_pr_info("Invalid MAC address\n");
-		return -EINVAL;
-	}
-
-	lbs_deb_ioctl("BT: deleting %s\n", ethaddrs_str);
-
-	return (libertas_prepare_and_send_command(priv,
-				      cmd_bt_access,
-				      cmd_act_bt_access_del,
-				      cmd_option_waitforrsp, 0, ethaddr));
-
-	lbs_deb_leave(LBS_DEB_IOCTL);
-	return 0;
-}
-
-/**
- *  @brief          Reset all entries from the BT table
- *  @param priv     A pointer to wlan_private structure
- *  @return         0 --success, otherwise fail
- */
-static int wlan_bt_reset_ioctl(wlan_private * priv)
-{
-	lbs_deb_enter(LBS_DEB_IOCTL);
-
-	lbs_pr_alert( "BT: resetting\n");
-
-	return (libertas_prepare_and_send_command(priv,
-				      cmd_bt_access,
-				      cmd_act_bt_access_reset,
-				      cmd_option_waitforrsp, 0, NULL));
-
-	lbs_deb_leave(LBS_DEB_IOCTL);
-	return 0;
-}
-
-/**
- *  @brief          List an entry from the BT table
- *  @param priv     A pointer to wlan_private structure
- *  @param req      A pointer to ifreq structure
- *  @return         0 --success, otherwise fail
- */
-static int wlan_bt_list_ioctl(wlan_private * priv, struct ifreq *req)
-{
-	int pos;
-	char *addr1;
-	struct iwreq *wrq = (struct iwreq *)req;
-	/* used to pass id and store the bt entry returned by the FW */
-	union {
-		u32 id;
-		char addr1addr2[2 * ETH_ALEN];
-	} param;
-	static char outstr[64];
-	char *pbuf = outstr;
-	int ret;
-
-	lbs_deb_enter(LBS_DEB_IOCTL);
-
-	if (copy_from_user(outstr, wrq->u.data.pointer, sizeof(outstr))) {
-		lbs_deb_ioctl("Copy from user failed\n");
-		return -1;
-	}
-	param.id = simple_strtoul(outstr, NULL, 10);
-	pos = sprintf(pbuf, "%d: ", param.id);
-	pbuf += pos;
-
-	ret = libertas_prepare_and_send_command(priv, cmd_bt_access,
-				    cmd_act_bt_access_list,
-				    cmd_option_waitforrsp, 0,
-				    (char *)&param);
-
-	if (ret == 0) {
-		addr1 = param.addr1addr2;
-
-		pos = sprintf(pbuf, "BT includes node ");
-		pbuf += pos;
-		pos = eth_addr2str(addr1, pbuf);
-		pbuf += pos;
-	} else {
-		sprintf(pbuf, "(null)");
-		pbuf += pos;
-	}
-
-	wrq->u.data.length = strlen(outstr);
-	if (copy_to_user(wrq->u.data.pointer, (char *)outstr,
-			 wrq->u.data.length)) {
-		lbs_deb_ioctl("BT_LIST: Copy to user failed!\n");
-		return -EFAULT;
-	}
-
-	lbs_deb_leave(LBS_DEB_IOCTL);
-	return 0 ;
-}
-
-/**
- *  @brief          Sets inverted state of blacklist (non-zero if inverted)
- *  @param priv     A pointer to wlan_private structure
- *  @param req      A pointer to ifreq structure
- *  @return         0 --success, otherwise fail
- */
-static int wlan_bt_set_invert_ioctl(wlan_private * priv, struct ifreq *req)
-{
-	int ret;
-	struct iwreq *wrq = (struct iwreq *)req;
-	union {
-		u32 id;
-		char addr1addr2[2 * ETH_ALEN];
-	} param;
-
-	lbs_deb_enter(LBS_DEB_IOCTL);
-
-	param.id = SUBCMD_DATA(wrq) ;
-	ret = libertas_prepare_and_send_command(priv, cmd_bt_access,
-				    cmd_act_bt_access_set_invert,
-				    cmd_option_waitforrsp, 0,
-				    (char *)&param);
-	if (ret != 0)
-		return -EFAULT;
-	lbs_deb_leave(LBS_DEB_IOCTL);
-	return 0;
-}
-
-/**
- *  @brief          Gets inverted state of blacklist (non-zero if inverted)
- *  @param priv     A pointer to wlan_private structure
- *  @param req      A pointer to ifreq structure
- *  @return         0 --success, otherwise fail
- */
-static int wlan_bt_get_invert_ioctl(wlan_private * priv, struct ifreq *req)
-{
-	struct iwreq *wrq = (struct iwreq *)req;
-	int ret;
-	union {
-		u32 id;
-		char addr1addr2[2 * ETH_ALEN];
-	} param;
-
-	lbs_deb_enter(LBS_DEB_IOCTL);
-
-	ret = libertas_prepare_and_send_command(priv, cmd_bt_access,
-				    cmd_act_bt_access_get_invert,
-				    cmd_option_waitforrsp, 0,
-				    (char *)&param);
-
-	if (ret == 0)
-		wrq->u.param.value = le32_to_cpu(param.id);
-	else
-		return -EFAULT;
-
-	lbs_deb_leave(LBS_DEB_IOCTL);
-	return 0;
-}
-
-/**
- *  @brief          Find the next parameter in an input string
- *  @param ptr      A pointer to the input parameter string
- *  @return         A pointer to the next parameter, or 0 if no parameters left.
- */
-static char * next_param(char * ptr)
-{
-	if (!ptr) return NULL;
-	while (*ptr == ' ' || *ptr == '\t') ++ptr;
-	return (*ptr == '\0') ? NULL : ptr;
-}
-
-/**
- *  @brief          Add an entry to the FWT table
- *  @param priv     A pointer to wlan_private structure
- *  @param req      A pointer to ifreq structure
- *  @return         0 --success, otherwise fail
- */
-static int wlan_fwt_add_ioctl(wlan_private * priv, struct ifreq *req)
-{
-	struct iwreq *wrq = (struct iwreq *)req;
-	char in_str[128];
-	static struct cmd_ds_fwt_access fwt_access;
-	char *ptr;
-	int ret;
-
-	lbs_deb_enter(LBS_DEB_IOCTL);
-
-	if (copy_from_user(in_str, wrq->u.data.pointer, sizeof(in_str)))
-		return -EFAULT;
-
-	if ((ptr = eth_str2addr(in_str, fwt_access.da)) == NULL) {
-		lbs_pr_alert( "FWT_ADD: Invalid MAC address 1\n");
-		return -EINVAL;
-	}
-
-	if ((ptr = eth_str2addr(ptr, fwt_access.ra)) == NULL) {
-		lbs_pr_alert( "FWT_ADD: Invalid MAC address 2\n");
-		return -EINVAL;
-	}
-
-	if ((ptr = next_param(ptr)))
-		fwt_access.metric =
-			cpu_to_le32(simple_strtoul(ptr, &ptr, 10));
-	else
-		fwt_access.metric = cpu_to_le32(FWT_DEFAULT_METRIC);
-
-	if ((ptr = next_param(ptr)))
-		fwt_access.dir = (u8)simple_strtoul(ptr, &ptr, 10);
-	else
-		fwt_access.dir = FWT_DEFAULT_DIR;
-
-	if ((ptr = next_param(ptr)))
-		fwt_access.rate = (u8) simple_strtoul(ptr, &ptr, 10);
-	else
-		fwt_access.rate = FWT_DEFAULT_RATE;
-
-	if ((ptr = next_param(ptr)))
-		fwt_access.ssn =
-			cpu_to_le32(simple_strtoul(ptr, &ptr, 10));
-	else
-		fwt_access.ssn = cpu_to_le32(FWT_DEFAULT_SSN);
-
-	if ((ptr = next_param(ptr)))
-		fwt_access.dsn =
-			cpu_to_le32(simple_strtoul(ptr, &ptr, 10));
-	else
-		fwt_access.dsn = cpu_to_le32(FWT_DEFAULT_DSN);
-
-	if ((ptr = next_param(ptr)))
-		fwt_access.hopcount = simple_strtoul(ptr, &ptr, 10);
-	else
-		fwt_access.hopcount = FWT_DEFAULT_HOPCOUNT;
-
-	if ((ptr = next_param(ptr)))
-		fwt_access.ttl = simple_strtoul(ptr, &ptr, 10);
-	else
-		fwt_access.ttl = FWT_DEFAULT_TTL;
-
-	if ((ptr = next_param(ptr)))
-		fwt_access.expiration =
-			cpu_to_le32(simple_strtoul(ptr, &ptr, 10));
-	else
-		fwt_access.expiration = cpu_to_le32(FWT_DEFAULT_EXPIRATION);
-
-	if ((ptr = next_param(ptr)))
-		fwt_access.sleepmode = (u8)simple_strtoul(ptr, &ptr, 10);
-	else
-		fwt_access.sleepmode = FWT_DEFAULT_SLEEPMODE;
-
-	if ((ptr = next_param(ptr)))
-		fwt_access.snr =
-			cpu_to_le32(simple_strtoul(ptr, &ptr, 10));
-	else
-		fwt_access.snr = cpu_to_le32(FWT_DEFAULT_SNR);
-
-#ifdef DEBUG
-	{
-		char ethaddr1_str[18], ethaddr2_str[18];
-		eth_addr2str(fwt_access.da, ethaddr1_str);
-		eth_addr2str(fwt_access.ra, ethaddr2_str);
-		lbs_deb_ioctl("FWT_ADD: adding (da:%s,%i,ra:%s)\n", ethaddr1_str,
-		       fwt_access.dir, ethaddr2_str);
-		lbs_deb_ioctl("FWT_ADD: ssn:%u dsn:%u met:%u hop:%u ttl:%u exp:%u slp:%u snr:%u\n",
-		       fwt_access.ssn, fwt_access.dsn, fwt_access.metric,
-		       fwt_access.hopcount, fwt_access.ttl, fwt_access.expiration,
-		       fwt_access.sleepmode, fwt_access.snr);
-	}
-#endif
-
-	ret = libertas_prepare_and_send_command(priv, cmd_fwt_access,
-						cmd_act_fwt_access_add,
-						cmd_option_waitforrsp, 0,
-						(void *)&fwt_access);
-
-	lbs_deb_leave_args(LBS_DEB_IOCTL, "ret %d", ret);
-	return ret;
-}
-
-/**
- *  @brief          Delete an entry from the FWT table
- *  @param priv     A pointer to wlan_private structure
- *  @param req      A pointer to ifreq structure
- *  @return         0 --success, otherwise fail
- */
-static int wlan_fwt_del_ioctl(wlan_private * priv, struct ifreq *req)
-{
-	struct iwreq *wrq = (struct iwreq *)req;
-	char in_str[64];
-	static struct cmd_ds_fwt_access fwt_access;
-	char *ptr;
-	int ret;
-
-	lbs_deb_enter(LBS_DEB_IOCTL);
-
-	if (copy_from_user(in_str, wrq->u.data.pointer, sizeof(in_str)))
-		return -EFAULT;
-
-	if ((ptr = eth_str2addr(in_str, fwt_access.da)) == NULL) {
-		lbs_pr_alert( "FWT_DEL: Invalid MAC address 1\n");
-		return -EINVAL;
-	}
-
-	if ((ptr = eth_str2addr(ptr, fwt_access.ra)) == NULL) {
-		lbs_pr_alert( "FWT_DEL: Invalid MAC address 2\n");
-		return -EINVAL;
-	}
-
-	if ((ptr = next_param(ptr)))
-		fwt_access.dir = (u8)simple_strtoul(ptr, &ptr, 10);
-	else
-		fwt_access.dir = FWT_DEFAULT_DIR;
-
-#ifdef DEBUG
-	{
-		char ethaddr1_str[18], ethaddr2_str[18];
-		lbs_deb_ioctl("FWT_DEL: line is %s\n", in_str);
-		eth_addr2str(fwt_access.da, ethaddr1_str);
-		eth_addr2str(fwt_access.ra, ethaddr2_str);
-		lbs_deb_ioctl("FWT_DEL: removing (da:%s,ra:%s,dir:%d)\n", ethaddr1_str,
-		       ethaddr2_str, fwt_access.dir);
-	}
-#endif
-
-	ret = libertas_prepare_and_send_command(priv,
-						cmd_fwt_access,
-						cmd_act_fwt_access_del,
-						cmd_option_waitforrsp, 0,
-						(void *)&fwt_access);
-	lbs_deb_leave_args(LBS_DEB_IOCTL, "ret %d", ret);
-	return ret;
-}
-
-
-/**
- *  @brief             Print route parameters
- *  @param fwt_access  struct cmd_ds_fwt_access with route info
- *  @param buf         destination buffer for route info
- */
-static void print_route(struct cmd_ds_fwt_access fwt_access, char *buf)
-{
-	buf += sprintf(buf, " ");
-	buf += eth_addr2str(fwt_access.da, buf);
-	buf += sprintf(buf, " ");
-	buf += eth_addr2str(fwt_access.ra, buf);
-	buf += sprintf(buf, " %u", fwt_access.valid);
-	buf += sprintf(buf, " %u", le32_to_cpu(fwt_access.metric));
-	buf += sprintf(buf, " %u", fwt_access.dir);
-	buf += sprintf(buf, " %u", fwt_access.rate);
-	buf += sprintf(buf, " %u", le32_to_cpu(fwt_access.ssn));
-	buf += sprintf(buf, " %u", le32_to_cpu(fwt_access.dsn));
-	buf += sprintf(buf, " %u", fwt_access.hopcount);
-	buf += sprintf(buf, " %u", fwt_access.ttl);
-	buf += sprintf(buf, " %u", le32_to_cpu(fwt_access.expiration));
-	buf += sprintf(buf, " %u", fwt_access.sleepmode);
-	buf += sprintf(buf, " %u ", le32_to_cpu(fwt_access.snr));
-	buf += eth_addr2str(fwt_access.prec, buf);
-}
-
-/**
- *  @brief          Lookup an entry in the FWT table
- *  @param priv     A pointer to wlan_private structure
- *  @param req      A pointer to ifreq structure
- *  @return         0 --success, otherwise fail
- */
-static int wlan_fwt_lookup_ioctl(wlan_private * priv, struct ifreq *req)
-{
-	struct iwreq *wrq = (struct iwreq *)req;
-	char in_str[64];
-	char *ptr;
-	static struct cmd_ds_fwt_access fwt_access;
-	static char out_str[128];
-	int ret;
-
-	lbs_deb_enter(LBS_DEB_IOCTL);
-
-	if (copy_from_user(in_str, wrq->u.data.pointer, sizeof(in_str)))
-		return -EFAULT;
-
-	if ((ptr = eth_str2addr(in_str, fwt_access.da)) == NULL) {
-		lbs_pr_alert( "FWT_LOOKUP: Invalid MAC address\n");
-		return -EINVAL;
-	}
-
-#ifdef DEBUG
-	{
-		char ethaddr1_str[18];
-		lbs_deb_ioctl("FWT_LOOKUP: line is %s\n", in_str);
-		eth_addr2str(fwt_access.da, ethaddr1_str);
-		lbs_deb_ioctl("FWT_LOOKUP: looking for (da:%s)\n", ethaddr1_str);
-	}
-#endif
-
-	ret = libertas_prepare_and_send_command(priv,
-						cmd_fwt_access,
-						cmd_act_fwt_access_lookup,
-						cmd_option_waitforrsp, 0,
-						(void *)&fwt_access);
-
-	if (ret == 0)
-		print_route(fwt_access, out_str);
-	else
-		sprintf(out_str, "(null)");
-
-	wrq->u.data.length = strlen(out_str);
-	if (copy_to_user(wrq->u.data.pointer, (char *)out_str,
-			 wrq->u.data.length)) {
-		lbs_deb_ioctl("FWT_LOOKUP: Copy to user failed!\n");
-		return -EFAULT;
-	}
-
-	lbs_deb_leave(LBS_DEB_IOCTL);
-	return 0;
-}
-
-/**
- *  @brief          Reset all entries from the FWT table
- *  @param priv     A pointer to wlan_private structure
- *  @return         0 --success, otherwise fail
- */
-static int wlan_fwt_reset_ioctl(wlan_private * priv)
-{
-	lbs_deb_ioctl("FWT: resetting\n");
-
-	return (libertas_prepare_and_send_command(priv,
-				      cmd_fwt_access,
-				      cmd_act_fwt_access_reset,
-				      cmd_option_waitforrsp, 0, NULL));
-}
-
-/**
- *  @brief          List an entry from the FWT table
- *  @param priv     A pointer to wlan_private structure
- *  @param req      A pointer to ifreq structure
- *  @return         0 --success, otherwise fail
- */
-static int wlan_fwt_list_ioctl(wlan_private * priv, struct ifreq *req)
-{
-	struct iwreq *wrq = (struct iwreq *)req;
-	char in_str[8];
-	static struct cmd_ds_fwt_access fwt_access;
-	char *ptr = in_str;
-	static char out_str[128];
-	char *pbuf = out_str;
-	int ret = 0;
-
-	lbs_deb_enter(LBS_DEB_IOCTL);
-
-	if (copy_from_user(in_str, wrq->u.data.pointer, sizeof(in_str))) {
-		ret = -EFAULT;
-		goto out;
-	}
-
-	fwt_access.id = cpu_to_le32(simple_strtoul(ptr, &ptr, 10));
-
-#ifdef DEBUG
-	{
-		lbs_deb_ioctl("FWT_LIST: line is %s\n", in_str);
-		lbs_deb_ioctl("FWT_LIST: listing id:%i\n", le32_to_cpu(fwt_access.id));
-	}
-#endif
-
-	ret = libertas_prepare_and_send_command(priv, cmd_fwt_access,
-				    cmd_act_fwt_access_list,
-				    cmd_option_waitforrsp, 0, (void *)&fwt_access);
-
-	if (ret == 0)
-		print_route(fwt_access, pbuf);
-	else
-		pbuf += sprintf(pbuf, " (null)");
-
-	wrq->u.data.length = strlen(out_str);
-	if (copy_to_user(wrq->u.data.pointer, (char *)out_str,
-			 wrq->u.data.length)) {
-		lbs_deb_ioctl("FWT_LIST: Copy to user failed!\n");
-		ret = -EFAULT;
-		goto out;
-	}
-
-	ret = 0;
-
-out:
-	lbs_deb_leave(LBS_DEB_IOCTL);
-	return ret;
-}
-
-/**
- *  @brief          List an entry from the FRT table
- *  @param priv     A pointer to wlan_private structure
- *  @param req      A pointer to ifreq structure
- *  @return         0 --success, otherwise fail
- */
-static int wlan_fwt_list_route_ioctl(wlan_private * priv, struct ifreq *req)
-{
-	struct iwreq *wrq = (struct iwreq *)req;
-	char in_str[64];
-	static struct cmd_ds_fwt_access fwt_access;
-	char *ptr = in_str;
-	static char out_str[128];
-	char *pbuf = out_str;
-	int ret;
-
-	lbs_deb_enter(LBS_DEB_IOCTL);
-
-	if (copy_from_user(in_str, wrq->u.data.pointer, sizeof(in_str)))
-		return -EFAULT;
-
-	fwt_access.id = cpu_to_le32(simple_strtoul(ptr, &ptr, 10));
-
-#ifdef DEBUG
-	{
-		lbs_deb_ioctl("FWT_LIST_ROUTE: line is %s\n", in_str);
-		lbs_deb_ioctl("FWT_LIST_ROUTE: listing id:%i\n", le32_to_cpu(fwt_access.id));
-	}
-#endif
-
-	ret = libertas_prepare_and_send_command(priv, cmd_fwt_access,
-				    cmd_act_fwt_access_list_route,
-				    cmd_option_waitforrsp, 0, (void *)&fwt_access);
-
-	if (ret == 0) {
-		print_route(fwt_access, pbuf);
-	} else
-		pbuf += sprintf(pbuf, " (null)");
-
-	wrq->u.data.length = strlen(out_str);
-	if (copy_to_user(wrq->u.data.pointer, (char *)out_str,
-			 wrq->u.data.length)) {
-		lbs_deb_ioctl("FWT_LIST_ROUTE: Copy to user failed!\n");
-		return -EFAULT;
-	}
-
-	lbs_deb_leave(LBS_DEB_IOCTL);
-	return 0;
-}
-
-/**
- *  @brief          List an entry from the FNT table
- *  @param priv     A pointer to wlan_private structure
- *  @param req      A pointer to ifreq structure
- *  @return         0 --success, otherwise fail
- */
-static int wlan_fwt_list_neighbor_ioctl(wlan_private * priv, struct ifreq *req)
-{
-	struct iwreq *wrq = (struct iwreq *)req;
-	char in_str[8];
-	static struct cmd_ds_fwt_access fwt_access;
-	char *ptr = in_str;
-	static char out_str[128];
-	char *pbuf = out_str;
-	int ret;
-
-	lbs_deb_enter(LBS_DEB_IOCTL);
-
-	if (copy_from_user(in_str, wrq->u.data.pointer, sizeof(in_str)))
-		return -EFAULT;
-
-	memset(&fwt_access, 0, sizeof(fwt_access));
-	fwt_access.id = cpu_to_le32(simple_strtoul(ptr, &ptr, 10));
-
-#ifdef DEBUG
-	{
-		lbs_deb_ioctl("FWT_LIST_NEIGHBOR: line is %s\n", in_str);
-		lbs_deb_ioctl("FWT_LIST_NEIGHBOR: listing id:%i\n", le32_to_cpu(fwt_access.id));
-	}
-#endif
-
-	ret = libertas_prepare_and_send_command(priv, cmd_fwt_access,
-				    cmd_act_fwt_access_list_neighbor,
-				    cmd_option_waitforrsp, 0,
-				    (void *)&fwt_access);
-
-	if (ret == 0) {
-		pbuf += sprintf(pbuf, " ra ");
-		pbuf += eth_addr2str(fwt_access.ra, pbuf);
-		pbuf += sprintf(pbuf, "  slp %u", fwt_access.sleepmode);
-		pbuf += sprintf(pbuf, "  snr %u", le32_to_cpu(fwt_access.snr));
-		pbuf += sprintf(pbuf, "  ref %u", le32_to_cpu(fwt_access.references));
-	} else
-		pbuf += sprintf(pbuf, " (null)");
-
-	wrq->u.data.length = strlen(out_str);
-	if (copy_to_user(wrq->u.data.pointer, (char *)out_str,
-			 wrq->u.data.length)) {
-		lbs_deb_ioctl("FWT_LIST_NEIGHBOR: Copy to user failed!\n");
-		return -EFAULT;
-	}
-
-	lbs_deb_leave(LBS_DEB_IOCTL);
-	return 0;
-}
-
-/**
- *  @brief          Cleans up the route (FRT) and neighbor (FNT) tables
- *                  (Garbage Collection)
- *  @param priv     A pointer to wlan_private structure
- *  @param req      A pointer to ifreq structure
- *  @return         0 --success, otherwise fail
- */
-static int wlan_fwt_cleanup_ioctl(wlan_private * priv, struct ifreq *req)
-{
-	struct iwreq *wrq = (struct iwreq *)req;
-	static struct cmd_ds_fwt_access fwt_access;
-	int ret;
-
-	lbs_deb_enter(LBS_DEB_IOCTL);
-
-	lbs_deb_ioctl("FWT: cleaning up\n");
-
-	memset(&fwt_access, 0, sizeof(fwt_access));
-
-	ret = libertas_prepare_and_send_command(priv, cmd_fwt_access,
-				    cmd_act_fwt_access_cleanup,
-				    cmd_option_waitforrsp, 0,
-				    (void *)&fwt_access);
-
-	if (ret == 0)
-		wrq->u.param.value = le32_to_cpu(fwt_access.references);
-	else
-		return -EFAULT;
-
-	lbs_deb_leave(LBS_DEB_IOCTL);
-	return 0;
-}
-
-/**
- *  @brief          Gets firmware internal time (debug purposes)
- *  @param priv     A pointer to wlan_private structure
- *  @param req      A pointer to ifreq structure
- *  @return         0 --success, otherwise fail
- */
-static int wlan_fwt_time_ioctl(wlan_private * priv, struct ifreq *req)
-{
-	struct iwreq *wrq = (struct iwreq *)req;
-	static struct cmd_ds_fwt_access fwt_access;
-	int ret;
-
-	lbs_deb_enter(LBS_DEB_IOCTL);
-
-	lbs_deb_ioctl("FWT: getting time\n");
-
-	memset(&fwt_access, 0, sizeof(fwt_access));
-
-	ret = libertas_prepare_and_send_command(priv, cmd_fwt_access,
-				    cmd_act_fwt_access_time,
-				    cmd_option_waitforrsp, 0,
-				    (void *)&fwt_access);
-
-	if (ret == 0)
-		wrq->u.param.value = le32_to_cpu(fwt_access.references);
-	else
-		return -EFAULT;
-
-	lbs_deb_leave(LBS_DEB_IOCTL);
-	return 0;
-}
-
-/**
- *  @brief          Gets mesh ttl from firmware
- *  @param priv     A pointer to wlan_private structure
- *  @param req      A pointer to ifreq structure
- *  @return         0 --success, otherwise fail
- */
-static int wlan_mesh_get_ttl_ioctl(wlan_private * priv, struct ifreq *req)
-{
-	struct iwreq *wrq = (struct iwreq *)req;
-	struct cmd_ds_mesh_access mesh_access;
-	int ret;
-
-	lbs_deb_enter(LBS_DEB_IOCTL);
-
-	memset(&mesh_access, 0, sizeof(mesh_access));
-
-	ret = libertas_prepare_and_send_command(priv, cmd_mesh_access,
-				    cmd_act_mesh_get_ttl,
-				    cmd_option_waitforrsp, 0,
-				    (void *)&mesh_access);
-
-	if (ret == 0)
-		wrq->u.param.value = le32_to_cpu(mesh_access.data[0]);
-	else
-		return -EFAULT;
-
-	lbs_deb_leave(LBS_DEB_IOCTL);
-	return 0;
-}
-
-/**
- *  @brief          Gets mesh ttl from firmware
- *  @param priv     A pointer to wlan_private structure
- *  @param ttl      New ttl value
- *  @return         0 --success, otherwise fail
- */
-static int wlan_mesh_set_ttl_ioctl(wlan_private * priv, int ttl)
-{
-	struct cmd_ds_mesh_access mesh_access;
-	int ret;
-
-	lbs_deb_enter(LBS_DEB_IOCTL);
-
-	if( (ttl > 0xff) || (ttl < 0) )
-		return -EINVAL;
-
-	memset(&mesh_access, 0, sizeof(mesh_access));
-	mesh_access.data[0] = cpu_to_le32(ttl);
-
-	ret = libertas_prepare_and_send_command(priv, cmd_mesh_access,
-						cmd_act_mesh_set_ttl,
-						cmd_option_waitforrsp, 0,
-						(void *)&mesh_access);
-
-	if (ret != 0)
-		ret = -EFAULT;
-
-	lbs_deb_leave(LBS_DEB_IOCTL);
-	return ret;
-}
-
-/**
- *  @brief ioctl function - entry point
- *
- *  @param dev		A pointer to net_device structure
- *  @param req	   	A pointer to ifreq structure
- *  @param cmd 		command
- *  @return 	   	0--success, otherwise fail
- */
-int libertas_do_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
-{
-	int subcmd = 0;
-	int idata = 0;
-	int *pdata;
-	int ret = 0;
-	wlan_private *priv = dev->priv;
-	wlan_adapter *adapter = priv->adapter;
-	struct iwreq *wrq = (struct iwreq *)req;
-
-	lbs_deb_enter(LBS_DEB_IOCTL);
-
-	lbs_deb_ioctl("libertas_do_ioctl: ioctl cmd = 0x%x\n", cmd);
-	switch (cmd) {
-	case WLAN_SETNONE_GETNONE:	/* set WPA mode on/off ioctl #20 */
-		switch (wrq->u.data.flags) {
-		case WLAN_SUBCMD_BT_RESET:	/* bt_reset */
-			wlan_bt_reset_ioctl(priv);
-			break;
-		case WLAN_SUBCMD_FWT_RESET:	/* fwt_reset */
-			wlan_fwt_reset_ioctl(priv);
-			break;
-		}		/* End of switch */
-		break;
-
-	case WLAN_SETONEINT_GETNONE:
-		/* The first 4 bytes of req->ifr_data is sub-ioctl number
-		 * after 4 bytes sits the payload.
-		 */
-		subcmd = wrq->u.data.flags;
-		if (!subcmd)
-			subcmd = (int)wrq->u.param.value;
-
-		switch (subcmd) {
-		case WLANSETREGION:
-			idata = SUBCMD_DATA(wrq);
-			ret = wlan_set_region(priv, (u16) idata);
-			break;
-		case WLAN_SUBCMD_MESH_SET_TTL:
-			idata = SUBCMD_DATA(wrq);
-			ret = wlan_mesh_set_ttl_ioctl(priv, idata);
-			break;
-
-		case WLAN_SUBCMD_BT_SET_INVERT:
-			ret = wlan_bt_set_invert_ioctl(priv, req);
-			break ;
-
-		default:
-			ret = -EOPNOTSUPP;
-			break;
-		}
-
-		break;
-
-	case WLAN_SET128CHAR_GET128CHAR:
-		switch ((int)wrq->u.data.flags) {
-		case WLAN_SUBCMD_BT_ADD:
-			ret = wlan_bt_add_ioctl(priv, req);
-			break;
-		case WLAN_SUBCMD_BT_DEL:
-			ret = wlan_bt_del_ioctl(priv, req);
-			break;
-		case WLAN_SUBCMD_BT_LIST:
-			ret = wlan_bt_list_ioctl(priv, req);
-			break;
-		case WLAN_SUBCMD_FWT_ADD:
-			ret = wlan_fwt_add_ioctl(priv, req);
-			break;
-		case WLAN_SUBCMD_FWT_DEL:
-			ret = wlan_fwt_del_ioctl(priv, req);
-			break;
-		case WLAN_SUBCMD_FWT_LOOKUP:
-			ret = wlan_fwt_lookup_ioctl(priv, req);
-			break;
-		case WLAN_SUBCMD_FWT_LIST_NEIGHBOR:
-			ret = wlan_fwt_list_neighbor_ioctl(priv, req);
-			break;
-		case WLAN_SUBCMD_FWT_LIST:
-			ret = wlan_fwt_list_ioctl(priv, req);
-			break;
-		case WLAN_SUBCMD_FWT_LIST_ROUTE:
-			ret = wlan_fwt_list_route_ioctl(priv, req);
-			break;
-		}
-		break;
-
-	case WLAN_SETNONE_GETONEINT:
-		switch (wrq->u.param.value) {
-		case WLANGETREGION:
-			pdata = (int *)wrq->u.name;
-			*pdata = (int)adapter->regioncode;
-			break;
-		case WLAN_SUBCMD_FWT_CLEANUP:	/* fwt_cleanup */
-			ret = wlan_fwt_cleanup_ioctl(priv, req);
-			break;
-
-		case WLAN_SUBCMD_FWT_TIME:	/* fwt_time */
-			ret = wlan_fwt_time_ioctl(priv, req);
-			break;
-
-		case WLAN_SUBCMD_MESH_GET_TTL:
-			ret = wlan_mesh_get_ttl_ioctl(priv, req);
-			break;
-
-		case WLAN_SUBCMD_BT_GET_INVERT:
-			ret = wlan_bt_get_invert_ioctl(priv, req);
-			break ;
-
-		default:
-			ret = -EOPNOTSUPP;
-
-		}
-
-		break;
-
-	case WLAN_SET_GET_SIXTEEN_INT:
-		switch ((int)wrq->u.data.flags) {
-		case WLAN_LED_GPIO_CTRL:
-			{
-				int i;
-				int data[16];
-
-				struct cmd_ds_802_11_led_ctrl ctrl;
-				struct mrvlietypes_ledgpio *gpio =
-				    (struct mrvlietypes_ledgpio *) ctrl.data;
-
-				memset(&ctrl, 0, sizeof(ctrl));
-				if (wrq->u.data.length > MAX_LEDS * 2)
-					return -ENOTSUPP;
-				if ((wrq->u.data.length % 2) != 0)
-					return -ENOTSUPP;
-				if (wrq->u.data.length == 0) {
-					ctrl.action =
-					    cpu_to_le16
-					    (cmd_act_get);
-				} else {
-					if (copy_from_user
-					    (data, wrq->u.data.pointer,
-					     sizeof(int) *
-					     wrq->u.data.length)) {
-						lbs_deb_ioctl(
-						       "Copy from user failed\n");
-						return -EFAULT;
-					}
-
-					ctrl.action =
-					    cpu_to_le16
-					    (cmd_act_set);
-					ctrl.numled = cpu_to_le16(0);
-					gpio->header.type =
-					    cpu_to_le16(TLV_TYPE_LED_GPIO);
-					gpio->header.len = wrq->u.data.length;
-					for (i = 0; i < wrq->u.data.length;
-					     i += 2) {
-						gpio->ledpin[i / 2].led =
-						    data[i];
-						gpio->ledpin[i / 2].pin =
-						    data[i + 1];
-					}
-				}
-				ret =
-				    libertas_prepare_and_send_command(priv,
-							  cmd_802_11_led_gpio_ctrl,
-							  0,
-							  cmd_option_waitforrsp,
-							  0, (void *)&ctrl);
-				for (i = 0; i < gpio->header.len; i += 2) {
-					data[i] = gpio->ledpin[i / 2].led;
-					data[i + 1] = gpio->ledpin[i / 2].pin;
-				}
-				if (copy_to_user(wrq->u.data.pointer, data,
-						 sizeof(int) *
-						 gpio->header.len)) {
-					lbs_deb_ioctl("Copy to user failed\n");
-					return -EFAULT;
-				}
-
-				wrq->u.data.length = gpio->header.len;
-			}
-			break;
-		}
-		break;
-
-	default:
-		ret = -EINVAL;
-		break;
-	}
-
-	lbs_deb_leave_args(LBS_DEB_IOCTL, "ret %d", ret);
-	return ret;
-}
-
-
diff --git a/drivers/net/wireless/libertas/main.c b/drivers/net/wireless/libertas/main.c
index 623ab4b..4a59306 100644
--- a/drivers/net/wireless/libertas/main.c
+++ b/drivers/net/wireless/libertas/main.c
@@ -181,7 +181,8 @@ u16 libertas_region_code_to_index[MRVDRV_MAX_REGION_CODE] =
  * @brief Get function for sysfs attribute anycast_mask
  */
 static ssize_t libertas_anycast_get(struct device * dev,
-		struct device_attribute *attr, char * buf) {
+		struct device_attribute *attr, char * buf)
+{
 	struct cmd_ds_mesh_access mesh_access;
 
 	memset(&mesh_access, 0, sizeof(mesh_access));
@@ -197,7 +198,8 @@ static ssize_t libertas_anycast_get(struct device * dev,
  * @brief Set function for sysfs attribute anycast_mask
  */
 static ssize_t libertas_anycast_set(struct device * dev,
-		struct device_attribute *attr, const char * buf, size_t count) {
+		struct device_attribute *attr, const char * buf, size_t count)
+{
 	struct cmd_ds_mesh_access mesh_access;
 	uint32_t datum;
 
@@ -799,7 +801,6 @@ wlan_private *libertas_add_card(void *card, struct device *dmdev)
 	dev->open = wlan_open;
 	dev->hard_start_xmit = wlan_pre_start_xmit;
 	dev->stop = wlan_close;
-	dev->do_ioctl = libertas_do_ioctl;
 	dev->set_mac_address = wlan_set_mac_address;
 	dev->tx_timeout = wlan_tx_timeout;
 	dev->get_stats = wlan_get_stats;
@@ -918,7 +919,6 @@ int libertas_add_mesh(wlan_private *priv, struct device *dev)
 	mesh_dev->open = mesh_open;
 	mesh_dev->hard_start_xmit = mesh_pre_start_xmit;
 	mesh_dev->stop = mesh_close;
-	mesh_dev->do_ioctl = libertas_do_ioctl;
 	mesh_dev->get_stats = wlan_get_stats;
 	mesh_dev->set_mac_address = wlan_set_mac_address;
 	mesh_dev->ethtool_ops = &libertas_ethtool_ops;
diff --git a/drivers/net/wireless/libertas/scan.c b/drivers/net/wireless/libertas/scan.c
index 606af50..c3043dc 100644
--- a/drivers/net/wireless/libertas/scan.c
+++ b/drivers/net/wireless/libertas/scan.c
@@ -215,38 +215,6 @@ done:
 }
 
 /**
- *  @brief Post process the scan table after a new scan command has completed
- *
- *  Inspect each entry of the scan table and try to find an entry that
- *    matches our current associated/joined network from the scan.  If
- *    one is found, update the stored copy of the bssdescriptor for our
- *    current network.
- *
- *  Debug dump the current scan table contents if compiled accordingly.
- *
- *  @param priv   A pointer to wlan_private structure
- *
- *  @return       void
- */
-static void wlan_scan_process_results(wlan_private * priv)
-{
-	wlan_adapter *adapter = priv->adapter;
-	struct bss_descriptor * iter_bss;
-	int i = 0;
-
-	if (adapter->connect_status == libertas_connected)
-		return;
-
-	mutex_lock(&adapter->lock);
-	list_for_each_entry (iter_bss, &adapter->network_list, list) {
-		lbs_deb_scan("Scan:(%02d) " MAC_FMT ", RSSI[%03d], SSID[%s]\n",
-		       i++, MAC_ARG(iter_bss->bssid), (s32) iter_bss->rssi,
-		       escape_essid(iter_bss->ssid, iter_bss->ssid_len));
-	}
-	mutex_unlock(&adapter->lock);
-}
-
-/**
  *  @brief Create a channel list for the driver to scan based on region info
  *
  *  Use the driver region/band information to construct a comprehensive list
@@ -791,6 +759,10 @@ int wlan_scan_networks(wlan_private * priv,
 	u8 scancurrentchanonly;
 	int maxchanperscan;
 	int ret;
+#ifdef CONFIG_LIBERTAS_DEBUG
+	struct bss_descriptor * iter_bss;
+	int i = 0;
+#endif
 
 	lbs_deb_enter(LBS_DEB_ASSOC);
 
@@ -832,11 +804,16 @@ int wlan_scan_networks(wlan_private * priv,
 				     puserscanin,
 				     full_scan);
 
-	/*  Process the resulting scan table:
-	 *    - Remove any bad ssids
-	 *    - Update our current BSS information from scan data
-	 */
-	wlan_scan_process_results(priv);
+#ifdef CONFIG_LIBERTAS_DEBUG
+	/* Dump the scan table */
+	mutex_lock(&adapter->lock);
+	list_for_each_entry (iter_bss, &adapter->network_list, list) {
+		lbs_deb_scan("Scan:(%02d) " MAC_FMT ", RSSI[%03d], SSID[%s]\n",
+		       i++, MAC_ARG(iter_bss->bssid), (s32) iter_bss->rssi,
+		       escape_essid(iter_bss->ssid, iter_bss->ssid_len));
+	}
+	mutex_unlock(&adapter->lock);
+#endif
 
 	if (priv->adapter->connect_status == libertas_connected) {
 		netif_carrier_on(priv->dev);
diff --git a/drivers/net/wireless/libertas/wext.c b/drivers/net/wireless/libertas/wext.c
index 8939251..f42b796 100644
--- a/drivers/net/wireless/libertas/wext.c
+++ b/drivers/net/wireless/libertas/wext.c
@@ -913,148 +913,6 @@ out:
 	return 0;
 }
 
-/*
- * iwpriv settable callbacks
- */
-
-static const iw_handler wlan_private_handler[] = {
-	NULL,			/* SIOCIWFIRSTPRIV */
-};
-
-static const struct iw_priv_args wlan_private_args[] = {
-	/*
-	 * { cmd, set_args, get_args, name }
-	 */
-	/* Using iwpriv sub-command feature */
-	{
-	 WLAN_SETONEINT_GETNONE,	/* IOCTL: 24 */
-	 IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
-	 IW_PRIV_TYPE_NONE,
-	 ""},
-	{
-	 WLANSETREGION,
-	 IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
-	 IW_PRIV_TYPE_NONE,
-	 "setregioncode"},
-	{
-	 WLAN_SUBCMD_MESH_SET_TTL,
-	 IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
-	 IW_PRIV_TYPE_NONE,
-	 "mesh_set_ttl"},
-	{
-	 WLAN_SETNONE_GETONEINT,
-	 IW_PRIV_TYPE_NONE,
-	 IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
-	 ""},
-	{
-	 WLANGETREGION,
-	 IW_PRIV_TYPE_NONE,
-	 IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
-	 "getregioncode"},
-	{
-	 WLAN_SUBCMD_FWT_CLEANUP,
-	 IW_PRIV_TYPE_NONE,
-	 IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
-	 "fwt_cleanup"},
-	{
-	 WLAN_SUBCMD_FWT_TIME,
-	 IW_PRIV_TYPE_NONE,
-	 IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
-	 "fwt_time"},
-	{
-	 WLAN_SUBCMD_MESH_GET_TTL,
-	 IW_PRIV_TYPE_NONE,
-	 IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
-	 "mesh_get_ttl"},
-	{
-	 WLAN_SETNONE_GETNONE,
-	 IW_PRIV_TYPE_NONE,
-	 IW_PRIV_TYPE_NONE,
-	 ""},
-	{
-	 WLAN_SUBCMD_FWT_RESET,
-	 IW_PRIV_TYPE_NONE,
-	 IW_PRIV_TYPE_NONE,
-	 "fwt_reset"},
-	{
-	 WLAN_SUBCMD_BT_RESET,
-	 IW_PRIV_TYPE_NONE,
-	 IW_PRIV_TYPE_NONE,
-	 "bt_reset"},
-	{
-	 WLAN_SET128CHAR_GET128CHAR,
-	 IW_PRIV_TYPE_CHAR | 128,
-	 IW_PRIV_TYPE_CHAR | 128,
-	 ""},
-	/* BT Management */
-	{
-	 WLAN_SUBCMD_BT_ADD,
-	 IW_PRIV_TYPE_CHAR | 128,
-	 IW_PRIV_TYPE_CHAR | 128,
-	 "bt_add"},
-	{
-	 WLAN_SUBCMD_BT_DEL,
-	 IW_PRIV_TYPE_CHAR | 128,
-	 IW_PRIV_TYPE_CHAR | 128,
-	 "bt_del"},
-	{
-	 WLAN_SUBCMD_BT_LIST,
-	 IW_PRIV_TYPE_CHAR | 128,
-	 IW_PRIV_TYPE_CHAR | 128,
-	 "bt_list"},
-	{
-	 WLAN_SUBCMD_BT_SET_INVERT,
-	 IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
-	 IW_PRIV_TYPE_NONE,
-	 "bt_set_invert"},
-	{
-	 WLAN_SUBCMD_BT_GET_INVERT,
-	 IW_PRIV_TYPE_NONE,
-	 IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
-	 "bt_get_invert"},
-	/* FWT Management */
-	{
-	 WLAN_SUBCMD_FWT_ADD,
-	 IW_PRIV_TYPE_CHAR | 128,
-	 IW_PRIV_TYPE_CHAR | 128,
-	 "fwt_add"},
-	{
-	 WLAN_SUBCMD_FWT_DEL,
-	 IW_PRIV_TYPE_CHAR | 128,
-	 IW_PRIV_TYPE_CHAR | 128,
-	 "fwt_del"},
-	{
-	 WLAN_SUBCMD_FWT_LOOKUP,
-	 IW_PRIV_TYPE_CHAR | 128,
-	 IW_PRIV_TYPE_CHAR | 128,
-	 "fwt_lookup"},
-	{
-	 WLAN_SUBCMD_FWT_LIST_NEIGHBOR,
-	 IW_PRIV_TYPE_CHAR | 128,
-	 IW_PRIV_TYPE_CHAR | 128,
-	 "fwt_list_neigh"},
-	{
-	 WLAN_SUBCMD_FWT_LIST,
-	 IW_PRIV_TYPE_CHAR | 128,
-	 IW_PRIV_TYPE_CHAR | 128,
-	 "fwt_list"},
-	{
-	 WLAN_SUBCMD_FWT_LIST_ROUTE,
-	 IW_PRIV_TYPE_CHAR | 128,
-	 IW_PRIV_TYPE_CHAR | 128,
-	 "fwt_list_route"},
-	{
-	 WLAN_SET_GET_SIXTEEN_INT,
-	 IW_PRIV_TYPE_INT | 16,
-	 IW_PRIV_TYPE_INT | 16,
-	 ""},
-	{
-	 WLAN_LED_GPIO_CTRL,
-	 IW_PRIV_TYPE_INT | 16,
-	 IW_PRIV_TYPE_INT | 16,
-	 "ledgpio"},
-};
-
 static struct iw_statistics *wlan_get_wireless_stats(struct net_device *dev)
 {
 	enum {
@@ -2444,22 +2302,12 @@ static const iw_handler mesh_wlan_handler[] = {
 };
 struct iw_handler_def libertas_handler_def = {
 	.num_standard	= sizeof(wlan_handler) / sizeof(iw_handler),
-	.num_private	= sizeof(wlan_private_handler) / sizeof(iw_handler),
-	.num_private_args = sizeof(wlan_private_args) /
-		sizeof(struct iw_priv_args),
 	.standard	= (iw_handler *) wlan_handler,
-	.private	= (iw_handler *) wlan_private_handler,
-	.private_args	= (struct iw_priv_args *)wlan_private_args,
 	.get_wireless_stats = wlan_get_wireless_stats,
 };
 
 struct iw_handler_def mesh_handler_def = {
 	.num_standard	= sizeof(mesh_wlan_handler) / sizeof(iw_handler),
-	.num_private	= sizeof(wlan_private_handler) / sizeof(iw_handler),
-	.num_private_args = sizeof(wlan_private_args) /
-		sizeof(struct iw_priv_args),
 	.standard	= (iw_handler *) mesh_wlan_handler,
-	.private	= (iw_handler *) wlan_private_handler,
-	.private_args	= (struct iw_priv_args *)wlan_private_args,
 	.get_wireless_stats = wlan_get_wireless_stats,
 };
diff --git a/drivers/net/wireless/libertas/wext.h b/drivers/net/wireless/libertas/wext.h
index d555056..3d5196c 100644
--- a/drivers/net/wireless/libertas/wext.h
+++ b/drivers/net/wireless/libertas/wext.h
@@ -7,45 +7,6 @@
 #define SUBCMD_OFFSET			4
 #define SUBCMD_DATA(x)			*((int *)(x->u.name + SUBCMD_OFFSET))
 
-/** PRIVATE CMD ID */
-#define	WLANIOCTL			SIOCIWFIRSTPRIV
-
-#define WLAN_SETNONE_GETNONE	        (WLANIOCTL + 8)
-#define WLAN_SUBCMD_BT_RESET			13
-#define WLAN_SUBCMD_FWT_RESET			14
-
-#define WLAN_SETNONE_GETONEINT		(WLANIOCTL + 15)
-#define WLANGETREGION				1
-
-#define WLAN_SUBCMD_FWT_CLEANUP			15
-#define WLAN_SUBCMD_FWT_TIME			16
-#define WLAN_SUBCMD_MESH_GET_TTL		17
-#define WLAN_SUBCMD_BT_GET_INVERT		18
-
-#define WLAN_SETONEINT_GETNONE		(WLANIOCTL + 24)
-#define WLANSETREGION				8
-#define WLAN_SUBCMD_MESH_SET_TTL		18
-#define WLAN_SUBCMD_BT_SET_INVERT		19
-
-#define WLAN_SET128CHAR_GET128CHAR	(WLANIOCTL + 25)
-#define WLAN_SUBCMD_BT_ADD			18
-#define WLAN_SUBCMD_BT_DEL   			19
-#define WLAN_SUBCMD_BT_LIST			20
-#define WLAN_SUBCMD_FWT_ADD			21
-#define WLAN_SUBCMD_FWT_DEL   			22
-#define WLAN_SUBCMD_FWT_LOOKUP			23
-#define WLAN_SUBCMD_FWT_LIST_NEIGHBOR		24
-#define WLAN_SUBCMD_FWT_LIST			25
-#define WLAN_SUBCMD_FWT_LIST_ROUTE		26
-
-#define WLAN_SET_GET_SIXTEEN_INT       (WLANIOCTL + 29)
-#define WLAN_LED_GPIO_CTRL			5
-
-#define WLAN_LINKMODE_802_3			0
-#define WLAN_LINKMODE_802_11			2
-#define WLAN_RADIOMODE_NONE    			0
-#define WLAN_RADIOMODE_RADIOTAP			2
-
 /** wlan_ioctl_regrdwr */
 struct wlan_ioctl_regrdwr {
 	/** Which register to access */
@@ -57,9 +18,13 @@ struct wlan_ioctl_regrdwr {
 	u32 value;
 };
 
+#define WLAN_LINKMODE_802_3			0
+#define WLAN_LINKMODE_802_11			2
+#define WLAN_RADIOMODE_NONE			0
+#define WLAN_RADIOMODE_RADIOTAP			2
+
 extern struct iw_handler_def libertas_handler_def;
 extern struct iw_handler_def mesh_handler_def;
-int libertas_do_ioctl(struct net_device *dev, struct ifreq *req, int i);
 int wlan_radio_ioctl(wlan_private * priv, u8 option);
 
 #endif				/* _WLAN_WEXT_H_ */
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
