From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 1/9] sfc: update MCDI protocol definitions
Date: Tue, 21 Jul 2015 15:08:56 +0100
Message-ID: <55AE5278.7000303@solarflare.com>
References: <55AE5230.3040605@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:33188 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753084AbbGUOSF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2015 10:18:05 -0400
In-Reply-To: <55AE5230.3040605@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi_pcol.h | 3463 +++++++++++++++++++++++++---------
 1 file changed, 2600 insertions(+), 863 deletions(-)

diff --git a/drivers/net/ethernet/sfc/mcdi_pcol.h b/drivers/net/ethernet/sfc/mcdi_pcol.h
index 45fca9f..4cc7721 100644
--- a/drivers/net/ethernet/sfc/mcdi_pcol.h
+++ b/drivers/net/ethernet/sfc/mcdi_pcol.h
@@ -26,6 +26,10 @@
  * Unlike a warm boot, assume DMEM has been reloaded, so that
  * the MC persistent data must be reinitialised. */
 #define MC_FW_TEPID_BOOT_OK (16)
+/* We have entered the main firmware via recovery mode.  This
+ * means that MC persistent data must be reinitialised, but that
+ * we shouldn't touch PCIe config. */
+#define MC_FW_RECOVERY_MODE_PCIE_INIT_OK (32)
 /* BIST state has been initialized */
 #define MC_FW_BIST_INIT_OK (128)
 
@@ -169,6 +173,8 @@
 #define MC_CMD_ERR_EINTR 4
 /* I/O failure */
 #define MC_CMD_ERR_EIO 5
+/* Already exists */
+#define MC_CMD_ERR_EEXIST 6
 /* Try again */
 #define MC_CMD_ERR_EAGAIN 11
 /* Out of memory */
@@ -181,6 +187,10 @@
 #define MC_CMD_ERR_ENODEV 19
 /* Invalid argument to target */
 #define MC_CMD_ERR_EINVAL 22
+/* Broken pipe */
+#define MC_CMD_ERR_EPIPE 32
+/* Read-only */
+#define MC_CMD_ERR_EROFS 30
 /* Out of range */
 #define MC_CMD_ERR_ERANGE 34
 /* Non-recursive resource is already acquired */
@@ -226,6 +236,43 @@
 #define MC_CMD_ERR_SLAVE_NOT_PRESENT 0x100a
 /* The datapath is disabled. */
 #define MC_CMD_ERR_DATAPATH_DISABLED 0x100b
+/* The requesting client is not a function */
+#define MC_CMD_ERR_CLIENT_NOT_FN  0x100c
+/* The requested operation might require the
+   command to be passed between MCs, and the
+   transport doesn't support that.  Should
+   only ever been seen over the UART. */
+#define MC_CMD_ERR_TRANSPORT_NOPROXY 0x100d
+/* VLAN tag(s) exists */
+#define MC_CMD_ERR_VLAN_EXIST 0x100e
+/* No MAC address assigned to an EVB port */
+#define MC_CMD_ERR_NO_MAC_ADDR 0x100f
+/* Notifies the driver that the request has been relayed
+ * to an admin function for authorization. The driver should
+ * wait for a PROXY_RESPONSE event and then resend its request.
+ * This error code is followed by a 32-bit handle that
+ * helps matching it with the respective PROXY_RESPONSE event. */
+#define MC_CMD_ERR_PROXY_PENDING 0x1010
+#define MC_CMD_ERR_PROXY_PENDING_HANDLE_OFST 4
+/* The request cannot be passed for authorization because
+ * another request from the same function is currently being
+ * authorized. The drvier should try again later. */
+#define MC_CMD_ERR_PROXY_INPROGRESS 0x1011
+/* Returned by MC_CMD_PROXY_COMPLETE if the caller is not the function
+ * that has enabled proxying or BLOCK_INDEX points to a function that
+ * doesn't await an authorization. */
+#define MC_CMD_ERR_PROXY_UNEXPECTED 0x1012
+/* This code is currently only used internally in FW. Its meaning is that
+ * an operation failed due to lack of SR-IOV privilege.
+ * Normally it is translated to EPERM by send_cmd_err(),
+ * but it may also be used to trigger some special mechanism
+ * for handling such case, e.g. to relay the failed request
+ * to a designated admin function for authorization. */
+#define MC_CMD_ERR_NO_PRIVILEGE 0x1013
+/* Workaround 26807 could not be turned on/off because some functions
+ * have already installed filters. See the comment at
+ * MC_CMD_WORKAROUND_BUG26807. */
+#define MC_CMD_ERR_FILTERS_PRESENT 0x1014
 
 #define MC_CMD_ERR_CODE_OFST 0
 
@@ -275,6 +322,11 @@
 	 MC_CMD_DBIWROP_TYPEDEF_VALUE_OFST +		\
 	 (n) * MC_CMD_DBIWROP_TYPEDEF_LEN)
 
+/* This may be ORed with an EVB_PORT_ID_xxx constant to pass a non-default
+ * stack ID (which must be in the range 1-255) along with an EVB port ID.
+ */
+#define EVB_STACK_ID(n)  (((n) & 0xff) << 16)
+
 
 /* Version 2 adds an optional argument to error returns: the errno value
  * may be followed by the (0-based) number of the first argument that
@@ -394,6 +446,8 @@
 #define          MCDI_EVENT_AOE_BYTEBLASTER 0x9
 /* enum: DDR ECC status update */
 #define          MCDI_EVENT_AOE_DDR_ECC_STATUS 0xa
+/* enum: PTP status update */
+#define          MCDI_EVENT_AOE_PTP_STATUS 0xb
 #define        MCDI_EVENT_AOE_ERR_DATA_LBN 8
 #define        MCDI_EVENT_AOE_ERR_DATA_WIDTH 8
 #define        MCDI_EVENT_RX_ERR_RXQ_LBN 0
@@ -408,6 +462,16 @@
 #define        MCDI_EVENT_RX_FLUSH_RXQ_WIDTH 12
 #define        MCDI_EVENT_MC_REBOOT_COUNT_LBN 0
 #define        MCDI_EVENT_MC_REBOOT_COUNT_WIDTH 16
+#define        MCDI_EVENT_MUM_ERR_TYPE_LBN 0
+#define        MCDI_EVENT_MUM_ERR_TYPE_WIDTH 8
+/* enum: MUM failed to load - no valid image? */
+#define          MCDI_EVENT_MUM_NO_LOAD 0x1
+/* enum: MUM f/w reported an exception */
+#define          MCDI_EVENT_MUM_ASSERT 0x2
+/* enum: MUM not kicking watchdog */
+#define          MCDI_EVENT_MUM_WATCHDOG 0x3
+#define        MCDI_EVENT_MUM_ERR_DATA_LBN 8
+#define        MCDI_EVENT_MUM_ERR_DATA_WIDTH 8
 #define       MCDI_EVENT_DATA_LBN 0
 #define       MCDI_EVENT_DATA_WIDTH 32
 #define       MCDI_EVENT_SRC_LBN 36
@@ -416,6 +480,8 @@
 #define       MCDI_EVENT_EV_CODE_WIDTH 4
 #define       MCDI_EVENT_CODE_LBN 44
 #define       MCDI_EVENT_CODE_WIDTH 8
+/* enum: Event generated by host software */
+#define          MCDI_EVENT_SW_EVENT 0x0
 /* enum: Bad assert. */
 #define          MCDI_EVENT_CODE_BADSSERT 0x1
 /* enum: PM Notice. */
@@ -470,6 +536,14 @@
 #define          MCDI_EVENT_CODE_MC_BIST 0x19
 /* enum: PTP tick event providing current NIC time */
 #define          MCDI_EVENT_CODE_PTP_TIME 0x1a
+/* enum: MUM fault */
+#define          MCDI_EVENT_CODE_MUM 0x1b
+/* enum: notify the designated PF of a new authorization request */
+#define          MCDI_EVENT_CODE_PROXY_REQUEST 0x1c
+/* enum: notify a function that awaits an authorization that its request has
+ * been processed and it may now resend the command
+ */
+#define          MCDI_EVENT_CODE_PROXY_RESPONSE 0x1d
 /* enum: Artificial event generated by host and posted via MC for test
  * purposes.
  */
@@ -537,6 +611,33 @@
 /* For CODE_PTP_TIME events, bits 19-26 of the minor value of the PTP clock */
 #define       MCDI_EVENT_PTP_TIME_MINOR_26_19_LBN 36
 #define       MCDI_EVENT_PTP_TIME_MINOR_26_19_WIDTH 8
+/* For CODE_PTP_TIME events where report sync status is enabled, indicates
+ * whether the NIC clock has ever been set
+ */
+#define       MCDI_EVENT_PTP_TIME_NIC_CLOCK_VALID_LBN 36
+#define       MCDI_EVENT_PTP_TIME_NIC_CLOCK_VALID_WIDTH 1
+/* For CODE_PTP_TIME events where report sync status is enabled, indicates
+ * whether the NIC and System clocks are in sync
+ */
+#define       MCDI_EVENT_PTP_TIME_HOST_NIC_IN_SYNC_LBN 37
+#define       MCDI_EVENT_PTP_TIME_HOST_NIC_IN_SYNC_WIDTH 1
+/* For CODE_PTP_TIME events where report sync status is enabled, bits 21-26 of
+ * the minor value of the PTP clock
+ */
+#define       MCDI_EVENT_PTP_TIME_MINOR_26_21_LBN 38
+#define       MCDI_EVENT_PTP_TIME_MINOR_26_21_WIDTH 6
+#define       MCDI_EVENT_PROXY_REQUEST_BUFF_INDEX_OFST 0
+#define       MCDI_EVENT_PROXY_REQUEST_BUFF_INDEX_LBN 0
+#define       MCDI_EVENT_PROXY_REQUEST_BUFF_INDEX_WIDTH 32
+#define       MCDI_EVENT_PROXY_RESPONSE_HANDLE_OFST 0
+#define       MCDI_EVENT_PROXY_RESPONSE_HANDLE_LBN 0
+#define       MCDI_EVENT_PROXY_RESPONSE_HANDLE_WIDTH 32
+/* Zero means that the request has been completed or authorized, and the driver
+ * should resend it. A non-zero value means that the authorization has been
+ * denied, and gives the reason. Typically it will be EPERM.
+ */
+#define       MCDI_EVENT_PROXY_RESPONSE_RC_LBN 36
+#define       MCDI_EVENT_PROXY_RESPONSE_RC_WIDTH 8
 
 /* FCDI_EVENT structuredef */
 #define    FCDI_EVENT_LEN 8
@@ -581,6 +682,10 @@
 #define          FCDI_EVENT_CODE_PTP_TICK 0x7
 /* enum: ECC error counters */
 #define          FCDI_EVENT_CODE_DDR_ECC_STATUS 0x8
+/* enum: Current status of PTP */
+#define          FCDI_EVENT_CODE_PTP_STATUS 0x9
+/* enum: Port id config to map MC-FC port idx */
+#define          FCDI_EVENT_CODE_PORT_CONFIG 0xa
 #define       FCDI_EVENT_ASSERT_INSTR_ADDRESS_OFST 0
 #define       FCDI_EVENT_ASSERT_INSTR_ADDRESS_LBN 0
 #define       FCDI_EVENT_ASSERT_INSTR_ADDRESS_WIDTH 32
@@ -594,11 +699,24 @@
 #define       FCDI_EVENT_LINK_STATE_DATA_OFST 0
 #define       FCDI_EVENT_LINK_STATE_DATA_LBN 0
 #define       FCDI_EVENT_LINK_STATE_DATA_WIDTH 32
+#define       FCDI_EVENT_PTP_STATE_OFST 0
+#define          FCDI_EVENT_PTP_UNDEFINED 0x0 /* enum */
+#define          FCDI_EVENT_PTP_SETUP_FAILED 0x1 /* enum */
+#define          FCDI_EVENT_PTP_OPERATIONAL 0x2 /* enum */
+#define       FCDI_EVENT_PTP_STATE_LBN 0
+#define       FCDI_EVENT_PTP_STATE_WIDTH 32
 #define       FCDI_EVENT_DDR_ECC_STATUS_BANK_ID_LBN 36
 #define       FCDI_EVENT_DDR_ECC_STATUS_BANK_ID_WIDTH 8
 #define       FCDI_EVENT_DDR_ECC_STATUS_STATUS_OFST 0
 #define       FCDI_EVENT_DDR_ECC_STATUS_STATUS_LBN 0
 #define       FCDI_EVENT_DDR_ECC_STATUS_STATUS_WIDTH 32
+/* Index of MC port being referred to */
+#define       FCDI_EVENT_PORT_CONFIG_SRC_LBN 36
+#define       FCDI_EVENT_PORT_CONFIG_SRC_WIDTH 8
+/* FC Port index that matches the MC port index in SRC */
+#define       FCDI_EVENT_PORT_CONFIG_DATA_OFST 0
+#define       FCDI_EVENT_PORT_CONFIG_DATA_LBN 0
+#define       FCDI_EVENT_PORT_CONFIG_DATA_WIDTH 32
 
 /* FCDI_EXTENDED_EVENT_PPS structuredef: Extended FCDI event to send PPS events
  * to the MC. Note that this structure | is overlayed over a normal FCDI event
@@ -631,6 +749,90 @@
 #define       FCDI_EXTENDED_EVENT_PPS_TIMESTAMPS_LBN 64
 #define       FCDI_EXTENDED_EVENT_PPS_TIMESTAMPS_WIDTH 64
 
+/* MUM_EVENT structuredef */
+#define    MUM_EVENT_LEN 8
+#define       MUM_EVENT_CONT_LBN 32
+#define       MUM_EVENT_CONT_WIDTH 1
+#define       MUM_EVENT_LEVEL_LBN 33
+#define       MUM_EVENT_LEVEL_WIDTH 3
+/* enum: Info. */
+#define          MUM_EVENT_LEVEL_INFO  0x0
+/* enum: Warning. */
+#define          MUM_EVENT_LEVEL_WARN 0x1
+/* enum: Error. */
+#define          MUM_EVENT_LEVEL_ERR 0x2
+/* enum: Fatal. */
+#define          MUM_EVENT_LEVEL_FATAL 0x3
+#define       MUM_EVENT_DATA_OFST 0
+#define        MUM_EVENT_SENSOR_ID_LBN 0
+#define        MUM_EVENT_SENSOR_ID_WIDTH 8
+/*             Enum values, see field(s): */
+/*                MC_CMD_SENSOR_INFO/MC_CMD_SENSOR_INFO_OUT/MASK */
+#define        MUM_EVENT_SENSOR_STATE_LBN 8
+#define        MUM_EVENT_SENSOR_STATE_WIDTH 8
+#define        MUM_EVENT_PORT_PHY_READY_LBN 0
+#define        MUM_EVENT_PORT_PHY_READY_WIDTH 1
+#define        MUM_EVENT_PORT_PHY_LINK_UP_LBN 1
+#define        MUM_EVENT_PORT_PHY_LINK_UP_WIDTH 1
+#define        MUM_EVENT_PORT_PHY_TX_LOL_LBN 2
+#define        MUM_EVENT_PORT_PHY_TX_LOL_WIDTH 1
+#define        MUM_EVENT_PORT_PHY_RX_LOL_LBN 3
+#define        MUM_EVENT_PORT_PHY_RX_LOL_WIDTH 1
+#define        MUM_EVENT_PORT_PHY_TX_LOS_LBN 4
+#define        MUM_EVENT_PORT_PHY_TX_LOS_WIDTH 1
+#define        MUM_EVENT_PORT_PHY_RX_LOS_LBN 5
+#define        MUM_EVENT_PORT_PHY_RX_LOS_WIDTH 1
+#define        MUM_EVENT_PORT_PHY_TX_FAULT_LBN 6
+#define        MUM_EVENT_PORT_PHY_TX_FAULT_WIDTH 1
+#define       MUM_EVENT_DATA_LBN 0
+#define       MUM_EVENT_DATA_WIDTH 32
+#define       MUM_EVENT_SRC_LBN 36
+#define       MUM_EVENT_SRC_WIDTH 8
+#define       MUM_EVENT_EV_CODE_LBN 60
+#define       MUM_EVENT_EV_CODE_WIDTH 4
+#define       MUM_EVENT_CODE_LBN 44
+#define       MUM_EVENT_CODE_WIDTH 8
+/* enum: The MUM was rebooted. */
+#define          MUM_EVENT_CODE_REBOOT 0x1
+/* enum: Bad assert. */
+#define          MUM_EVENT_CODE_ASSERT 0x2
+/* enum: Sensor failure. */
+#define          MUM_EVENT_CODE_SENSOR 0x3
+/* enum: Link fault has been asserted, or has cleared. */
+#define          MUM_EVENT_CODE_QSFP_LASI_INTERRUPT 0x4
+#define       MUM_EVENT_SENSOR_DATA_OFST 0
+#define       MUM_EVENT_SENSOR_DATA_LBN 0
+#define       MUM_EVENT_SENSOR_DATA_WIDTH 32
+#define       MUM_EVENT_PORT_PHY_FLAGS_OFST 0
+#define       MUM_EVENT_PORT_PHY_FLAGS_LBN 0
+#define       MUM_EVENT_PORT_PHY_FLAGS_WIDTH 32
+#define       MUM_EVENT_PORT_PHY_COPPER_LEN_OFST 0
+#define       MUM_EVENT_PORT_PHY_COPPER_LEN_LBN 0
+#define       MUM_EVENT_PORT_PHY_COPPER_LEN_WIDTH 32
+#define       MUM_EVENT_PORT_PHY_CAPS_OFST 0
+#define       MUM_EVENT_PORT_PHY_CAPS_LBN 0
+#define       MUM_EVENT_PORT_PHY_CAPS_WIDTH 32
+#define       MUM_EVENT_PORT_PHY_TECH_OFST 0
+#define          MUM_EVENT_PORT_PHY_STATE_QSFP_MODULE_TECH_UNKNOWN 0x0 /* enum */
+#define          MUM_EVENT_PORT_PHY_STATE_QSFP_MODULE_TECH_OPTICAL 0x1 /* enum */
+#define          MUM_EVENT_PORT_PHY_STATE_QSFP_MODULE_TECH_COPPER_PASSIVE 0x2 /* enum */
+#define          MUM_EVENT_PORT_PHY_STATE_QSFP_MODULE_TECH_COPPER_PASSIVE_EQUALIZED 0x3 /* enum */
+#define          MUM_EVENT_PORT_PHY_STATE_QSFP_MODULE_TECH_COPPER_ACTIVE_LIMITING 0x4 /* enum */
+#define          MUM_EVENT_PORT_PHY_STATE_QSFP_MODULE_TECH_COPPER_ACTIVE_LINEAR 0x5 /* enum */
+#define          MUM_EVENT_PORT_PHY_STATE_QSFP_MODULE_TECH_BASE_T 0x6 /* enum */
+#define          MUM_EVENT_PORT_PHY_STATE_QSFP_MODULE_TECH_LOOPBACK_PASSIVE 0x7 /* enum */
+#define       MUM_EVENT_PORT_PHY_TECH_LBN 0
+#define       MUM_EVENT_PORT_PHY_TECH_WIDTH 32
+#define       MUM_EVENT_PORT_PHY_SRC_DATA_ID_LBN 36
+#define       MUM_EVENT_PORT_PHY_SRC_DATA_ID_WIDTH 4
+#define          MUM_EVENT_PORT_PHY_SRC_DATA_ID_FLAGS 0x0 /* enum */
+#define          MUM_EVENT_PORT_PHY_SRC_DATA_ID_COPPER_LEN 0x1 /* enum */
+#define          MUM_EVENT_PORT_PHY_SRC_DATA_ID_CAPS 0x2 /* enum */
+#define          MUM_EVENT_PORT_PHY_SRC_DATA_ID_TECH 0x3 /* enum */
+#define          MUM_EVENT_PORT_PHY_SRC_DATA_ID_MAX 0x4 /* enum */
+#define       MUM_EVENT_PORT_PHY_SRC_PORT_NO_LBN 40
+#define       MUM_EVENT_PORT_PHY_SRC_PORT_NO_WIDTH 4
+
 
 /***********************************/
 /* MC_CMD_READ32
@@ -687,24 +889,34 @@
 
 /* MC_CMD_COPYCODE_IN msgrequest */
 #define    MC_CMD_COPYCODE_IN_LEN 16
-/* Source address */
-#define       MC_CMD_COPYCODE_IN_SRC_ADDR_OFST 0
-/* enum: The main image should be entered via a copy of a single word from and
- * to this address when none of the other magic behaviours are required.
+/* Source address
+ *
+ * The main image should be entered via a copy of a single word from and to a
+ * magic address, which controls various aspects of the boot. The magic address
+ * is a bitfield, with each bit as documented below.
  */
+#define       MC_CMD_COPYCODE_IN_SRC_ADDR_OFST 0
+/* enum: Deprecated; equivalent to setting BOOT_MAGIC_PRESENT (see below) */
 #define          MC_CMD_COPYCODE_HUNT_NO_MAGIC_ADDR 0x10000
-/* enum: Entering the main image via a copy of a single word from and to this
- * address indicates that it should not attempt to start the datapath CPUs.
- * This is useful for certain soft rebooting scenarios. (Huntington only)
+/* enum: Deprecated; equivalent to setting BOOT_MAGIC_PRESENT and
+ * BOOT_MAGIC_SATELLITE_CPUS_NOT_LOADED (see below)
  */
 #define          MC_CMD_COPYCODE_HUNT_NO_DATAPATH_MAGIC_ADDR 0x1d0d0
-/* enum: Entering the main image via a copy of a single word from and to this
- * address indicates that it should not attempt to parse any configuration from
- * flash. (In addition, the datapath CPUs will not be started, as for
- * MC_CMD_COPYCODE_HUNT_NO_DATAPATH_MAGIC_ADDR above.) This is useful for
- * certain soft rebooting scenarios. (Huntington only)
+/* enum: Deprecated; equivalent to setting BOOT_MAGIC_PRESENT,
+ * BOOT_MAGIC_SATELLITE_CPUS_NOT_LOADED and BOOT_MAGIC_IGNORE_CONFIG (see
+ * below)
  */
 #define          MC_CMD_COPYCODE_HUNT_IGNORE_CONFIG_MAGIC_ADDR 0x1badc
+#define        MC_CMD_COPYCODE_IN_BOOT_MAGIC_PRESENT_LBN 17
+#define        MC_CMD_COPYCODE_IN_BOOT_MAGIC_PRESENT_WIDTH 1
+#define        MC_CMD_COPYCODE_IN_BOOT_MAGIC_SATELLITE_CPUS_NOT_LOADED_LBN 2
+#define        MC_CMD_COPYCODE_IN_BOOT_MAGIC_SATELLITE_CPUS_NOT_LOADED_WIDTH 1
+#define        MC_CMD_COPYCODE_IN_BOOT_MAGIC_IGNORE_CONFIG_LBN 3
+#define        MC_CMD_COPYCODE_IN_BOOT_MAGIC_IGNORE_CONFIG_WIDTH 1
+#define        MC_CMD_COPYCODE_IN_BOOT_MAGIC_SKIP_BOOT_ICORE_SYNC_LBN 4
+#define        MC_CMD_COPYCODE_IN_BOOT_MAGIC_SKIP_BOOT_ICORE_SYNC_WIDTH 1
+#define        MC_CMD_COPYCODE_IN_BOOT_MAGIC_FORCE_STANDALONE_LBN 5
+#define        MC_CMD_COPYCODE_IN_BOOT_MAGIC_FORCE_STANDALONE_WIDTH 1
 /* Destination address */
 #define       MC_CMD_COPYCODE_IN_DEST_ADDR_OFST 4
 #define       MC_CMD_COPYCODE_IN_NUMWORDS_OFST 8
@@ -795,6 +1007,10 @@
 #define       MC_CMD_GET_ASSERTS_OUT_GP_REGS_OFFS_OFST 8
 #define       MC_CMD_GET_ASSERTS_OUT_GP_REGS_OFFS_LEN 4
 #define       MC_CMD_GET_ASSERTS_OUT_GP_REGS_OFFS_NUM 31
+/* enum: A magic value hinting that the value in this register at the time of
+ * the failure has likely been lost.
+ */
+#define          MC_CMD_GET_ASSERTS_REG_NO_DATA 0xda7a1057
 /* Failing thread address */
 #define       MC_CMD_GET_ASSERTS_OUT_THREAD_OFFS_OFST 132
 #define       MC_CMD_GET_ASSERTS_OUT_RESERVED_OFST 136
@@ -802,7 +1018,8 @@
 
 /***********************************/
 /* MC_CMD_LOG_CTRL
- * Configure the output stream for various events and messages.
+ * Configure the output stream for log events such as link state changes,
+ * sensor notifications and MCDI completions
  */
 #define MC_CMD_LOG_CTRL 0x7
 
@@ -816,6 +1033,7 @@
 #define          MC_CMD_LOG_CTRL_IN_LOG_DEST_UART 0x1
 /* enum: Event queue. */
 #define          MC_CMD_LOG_CTRL_IN_LOG_DEST_EVQ 0x2
+/* Legacy argument. Must be zero. */
 #define       MC_CMD_LOG_CTRL_IN_LOG_DEST_EVQ_OFST 4
 
 /* MC_CMD_LOG_CTRL_OUT msgresponse */
@@ -955,8 +1173,12 @@
  * input on the same NIC.
  */
 #define          MC_CMD_PTP_OP_MANFTEST_PPS 0x1a
+/* enum: Set the PTP sync status. Status is used by firmware to report to event
+ * subscribers.
+ */
+#define          MC_CMD_PTP_OP_SET_SYNC_STATUS 0x1b
 /* enum: Above this for future use. */
-#define          MC_CMD_PTP_OP_MAX 0x1b
+#define          MC_CMD_PTP_OP_MAX 0x1c
 
 /* MC_CMD_PTP_IN_ENABLE msgrequest */
 #define    MC_CMD_PTP_IN_ENABLE_LEN 16
@@ -1191,8 +1413,12 @@
 #define    MC_CMD_PTP_IN_TIME_EVENT_SUBSCRIBE_LEN 12
 /*            MC_CMD_PTP_IN_CMD_OFST 0 */
 /*            MC_CMD_PTP_IN_PERIPH_ID_OFST 4 */
-/* Event queue to send PTP time events to */
+/* Original field containing queue ID. Now extended to include flags. */
 #define       MC_CMD_PTP_IN_TIME_EVENT_SUBSCRIBE_QUEUE_OFST 8
+#define        MC_CMD_PTP_IN_TIME_EVENT_SUBSCRIBE_QUEUE_ID_LBN 0
+#define        MC_CMD_PTP_IN_TIME_EVENT_SUBSCRIBE_QUEUE_ID_WIDTH 16
+#define        MC_CMD_PTP_IN_TIME_EVENT_SUBSCRIBE_REPORT_SYNC_STATUS_LBN 31
+#define        MC_CMD_PTP_IN_TIME_EVENT_SUBSCRIBE_REPORT_SYNC_STATUS_WIDTH 1
 
 /* MC_CMD_PTP_IN_TIME_EVENT_UNSUBSCRIBE msgrequest */
 #define    MC_CMD_PTP_IN_TIME_EVENT_UNSUBSCRIBE_LEN 16
@@ -1214,6 +1440,23 @@
 /* 1 to enable PPS test mode, 0 to disable and return result. */
 #define       MC_CMD_PTP_IN_MANFTEST_PPS_TEST_ENABLE_OFST 8
 
+/* MC_CMD_PTP_IN_SET_SYNC_STATUS msgrequest */
+#define    MC_CMD_PTP_IN_SET_SYNC_STATUS_LEN 24
+/*            MC_CMD_PTP_IN_CMD_OFST 0 */
+/*            MC_CMD_PTP_IN_PERIPH_ID_OFST 4 */
+/* NIC - Host System Clock Synchronization status */
+#define       MC_CMD_PTP_IN_SET_SYNC_STATUS_STATUS_OFST 8
+/* enum: Host System clock and NIC clock are not in sync */
+#define          MC_CMD_PTP_IN_SET_SYNC_STATUS_NOT_IN_SYNC 0x0
+/* enum: Host System clock and NIC clock are synchronized */
+#define          MC_CMD_PTP_IN_SET_SYNC_STATUS_IN_SYNC 0x1
+/* If synchronized, number of seconds until clocks should be considered to be
+ * no longer in sync.
+ */
+#define       MC_CMD_PTP_IN_SET_SYNC_STATUS_TIMEOUT_OFST 12
+#define       MC_CMD_PTP_IN_SET_SYNC_STATUS_RESERVED0_OFST 16
+#define       MC_CMD_PTP_IN_SET_SYNC_STATUS_RESERVED1_OFST 20
+
 /* MC_CMD_PTP_OUT msgresponse */
 #define    MC_CMD_PTP_OUT_LEN 0
 
@@ -1375,7 +1618,7 @@
 #define          MC_CMD_PTP_OUT_GET_TIME_FORMAT_SECONDS_27FRACTION 0x2
 
 /* MC_CMD_PTP_OUT_GET_ATTRIBUTES msgresponse */
-#define    MC_CMD_PTP_OUT_GET_ATTRIBUTES_LEN 8
+#define    MC_CMD_PTP_OUT_GET_ATTRIBUTES_LEN 24
 /* Time format required/used by for this NIC. Applies to all PTP MCDI
  * operations that pass times between the host and firmware. If this operation
  * is not supported (older firmware) a format of seconds and nanoseconds should
@@ -1396,6 +1639,13 @@
  * end and start times minus the time that the MC waited for host end.
  */
 #define       MC_CMD_PTP_OUT_GET_ATTRIBUTES_SYNC_WINDOW_MIN_OFST 4
+/* Various PTP capabilities */
+#define       MC_CMD_PTP_OUT_GET_ATTRIBUTES_CAPABILITIES_OFST 8
+#define        MC_CMD_PTP_OUT_GET_ATTRIBUTES_REPORT_SYNC_STATUS_LBN 0
+#define        MC_CMD_PTP_OUT_GET_ATTRIBUTES_REPORT_SYNC_STATUS_WIDTH 1
+#define       MC_CMD_PTP_OUT_GET_ATTRIBUTES_RESERVED0_OFST 12
+#define       MC_CMD_PTP_OUT_GET_ATTRIBUTES_RESERVED1_OFST 16
+#define       MC_CMD_PTP_OUT_GET_ATTRIBUTES_RESERVED2_OFST 20
 
 /* MC_CMD_PTP_OUT_GET_TIMESTAMP_CORRECTIONS msgresponse */
 #define    MC_CMD_PTP_OUT_GET_TIMESTAMP_CORRECTIONS_LEN 16
@@ -1415,6 +1665,9 @@
 /*            Enum values, see field(s): */
 /*               MC_CMD_PTP_OUT_MANFTEST_BASIC/TEST_RESULT */
 
+/* MC_CMD_PTP_OUT_SET_SYNC_STATUS msgresponse */
+#define    MC_CMD_PTP_OUT_SET_SYNC_STATUS_LEN 0
+
 
 /***********************************/
 /* MC_CMD_CSR_READ32
@@ -1915,6 +2168,14 @@
 #define          MC_CMD_FW_FULL_FEATURED 0x0
 /* enum: Prefer to use firmware with fewer features but lower latency */
 #define          MC_CMD_FW_LOW_LATENCY 0x1
+/* enum: Prefer to use firmware for SolarCapture packed stream mode */
+#define          MC_CMD_FW_PACKED_STREAM 0x2
+/* enum: Prefer to use firmware with fewer features and simpler TX event
+ * batching but higher TX packet rate
+ */
+#define          MC_CMD_FW_HIGH_TX_RATE 0x3
+/* enum: Reserved value */
+#define          MC_CMD_FW_PACKED_STREAM_HASH_MODE_1 0x4
 /* enum: Only this option is allowed for non-admin functions */
 #define          MC_CMD_FW_DONT_CARE  0xffffffff
 
@@ -2481,6 +2742,12 @@
 #define          MC_CMD_LOOPBACK_SD_FES_WS  0x22
 /* enum: Near side of AOE Siena side port */
 #define          MC_CMD_LOOPBACK_AOE_INT_NEAR  0x23
+/* enum: Medford Wireside datapath loopback */
+#define          MC_CMD_LOOPBACK_DATA_WS  0x24
+/* enum: Force link up without setting up any physical loopback (snapper use
+ * only)
+ */
+#define          MC_CMD_LOOPBACK_FORCE_EXT_LINK  0x25
 /* Supported loopbacks. */
 #define       MC_CMD_GET_LOOPBACK_MODES_OUT_1G_OFST 8
 #define       MC_CMD_GET_LOOPBACK_MODES_OUT_1G_LEN 8
@@ -2552,12 +2819,8 @@
 #define        MC_CMD_GET_LINK_OUT_LINK_FAULT_TX_WIDTH 1
 /* This returns the negotiated flow control value. */
 #define       MC_CMD_GET_LINK_OUT_FCNTL_OFST 20
-/* enum: Flow control is off. */
-#define          MC_CMD_FCNTL_OFF 0x0
-/* enum: Respond to flow control. */
-#define          MC_CMD_FCNTL_RESPOND 0x1
-/* enum: Respond to and Issue flow control. */
-#define          MC_CMD_FCNTL_BIDIR 0x2
+/*            Enum values, see field(s): */
+/*               MC_CMD_SET_MAC/MC_CMD_SET_MAC_IN/FCNTL */
 #define       MC_CMD_GET_LINK_OUT_MAC_FAULT_OFST 24
 #define        MC_CMD_MAC_FAULT_XGMII_LOCAL_LBN 0
 #define        MC_CMD_MAC_FAULT_XGMII_LOCAL_WIDTH 1
@@ -2632,7 +2895,7 @@
 #define MC_CMD_0x2c_PRIVILEGE_CTG SRIOV_CTG_LINK
 
 /* MC_CMD_SET_MAC_IN msgrequest */
-#define    MC_CMD_SET_MAC_IN_LEN 24
+#define    MC_CMD_SET_MAC_IN_LEN 28
 /* The MTU is the MTU programmed directly into the XMAC/GMAC (inclusive of
  * EtherII, VLAN, bug16011 padding).
  */
@@ -2649,13 +2912,20 @@
 #define        MC_CMD_SET_MAC_IN_REJECT_BRDCST_WIDTH 1
 #define       MC_CMD_SET_MAC_IN_FCNTL_OFST 20
 /* enum: Flow control is off. */
-/*               MC_CMD_FCNTL_OFF 0x0 */
+#define          MC_CMD_FCNTL_OFF 0x0
 /* enum: Respond to flow control. */
-/*               MC_CMD_FCNTL_RESPOND 0x1 */
+#define          MC_CMD_FCNTL_RESPOND 0x1
 /* enum: Respond to and Issue flow control. */
-/*               MC_CMD_FCNTL_BIDIR 0x2 */
+#define          MC_CMD_FCNTL_BIDIR 0x2
 /* enum: Auto neg flow control. */
 #define          MC_CMD_FCNTL_AUTO 0x3
+/* enum: Priority flow control (eftest builds only). */
+#define          MC_CMD_FCNTL_QBB 0x4
+/* enum: Issue flow control. */
+#define          MC_CMD_FCNTL_GENERATE 0x5
+#define       MC_CMD_SET_MAC_IN_FLAGS_OFST 24
+#define        MC_CMD_SET_MAC_IN_FLAG_INCLUDE_FCS_LBN 0
+#define        MC_CMD_SET_MAC_IN_FLAG_INCLUDE_FCS_WIDTH 1
 
 /* MC_CMD_SET_MAC_OUT msgresponse */
 #define    MC_CMD_SET_MAC_OUT_LEN 0
@@ -2748,7 +3018,8 @@
  * guarantee consistent results. If the DMA_ADDR is 0, then no DMA is
  * performed, and the statistics may be read from the message response. If
  * DMA_ADDR != 0, then the statistics are dmad to that (page-aligned location).
- * Locks required: None. Returns: 0, ETIME
+ * Locks required: None. The PERIODIC_CLEAR option is not used and now has no
+ * effect. Returns: 0, ETIME
  */
 #define MC_CMD_MAC_STATS 0x2e
 
@@ -2791,6 +3062,7 @@
 #define       MC_CMD_MAC_STATS_OUT_NO_DMA_STATISTICS_HI_OFST 4
 #define       MC_CMD_MAC_STATS_OUT_NO_DMA_STATISTICS_NUM MC_CMD_MAC_NSTATS
 #define          MC_CMD_MAC_GENERATION_START  0x0 /* enum */
+#define          MC_CMD_MAC_DMABUF_START  0x1 /* enum */
 #define          MC_CMD_MAC_TX_PKTS  0x1 /* enum */
 #define          MC_CMD_MAC_TX_PAUSE_PKTS  0x2 /* enum */
 #define          MC_CMD_MAC_TX_CONTROL_PKTS  0x3 /* enum */
@@ -2890,8 +3162,8 @@
  * PM_AND_RXDP_COUNTERS capability only.
  */
 #define          MC_CMD_MAC_RXDP_STREAMING_PKTS  0x46
-/* enum: RXDP counter: Number of times an emergency descriptor fetch was
- * performed. Valid for EF10 with PM_AND_RXDP_COUNTERS capability only.
+/* enum: RXDP counter: Number of times an hlb descriptor fetch was performed.
+ * Valid for EF10 with PM_AND_RXDP_COUNTERS capability only.
  */
 #define          MC_CMD_MAC_RXDP_HLB_FETCH_CONDITIONS  0x47
 /* enum: RXDP counter: Number of times the DPCPU waited for an existing
@@ -3213,6 +3485,8 @@
 #define          MC_CMD_NVRAM_TYPE_LICENSE 0x12
 /* enum: FC Log. */
 #define          MC_CMD_NVRAM_TYPE_FC_LOG 0x13
+/* enum: Additional flash on FPGA. */
+#define          MC_CMD_NVRAM_TYPE_FC_EXTRA 0x14
 
 
 /***********************************/
@@ -3407,6 +3681,8 @@
  */
 #define MC_CMD_SCHEDINFO 0x3e
 
+#define MC_CMD_0x3e_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
 /* MC_CMD_SCHEDINFO_IN msgrequest */
 #define    MC_CMD_SCHEDINFO_IN_LEN 0
 
@@ -3593,6 +3869,68 @@
 #define          MC_CMD_SENSOR_VDD08D_VSS08D_CSR_EXTADC  0x2c
 /* enum: Hotpoint temperature: degC */
 #define          MC_CMD_SENSOR_HOTPOINT_TEMP  0x2d
+/* enum: Port 0 PHY power switch over-current: bool */
+#define          MC_CMD_SENSOR_PHY_POWER_PORT0  0x2e
+/* enum: Port 1 PHY power switch over-current: bool */
+#define          MC_CMD_SENSOR_PHY_POWER_PORT1  0x2f
+/* enum: Mop-up microcontroller reference voltage (millivolts) */
+#define          MC_CMD_SENSOR_MUM_VCC  0x30
+/* enum: 0.9v power phase A voltage: mV */
+#define          MC_CMD_SENSOR_IN_0V9_A  0x31
+/* enum: 0.9v power phase A current: mA */
+#define          MC_CMD_SENSOR_IN_I0V9_A  0x32
+/* enum: 0.9V voltage regulator phase A temperature: degC */
+#define          MC_CMD_SENSOR_VREG_0V9_A_TEMP  0x33
+/* enum: 0.9v power phase B voltage: mV */
+#define          MC_CMD_SENSOR_IN_0V9_B  0x34
+/* enum: 0.9v power phase B current: mA */
+#define          MC_CMD_SENSOR_IN_I0V9_B  0x35
+/* enum: 0.9V voltage regulator phase B temperature: degC */
+#define          MC_CMD_SENSOR_VREG_0V9_B_TEMP  0x36
+/* enum: CCOM AVREG 1v2 supply (interval ADC): mV */
+#define          MC_CMD_SENSOR_CCOM_AVREG_1V2_SUPPLY  0x37
+/* enum: CCOM AVREG 1v2 supply (external ADC): mV */
+#define          MC_CMD_SENSOR_CCOM_AVREG_1V2_SUPPLY_EXTADC  0x38
+/* enum: CCOM AVREG 1v8 supply (interval ADC): mV */
+#define          MC_CMD_SENSOR_CCOM_AVREG_1V8_SUPPLY  0x39
+/* enum: CCOM AVREG 1v8 supply (external ADC): mV */
+#define          MC_CMD_SENSOR_CCOM_AVREG_1V8_SUPPLY_EXTADC  0x3a
+/* enum: Not a sensor: reserved for the next page flag */
+#define          MC_CMD_SENSOR_PAGE1_NEXT  0x3f
+/* enum: controller internal temperature sensor voltage on master core
+ * (internal ADC): mV
+ */
+#define          MC_CMD_SENSOR_CONTROLLER_MASTER_VPTAT  0x40
+/* enum: controller internal temperature on master core (internal ADC): degC */
+#define          MC_CMD_SENSOR_CONTROLLER_MASTER_INTERNAL_TEMP  0x41
+/* enum: controller internal temperature sensor voltage on master core
+ * (external ADC): mV
+ */
+#define          MC_CMD_SENSOR_CONTROLLER_MASTER_VPTAT_EXTADC  0x42
+/* enum: controller internal temperature on master core (external ADC): degC */
+#define          MC_CMD_SENSOR_CONTROLLER_MASTER_INTERNAL_TEMP_EXTADC  0x43
+/* enum: controller internal temperature on slave core sensor voltage (internal
+ * ADC): mV
+ */
+#define          MC_CMD_SENSOR_CONTROLLER_SLAVE_VPTAT  0x44
+/* enum: controller internal temperature on slave core (internal ADC): degC */
+#define          MC_CMD_SENSOR_CONTROLLER_SLAVE_INTERNAL_TEMP  0x45
+/* enum: controller internal temperature on slave core sensor voltage (external
+ * ADC): mV
+ */
+#define          MC_CMD_SENSOR_CONTROLLER_SLAVE_VPTAT_EXTADC  0x46
+/* enum: controller internal temperature on slave core (external ADC): degC */
+#define          MC_CMD_SENSOR_CONTROLLER_SLAVE_INTERNAL_TEMP_EXTADC  0x47
+/* enum: Voltage supplied to the SODIMMs from their power supply: mV */
+#define          MC_CMD_SENSOR_SODIMM_VOUT  0x49
+/* enum: Temperature of SODIMM 0 (if installed): degC */
+#define          MC_CMD_SENSOR_SODIMM_0_TEMP  0x4a
+/* enum: Temperature of SODIMM 1 (if installed): degC */
+#define          MC_CMD_SENSOR_SODIMM_1_TEMP  0x4b
+/* enum: Voltage supplied to the QSFP #0 from their power supply: mV */
+#define          MC_CMD_SENSOR_PHY0_VCC  0x4c
+/* enum: Voltage supplied to the QSFP #1 from their power supply: mV */
+#define          MC_CMD_SENSOR_PHY1_VCC  0x4d
 /* MC_CMD_SENSOR_INFO_ENTRY_TYPEDEF */
 #define       MC_CMD_SENSOR_ENTRY_OFST 4
 #define       MC_CMD_SENSOR_ENTRY_LEN 8
@@ -3701,6 +4039,8 @@
 #define          MC_CMD_SENSOR_STATE_BROKEN  0x3
 /* enum: Sensor is working but does not currently have a reading. */
 #define          MC_CMD_SENSOR_STATE_NO_READING  0x4
+/* enum: Sensor initialisation failed. */
+#define          MC_CMD_SENSOR_STATE_INIT_FAILED  0x5
 #define       MC_CMD_SENSOR_VALUE_ENTRY_TYPEDEF_STATE_LBN 16
 #define       MC_CMD_SENSOR_VALUE_ENTRY_TYPEDEF_STATE_WIDTH 8
 #define       MC_CMD_SENSOR_VALUE_ENTRY_TYPEDEF_TYPE_OFST 3
@@ -3870,6 +4210,7 @@
 
 /* MC_CMD_WORKAROUND_IN msgrequest */
 #define    MC_CMD_WORKAROUND_IN_LEN 8
+/* The enums here must correspond with those in MC_CMD_GET_WORKAROUND. */
 #define       MC_CMD_WORKAROUND_IN_TYPE_OFST 0
 /* enum: Bug 17230 work around. */
 #define          MC_CMD_WORKAROUND_BUG17230 0x1
@@ -3877,11 +4218,38 @@
 #define          MC_CMD_WORKAROUND_BUG35388 0x2
 /* enum: Bug35017 workaround (A64 tables must be identity map) */
 #define          MC_CMD_WORKAROUND_BUG35017 0x3
+/* enum: Bug 41750 present (MC_CMD_TRIGGER_INTERRUPT won't work) */
+#define          MC_CMD_WORKAROUND_BUG41750 0x4
+/* enum: Bug 42008 present (Interrupts can overtake associated events). Caution
+ * - before adding code that queries this workaround, remember that there's
+ * released Monza firmware that doesn't understand MC_CMD_WORKAROUND_BUG42008,
+ * and will hence (incorrectly) report that the bug doesn't exist.
+ */
+#define          MC_CMD_WORKAROUND_BUG42008 0x5
+/* enum: Bug 26807 features present in firmware (multicast filter chaining)
+ * This feature cannot be turned on/off while there are any filters already
+ * present. The behaviour in such case depends on the acting client's privilege
+ * level. If the client has the admin privilege, then all functions that have
+ * filters installed will be FLRed and the FLR_DONE flag will be set. Otherwise
+ * the command will fail with MC_CMD_ERR_FILTERS_PRESENT.
+ */
+#define          MC_CMD_WORKAROUND_BUG26807 0x6
+/* 0 = disable the workaround indicated by TYPE; any non-zero value = enable
+ * the workaround
+ */
 #define       MC_CMD_WORKAROUND_IN_ENABLED_OFST 4
 
 /* MC_CMD_WORKAROUND_OUT msgresponse */
 #define    MC_CMD_WORKAROUND_OUT_LEN 0
 
+/* MC_CMD_WORKAROUND_EXT_OUT msgresponse: This response format will be used
+ * when (TYPE == MC_CMD_WORKAROUND_BUG26807)
+ */
+#define    MC_CMD_WORKAROUND_EXT_OUT_LEN 4
+#define       MC_CMD_WORKAROUND_EXT_OUT_FLAGS_OFST 0
+#define        MC_CMD_WORKAROUND_EXT_OUT_FLR_DONE_LBN 0
+#define        MC_CMD_WORKAROUND_EXT_OUT_FLR_DONE_WIDTH 1
+
 
 /***********************************/
 /* MC_CMD_GET_PHY_MEDIA_INFO
@@ -4093,7 +4461,7 @@
 
 /***********************************/
 /* MC_CMD_GET_MAC_ADDRESSES
- * Returns the base MAC, count and stride for the requestiong function
+ * Returns the base MAC, count and stride for the requesting function
  */
 #define MC_CMD_GET_MAC_ADDRESSES 0x55
 
@@ -4115,6 +4483,527 @@
 /* Spacing of allocated MAC addresses */
 #define       MC_CMD_GET_MAC_ADDRESSES_OUT_MAC_STRIDE_OFST 12
 
+
+/***********************************/
+/* MC_CMD_CLP
+ * Perform a CLP related operation
+ */
+#define MC_CMD_CLP 0x56
+
+#define MC_CMD_0x56_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
+/* MC_CMD_CLP_IN msgrequest */
+#define    MC_CMD_CLP_IN_LEN 4
+/* Sub operation */
+#define       MC_CMD_CLP_IN_OP_OFST 0
+/* enum: Return to factory default settings */
+#define          MC_CMD_CLP_OP_DEFAULT 0x1
+/* enum: Set MAC address */
+#define          MC_CMD_CLP_OP_SET_MAC 0x2
+/* enum: Get MAC address */
+#define          MC_CMD_CLP_OP_GET_MAC 0x3
+/* enum: Set UEFI/GPXE boot mode */
+#define          MC_CMD_CLP_OP_SET_BOOT 0x4
+/* enum: Get UEFI/GPXE boot mode */
+#define          MC_CMD_CLP_OP_GET_BOOT 0x5
+
+/* MC_CMD_CLP_OUT msgresponse */
+#define    MC_CMD_CLP_OUT_LEN 0
+
+/* MC_CMD_CLP_IN_DEFAULT msgrequest */
+#define    MC_CMD_CLP_IN_DEFAULT_LEN 4
+/*            MC_CMD_CLP_IN_OP_OFST 0 */
+
+/* MC_CMD_CLP_OUT_DEFAULT msgresponse */
+#define    MC_CMD_CLP_OUT_DEFAULT_LEN 0
+
+/* MC_CMD_CLP_IN_SET_MAC msgrequest */
+#define    MC_CMD_CLP_IN_SET_MAC_LEN 12
+/*            MC_CMD_CLP_IN_OP_OFST 0 */
+/* MAC address assigned to port */
+#define       MC_CMD_CLP_IN_SET_MAC_ADDR_OFST 4
+#define       MC_CMD_CLP_IN_SET_MAC_ADDR_LEN 6
+/* Padding */
+#define       MC_CMD_CLP_IN_SET_MAC_RESERVED_OFST 10
+#define       MC_CMD_CLP_IN_SET_MAC_RESERVED_LEN 2
+
+/* MC_CMD_CLP_OUT_SET_MAC msgresponse */
+#define    MC_CMD_CLP_OUT_SET_MAC_LEN 0
+
+/* MC_CMD_CLP_IN_GET_MAC msgrequest */
+#define    MC_CMD_CLP_IN_GET_MAC_LEN 4
+/*            MC_CMD_CLP_IN_OP_OFST 0 */
+
+/* MC_CMD_CLP_OUT_GET_MAC msgresponse */
+#define    MC_CMD_CLP_OUT_GET_MAC_LEN 8
+/* MAC address assigned to port */
+#define       MC_CMD_CLP_OUT_GET_MAC_ADDR_OFST 0
+#define       MC_CMD_CLP_OUT_GET_MAC_ADDR_LEN 6
+/* Padding */
+#define       MC_CMD_CLP_OUT_GET_MAC_RESERVED_OFST 6
+#define       MC_CMD_CLP_OUT_GET_MAC_RESERVED_LEN 2
+
+/* MC_CMD_CLP_IN_SET_BOOT msgrequest */
+#define    MC_CMD_CLP_IN_SET_BOOT_LEN 5
+/*            MC_CMD_CLP_IN_OP_OFST 0 */
+/* Boot flag */
+#define       MC_CMD_CLP_IN_SET_BOOT_FLAG_OFST 4
+#define       MC_CMD_CLP_IN_SET_BOOT_FLAG_LEN 1
+
+/* MC_CMD_CLP_OUT_SET_BOOT msgresponse */
+#define    MC_CMD_CLP_OUT_SET_BOOT_LEN 0
+
+/* MC_CMD_CLP_IN_GET_BOOT msgrequest */
+#define    MC_CMD_CLP_IN_GET_BOOT_LEN 4
+/*            MC_CMD_CLP_IN_OP_OFST 0 */
+
+/* MC_CMD_CLP_OUT_GET_BOOT msgresponse */
+#define    MC_CMD_CLP_OUT_GET_BOOT_LEN 4
+/* Boot flag */
+#define       MC_CMD_CLP_OUT_GET_BOOT_FLAG_OFST 0
+#define       MC_CMD_CLP_OUT_GET_BOOT_FLAG_LEN 1
+/* Padding */
+#define       MC_CMD_CLP_OUT_GET_BOOT_RESERVED_OFST 1
+#define       MC_CMD_CLP_OUT_GET_BOOT_RESERVED_LEN 3
+
+
+/***********************************/
+/* MC_CMD_MUM
+ * Perform a MUM operation
+ */
+#define MC_CMD_MUM 0x57
+
+#define MC_CMD_0x57_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
+/* MC_CMD_MUM_IN msgrequest */
+#define    MC_CMD_MUM_IN_LEN 4
+#define       MC_CMD_MUM_IN_OP_HDR_OFST 0
+#define        MC_CMD_MUM_IN_OP_LBN 0
+#define        MC_CMD_MUM_IN_OP_WIDTH 8
+/* enum: NULL MCDI command to MUM */
+#define          MC_CMD_MUM_OP_NULL 0x1
+/* enum: Get MUM version */
+#define          MC_CMD_MUM_OP_GET_VERSION 0x2
+/* enum: Issue raw I2C command to MUM */
+#define          MC_CMD_MUM_OP_RAW_CMD 0x3
+/* enum: Read from registers on devices connected to MUM. */
+#define          MC_CMD_MUM_OP_READ 0x4
+/* enum: Write to registers on devices connected to MUM. */
+#define          MC_CMD_MUM_OP_WRITE 0x5
+/* enum: Control UART logging. */
+#define          MC_CMD_MUM_OP_LOG 0x6
+/* enum: Operations on MUM GPIO lines */
+#define          MC_CMD_MUM_OP_GPIO 0x7
+/* enum: Get sensor readings from MUM */
+#define          MC_CMD_MUM_OP_READ_SENSORS 0x8
+/* enum: Initiate clock programming on the MUM */
+#define          MC_CMD_MUM_OP_PROGRAM_CLOCKS 0x9
+/* enum: Initiate FPGA load from flash on the MUM */
+#define          MC_CMD_MUM_OP_FPGA_LOAD 0xa
+/* enum: Request sensor reading from MUM ADC resulting from earlier request via
+ * MUM ATB
+ */
+#define          MC_CMD_MUM_OP_READ_ATB_SENSOR 0xb
+/* enum: Send commands relating to the QSFP ports via the MUM for PHY
+ * operations
+ */
+#define          MC_CMD_MUM_OP_QSFP 0xc
+
+/* MC_CMD_MUM_IN_NULL msgrequest */
+#define    MC_CMD_MUM_IN_NULL_LEN 4
+/* MUM cmd header */
+#define       MC_CMD_MUM_IN_CMD_OFST 0
+
+/* MC_CMD_MUM_IN_GET_VERSION msgrequest */
+#define    MC_CMD_MUM_IN_GET_VERSION_LEN 4
+/* MUM cmd header */
+/*            MC_CMD_MUM_IN_CMD_OFST 0 */
+
+/* MC_CMD_MUM_IN_READ msgrequest */
+#define    MC_CMD_MUM_IN_READ_LEN 16
+/* MUM cmd header */
+/*            MC_CMD_MUM_IN_CMD_OFST 0 */
+/* ID of (device connected to MUM) to read from registers of */
+#define       MC_CMD_MUM_IN_READ_DEVICE_OFST 4
+/* enum: Hittite HMC1035 clock generator on Sorrento board */
+#define          MC_CMD_MUM_DEV_HITTITE 0x1
+/* enum: Hittite HMC1035 clock generator for NIC-side on Sorrento board */
+#define          MC_CMD_MUM_DEV_HITTITE_NIC 0x2
+/* 32-bit address to read from */
+#define       MC_CMD_MUM_IN_READ_ADDR_OFST 8
+/* Number of words to read. */
+#define       MC_CMD_MUM_IN_READ_NUMWORDS_OFST 12
+
+/* MC_CMD_MUM_IN_WRITE msgrequest */
+#define    MC_CMD_MUM_IN_WRITE_LENMIN 16
+#define    MC_CMD_MUM_IN_WRITE_LENMAX 252
+#define    MC_CMD_MUM_IN_WRITE_LEN(num) (12+4*(num))
+/* MUM cmd header */
+/*            MC_CMD_MUM_IN_CMD_OFST 0 */
+/* ID of (device connected to MUM) to write to registers of */
+#define       MC_CMD_MUM_IN_WRITE_DEVICE_OFST 4
+/* enum: Hittite HMC1035 clock generator on Sorrento board */
+/*               MC_CMD_MUM_DEV_HITTITE 0x1 */
+/* 32-bit address to write to */
+#define       MC_CMD_MUM_IN_WRITE_ADDR_OFST 8
+/* Words to write */
+#define       MC_CMD_MUM_IN_WRITE_BUFFER_OFST 12
+#define       MC_CMD_MUM_IN_WRITE_BUFFER_LEN 4
+#define       MC_CMD_MUM_IN_WRITE_BUFFER_MINNUM 1
+#define       MC_CMD_MUM_IN_WRITE_BUFFER_MAXNUM 60
+
+/* MC_CMD_MUM_IN_RAW_CMD msgrequest */
+#define    MC_CMD_MUM_IN_RAW_CMD_LENMIN 17
+#define    MC_CMD_MUM_IN_RAW_CMD_LENMAX 252
+#define    MC_CMD_MUM_IN_RAW_CMD_LEN(num) (16+1*(num))
+/* MUM cmd header */
+/*            MC_CMD_MUM_IN_CMD_OFST 0 */
+/* MUM I2C cmd code */
+#define       MC_CMD_MUM_IN_RAW_CMD_CMD_CODE_OFST 4
+/* Number of bytes to write */
+#define       MC_CMD_MUM_IN_RAW_CMD_NUM_WRITE_OFST 8
+/* Number of bytes to read */
+#define       MC_CMD_MUM_IN_RAW_CMD_NUM_READ_OFST 12
+/* Bytes to write */
+#define       MC_CMD_MUM_IN_RAW_CMD_WRITE_DATA_OFST 16
+#define       MC_CMD_MUM_IN_RAW_CMD_WRITE_DATA_LEN 1
+#define       MC_CMD_MUM_IN_RAW_CMD_WRITE_DATA_MINNUM 1
+#define       MC_CMD_MUM_IN_RAW_CMD_WRITE_DATA_MAXNUM 236
+
+/* MC_CMD_MUM_IN_LOG msgrequest */
+#define    MC_CMD_MUM_IN_LOG_LEN 8
+/* MUM cmd header */
+/*            MC_CMD_MUM_IN_CMD_OFST 0 */
+#define       MC_CMD_MUM_IN_LOG_OP_OFST 4
+#define          MC_CMD_MUM_IN_LOG_OP_UART  0x1 /* enum */
+
+/* MC_CMD_MUM_IN_LOG_OP_UART msgrequest */
+#define    MC_CMD_MUM_IN_LOG_OP_UART_LEN 12
+/*            MC_CMD_MUM_IN_CMD_OFST 0 */
+/*            MC_CMD_MUM_IN_LOG_OP_OFST 4 */
+/* Enable/disable debug output to UART */
+#define       MC_CMD_MUM_IN_LOG_OP_UART_ENABLE_OFST 8
+
+/* MC_CMD_MUM_IN_GPIO msgrequest */
+#define    MC_CMD_MUM_IN_GPIO_LEN 8
+/* MUM cmd header */
+/*            MC_CMD_MUM_IN_CMD_OFST 0 */
+#define       MC_CMD_MUM_IN_GPIO_HDR_OFST 4
+#define        MC_CMD_MUM_IN_GPIO_OPCODE_LBN 0
+#define        MC_CMD_MUM_IN_GPIO_OPCODE_WIDTH 8
+#define          MC_CMD_MUM_IN_GPIO_IN_READ 0x0 /* enum */
+#define          MC_CMD_MUM_IN_GPIO_OUT_WRITE 0x1 /* enum */
+#define          MC_CMD_MUM_IN_GPIO_OUT_READ 0x2 /* enum */
+#define          MC_CMD_MUM_IN_GPIO_OUT_ENABLE_WRITE 0x3 /* enum */
+#define          MC_CMD_MUM_IN_GPIO_OUT_ENABLE_READ 0x4 /* enum */
+#define          MC_CMD_MUM_IN_GPIO_OP 0x5 /* enum */
+
+/* MC_CMD_MUM_IN_GPIO_IN_READ msgrequest */
+#define    MC_CMD_MUM_IN_GPIO_IN_READ_LEN 8
+/*            MC_CMD_MUM_IN_CMD_OFST 0 */
+#define       MC_CMD_MUM_IN_GPIO_IN_READ_HDR_OFST 4
+
+/* MC_CMD_MUM_IN_GPIO_OUT_WRITE msgrequest */
+#define    MC_CMD_MUM_IN_GPIO_OUT_WRITE_LEN 16
+/*            MC_CMD_MUM_IN_CMD_OFST 0 */
+#define       MC_CMD_MUM_IN_GPIO_OUT_WRITE_HDR_OFST 4
+/* The first 32-bit word to be written to the GPIO OUT register. */
+#define       MC_CMD_MUM_IN_GPIO_OUT_WRITE_GPIOMASK1_OFST 8
+/* The second 32-bit word to be written to the GPIO OUT register. */
+#define       MC_CMD_MUM_IN_GPIO_OUT_WRITE_GPIOMASK2_OFST 12
+
+/* MC_CMD_MUM_IN_GPIO_OUT_READ msgrequest */
+#define    MC_CMD_MUM_IN_GPIO_OUT_READ_LEN 8
+/*            MC_CMD_MUM_IN_CMD_OFST 0 */
+#define       MC_CMD_MUM_IN_GPIO_OUT_READ_HDR_OFST 4
+
+/* MC_CMD_MUM_IN_GPIO_OUT_ENABLE_WRITE msgrequest */
+#define    MC_CMD_MUM_IN_GPIO_OUT_ENABLE_WRITE_LEN 16
+/*            MC_CMD_MUM_IN_CMD_OFST 0 */
+#define       MC_CMD_MUM_IN_GPIO_OUT_ENABLE_WRITE_HDR_OFST 4
+/* The first 32-bit word to be written to the GPIO OUT ENABLE register. */
+#define       MC_CMD_MUM_IN_GPIO_OUT_ENABLE_WRITE_GPIOMASK1_OFST 8
+/* The second 32-bit word to be written to the GPIO OUT ENABLE register. */
+#define       MC_CMD_MUM_IN_GPIO_OUT_ENABLE_WRITE_GPIOMASK2_OFST 12
+
+/* MC_CMD_MUM_IN_GPIO_OUT_ENABLE_READ msgrequest */
+#define    MC_CMD_MUM_IN_GPIO_OUT_ENABLE_READ_LEN 8
+/*            MC_CMD_MUM_IN_CMD_OFST 0 */
+#define       MC_CMD_MUM_IN_GPIO_OUT_ENABLE_READ_HDR_OFST 4
+
+/* MC_CMD_MUM_IN_GPIO_OP msgrequest */
+#define    MC_CMD_MUM_IN_GPIO_OP_LEN 8
+/*            MC_CMD_MUM_IN_CMD_OFST 0 */
+#define       MC_CMD_MUM_IN_GPIO_OP_HDR_OFST 4
+#define        MC_CMD_MUM_IN_GPIO_OP_BITWISE_OP_LBN 8
+#define        MC_CMD_MUM_IN_GPIO_OP_BITWISE_OP_WIDTH 8
+#define          MC_CMD_MUM_IN_GPIO_OP_OUT_READ 0x0 /* enum */
+#define          MC_CMD_MUM_IN_GPIO_OP_OUT_WRITE 0x1 /* enum */
+#define          MC_CMD_MUM_IN_GPIO_OP_OUT_CONFIG 0x2 /* enum */
+#define          MC_CMD_MUM_IN_GPIO_OP_OUT_ENABLE 0x3 /* enum */
+#define        MC_CMD_MUM_IN_GPIO_OP_GPIO_NUMBER_LBN 16
+#define        MC_CMD_MUM_IN_GPIO_OP_GPIO_NUMBER_WIDTH 8
+
+/* MC_CMD_MUM_IN_GPIO_OP_OUT_READ msgrequest */
+#define    MC_CMD_MUM_IN_GPIO_OP_OUT_READ_LEN 8
+/*            MC_CMD_MUM_IN_CMD_OFST 0 */
+#define       MC_CMD_MUM_IN_GPIO_OP_OUT_READ_HDR_OFST 4
+
+/* MC_CMD_MUM_IN_GPIO_OP_OUT_WRITE msgrequest */
+#define    MC_CMD_MUM_IN_GPIO_OP_OUT_WRITE_LEN 8
+/*            MC_CMD_MUM_IN_CMD_OFST 0 */
+#define       MC_CMD_MUM_IN_GPIO_OP_OUT_WRITE_HDR_OFST 4
+#define        MC_CMD_MUM_IN_GPIO_OP_OUT_WRITE_WRITEBIT_LBN 24
+#define        MC_CMD_MUM_IN_GPIO_OP_OUT_WRITE_WRITEBIT_WIDTH 8
+
+/* MC_CMD_MUM_IN_GPIO_OP_OUT_CONFIG msgrequest */
+#define    MC_CMD_MUM_IN_GPIO_OP_OUT_CONFIG_LEN 8
+/*            MC_CMD_MUM_IN_CMD_OFST 0 */
+#define       MC_CMD_MUM_IN_GPIO_OP_OUT_CONFIG_HDR_OFST 4
+#define        MC_CMD_MUM_IN_GPIO_OP_OUT_CONFIG_CFG_LBN 24
+#define        MC_CMD_MUM_IN_GPIO_OP_OUT_CONFIG_CFG_WIDTH 8
+
+/* MC_CMD_MUM_IN_GPIO_OP_OUT_ENABLE msgrequest */
+#define    MC_CMD_MUM_IN_GPIO_OP_OUT_ENABLE_LEN 8
+/*            MC_CMD_MUM_IN_CMD_OFST 0 */
+#define       MC_CMD_MUM_IN_GPIO_OP_OUT_ENABLE_HDR_OFST 4
+#define        MC_CMD_MUM_IN_GPIO_OP_OUT_ENABLE_ENABLEBIT_LBN 24
+#define        MC_CMD_MUM_IN_GPIO_OP_OUT_ENABLE_ENABLEBIT_WIDTH 8
+
+/* MC_CMD_MUM_IN_READ_SENSORS msgrequest */
+#define    MC_CMD_MUM_IN_READ_SENSORS_LEN 8
+/* MUM cmd header */
+/*            MC_CMD_MUM_IN_CMD_OFST 0 */
+#define       MC_CMD_MUM_IN_READ_SENSORS_PARAMS_OFST 4
+#define        MC_CMD_MUM_IN_READ_SENSORS_SENSOR_ID_LBN 0
+#define        MC_CMD_MUM_IN_READ_SENSORS_SENSOR_ID_WIDTH 8
+#define        MC_CMD_MUM_IN_READ_SENSORS_NUM_SENSORS_LBN 8
+#define        MC_CMD_MUM_IN_READ_SENSORS_NUM_SENSORS_WIDTH 8
+
+/* MC_CMD_MUM_IN_PROGRAM_CLOCKS msgrequest */
+#define    MC_CMD_MUM_IN_PROGRAM_CLOCKS_LEN 12
+/* MUM cmd header */
+/*            MC_CMD_MUM_IN_CMD_OFST 0 */
+/* Bit-mask of clocks to be programmed */
+#define       MC_CMD_MUM_IN_PROGRAM_CLOCKS_MASK_OFST 4
+#define          MC_CMD_MUM_CLOCK_ID_FPGA 0x0 /* enum */
+#define          MC_CMD_MUM_CLOCK_ID_DDR 0x1 /* enum */
+#define          MC_CMD_MUM_CLOCK_ID_NIC 0x2 /* enum */
+/* Control flags for clock programming */
+#define       MC_CMD_MUM_IN_PROGRAM_CLOCKS_FLAGS_OFST 8
+#define        MC_CMD_MUM_IN_PROGRAM_CLOCKS_OVERCLOCK_110_LBN 0
+#define        MC_CMD_MUM_IN_PROGRAM_CLOCKS_OVERCLOCK_110_WIDTH 1
+
+/* MC_CMD_MUM_IN_FPGA_LOAD msgrequest */
+#define    MC_CMD_MUM_IN_FPGA_LOAD_LEN 8
+/* MUM cmd header */
+/*            MC_CMD_MUM_IN_CMD_OFST 0 */
+/* Enable/Disable FPGA config from flash */
+#define       MC_CMD_MUM_IN_FPGA_LOAD_ENABLE_OFST 4
+
+/* MC_CMD_MUM_IN_READ_ATB_SENSOR msgrequest */
+#define    MC_CMD_MUM_IN_READ_ATB_SENSOR_LEN 4
+/* MUM cmd header */
+/*            MC_CMD_MUM_IN_CMD_OFST 0 */
+
+/* MC_CMD_MUM_IN_QSFP msgrequest */
+#define    MC_CMD_MUM_IN_QSFP_LEN 12
+/* MUM cmd header */
+/*            MC_CMD_MUM_IN_CMD_OFST 0 */
+#define       MC_CMD_MUM_IN_QSFP_HDR_OFST 4
+#define        MC_CMD_MUM_IN_QSFP_OPCODE_LBN 0
+#define        MC_CMD_MUM_IN_QSFP_OPCODE_WIDTH 4
+#define          MC_CMD_MUM_IN_QSFP_INIT 0x0 /* enum */
+#define          MC_CMD_MUM_IN_QSFP_RECONFIGURE 0x1 /* enum */
+#define          MC_CMD_MUM_IN_QSFP_GET_SUPPORTED_CAP 0x2 /* enum */
+#define          MC_CMD_MUM_IN_QSFP_GET_MEDIA_INFO 0x3 /* enum */
+#define          MC_CMD_MUM_IN_QSFP_FILL_STATS 0x4 /* enum */
+#define          MC_CMD_MUM_IN_QSFP_POLL_BIST 0x5 /* enum */
+#define       MC_CMD_MUM_IN_QSFP_IDX_OFST 8
+
+/* MC_CMD_MUM_IN_QSFP_INIT msgrequest */
+#define    MC_CMD_MUM_IN_QSFP_INIT_LEN 16
+/*            MC_CMD_MUM_IN_CMD_OFST 0 */
+#define       MC_CMD_MUM_IN_QSFP_INIT_HDR_OFST 4
+#define       MC_CMD_MUM_IN_QSFP_INIT_IDX_OFST 8
+#define       MC_CMD_MUM_IN_QSFP_INIT_CAGE_OFST 12
+
+/* MC_CMD_MUM_IN_QSFP_RECONFIGURE msgrequest */
+#define    MC_CMD_MUM_IN_QSFP_RECONFIGURE_LEN 24
+/*            MC_CMD_MUM_IN_CMD_OFST 0 */
+#define       MC_CMD_MUM_IN_QSFP_RECONFIGURE_HDR_OFST 4
+#define       MC_CMD_MUM_IN_QSFP_RECONFIGURE_IDX_OFST 8
+#define       MC_CMD_MUM_IN_QSFP_RECONFIGURE_TX_DISABLE_OFST 12
+#define       MC_CMD_MUM_IN_QSFP_RECONFIGURE_PORT_LANES_OFST 16
+#define       MC_CMD_MUM_IN_QSFP_RECONFIGURE_PORT_LINK_SPEED_OFST 20
+
+/* MC_CMD_MUM_IN_QSFP_GET_SUPPORTED_CAP msgrequest */
+#define    MC_CMD_MUM_IN_QSFP_GET_SUPPORTED_CAP_LEN 12
+/*            MC_CMD_MUM_IN_CMD_OFST 0 */
+#define       MC_CMD_MUM_IN_QSFP_GET_SUPPORTED_CAP_HDR_OFST 4
+#define       MC_CMD_MUM_IN_QSFP_GET_SUPPORTED_CAP_IDX_OFST 8
+
+/* MC_CMD_MUM_IN_QSFP_GET_MEDIA_INFO msgrequest */
+#define    MC_CMD_MUM_IN_QSFP_GET_MEDIA_INFO_LEN 16
+/*            MC_CMD_MUM_IN_CMD_OFST 0 */
+#define       MC_CMD_MUM_IN_QSFP_GET_MEDIA_INFO_HDR_OFST 4
+#define       MC_CMD_MUM_IN_QSFP_GET_MEDIA_INFO_IDX_OFST 8
+#define       MC_CMD_MUM_IN_QSFP_GET_MEDIA_INFO_PAGE_OFST 12
+
+/* MC_CMD_MUM_IN_QSFP_FILL_STATS msgrequest */
+#define    MC_CMD_MUM_IN_QSFP_FILL_STATS_LEN 12
+/*            MC_CMD_MUM_IN_CMD_OFST 0 */
+#define       MC_CMD_MUM_IN_QSFP_FILL_STATS_HDR_OFST 4
+#define       MC_CMD_MUM_IN_QSFP_FILL_STATS_IDX_OFST 8
+
+/* MC_CMD_MUM_IN_QSFP_POLL_BIST msgrequest */
+#define    MC_CMD_MUM_IN_QSFP_POLL_BIST_LEN 12
+/*            MC_CMD_MUM_IN_CMD_OFST 0 */
+#define       MC_CMD_MUM_IN_QSFP_POLL_BIST_HDR_OFST 4
+#define       MC_CMD_MUM_IN_QSFP_POLL_BIST_IDX_OFST 8
+
+/* MC_CMD_MUM_OUT msgresponse */
+#define    MC_CMD_MUM_OUT_LEN 0
+
+/* MC_CMD_MUM_OUT_NULL msgresponse */
+#define    MC_CMD_MUM_OUT_NULL_LEN 0
+
+/* MC_CMD_MUM_OUT_GET_VERSION msgresponse */
+#define    MC_CMD_MUM_OUT_GET_VERSION_LEN 12
+#define       MC_CMD_MUM_OUT_GET_VERSION_FIRMWARE_OFST 0
+#define       MC_CMD_MUM_OUT_GET_VERSION_VERSION_OFST 4
+#define       MC_CMD_MUM_OUT_GET_VERSION_VERSION_LEN 8
+#define       MC_CMD_MUM_OUT_GET_VERSION_VERSION_LO_OFST 4
+#define       MC_CMD_MUM_OUT_GET_VERSION_VERSION_HI_OFST 8
+
+/* MC_CMD_MUM_OUT_RAW_CMD msgresponse */
+#define    MC_CMD_MUM_OUT_RAW_CMD_LENMIN 1
+#define    MC_CMD_MUM_OUT_RAW_CMD_LENMAX 252
+#define    MC_CMD_MUM_OUT_RAW_CMD_LEN(num) (0+1*(num))
+/* returned data */
+#define       MC_CMD_MUM_OUT_RAW_CMD_DATA_OFST 0
+#define       MC_CMD_MUM_OUT_RAW_CMD_DATA_LEN 1
+#define       MC_CMD_MUM_OUT_RAW_CMD_DATA_MINNUM 1
+#define       MC_CMD_MUM_OUT_RAW_CMD_DATA_MAXNUM 252
+
+/* MC_CMD_MUM_OUT_READ msgresponse */
+#define    MC_CMD_MUM_OUT_READ_LENMIN 4
+#define    MC_CMD_MUM_OUT_READ_LENMAX 252
+#define    MC_CMD_MUM_OUT_READ_LEN(num) (0+4*(num))
+#define       MC_CMD_MUM_OUT_READ_BUFFER_OFST 0
+#define       MC_CMD_MUM_OUT_READ_BUFFER_LEN 4
+#define       MC_CMD_MUM_OUT_READ_BUFFER_MINNUM 1
+#define       MC_CMD_MUM_OUT_READ_BUFFER_MAXNUM 63
+
+/* MC_CMD_MUM_OUT_WRITE msgresponse */
+#define    MC_CMD_MUM_OUT_WRITE_LEN 0
+
+/* MC_CMD_MUM_OUT_LOG msgresponse */
+#define    MC_CMD_MUM_OUT_LOG_LEN 0
+
+/* MC_CMD_MUM_OUT_LOG_OP_UART msgresponse */
+#define    MC_CMD_MUM_OUT_LOG_OP_UART_LEN 0
+
+/* MC_CMD_MUM_OUT_GPIO_IN_READ msgresponse */
+#define    MC_CMD_MUM_OUT_GPIO_IN_READ_LEN 8
+/* The first 32-bit word read from the GPIO IN register. */
+#define       MC_CMD_MUM_OUT_GPIO_IN_READ_GPIOMASK1_OFST 0
+/* The second 32-bit word read from the GPIO IN register. */
+#define       MC_CMD_MUM_OUT_GPIO_IN_READ_GPIOMASK2_OFST 4
+
+/* MC_CMD_MUM_OUT_GPIO_OUT_WRITE msgresponse */
+#define    MC_CMD_MUM_OUT_GPIO_OUT_WRITE_LEN 0
+
+/* MC_CMD_MUM_OUT_GPIO_OUT_READ msgresponse */
+#define    MC_CMD_MUM_OUT_GPIO_OUT_READ_LEN 8
+/* The first 32-bit word read from the GPIO OUT register. */
+#define       MC_CMD_MUM_OUT_GPIO_OUT_READ_GPIOMASK1_OFST 0
+/* The second 32-bit word read from the GPIO OUT register. */
+#define       MC_CMD_MUM_OUT_GPIO_OUT_READ_GPIOMASK2_OFST 4
+
+/* MC_CMD_MUM_OUT_GPIO_OUT_ENABLE_WRITE msgresponse */
+#define    MC_CMD_MUM_OUT_GPIO_OUT_ENABLE_WRITE_LEN 0
+
+/* MC_CMD_MUM_OUT_GPIO_OUT_ENABLE_READ msgresponse */
+#define    MC_CMD_MUM_OUT_GPIO_OUT_ENABLE_READ_LEN 8
+#define       MC_CMD_MUM_OUT_GPIO_OUT_ENABLE_READ_GPIOMASK1_OFST 0
+#define       MC_CMD_MUM_OUT_GPIO_OUT_ENABLE_READ_GPIOMASK2_OFST 4
+
+/* MC_CMD_MUM_OUT_GPIO_OP_OUT_READ msgresponse */
+#define    MC_CMD_MUM_OUT_GPIO_OP_OUT_READ_LEN 4
+#define       MC_CMD_MUM_OUT_GPIO_OP_OUT_READ_BIT_READ_OFST 0
+
+/* MC_CMD_MUM_OUT_GPIO_OP_OUT_WRITE msgresponse */
+#define    MC_CMD_MUM_OUT_GPIO_OP_OUT_WRITE_LEN 0
+
+/* MC_CMD_MUM_OUT_GPIO_OP_OUT_CONFIG msgresponse */
+#define    MC_CMD_MUM_OUT_GPIO_OP_OUT_CONFIG_LEN 0
+
+/* MC_CMD_MUM_OUT_GPIO_OP_OUT_ENABLE msgresponse */
+#define    MC_CMD_MUM_OUT_GPIO_OP_OUT_ENABLE_LEN 0
+
+/* MC_CMD_MUM_OUT_READ_SENSORS msgresponse */
+#define    MC_CMD_MUM_OUT_READ_SENSORS_LENMIN 4
+#define    MC_CMD_MUM_OUT_READ_SENSORS_LENMAX 252
+#define    MC_CMD_MUM_OUT_READ_SENSORS_LEN(num) (0+4*(num))
+#define       MC_CMD_MUM_OUT_READ_SENSORS_DATA_OFST 0
+#define       MC_CMD_MUM_OUT_READ_SENSORS_DATA_LEN 4
+#define       MC_CMD_MUM_OUT_READ_SENSORS_DATA_MINNUM 1
+#define       MC_CMD_MUM_OUT_READ_SENSORS_DATA_MAXNUM 63
+#define        MC_CMD_MUM_OUT_READ_SENSORS_READING_LBN 0
+#define        MC_CMD_MUM_OUT_READ_SENSORS_READING_WIDTH 16
+#define        MC_CMD_MUM_OUT_READ_SENSORS_STATE_LBN 16
+#define        MC_CMD_MUM_OUT_READ_SENSORS_STATE_WIDTH 8
+#define        MC_CMD_MUM_OUT_READ_SENSORS_TYPE_LBN 24
+#define        MC_CMD_MUM_OUT_READ_SENSORS_TYPE_WIDTH 8
+
+/* MC_CMD_MUM_OUT_PROGRAM_CLOCKS msgresponse */
+#define    MC_CMD_MUM_OUT_PROGRAM_CLOCKS_LEN 4
+#define       MC_CMD_MUM_OUT_PROGRAM_CLOCKS_OK_MASK_OFST 0
+
+/* MC_CMD_MUM_OUT_FPGA_LOAD msgresponse */
+#define    MC_CMD_MUM_OUT_FPGA_LOAD_LEN 0
+
+/* MC_CMD_MUM_OUT_READ_ATB_SENSOR msgresponse */
+#define    MC_CMD_MUM_OUT_READ_ATB_SENSOR_LEN 4
+#define       MC_CMD_MUM_OUT_READ_ATB_SENSOR_RESULT_OFST 0
+
+/* MC_CMD_MUM_OUT_QSFP_INIT msgresponse */
+#define    MC_CMD_MUM_OUT_QSFP_INIT_LEN 0
+
+/* MC_CMD_MUM_OUT_QSFP_RECONFIGURE msgresponse */
+#define    MC_CMD_MUM_OUT_QSFP_RECONFIGURE_LEN 8
+#define       MC_CMD_MUM_OUT_QSFP_RECONFIGURE_PORT_PHY_LP_CAP_OFST 0
+#define       MC_CMD_MUM_OUT_QSFP_RECONFIGURE_PORT_PHY_FLAGS_OFST 4
+#define        MC_CMD_MUM_OUT_QSFP_RECONFIGURE_PORT_PHY_READY_LBN 0
+#define        MC_CMD_MUM_OUT_QSFP_RECONFIGURE_PORT_PHY_READY_WIDTH 1
+#define        MC_CMD_MUM_OUT_QSFP_RECONFIGURE_PORT_PHY_LINK_UP_LBN 1
+#define        MC_CMD_MUM_OUT_QSFP_RECONFIGURE_PORT_PHY_LINK_UP_WIDTH 1
+
+/* MC_CMD_MUM_OUT_QSFP_GET_SUPPORTED_CAP msgresponse */
+#define    MC_CMD_MUM_OUT_QSFP_GET_SUPPORTED_CAP_LEN 4
+#define       MC_CMD_MUM_OUT_QSFP_GET_SUPPORTED_CAP_PORT_PHY_LP_CAP_OFST 0
+
+/* MC_CMD_MUM_OUT_QSFP_GET_MEDIA_INFO msgresponse */
+#define    MC_CMD_MUM_OUT_QSFP_GET_MEDIA_INFO_LENMIN 5
+#define    MC_CMD_MUM_OUT_QSFP_GET_MEDIA_INFO_LENMAX 252
+#define    MC_CMD_MUM_OUT_QSFP_GET_MEDIA_INFO_LEN(num) (4+1*(num))
+/* in bytes */
+#define       MC_CMD_MUM_OUT_QSFP_GET_MEDIA_INFO_DATALEN_OFST 0
+#define       MC_CMD_MUM_OUT_QSFP_GET_MEDIA_INFO_DATA_OFST 4
+#define       MC_CMD_MUM_OUT_QSFP_GET_MEDIA_INFO_DATA_LEN 1
+#define       MC_CMD_MUM_OUT_QSFP_GET_MEDIA_INFO_DATA_MINNUM 1
+#define       MC_CMD_MUM_OUT_QSFP_GET_MEDIA_INFO_DATA_MAXNUM 248
+
+/* MC_CMD_MUM_OUT_QSFP_FILL_STATS msgresponse */
+#define    MC_CMD_MUM_OUT_QSFP_FILL_STATS_LEN 8
+#define       MC_CMD_MUM_OUT_QSFP_FILL_STATS_PORT_PHY_STATS_PMA_PMD_LINK_UP_OFST 0
+#define       MC_CMD_MUM_OUT_QSFP_FILL_STATS_PORT_PHY_STATS_PCS_LINK_UP_OFST 4
+
+/* MC_CMD_MUM_OUT_QSFP_POLL_BIST msgresponse */
+#define    MC_CMD_MUM_OUT_QSFP_POLL_BIST_LEN 4
+#define       MC_CMD_MUM_OUT_QSFP_POLL_BIST_TEST_OFST 0
+
 /* MC_CMD_RESOURCE_SPECIFIER enum */
 /* enum: Any */
 #define          MC_CMD_RESOURCE_INSTANCE_ANY 0xffffffff
@@ -4203,6 +5092,30 @@
 #define          NVRAM_PARTITION_TYPE_PHY_MIN              0xa00
 /* enum: End of range used for PHY partitions (low 8 bits are the PHY ID) */
 #define          NVRAM_PARTITION_TYPE_PHY_MAX              0xaff
+/* enum: Primary FPGA partition */
+#define          NVRAM_PARTITION_TYPE_FPGA                 0xb00
+/* enum: Secondary FPGA partition */
+#define          NVRAM_PARTITION_TYPE_FPGA_BACKUP          0xb01
+/* enum: FC firmware partition */
+#define          NVRAM_PARTITION_TYPE_FC_FIRMWARE          0xb02
+/* enum: FC License partition */
+#define          NVRAM_PARTITION_TYPE_FC_LICENSE           0xb03
+/* enum: Non-volatile log output partition for FC */
+#define          NVRAM_PARTITION_TYPE_FC_LOG               0xb04
+/* enum: MUM firmware partition */
+#define          NVRAM_PARTITION_TYPE_MUM_FIRMWARE         0xc00
+/* enum: MUM Non-volatile log output partition. */
+#define          NVRAM_PARTITION_TYPE_MUM_LOG              0xc01
+/* enum: MUM Application table partition. */
+#define          NVRAM_PARTITION_TYPE_MUM_APPTABLE         0xc02
+/* enum: MUM boot rom partition. */
+#define          NVRAM_PARTITION_TYPE_MUM_BOOT_ROM         0xc03
+/* enum: MUM production signatures & calibration rom partition. */
+#define          NVRAM_PARTITION_TYPE_MUM_PROD_ROM         0xc04
+/* enum: MUM user signatures & calibration rom partition. */
+#define          NVRAM_PARTITION_TYPE_MUM_USER_ROM         0xc05
+/* enum: MUM fuses and lockbits partition. */
+#define          NVRAM_PARTITION_TYPE_MUM_FUSELOCK         0xc06
 /* enum: Start of reserved value range (firmware may use for any purpose) */
 #define          NVRAM_PARTITION_TYPE_RESERVED_VALUES_MIN  0xff00
 /* enum: End of reserved value range (firmware may use for any purpose) */
@@ -4218,66 +5131,69 @@
 #define    LICENSED_APP_ID_LEN 4
 #define       LICENSED_APP_ID_ID_OFST 0
 /* enum: OpenOnload */
-#define          LICENSED_APP_ID_ONLOAD            0x1
+#define          LICENSED_APP_ID_ONLOAD                  0x1
 /* enum: PTP timestamping */
-#define          LICENSED_APP_ID_PTP               0x2
+#define          LICENSED_APP_ID_PTP                     0x2
 /* enum: SolarCapture Pro */
-#define          LICENSED_APP_ID_SOLARCAPTURE_PRO  0x4
+#define          LICENSED_APP_ID_SOLARCAPTURE_PRO        0x4
+/* enum: SolarSecure filter engine */
+#define          LICENSED_APP_ID_SOLARSECURE             0x8
+/* enum: Performance monitor */
+#define          LICENSED_APP_ID_PERF_MONITOR            0x10
+/* enum: SolarCapture Live */
+#define          LICENSED_APP_ID_SOLARCAPTURE_LIVE       0x20
+/* enum: Capture SolarSystem */
+#define          LICENSED_APP_ID_CAPTURE_SOLARSYSTEM     0x40
+/* enum: Network Access Control */
+#define          LICENSED_APP_ID_NETWORK_ACCESS_CONTROL  0x80
 #define       LICENSED_APP_ID_ID_LBN 0
 #define       LICENSED_APP_ID_ID_WIDTH 32
 
-
-/***********************************/
-/* MC_CMD_GET_WORKAROUNDS
- * Read the list of all implemented and all currently enabled workarounds. The
- * enums here must correspond with those in MC_CMD_WORKAROUND.
- */
-#define MC_CMD_GET_WORKAROUNDS 0x59
-
-/* MC_CMD_GET_WORKAROUNDS_OUT msgresponse */
-#define    MC_CMD_GET_WORKAROUNDS_OUT_LEN 8
-/* Each workaround is represented by a single bit according to the enums below.
- */
-#define       MC_CMD_GET_WORKAROUNDS_OUT_IMPLEMENTED_OFST 0
-#define       MC_CMD_GET_WORKAROUNDS_OUT_ENABLED_OFST 4
-/* enum: Bug 17230 work around. */
-#define          MC_CMD_GET_WORKAROUNDS_OUT_BUG17230 0x2
-/* enum: Bug 35388 work around (unsafe EVQ writes). */
-#define          MC_CMD_GET_WORKAROUNDS_OUT_BUG35388 0x4
-/* enum: Bug35017 workaround (A64 tables must be identity map) */
-#define          MC_CMD_GET_WORKAROUNDS_OUT_BUG35017 0x8
-
-
-/***********************************/
-/* MC_CMD_LINK_STATE_MODE
- * Read/set link state mode of a VF
- */
-#define MC_CMD_LINK_STATE_MODE 0x5c
-
-#define MC_CMD_0x5c_PRIVILEGE_CTG SRIOV_CTG_GENERAL
-
-/* MC_CMD_LINK_STATE_MODE_IN msgrequest */
-#define    MC_CMD_LINK_STATE_MODE_IN_LEN 8
-/* The target function to have its link state mode read or set, must be a VF
- * e.g. VF 1,3 = 0x00030001
- */
-#define       MC_CMD_LINK_STATE_MODE_IN_FUNCTION_OFST 0
-#define        MC_CMD_LINK_STATE_MODE_IN_FUNCTION_PF_LBN 0
-#define        MC_CMD_LINK_STATE_MODE_IN_FUNCTION_PF_WIDTH 16
-#define        MC_CMD_LINK_STATE_MODE_IN_FUNCTION_VF_LBN 16
-#define        MC_CMD_LINK_STATE_MODE_IN_FUNCTION_VF_WIDTH 16
-/* New link state mode to be set */
-#define       MC_CMD_LINK_STATE_MODE_IN_NEW_MODE_OFST 4
-#define          MC_CMD_LINK_STATE_MODE_IN_LINK_STATE_AUTO       0x0 /* enum */
-#define          MC_CMD_LINK_STATE_MODE_IN_LINK_STATE_UP         0x1 /* enum */
-#define          MC_CMD_LINK_STATE_MODE_IN_LINK_STATE_DOWN       0x2 /* enum */
-/* enum: Use this value to just read the existing setting without modifying it.
- */
-#define          MC_CMD_LINK_STATE_MODE_IN_DO_NOT_CHANGE         0xffffffff
-
-/* MC_CMD_LINK_STATE_MODE_OUT msgresponse */
-#define    MC_CMD_LINK_STATE_MODE_OUT_LEN 4
-#define       MC_CMD_LINK_STATE_MODE_OUT_OLD_MODE_OFST 0
+/* TX_TIMESTAMP_EVENT structuredef */
+#define    TX_TIMESTAMP_EVENT_LEN 6
+/* lower 16 bits of timestamp data */
+#define       TX_TIMESTAMP_EVENT_TSTAMP_DATA_LO_OFST 0
+#define       TX_TIMESTAMP_EVENT_TSTAMP_DATA_LO_LEN 2
+#define       TX_TIMESTAMP_EVENT_TSTAMP_DATA_LO_LBN 0
+#define       TX_TIMESTAMP_EVENT_TSTAMP_DATA_LO_WIDTH 16
+/* Type of TX event, ordinary TX completion, low or high part of TX timestamp
+ */
+#define       TX_TIMESTAMP_EVENT_TX_EV_TYPE_OFST 3
+#define       TX_TIMESTAMP_EVENT_TX_EV_TYPE_LEN 1
+/* enum: This is a TX completion event, not a timestamp */
+#define          TX_TIMESTAMP_EVENT_TX_EV_COMPLETION  0x0
+/* enum: This is the low part of a TX timestamp event */
+#define          TX_TIMESTAMP_EVENT_TX_EV_TSTAMP_LO  0x51
+/* enum: This is the high part of a TX timestamp event */
+#define          TX_TIMESTAMP_EVENT_TX_EV_TSTAMP_HI  0x52
+#define       TX_TIMESTAMP_EVENT_TX_EV_TYPE_LBN 24
+#define       TX_TIMESTAMP_EVENT_TX_EV_TYPE_WIDTH 8
+/* upper 16 bits of timestamp data */
+#define       TX_TIMESTAMP_EVENT_TSTAMP_DATA_HI_OFST 4
+#define       TX_TIMESTAMP_EVENT_TSTAMP_DATA_HI_LEN 2
+#define       TX_TIMESTAMP_EVENT_TSTAMP_DATA_HI_LBN 32
+#define       TX_TIMESTAMP_EVENT_TSTAMP_DATA_HI_WIDTH 16
+
+/* RSS_MODE structuredef */
+#define    RSS_MODE_LEN 1
+/* The RSS mode for a particular packet type is a value from 0 - 15 which can
+ * be considered as 4 bits selecting which fields are included in the hash. (A
+ * value 0 effectively disables RSS spreading for the packet type.) The YAML
+ * generation tools require this structure to be a whole number of bytes wide,
+ * but only 4 bits are relevant.
+ */
+#define       RSS_MODE_HASH_SELECTOR_OFST 0
+#define       RSS_MODE_HASH_SELECTOR_LEN 1
+#define        RSS_MODE_HASH_SRC_ADDR_LBN 0
+#define        RSS_MODE_HASH_SRC_ADDR_WIDTH 1
+#define        RSS_MODE_HASH_DST_ADDR_LBN 1
+#define        RSS_MODE_HASH_DST_ADDR_WIDTH 1
+#define        RSS_MODE_HASH_SRC_PORT_LBN 2
+#define        RSS_MODE_HASH_SRC_PORT_WIDTH 1
+#define        RSS_MODE_HASH_DST_PORT_LBN 3
+#define        RSS_MODE_HASH_DST_PORT_WIDTH 1
+#define       RSS_MODE_HASH_SELECTOR_LBN 0
+#define       RSS_MODE_HASH_SELECTOR_WIDTH 8
 
 
 /***********************************/
@@ -4413,7 +5329,9 @@
 
 #define MC_CMD_0x81_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
-/* MC_CMD_INIT_RXQ_IN msgrequest */
+/* MC_CMD_INIT_RXQ_IN msgrequest: Legacy RXQ_INIT request. Use extended version
+ * in new code.
+ */
 #define    MC_CMD_INIT_RXQ_IN_LENMIN 36
 #define    MC_CMD_INIT_RXQ_IN_LENMAX 252
 #define    MC_CMD_INIT_RXQ_IN_LEN(num) (28+8*(num))
@@ -4456,9 +5374,73 @@
 #define       MC_CMD_INIT_RXQ_IN_DMA_ADDR_MINNUM 1
 #define       MC_CMD_INIT_RXQ_IN_DMA_ADDR_MAXNUM 28
 
+/* MC_CMD_INIT_RXQ_EXT_IN msgrequest: Extended RXQ_INIT with additional mode
+ * flags
+ */
+#define    MC_CMD_INIT_RXQ_EXT_IN_LEN 544
+/* Size, in entries */
+#define       MC_CMD_INIT_RXQ_EXT_IN_SIZE_OFST 0
+/* The EVQ to send events to. This is an index originally specified to INIT_EVQ
+ */
+#define       MC_CMD_INIT_RXQ_EXT_IN_TARGET_EVQ_OFST 4
+/* The value to put in the event data. Check hardware spec. for valid range. */
+#define       MC_CMD_INIT_RXQ_EXT_IN_LABEL_OFST 8
+/* Desired instance. Must be set to a specific instance, which is a function
+ * local queue index.
+ */
+#define       MC_CMD_INIT_RXQ_EXT_IN_INSTANCE_OFST 12
+/* There will be more flags here. */
+#define       MC_CMD_INIT_RXQ_EXT_IN_FLAGS_OFST 16
+#define        MC_CMD_INIT_RXQ_EXT_IN_FLAG_BUFF_MODE_LBN 0
+#define        MC_CMD_INIT_RXQ_EXT_IN_FLAG_BUFF_MODE_WIDTH 1
+#define        MC_CMD_INIT_RXQ_EXT_IN_FLAG_HDR_SPLIT_LBN 1
+#define        MC_CMD_INIT_RXQ_EXT_IN_FLAG_HDR_SPLIT_WIDTH 1
+#define        MC_CMD_INIT_RXQ_EXT_IN_FLAG_TIMESTAMP_LBN 2
+#define        MC_CMD_INIT_RXQ_EXT_IN_FLAG_TIMESTAMP_WIDTH 1
+#define        MC_CMD_INIT_RXQ_EXT_IN_CRC_MODE_LBN 3
+#define        MC_CMD_INIT_RXQ_EXT_IN_CRC_MODE_WIDTH 4
+#define        MC_CMD_INIT_RXQ_EXT_IN_FLAG_CHAIN_LBN 7
+#define        MC_CMD_INIT_RXQ_EXT_IN_FLAG_CHAIN_WIDTH 1
+#define        MC_CMD_INIT_RXQ_EXT_IN_FLAG_PREFIX_LBN 8
+#define        MC_CMD_INIT_RXQ_EXT_IN_FLAG_PREFIX_WIDTH 1
+#define        MC_CMD_INIT_RXQ_EXT_IN_FLAG_DISABLE_SCATTER_LBN 9
+#define        MC_CMD_INIT_RXQ_EXT_IN_FLAG_DISABLE_SCATTER_WIDTH 1
+#define        MC_CMD_INIT_RXQ_EXT_IN_DMA_MODE_LBN 10
+#define        MC_CMD_INIT_RXQ_EXT_IN_DMA_MODE_WIDTH 4
+/* enum: One packet per descriptor (for normal networking) */
+#define          MC_CMD_INIT_RXQ_EXT_IN_SINGLE_PACKET  0x0
+/* enum: Pack multiple packets into large descriptors (for SolarCapture) */
+#define          MC_CMD_INIT_RXQ_EXT_IN_PACKED_STREAM  0x1
+#define        MC_CMD_INIT_RXQ_EXT_IN_FLAG_SNAPSHOT_MODE_LBN 14
+#define        MC_CMD_INIT_RXQ_EXT_IN_FLAG_SNAPSHOT_MODE_WIDTH 1
+#define        MC_CMD_INIT_RXQ_EXT_IN_PACKED_STREAM_BUFF_SIZE_LBN 15
+#define        MC_CMD_INIT_RXQ_EXT_IN_PACKED_STREAM_BUFF_SIZE_WIDTH 3
+#define          MC_CMD_INIT_RXQ_EXT_IN_PS_BUFF_1M  0x0 /* enum */
+#define          MC_CMD_INIT_RXQ_EXT_IN_PS_BUFF_512K  0x1 /* enum */
+#define          MC_CMD_INIT_RXQ_EXT_IN_PS_BUFF_256K  0x2 /* enum */
+#define          MC_CMD_INIT_RXQ_EXT_IN_PS_BUFF_128K  0x3 /* enum */
+#define          MC_CMD_INIT_RXQ_EXT_IN_PS_BUFF_64K  0x4 /* enum */
+#define        MC_CMD_INIT_RXQ_EXT_IN_FLAG_WANT_OUTER_CLASSES_LBN 18
+#define        MC_CMD_INIT_RXQ_EXT_IN_FLAG_WANT_OUTER_CLASSES_WIDTH 1
+/* Owner ID to use if in buffer mode (zero if physical) */
+#define       MC_CMD_INIT_RXQ_EXT_IN_OWNER_ID_OFST 20
+/* The port ID associated with the v-adaptor which should contain this DMAQ. */
+#define       MC_CMD_INIT_RXQ_EXT_IN_PORT_ID_OFST 24
+/* 64-bit address of 4k of 4k-aligned host memory buffer */
+#define       MC_CMD_INIT_RXQ_EXT_IN_DMA_ADDR_OFST 28
+#define       MC_CMD_INIT_RXQ_EXT_IN_DMA_ADDR_LEN 8
+#define       MC_CMD_INIT_RXQ_EXT_IN_DMA_ADDR_LO_OFST 28
+#define       MC_CMD_INIT_RXQ_EXT_IN_DMA_ADDR_HI_OFST 32
+#define       MC_CMD_INIT_RXQ_EXT_IN_DMA_ADDR_NUM 64
+/* Maximum length of packet to receive, if SNAPSHOT_MODE flag is set */
+#define       MC_CMD_INIT_RXQ_EXT_IN_SNAPSHOT_LENGTH_OFST 540
+
 /* MC_CMD_INIT_RXQ_OUT msgresponse */
 #define    MC_CMD_INIT_RXQ_OUT_LEN 0
 
+/* MC_CMD_INIT_RXQ_EXT_OUT msgresponse */
+#define    MC_CMD_INIT_RXQ_EXT_OUT_LEN 0
+
 
 /***********************************/
 /* MC_CMD_INIT_TXQ
@@ -4467,7 +5449,9 @@
 
 #define MC_CMD_0x82_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
-/* MC_CMD_INIT_TXQ_IN msgrequest */
+/* MC_CMD_INIT_TXQ_IN msgrequest: Legacy INIT_TXQ request. Use extended version
+ * in new code.
+ */
 #define    MC_CMD_INIT_TXQ_IN_LENMIN 36
 #define    MC_CMD_INIT_TXQ_IN_LENMAX 252
 #define    MC_CMD_INIT_TXQ_IN_LEN(num) (28+8*(num))
@@ -4499,6 +5483,10 @@
 #define        MC_CMD_INIT_TXQ_IN_FLAG_TIMESTAMP_WIDTH 1
 #define        MC_CMD_INIT_TXQ_IN_FLAG_PACER_BYPASS_LBN 9
 #define        MC_CMD_INIT_TXQ_IN_FLAG_PACER_BYPASS_WIDTH 1
+#define        MC_CMD_INIT_TXQ_IN_FLAG_INNER_IP_CSUM_EN_LBN 10
+#define        MC_CMD_INIT_TXQ_IN_FLAG_INNER_IP_CSUM_EN_WIDTH 1
+#define        MC_CMD_INIT_TXQ_IN_FLAG_INNER_TCP_CSUM_EN_LBN 11
+#define        MC_CMD_INIT_TXQ_IN_FLAG_INNER_TCP_CSUM_EN_WIDTH 1
 /* Owner ID to use if in buffer mode (zero if physical) */
 #define       MC_CMD_INIT_TXQ_IN_OWNER_ID_OFST 20
 /* The port ID associated with the v-adaptor which should contain this DMAQ. */
@@ -4511,6 +5499,60 @@
 #define       MC_CMD_INIT_TXQ_IN_DMA_ADDR_MINNUM 1
 #define       MC_CMD_INIT_TXQ_IN_DMA_ADDR_MAXNUM 28
 
+/* MC_CMD_INIT_TXQ_EXT_IN msgrequest: Extended INIT_TXQ with additional mode
+ * flags
+ */
+#define    MC_CMD_INIT_TXQ_EXT_IN_LEN 544
+/* Size, in entries */
+#define       MC_CMD_INIT_TXQ_EXT_IN_SIZE_OFST 0
+/* The EVQ to send events to. This is an index originally specified to
+ * INIT_EVQ.
+ */
+#define       MC_CMD_INIT_TXQ_EXT_IN_TARGET_EVQ_OFST 4
+/* The value to put in the event data. Check hardware spec. for valid range. */
+#define       MC_CMD_INIT_TXQ_EXT_IN_LABEL_OFST 8
+/* Desired instance. Must be set to a specific instance, which is a function
+ * local queue index.
+ */
+#define       MC_CMD_INIT_TXQ_EXT_IN_INSTANCE_OFST 12
+/* There will be more flags here. */
+#define       MC_CMD_INIT_TXQ_EXT_IN_FLAGS_OFST 16
+#define        MC_CMD_INIT_TXQ_EXT_IN_FLAG_BUFF_MODE_LBN 0
+#define        MC_CMD_INIT_TXQ_EXT_IN_FLAG_BUFF_MODE_WIDTH 1
+#define        MC_CMD_INIT_TXQ_EXT_IN_FLAG_IP_CSUM_DIS_LBN 1
+#define        MC_CMD_INIT_TXQ_EXT_IN_FLAG_IP_CSUM_DIS_WIDTH 1
+#define        MC_CMD_INIT_TXQ_EXT_IN_FLAG_TCP_CSUM_DIS_LBN 2
+#define        MC_CMD_INIT_TXQ_EXT_IN_FLAG_TCP_CSUM_DIS_WIDTH 1
+#define        MC_CMD_INIT_TXQ_EXT_IN_FLAG_TCP_UDP_ONLY_LBN 3
+#define        MC_CMD_INIT_TXQ_EXT_IN_FLAG_TCP_UDP_ONLY_WIDTH 1
+#define        MC_CMD_INIT_TXQ_EXT_IN_CRC_MODE_LBN 4
+#define        MC_CMD_INIT_TXQ_EXT_IN_CRC_MODE_WIDTH 4
+#define        MC_CMD_INIT_TXQ_EXT_IN_FLAG_TIMESTAMP_LBN 8
+#define        MC_CMD_INIT_TXQ_EXT_IN_FLAG_TIMESTAMP_WIDTH 1
+#define        MC_CMD_INIT_TXQ_EXT_IN_FLAG_PACER_BYPASS_LBN 9
+#define        MC_CMD_INIT_TXQ_EXT_IN_FLAG_PACER_BYPASS_WIDTH 1
+#define        MC_CMD_INIT_TXQ_EXT_IN_FLAG_INNER_IP_CSUM_EN_LBN 10
+#define        MC_CMD_INIT_TXQ_EXT_IN_FLAG_INNER_IP_CSUM_EN_WIDTH 1
+#define        MC_CMD_INIT_TXQ_EXT_IN_FLAG_INNER_TCP_CSUM_EN_LBN 11
+#define        MC_CMD_INIT_TXQ_EXT_IN_FLAG_INNER_TCP_CSUM_EN_WIDTH 1
+/* Owner ID to use if in buffer mode (zero if physical) */
+#define       MC_CMD_INIT_TXQ_EXT_IN_OWNER_ID_OFST 20
+/* The port ID associated with the v-adaptor which should contain this DMAQ. */
+#define       MC_CMD_INIT_TXQ_EXT_IN_PORT_ID_OFST 24
+/* 64-bit address of 4k of 4k-aligned host memory buffer */
+#define       MC_CMD_INIT_TXQ_EXT_IN_DMA_ADDR_OFST 28
+#define       MC_CMD_INIT_TXQ_EXT_IN_DMA_ADDR_LEN 8
+#define       MC_CMD_INIT_TXQ_EXT_IN_DMA_ADDR_LO_OFST 28
+#define       MC_CMD_INIT_TXQ_EXT_IN_DMA_ADDR_HI_OFST 32
+#define       MC_CMD_INIT_TXQ_EXT_IN_DMA_ADDR_MINNUM 1
+#define       MC_CMD_INIT_TXQ_EXT_IN_DMA_ADDR_MAXNUM 64
+/* Flags related to Qbb flow control mode. */
+#define       MC_CMD_INIT_TXQ_EXT_IN_QBB_FLAGS_OFST 540
+#define        MC_CMD_INIT_TXQ_EXT_IN_QBB_ENABLE_LBN 0
+#define        MC_CMD_INIT_TXQ_EXT_IN_QBB_ENABLE_WIDTH 1
+#define        MC_CMD_INIT_TXQ_EXT_IN_QBB_PRIORITY_LBN 1
+#define        MC_CMD_INIT_TXQ_EXT_IN_QBB_PRIORITY_WIDTH 3
+
 /* MC_CMD_INIT_TXQ_OUT msgresponse */
 #define    MC_CMD_INIT_TXQ_OUT_LEN 0
 
@@ -4617,6 +5659,132 @@
 /* MC_CMD_PROXY_CMD_OUT msgresponse */
 #define    MC_CMD_PROXY_CMD_OUT_LEN 0
 
+/* MC_PROXY_STATUS_BUFFER structuredef: Host memory status buffer used to
+ * manage proxied requests
+ */
+#define    MC_PROXY_STATUS_BUFFER_LEN 16
+/* Handle allocated by the firmware for this proxy transaction */
+#define       MC_PROXY_STATUS_BUFFER_HANDLE_OFST 0
+/* enum: An invalid handle. */
+#define          MC_PROXY_STATUS_BUFFER_HANDLE_INVALID  0x0
+#define       MC_PROXY_STATUS_BUFFER_HANDLE_LBN 0
+#define       MC_PROXY_STATUS_BUFFER_HANDLE_WIDTH 32
+/* The requesting physical function number */
+#define       MC_PROXY_STATUS_BUFFER_PF_OFST 4
+#define       MC_PROXY_STATUS_BUFFER_PF_LEN 2
+#define       MC_PROXY_STATUS_BUFFER_PF_LBN 32
+#define       MC_PROXY_STATUS_BUFFER_PF_WIDTH 16
+/* The requesting virtual function number. Set to VF_NULL if the target is a
+ * PF.
+ */
+#define       MC_PROXY_STATUS_BUFFER_VF_OFST 6
+#define       MC_PROXY_STATUS_BUFFER_VF_LEN 2
+#define       MC_PROXY_STATUS_BUFFER_VF_LBN 48
+#define       MC_PROXY_STATUS_BUFFER_VF_WIDTH 16
+/* The target function RID. */
+#define       MC_PROXY_STATUS_BUFFER_RID_OFST 8
+#define       MC_PROXY_STATUS_BUFFER_RID_LEN 2
+#define       MC_PROXY_STATUS_BUFFER_RID_LBN 64
+#define       MC_PROXY_STATUS_BUFFER_RID_WIDTH 16
+/* The status of the proxy as described in MC_CMD_PROXY_COMPLETE. */
+#define       MC_PROXY_STATUS_BUFFER_STATUS_OFST 10
+#define       MC_PROXY_STATUS_BUFFER_STATUS_LEN 2
+#define       MC_PROXY_STATUS_BUFFER_STATUS_LBN 80
+#define       MC_PROXY_STATUS_BUFFER_STATUS_WIDTH 16
+/* If a request is authorized rather than carried out by the host, this is the
+ * elevated privilege mask granted to the requesting function.
+ */
+#define       MC_PROXY_STATUS_BUFFER_GRANTED_PRIVILEGES_OFST 12
+#define       MC_PROXY_STATUS_BUFFER_GRANTED_PRIVILEGES_LBN 96
+#define       MC_PROXY_STATUS_BUFFER_GRANTED_PRIVILEGES_WIDTH 32
+
+
+/***********************************/
+/* MC_CMD_PROXY_CONFIGURE
+ * Enable/disable authorization of MCDI requests from unprivileged functions by
+ * a designated admin function
+ */
+#define MC_CMD_PROXY_CONFIGURE 0x58
+
+#define MC_CMD_0x58_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
+/* MC_CMD_PROXY_CONFIGURE_IN msgrequest */
+#define    MC_CMD_PROXY_CONFIGURE_IN_LEN 108
+#define       MC_CMD_PROXY_CONFIGURE_IN_FLAGS_OFST 0
+#define        MC_CMD_PROXY_CONFIGURE_IN_ENABLE_LBN 0
+#define        MC_CMD_PROXY_CONFIGURE_IN_ENABLE_WIDTH 1
+/* Host provides a contiguous memory buffer that contains at least NUM_BLOCKS
+ * of blocks, each of the size REQUEST_BLOCK_SIZE.
+ */
+#define       MC_CMD_PROXY_CONFIGURE_IN_STATUS_BUFF_ADDR_OFST 4
+#define       MC_CMD_PROXY_CONFIGURE_IN_STATUS_BUFF_ADDR_LEN 8
+#define       MC_CMD_PROXY_CONFIGURE_IN_STATUS_BUFF_ADDR_LO_OFST 4
+#define       MC_CMD_PROXY_CONFIGURE_IN_STATUS_BUFF_ADDR_HI_OFST 8
+/* Must be a power of 2 */
+#define       MC_CMD_PROXY_CONFIGURE_IN_STATUS_BLOCK_SIZE_OFST 12
+/* Host provides a contiguous memory buffer that contains at least NUM_BLOCKS
+ * of blocks, each of the size REPLY_BLOCK_SIZE.
+ */
+#define       MC_CMD_PROXY_CONFIGURE_IN_REQUEST_BUFF_ADDR_OFST 16
+#define       MC_CMD_PROXY_CONFIGURE_IN_REQUEST_BUFF_ADDR_LEN 8
+#define       MC_CMD_PROXY_CONFIGURE_IN_REQUEST_BUFF_ADDR_LO_OFST 16
+#define       MC_CMD_PROXY_CONFIGURE_IN_REQUEST_BUFF_ADDR_HI_OFST 20
+/* Must be a power of 2 */
+#define       MC_CMD_PROXY_CONFIGURE_IN_REQUEST_BLOCK_SIZE_OFST 24
+/* Host provides a contiguous memory buffer that contains at least NUM_BLOCKS
+ * of blocks, each of the size STATUS_BLOCK_SIZE. This buffer is only needed if
+ * host intends to complete proxied operations by using MC_CMD_PROXY_CMD.
+ */
+#define       MC_CMD_PROXY_CONFIGURE_IN_REPLY_BUFF_ADDR_OFST 28
+#define       MC_CMD_PROXY_CONFIGURE_IN_REPLY_BUFF_ADDR_LEN 8
+#define       MC_CMD_PROXY_CONFIGURE_IN_REPLY_BUFF_ADDR_LO_OFST 28
+#define       MC_CMD_PROXY_CONFIGURE_IN_REPLY_BUFF_ADDR_HI_OFST 32
+/* Must be a power of 2, or zero if this buffer is not provided */
+#define       MC_CMD_PROXY_CONFIGURE_IN_REPLY_BLOCK_SIZE_OFST 36
+/* Applies to all three buffers */
+#define       MC_CMD_PROXY_CONFIGURE_IN_NUM_BLOCKS_OFST 40
+/* A bit mask defining which MCDI operations may be proxied */
+#define       MC_CMD_PROXY_CONFIGURE_IN_ALLOWED_MCDI_MASK_OFST 44
+#define       MC_CMD_PROXY_CONFIGURE_IN_ALLOWED_MCDI_MASK_LEN 64
+
+/* MC_CMD_PROXY_CONFIGURE_OUT msgresponse */
+#define    MC_CMD_PROXY_CONFIGURE_OUT_LEN 0
+
+
+/***********************************/
+/* MC_CMD_PROXY_COMPLETE
+ * Tells FW that a requested proxy operation has either been completed (by
+ * using MC_CMD_PROXY_CMD) or authorized/declined. May only be sent by the
+ * function that enabled proxying/authorization (by using
+ * MC_CMD_PROXY_CONFIGURE).
+ */
+#define MC_CMD_PROXY_COMPLETE 0x5f
+
+#define MC_CMD_0x5f_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
+/* MC_CMD_PROXY_COMPLETE_IN msgrequest */
+#define    MC_CMD_PROXY_COMPLETE_IN_LEN 12
+#define       MC_CMD_PROXY_COMPLETE_IN_BLOCK_INDEX_OFST 0
+#define       MC_CMD_PROXY_COMPLETE_IN_STATUS_OFST 4
+/* enum: The operation has been completed by using MC_CMD_PROXY_CMD, the reply
+ * is stored in the REPLY_BUFF.
+ */
+#define          MC_CMD_PROXY_COMPLETE_IN_COMPLETE 0x0
+/* enum: The operation has been authorized. The originating function may now
+ * try again.
+ */
+#define          MC_CMD_PROXY_COMPLETE_IN_AUTHORIZED 0x1
+/* enum: The operation has been declined. */
+#define          MC_CMD_PROXY_COMPLETE_IN_DECLINED 0x2
+/* enum: The authorization failed because the relevant application did not
+ * respond in time.
+ */
+#define          MC_CMD_PROXY_COMPLETE_IN_TIMEDOUT 0x3
+#define       MC_CMD_PROXY_COMPLETE_IN_HANDLE_OFST 8
+
+/* MC_CMD_PROXY_COMPLETE_OUT msgresponse */
+#define    MC_CMD_PROXY_COMPLETE_OUT_LEN 0
+
 
 /***********************************/
 /* MC_CMD_ALLOC_BUFTBL_CHUNK
@@ -4688,6 +5856,44 @@
 /* MC_CMD_FREE_BUFTBL_CHUNK_OUT msgresponse */
 #define    MC_CMD_FREE_BUFTBL_CHUNK_OUT_LEN 0
 
+/* PORT_CONFIG_ENTRY structuredef */
+#define    PORT_CONFIG_ENTRY_LEN 16
+/* External port number (label) */
+#define       PORT_CONFIG_ENTRY_EXT_NUMBER_OFST 0
+#define       PORT_CONFIG_ENTRY_EXT_NUMBER_LEN 1
+#define       PORT_CONFIG_ENTRY_EXT_NUMBER_LBN 0
+#define       PORT_CONFIG_ENTRY_EXT_NUMBER_WIDTH 8
+/* Port core location */
+#define       PORT_CONFIG_ENTRY_CORE_OFST 1
+#define       PORT_CONFIG_ENTRY_CORE_LEN 1
+#define          PORT_CONFIG_ENTRY_STANDALONE  0x0 /* enum */
+#define          PORT_CONFIG_ENTRY_MASTER  0x1 /* enum */
+#define          PORT_CONFIG_ENTRY_SLAVE  0x2 /* enum */
+#define       PORT_CONFIG_ENTRY_CORE_LBN 8
+#define       PORT_CONFIG_ENTRY_CORE_WIDTH 8
+/* Internal number (HW resource) relative to the core */
+#define       PORT_CONFIG_ENTRY_INT_NUMBER_OFST 2
+#define       PORT_CONFIG_ENTRY_INT_NUMBER_LEN 1
+#define       PORT_CONFIG_ENTRY_INT_NUMBER_LBN 16
+#define       PORT_CONFIG_ENTRY_INT_NUMBER_WIDTH 8
+/* Reserved */
+#define       PORT_CONFIG_ENTRY_RSVD_OFST 3
+#define       PORT_CONFIG_ENTRY_RSVD_LEN 1
+#define       PORT_CONFIG_ENTRY_RSVD_LBN 24
+#define       PORT_CONFIG_ENTRY_RSVD_WIDTH 8
+/* Bitmask of KR lanes used by the port */
+#define       PORT_CONFIG_ENTRY_LANES_OFST 4
+#define       PORT_CONFIG_ENTRY_LANES_LBN 32
+#define       PORT_CONFIG_ENTRY_LANES_WIDTH 32
+/* Port capabilities (MC_CMD_PHY_CAP_*) */
+#define       PORT_CONFIG_ENTRY_SUPPORTED_CAPS_OFST 8
+#define       PORT_CONFIG_ENTRY_SUPPORTED_CAPS_LBN 64
+#define       PORT_CONFIG_ENTRY_SUPPORTED_CAPS_WIDTH 32
+/* Reserved (align to 16 bytes) */
+#define       PORT_CONFIG_ENTRY_RSVD2_OFST 12
+#define       PORT_CONFIG_ENTRY_RSVD2_LBN 96
+#define       PORT_CONFIG_ENTRY_RSVD2_WIDTH 32
+
 
 /***********************************/
 /* MC_CMD_FILTER_OP
@@ -4759,9 +5965,9 @@
 #define          MC_CMD_FILTER_OP_IN_RX_DEST_HOST  0x1
 /* enum: receive to MC */
 #define          MC_CMD_FILTER_OP_IN_RX_DEST_MC  0x2
-/* enum: loop back to port 0 TX MAC */
+/* enum: loop back to TXDP 0 */
 #define          MC_CMD_FILTER_OP_IN_RX_DEST_TX0  0x3
-/* enum: loop back to port 1 TX MAC */
+/* enum: loop back to TXDP 1 */
 #define          MC_CMD_FILTER_OP_IN_RX_DEST_TX1  0x4
 /* receive queue handle (for multiple queue modes, this is the base queue) */
 #define       MC_CMD_FILTER_OP_IN_RX_QUEUE_OFST 24
@@ -4778,9 +5984,7 @@
 #define          MC_CMD_FILTER_OP_IN_RX_MODE_TEST_NEVER_MATCH  0x80000000
 /* RSS context (for RX_MODE_RSS) or .1p mapping handle (for
  * RX_MODE_DOT1P_MAPPING), as returned by MC_CMD_RSS_CONTEXT_ALLOC or
- * MC_CMD_DOT1P_MAPPING_ALLOC. Note that these handles should be considered
- * opaque to the host, although a value of 0xFFFFFFFF is guaranteed never to be
- * a valid handle.
+ * MC_CMD_DOT1P_MAPPING_ALLOC.
  */
 #define       MC_CMD_FILTER_OP_IN_RX_CONTEXT_OFST 32
 /* transmit domain (reserved; set to 0) */
@@ -4835,6 +6039,235 @@
 #define       MC_CMD_FILTER_OP_IN_DST_IP_OFST 92
 #define       MC_CMD_FILTER_OP_IN_DST_IP_LEN 16
 
+/* MC_CMD_FILTER_OP_EXT_IN msgrequest: Extension to MC_CMD_FILTER_OP_IN to
+ * include handling of VXLAN/NVGRE encapsulated frame filtering (which is
+ * supported on Medford only).
+ */
+#define    MC_CMD_FILTER_OP_EXT_IN_LEN 172
+/* identifies the type of operation requested */
+#define       MC_CMD_FILTER_OP_EXT_IN_OP_OFST 0
+/*            Enum values, see field(s): */
+/*               MC_CMD_FILTER_OP_IN/OP */
+/* filter handle (for remove / unsubscribe operations) */
+#define       MC_CMD_FILTER_OP_EXT_IN_HANDLE_OFST 4
+#define       MC_CMD_FILTER_OP_EXT_IN_HANDLE_LEN 8
+#define       MC_CMD_FILTER_OP_EXT_IN_HANDLE_LO_OFST 4
+#define       MC_CMD_FILTER_OP_EXT_IN_HANDLE_HI_OFST 8
+/* The port ID associated with the v-adaptor which should contain this filter.
+ */
+#define       MC_CMD_FILTER_OP_EXT_IN_PORT_ID_OFST 12
+/* fields to include in match criteria */
+#define       MC_CMD_FILTER_OP_EXT_IN_MATCH_FIELDS_OFST 16
+#define        MC_CMD_FILTER_OP_EXT_IN_MATCH_SRC_IP_LBN 0
+#define        MC_CMD_FILTER_OP_EXT_IN_MATCH_SRC_IP_WIDTH 1
+#define        MC_CMD_FILTER_OP_EXT_IN_MATCH_DST_IP_LBN 1
+#define        MC_CMD_FILTER_OP_EXT_IN_MATCH_DST_IP_WIDTH 1
+#define        MC_CMD_FILTER_OP_EXT_IN_MATCH_SRC_MAC_LBN 2
+#define        MC_CMD_FILTER_OP_EXT_IN_MATCH_SRC_MAC_WIDTH 1
+#define        MC_CMD_FILTER_OP_EXT_IN_MATCH_SRC_PORT_LBN 3
+#define        MC_CMD_FILTER_OP_EXT_IN_MATCH_SRC_PORT_WIDTH 1
+#define        MC_CMD_FILTER_OP_EXT_IN_MATCH_DST_MAC_LBN 4
+#define        MC_CMD_FILTER_OP_EXT_IN_MATCH_DST_MAC_WIDTH 1
+#define        MC_CMD_FILTER_OP_EXT_IN_MATCH_DST_PORT_LBN 5
+#define        MC_CMD_FILTER_OP_EXT_IN_MATCH_DST_PORT_WIDTH 1
+#define        MC_CMD_FILTER_OP_EXT_IN_MATCH_ETHER_TYPE_LBN 6
+#define        MC_CMD_FILTER_OP_EXT_IN_MATCH_ETHER_TYPE_WIDTH 1
+#define        MC_CMD_FILTER_OP_EXT_IN_MATCH_INNER_VLAN_LBN 7
+#define        MC_CMD_FILTER_OP_EXT_IN_MATCH_INNER_VLAN_WIDTH 1
+#define        MC_CMD_FILTER_OP_EXT_IN_MATCH_OUTER_VLAN_LBN 8
+#define        MC_CMD_FILTER_OP_EXT_IN_MATCH_OUTER_VLAN_WIDTH 1
+#define        MC_CMD_FILTER_OP_EXT_IN_MATCH_IP_PROTO_LBN 9
+#define        MC_CMD_FILTER_OP_EXT_IN_MATCH_IP_PROTO_WIDTH 1
+#define        MC_CMD_FILTER_OP_EXT_IN_MATCH_FWDEF0_LBN 10
+#define        MC_CMD_FILTER_OP_EXT_IN_MATCH_FWDEF0_WIDTH 1
+#define        MC_CMD_FILTER_OP_EXT_IN_MATCH_VNI_OR_VSID_LBN 11
+#define        MC_CMD_FILTER_OP_EXT_IN_MATCH_VNI_OR_VSID_WIDTH 1
+#define        MC_CMD_FILTER_OP_EXT_IN_MATCH_IFRM_SRC_IP_LBN 12
+#define        MC_CMD_FILTER_OP_EXT_IN_MATCH_IFRM_SRC_IP_WIDTH 1
+#define        MC_CMD_FILTER_OP_EXT_IN_MATCH_IFRM_DST_IP_LBN 13
+#define        MC_CMD_FILTER_OP_EXT_IN_MATCH_IFRM_DST_IP_WIDTH 1
+#define        MC_CMD_FILTER_OP_EXT_IN_MATCH_IFRM_SRC_MAC_LBN 14
+#define        MC_CMD_FILTER_OP_EXT_IN_MATCH_IFRM_SRC_MAC_WIDTH 1
+#define        MC_CMD_FILTER_OP_EXT_IN_MATCH_IFRM_SRC_PORT_LBN 15
+#define        MC_CMD_FILTER_OP_EXT_IN_MATCH_IFRM_SRC_PORT_WIDTH 1
+#define        MC_CMD_FILTER_OP_EXT_IN_MATCH_IFRM_DST_MAC_LBN 16
+#define        MC_CMD_FILTER_OP_EXT_IN_MATCH_IFRM_DST_MAC_WIDTH 1
+#define        MC_CMD_FILTER_OP_EXT_IN_MATCH_IFRM_DST_PORT_LBN 17
+#define        MC_CMD_FILTER_OP_EXT_IN_MATCH_IFRM_DST_PORT_WIDTH 1
+#define        MC_CMD_FILTER_OP_EXT_IN_MATCH_IFRM_ETHER_TYPE_LBN 18
+#define        MC_CMD_FILTER_OP_EXT_IN_MATCH_IFRM_ETHER_TYPE_WIDTH 1
+#define        MC_CMD_FILTER_OP_EXT_IN_MATCH_IFRM_INNER_VLAN_LBN 19
+#define        MC_CMD_FILTER_OP_EXT_IN_MATCH_IFRM_INNER_VLAN_WIDTH 1
+#define        MC_CMD_FILTER_OP_EXT_IN_MATCH_IFRM_OUTER_VLAN_LBN 20
+#define        MC_CMD_FILTER_OP_EXT_IN_MATCH_IFRM_OUTER_VLAN_WIDTH 1
+#define        MC_CMD_FILTER_OP_EXT_IN_MATCH_IFRM_IP_PROTO_LBN 21
+#define        MC_CMD_FILTER_OP_EXT_IN_MATCH_IFRM_IP_PROTO_WIDTH 1
+#define        MC_CMD_FILTER_OP_EXT_IN_MATCH_IFRM_FWDEF0_LBN 22
+#define        MC_CMD_FILTER_OP_EXT_IN_MATCH_IFRM_FWDEF0_WIDTH 1
+#define        MC_CMD_FILTER_OP_EXT_IN_MATCH_IFRM_FWDEF1_LBN 23
+#define        MC_CMD_FILTER_OP_EXT_IN_MATCH_IFRM_FWDEF1_WIDTH 1
+#define        MC_CMD_FILTER_OP_EXT_IN_MATCH_IFRM_UNKNOWN_MCAST_DST_LBN 24
+#define        MC_CMD_FILTER_OP_EXT_IN_MATCH_IFRM_UNKNOWN_MCAST_DST_WIDTH 1
+#define        MC_CMD_FILTER_OP_EXT_IN_MATCH_IFRM_UNKNOWN_UCAST_DST_LBN 25
+#define        MC_CMD_FILTER_OP_EXT_IN_MATCH_IFRM_UNKNOWN_UCAST_DST_WIDTH 1
+#define        MC_CMD_FILTER_OP_EXT_IN_MATCH_UNKNOWN_MCAST_DST_LBN 30
+#define        MC_CMD_FILTER_OP_EXT_IN_MATCH_UNKNOWN_MCAST_DST_WIDTH 1
+#define        MC_CMD_FILTER_OP_EXT_IN_MATCH_UNKNOWN_UCAST_DST_LBN 31
+#define        MC_CMD_FILTER_OP_EXT_IN_MATCH_UNKNOWN_UCAST_DST_WIDTH 1
+/* receive destination */
+#define       MC_CMD_FILTER_OP_EXT_IN_RX_DEST_OFST 20
+/* enum: drop packets */
+#define          MC_CMD_FILTER_OP_EXT_IN_RX_DEST_DROP  0x0
+/* enum: receive to host */
+#define          MC_CMD_FILTER_OP_EXT_IN_RX_DEST_HOST  0x1
+/* enum: receive to MC */
+#define          MC_CMD_FILTER_OP_EXT_IN_RX_DEST_MC  0x2
+/* enum: loop back to TXDP 0 */
+#define          MC_CMD_FILTER_OP_EXT_IN_RX_DEST_TX0  0x3
+/* enum: loop back to TXDP 1 */
+#define          MC_CMD_FILTER_OP_EXT_IN_RX_DEST_TX1  0x4
+/* receive queue handle (for multiple queue modes, this is the base queue) */
+#define       MC_CMD_FILTER_OP_EXT_IN_RX_QUEUE_OFST 24
+/* receive mode */
+#define       MC_CMD_FILTER_OP_EXT_IN_RX_MODE_OFST 28
+/* enum: receive to just the specified queue */
+#define          MC_CMD_FILTER_OP_EXT_IN_RX_MODE_SIMPLE  0x0
+/* enum: receive to multiple queues using RSS context */
+#define          MC_CMD_FILTER_OP_EXT_IN_RX_MODE_RSS  0x1
+/* enum: receive to multiple queues using .1p mapping */
+#define          MC_CMD_FILTER_OP_EXT_IN_RX_MODE_DOT1P_MAPPING  0x2
+/* enum: install a filter entry that will never match; for test purposes only
+ */
+#define          MC_CMD_FILTER_OP_EXT_IN_RX_MODE_TEST_NEVER_MATCH  0x80000000
+/* RSS context (for RX_MODE_RSS) or .1p mapping handle (for
+ * RX_MODE_DOT1P_MAPPING), as returned by MC_CMD_RSS_CONTEXT_ALLOC or
+ * MC_CMD_DOT1P_MAPPING_ALLOC.
+ */
+#define       MC_CMD_FILTER_OP_EXT_IN_RX_CONTEXT_OFST 32
+/* transmit domain (reserved; set to 0) */
+#define       MC_CMD_FILTER_OP_EXT_IN_TX_DOMAIN_OFST 36
+/* transmit destination (either set the MAC and/or PM bits for explicit
+ * control, or set this field to TX_DEST_DEFAULT for sensible default
+ * behaviour)
+ */
+#define       MC_CMD_FILTER_OP_EXT_IN_TX_DEST_OFST 40
+/* enum: request default behaviour (based on filter type) */
+#define          MC_CMD_FILTER_OP_EXT_IN_TX_DEST_DEFAULT  0xffffffff
+#define        MC_CMD_FILTER_OP_EXT_IN_TX_DEST_MAC_LBN 0
+#define        MC_CMD_FILTER_OP_EXT_IN_TX_DEST_MAC_WIDTH 1
+#define        MC_CMD_FILTER_OP_EXT_IN_TX_DEST_PM_LBN 1
+#define        MC_CMD_FILTER_OP_EXT_IN_TX_DEST_PM_WIDTH 1
+/* source MAC address to match (as bytes in network order) */
+#define       MC_CMD_FILTER_OP_EXT_IN_SRC_MAC_OFST 44
+#define       MC_CMD_FILTER_OP_EXT_IN_SRC_MAC_LEN 6
+/* source port to match (as bytes in network order) */
+#define       MC_CMD_FILTER_OP_EXT_IN_SRC_PORT_OFST 50
+#define       MC_CMD_FILTER_OP_EXT_IN_SRC_PORT_LEN 2
+/* destination MAC address to match (as bytes in network order) */
+#define       MC_CMD_FILTER_OP_EXT_IN_DST_MAC_OFST 52
+#define       MC_CMD_FILTER_OP_EXT_IN_DST_MAC_LEN 6
+/* destination port to match (as bytes in network order) */
+#define       MC_CMD_FILTER_OP_EXT_IN_DST_PORT_OFST 58
+#define       MC_CMD_FILTER_OP_EXT_IN_DST_PORT_LEN 2
+/* Ethernet type to match (as bytes in network order) */
+#define       MC_CMD_FILTER_OP_EXT_IN_ETHER_TYPE_OFST 60
+#define       MC_CMD_FILTER_OP_EXT_IN_ETHER_TYPE_LEN 2
+/* Inner VLAN tag to match (as bytes in network order) */
+#define       MC_CMD_FILTER_OP_EXT_IN_INNER_VLAN_OFST 62
+#define       MC_CMD_FILTER_OP_EXT_IN_INNER_VLAN_LEN 2
+/* Outer VLAN tag to match (as bytes in network order) */
+#define       MC_CMD_FILTER_OP_EXT_IN_OUTER_VLAN_OFST 64
+#define       MC_CMD_FILTER_OP_EXT_IN_OUTER_VLAN_LEN 2
+/* IP protocol to match (in low byte; set high byte to 0) */
+#define       MC_CMD_FILTER_OP_EXT_IN_IP_PROTO_OFST 66
+#define       MC_CMD_FILTER_OP_EXT_IN_IP_PROTO_LEN 2
+/* Firmware defined register 0 to match (reserved; set to 0) */
+#define       MC_CMD_FILTER_OP_EXT_IN_FWDEF0_OFST 68
+/* VNI (for VXLAN/Geneve, when IP protocol is UDP) or VSID (for NVGRE, when IP
+ * protocol is GRE) to match (as bytes in network order; set last byte to 0 for
+ * VXLAN/NVGRE, or 1 for Geneve)
+ */
+#define       MC_CMD_FILTER_OP_EXT_IN_VNI_OR_VSID_OFST 72
+#define        MC_CMD_FILTER_OP_EXT_IN_VNI_VALUE_LBN 0
+#define        MC_CMD_FILTER_OP_EXT_IN_VNI_VALUE_WIDTH 24
+#define        MC_CMD_FILTER_OP_EXT_IN_VNI_TYPE_LBN 24
+#define        MC_CMD_FILTER_OP_EXT_IN_VNI_TYPE_WIDTH 8
+/* enum: Match VXLAN traffic with this VNI */
+#define          MC_CMD_FILTER_OP_EXT_IN_VNI_TYPE_VXLAN  0x0
+/* enum: Match Geneve traffic with this VNI */
+#define          MC_CMD_FILTER_OP_EXT_IN_VNI_TYPE_GENEVE  0x1
+/* enum: Reserved for experimental development use */
+#define          MC_CMD_FILTER_OP_EXT_IN_VNI_TYPE_EXPERIMENTAL  0xfe
+#define        MC_CMD_FILTER_OP_EXT_IN_VSID_VALUE_LBN 0
+#define        MC_CMD_FILTER_OP_EXT_IN_VSID_VALUE_WIDTH 24
+#define        MC_CMD_FILTER_OP_EXT_IN_VSID_TYPE_LBN 24
+#define        MC_CMD_FILTER_OP_EXT_IN_VSID_TYPE_WIDTH 8
+/* enum: Match NVGRE traffic with this VSID */
+#define          MC_CMD_FILTER_OP_EXT_IN_VSID_TYPE_NVGRE  0x0
+/* source IP address to match (as bytes in network order; set last 12 bytes to
+ * 0 for IPv4 address)
+ */
+#define       MC_CMD_FILTER_OP_EXT_IN_SRC_IP_OFST 76
+#define       MC_CMD_FILTER_OP_EXT_IN_SRC_IP_LEN 16
+/* destination IP address to match (as bytes in network order; set last 12
+ * bytes to 0 for IPv4 address)
+ */
+#define       MC_CMD_FILTER_OP_EXT_IN_DST_IP_OFST 92
+#define       MC_CMD_FILTER_OP_EXT_IN_DST_IP_LEN 16
+/* VXLAN/NVGRE inner frame source MAC address to match (as bytes in network
+ * order)
+ */
+#define       MC_CMD_FILTER_OP_EXT_IN_IFRM_SRC_MAC_OFST 108
+#define       MC_CMD_FILTER_OP_EXT_IN_IFRM_SRC_MAC_LEN 6
+/* VXLAN/NVGRE inner frame source port to match (as bytes in network order) */
+#define       MC_CMD_FILTER_OP_EXT_IN_IFRM_SRC_PORT_OFST 114
+#define       MC_CMD_FILTER_OP_EXT_IN_IFRM_SRC_PORT_LEN 2
+/* VXLAN/NVGRE inner frame destination MAC address to match (as bytes in
+ * network order)
+ */
+#define       MC_CMD_FILTER_OP_EXT_IN_IFRM_DST_MAC_OFST 116
+#define       MC_CMD_FILTER_OP_EXT_IN_IFRM_DST_MAC_LEN 6
+/* VXLAN/NVGRE inner frame destination port to match (as bytes in network
+ * order)
+ */
+#define       MC_CMD_FILTER_OP_EXT_IN_IFRM_DST_PORT_OFST 122
+#define       MC_CMD_FILTER_OP_EXT_IN_IFRM_DST_PORT_LEN 2
+/* VXLAN/NVGRE inner frame Ethernet type to match (as bytes in network order)
+ */
+#define       MC_CMD_FILTER_OP_EXT_IN_IFRM_ETHER_TYPE_OFST 124
+#define       MC_CMD_FILTER_OP_EXT_IN_IFRM_ETHER_TYPE_LEN 2
+/* VXLAN/NVGRE inner frame Inner VLAN tag to match (as bytes in network order)
+ */
+#define       MC_CMD_FILTER_OP_EXT_IN_IFRM_INNER_VLAN_OFST 126
+#define       MC_CMD_FILTER_OP_EXT_IN_IFRM_INNER_VLAN_LEN 2
+/* VXLAN/NVGRE inner frame Outer VLAN tag to match (as bytes in network order)
+ */
+#define       MC_CMD_FILTER_OP_EXT_IN_IFRM_OUTER_VLAN_OFST 128
+#define       MC_CMD_FILTER_OP_EXT_IN_IFRM_OUTER_VLAN_LEN 2
+/* VXLAN/NVGRE inner frame IP protocol to match (in low byte; set high byte to
+ * 0)
+ */
+#define       MC_CMD_FILTER_OP_EXT_IN_IFRM_IP_PROTO_OFST 130
+#define       MC_CMD_FILTER_OP_EXT_IN_IFRM_IP_PROTO_LEN 2
+/* VXLAN/NVGRE inner frame Firmware defined register 0 to match (reserved; set
+ * to 0)
+ */
+#define       MC_CMD_FILTER_OP_EXT_IN_IFRM_FWDEF0_OFST 132
+/* VXLAN/NVGRE inner frame Firmware defined register 1 to match (reserved; set
+ * to 0)
+ */
+#define       MC_CMD_FILTER_OP_EXT_IN_IFRM_FWDEF1_OFST 136
+/* VXLAN/NVGRE inner frame source IP address to match (as bytes in network
+ * order; set last 12 bytes to 0 for IPv4 address)
+ */
+#define       MC_CMD_FILTER_OP_EXT_IN_IFRM_SRC_IP_OFST 140
+#define       MC_CMD_FILTER_OP_EXT_IN_IFRM_SRC_IP_LEN 16
+/* VXLAN/NVGRE inner frame destination IP address to match (as bytes in network
+ * order; set last 12 bytes to 0 for IPv4 address)
+ */
+#define       MC_CMD_FILTER_OP_EXT_IN_IFRM_DST_IP_OFST 156
+#define       MC_CMD_FILTER_OP_EXT_IN_IFRM_DST_IP_LEN 16
+
 /* MC_CMD_FILTER_OP_OUT msgresponse */
 #define    MC_CMD_FILTER_OP_OUT_LEN 12
 /* identifies the type of operation requested */
@@ -4849,6 +6282,27 @@
 #define       MC_CMD_FILTER_OP_OUT_HANDLE_LEN 8
 #define       MC_CMD_FILTER_OP_OUT_HANDLE_LO_OFST 4
 #define       MC_CMD_FILTER_OP_OUT_HANDLE_HI_OFST 8
+/* enum: guaranteed invalid filter handle (low 32 bits) */
+#define          MC_CMD_FILTER_OP_OUT_HANDLE_LO_INVALID  0xffffffff
+/* enum: guaranteed invalid filter handle (high 32 bits) */
+#define          MC_CMD_FILTER_OP_OUT_HANDLE_HI_INVALID  0xffffffff
+
+/* MC_CMD_FILTER_OP_EXT_OUT msgresponse */
+#define    MC_CMD_FILTER_OP_EXT_OUT_LEN 12
+/* identifies the type of operation requested */
+#define       MC_CMD_FILTER_OP_EXT_OUT_OP_OFST 0
+/*            Enum values, see field(s): */
+/*               MC_CMD_FILTER_OP_EXT_IN/OP */
+/* Returned filter handle (for insert / subscribe operations). Note that these
+ * handles should be considered opaque to the host, although a value of
+ * 0xFFFFFFFF_FFFFFFFF is guaranteed never to be a valid handle.
+ */
+#define       MC_CMD_FILTER_OP_EXT_OUT_HANDLE_OFST 4
+#define       MC_CMD_FILTER_OP_EXT_OUT_HANDLE_LEN 8
+#define       MC_CMD_FILTER_OP_EXT_OUT_HANDLE_LO_OFST 4
+#define       MC_CMD_FILTER_OP_EXT_OUT_HANDLE_HI_OFST 8
+/*            Enum values, see field(s): */
+/*               MC_CMD_FILTER_OP_OUT/HANDLE */
 
 
 /***********************************/
@@ -4865,6 +6319,10 @@
 #define       MC_CMD_GET_PARSER_DISP_INFO_IN_OP_OFST 0
 /* enum: read the list of supported RX filter matches */
 #define          MC_CMD_GET_PARSER_DISP_INFO_IN_OP_GET_SUPPORTED_RX_MATCHES  0x1
+/* enum: read flags indicating restrictions on filter insertion for the calling
+ * client
+ */
+#define          MC_CMD_GET_PARSER_DISP_INFO_IN_OP_GET_RESTRICTIONS  0x2
 
 /* MC_CMD_GET_PARSER_DISP_INFO_OUT msgresponse */
 #define    MC_CMD_GET_PARSER_DISP_INFO_OUT_LENMIN 8
@@ -4884,6 +6342,17 @@
 #define       MC_CMD_GET_PARSER_DISP_INFO_OUT_SUPPORTED_MATCHES_MINNUM 0
 #define       MC_CMD_GET_PARSER_DISP_INFO_OUT_SUPPORTED_MATCHES_MAXNUM 61
 
+/* MC_CMD_GET_PARSER_DISP_RESTRICTIONS_OUT msgresponse */
+#define    MC_CMD_GET_PARSER_DISP_RESTRICTIONS_OUT_LEN 8
+/* identifies the type of operation requested */
+#define       MC_CMD_GET_PARSER_DISP_RESTRICTIONS_OUT_OP_OFST 0
+/*            Enum values, see field(s): */
+/*               MC_CMD_GET_PARSER_DISP_INFO_IN/OP */
+/* bitfield of filter insertion restrictions */
+#define       MC_CMD_GET_PARSER_DISP_RESTRICTIONS_OUT_RESTRICTION_FLAGS_OFST 4
+#define        MC_CMD_GET_PARSER_DISP_RESTRICTIONS_OUT_DST_IP_MCAST_ONLY_LBN 0
+#define        MC_CMD_GET_PARSER_DISP_RESTRICTIONS_OUT_DST_IP_MCAST_ONLY_WIDTH 1
+
 
 /***********************************/
 /* MC_CMD_PARSER_DISP_RW
@@ -4901,8 +6370,10 @@
 #define          MC_CMD_PARSER_DISP_RW_IN_RX_DICPU  0x0
 /* enum: TX dispatcher CPU */
 #define          MC_CMD_PARSER_DISP_RW_IN_TX_DICPU  0x1
-/* enum: Lookup engine */
+/* enum: Lookup engine (with original metadata format) */
 #define          MC_CMD_PARSER_DISP_RW_IN_LUE  0x2
+/* enum: Lookup engine (with requested metadata format) */
+#define          MC_CMD_PARSER_DISP_RW_IN_LUE_VERSIONED_METADATA  0x3
 /* identifies the type of operation requested */
 #define       MC_CMD_PARSER_DISP_RW_IN_OP_OFST 4
 /* enum: read a word of DICPU DMEM or a LUE entry */
@@ -4919,6 +6390,8 @@
 #define       MC_CMD_PARSER_DISP_RW_IN_DMEM_RMW_XOR_VALUE_OFST 12
 /* AND mask (for DMEM read-modify-writes: new = (old & mask) ^ value) */
 #define       MC_CMD_PARSER_DISP_RW_IN_DMEM_RMW_AND_MASK_OFST 16
+/* metadata format (for LUE reads using LUE_VERSIONED_METADATA) */
+#define       MC_CMD_PARSER_DISP_RW_IN_LUE_READ_METADATA_VERSION_OFST 12
 /* value to write (for LUE writes) */
 #define       MC_CMD_PARSER_DISP_RW_IN_LUE_WRITE_VALUE_OFST 12
 #define       MC_CMD_PARSER_DISP_RW_IN_LUE_WRITE_VALUE_LEN 20
@@ -5019,7 +6492,9 @@
 /* The maximum number of VIs that would be useful */
 #define       MC_CMD_ALLOC_VIS_IN_MAX_VI_COUNT_OFST 4
 
-/* MC_CMD_ALLOC_VIS_OUT msgresponse */
+/* MC_CMD_ALLOC_VIS_OUT msgresponse: Huntington-compatible VI_ALLOC request.
+ * Use extended version in new code.
+ */
 #define    MC_CMD_ALLOC_VIS_OUT_LEN 8
 /* The number of VIs allocated on this function */
 #define       MC_CMD_ALLOC_VIS_OUT_VI_COUNT_OFST 0
@@ -5028,6 +6503,17 @@
  */
 #define       MC_CMD_ALLOC_VIS_OUT_VI_BASE_OFST 4
 
+/* MC_CMD_ALLOC_VIS_EXT_OUT msgresponse */
+#define    MC_CMD_ALLOC_VIS_EXT_OUT_LEN 12
+/* The number of VIs allocated on this function */
+#define       MC_CMD_ALLOC_VIS_EXT_OUT_VI_COUNT_OFST 0
+/* The base absolute VI number allocated to this function. Required to
+ * correctly interpret wakeup events.
+ */
+#define       MC_CMD_ALLOC_VIS_EXT_OUT_VI_BASE_OFST 4
+/* Function's port vi_shift value (always 0 on Huntington) */
+#define       MC_CMD_ALLOC_VIS_EXT_OUT_VI_SHIFT_OFST 8
+
 
 /***********************************/
 /* MC_CMD_FREE_VIS
@@ -5114,13 +6600,15 @@
 #define    MC_CMD_GET_VI_ALLOC_INFO_IN_LEN 0
 
 /* MC_CMD_GET_VI_ALLOC_INFO_OUT msgresponse */
-#define    MC_CMD_GET_VI_ALLOC_INFO_OUT_LEN 8
+#define    MC_CMD_GET_VI_ALLOC_INFO_OUT_LEN 12
 /* The number of VIs allocated on this function */
 #define       MC_CMD_GET_VI_ALLOC_INFO_OUT_VI_COUNT_OFST 0
 /* The base absolute VI number allocated to this function. Required to
  * correctly interpret wakeup events.
  */
 #define       MC_CMD_GET_VI_ALLOC_INFO_OUT_VI_BASE_OFST 4
+/* Function's port vi_shift value (always 0 on Huntington) */
+#define       MC_CMD_GET_VI_ALLOC_INFO_OUT_VI_SHIFT_OFST 8
 
 
 /***********************************/
@@ -5575,6 +7063,7 @@
 #define MC_CMD_GET_CAPABILITIES 0xbe
 
 #define MC_CMD_0xbe_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
 /* MC_CMD_GET_CAPABILITIES_IN msgrequest */
 #define    MC_CMD_GET_CAPABILITIES_IN_LEN 0
 
@@ -5582,6 +7071,20 @@
 #define    MC_CMD_GET_CAPABILITIES_OUT_LEN 20
 /* First word of flags. */
 #define       MC_CMD_GET_CAPABILITIES_OUT_FLAGS1_OFST 0
+#define        MC_CMD_GET_CAPABILITIES_OUT_TX_MAC_SECURITY_FILTERING_LBN 12
+#define        MC_CMD_GET_CAPABILITIES_OUT_TX_MAC_SECURITY_FILTERING_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_OUT_ADDITIONAL_RSS_MODES_LBN 13
+#define        MC_CMD_GET_CAPABILITIES_OUT_ADDITIONAL_RSS_MODES_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_OUT_QBB_LBN 14
+#define        MC_CMD_GET_CAPABILITIES_OUT_QBB_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_OUT_RX_PACKED_STREAM_VAR_BUFFERS_LBN 15
+#define        MC_CMD_GET_CAPABILITIES_OUT_RX_PACKED_STREAM_VAR_BUFFERS_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_OUT_RX_RSS_LIMITED_LBN 16
+#define        MC_CMD_GET_CAPABILITIES_OUT_RX_RSS_LIMITED_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_OUT_RX_PACKED_STREAM_LBN 17
+#define        MC_CMD_GET_CAPABILITIES_OUT_RX_PACKED_STREAM_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_OUT_RX_INCLUDE_FCS_LBN 18
+#define        MC_CMD_GET_CAPABILITIES_OUT_RX_INCLUDE_FCS_WIDTH 1
 #define        MC_CMD_GET_CAPABILITIES_OUT_TX_VLAN_INSERTION_LBN 19
 #define        MC_CMD_GET_CAPABILITIES_OUT_TX_VLAN_INSERTION_WIDTH 1
 #define        MC_CMD_GET_CAPABILITIES_OUT_RX_VLAN_STRIPPING_LBN 20
@@ -5600,8 +7103,14 @@
 #define        MC_CMD_GET_CAPABILITIES_OUT_MCAST_FILTER_CHAINING_WIDTH 1
 #define        MC_CMD_GET_CAPABILITIES_OUT_PM_AND_RXDP_COUNTERS_LBN 27
 #define        MC_CMD_GET_CAPABILITIES_OUT_PM_AND_RXDP_COUNTERS_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_OUT_RX_DISABLE_SCATTER_LBN 28
+#define        MC_CMD_GET_CAPABILITIES_OUT_RX_DISABLE_SCATTER_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_OUT_TX_MCAST_UDP_LOOPBACK_LBN 29
+#define        MC_CMD_GET_CAPABILITIES_OUT_TX_MCAST_UDP_LOOPBACK_WIDTH 1
 #define        MC_CMD_GET_CAPABILITIES_OUT_EVB_LBN 30
 #define        MC_CMD_GET_CAPABILITIES_OUT_EVB_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_OUT_VXLAN_NVGRE_LBN 31
+#define        MC_CMD_GET_CAPABILITIES_OUT_VXLAN_NVGRE_WIDTH 1
 /* RxDPCPU firmware id. */
 #define       MC_CMD_GET_CAPABILITIES_OUT_RX_DPCPU_FW_ID_OFST 4
 #define       MC_CMD_GET_CAPABILITIES_OUT_RX_DPCPU_FW_ID_LEN 2
@@ -5609,6 +7118,10 @@
 #define          MC_CMD_GET_CAPABILITIES_OUT_RXDP  0x0
 /* enum: Low latency RXDP firmware */
 #define          MC_CMD_GET_CAPABILITIES_OUT_RXDP_LOW_LATENCY  0x1
+/* enum: Packed stream RXDP firmware */
+#define          MC_CMD_GET_CAPABILITIES_OUT_RXDP_PACKED_STREAM  0x2
+/* enum: BIST RXDP firmware */
+#define          MC_CMD_GET_CAPABILITIES_OUT_RXDP_BIST  0x10a
 /* enum: RXDP Test firmware image 1 */
 #define          MC_CMD_GET_CAPABILITIES_OUT_RXDP_TEST_FW_TO_MC_CUT_THROUGH  0x101
 /* enum: RXDP Test firmware image 2 */
@@ -5632,6 +7145,10 @@
 #define          MC_CMD_GET_CAPABILITIES_OUT_TXDP  0x0
 /* enum: Low latency TXDP firmware */
 #define          MC_CMD_GET_CAPABILITIES_OUT_TXDP_LOW_LATENCY  0x1
+/* enum: High packet rate TXDP firmware */
+#define          MC_CMD_GET_CAPABILITIES_OUT_TXDP_HIGH_PACKET_RATE  0x3
+/* enum: BIST TXDP firmware */
+#define          MC_CMD_GET_CAPABILITIES_OUT_TXDP_BIST  0x12d
 /* enum: TXDP Test firmware image 1 */
 #define          MC_CMD_GET_CAPABILITIES_OUT_TXDP_TEST_FW_TSO_EDIT  0x101
 /* enum: TXDP Test firmware image 2 */
@@ -5642,22 +7159,69 @@
 #define        MC_CMD_GET_CAPABILITIES_OUT_RXPD_FW_VERSION_REV_WIDTH 12
 #define        MC_CMD_GET_CAPABILITIES_OUT_RXPD_FW_VERSION_TYPE_LBN 12
 #define        MC_CMD_GET_CAPABILITIES_OUT_RXPD_FW_VERSION_TYPE_WIDTH 4
-#define          MC_CMD_GET_CAPABILITIES_OUT_RXPD_FW_TYPE_FIRST_PKT  0x1 /* enum */
-#define          MC_CMD_GET_CAPABILITIES_OUT_RXPD_FW_TYPE_SIENA_COMPAT  0x2 /* enum */
-#define          MC_CMD_GET_CAPABILITIES_OUT_RXPD_FW_TYPE_VSWITCH  0x3 /* enum */
-#define          MC_CMD_GET_CAPABILITIES_OUT_RXPD_FW_TYPE_SIENA_COMPAT_PM  0x4 /* enum */
-#define          MC_CMD_GET_CAPABILITIES_OUT_RXPD_FW_TYPE_LOW_LATENCY  0x5 /* enum */
+/* enum: reserved value - do not use (may indicate alternative interpretation
+ * of REV field in future)
+ */
+#define          MC_CMD_GET_CAPABILITIES_OUT_RXPD_FW_TYPE_RESERVED  0x0
+/* enum: Trivial RX PD firmware for early Huntington development (Huntington
+ * development only)
+ */
+#define          MC_CMD_GET_CAPABILITIES_OUT_RXPD_FW_TYPE_FIRST_PKT  0x1
+/* enum: RX PD firmware with approximately Siena-compatible behaviour
+ * (Huntington development only)
+ */
+#define          MC_CMD_GET_CAPABILITIES_OUT_RXPD_FW_TYPE_SIENA_COMPAT  0x2
+/* enum: Virtual switching (full feature) RX PD production firmware */
+#define          MC_CMD_GET_CAPABILITIES_OUT_RXPD_FW_TYPE_VSWITCH  0x3
+/* enum: siena_compat variant RX PD firmware using PM rather than MAC
+ * (Huntington development only)
+ */
+#define          MC_CMD_GET_CAPABILITIES_OUT_RXPD_FW_TYPE_SIENA_COMPAT_PM  0x4
+/* enum: Low latency RX PD production firmware */
+#define          MC_CMD_GET_CAPABILITIES_OUT_RXPD_FW_TYPE_LOW_LATENCY  0x5
+/* enum: Packed stream RX PD production firmware */
+#define          MC_CMD_GET_CAPABILITIES_OUT_RXPD_FW_TYPE_PACKED_STREAM  0x6
+/* enum: RX PD firmware handling layer 2 only for high packet rate performance
+ * tests (Medford development only)
+ */
+#define          MC_CMD_GET_CAPABILITIES_OUT_RXPD_FW_TYPE_LAYER2_PERF  0x7
+/* enum: RX PD firmware for GUE parsing prototype (Medford development only) */
+#define          MC_CMD_GET_CAPABILITIES_OUT_RXPD_FW_TYPE_TESTFW_GUE_PROTOTYPE  0xe
+/* enum: RX PD firmware parsing but not filtering network overlay tunnel
+ * encapsulations (Medford development only)
+ */
+#define          MC_CMD_GET_CAPABILITIES_OUT_RXPD_FW_TYPE_TESTFW_ENCAP_PARSING_ONLY  0xf
 #define       MC_CMD_GET_CAPABILITIES_OUT_TXPD_FW_VERSION_OFST 10
 #define       MC_CMD_GET_CAPABILITIES_OUT_TXPD_FW_VERSION_LEN 2
 #define        MC_CMD_GET_CAPABILITIES_OUT_TXPD_FW_VERSION_REV_LBN 0
 #define        MC_CMD_GET_CAPABILITIES_OUT_TXPD_FW_VERSION_REV_WIDTH 12
 #define        MC_CMD_GET_CAPABILITIES_OUT_TXPD_FW_VERSION_TYPE_LBN 12
 #define        MC_CMD_GET_CAPABILITIES_OUT_TXPD_FW_VERSION_TYPE_WIDTH 4
-#define          MC_CMD_GET_CAPABILITIES_OUT_TXPD_FW_TYPE_FIRST_PKT  0x1 /* enum */
-#define          MC_CMD_GET_CAPABILITIES_OUT_TXPD_FW_TYPE_SIENA_COMPAT  0x2 /* enum */
-#define          MC_CMD_GET_CAPABILITIES_OUT_TXPD_FW_TYPE_VSWITCH  0x3 /* enum */
-#define          MC_CMD_GET_CAPABILITIES_OUT_TXPD_FW_TYPE_SIENA_COMPAT_PM  0x4 /* enum */
+/* enum: reserved value - do not use (may indicate alternative interpretation
+ * of REV field in future)
+ */
+#define          MC_CMD_GET_CAPABILITIES_OUT_TXPD_FW_TYPE_RESERVED  0x0
+/* enum: Trivial TX PD firmware for early Huntington development (Huntington
+ * development only)
+ */
+#define          MC_CMD_GET_CAPABILITIES_OUT_TXPD_FW_TYPE_FIRST_PKT  0x1
+/* enum: TX PD firmware with approximately Siena-compatible behaviour
+ * (Huntington development only)
+ */
+#define          MC_CMD_GET_CAPABILITIES_OUT_TXPD_FW_TYPE_SIENA_COMPAT  0x2
+/* enum: Virtual switching (full feature) TX PD production firmware */
+#define          MC_CMD_GET_CAPABILITIES_OUT_TXPD_FW_TYPE_VSWITCH  0x3
+/* enum: siena_compat variant TX PD firmware using PM rather than MAC
+ * (Huntington development only)
+ */
+#define          MC_CMD_GET_CAPABILITIES_OUT_TXPD_FW_TYPE_SIENA_COMPAT_PM  0x4
 #define          MC_CMD_GET_CAPABILITIES_OUT_TXPD_FW_TYPE_LOW_LATENCY  0x5 /* enum */
+/* enum: TX PD firmware handling layer 2 only for high packet rate performance
+ * tests (Medford development only)
+ */
+#define          MC_CMD_GET_CAPABILITIES_OUT_TXPD_FW_TYPE_LAYER2_PERF  0x7
+/* enum: RX PD firmware for GUE parsing prototype (Medford development only) */
+#define          MC_CMD_GET_CAPABILITIES_OUT_TXPD_FW_TYPE_TESTFW_GUE_PROTOTYPE  0xe
 /* Hardware capabilities of NIC */
 #define       MC_CMD_GET_CAPABILITIES_OUT_HW_CAPABILITIES_OFST 12
 /* Licensed capabilities */
@@ -5735,6 +7299,15 @@
 /* the rate in mbps */
 #define       MC_CMD_TCM_BUCKET_INIT_IN_RATE_OFST 4
 
+/* MC_CMD_TCM_BUCKET_INIT_EXT_IN msgrequest */
+#define    MC_CMD_TCM_BUCKET_INIT_EXT_IN_LEN 12
+/* the bucket id */
+#define       MC_CMD_TCM_BUCKET_INIT_EXT_IN_BUCKET_OFST 0
+/* the rate in mbps */
+#define       MC_CMD_TCM_BUCKET_INIT_EXT_IN_RATE_OFST 4
+/* the desired maximum fill level */
+#define       MC_CMD_TCM_BUCKET_INIT_EXT_IN_MAX_FILL_OFST 8
+
 /* MC_CMD_TCM_BUCKET_INIT_OUT msgresponse */
 #define    MC_CMD_TCM_BUCKET_INIT_OUT_LEN 0
 
@@ -5753,8 +7326,14 @@
 #define       MC_CMD_TCM_TXQ_INIT_IN_QID_OFST 0
 /* the static priority associated with the txq */
 #define       MC_CMD_TCM_TXQ_INIT_IN_LABEL_OFST 4
-/* bitmask of the priority queues this txq is inserted into */
+/* bitmask of the priority queues this txq is inserted into when inserted. */
 #define       MC_CMD_TCM_TXQ_INIT_IN_PQ_FLAGS_OFST 8
+#define        MC_CMD_TCM_TXQ_INIT_IN_PQ_FLAG_GUARANTEED_LBN 0
+#define        MC_CMD_TCM_TXQ_INIT_IN_PQ_FLAG_GUARANTEED_WIDTH 1
+#define        MC_CMD_TCM_TXQ_INIT_IN_PQ_FLAG_NORMAL_LBN 1
+#define        MC_CMD_TCM_TXQ_INIT_IN_PQ_FLAG_NORMAL_WIDTH 1
+#define        MC_CMD_TCM_TXQ_INIT_IN_PQ_FLAG_LOW_LBN 2
+#define        MC_CMD_TCM_TXQ_INIT_IN_PQ_FLAG_LOW_WIDTH 1
 /* the reaction point (RP) bucket */
 #define       MC_CMD_TCM_TXQ_INIT_IN_RP_BKT_OFST 12
 /* an already reserved bucket (typically set to bucket associated with outer
@@ -5768,6 +7347,35 @@
 /* the min bucket (typically for ETS/minimum bandwidth) */
 #define       MC_CMD_TCM_TXQ_INIT_IN_MIN_BKT_OFST 24
 
+/* MC_CMD_TCM_TXQ_INIT_EXT_IN msgrequest */
+#define    MC_CMD_TCM_TXQ_INIT_EXT_IN_LEN 32
+/* the txq id */
+#define       MC_CMD_TCM_TXQ_INIT_EXT_IN_QID_OFST 0
+/* the static priority associated with the txq */
+#define       MC_CMD_TCM_TXQ_INIT_EXT_IN_LABEL_NORMAL_OFST 4
+/* bitmask of the priority queues this txq is inserted into when inserted. */
+#define       MC_CMD_TCM_TXQ_INIT_EXT_IN_PQ_FLAGS_OFST 8
+#define        MC_CMD_TCM_TXQ_INIT_EXT_IN_PQ_FLAG_GUARANTEED_LBN 0
+#define        MC_CMD_TCM_TXQ_INIT_EXT_IN_PQ_FLAG_GUARANTEED_WIDTH 1
+#define        MC_CMD_TCM_TXQ_INIT_EXT_IN_PQ_FLAG_NORMAL_LBN 1
+#define        MC_CMD_TCM_TXQ_INIT_EXT_IN_PQ_FLAG_NORMAL_WIDTH 1
+#define        MC_CMD_TCM_TXQ_INIT_EXT_IN_PQ_FLAG_LOW_LBN 2
+#define        MC_CMD_TCM_TXQ_INIT_EXT_IN_PQ_FLAG_LOW_WIDTH 1
+/* the reaction point (RP) bucket */
+#define       MC_CMD_TCM_TXQ_INIT_EXT_IN_RP_BKT_OFST 12
+/* an already reserved bucket (typically set to bucket associated with outer
+ * vswitch)
+ */
+#define       MC_CMD_TCM_TXQ_INIT_EXT_IN_MAX_BKT1_OFST 16
+/* an already reserved bucket (typically set to bucket associated with inner
+ * vswitch)
+ */
+#define       MC_CMD_TCM_TXQ_INIT_EXT_IN_MAX_BKT2_OFST 20
+/* the min bucket (typically for ETS/minimum bandwidth) */
+#define       MC_CMD_TCM_TXQ_INIT_EXT_IN_MIN_BKT_OFST 24
+/* the static priority associated with the txq */
+#define       MC_CMD_TCM_TXQ_INIT_EXT_IN_LABEL_GUARANTEED_OFST 28
+
 /* MC_CMD_TCM_TXQ_INIT_OUT msgresponse */
 #define    MC_CMD_TCM_TXQ_INIT_OUT_LEN 0
 
@@ -5826,13 +7434,23 @@
 #define          MC_CMD_VSWITCH_ALLOC_IN_VSWITCH_TYPE_VLAN  0x1
 /* enum: VEB */
 #define          MC_CMD_VSWITCH_ALLOC_IN_VSWITCH_TYPE_VEB  0x2
-/* enum: VEPA */
+/* enum: VEPA (obsolete) */
 #define          MC_CMD_VSWITCH_ALLOC_IN_VSWITCH_TYPE_VEPA  0x3
+/* enum: MUX */
+#define          MC_CMD_VSWITCH_ALLOC_IN_VSWITCH_TYPE_MUX  0x4
+/* enum: Snapper specific; semantics TBD */
+#define          MC_CMD_VSWITCH_ALLOC_IN_VSWITCH_TYPE_TEST  0x5
 /* Flags controlling v-port creation */
 #define       MC_CMD_VSWITCH_ALLOC_IN_FLAGS_OFST 8
 #define        MC_CMD_VSWITCH_ALLOC_IN_FLAG_AUTO_PORT_LBN 0
 #define        MC_CMD_VSWITCH_ALLOC_IN_FLAG_AUTO_PORT_WIDTH 1
-/* The number of VLAN tags to support. */
+/* The number of VLAN tags to allow for attached v-ports. For VLAN aggregators,
+ * this must be one or greated, and the attached v-ports must have exactly this
+ * number of tags. For other v-switch types, this must be zero of greater, and
+ * is an upper limit on the number of VLAN tags for attached v-ports. An error
+ * will be returned if existing configuration means we can't support attached
+ * v-ports with this number of tags.
+ */
 #define       MC_CMD_VSWITCH_ALLOC_IN_NUM_VLAN_TAGS_OFST 12
 
 /* MC_CMD_VSWITCH_ALLOC_OUT msgresponse */
@@ -5892,7 +7510,10 @@
 #define       MC_CMD_VPORT_ALLOC_IN_FLAGS_OFST 8
 #define        MC_CMD_VPORT_ALLOC_IN_FLAG_AUTO_PORT_LBN 0
 #define        MC_CMD_VPORT_ALLOC_IN_FLAG_AUTO_PORT_WIDTH 1
-/* The number of VLAN tags to insert/remove. */
+/* The number of VLAN tags to insert/remove. An error will be returned if
+ * incompatible with the number of VLAN tags specified for the upstream
+ * v-switch.
+ */
 #define       MC_CMD_VPORT_ALLOC_IN_NUM_VLAN_TAGS_OFST 12
 /* The actual VLAN tags to insert/remove */
 #define       MC_CMD_VPORT_ALLOC_IN_VLAN_TAGS_OFST 16
@@ -6136,8 +7757,13 @@
 
 /* MC_CMD_RSS_CONTEXT_ALLOC_OUT msgresponse */
 #define    MC_CMD_RSS_CONTEXT_ALLOC_OUT_LEN 4
-/* The handle of the new RSS context */
+/* The handle of the new RSS context. This should be considered opaque to the
+ * host, although a value of 0xFFFFFFFF is guaranteed never to be a valid
+ * handle.
+ */
 #define       MC_CMD_RSS_CONTEXT_ALLOC_OUT_RSS_CONTEXT_ID_OFST 0
+/* enum: guaranteed invalid RSS context handle value */
+#define          MC_CMD_RSS_CONTEXT_ALLOC_OUT_RSS_CONTEXT_ID_INVALID  0xffffffff
 
 
 /***********************************/
@@ -6249,7 +7875,11 @@
 #define    MC_CMD_RSS_CONTEXT_SET_FLAGS_IN_LEN 8
 /* The handle of the RSS context */
 #define       MC_CMD_RSS_CONTEXT_SET_FLAGS_IN_RSS_CONTEXT_ID_OFST 0
-/* Hash control flags */
+/* Hash control flags. The _EN bits are always supported. The _MODE bits only
+ * work when the firmware reports ADDITIONAL_RSS_MODES in
+ * MC_CMD_GET_CAPABILITIES and override the _EN bits if any of them are not 0.
+ * See the RSS_MODE structure for the meaning of the mode bits.
+ */
 #define       MC_CMD_RSS_CONTEXT_SET_FLAGS_IN_FLAGS_OFST 4
 #define        MC_CMD_RSS_CONTEXT_SET_FLAGS_IN_TOEPLITZ_IPV4_EN_LBN 0
 #define        MC_CMD_RSS_CONTEXT_SET_FLAGS_IN_TOEPLITZ_IPV4_EN_WIDTH 1
@@ -6259,6 +7889,20 @@
 #define        MC_CMD_RSS_CONTEXT_SET_FLAGS_IN_TOEPLITZ_IPV6_EN_WIDTH 1
 #define        MC_CMD_RSS_CONTEXT_SET_FLAGS_IN_TOEPLITZ_TCPV6_EN_LBN 3
 #define        MC_CMD_RSS_CONTEXT_SET_FLAGS_IN_TOEPLITZ_TCPV6_EN_WIDTH 1
+#define        MC_CMD_RSS_CONTEXT_SET_FLAGS_IN_RESERVED_LBN 4
+#define        MC_CMD_RSS_CONTEXT_SET_FLAGS_IN_RESERVED_WIDTH 4
+#define        MC_CMD_RSS_CONTEXT_SET_FLAGS_IN_TCP_IPV4_RSS_MODE_LBN 8
+#define        MC_CMD_RSS_CONTEXT_SET_FLAGS_IN_TCP_IPV4_RSS_MODE_WIDTH 4
+#define        MC_CMD_RSS_CONTEXT_SET_FLAGS_IN_UDP_IPV4_RSS_MODE_LBN 12
+#define        MC_CMD_RSS_CONTEXT_SET_FLAGS_IN_UDP_IPV4_RSS_MODE_WIDTH 4
+#define        MC_CMD_RSS_CONTEXT_SET_FLAGS_IN_OTHER_IPV4_RSS_MODE_LBN 16
+#define        MC_CMD_RSS_CONTEXT_SET_FLAGS_IN_OTHER_IPV4_RSS_MODE_WIDTH 4
+#define        MC_CMD_RSS_CONTEXT_SET_FLAGS_IN_TCP_IPV6_RSS_MODE_LBN 20
+#define        MC_CMD_RSS_CONTEXT_SET_FLAGS_IN_TCP_IPV6_RSS_MODE_WIDTH 4
+#define        MC_CMD_RSS_CONTEXT_SET_FLAGS_IN_UDP_IPV6_RSS_MODE_LBN 24
+#define        MC_CMD_RSS_CONTEXT_SET_FLAGS_IN_UDP_IPV6_RSS_MODE_WIDTH 4
+#define        MC_CMD_RSS_CONTEXT_SET_FLAGS_IN_OTHER_IPV6_RSS_MODE_LBN 28
+#define        MC_CMD_RSS_CONTEXT_SET_FLAGS_IN_OTHER_IPV6_RSS_MODE_WIDTH 4
 
 /* MC_CMD_RSS_CONTEXT_SET_FLAGS_OUT msgresponse */
 #define    MC_CMD_RSS_CONTEXT_SET_FLAGS_OUT_LEN 0
@@ -6279,7 +7923,12 @@
 
 /* MC_CMD_RSS_CONTEXT_GET_FLAGS_OUT msgresponse */
 #define    MC_CMD_RSS_CONTEXT_GET_FLAGS_OUT_LEN 8
-/* Hash control flags */
+/* Hash control flags. If any _MODE bits are non-zero (which will only be true
+ * when the firmware reports ADDITIONAL_RSS_MODES) then the _EN bits should be
+ * disregarded (but are guaranteed to be consistent with the _MODE bits if
+ * RSS_CONTEXT_SET_FLAGS has never been called for this context since it was
+ * allocated).
+ */
 #define       MC_CMD_RSS_CONTEXT_GET_FLAGS_OUT_FLAGS_OFST 4
 #define        MC_CMD_RSS_CONTEXT_GET_FLAGS_OUT_TOEPLITZ_IPV4_EN_LBN 0
 #define        MC_CMD_RSS_CONTEXT_GET_FLAGS_OUT_TOEPLITZ_IPV4_EN_WIDTH 1
@@ -6289,6 +7938,20 @@
 #define        MC_CMD_RSS_CONTEXT_GET_FLAGS_OUT_TOEPLITZ_IPV6_EN_WIDTH 1
 #define        MC_CMD_RSS_CONTEXT_GET_FLAGS_OUT_TOEPLITZ_TCPV6_EN_LBN 3
 #define        MC_CMD_RSS_CONTEXT_GET_FLAGS_OUT_TOEPLITZ_TCPV6_EN_WIDTH 1
+#define        MC_CMD_RSS_CONTEXT_GET_FLAGS_OUT_RESERVED_LBN 4
+#define        MC_CMD_RSS_CONTEXT_GET_FLAGS_OUT_RESERVED_WIDTH 4
+#define        MC_CMD_RSS_CONTEXT_GET_FLAGS_OUT_TCP_IPV4_RSS_MODE_LBN 8
+#define        MC_CMD_RSS_CONTEXT_GET_FLAGS_OUT_TCP_IPV4_RSS_MODE_WIDTH 4
+#define        MC_CMD_RSS_CONTEXT_GET_FLAGS_OUT_UDP_IPV4_RSS_MODE_LBN 12
+#define        MC_CMD_RSS_CONTEXT_GET_FLAGS_OUT_UDP_IPV4_RSS_MODE_WIDTH 4
+#define        MC_CMD_RSS_CONTEXT_GET_FLAGS_OUT_OTHER_IPV4_RSS_MODE_LBN 16
+#define        MC_CMD_RSS_CONTEXT_GET_FLAGS_OUT_OTHER_IPV4_RSS_MODE_WIDTH 4
+#define        MC_CMD_RSS_CONTEXT_GET_FLAGS_OUT_TCP_IPV6_RSS_MODE_LBN 20
+#define        MC_CMD_RSS_CONTEXT_GET_FLAGS_OUT_TCP_IPV6_RSS_MODE_WIDTH 4
+#define        MC_CMD_RSS_CONTEXT_GET_FLAGS_OUT_UDP_IPV6_RSS_MODE_LBN 24
+#define        MC_CMD_RSS_CONTEXT_GET_FLAGS_OUT_UDP_IPV6_RSS_MODE_WIDTH 4
+#define        MC_CMD_RSS_CONTEXT_GET_FLAGS_OUT_OTHER_IPV6_RSS_MODE_LBN 28
+#define        MC_CMD_RSS_CONTEXT_GET_FLAGS_OUT_OTHER_IPV6_RSS_MODE_WIDTH 4
 
 
 /***********************************/
@@ -6311,8 +7974,13 @@
 
 /* MC_CMD_DOT1P_MAPPING_ALLOC_OUT msgresponse */
 #define    MC_CMD_DOT1P_MAPPING_ALLOC_OUT_LEN 4
-/* The handle of the new .1p mapping */
+/* The handle of the new .1p mapping. This should be considered opaque to the
+ * host, although a value of 0xFFFFFFFF is guaranteed never to be a valid
+ * handle.
+ */
 #define       MC_CMD_DOT1P_MAPPING_ALLOC_OUT_DOT1P_MAPPING_ID_OFST 0
+/* enum: guaranteed invalid .1p mapping handle value */
+#define          MC_CMD_DOT1P_MAPPING_ALLOC_OUT_DOT1P_MAPPING_ID_INVALID  0xffffffff
 
 
 /***********************************/
@@ -6421,401 +8089,32 @@
 
 
 /***********************************/
-/* MC_CMD_RMON_RX_CLASS_STATS
- * Retrieve rmon rx class statistics
+/* MC_CMD_VPORT_ADD_MAC_ADDRESS
+ * Add a MAC address to a v-port
  */
-#define MC_CMD_RMON_RX_CLASS_STATS 0xc3
-
-/* MC_CMD_RMON_RX_CLASS_STATS_IN msgrequest */
-#define    MC_CMD_RMON_RX_CLASS_STATS_IN_LEN 4
-/* flags */
-#define       MC_CMD_RMON_RX_CLASS_STATS_IN_FLAGS_OFST 0
-#define        MC_CMD_RMON_RX_CLASS_STATS_IN_CLASS_LBN 0
-#define        MC_CMD_RMON_RX_CLASS_STATS_IN_CLASS_WIDTH 8
-#define        MC_CMD_RMON_RX_CLASS_STATS_IN_RST_LBN 8
-#define        MC_CMD_RMON_RX_CLASS_STATS_IN_RST_WIDTH 1
-
-/* MC_CMD_RMON_RX_CLASS_STATS_OUT msgresponse */
-#define    MC_CMD_RMON_RX_CLASS_STATS_OUT_LENMIN 4
-#define    MC_CMD_RMON_RX_CLASS_STATS_OUT_LENMAX 252
-#define    MC_CMD_RMON_RX_CLASS_STATS_OUT_LEN(num) (0+4*(num))
-/* Array of stats */
-#define       MC_CMD_RMON_RX_CLASS_STATS_OUT_BUFFER_OFST 0
-#define       MC_CMD_RMON_RX_CLASS_STATS_OUT_BUFFER_LEN 4
-#define       MC_CMD_RMON_RX_CLASS_STATS_OUT_BUFFER_MINNUM 1
-#define       MC_CMD_RMON_RX_CLASS_STATS_OUT_BUFFER_MAXNUM 63
-
+#define MC_CMD_VPORT_ADD_MAC_ADDRESS 0xa8
 
-/***********************************/
-/* MC_CMD_RMON_TX_CLASS_STATS
- * Retrieve rmon tx class statistics
- */
-#define MC_CMD_RMON_TX_CLASS_STATS 0xc4
+#define MC_CMD_0xa8_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
-/* MC_CMD_RMON_TX_CLASS_STATS_IN msgrequest */
-#define    MC_CMD_RMON_TX_CLASS_STATS_IN_LEN 4
-/* flags */
-#define       MC_CMD_RMON_TX_CLASS_STATS_IN_FLAGS_OFST 0
-#define        MC_CMD_RMON_TX_CLASS_STATS_IN_CLASS_LBN 0
-#define        MC_CMD_RMON_TX_CLASS_STATS_IN_CLASS_WIDTH 8
-#define        MC_CMD_RMON_TX_CLASS_STATS_IN_RST_LBN 8
-#define        MC_CMD_RMON_TX_CLASS_STATS_IN_RST_WIDTH 1
+/* MC_CMD_VPORT_ADD_MAC_ADDRESS_IN msgrequest */
+#define    MC_CMD_VPORT_ADD_MAC_ADDRESS_IN_LEN 10
+/* The handle of the v-port */
+#define       MC_CMD_VPORT_ADD_MAC_ADDRESS_IN_VPORT_ID_OFST 0
+/* MAC address to add */
+#define       MC_CMD_VPORT_ADD_MAC_ADDRESS_IN_MACADDR_OFST 4
+#define       MC_CMD_VPORT_ADD_MAC_ADDRESS_IN_MACADDR_LEN 6
 
-/* MC_CMD_RMON_TX_CLASS_STATS_OUT msgresponse */
-#define    MC_CMD_RMON_TX_CLASS_STATS_OUT_LENMIN 4
-#define    MC_CMD_RMON_TX_CLASS_STATS_OUT_LENMAX 252
-#define    MC_CMD_RMON_TX_CLASS_STATS_OUT_LEN(num) (0+4*(num))
-/* Array of stats */
-#define       MC_CMD_RMON_TX_CLASS_STATS_OUT_BUFFER_OFST 0
-#define       MC_CMD_RMON_TX_CLASS_STATS_OUT_BUFFER_LEN 4
-#define       MC_CMD_RMON_TX_CLASS_STATS_OUT_BUFFER_MINNUM 1
-#define       MC_CMD_RMON_TX_CLASS_STATS_OUT_BUFFER_MAXNUM 63
+/* MC_CMD_VPORT_ADD_MAC_ADDRESS_OUT msgresponse */
+#define    MC_CMD_VPORT_ADD_MAC_ADDRESS_OUT_LEN 0
 
 
 /***********************************/
-/* MC_CMD_RMON_RX_SUPER_CLASS_STATS
- * Retrieve rmon rx super_class statistics
+/* MC_CMD_VPORT_DEL_MAC_ADDRESS
+ * Delete a MAC address from a v-port
  */
-#define MC_CMD_RMON_RX_SUPER_CLASS_STATS 0xc5
-
-/* MC_CMD_RMON_RX_SUPER_CLASS_STATS_IN msgrequest */
-#define    MC_CMD_RMON_RX_SUPER_CLASS_STATS_IN_LEN 4
-/* flags */
-#define       MC_CMD_RMON_RX_SUPER_CLASS_STATS_IN_FLAGS_OFST 0
-#define        MC_CMD_RMON_RX_SUPER_CLASS_STATS_IN_SUPER_CLASS_LBN 0
-#define        MC_CMD_RMON_RX_SUPER_CLASS_STATS_IN_SUPER_CLASS_WIDTH 4
-#define        MC_CMD_RMON_RX_SUPER_CLASS_STATS_IN_RST_LBN 4
-#define        MC_CMD_RMON_RX_SUPER_CLASS_STATS_IN_RST_WIDTH 1
-
-/* MC_CMD_RMON_RX_SUPER_CLASS_STATS_OUT msgresponse */
-#define    MC_CMD_RMON_RX_SUPER_CLASS_STATS_OUT_LENMIN 4
-#define    MC_CMD_RMON_RX_SUPER_CLASS_STATS_OUT_LENMAX 252
-#define    MC_CMD_RMON_RX_SUPER_CLASS_STATS_OUT_LEN(num) (0+4*(num))
-/* Array of stats */
-#define       MC_CMD_RMON_RX_SUPER_CLASS_STATS_OUT_BUFFER_OFST 0
-#define       MC_CMD_RMON_RX_SUPER_CLASS_STATS_OUT_BUFFER_LEN 4
-#define       MC_CMD_RMON_RX_SUPER_CLASS_STATS_OUT_BUFFER_MINNUM 1
-#define       MC_CMD_RMON_RX_SUPER_CLASS_STATS_OUT_BUFFER_MAXNUM 63
+#define MC_CMD_VPORT_DEL_MAC_ADDRESS 0xa9
 
-
-/***********************************/
-/* MC_CMD_RMON_TX_SUPER_CLASS_STATS
- * Retrieve rmon tx super_class statistics
- */
-#define MC_CMD_RMON_TX_SUPER_CLASS_STATS 0xc6
-
-/* MC_CMD_RMON_TX_SUPER_CLASS_STATS_IN msgrequest */
-#define    MC_CMD_RMON_TX_SUPER_CLASS_STATS_IN_LEN 4
-/* flags */
-#define       MC_CMD_RMON_TX_SUPER_CLASS_STATS_IN_FLAGS_OFST 0
-#define        MC_CMD_RMON_TX_SUPER_CLASS_STATS_IN_SUPER_CLASS_LBN 0
-#define        MC_CMD_RMON_TX_SUPER_CLASS_STATS_IN_SUPER_CLASS_WIDTH 4
-#define        MC_CMD_RMON_TX_SUPER_CLASS_STATS_IN_RST_LBN 4
-#define        MC_CMD_RMON_TX_SUPER_CLASS_STATS_IN_RST_WIDTH 1
-
-/* MC_CMD_RMON_TX_SUPER_CLASS_STATS_OUT msgresponse */
-#define    MC_CMD_RMON_TX_SUPER_CLASS_STATS_OUT_LENMIN 4
-#define    MC_CMD_RMON_TX_SUPER_CLASS_STATS_OUT_LENMAX 252
-#define    MC_CMD_RMON_TX_SUPER_CLASS_STATS_OUT_LEN(num) (0+4*(num))
-/* Array of stats */
-#define       MC_CMD_RMON_TX_SUPER_CLASS_STATS_OUT_BUFFER_OFST 0
-#define       MC_CMD_RMON_TX_SUPER_CLASS_STATS_OUT_BUFFER_LEN 4
-#define       MC_CMD_RMON_TX_SUPER_CLASS_STATS_OUT_BUFFER_MINNUM 1
-#define       MC_CMD_RMON_TX_SUPER_CLASS_STATS_OUT_BUFFER_MAXNUM 63
-
-
-/***********************************/
-/* MC_CMD_RMON_RX_ADD_QID_TO_CLASS
- * Add qid to class for statistics collection
- */
-#define MC_CMD_RMON_RX_ADD_QID_TO_CLASS 0xc7
-
-/* MC_CMD_RMON_RX_ADD_QID_TO_CLASS_IN msgrequest */
-#define    MC_CMD_RMON_RX_ADD_QID_TO_CLASS_IN_LEN 12
-/* class */
-#define       MC_CMD_RMON_RX_ADD_QID_TO_CLASS_IN_CLASS_OFST 0
-/* qid */
-#define       MC_CMD_RMON_RX_ADD_QID_TO_CLASS_IN_QID_OFST 4
-/* flags */
-#define       MC_CMD_RMON_RX_ADD_QID_TO_CLASS_IN_FLAGS_OFST 8
-#define        MC_CMD_RMON_RX_ADD_QID_TO_CLASS_IN_SUPER_CLASS_LBN 0
-#define        MC_CMD_RMON_RX_ADD_QID_TO_CLASS_IN_SUPER_CLASS_WIDTH 4
-#define        MC_CMD_RMON_RX_ADD_QID_TO_CLASS_IN_PE_DELTA_LBN 4
-#define        MC_CMD_RMON_RX_ADD_QID_TO_CLASS_IN_PE_DELTA_WIDTH 4
-#define        MC_CMD_RMON_RX_ADD_QID_TO_CLASS_IN_MTU_LBN 8
-#define        MC_CMD_RMON_RX_ADD_QID_TO_CLASS_IN_MTU_WIDTH 14
-
-/* MC_CMD_RMON_RX_ADD_QID_TO_CLASS_OUT msgresponse */
-#define    MC_CMD_RMON_RX_ADD_QID_TO_CLASS_OUT_LEN 0
-
-
-/***********************************/
-/* MC_CMD_RMON_TX_ADD_QID_TO_CLASS
- * Add qid to class for statistics collection
- */
-#define MC_CMD_RMON_TX_ADD_QID_TO_CLASS 0xc8
-
-/* MC_CMD_RMON_TX_ADD_QID_TO_CLASS_IN msgrequest */
-#define    MC_CMD_RMON_TX_ADD_QID_TO_CLASS_IN_LEN 12
-/* class */
-#define       MC_CMD_RMON_TX_ADD_QID_TO_CLASS_IN_CLASS_OFST 0
-/* qid */
-#define       MC_CMD_RMON_TX_ADD_QID_TO_CLASS_IN_QID_OFST 4
-/* flags */
-#define       MC_CMD_RMON_TX_ADD_QID_TO_CLASS_IN_FLAGS_OFST 8
-#define        MC_CMD_RMON_TX_ADD_QID_TO_CLASS_IN_SUPER_CLASS_LBN 0
-#define        MC_CMD_RMON_TX_ADD_QID_TO_CLASS_IN_SUPER_CLASS_WIDTH 4
-#define        MC_CMD_RMON_TX_ADD_QID_TO_CLASS_IN_PE_DELTA_LBN 4
-#define        MC_CMD_RMON_TX_ADD_QID_TO_CLASS_IN_PE_DELTA_WIDTH 4
-#define        MC_CMD_RMON_TX_ADD_QID_TO_CLASS_IN_MTU_LBN 8
-#define        MC_CMD_RMON_TX_ADD_QID_TO_CLASS_IN_MTU_WIDTH 14
-
-/* MC_CMD_RMON_TX_ADD_QID_TO_CLASS_OUT msgresponse */
-#define    MC_CMD_RMON_TX_ADD_QID_TO_CLASS_OUT_LEN 0
-
-
-/***********************************/
-/* MC_CMD_RMON_MC_ADD_QID_TO_CLASS
- * Add qid to class for statistics collection
- */
-#define MC_CMD_RMON_MC_ADD_QID_TO_CLASS 0xc9
-
-/* MC_CMD_RMON_MC_ADD_QID_TO_CLASS_IN msgrequest */
-#define    MC_CMD_RMON_MC_ADD_QID_TO_CLASS_IN_LEN 12
-/* class */
-#define       MC_CMD_RMON_MC_ADD_QID_TO_CLASS_IN_CLASS_OFST 0
-/* qid */
-#define       MC_CMD_RMON_MC_ADD_QID_TO_CLASS_IN_QID_OFST 4
-/* flags */
-#define       MC_CMD_RMON_MC_ADD_QID_TO_CLASS_IN_FLAGS_OFST 8
-#define        MC_CMD_RMON_MC_ADD_QID_TO_CLASS_IN_SUPER_CLASS_LBN 0
-#define        MC_CMD_RMON_MC_ADD_QID_TO_CLASS_IN_SUPER_CLASS_WIDTH 4
-#define        MC_CMD_RMON_MC_ADD_QID_TO_CLASS_IN_PE_DELTA_LBN 4
-#define        MC_CMD_RMON_MC_ADD_QID_TO_CLASS_IN_PE_DELTA_WIDTH 4
-#define        MC_CMD_RMON_MC_ADD_QID_TO_CLASS_IN_MTU_LBN 8
-#define        MC_CMD_RMON_MC_ADD_QID_TO_CLASS_IN_MTU_WIDTH 14
-
-/* MC_CMD_RMON_MC_ADD_QID_TO_CLASS_OUT msgresponse */
-#define    MC_CMD_RMON_MC_ADD_QID_TO_CLASS_OUT_LEN 0
-
-
-/***********************************/
-/* MC_CMD_RMON_ALLOC_CLASS
- * Allocate an rmon class
- */
-#define MC_CMD_RMON_ALLOC_CLASS 0xca
-
-/* MC_CMD_RMON_ALLOC_CLASS_IN msgrequest */
-#define    MC_CMD_RMON_ALLOC_CLASS_IN_LEN 0
-
-/* MC_CMD_RMON_ALLOC_CLASS_OUT msgresponse */
-#define    MC_CMD_RMON_ALLOC_CLASS_OUT_LEN 4
-/* class */
-#define       MC_CMD_RMON_ALLOC_CLASS_OUT_CLASS_OFST 0
-
-
-/***********************************/
-/* MC_CMD_RMON_DEALLOC_CLASS
- * Deallocate an rmon class
- */
-#define MC_CMD_RMON_DEALLOC_CLASS 0xcb
-
-/* MC_CMD_RMON_DEALLOC_CLASS_IN msgrequest */
-#define    MC_CMD_RMON_DEALLOC_CLASS_IN_LEN 4
-/* class */
-#define       MC_CMD_RMON_DEALLOC_CLASS_IN_CLASS_OFST 0
-
-/* MC_CMD_RMON_DEALLOC_CLASS_OUT msgresponse */
-#define    MC_CMD_RMON_DEALLOC_CLASS_OUT_LEN 0
-
-
-/***********************************/
-/* MC_CMD_RMON_ALLOC_SUPER_CLASS
- * Allocate an rmon super_class
- */
-#define MC_CMD_RMON_ALLOC_SUPER_CLASS 0xcc
-
-/* MC_CMD_RMON_ALLOC_SUPER_CLASS_IN msgrequest */
-#define    MC_CMD_RMON_ALLOC_SUPER_CLASS_IN_LEN 0
-
-/* MC_CMD_RMON_ALLOC_SUPER_CLASS_OUT msgresponse */
-#define    MC_CMD_RMON_ALLOC_SUPER_CLASS_OUT_LEN 4
-/* super_class */
-#define       MC_CMD_RMON_ALLOC_SUPER_CLASS_OUT_SUPER_CLASS_OFST 0
-
-
-/***********************************/
-/* MC_CMD_RMON_DEALLOC_SUPER_CLASS
- * Deallocate an rmon tx super_class
- */
-#define MC_CMD_RMON_DEALLOC_SUPER_CLASS 0xcd
-
-/* MC_CMD_RMON_DEALLOC_SUPER_CLASS_IN msgrequest */
-#define    MC_CMD_RMON_DEALLOC_SUPER_CLASS_IN_LEN 4
-/* super_class */
-#define       MC_CMD_RMON_DEALLOC_SUPER_CLASS_IN_SUPER_CLASS_OFST 0
-
-/* MC_CMD_RMON_DEALLOC_SUPER_CLASS_OUT msgresponse */
-#define    MC_CMD_RMON_DEALLOC_SUPER_CLASS_OUT_LEN 0
-
-
-/***********************************/
-/* MC_CMD_RMON_RX_UP_CONV_STATS
- * Retrieve up converter statistics
- */
-#define MC_CMD_RMON_RX_UP_CONV_STATS 0xce
-
-/* MC_CMD_RMON_RX_UP_CONV_STATS_IN msgrequest */
-#define    MC_CMD_RMON_RX_UP_CONV_STATS_IN_LEN 4
-/* flags */
-#define       MC_CMD_RMON_RX_UP_CONV_STATS_IN_FLAGS_OFST 0
-#define        MC_CMD_RMON_RX_UP_CONV_STATS_IN_PORT_LBN 0
-#define        MC_CMD_RMON_RX_UP_CONV_STATS_IN_PORT_WIDTH 2
-#define        MC_CMD_RMON_RX_UP_CONV_STATS_IN_RST_LBN 2
-#define        MC_CMD_RMON_RX_UP_CONV_STATS_IN_RST_WIDTH 1
-
-/* MC_CMD_RMON_RX_UP_CONV_STATS_OUT msgresponse */
-#define    MC_CMD_RMON_RX_UP_CONV_STATS_OUT_LENMIN 4
-#define    MC_CMD_RMON_RX_UP_CONV_STATS_OUT_LENMAX 252
-#define    MC_CMD_RMON_RX_UP_CONV_STATS_OUT_LEN(num) (0+4*(num))
-/* Array of stats */
-#define       MC_CMD_RMON_RX_UP_CONV_STATS_OUT_BUFFER_OFST 0
-#define       MC_CMD_RMON_RX_UP_CONV_STATS_OUT_BUFFER_LEN 4
-#define       MC_CMD_RMON_RX_UP_CONV_STATS_OUT_BUFFER_MINNUM 1
-#define       MC_CMD_RMON_RX_UP_CONV_STATS_OUT_BUFFER_MAXNUM 63
-
-
-/***********************************/
-/* MC_CMD_RMON_RX_IPI_STATS
- * Retrieve rx ipi stats
- */
-#define MC_CMD_RMON_RX_IPI_STATS 0xcf
-
-/* MC_CMD_RMON_RX_IPI_STATS_IN msgrequest */
-#define    MC_CMD_RMON_RX_IPI_STATS_IN_LEN 4
-/* flags */
-#define       MC_CMD_RMON_RX_IPI_STATS_IN_FLAGS_OFST 0
-#define        MC_CMD_RMON_RX_IPI_STATS_IN_VFIFO_LBN 0
-#define        MC_CMD_RMON_RX_IPI_STATS_IN_VFIFO_WIDTH 5
-#define        MC_CMD_RMON_RX_IPI_STATS_IN_RST_LBN 5
-#define        MC_CMD_RMON_RX_IPI_STATS_IN_RST_WIDTH 1
-
-/* MC_CMD_RMON_RX_IPI_STATS_OUT msgresponse */
-#define    MC_CMD_RMON_RX_IPI_STATS_OUT_LENMIN 4
-#define    MC_CMD_RMON_RX_IPI_STATS_OUT_LENMAX 252
-#define    MC_CMD_RMON_RX_IPI_STATS_OUT_LEN(num) (0+4*(num))
-/* Array of stats */
-#define       MC_CMD_RMON_RX_IPI_STATS_OUT_BUFFER_OFST 0
-#define       MC_CMD_RMON_RX_IPI_STATS_OUT_BUFFER_LEN 4
-#define       MC_CMD_RMON_RX_IPI_STATS_OUT_BUFFER_MINNUM 1
-#define       MC_CMD_RMON_RX_IPI_STATS_OUT_BUFFER_MAXNUM 63
-
-
-/***********************************/
-/* MC_CMD_RMON_RX_IPSEC_CNTXT_PTR_STATS
- * Retrieve rx ipsec cntxt_ptr indexed stats
- */
-#define MC_CMD_RMON_RX_IPSEC_CNTXT_PTR_STATS 0xd0
-
-/* MC_CMD_RMON_RX_IPSEC_CNTXT_PTR_STATS_IN msgrequest */
-#define    MC_CMD_RMON_RX_IPSEC_CNTXT_PTR_STATS_IN_LEN 4
-/* flags */
-#define       MC_CMD_RMON_RX_IPSEC_CNTXT_PTR_STATS_IN_FLAGS_OFST 0
-#define        MC_CMD_RMON_RX_IPSEC_CNTXT_PTR_STATS_IN_CNTXT_PTR_LBN 0
-#define        MC_CMD_RMON_RX_IPSEC_CNTXT_PTR_STATS_IN_CNTXT_PTR_WIDTH 9
-#define        MC_CMD_RMON_RX_IPSEC_CNTXT_PTR_STATS_IN_RST_LBN 9
-#define        MC_CMD_RMON_RX_IPSEC_CNTXT_PTR_STATS_IN_RST_WIDTH 1
-
-/* MC_CMD_RMON_RX_IPSEC_CNTXT_PTR_STATS_OUT msgresponse */
-#define    MC_CMD_RMON_RX_IPSEC_CNTXT_PTR_STATS_OUT_LENMIN 4
-#define    MC_CMD_RMON_RX_IPSEC_CNTXT_PTR_STATS_OUT_LENMAX 252
-#define    MC_CMD_RMON_RX_IPSEC_CNTXT_PTR_STATS_OUT_LEN(num) (0+4*(num))
-/* Array of stats */
-#define       MC_CMD_RMON_RX_IPSEC_CNTXT_PTR_STATS_OUT_BUFFER_OFST 0
-#define       MC_CMD_RMON_RX_IPSEC_CNTXT_PTR_STATS_OUT_BUFFER_LEN 4
-#define       MC_CMD_RMON_RX_IPSEC_CNTXT_PTR_STATS_OUT_BUFFER_MINNUM 1
-#define       MC_CMD_RMON_RX_IPSEC_CNTXT_PTR_STATS_OUT_BUFFER_MAXNUM 63
-
-
-/***********************************/
-/* MC_CMD_RMON_RX_IPSEC_PORT_STATS
- * Retrieve rx ipsec port indexed stats
- */
-#define MC_CMD_RMON_RX_IPSEC_PORT_STATS 0xd1
-
-/* MC_CMD_RMON_RX_IPSEC_PORT_STATS_IN msgrequest */
-#define    MC_CMD_RMON_RX_IPSEC_PORT_STATS_IN_LEN 4
-/* flags */
-#define       MC_CMD_RMON_RX_IPSEC_PORT_STATS_IN_FLAGS_OFST 0
-#define        MC_CMD_RMON_RX_IPSEC_PORT_STATS_IN_PORT_LBN 0
-#define        MC_CMD_RMON_RX_IPSEC_PORT_STATS_IN_PORT_WIDTH 2
-#define        MC_CMD_RMON_RX_IPSEC_PORT_STATS_IN_RST_LBN 2
-#define        MC_CMD_RMON_RX_IPSEC_PORT_STATS_IN_RST_WIDTH 1
-
-/* MC_CMD_RMON_RX_IPSEC_PORT_STATS_OUT msgresponse */
-#define    MC_CMD_RMON_RX_IPSEC_PORT_STATS_OUT_LENMIN 4
-#define    MC_CMD_RMON_RX_IPSEC_PORT_STATS_OUT_LENMAX 252
-#define    MC_CMD_RMON_RX_IPSEC_PORT_STATS_OUT_LEN(num) (0+4*(num))
-/* Array of stats */
-#define       MC_CMD_RMON_RX_IPSEC_PORT_STATS_OUT_BUFFER_OFST 0
-#define       MC_CMD_RMON_RX_IPSEC_PORT_STATS_OUT_BUFFER_LEN 4
-#define       MC_CMD_RMON_RX_IPSEC_PORT_STATS_OUT_BUFFER_MINNUM 1
-#define       MC_CMD_RMON_RX_IPSEC_PORT_STATS_OUT_BUFFER_MAXNUM 63
-
-
-/***********************************/
-/* MC_CMD_RMON_RX_IPSEC_OFLOW_STATS
- * Retrieve tx ipsec overflow
- */
-#define MC_CMD_RMON_RX_IPSEC_OFLOW_STATS 0xd2
-
-/* MC_CMD_RMON_RX_IPSEC_OFLOW_STATS_IN msgrequest */
-#define    MC_CMD_RMON_RX_IPSEC_OFLOW_STATS_IN_LEN 4
-/* flags */
-#define       MC_CMD_RMON_RX_IPSEC_OFLOW_STATS_IN_FLAGS_OFST 0
-#define        MC_CMD_RMON_RX_IPSEC_OFLOW_STATS_IN_PORT_LBN 0
-#define        MC_CMD_RMON_RX_IPSEC_OFLOW_STATS_IN_PORT_WIDTH 2
-#define        MC_CMD_RMON_RX_IPSEC_OFLOW_STATS_IN_RST_LBN 2
-#define        MC_CMD_RMON_RX_IPSEC_OFLOW_STATS_IN_RST_WIDTH 1
-
-/* MC_CMD_RMON_RX_IPSEC_OFLOW_STATS_OUT msgresponse */
-#define    MC_CMD_RMON_RX_IPSEC_OFLOW_STATS_OUT_LENMIN 4
-#define    MC_CMD_RMON_RX_IPSEC_OFLOW_STATS_OUT_LENMAX 252
-#define    MC_CMD_RMON_RX_IPSEC_OFLOW_STATS_OUT_LEN(num) (0+4*(num))
-/* Array of stats */
-#define       MC_CMD_RMON_RX_IPSEC_OFLOW_STATS_OUT_BUFFER_OFST 0
-#define       MC_CMD_RMON_RX_IPSEC_OFLOW_STATS_OUT_BUFFER_LEN 4
-#define       MC_CMD_RMON_RX_IPSEC_OFLOW_STATS_OUT_BUFFER_MINNUM 1
-#define       MC_CMD_RMON_RX_IPSEC_OFLOW_STATS_OUT_BUFFER_MAXNUM 63
-
-
-/***********************************/
-/* MC_CMD_VPORT_ADD_MAC_ADDRESS
- * Add a MAC address to a v-port
- */
-#define MC_CMD_VPORT_ADD_MAC_ADDRESS 0xa8
-
-#define MC_CMD_0xa8_PRIVILEGE_CTG SRIOV_CTG_GENERAL
-
-/* MC_CMD_VPORT_ADD_MAC_ADDRESS_IN msgrequest */
-#define    MC_CMD_VPORT_ADD_MAC_ADDRESS_IN_LEN 10
-/* The handle of the v-port */
-#define       MC_CMD_VPORT_ADD_MAC_ADDRESS_IN_VPORT_ID_OFST 0
-/* MAC address to add */
-#define       MC_CMD_VPORT_ADD_MAC_ADDRESS_IN_MACADDR_OFST 4
-#define       MC_CMD_VPORT_ADD_MAC_ADDRESS_IN_MACADDR_LEN 6
-
-/* MC_CMD_VPORT_ADD_MAC_ADDRESS_OUT msgresponse */
-#define    MC_CMD_VPORT_ADD_MAC_ADDRESS_OUT_LEN 0
-
-
-/***********************************/
-/* MC_CMD_VPORT_DEL_MAC_ADDRESS
- * Delete a MAC address from a v-port
- */
-#define MC_CMD_VPORT_DEL_MAC_ADDRESS 0xa9
-
-#define MC_CMD_0xa9_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+#define MC_CMD_0xa9_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_VPORT_DEL_MAC_ADDRESS_IN msgrequest */
 #define    MC_CMD_VPORT_DEL_MAC_ADDRESS_IN_LEN 10
@@ -6877,7 +8176,7 @@
 #define    MC_CMD_DUMP_BUFTBL_ENTRIES_OUT_LENMIN 12
 #define    MC_CMD_DUMP_BUFTBL_ENTRIES_OUT_LENMAX 252
 #define    MC_CMD_DUMP_BUFTBL_ENTRIES_OUT_LEN(num) (0+12*(num))
-/* Raw buffer table entries, laid out as BUFTBL_ENTRY. */
+/* Raw buffer table entries, layed out as BUFTBL_ENTRY. */
 #define       MC_CMD_DUMP_BUFTBL_ENTRIES_OUT_ENTRY_OFST 0
 #define       MC_CMD_DUMP_BUFTBL_ENTRIES_OUT_ENTRY_LEN 12
 #define       MC_CMD_DUMP_BUFTBL_ENTRIES_OUT_ENTRY_MINNUM 1
@@ -6921,354 +8220,6 @@
 
 
 /***********************************/
-/* MC_CMD_RMON_RX_CLASS_DROPS_STATS
- * Retrieve rx class drop stats
- */
-#define MC_CMD_RMON_RX_CLASS_DROPS_STATS 0xd3
-
-/* MC_CMD_RMON_RX_CLASS_DROPS_STATS_IN msgrequest */
-#define    MC_CMD_RMON_RX_CLASS_DROPS_STATS_IN_LEN 4
-/* flags */
-#define       MC_CMD_RMON_RX_CLASS_DROPS_STATS_IN_FLAGS_OFST 0
-#define        MC_CMD_RMON_RX_CLASS_DROPS_STATS_IN_CLASS_LBN 0
-#define        MC_CMD_RMON_RX_CLASS_DROPS_STATS_IN_CLASS_WIDTH 8
-#define        MC_CMD_RMON_RX_CLASS_DROPS_STATS_IN_RST_LBN 8
-#define        MC_CMD_RMON_RX_CLASS_DROPS_STATS_IN_RST_WIDTH 1
-
-/* MC_CMD_RMON_RX_CLASS_DROPS_STATS_OUT msgresponse */
-#define    MC_CMD_RMON_RX_CLASS_DROPS_STATS_OUT_LENMIN 4
-#define    MC_CMD_RMON_RX_CLASS_DROPS_STATS_OUT_LENMAX 252
-#define    MC_CMD_RMON_RX_CLASS_DROPS_STATS_OUT_LEN(num) (0+4*(num))
-/* Array of stats */
-#define       MC_CMD_RMON_RX_CLASS_DROPS_STATS_OUT_BUFFER_OFST 0
-#define       MC_CMD_RMON_RX_CLASS_DROPS_STATS_OUT_BUFFER_LEN 4
-#define       MC_CMD_RMON_RX_CLASS_DROPS_STATS_OUT_BUFFER_MINNUM 1
-#define       MC_CMD_RMON_RX_CLASS_DROPS_STATS_OUT_BUFFER_MAXNUM 63
-
-
-/***********************************/
-/* MC_CMD_RMON_RX_SUPER_CLASS_DROPS_STATS
- * Retrieve rx super class drop stats
- */
-#define MC_CMD_RMON_RX_SUPER_CLASS_DROPS_STATS 0xd4
-
-/* MC_CMD_RMON_RX_SUPER_CLASS_DROPS_STATS_IN msgrequest */
-#define    MC_CMD_RMON_RX_SUPER_CLASS_DROPS_STATS_IN_LEN 4
-/* flags */
-#define       MC_CMD_RMON_RX_SUPER_CLASS_DROPS_STATS_IN_FLAGS_OFST 0
-#define        MC_CMD_RMON_RX_SUPER_CLASS_DROPS_STATS_IN_SUPER_CLASS_LBN 0
-#define        MC_CMD_RMON_RX_SUPER_CLASS_DROPS_STATS_IN_SUPER_CLASS_WIDTH 4
-#define        MC_CMD_RMON_RX_SUPER_CLASS_DROPS_STATS_IN_RST_LBN 4
-#define        MC_CMD_RMON_RX_SUPER_CLASS_DROPS_STATS_IN_RST_WIDTH 1
-
-/* MC_CMD_RMON_RX_SUPER_CLASS_DROPS_STATS_OUT msgresponse */
-#define    MC_CMD_RMON_RX_SUPER_CLASS_DROPS_STATS_OUT_LENMIN 4
-#define    MC_CMD_RMON_RX_SUPER_CLASS_DROPS_STATS_OUT_LENMAX 252
-#define    MC_CMD_RMON_RX_SUPER_CLASS_DROPS_STATS_OUT_LEN(num) (0+4*(num))
-/* Array of stats */
-#define       MC_CMD_RMON_RX_SUPER_CLASS_DROPS_STATS_OUT_BUFFER_OFST 0
-#define       MC_CMD_RMON_RX_SUPER_CLASS_DROPS_STATS_OUT_BUFFER_LEN 4
-#define       MC_CMD_RMON_RX_SUPER_CLASS_DROPS_STATS_OUT_BUFFER_MINNUM 1
-#define       MC_CMD_RMON_RX_SUPER_CLASS_DROPS_STATS_OUT_BUFFER_MAXNUM 63
-
-
-/***********************************/
-/* MC_CMD_RMON_RX_ERRORS_STATS
- * Retrieve rxdp errors
- */
-#define MC_CMD_RMON_RX_ERRORS_STATS 0xd5
-
-/* MC_CMD_RMON_RX_ERRORS_STATS_IN msgrequest */
-#define    MC_CMD_RMON_RX_ERRORS_STATS_IN_LEN 4
-/* flags */
-#define       MC_CMD_RMON_RX_ERRORS_STATS_IN_FLAGS_OFST 0
-#define        MC_CMD_RMON_RX_ERRORS_STATS_IN_QID_LBN 0
-#define        MC_CMD_RMON_RX_ERRORS_STATS_IN_QID_WIDTH 11
-#define        MC_CMD_RMON_RX_ERRORS_STATS_IN_RST_LBN 11
-#define        MC_CMD_RMON_RX_ERRORS_STATS_IN_RST_WIDTH 1
-
-/* MC_CMD_RMON_RX_ERRORS_STATS_OUT msgresponse */
-#define    MC_CMD_RMON_RX_ERRORS_STATS_OUT_LENMIN 4
-#define    MC_CMD_RMON_RX_ERRORS_STATS_OUT_LENMAX 252
-#define    MC_CMD_RMON_RX_ERRORS_STATS_OUT_LEN(num) (0+4*(num))
-/* Array of stats */
-#define       MC_CMD_RMON_RX_ERRORS_STATS_OUT_BUFFER_OFST 0
-#define       MC_CMD_RMON_RX_ERRORS_STATS_OUT_BUFFER_LEN 4
-#define       MC_CMD_RMON_RX_ERRORS_STATS_OUT_BUFFER_MINNUM 1
-#define       MC_CMD_RMON_RX_ERRORS_STATS_OUT_BUFFER_MAXNUM 63
-
-
-/***********************************/
-/* MC_CMD_RMON_RX_OVERFLOW_STATS
- * Retrieve rxdp overflow
- */
-#define MC_CMD_RMON_RX_OVERFLOW_STATS 0xd6
-
-/* MC_CMD_RMON_RX_OVERFLOW_STATS_IN msgrequest */
-#define    MC_CMD_RMON_RX_OVERFLOW_STATS_IN_LEN 4
-/* flags */
-#define       MC_CMD_RMON_RX_OVERFLOW_STATS_IN_FLAGS_OFST 0
-#define        MC_CMD_RMON_RX_OVERFLOW_STATS_IN_CLASS_LBN 0
-#define        MC_CMD_RMON_RX_OVERFLOW_STATS_IN_CLASS_WIDTH 8
-#define        MC_CMD_RMON_RX_OVERFLOW_STATS_IN_RST_LBN 8
-#define        MC_CMD_RMON_RX_OVERFLOW_STATS_IN_RST_WIDTH 1
-
-/* MC_CMD_RMON_RX_OVERFLOW_STATS_OUT msgresponse */
-#define    MC_CMD_RMON_RX_OVERFLOW_STATS_OUT_LENMIN 4
-#define    MC_CMD_RMON_RX_OVERFLOW_STATS_OUT_LENMAX 252
-#define    MC_CMD_RMON_RX_OVERFLOW_STATS_OUT_LEN(num) (0+4*(num))
-/* Array of stats */
-#define       MC_CMD_RMON_RX_OVERFLOW_STATS_OUT_BUFFER_OFST 0
-#define       MC_CMD_RMON_RX_OVERFLOW_STATS_OUT_BUFFER_LEN 4
-#define       MC_CMD_RMON_RX_OVERFLOW_STATS_OUT_BUFFER_MINNUM 1
-#define       MC_CMD_RMON_RX_OVERFLOW_STATS_OUT_BUFFER_MAXNUM 63
-
-
-/***********************************/
-/* MC_CMD_RMON_TX_IPI_STATS
- * Retrieve tx ipi stats
- */
-#define MC_CMD_RMON_TX_IPI_STATS 0xd7
-
-/* MC_CMD_RMON_TX_IPI_STATS_IN msgrequest */
-#define    MC_CMD_RMON_TX_IPI_STATS_IN_LEN 4
-/* flags */
-#define       MC_CMD_RMON_TX_IPI_STATS_IN_FLAGS_OFST 0
-#define        MC_CMD_RMON_TX_IPI_STATS_IN_VFIFO_LBN 0
-#define        MC_CMD_RMON_TX_IPI_STATS_IN_VFIFO_WIDTH 5
-#define        MC_CMD_RMON_TX_IPI_STATS_IN_RST_LBN 5
-#define        MC_CMD_RMON_TX_IPI_STATS_IN_RST_WIDTH 1
-
-/* MC_CMD_RMON_TX_IPI_STATS_OUT msgresponse */
-#define    MC_CMD_RMON_TX_IPI_STATS_OUT_LENMIN 4
-#define    MC_CMD_RMON_TX_IPI_STATS_OUT_LENMAX 252
-#define    MC_CMD_RMON_TX_IPI_STATS_OUT_LEN(num) (0+4*(num))
-/* Array of stats */
-#define       MC_CMD_RMON_TX_IPI_STATS_OUT_BUFFER_OFST 0
-#define       MC_CMD_RMON_TX_IPI_STATS_OUT_BUFFER_LEN 4
-#define       MC_CMD_RMON_TX_IPI_STATS_OUT_BUFFER_MINNUM 1
-#define       MC_CMD_RMON_TX_IPI_STATS_OUT_BUFFER_MAXNUM 63
-
-
-/***********************************/
-/* MC_CMD_RMON_TX_IPSEC_CNTXT_PTR_STATS
- * Retrieve tx ipsec counters by cntxt_ptr
- */
-#define MC_CMD_RMON_TX_IPSEC_CNTXT_PTR_STATS 0xd8
-
-/* MC_CMD_RMON_TX_IPSEC_CNTXT_PTR_STATS_IN msgrequest */
-#define    MC_CMD_RMON_TX_IPSEC_CNTXT_PTR_STATS_IN_LEN 4
-/* flags */
-#define       MC_CMD_RMON_TX_IPSEC_CNTXT_PTR_STATS_IN_FLAGS_OFST 0
-#define        MC_CMD_RMON_TX_IPSEC_CNTXT_PTR_STATS_IN_CNTXT_PTR_LBN 0
-#define        MC_CMD_RMON_TX_IPSEC_CNTXT_PTR_STATS_IN_CNTXT_PTR_WIDTH 9
-#define        MC_CMD_RMON_TX_IPSEC_CNTXT_PTR_STATS_IN_RST_LBN 9
-#define        MC_CMD_RMON_TX_IPSEC_CNTXT_PTR_STATS_IN_RST_WIDTH 1
-
-/* MC_CMD_RMON_TX_IPSEC_CNTXT_PTR_STATS_OUT msgresponse */
-#define    MC_CMD_RMON_TX_IPSEC_CNTXT_PTR_STATS_OUT_LENMIN 4
-#define    MC_CMD_RMON_TX_IPSEC_CNTXT_PTR_STATS_OUT_LENMAX 252
-#define    MC_CMD_RMON_TX_IPSEC_CNTXT_PTR_STATS_OUT_LEN(num) (0+4*(num))
-/* Array of stats */
-#define       MC_CMD_RMON_TX_IPSEC_CNTXT_PTR_STATS_OUT_BUFFER_OFST 0
-#define       MC_CMD_RMON_TX_IPSEC_CNTXT_PTR_STATS_OUT_BUFFER_LEN 4
-#define       MC_CMD_RMON_TX_IPSEC_CNTXT_PTR_STATS_OUT_BUFFER_MINNUM 1
-#define       MC_CMD_RMON_TX_IPSEC_CNTXT_PTR_STATS_OUT_BUFFER_MAXNUM 63
-
-
-/***********************************/
-/* MC_CMD_RMON_TX_IPSEC_PORT_STATS
- * Retrieve tx ipsec counters by port
- */
-#define MC_CMD_RMON_TX_IPSEC_PORT_STATS 0xd9
-
-/* MC_CMD_RMON_TX_IPSEC_PORT_STATS_IN msgrequest */
-#define    MC_CMD_RMON_TX_IPSEC_PORT_STATS_IN_LEN 4
-/* flags */
-#define       MC_CMD_RMON_TX_IPSEC_PORT_STATS_IN_FLAGS_OFST 0
-#define        MC_CMD_RMON_TX_IPSEC_PORT_STATS_IN_PORT_LBN 0
-#define        MC_CMD_RMON_TX_IPSEC_PORT_STATS_IN_PORT_WIDTH 2
-#define        MC_CMD_RMON_TX_IPSEC_PORT_STATS_IN_RST_LBN 2
-#define        MC_CMD_RMON_TX_IPSEC_PORT_STATS_IN_RST_WIDTH 1
-
-/* MC_CMD_RMON_TX_IPSEC_PORT_STATS_OUT msgresponse */
-#define    MC_CMD_RMON_TX_IPSEC_PORT_STATS_OUT_LENMIN 4
-#define    MC_CMD_RMON_TX_IPSEC_PORT_STATS_OUT_LENMAX 252
-#define    MC_CMD_RMON_TX_IPSEC_PORT_STATS_OUT_LEN(num) (0+4*(num))
-/* Array of stats */
-#define       MC_CMD_RMON_TX_IPSEC_PORT_STATS_OUT_BUFFER_OFST 0
-#define       MC_CMD_RMON_TX_IPSEC_PORT_STATS_OUT_BUFFER_LEN 4
-#define       MC_CMD_RMON_TX_IPSEC_PORT_STATS_OUT_BUFFER_MINNUM 1
-#define       MC_CMD_RMON_TX_IPSEC_PORT_STATS_OUT_BUFFER_MAXNUM 63
-
-
-/***********************************/
-/* MC_CMD_RMON_TX_IPSEC_OFLOW_STATS
- * Retrieve tx ipsec overflow
- */
-#define MC_CMD_RMON_TX_IPSEC_OFLOW_STATS 0xda
-
-/* MC_CMD_RMON_TX_IPSEC_OFLOW_STATS_IN msgrequest */
-#define    MC_CMD_RMON_TX_IPSEC_OFLOW_STATS_IN_LEN 4
-/* flags */
-#define       MC_CMD_RMON_TX_IPSEC_OFLOW_STATS_IN_FLAGS_OFST 0
-#define        MC_CMD_RMON_TX_IPSEC_OFLOW_STATS_IN_PORT_LBN 0
-#define        MC_CMD_RMON_TX_IPSEC_OFLOW_STATS_IN_PORT_WIDTH 2
-#define        MC_CMD_RMON_TX_IPSEC_OFLOW_STATS_IN_RST_LBN 2
-#define        MC_CMD_RMON_TX_IPSEC_OFLOW_STATS_IN_RST_WIDTH 1
-
-/* MC_CMD_RMON_TX_IPSEC_OFLOW_STATS_OUT msgresponse */
-#define    MC_CMD_RMON_TX_IPSEC_OFLOW_STATS_OUT_LENMIN 4
-#define    MC_CMD_RMON_TX_IPSEC_OFLOW_STATS_OUT_LENMAX 252
-#define    MC_CMD_RMON_TX_IPSEC_OFLOW_STATS_OUT_LEN(num) (0+4*(num))
-/* Array of stats */
-#define       MC_CMD_RMON_TX_IPSEC_OFLOW_STATS_OUT_BUFFER_OFST 0
-#define       MC_CMD_RMON_TX_IPSEC_OFLOW_STATS_OUT_BUFFER_LEN 4
-#define       MC_CMD_RMON_TX_IPSEC_OFLOW_STATS_OUT_BUFFER_MINNUM 1
-#define       MC_CMD_RMON_TX_IPSEC_OFLOW_STATS_OUT_BUFFER_MAXNUM 63
-
-
-/***********************************/
-/* MC_CMD_RMON_TX_NOWHERE_STATS
- * Retrieve tx nowhere stats
- */
-#define MC_CMD_RMON_TX_NOWHERE_STATS 0xdb
-
-/* MC_CMD_RMON_TX_NOWHERE_STATS_IN msgrequest */
-#define    MC_CMD_RMON_TX_NOWHERE_STATS_IN_LEN 4
-/* flags */
-#define       MC_CMD_RMON_TX_NOWHERE_STATS_IN_FLAGS_OFST 0
-#define        MC_CMD_RMON_TX_NOWHERE_STATS_IN_CLASS_LBN 0
-#define        MC_CMD_RMON_TX_NOWHERE_STATS_IN_CLASS_WIDTH 8
-#define        MC_CMD_RMON_TX_NOWHERE_STATS_IN_RST_LBN 8
-#define        MC_CMD_RMON_TX_NOWHERE_STATS_IN_RST_WIDTH 1
-
-/* MC_CMD_RMON_TX_NOWHERE_STATS_OUT msgresponse */
-#define    MC_CMD_RMON_TX_NOWHERE_STATS_OUT_LENMIN 4
-#define    MC_CMD_RMON_TX_NOWHERE_STATS_OUT_LENMAX 252
-#define    MC_CMD_RMON_TX_NOWHERE_STATS_OUT_LEN(num) (0+4*(num))
-/* Array of stats */
-#define       MC_CMD_RMON_TX_NOWHERE_STATS_OUT_BUFFER_OFST 0
-#define       MC_CMD_RMON_TX_NOWHERE_STATS_OUT_BUFFER_LEN 4
-#define       MC_CMD_RMON_TX_NOWHERE_STATS_OUT_BUFFER_MINNUM 1
-#define       MC_CMD_RMON_TX_NOWHERE_STATS_OUT_BUFFER_MAXNUM 63
-
-
-/***********************************/
-/* MC_CMD_RMON_TX_NOWHERE_QBB_STATS
- * Retrieve tx nowhere qbb stats
- */
-#define MC_CMD_RMON_TX_NOWHERE_QBB_STATS 0xdc
-
-/* MC_CMD_RMON_TX_NOWHERE_QBB_STATS_IN msgrequest */
-#define    MC_CMD_RMON_TX_NOWHERE_QBB_STATS_IN_LEN 4
-/* flags */
-#define       MC_CMD_RMON_TX_NOWHERE_QBB_STATS_IN_FLAGS_OFST 0
-#define        MC_CMD_RMON_TX_NOWHERE_QBB_STATS_IN_PRIORITY_LBN 0
-#define        MC_CMD_RMON_TX_NOWHERE_QBB_STATS_IN_PRIORITY_WIDTH 3
-#define        MC_CMD_RMON_TX_NOWHERE_QBB_STATS_IN_RST_LBN 3
-#define        MC_CMD_RMON_TX_NOWHERE_QBB_STATS_IN_RST_WIDTH 1
-
-/* MC_CMD_RMON_TX_NOWHERE_QBB_STATS_OUT msgresponse */
-#define    MC_CMD_RMON_TX_NOWHERE_QBB_STATS_OUT_LENMIN 4
-#define    MC_CMD_RMON_TX_NOWHERE_QBB_STATS_OUT_LENMAX 252
-#define    MC_CMD_RMON_TX_NOWHERE_QBB_STATS_OUT_LEN(num) (0+4*(num))
-/* Array of stats */
-#define       MC_CMD_RMON_TX_NOWHERE_QBB_STATS_OUT_BUFFER_OFST 0
-#define       MC_CMD_RMON_TX_NOWHERE_QBB_STATS_OUT_BUFFER_LEN 4
-#define       MC_CMD_RMON_TX_NOWHERE_QBB_STATS_OUT_BUFFER_MINNUM 1
-#define       MC_CMD_RMON_TX_NOWHERE_QBB_STATS_OUT_BUFFER_MAXNUM 63
-
-
-/***********************************/
-/* MC_CMD_RMON_TX_ERRORS_STATS
- * Retrieve rxdp errors
- */
-#define MC_CMD_RMON_TX_ERRORS_STATS 0xdd
-
-/* MC_CMD_RMON_TX_ERRORS_STATS_IN msgrequest */
-#define    MC_CMD_RMON_TX_ERRORS_STATS_IN_LEN 4
-/* flags */
-#define       MC_CMD_RMON_TX_ERRORS_STATS_IN_FLAGS_OFST 0
-#define        MC_CMD_RMON_TX_ERRORS_STATS_IN_QID_LBN 0
-#define        MC_CMD_RMON_TX_ERRORS_STATS_IN_QID_WIDTH 11
-#define        MC_CMD_RMON_TX_ERRORS_STATS_IN_RST_LBN 11
-#define        MC_CMD_RMON_TX_ERRORS_STATS_IN_RST_WIDTH 1
-
-/* MC_CMD_RMON_TX_ERRORS_STATS_OUT msgresponse */
-#define    MC_CMD_RMON_TX_ERRORS_STATS_OUT_LENMIN 4
-#define    MC_CMD_RMON_TX_ERRORS_STATS_OUT_LENMAX 252
-#define    MC_CMD_RMON_TX_ERRORS_STATS_OUT_LEN(num) (0+4*(num))
-/* Array of stats */
-#define       MC_CMD_RMON_TX_ERRORS_STATS_OUT_BUFFER_OFST 0
-#define       MC_CMD_RMON_TX_ERRORS_STATS_OUT_BUFFER_LEN 4
-#define       MC_CMD_RMON_TX_ERRORS_STATS_OUT_BUFFER_MINNUM 1
-#define       MC_CMD_RMON_TX_ERRORS_STATS_OUT_BUFFER_MAXNUM 63
-
-
-/***********************************/
-/* MC_CMD_RMON_TX_OVERFLOW_STATS
- * Retrieve rxdp overflow
- */
-#define MC_CMD_RMON_TX_OVERFLOW_STATS 0xde
-
-/* MC_CMD_RMON_TX_OVERFLOW_STATS_IN msgrequest */
-#define    MC_CMD_RMON_TX_OVERFLOW_STATS_IN_LEN 4
-/* flags */
-#define       MC_CMD_RMON_TX_OVERFLOW_STATS_IN_FLAGS_OFST 0
-#define        MC_CMD_RMON_TX_OVERFLOW_STATS_IN_CLASS_LBN 0
-#define        MC_CMD_RMON_TX_OVERFLOW_STATS_IN_CLASS_WIDTH 8
-#define        MC_CMD_RMON_TX_OVERFLOW_STATS_IN_RST_LBN 8
-#define        MC_CMD_RMON_TX_OVERFLOW_STATS_IN_RST_WIDTH 1
-
-/* MC_CMD_RMON_TX_OVERFLOW_STATS_OUT msgresponse */
-#define    MC_CMD_RMON_TX_OVERFLOW_STATS_OUT_LENMIN 4
-#define    MC_CMD_RMON_TX_OVERFLOW_STATS_OUT_LENMAX 252
-#define    MC_CMD_RMON_TX_OVERFLOW_STATS_OUT_LEN(num) (0+4*(num))
-/* Array of stats */
-#define       MC_CMD_RMON_TX_OVERFLOW_STATS_OUT_BUFFER_OFST 0
-#define       MC_CMD_RMON_TX_OVERFLOW_STATS_OUT_BUFFER_LEN 4
-#define       MC_CMD_RMON_TX_OVERFLOW_STATS_OUT_BUFFER_MINNUM 1
-#define       MC_CMD_RMON_TX_OVERFLOW_STATS_OUT_BUFFER_MAXNUM 63
-
-
-/***********************************/
-/* MC_CMD_RMON_COLLECT_CLASS_STATS
- * Explicitly collect class stats at the specified evb port
- */
-#define MC_CMD_RMON_COLLECT_CLASS_STATS 0xdf
-
-/* MC_CMD_RMON_COLLECT_CLASS_STATS_IN msgrequest */
-#define    MC_CMD_RMON_COLLECT_CLASS_STATS_IN_LEN 4
-/* The port id associated with the vport/pport at which to collect class stats
- */
-#define       MC_CMD_RMON_COLLECT_CLASS_STATS_IN_PORT_ID_OFST 0
-
-/* MC_CMD_RMON_COLLECT_CLASS_STATS_OUT msgresponse */
-#define    MC_CMD_RMON_COLLECT_CLASS_STATS_OUT_LEN 4
-/* class */
-#define       MC_CMD_RMON_COLLECT_CLASS_STATS_OUT_CLASS_OFST 0
-
-
-/***********************************/
-/* MC_CMD_RMON_COLLECT_SUPER_CLASS_STATS
- * Explicitly collect class stats at the specified evb port
- */
-#define MC_CMD_RMON_COLLECT_SUPER_CLASS_STATS 0xe0
-
-/* MC_CMD_RMON_COLLECT_SUPER_CLASS_STATS_IN msgrequest */
-#define    MC_CMD_RMON_COLLECT_SUPER_CLASS_STATS_IN_LEN 4
-/* The port id associated with the vport/pport at which to collect class stats
- */
-#define       MC_CMD_RMON_COLLECT_SUPER_CLASS_STATS_IN_PORT_ID_OFST 0
-
-/* MC_CMD_RMON_COLLECT_SUPER_CLASS_STATS_OUT msgresponse */
-#define    MC_CMD_RMON_COLLECT_SUPER_CLASS_STATS_OUT_LEN 4
-/* super_class */
-#define       MC_CMD_RMON_COLLECT_SUPER_CLASS_STATS_OUT_SUPER_CLASS_OFST 0
-
-
-/***********************************/
 /* MC_CMD_GET_CLOCK
  * Return the system and PDCPU clock frequencies.
  */
@@ -7296,22 +8247,66 @@
 #define MC_CMD_0xad_PRIVILEGE_CTG SRIOV_CTG_ADMIN
 
 /* MC_CMD_SET_CLOCK_IN msgrequest */
-#define    MC_CMD_SET_CLOCK_IN_LEN 12
-/* Requested system frequency in MHz; 0 leaves unchanged. */
+#define    MC_CMD_SET_CLOCK_IN_LEN 28
+/* Requested frequency in MHz for system clock domain */
 #define       MC_CMD_SET_CLOCK_IN_SYS_FREQ_OFST 0
-/* Requested inter-core frequency in MHz; 0 leaves unchanged. */
+/* enum: Leave the system clock domain frequency unchanged */
+#define          MC_CMD_SET_CLOCK_IN_SYS_DOMAIN_DONT_CHANGE  0x0
+/* Requested frequency in MHz for inter-core clock domain */
 #define       MC_CMD_SET_CLOCK_IN_ICORE_FREQ_OFST 4
-/* Request DPCPU frequency in MHz; 0 leaves unchanged. */
+/* enum: Leave the inter-core clock domain frequency unchanged */
+#define          MC_CMD_SET_CLOCK_IN_ICORE_DOMAIN_DONT_CHANGE  0x0
+/* Requested frequency in MHz for DPCPU clock domain */
 #define       MC_CMD_SET_CLOCK_IN_DPCPU_FREQ_OFST 8
+/* enum: Leave the DPCPU clock domain frequency unchanged */
+#define          MC_CMD_SET_CLOCK_IN_DPCPU_DOMAIN_DONT_CHANGE  0x0
+/* Requested frequency in MHz for PCS clock domain */
+#define       MC_CMD_SET_CLOCK_IN_PCS_FREQ_OFST 12
+/* enum: Leave the PCS clock domain frequency unchanged */
+#define          MC_CMD_SET_CLOCK_IN_PCS_DOMAIN_DONT_CHANGE  0x0
+/* Requested frequency in MHz for MC clock domain */
+#define       MC_CMD_SET_CLOCK_IN_MC_FREQ_OFST 16
+/* enum: Leave the MC clock domain frequency unchanged */
+#define          MC_CMD_SET_CLOCK_IN_MC_DOMAIN_DONT_CHANGE  0x0
+/* Requested frequency in MHz for rmon clock domain */
+#define       MC_CMD_SET_CLOCK_IN_RMON_FREQ_OFST 20
+/* enum: Leave the rmon clock domain frequency unchanged */
+#define          MC_CMD_SET_CLOCK_IN_RMON_DOMAIN_DONT_CHANGE  0x0
+/* Requested frequency in MHz for vswitch clock domain */
+#define       MC_CMD_SET_CLOCK_IN_VSWITCH_FREQ_OFST 24
+/* enum: Leave the vswitch clock domain frequency unchanged */
+#define          MC_CMD_SET_CLOCK_IN_VSWITCH_DOMAIN_DONT_CHANGE  0x0
 
 /* MC_CMD_SET_CLOCK_OUT msgresponse */
-#define    MC_CMD_SET_CLOCK_OUT_LEN 12
+#define    MC_CMD_SET_CLOCK_OUT_LEN 28
 /* Resulting system frequency in MHz */
 #define       MC_CMD_SET_CLOCK_OUT_SYS_FREQ_OFST 0
+/* enum: The system clock domain doesn't exist */
+#define          MC_CMD_SET_CLOCK_OUT_SYS_DOMAIN_UNSUPPORTED  0x0
 /* Resulting inter-core frequency in MHz */
 #define       MC_CMD_SET_CLOCK_OUT_ICORE_FREQ_OFST 4
+/* enum: The inter-core clock domain doesn't exist / isn't used */
+#define          MC_CMD_SET_CLOCK_OUT_ICORE_DOMAIN_UNSUPPORTED  0x0
 /* Resulting DPCPU frequency in MHz */
 #define       MC_CMD_SET_CLOCK_OUT_DPCPU_FREQ_OFST 8
+/* enum: The dpcpu clock domain doesn't exist */
+#define          MC_CMD_SET_CLOCK_OUT_DPCPU_DOMAIN_UNSUPPORTED  0x0
+/* Resulting PCS frequency in MHz */
+#define       MC_CMD_SET_CLOCK_OUT_PCS_FREQ_OFST 12
+/* enum: The PCS clock domain doesn't exist / isn't controlled */
+#define          MC_CMD_SET_CLOCK_OUT_PCS_DOMAIN_UNSUPPORTED  0x0
+/* Resulting MC frequency in MHz */
+#define       MC_CMD_SET_CLOCK_OUT_MC_FREQ_OFST 16
+/* enum: The MC clock domain doesn't exist / isn't controlled */
+#define          MC_CMD_SET_CLOCK_OUT_MC_DOMAIN_UNSUPPORTED  0x0
+/* Resulting rmon frequency in MHz */
+#define       MC_CMD_SET_CLOCK_OUT_RMON_FREQ_OFST 20
+/* enum: The rmon clock domain doesn't exist / isn't controlled */
+#define          MC_CMD_SET_CLOCK_OUT_RMON_DOMAIN_UNSUPPORTED  0x0
+/* Resulting vswitch frequency in MHz */
+#define       MC_CMD_SET_CLOCK_OUT_VSWITCH_FREQ_OFST 24
+/* enum: The vswitch clock domain doesn't exist / isn't controlled */
+#define          MC_CMD_SET_CLOCK_OUT_VSWITCH_DOMAIN_UNSUPPORTED  0x0
 
 
 /***********************************/
@@ -7325,12 +8320,22 @@
 /* MC_CMD_DPCPU_RPC_IN msgrequest */
 #define    MC_CMD_DPCPU_RPC_IN_LEN 36
 #define       MC_CMD_DPCPU_RPC_IN_CPU_OFST 0
-/* enum: RxDPCPU */
-#define          MC_CMD_DPCPU_RPC_IN_DPCPU_RX   0x0
+/* enum: RxDPCPU0 */
+#define          MC_CMD_DPCPU_RPC_IN_DPCPU_RX0  0x0
 /* enum: TxDPCPU0 */
 #define          MC_CMD_DPCPU_RPC_IN_DPCPU_TX0  0x1
 /* enum: TxDPCPU1 */
 #define          MC_CMD_DPCPU_RPC_IN_DPCPU_TX1  0x2
+/* enum: RxDPCPU1 (Medford only) */
+#define          MC_CMD_DPCPU_RPC_IN_DPCPU_RX1   0x3
+/* enum: RxDPCPU (will be for the calling function; for now, just an alias of
+ * DPCPU_RX0)
+ */
+#define          MC_CMD_DPCPU_RPC_IN_DPCPU_RX   0x80
+/* enum: TxDPCPU (will be for the calling function; for now, just an alias of
+ * DPCPU_TX0)
+ */
+#define          MC_CMD_DPCPU_RPC_IN_DPCPU_TX   0x81
 /* First 8 bits [39:32] of DATA are consumed by MC-DPCPU protocol and must be
  * initialised to zero
  */
@@ -7418,6 +8423,25 @@
 
 
 /***********************************/
+/* MC_CMD_SHMBOOT_OP
+ * Special operations to support (for now) shmboot.
+ */
+#define MC_CMD_SHMBOOT_OP 0xe6
+
+#define MC_CMD_0xe6_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
+/* MC_CMD_SHMBOOT_OP_IN msgrequest */
+#define    MC_CMD_SHMBOOT_OP_IN_LEN 4
+/* Identifies the operation to perform */
+#define       MC_CMD_SHMBOOT_OP_IN_SHMBOOT_OP_OFST 0
+/* enum: Copy slave_data section to the slave core. (Greenport only) */
+#define          MC_CMD_SHMBOOT_OP_IN_PUSH_SLAVE_DATA  0x0
+
+/* MC_CMD_SHMBOOT_OP_OUT msgresponse */
+#define    MC_CMD_SHMBOOT_OP_OUT_LEN 0
+
+
+/***********************************/
 /* MC_CMD_CAP_BLK_READ
  * Read multiple 64bit words from capture block memory
  */
@@ -7730,6 +8754,8 @@
  * more data is returned.
  */
 #define          MC_CMD_KR_TUNE_IN_POLL_EYE_PLOT  0x6
+/* enum: Read Figure Of Merit (eye quality, higher is better). */
+#define          MC_CMD_KR_TUNE_IN_READ_FOM  0x7
 /* Align the arguments to 32 bits */
 #define       MC_CMD_KR_TUNE_IN_KR_TUNE_RSVD_OFST 1
 #define       MC_CMD_KR_TUNE_IN_KR_TUNE_RSVD_LEN 3
@@ -7762,20 +8788,32 @@
 #define       MC_CMD_KR_TUNE_RXEQ_GET_OUT_PARAM_MAXNUM 63
 #define        MC_CMD_KR_TUNE_RXEQ_GET_OUT_PARAM_ID_LBN 0
 #define        MC_CMD_KR_TUNE_RXEQ_GET_OUT_PARAM_ID_WIDTH 8
-/* enum: Attenuation (0-15) */
+/* enum: Attenuation (0-15, TBD for Medford) */
 #define          MC_CMD_KR_TUNE_RXEQ_GET_OUT_ATT  0x0
-/* enum: CTLE Boost (0-15) */
+/* enum: CTLE Boost (0-15, TBD for Medford) */
 #define          MC_CMD_KR_TUNE_RXEQ_GET_OUT_BOOST  0x1
-/* enum: Edge DFE Tap1 (0 - max negative, 64 - zero, 127 - max positive) */
+/* enum: Edge DFE Tap1 (0 - max negative, 64 - zero, 127 - max positive, TBD
+ * for Medford)
+ */
 #define          MC_CMD_KR_TUNE_RXEQ_GET_OUT_EDFE_TAP1  0x2
-/* enum: Edge DFE Tap2 (0 - max negative, 32 - zero, 63 - max positive) */
+/* enum: Edge DFE Tap2 (0 - max negative, 32 - zero, 63 - max positive, TBD for
+ * Medford)
+ */
 #define          MC_CMD_KR_TUNE_RXEQ_GET_OUT_EDFE_TAP2  0x3
-/* enum: Edge DFE Tap3 (0 - max negative, 32 - zero, 63 - max positive) */
+/* enum: Edge DFE Tap3 (0 - max negative, 32 - zero, 63 - max positive, TBD for
+ * Medford)
+ */
 #define          MC_CMD_KR_TUNE_RXEQ_GET_OUT_EDFE_TAP3  0x4
-/* enum: Edge DFE Tap4 (0 - max negative, 32 - zero, 63 - max positive) */
+/* enum: Edge DFE Tap4 (0 - max negative, 32 - zero, 63 - max positive, TBD for
+ * Medford)
+ */
 #define          MC_CMD_KR_TUNE_RXEQ_GET_OUT_EDFE_TAP4  0x5
-/* enum: Edge DFE Tap5 (0 - max negative, 32 - zero, 63 - max positive) */
+/* enum: Edge DFE Tap5 (0 - max negative, 32 - zero, 63 - max positive, TBD for
+ * Medford)
+ */
 #define          MC_CMD_KR_TUNE_RXEQ_GET_OUT_EDFE_TAP5  0x6
+/* enum: Edge DFE DLEV (TBD for Medford) */
+#define          MC_CMD_KR_TUNE_RXEQ_GET_OUT_EDFE_DLEV  0x7
 #define        MC_CMD_KR_TUNE_RXEQ_GET_OUT_PARAM_LANE_LBN 8
 #define        MC_CMD_KR_TUNE_RXEQ_GET_OUT_PARAM_LANE_WIDTH 3
 #define          MC_CMD_KR_TUNE_RXEQ_GET_OUT_LANE_0  0x0 /* enum */
@@ -7865,6 +8903,8 @@
 #define          MC_CMD_KR_TUNE_TXEQ_GET_OUT_TX_PREDRV_DLY  0x7
 /* enum: TX Slew Rate Fine control */
 #define          MC_CMD_KR_TUNE_TXEQ_GET_OUT_TX_SR_SET  0x8
+/* enum: TX Termination Impedance control */
+#define          MC_CMD_KR_TUNE_TXEQ_GET_OUT_TX_RT_SET  0x9
 #define        MC_CMD_KR_TUNE_TXEQ_GET_OUT_PARAM_LANE_LBN 8
 #define        MC_CMD_KR_TUNE_TXEQ_GET_OUT_PARAM_LANE_WIDTH 3
 #define          MC_CMD_KR_TUNE_TXEQ_GET_OUT_LANE_0  0x0 /* enum */
@@ -7955,6 +8995,20 @@
 #define       MC_CMD_KR_TUNE_POLL_EYE_PLOT_OUT_SAMPLES_MINNUM 0
 #define       MC_CMD_KR_TUNE_POLL_EYE_PLOT_OUT_SAMPLES_MAXNUM 126
 
+/* MC_CMD_KR_TUNE_READ_FOM_IN msgrequest */
+#define    MC_CMD_KR_TUNE_READ_FOM_IN_LEN 8
+/* Requested operation */
+#define       MC_CMD_KR_TUNE_READ_FOM_IN_KR_TUNE_OP_OFST 0
+#define       MC_CMD_KR_TUNE_READ_FOM_IN_KR_TUNE_OP_LEN 1
+/* Align the arguments to 32 bits */
+#define       MC_CMD_KR_TUNE_READ_FOM_IN_KR_TUNE_RSVD_OFST 1
+#define       MC_CMD_KR_TUNE_READ_FOM_IN_KR_TUNE_RSVD_LEN 3
+#define       MC_CMD_KR_TUNE_READ_FOM_IN_LANE_OFST 4
+
+/* MC_CMD_KR_TUNE_READ_FOM_OUT msgresponse */
+#define    MC_CMD_KR_TUNE_READ_FOM_OUT_LEN 4
+#define       MC_CMD_KR_TUNE_READ_FOM_OUT_FOM_OFST 0
+
 
 /***********************************/
 /* MC_CMD_PCIE_TUNE
@@ -8224,6 +9278,8 @@
 #define       MC_CMD_LICENSED_APP_OP_IN_OP_OFST 4
 /* enum: validate application */
 #define          MC_CMD_LICENSED_APP_OP_IN_OP_VALIDATE  0x0
+/* enum: mask application */
+#define          MC_CMD_LICENSED_APP_OP_IN_OP_MASK  0x1
 /* arguments specific to this particular operation */
 #define       MC_CMD_LICENSED_APP_OP_IN_ARGS_OFST 8
 #define       MC_CMD_LICENSED_APP_OP_IN_ARGS_LEN 4
@@ -8258,10 +9314,22 @@
 #define       MC_CMD_LICENSED_APP_OP_VALIDATE_OUT_RESPONSE_OFST 4
 #define       MC_CMD_LICENSED_APP_OP_VALIDATE_OUT_RESPONSE_LEN 64
 
+/* MC_CMD_LICENSED_APP_OP_MASK_IN msgrequest */
+#define    MC_CMD_LICENSED_APP_OP_MASK_IN_LEN 12
+/* application ID */
+#define       MC_CMD_LICENSED_APP_OP_MASK_IN_APP_ID_OFST 0
+/* the type of operation requested */
+#define       MC_CMD_LICENSED_APP_OP_MASK_IN_OP_OFST 4
+/* flag */
+#define       MC_CMD_LICENSED_APP_OP_MASK_IN_FLAG_OFST 8
+
+/* MC_CMD_LICENSED_APP_OP_MASK_OUT msgresponse */
+#define    MC_CMD_LICENSED_APP_OP_MASK_OUT_LEN 0
+
 
 /***********************************/
 /* MC_CMD_SET_PORT_SNIFF_CONFIG
- * Configure port sniffing for the physical port associated with the calling
+ * Configure RX port sniffing for the physical port associated with the calling
  * function. Only a privileged function may change the port sniffing
  * configuration. A copy of all traffic delivered to the host (non-promiscuous
  * mode) or all traffic arriving at the port (promiscuous mode) may be
@@ -8299,7 +9367,7 @@
 
 /***********************************/
 /* MC_CMD_GET_PORT_SNIFF_CONFIG
- * Obtain the current port sniffing configuration for the physical port
+ * Obtain the current RX port sniffing configuration for the physical port
  * associated with the calling function. Only a privileged function may read
  * the configuration.
  */
@@ -8330,4 +9398,673 @@
 #define       MC_CMD_GET_PORT_SNIFF_CONFIG_OUT_RX_CONTEXT_OFST 12
 
 
+/***********************************/
+/* MC_CMD_SET_PARSER_DISP_CONFIG
+ * Change configuration related to the parser-dispatcher subsystem.
+ */
+#define MC_CMD_SET_PARSER_DISP_CONFIG 0xf9
+
+#define MC_CMD_0xf9_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
+/* MC_CMD_SET_PARSER_DISP_CONFIG_IN msgrequest */
+#define    MC_CMD_SET_PARSER_DISP_CONFIG_IN_LENMIN 12
+#define    MC_CMD_SET_PARSER_DISP_CONFIG_IN_LENMAX 252
+#define    MC_CMD_SET_PARSER_DISP_CONFIG_IN_LEN(num) (8+4*(num))
+/* the type of configuration setting to change */
+#define       MC_CMD_SET_PARSER_DISP_CONFIG_IN_TYPE_OFST 0
+/* enum: Per-TXQ enable for multicast UDP destination lookup for possible
+ * internal loopback. (ENTITY is a queue handle, VALUE is a single boolean.)
+ */
+#define          MC_CMD_SET_PARSER_DISP_CONFIG_IN_TXQ_MCAST_UDP_DST_LOOKUP_EN  0x0
+/* enum: Per-v-adaptor enable for suppression of self-transmissions on the
+ * internal loopback path. (ENTITY is an EVB_PORT_ID, VALUE is a single
+ * boolean.)
+ */
+#define          MC_CMD_SET_PARSER_DISP_CONFIG_IN_VADAPTOR_SUPPRESS_SELF_TX  0x1
+/* handle for the entity to update: queue handle, EVB port ID, etc. depending
+ * on the type of configuration setting being changed
+ */
+#define       MC_CMD_SET_PARSER_DISP_CONFIG_IN_ENTITY_OFST 4
+/* new value: the details depend on the type of configuration setting being
+ * changed
+ */
+#define       MC_CMD_SET_PARSER_DISP_CONFIG_IN_VALUE_OFST 8
+#define       MC_CMD_SET_PARSER_DISP_CONFIG_IN_VALUE_LEN 4
+#define       MC_CMD_SET_PARSER_DISP_CONFIG_IN_VALUE_MINNUM 1
+#define       MC_CMD_SET_PARSER_DISP_CONFIG_IN_VALUE_MAXNUM 61
+
+/* MC_CMD_SET_PARSER_DISP_CONFIG_OUT msgresponse */
+#define    MC_CMD_SET_PARSER_DISP_CONFIG_OUT_LEN 0
+
+
+/***********************************/
+/* MC_CMD_GET_PARSER_DISP_CONFIG
+ * Read configuration related to the parser-dispatcher subsystem.
+ */
+#define MC_CMD_GET_PARSER_DISP_CONFIG 0xfa
+
+#define MC_CMD_0xfa_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
+/* MC_CMD_GET_PARSER_DISP_CONFIG_IN msgrequest */
+#define    MC_CMD_GET_PARSER_DISP_CONFIG_IN_LEN 8
+/* the type of configuration setting to read */
+#define       MC_CMD_GET_PARSER_DISP_CONFIG_IN_TYPE_OFST 0
+/*            Enum values, see field(s): */
+/*               MC_CMD_SET_PARSER_DISP_CONFIG/MC_CMD_SET_PARSER_DISP_CONFIG_IN/TYPE */
+/* handle for the entity to query: queue handle, EVB port ID, etc. depending on
+ * the type of configuration setting being read
+ */
+#define       MC_CMD_GET_PARSER_DISP_CONFIG_IN_ENTITY_OFST 4
+
+/* MC_CMD_GET_PARSER_DISP_CONFIG_OUT msgresponse */
+#define    MC_CMD_GET_PARSER_DISP_CONFIG_OUT_LENMIN 4
+#define    MC_CMD_GET_PARSER_DISP_CONFIG_OUT_LENMAX 252
+#define    MC_CMD_GET_PARSER_DISP_CONFIG_OUT_LEN(num) (0+4*(num))
+/* current value: the details depend on the type of configuration setting being
+ * read
+ */
+#define       MC_CMD_GET_PARSER_DISP_CONFIG_OUT_VALUE_OFST 0
+#define       MC_CMD_GET_PARSER_DISP_CONFIG_OUT_VALUE_LEN 4
+#define       MC_CMD_GET_PARSER_DISP_CONFIG_OUT_VALUE_MINNUM 1
+#define       MC_CMD_GET_PARSER_DISP_CONFIG_OUT_VALUE_MAXNUM 63
+
+
+/***********************************/
+/* MC_CMD_SET_TX_PORT_SNIFF_CONFIG
+ * Configure TX port sniffing for the physical port associated with the calling
+ * function. Only a privileged function may change the port sniffing
+ * configuration. A copy of all traffic transmitted through the port may be
+ * delivered to a specific queue, or a set of queues with RSS. Note that these
+ * packets are delivered with transmit timestamps in the packet prefix, not
+ * receive timestamps, so it is likely that the queue(s) will need to be
+ * dedicated as TX sniff receivers.
+ */
+#define MC_CMD_SET_TX_PORT_SNIFF_CONFIG 0xfb
+
+#define MC_CMD_0xfb_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
+/* MC_CMD_SET_TX_PORT_SNIFF_CONFIG_IN msgrequest */
+#define    MC_CMD_SET_TX_PORT_SNIFF_CONFIG_IN_LEN 16
+/* configuration flags */
+#define       MC_CMD_SET_TX_PORT_SNIFF_CONFIG_IN_FLAGS_OFST 0
+#define        MC_CMD_SET_TX_PORT_SNIFF_CONFIG_IN_ENABLE_LBN 0
+#define        MC_CMD_SET_TX_PORT_SNIFF_CONFIG_IN_ENABLE_WIDTH 1
+/* receive queue handle (for RSS mode, this is the base queue) */
+#define       MC_CMD_SET_TX_PORT_SNIFF_CONFIG_IN_RX_QUEUE_OFST 4
+/* receive mode */
+#define       MC_CMD_SET_TX_PORT_SNIFF_CONFIG_IN_RX_MODE_OFST 8
+/* enum: receive to just the specified queue */
+#define          MC_CMD_SET_TX_PORT_SNIFF_CONFIG_IN_RX_MODE_SIMPLE  0x0
+/* enum: receive to multiple queues using RSS context */
+#define          MC_CMD_SET_TX_PORT_SNIFF_CONFIG_IN_RX_MODE_RSS  0x1
+/* RSS context (for RX_MODE_RSS) as returned by MC_CMD_RSS_CONTEXT_ALLOC. Note
+ * that these handles should be considered opaque to the host, although a value
+ * of 0xFFFFFFFF is guaranteed never to be a valid handle.
+ */
+#define       MC_CMD_SET_TX_PORT_SNIFF_CONFIG_IN_RX_CONTEXT_OFST 12
+
+/* MC_CMD_SET_TX_PORT_SNIFF_CONFIG_OUT msgresponse */
+#define    MC_CMD_SET_TX_PORT_SNIFF_CONFIG_OUT_LEN 0
+
+
+/***********************************/
+/* MC_CMD_GET_TX_PORT_SNIFF_CONFIG
+ * Obtain the current TX port sniffing configuration for the physical port
+ * associated with the calling function. Only a privileged function may read
+ * the configuration.
+ */
+#define MC_CMD_GET_TX_PORT_SNIFF_CONFIG 0xfc
+
+#define MC_CMD_0xfc_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
+/* MC_CMD_GET_TX_PORT_SNIFF_CONFIG_IN msgrequest */
+#define    MC_CMD_GET_TX_PORT_SNIFF_CONFIG_IN_LEN 0
+
+/* MC_CMD_GET_TX_PORT_SNIFF_CONFIG_OUT msgresponse */
+#define    MC_CMD_GET_TX_PORT_SNIFF_CONFIG_OUT_LEN 16
+/* configuration flags */
+#define       MC_CMD_GET_TX_PORT_SNIFF_CONFIG_OUT_FLAGS_OFST 0
+#define        MC_CMD_GET_TX_PORT_SNIFF_CONFIG_OUT_ENABLE_LBN 0
+#define        MC_CMD_GET_TX_PORT_SNIFF_CONFIG_OUT_ENABLE_WIDTH 1
+/* receiving queue handle (for RSS mode, this is the base queue) */
+#define       MC_CMD_GET_TX_PORT_SNIFF_CONFIG_OUT_RX_QUEUE_OFST 4
+/* receive mode */
+#define       MC_CMD_GET_TX_PORT_SNIFF_CONFIG_OUT_RX_MODE_OFST 8
+/* enum: receiving to just the specified queue */
+#define          MC_CMD_GET_TX_PORT_SNIFF_CONFIG_OUT_RX_MODE_SIMPLE  0x0
+/* enum: receiving to multiple queues using RSS context */
+#define          MC_CMD_GET_TX_PORT_SNIFF_CONFIG_OUT_RX_MODE_RSS  0x1
+/* RSS context (for RX_MODE_RSS) */
+#define       MC_CMD_GET_TX_PORT_SNIFF_CONFIG_OUT_RX_CONTEXT_OFST 12
+
+
+/***********************************/
+/* MC_CMD_RMON_STATS_RX_ERRORS
+ * Per queue rx error stats.
+ */
+#define MC_CMD_RMON_STATS_RX_ERRORS 0xfe
+
+#define MC_CMD_0xfe_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
+/* MC_CMD_RMON_STATS_RX_ERRORS_IN msgrequest */
+#define    MC_CMD_RMON_STATS_RX_ERRORS_IN_LEN 8
+/* The rx queue to get stats for. */
+#define       MC_CMD_RMON_STATS_RX_ERRORS_IN_RX_QUEUE_OFST 0
+#define       MC_CMD_RMON_STATS_RX_ERRORS_IN_FLAGS_OFST 4
+#define        MC_CMD_RMON_STATS_RX_ERRORS_IN_RST_LBN 0
+#define        MC_CMD_RMON_STATS_RX_ERRORS_IN_RST_WIDTH 1
+
+/* MC_CMD_RMON_STATS_RX_ERRORS_OUT msgresponse */
+#define    MC_CMD_RMON_STATS_RX_ERRORS_OUT_LEN 16
+#define       MC_CMD_RMON_STATS_RX_ERRORS_OUT_CRC_ERRORS_OFST 0
+#define       MC_CMD_RMON_STATS_RX_ERRORS_OUT_TRUNC_ERRORS_OFST 4
+#define       MC_CMD_RMON_STATS_RX_ERRORS_OUT_RX_NO_DESC_DROPS_OFST 8
+#define       MC_CMD_RMON_STATS_RX_ERRORS_OUT_RX_ABORT_OFST 12
+
+
+/***********************************/
+/* MC_CMD_GET_PCIE_RESOURCE_INFO
+ * Find out about available PCIE resources
+ */
+#define MC_CMD_GET_PCIE_RESOURCE_INFO 0xfd
+
+/* MC_CMD_GET_PCIE_RESOURCE_INFO_IN msgrequest */
+#define    MC_CMD_GET_PCIE_RESOURCE_INFO_IN_LEN 0
+
+/* MC_CMD_GET_PCIE_RESOURCE_INFO_OUT msgresponse */
+#define    MC_CMD_GET_PCIE_RESOURCE_INFO_OUT_LEN 28
+/* The maximum number of PFs the device can expose */
+#define       MC_CMD_GET_PCIE_RESOURCE_INFO_OUT_MAX_PFS_OFST 0
+/* The maximum number of VFs the device can expose in total */
+#define       MC_CMD_GET_PCIE_RESOURCE_INFO_OUT_MAX_VFS_OFST 4
+/* The maximum number of MSI-X vectors the device can provide in total */
+#define       MC_CMD_GET_PCIE_RESOURCE_INFO_OUT_MAX_VECTORS_OFST 8
+/* the number of MSI-X vectors the device will allocate by default to each PF
+ */
+#define       MC_CMD_GET_PCIE_RESOURCE_INFO_OUT_DEFAULT_PF_VECTORS_OFST 12
+/* the number of MSI-X vectors the device will allocate by default to each VF
+ */
+#define       MC_CMD_GET_PCIE_RESOURCE_INFO_OUT_DEFAULT_VF_VECTORS_OFST 16
+/* the maximum number of MSI-X vectors the device can allocate to any one PF */
+#define       MC_CMD_GET_PCIE_RESOURCE_INFO_OUT_MAX_PF_VECTORS_OFST 20
+/* the maximum number of MSI-X vectors the device can allocate to any one VF */
+#define       MC_CMD_GET_PCIE_RESOURCE_INFO_OUT_MAX_VF_VECTORS_OFST 24
+
+
+/***********************************/
+/* MC_CMD_GET_PORT_MODES
+ * Find out about available port modes
+ */
+#define MC_CMD_GET_PORT_MODES 0xff
+
+#define MC_CMD_0xff_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
+/* MC_CMD_GET_PORT_MODES_IN msgrequest */
+#define    MC_CMD_GET_PORT_MODES_IN_LEN 0
+
+/* MC_CMD_GET_PORT_MODES_OUT msgresponse */
+#define    MC_CMD_GET_PORT_MODES_OUT_LEN 12
+/* Bitmask of port modes available on the board (indexed by TLV_PORT_MODE_*) */
+#define       MC_CMD_GET_PORT_MODES_OUT_MODES_OFST 0
+/* Default (canonical) board mode */
+#define       MC_CMD_GET_PORT_MODES_OUT_DEFAULT_MODE_OFST 4
+/* Current board mode */
+#define       MC_CMD_GET_PORT_MODES_OUT_CURRENT_MODE_OFST 8
+
+
+/***********************************/
+/* MC_CMD_READ_ATB
+ * Sample voltages on the ATB
+ */
+#define MC_CMD_READ_ATB 0x100
+
+#define MC_CMD_0x100_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
+/* MC_CMD_READ_ATB_IN msgrequest */
+#define    MC_CMD_READ_ATB_IN_LEN 16
+#define       MC_CMD_READ_ATB_IN_SIGNAL_BUS_OFST 0
+#define          MC_CMD_READ_ATB_IN_BUS_CCOM  0x0 /* enum */
+#define          MC_CMD_READ_ATB_IN_BUS_CKR  0x1 /* enum */
+#define          MC_CMD_READ_ATB_IN_BUS_CPCIE  0x8 /* enum */
+#define       MC_CMD_READ_ATB_IN_SIGNAL_EN_BITNO_OFST 4
+#define       MC_CMD_READ_ATB_IN_SIGNAL_SEL_OFST 8
+#define       MC_CMD_READ_ATB_IN_SETTLING_TIME_US_OFST 12
+
+/* MC_CMD_READ_ATB_OUT msgresponse */
+#define    MC_CMD_READ_ATB_OUT_LEN 4
+#define       MC_CMD_READ_ATB_OUT_SAMPLE_MV_OFST 0
+
+
+/***********************************/
+/* MC_CMD_GET_WORKAROUNDS
+ * Read the list of all implemented and all currently enabled workarounds. The
+ * enums here must correspond with those in MC_CMD_WORKAROUND.
+ */
+#define MC_CMD_GET_WORKAROUNDS 0x59
+
+#define MC_CMD_0x59_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
+/* MC_CMD_GET_WORKAROUNDS_OUT msgresponse */
+#define    MC_CMD_GET_WORKAROUNDS_OUT_LEN 8
+/* Each workaround is represented by a single bit according to the enums below.
+ */
+#define       MC_CMD_GET_WORKAROUNDS_OUT_IMPLEMENTED_OFST 0
+#define       MC_CMD_GET_WORKAROUNDS_OUT_ENABLED_OFST 4
+/* enum: Bug 17230 work around. */
+#define          MC_CMD_GET_WORKAROUNDS_OUT_BUG17230 0x2
+/* enum: Bug 35388 work around (unsafe EVQ writes). */
+#define          MC_CMD_GET_WORKAROUNDS_OUT_BUG35388 0x4
+/* enum: Bug35017 workaround (A64 tables must be identity map) */
+#define          MC_CMD_GET_WORKAROUNDS_OUT_BUG35017 0x8
+/* enum: Bug 41750 present (MC_CMD_TRIGGER_INTERRUPT won't work) */
+#define          MC_CMD_GET_WORKAROUNDS_OUT_BUG41750 0x10
+/* enum: Bug 42008 present (Interrupts can overtake associated events). Caution
+ * - before adding code that queries this workaround, remember that there's
+ * released Monza firmware that doesn't understand MC_CMD_WORKAROUND_BUG42008,
+ * and will hence (incorrectly) report that the bug doesn't exist.
+ */
+#define          MC_CMD_GET_WORKAROUNDS_OUT_BUG42008 0x20
+/* enum: Bug 26807 features present in firmware (multicast filter chaining) */
+#define          MC_CMD_GET_WORKAROUNDS_OUT_BUG26807 0x40
+
+
+/***********************************/
+/* MC_CMD_PRIVILEGE_MASK
+ * Read/set privileges of an arbitrary PCIe function
+ */
+#define MC_CMD_PRIVILEGE_MASK 0x5a
+
+#define MC_CMD_0x5a_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
+/* MC_CMD_PRIVILEGE_MASK_IN msgrequest */
+#define    MC_CMD_PRIVILEGE_MASK_IN_LEN 8
+/* The target function to have its mask read or set e.g. PF 0 = 0xFFFF0000, VF
+ * 1,3 = 0x00030001
+ */
+#define       MC_CMD_PRIVILEGE_MASK_IN_FUNCTION_OFST 0
+#define        MC_CMD_PRIVILEGE_MASK_IN_FUNCTION_PF_LBN 0
+#define        MC_CMD_PRIVILEGE_MASK_IN_FUNCTION_PF_WIDTH 16
+#define        MC_CMD_PRIVILEGE_MASK_IN_FUNCTION_VF_LBN 16
+#define        MC_CMD_PRIVILEGE_MASK_IN_FUNCTION_VF_WIDTH 16
+#define          MC_CMD_PRIVILEGE_MASK_IN_VF_NULL  0xffff /* enum */
+/* New privilege mask to be set. The mask will only be changed if the MSB is
+ * set to 1.
+ */
+#define       MC_CMD_PRIVILEGE_MASK_IN_NEW_MASK_OFST 4
+#define          MC_CMD_PRIVILEGE_MASK_IN_GRP_ADMIN             0x1 /* enum */
+#define          MC_CMD_PRIVILEGE_MASK_IN_GRP_LINK              0x2 /* enum */
+#define          MC_CMD_PRIVILEGE_MASK_IN_GRP_ONLOAD            0x4 /* enum */
+#define          MC_CMD_PRIVILEGE_MASK_IN_GRP_PTP               0x8 /* enum */
+#define          MC_CMD_PRIVILEGE_MASK_IN_GRP_INSECURE_FILTERS  0x10 /* enum */
+#define          MC_CMD_PRIVILEGE_MASK_IN_GRP_MAC_SPOOFING      0x20 /* enum */
+#define          MC_CMD_PRIVILEGE_MASK_IN_GRP_UNICAST           0x40 /* enum */
+#define          MC_CMD_PRIVILEGE_MASK_IN_GRP_MULTICAST         0x80 /* enum */
+#define          MC_CMD_PRIVILEGE_MASK_IN_GRP_BROADCAST         0x100 /* enum */
+#define          MC_CMD_PRIVILEGE_MASK_IN_GRP_ALL_MULTICAST     0x200 /* enum */
+#define          MC_CMD_PRIVILEGE_MASK_IN_GRP_PROMISCUOUS       0x400 /* enum */
+/* enum: Set this bit to indicate that a new privilege mask is to be set,
+ * otherwise the command will only read the existing mask.
+ */
+#define          MC_CMD_PRIVILEGE_MASK_IN_DO_CHANGE             0x80000000
+
+/* MC_CMD_PRIVILEGE_MASK_OUT msgresponse */
+#define    MC_CMD_PRIVILEGE_MASK_OUT_LEN 4
+/* For an admin function, always all the privileges are reported. */
+#define       MC_CMD_PRIVILEGE_MASK_OUT_OLD_MASK_OFST 0
+
+
+/***********************************/
+/* MC_CMD_LINK_STATE_MODE
+ * Read/set link state mode of a VF
+ */
+#define MC_CMD_LINK_STATE_MODE 0x5c
+
+#define MC_CMD_0x5c_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
+/* MC_CMD_LINK_STATE_MODE_IN msgrequest */
+#define    MC_CMD_LINK_STATE_MODE_IN_LEN 8
+/* The target function to have its link state mode read or set, must be a VF
+ * e.g. VF 1,3 = 0x00030001
+ */
+#define       MC_CMD_LINK_STATE_MODE_IN_FUNCTION_OFST 0
+#define        MC_CMD_LINK_STATE_MODE_IN_FUNCTION_PF_LBN 0
+#define        MC_CMD_LINK_STATE_MODE_IN_FUNCTION_PF_WIDTH 16
+#define        MC_CMD_LINK_STATE_MODE_IN_FUNCTION_VF_LBN 16
+#define        MC_CMD_LINK_STATE_MODE_IN_FUNCTION_VF_WIDTH 16
+/* New link state mode to be set */
+#define       MC_CMD_LINK_STATE_MODE_IN_NEW_MODE_OFST 4
+#define          MC_CMD_LINK_STATE_MODE_IN_LINK_STATE_AUTO       0x0 /* enum */
+#define          MC_CMD_LINK_STATE_MODE_IN_LINK_STATE_UP         0x1 /* enum */
+#define          MC_CMD_LINK_STATE_MODE_IN_LINK_STATE_DOWN       0x2 /* enum */
+/* enum: Use this value to just read the existing setting without modifying it.
+ */
+#define          MC_CMD_LINK_STATE_MODE_IN_DO_NOT_CHANGE         0xffffffff
+
+/* MC_CMD_LINK_STATE_MODE_OUT msgresponse */
+#define    MC_CMD_LINK_STATE_MODE_OUT_LEN 4
+#define       MC_CMD_LINK_STATE_MODE_OUT_OLD_MODE_OFST 0
+
+
+/***********************************/
+/* MC_CMD_GET_SNAPSHOT_LENGTH
+ * Obtain the curent range of allowable values for the SNAPSHOT_LENGTH
+ * parameter to MC_CMD_INIT_RXQ.
+ */
+#define MC_CMD_GET_SNAPSHOT_LENGTH 0x101
+
+#define MC_CMD_0x101_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
+/* MC_CMD_GET_SNAPSHOT_LENGTH_IN msgrequest */
+#define    MC_CMD_GET_SNAPSHOT_LENGTH_IN_LEN 0
+
+/* MC_CMD_GET_SNAPSHOT_LENGTH_OUT msgresponse */
+#define    MC_CMD_GET_SNAPSHOT_LENGTH_OUT_LEN 8
+/* Minimum acceptable snapshot length. */
+#define       MC_CMD_GET_SNAPSHOT_LENGTH_OUT_RX_SNAPLEN_MIN_OFST 0
+/* Maximum acceptable snapshot length. */
+#define       MC_CMD_GET_SNAPSHOT_LENGTH_OUT_RX_SNAPLEN_MAX_OFST 4
+
+
+/***********************************/
+/* MC_CMD_FUSE_DIAGS
+ * Additional fuse diagnostics
+ */
+#define MC_CMD_FUSE_DIAGS 0x102
+
+#define MC_CMD_0x102_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
+/* MC_CMD_FUSE_DIAGS_IN msgrequest */
+#define    MC_CMD_FUSE_DIAGS_IN_LEN 0
+
+/* MC_CMD_FUSE_DIAGS_OUT msgresponse */
+#define    MC_CMD_FUSE_DIAGS_OUT_LEN 48
+/* Total number of mismatched bits between pairs in area 0 */
+#define       MC_CMD_FUSE_DIAGS_OUT_AREA0_MISMATCH_BITS_OFST 0
+/* Total number of unexpectedly clear (set in B but not A) bits in area 0 */
+#define       MC_CMD_FUSE_DIAGS_OUT_AREA0_PAIR_A_BAD_BITS_OFST 4
+/* Total number of unexpectedly clear (set in A but not B) bits in area 0 */
+#define       MC_CMD_FUSE_DIAGS_OUT_AREA0_PAIR_B_BAD_BITS_OFST 8
+/* Checksum of data after logical OR of pairs in area 0 */
+#define       MC_CMD_FUSE_DIAGS_OUT_AREA0_CHECKSUM_OFST 12
+/* Total number of mismatched bits between pairs in area 1 */
+#define       MC_CMD_FUSE_DIAGS_OUT_AREA1_MISMATCH_BITS_OFST 16
+/* Total number of unexpectedly clear (set in B but not A) bits in area 1 */
+#define       MC_CMD_FUSE_DIAGS_OUT_AREA1_PAIR_A_BAD_BITS_OFST 20
+/* Total number of unexpectedly clear (set in A but not B) bits in area 1 */
+#define       MC_CMD_FUSE_DIAGS_OUT_AREA1_PAIR_B_BAD_BITS_OFST 24
+/* Checksum of data after logical OR of pairs in area 1 */
+#define       MC_CMD_FUSE_DIAGS_OUT_AREA1_CHECKSUM_OFST 28
+/* Total number of mismatched bits between pairs in area 2 */
+#define       MC_CMD_FUSE_DIAGS_OUT_AREA2_MISMATCH_BITS_OFST 32
+/* Total number of unexpectedly clear (set in B but not A) bits in area 2 */
+#define       MC_CMD_FUSE_DIAGS_OUT_AREA2_PAIR_A_BAD_BITS_OFST 36
+/* Total number of unexpectedly clear (set in A but not B) bits in area 2 */
+#define       MC_CMD_FUSE_DIAGS_OUT_AREA2_PAIR_B_BAD_BITS_OFST 40
+/* Checksum of data after logical OR of pairs in area 2 */
+#define       MC_CMD_FUSE_DIAGS_OUT_AREA2_CHECKSUM_OFST 44
+
+
+/***********************************/
+/* MC_CMD_PRIVILEGE_MODIFY
+ * Modify the privileges of a set of PCIe functions. Note that this operation
+ * only effects non-admin functions unless the admin privilege itself is
+ * included in one of the masks provided.
+ */
+#define MC_CMD_PRIVILEGE_MODIFY 0x60
+
+#define MC_CMD_0x60_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
+/* MC_CMD_PRIVILEGE_MODIFY_IN msgrequest */
+#define    MC_CMD_PRIVILEGE_MODIFY_IN_LEN 16
+/* The groups of functions to have their privilege masks modified. */
+#define       MC_CMD_PRIVILEGE_MODIFY_IN_FN_GROUP_OFST 0
+#define          MC_CMD_PRIVILEGE_MODIFY_IN_NONE       0x0 /* enum */
+#define          MC_CMD_PRIVILEGE_MODIFY_IN_ALL        0x1 /* enum */
+#define          MC_CMD_PRIVILEGE_MODIFY_IN_PFS_ONLY   0x2 /* enum */
+#define          MC_CMD_PRIVILEGE_MODIFY_IN_VFS_ONLY   0x3 /* enum */
+#define          MC_CMD_PRIVILEGE_MODIFY_IN_VFS_OF_PF  0x4 /* enum */
+#define          MC_CMD_PRIVILEGE_MODIFY_IN_ONE        0x5 /* enum */
+/* For VFS_OF_PF specify the PF, for ONE specify the target function */
+#define       MC_CMD_PRIVILEGE_MODIFY_IN_FUNCTION_OFST 4
+#define        MC_CMD_PRIVILEGE_MODIFY_IN_FUNCTION_PF_LBN 0
+#define        MC_CMD_PRIVILEGE_MODIFY_IN_FUNCTION_PF_WIDTH 16
+#define        MC_CMD_PRIVILEGE_MODIFY_IN_FUNCTION_VF_LBN 16
+#define        MC_CMD_PRIVILEGE_MODIFY_IN_FUNCTION_VF_WIDTH 16
+/* Privileges to be added to the target functions. For privilege definitions
+ * refer to the command MC_CMD_PRIVILEGE_MASK
+ */
+#define       MC_CMD_PRIVILEGE_MODIFY_IN_ADD_MASK_OFST 8
+/* Privileges to be removed from the target functions. For privilege
+ * definitions refer to the command MC_CMD_PRIVILEGE_MASK
+ */
+#define       MC_CMD_PRIVILEGE_MODIFY_IN_REMOVE_MASK_OFST 12
+
+/* MC_CMD_PRIVILEGE_MODIFY_OUT msgresponse */
+#define    MC_CMD_PRIVILEGE_MODIFY_OUT_LEN 0
+
+
+/***********************************/
+/* MC_CMD_XPM_READ_BYTES
+ * Read XPM memory
+ */
+#define MC_CMD_XPM_READ_BYTES 0x103
+
+#define MC_CMD_0x103_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
+/* MC_CMD_XPM_READ_BYTES_IN msgrequest */
+#define    MC_CMD_XPM_READ_BYTES_IN_LEN 8
+/* Start address (byte) */
+#define       MC_CMD_XPM_READ_BYTES_IN_ADDR_OFST 0
+/* Count (bytes) */
+#define       MC_CMD_XPM_READ_BYTES_IN_COUNT_OFST 4
+
+/* MC_CMD_XPM_READ_BYTES_OUT msgresponse */
+#define    MC_CMD_XPM_READ_BYTES_OUT_LENMIN 0
+#define    MC_CMD_XPM_READ_BYTES_OUT_LENMAX 252
+#define    MC_CMD_XPM_READ_BYTES_OUT_LEN(num) (0+1*(num))
+/* Data */
+#define       MC_CMD_XPM_READ_BYTES_OUT_DATA_OFST 0
+#define       MC_CMD_XPM_READ_BYTES_OUT_DATA_LEN 1
+#define       MC_CMD_XPM_READ_BYTES_OUT_DATA_MINNUM 0
+#define       MC_CMD_XPM_READ_BYTES_OUT_DATA_MAXNUM 252
+
+
+/***********************************/
+/* MC_CMD_XPM_WRITE_BYTES
+ * Write XPM memory
+ */
+#define MC_CMD_XPM_WRITE_BYTES 0x104
+
+#define MC_CMD_0x104_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
+/* MC_CMD_XPM_WRITE_BYTES_IN msgrequest */
+#define    MC_CMD_XPM_WRITE_BYTES_IN_LENMIN 8
+#define    MC_CMD_XPM_WRITE_BYTES_IN_LENMAX 252
+#define    MC_CMD_XPM_WRITE_BYTES_IN_LEN(num) (8+1*(num))
+/* Start address (byte) */
+#define       MC_CMD_XPM_WRITE_BYTES_IN_ADDR_OFST 0
+/* Count (bytes) */
+#define       MC_CMD_XPM_WRITE_BYTES_IN_COUNT_OFST 4
+/* Data */
+#define       MC_CMD_XPM_WRITE_BYTES_IN_DATA_OFST 8
+#define       MC_CMD_XPM_WRITE_BYTES_IN_DATA_LEN 1
+#define       MC_CMD_XPM_WRITE_BYTES_IN_DATA_MINNUM 0
+#define       MC_CMD_XPM_WRITE_BYTES_IN_DATA_MAXNUM 244
+
+/* MC_CMD_XPM_WRITE_BYTES_OUT msgresponse */
+#define    MC_CMD_XPM_WRITE_BYTES_OUT_LEN 0
+
+
+/***********************************/
+/* MC_CMD_XPM_READ_SECTOR
+ * Read XPM sector
+ */
+#define MC_CMD_XPM_READ_SECTOR 0x105
+
+#define MC_CMD_0x105_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
+/* MC_CMD_XPM_READ_SECTOR_IN msgrequest */
+#define    MC_CMD_XPM_READ_SECTOR_IN_LEN 8
+/* Sector index */
+#define       MC_CMD_XPM_READ_SECTOR_IN_INDEX_OFST 0
+/* Sector size */
+#define       MC_CMD_XPM_READ_SECTOR_IN_SIZE_OFST 4
+
+/* MC_CMD_XPM_READ_SECTOR_OUT msgresponse */
+#define    MC_CMD_XPM_READ_SECTOR_OUT_LENMIN 4
+#define    MC_CMD_XPM_READ_SECTOR_OUT_LENMAX 36
+#define    MC_CMD_XPM_READ_SECTOR_OUT_LEN(num) (4+1*(num))
+/* Sector type */
+#define       MC_CMD_XPM_READ_SECTOR_OUT_TYPE_OFST 0
+#define          MC_CMD_XPM_READ_SECTOR_OUT_BLANK            0x0 /* enum */
+#define          MC_CMD_XPM_READ_SECTOR_OUT_CRYPTO_KEY_128   0x1 /* enum */
+#define          MC_CMD_XPM_READ_SECTOR_OUT_CRYPTO_KEY_256   0x2 /* enum */
+#define          MC_CMD_XPM_READ_SECTOR_OUT_INVALID          0xff /* enum */
+/* Sector data */
+#define       MC_CMD_XPM_READ_SECTOR_OUT_DATA_OFST 4
+#define       MC_CMD_XPM_READ_SECTOR_OUT_DATA_LEN 1
+#define       MC_CMD_XPM_READ_SECTOR_OUT_DATA_MINNUM 0
+#define       MC_CMD_XPM_READ_SECTOR_OUT_DATA_MAXNUM 32
+
+
+/***********************************/
+/* MC_CMD_XPM_WRITE_SECTOR
+ * Write XPM sector
+ */
+#define MC_CMD_XPM_WRITE_SECTOR 0x106
+
+#define MC_CMD_0x106_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
+/* MC_CMD_XPM_WRITE_SECTOR_IN msgrequest */
+#define    MC_CMD_XPM_WRITE_SECTOR_IN_LENMIN 12
+#define    MC_CMD_XPM_WRITE_SECTOR_IN_LENMAX 44
+#define    MC_CMD_XPM_WRITE_SECTOR_IN_LEN(num) (12+1*(num))
+/* If writing fails due to an uncorrectable error, try up to RETRIES following
+ * sectors (or until no more space available). If 0, only one write attempt is
+ * made. Note that uncorrectable errors are unlikely, thanks to XPM self-repair
+ * mechanism.
+ */
+#define       MC_CMD_XPM_WRITE_SECTOR_IN_RETRIES_OFST 0
+#define       MC_CMD_XPM_WRITE_SECTOR_IN_RETRIES_LEN 1
+#define       MC_CMD_XPM_WRITE_SECTOR_IN_RESERVED_OFST 1
+#define       MC_CMD_XPM_WRITE_SECTOR_IN_RESERVED_LEN 3
+/* Sector type */
+#define       MC_CMD_XPM_WRITE_SECTOR_IN_TYPE_OFST 4
+/*            Enum values, see field(s): */
+/*               MC_CMD_XPM_READ_SECTOR_OUT/TYPE */
+/* Sector size */
+#define       MC_CMD_XPM_WRITE_SECTOR_IN_SIZE_OFST 8
+/* Sector data */
+#define       MC_CMD_XPM_WRITE_SECTOR_IN_DATA_OFST 12
+#define       MC_CMD_XPM_WRITE_SECTOR_IN_DATA_LEN 1
+#define       MC_CMD_XPM_WRITE_SECTOR_IN_DATA_MINNUM 0
+#define       MC_CMD_XPM_WRITE_SECTOR_IN_DATA_MAXNUM 32
+
+/* MC_CMD_XPM_WRITE_SECTOR_OUT msgresponse */
+#define    MC_CMD_XPM_WRITE_SECTOR_OUT_LEN 4
+/* New sector index */
+#define       MC_CMD_XPM_WRITE_SECTOR_OUT_INDEX_OFST 0
+
+
+/***********************************/
+/* MC_CMD_XPM_INVALIDATE_SECTOR
+ * Invalidate XPM sector
+ */
+#define MC_CMD_XPM_INVALIDATE_SECTOR 0x107
+
+#define MC_CMD_0x107_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
+/* MC_CMD_XPM_INVALIDATE_SECTOR_IN msgrequest */
+#define    MC_CMD_XPM_INVALIDATE_SECTOR_IN_LEN 4
+/* Sector index */
+#define       MC_CMD_XPM_INVALIDATE_SECTOR_IN_INDEX_OFST 0
+
+/* MC_CMD_XPM_INVALIDATE_SECTOR_OUT msgresponse */
+#define    MC_CMD_XPM_INVALIDATE_SECTOR_OUT_LEN 0
+
+
+/***********************************/
+/* MC_CMD_XPM_BLANK_CHECK
+ * Blank-check XPM memory and report bad locations
+ */
+#define MC_CMD_XPM_BLANK_CHECK 0x108
+
+#define MC_CMD_0x108_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
+/* MC_CMD_XPM_BLANK_CHECK_IN msgrequest */
+#define    MC_CMD_XPM_BLANK_CHECK_IN_LEN 8
+/* Start address (byte) */
+#define       MC_CMD_XPM_BLANK_CHECK_IN_ADDR_OFST 0
+/* Count (bytes) */
+#define       MC_CMD_XPM_BLANK_CHECK_IN_COUNT_OFST 4
+
+/* MC_CMD_XPM_BLANK_CHECK_OUT msgresponse */
+#define    MC_CMD_XPM_BLANK_CHECK_OUT_LENMIN 4
+#define    MC_CMD_XPM_BLANK_CHECK_OUT_LENMAX 252
+#define    MC_CMD_XPM_BLANK_CHECK_OUT_LEN(num) (4+2*(num))
+/* Total number of bad (non-blank) locations */
+#define       MC_CMD_XPM_BLANK_CHECK_OUT_BAD_COUNT_OFST 0
+/* Addresses of bad locations (may be less than BAD_COUNT, if all cannot fit
+ * into MCDI response)
+ */
+#define       MC_CMD_XPM_BLANK_CHECK_OUT_BAD_ADDR_OFST 4
+#define       MC_CMD_XPM_BLANK_CHECK_OUT_BAD_ADDR_LEN 2
+#define       MC_CMD_XPM_BLANK_CHECK_OUT_BAD_ADDR_MINNUM 0
+#define       MC_CMD_XPM_BLANK_CHECK_OUT_BAD_ADDR_MAXNUM 124
+
+
+/***********************************/
+/* MC_CMD_XPM_REPAIR
+ * Blank-check and repair XPM memory
+ */
+#define MC_CMD_XPM_REPAIR 0x109
+
+#define MC_CMD_0x109_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
+/* MC_CMD_XPM_REPAIR_IN msgrequest */
+#define    MC_CMD_XPM_REPAIR_IN_LEN 8
+/* Start address (byte) */
+#define       MC_CMD_XPM_REPAIR_IN_ADDR_OFST 0
+/* Count (bytes) */
+#define       MC_CMD_XPM_REPAIR_IN_COUNT_OFST 4
+
+/* MC_CMD_XPM_REPAIR_OUT msgresponse */
+#define    MC_CMD_XPM_REPAIR_OUT_LEN 0
+
+
+/***********************************/
+/* MC_CMD_XPM_DECODER_TEST
+ * Test XPM memory address decoders for gross manufacturing defects. Can only
+ * be performed on an unprogrammed part.
+ */
+#define MC_CMD_XPM_DECODER_TEST 0x10a
+
+#define MC_CMD_0x10a_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
+/* MC_CMD_XPM_DECODER_TEST_IN msgrequest */
+#define    MC_CMD_XPM_DECODER_TEST_IN_LEN 0
+
+/* MC_CMD_XPM_DECODER_TEST_OUT msgresponse */
+#define    MC_CMD_XPM_DECODER_TEST_OUT_LEN 0
+
+
+/***********************************/
+/* MC_CMD_XPM_WRITE_TEST
+ * XPM memory write test. Test XPM write logic for gross manufacturing defects
+ * by writing to a dedicated test row. There are 16 locations in the test row
+ * and the test can only be performed on locations that have not been
+ * previously used (i.e. can be run at most 16 times). The test will pick the
+ * first available location to use, or fail with ENOSPC if none left.
+ */
+#define MC_CMD_XPM_WRITE_TEST 0x10b
+
+#define MC_CMD_0x10b_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
+/* MC_CMD_XPM_WRITE_TEST_IN msgrequest */
+#define    MC_CMD_XPM_WRITE_TEST_IN_LEN 0
+
+/* MC_CMD_XPM_WRITE_TEST_OUT msgresponse */
+#define    MC_CMD_XPM_WRITE_TEST_OUT_LEN 0
+
+
 #endif /* MCDI_PCOL_H */
