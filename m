From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next] liquidio: fix VF incorrectly indicating that it
 successfully set its VLAN
Date: Thu, 6 Apr 2017 19:22:22 -0700
Message-ID: <20170407022222.GA1017@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0082.outbound.protection.outlook.com ([104.47.41.82]:52038
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751081AbdDGCW3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 6 Apr 2017 22:22:29 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For security reasons, NIC firmware does not allow VF to set its VLAN if PF
set it already.  Firmware allows VF to set its VLAN if PF did not set it.
After the VF instructs the firmware to set the VLAN, VF always indicates
(via return 0) that the operation is successful--even for the times when it
isn't.

Put in a mechanism for the VF's set VLAN function to receive the firmware
response code, then make that function return -EPERM if the firmware
forbids the operation.

Make that mechanism available for other functions that may, in the future,
be interested in receiving the response code from the firmware.  That
mechanism involves adding new fields to struct octnic_ctrl_pkt, so make all
users of struct octnic_ctrl_pkt initialize the struct to zero before using
it; otherwise, the mechanism might act on uninitialized garbage.

Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
Signed-off-by: Derek Chickles <derek.chickles@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_core.c    | 11 +++++++++++
 drivers/net/ethernet/cavium/liquidio/lio_main.c    |  4 ++++
 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c | 19 ++++++++++++++++++-
 drivers/net/ethernet/cavium/liquidio/octeon_nic.c  | 10 ++++++----
 drivers/net/ethernet/cavium/liquidio/octeon_nic.h  |  4 ++++
 5 files changed, 43 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_core.c b/drivers/net/ethernet/cavium/liquidio/lio_core.c
index 08676df..796c2cb 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_core.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_core.c
@@ -127,6 +127,17 @@ void liquidio_link_ctrl_cmd_completion(void *nctrl_ptr)
 	struct octeon_device *oct = lio->oct_dev;
 	u8 *mac;
 
+	if (nctrl->completion && nctrl->response_code) {
+		/* Signal whoever is interested that the response code from the
+		 * firmware has arrived.
+		 */
+		WRITE_ONCE(*nctrl->response_code, nctrl->status);
+		complete(nctrl->completion);
+	}
+
+	if (nctrl->status)
+		return;
+
 	switch (nctrl->ncmd.s.cmd) {
 	case OCTNET_CMD_CHANGE_DEVFLAGS:
 	case OCTNET_CMD_SET_MULTI_LIST:
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index a8426d3..afa816e 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -3472,6 +3472,8 @@ static int liquidio_set_rxcsum_command(struct net_device *netdev, int command,
 	struct octnic_ctrl_pkt nctrl;
 	int ret = 0;
 
+	memset(&nctrl, 0, sizeof(struct octnic_ctrl_pkt));
+
 	nctrl.ncmd.u64 = 0;
 	nctrl.ncmd.s.cmd = command;
 	nctrl.ncmd.s.param1 = rx_cmd;
@@ -3505,6 +3507,8 @@ static int liquidio_vxlan_port_command(struct net_device *netdev, int command,
 	struct octnic_ctrl_pkt nctrl;
 	int ret = 0;
 
+	memset(&nctrl, 0, sizeof(struct octnic_ctrl_pkt));
+
 	nctrl.ncmd.u64 = 0;
 	nctrl.ncmd.s.cmd = command;
 	nctrl.ncmd.s.more = vxlan_cmd_bit;
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
index 174d748..34c7782 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
@@ -2484,6 +2484,8 @@ liquidio_vlan_rx_add_vid(struct net_device *netdev,
 	struct lio *lio = GET_LIO(netdev);
 	struct octeon_device *oct = lio->oct_dev;
 	struct octnic_ctrl_pkt nctrl;
+	struct completion compl;
+	u16 response_code;
 	int ret = 0;
 
 	memset(&nctrl, 0, sizeof(struct octnic_ctrl_pkt));
@@ -2495,14 +2497,25 @@ liquidio_vlan_rx_add_vid(struct net_device *netdev,
 	nctrl.wait_time = 100;
 	nctrl.netpndev = (u64)netdev;
 	nctrl.cb_fn = liquidio_link_ctrl_cmd_completion;
+	init_completion(&compl);
+	nctrl.completion = &compl;
+	nctrl.response_code = &response_code;
 
 	ret = octnet_send_nic_ctrl_pkt(lio->oct_dev, &nctrl);
 	if (ret < 0) {
 		dev_err(&oct->pci_dev->dev, "Add VLAN filter failed in core (ret: 0x%x)\n",
 			ret);
+		return -EIO;
 	}
 
-	return ret;
+	if (!wait_for_completion_timeout(&compl,
+					 msecs_to_jiffies(nctrl.wait_time)))
+		return -EPERM;
+
+	if (READ_ONCE(response_code))
+		return -EPERM;
+
+	return 0;
 }
 
 static int
@@ -2547,6 +2560,8 @@ static int liquidio_set_rxcsum_command(struct net_device *netdev, int command,
 	struct octnic_ctrl_pkt nctrl;
 	int ret = 0;
 
+	memset(&nctrl, 0, sizeof(struct octnic_ctrl_pkt));
+
 	nctrl.ncmd.u64 = 0;
 	nctrl.ncmd.s.cmd = command;
 	nctrl.ncmd.s.param1 = rx_cmd;
@@ -2579,6 +2594,8 @@ static int liquidio_vxlan_port_command(struct net_device *netdev, int command,
 	struct octnic_ctrl_pkt nctrl;
 	int ret = 0;
 
+	memset(&nctrl, 0, sizeof(struct octnic_ctrl_pkt));
+
 	nctrl.ncmd.u64 = 0;
 	nctrl.ncmd.s.cmd = command;
 	nctrl.ncmd.s.more = vxlan_cmd_bit;
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_nic.c b/drivers/net/ethernet/cavium/liquidio/octeon_nic.c
index 0243be8..b457cf2 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_nic.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_nic.c
@@ -100,14 +100,16 @@ static void octnet_link_ctrl_callback(struct octeon_device *oct,
 
 	nctrl = (struct octnic_ctrl_pkt *)sc->ctxptr;
 
-	/* Call the callback function if status is OK.
-	 * Status is OK only if a response was expected and core returned
-	 * success.
+	/* Call the callback function if status is zero (meaning OK) or status
+	 * contains a firmware status code bigger than zero (meaning the
+	 * firmware is reporting an error).
 	 * If no response was expected, status is OK if the command was posted
 	 * successfully.
 	 */
-	if (!status && nctrl->cb_fn)
+	if ((!status || status > FIRMWARE_STATUS_CODE(0)) && nctrl->cb_fn) {
+		nctrl->status = status;
 		nctrl->cb_fn(nctrl);
+	}
 
 	octeon_free_soft_command(oct, sc);
 }
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_nic.h b/drivers/net/ethernet/cavium/liquidio/octeon_nic.h
index 0c7a5c9..6480ef8 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_nic.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_nic.h
@@ -62,6 +62,10 @@ struct octnic_ctrl_pkt {
 
 	/** Callback function called when the command has been fetched */
 	octnic_ctrl_pkt_cb_fn_t cb_fn;
+
+	u32 status;
+	u16 *response_code;
+	struct completion *completion;
 };
 
 #define MAX_UDD_SIZE(nctrl) (sizeof((nctrl)->udd))
