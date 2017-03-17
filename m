From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next] liquidio: fix for vf mac addr command sent to nic
 firmware
Date: Fri, 17 Mar 2017 15:43:26 -0700
Message-ID: <20170317224326.GA2409@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        ricardo.farrington@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0063.outbound.protection.outlook.com ([104.47.38.63]:2714
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751221AbdCQWni (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 17 Mar 2017 18:43:38 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Farrington <ricardo.farrington@cavium.com>

Change to support host<->firmware command return value.
Fix for vf mac addr state command.
1. Added support for firmware commands to return a value:
   - previously, the returned code overlapped with host codes, thus
     commands were only returning 0 (success) or -1 (interpreted as
     timeout)
   - per 'response_manager.h', the error codes are split into two fields
     (major/minor) now, firmware commands are grouped into their own
     'major' group, separate from the host's 'major' group, which allow f/w
     commands to return any 16-bit value
2. The command to set vf mac addr was logging a success message even if
   command failed.  Now command uses a callback function to log the status
   message.
3. The command to set vf mac addr was not logging a message when set via
   the host 'ip' command.  Now, the callback function will log an
   appropriate message.

Signed-off-by: Rick Farrington <ricardo.farrington@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
Signed-off-by: Derek Chickles <derek.chickles@cavium.com>
Signed-off-by: Satanand Burla <satananda.burla@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_core.c       | 19 ++++++++++++++-----
 drivers/net/ethernet/cavium/liquidio/lio_main.c       |  3 ++-
 .../net/ethernet/cavium/liquidio/response_manager.c   | 11 +++++++++--
 .../net/ethernet/cavium/liquidio/response_manager.h   |  5 +++++
 4 files changed, 30 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_core.c b/drivers/net/ethernet/cavium/liquidio/lio_core.c
index f629c2f..65a1a9e 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_core.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_core.c
@@ -131,11 +131,20 @@ void liquidio_link_ctrl_cmd_completion(void *nctrl_ptr)
 
 	case OCTNET_CMD_CHANGE_MACADDR:
 		mac = ((u8 *)&nctrl->udd[0]) + 2;
-		netif_info(lio, probe, lio->netdev,
-			   "MACAddr changed to %2.2x:%2.2x:%2.2x:%2.2x:%2.2x:%2.2x\n",
-			   mac[0], mac[1],
-			   mac[2], mac[3],
-			   mac[4], mac[5]);
+		if (nctrl->ncmd.s.param1) {
+			/* vfidx is 0 based, but vf_num (param1) is 1 based */
+			int vfidx = nctrl->ncmd.s.param1 - 1;
+			bool mac_is_admin_assigned = nctrl->ncmd.s.param2;
+
+			if (mac_is_admin_assigned)
+				netif_info(lio, probe, lio->netdev,
+					   "MAC Address %pM is configured for VF %d\n",
+					   mac, vfidx);
+		} else {
+			netif_info(lio, probe, lio->netdev,
+				   " MACAddr changed to %pM\n",
+				   mac);
+		}
 		break;
 
 	case OCTNET_CMD_CHANGE_MTU:
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index be9c0e3..6a0f7f1 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -3596,7 +3596,8 @@ static int __liquidio_set_vf_mac(struct net_device *netdev, int vfidx,
 	nctrl.ncmd.s.param2 = (is_admin_assigned ? 1 : 0);
 	nctrl.ncmd.s.more = 1;
 	nctrl.iq_no = lio->linfo.txpciq[0].s.q_no;
-	nctrl.cb_fn = 0;
+	nctrl.netpndev = (u64)netdev;
+	nctrl.cb_fn = liquidio_link_ctrl_cmd_completion;
 	nctrl.wait_time = LIO_CMD_WAIT_TM;
 
 	nctrl.udd[0] = 0;
diff --git a/drivers/net/ethernet/cavium/liquidio/response_manager.c b/drivers/net/ethernet/cavium/liquidio/response_manager.c
index 2fbaae9..011c5eb 100644
--- a/drivers/net/ethernet/cavium/liquidio/response_manager.c
+++ b/drivers/net/ethernet/cavium/liquidio/response_manager.c
@@ -107,8 +107,15 @@ int lio_process_ordered_list(struct octeon_device *octeon_dev,
 			if ((status64 & 0xff) != 0xff) {
 				octeon_swap_8B_data(&status64, 1);
 				if (((status64 & 0xff) != 0xff)) {
-					status = (u32)(status64 &
-						       0xffffffffULL);
+					/* retrieve 16-bit firmware status */
+					status = (u32)(status64 & 0xffffULL);
+					if (status) {
+						status =
+						  FIRMWARE_STATUS_CODE(status);
+					} else {
+						/* i.e. no error */
+						status = OCTEON_REQUEST_DONE;
+					}
 				}
 			}
 		} else if (force_quit || (sc->timeout &&
diff --git a/drivers/net/ethernet/cavium/liquidio/response_manager.h b/drivers/net/ethernet/cavium/liquidio/response_manager.h
index cbb2d84..9169c28 100644
--- a/drivers/net/ethernet/cavium/liquidio/response_manager.h
+++ b/drivers/net/ethernet/cavium/liquidio/response_manager.h
@@ -78,6 +78,8 @@ enum {
 
 /*------------   Error codes used by host driver   -----------------*/
 #define DRIVER_MAJOR_ERROR_CODE           0x0000
+/*------   Error codes used by firmware (bits 15..0 set by firmware */
+#define FIRMWARE_MAJOR_ERROR_CODE         0x0001
 
 /**  A value of 0x00000000 indicates no error i.e. success */
 #define DRIVER_ERROR_NONE                 0x00000000
@@ -116,6 +118,9 @@ enum {
 
 };
 
+#define FIRMWARE_STATUS_CODE(status) \
+	((FIRMWARE_MAJOR_ERROR_CODE << 16) | (status))
+
 /** Initialize the response lists. The number of response lists to create is
  * given by count.
  * @param octeon_dev      - the octeon device structure.
