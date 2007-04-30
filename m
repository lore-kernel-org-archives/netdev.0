From: Frank Pavlic <fpavlic@de.ibm.com>
Subject: [PATCH 5/5] s390: qeth driver hardware specs adaptions
Date: Mon, 30 Apr 2007 17:43:37 +0200
Message-ID: <20070430154337.GE23666@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:57782 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423401AbXD3Pmp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2007 11:42:45 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Peter Tiedemann <ptiedem@de.ibm.com>

s390: qeth driver hardware specs adaptions
    - according to the latest OSA hardware specification
      incorporate actual IPA command and return codes into qeth.
    - whitespaces removed from qeth_mpc.h

Signed-off-by: Peter Tiedemann <ptiedem@de.ibm.com>
Signed-off-by: Frank Pavlic <fpavlic@de.ibm.com>
---
 qeth_main.c |   26 +++++--
 qeth_mpc.c  |  101 +++++++++++++++++++++++++++
 qeth_mpc.h  |  219 ++++++++++++++++++++++++++++++++++--------------------------
 3 files changed, 247 insertions(+), 99 deletions(-)

diff --git a/drivers/s390/net/qeth_main.c b/drivers/s390/net/qeth_main.c
index 0d10ee0..6be98b1 100644
--- a/drivers/s390/net/qeth_main.c
+++ b/drivers/s390/net/qeth_main.c
@@ -1615,6 +1615,21 @@ qeth_put_reply(struct qeth_reply *reply)
 		kfree(reply);
 }
 
+static void
+qeth_issue_ipa_msg(struct qeth_ipa_cmd *cmd, struct qeth_card *card)
+{
+	int rc;
+	int com;
+	char * ipa_name;
+
+	com = cmd->hdr.command;
+	rc  = cmd->hdr.return_code;
+	ipa_name = qeth_get_ipa_cmd_name(com);
+
+	PRINT_ERR("%s(x%X) for %s returned x%X \"%s\"\n", ipa_name, com,
+		   QETH_CARD_IFNAME(card), rc, qeth_get_ipa_msg(rc));
+}
+
 static struct qeth_ipa_cmd *
 qeth_check_ipa_data(struct qeth_card *card, struct qeth_cmd_buffer *iob)
 {
@@ -1623,8 +1638,11 @@ qeth_check_ipa_data(struct qeth_card *card, struct qeth_cmd_buffer *iob)
 	QETH_DBF_TEXT(trace,5,"chkipad");
 	if (IS_IPA(iob->data)){
 		cmd = (struct qeth_ipa_cmd *) PDU_ENCAPSULATION(iob->data);
-		if (IS_IPA_REPLY(cmd))
+		if (IS_IPA_REPLY(cmd)) {
+			if (cmd->hdr.return_code)
+				qeth_issue_ipa_msg(cmd, card);
 			return cmd;
+		}
 		else {
 			switch (cmd->hdr.command) {
 			case IPA_CMD_STOPLAN:
@@ -5883,9 +5901,6 @@ qeth_layer2_send_setmac_cb(struct qeth_card *card,
 	cmd = (struct qeth_ipa_cmd *) data;
 	if (cmd->hdr.return_code) {
 		QETH_DBF_TEXT_(trace, 2, "L2er%x", cmd->hdr.return_code);
-		PRINT_WARN("Error in registering MAC address on " \
-			   "device %s: x%x\n", CARD_BUS_ID(card),
-			   cmd->hdr.return_code);
 		card->info.mac_bits &= ~QETH_LAYER2_MAC_REGISTERED;
 		cmd->hdr.return_code = -EIO;
 	} else {
@@ -5920,9 +5935,6 @@ qeth_layer2_send_delmac_cb(struct qeth_card *card,
 	QETH_DBF_TEXT(trace, 2, "L2Dmaccb");
 	cmd = (struct qeth_ipa_cmd *) data;
 	if (cmd->hdr.return_code) {
-		PRINT_WARN("Error in deregistering MAC address on " \
-			   "device %s: x%x\n", CARD_BUS_ID(card),
-			   cmd->hdr.return_code);
 		QETH_DBF_TEXT_(trace, 2, "err%d", cmd->hdr.return_code);
 		cmd->hdr.return_code = -EIO;
 		return 0;
diff --git a/drivers/s390/net/qeth_mpc.c b/drivers/s390/net/qeth_mpc.c
index 77c8320..f54fdfd 100644
--- a/drivers/s390/net/qeth_mpc.c
+++ b/drivers/s390/net/qeth_mpc.c
@@ -157,12 +157,113 @@ unsigned char READ_CCW[]={
 };
 
 
+struct ipa_rc_msg {
+	enum qeth_ipa_return_codes rc;
+	char *msg;
+};
 
+struct ipa_rc_msg qeth_ipa_rc_msg[] = {
+	{IPA_RC_SUCCESS,		"success"},
+	{IPA_RC_NOTSUPP,		"Command not supported"},
+	{IPA_RC_IP_TABLE_FULL,		"Add Addr IP Table Full - ipv6"},
+	{IPA_RC_UNKNOWN_ERROR,		"IPA command failed - reason unknown"},
+	{IPA_RC_UNSUPPORTED_COMMAND,	"Command not supported"},
+	{IPA_RC_DUP_IPV6_REMOTE,"ipv6 address already registered remote"},
+	{IPA_RC_DUP_IPV6_HOME,		"ipv6 address already registered"},
+	{IPA_RC_UNREGISTERED_ADDR,	"Address not registered"},
+	{IPA_RC_NO_ID_AVAILABLE,	"No identifiers available"},
+	{IPA_RC_ID_NOT_FOUND,		"Identifier not found"},
+	{IPA_RC_INVALID_IP_VERSION,	"IP version incorrect"},
+	{IPA_RC_LAN_FRAME_MISMATCH,	"LAN and frame mismatch"},
+	{IPA_RC_L2_UNSUPPORTED_CMD,	"Unsupported layer 2 command"},
+	{IPA_RC_L2_DUP_MAC,		"Duplicate MAC address"},
+	{IPA_RC_L2_ADDR_TABLE_FULL,	"Layer2 address table full"},
+	{IPA_RC_L2_DUP_LAYER3_MAC,	"Duplicate with layer 3 MAC"},
+	{IPA_RC_L2_GMAC_NOT_FOUND,	"GMAC not found"},
+	{IPA_RC_L2_MAC_NOT_FOUND,	"L2 mac address not found"},
+	{IPA_RC_L2_INVALID_VLAN_ID,	"L2 invalid vlan id"},
+	{IPA_RC_L2_DUP_VLAN_ID,		"L2 duplicate vlan id"},
+	{IPA_RC_L2_VLAN_ID_NOT_FOUND,	"L2 vlan id not found"},
+	{IPA_RC_DATA_MISMATCH,		"Data field mismatch (v4/v6 mixed)"},
+	{IPA_RC_INVALID_MTU_SIZE,	"Invalid MTU size"},
+	{IPA_RC_INVALID_LANTYPE,	"Invalid LAN type"},
+	{IPA_RC_INVALID_LANNUM,		"Invalid LAN num"},
+	{IPA_RC_DUPLICATE_IP_ADDRESS,	"Address already registered"},
+	{IPA_RC_IP_ADDR_TABLE_FULL,	"IP address table full"},
+	{IPA_RC_LAN_PORT_STATE_ERROR,	"LAN port state error"},
+	{IPA_RC_SETIP_NO_STARTLAN,	"Setip no startlan received"},
+	{IPA_RC_SETIP_ALREADY_RECEIVED,	"Setip already received"},
+	{IPA_RC_IP_ADDR_ALREADY_USED,	"IP address already in use on LAN"},
+	{IPA_RC_MULTICAST_FULL,		"No task available, multicast full"},
+	{IPA_RC_SETIP_INVALID_VERSION,	"SETIP invalid IP version"},
+	{IPA_RC_UNSUPPORTED_SUBCMD,	"Unsupported assist subcommand"},
+	{IPA_RC_ARP_ASSIST_NO_ENABLE,	"Only partial success, no enable"},
+	{IPA_RC_PRIMARY_ALREADY_DEFINED,"Primary already defined"},
+	{IPA_RC_SECOND_ALREADY_DEFINED,	"Secondary already defined"},
+	{IPA_RC_INVALID_SETRTG_INDICATOR,"Invalid SETRTG indicator"},
+	{IPA_RC_MC_ADDR_ALREADY_DEFINED,"Multicast address already defined"},
+	{IPA_RC_LAN_OFFLINE,		"STRTLAN_LAN_DISABLED - LAN offline"},
+	{IPA_RC_INVALID_IP_VERSION2,	"Invalid IP version"},
+	{IPA_RC_FFFF,			"Unknown Error"}
+};
 
 
 
+char *
+qeth_get_ipa_msg(enum qeth_ipa_return_codes rc)
+{
+	int x = 0;
+	qeth_ipa_rc_msg[sizeof(qeth_ipa_rc_msg) /
+			sizeof(struct ipa_rc_msg) - 1].rc = rc;
+	while(qeth_ipa_rc_msg[x].rc != rc)
+		x++;
+	return qeth_ipa_rc_msg[x].msg;
+}
 
 
+struct ipa_cmd_names {
+	enum qeth_ipa_cmds cmd;
+	char *name;
+};
+
+struct ipa_cmd_names qeth_ipa_cmd_names[] = {
+	{IPA_CMD_STARTLAN,	"startlan"},
+	{IPA_CMD_STOPLAN,	"stoplan"},
+	{IPA_CMD_SETVMAC,	"setvmac"},
+	{IPA_CMD_DELVMAC,	"delvmca"},
+	{IPA_CMD_SETGMAC,	"setgmac"},
+	{IPA_CMD_DELGMAC,	"delgmac"},
+	{IPA_CMD_SETVLAN,	"setvlan"},
+	{IPA_CMD_DELVLAN,	"delvlan"},
+	{IPA_CMD_SETCCID,	"setccid"},
+	{IPA_CMD_DELCCID,	"delccid"},
+	{IPA_CMD_MODCCID,	"setip"},
+	{IPA_CMD_SETIP,		"setip"},
+	{IPA_CMD_QIPASSIST,	"qipassist"},
+	{IPA_CMD_SETASSPARMS,	"setassparms"},
+	{IPA_CMD_SETIPM,	"setipm"},
+	{IPA_CMD_DELIPM,	"delipm"},
+	{IPA_CMD_SETRTG,	"setrtg"},
+	{IPA_CMD_DELIP,		"delip"},
+	{IPA_CMD_SETADAPTERPARMS, "setadapterparms"},
+	{IPA_CMD_SET_DIAG_ASS,	"set_diag_ass"},
+	{IPA_CMD_CREATE_ADDR,	"create_addr"},
+	{IPA_CMD_DESTROY_ADDR,	"destroy_addr"},
+	{IPA_CMD_REGISTER_LOCAL_ADDR,	"register_local_addr"},
+	{IPA_CMD_UNREGISTER_LOCAL_ADDR,	"unregister_local_addr"},
+	{IPA_CMD_UNKNOWN,	"unknown"},
+};
 
+char *
+qeth_get_ipa_cmd_name(enum qeth_ipa_cmds cmd)
+{
+	int x = 0;
+	qeth_ipa_cmd_names[
+		sizeof(qeth_ipa_cmd_names)/
+			sizeof(struct ipa_cmd_names)-1].cmd = cmd;
+	while(qeth_ipa_cmd_names[x].cmd != cmd)
+		x++;
+	return qeth_ipa_cmd_names[x].name;
+}
 
 
diff --git a/drivers/s390/net/qeth_mpc.h b/drivers/s390/net/qeth_mpc.h
index 0477c47..de0a113 100644
--- a/drivers/s390/net/qeth_mpc.h
+++ b/drivers/s390/net/qeth_mpc.h
@@ -25,14 +25,14 @@ extern unsigned char IPA_PDU_HEADER[];
 
 #define IPA_CMD_LENGTH	(IPA_PDU_HEADER_SIZE + sizeof(struct qeth_ipa_cmd))
 
-#define QETH_SEQ_NO_LENGTH 	4
-#define QETH_MPC_TOKEN_LENGTH 	4
+#define QETH_SEQ_NO_LENGTH	4
+#define QETH_MPC_TOKEN_LENGTH	4
 #define QETH_MCL_LENGTH		4
 #define OSA_ADDR_LEN		6
 
-#define QETH_TIMEOUT 		(10 * HZ)
-#define QETH_IPA_TIMEOUT 	(45 * HZ)
-#define QETH_IDX_COMMAND_SEQNO 	0xffff0000
+#define QETH_TIMEOUT		(10 * HZ)
+#define QETH_IPA_TIMEOUT	(45 * HZ)
+#define QETH_IDX_COMMAND_SEQNO	0xffff0000
 #define SR_INFO_LEN		16
 
 #define QETH_CLEAR_CHANNEL_PARM	-10
@@ -92,79 +92,107 @@ enum qeth_checksum_types {
  */
 #define RESET_ROUTING_FLAG 0x10 /* indicate that routing type shall be set */
 enum qeth_routing_types {
-	NO_ROUTER           = 0, /* TODO: set to bit flag used in IPA Command */
-	PRIMARY_ROUTER      = 1,
-	SECONDARY_ROUTER    = 2,
-	MULTICAST_ROUTER    = 3,
-	PRIMARY_CONNECTOR   = 4,
-	SECONDARY_CONNECTOR = 5,
+	NO_ROUTER		= 0, /* TODO: set to bit flag used in IPA Command */
+	PRIMARY_ROUTER		= 1,
+	SECONDARY_ROUTER	= 2,
+	MULTICAST_ROUTER	= 3,
+	PRIMARY_CONNECTOR	= 4,
+	SECONDARY_CONNECTOR	= 5,
 };
 
-
 /* IPA Commands */
 enum qeth_ipa_cmds {
-	IPA_CMD_STARTLAN              = 0x01,
-	IPA_CMD_STOPLAN               = 0x02,
-	IPA_CMD_SETVMAC 	      = 0x21,
-	IPA_CMD_DELVMAC 	      =	0x22,
-	IPA_CMD_SETGMAC  	      = 0x23,
-	IPA_CMD_DELGMAC 	      = 0x24,
-	IPA_CMD_SETVLAN 	      = 0x25,
-	IPA_CMD_DELVLAN 	      = 0x26,
-	IPA_CMD_SETCCID               = 0x41,
-	IPA_CMD_DELCCID               = 0x42,
-	IPA_CMD_MODCCID               = 0x43,
-	IPA_CMD_SETIP                 = 0xb1,
-	IPA_CMD_DELIP                 = 0xb7,
-	IPA_CMD_QIPASSIST             = 0xb2,
-	IPA_CMD_SETASSPARMS           = 0xb3,
-	IPA_CMD_SETIPM                = 0xb4,
-	IPA_CMD_DELIPM                = 0xb5,
-	IPA_CMD_SETRTG                = 0xb6,
-	IPA_CMD_SETADAPTERPARMS       = 0xb8,
-	IPA_CMD_IPFRAME               = 0xb9,
-	IPA_CMD_ADD_ADDR_ENTRY        = 0xc1,
-	IPA_CMD_DELETE_ADDR_ENTRY     = 0xc2,
-	IPA_CMD_CREATE_ADDR           = 0xc3,
-	IPA_CMD_DESTROY_ADDR          = 0xc4,
-	IPA_CMD_REGISTER_LOCAL_ADDR   = 0xd1,
-	IPA_CMD_UNREGISTER_LOCAL_ADDR = 0xd2,
+	IPA_CMD_STARTLAN		= 0x01,
+	IPA_CMD_STOPLAN			= 0x02,
+	IPA_CMD_SETVMAC			= 0x21,
+	IPA_CMD_DELVMAC			= 0x22,
+	IPA_CMD_SETGMAC			= 0x23,
+	IPA_CMD_DELGMAC			= 0x24,
+	IPA_CMD_SETVLAN			= 0x25,
+	IPA_CMD_DELVLAN			= 0x26,
+	IPA_CMD_SETCCID			= 0x41,
+	IPA_CMD_DELCCID			= 0x42,
+	IPA_CMD_MODCCID			= 0x43,
+	IPA_CMD_SETIP			= 0xb1,
+	IPA_CMD_QIPASSIST		= 0xb2,
+	IPA_CMD_SETASSPARMS		= 0xb3,
+	IPA_CMD_SETIPM			= 0xb4,
+	IPA_CMD_DELIPM			= 0xb5,
+	IPA_CMD_SETRTG			= 0xb6,
+	IPA_CMD_DELIP			= 0xb7,
+	IPA_CMD_SETADAPTERPARMS		= 0xb8,
+	IPA_CMD_SET_DIAG_ASS		= 0xb9,
+	IPA_CMD_CREATE_ADDR		= 0xc3,
+	IPA_CMD_DESTROY_ADDR		= 0xc4,
+	IPA_CMD_REGISTER_LOCAL_ADDR	= 0xd1,
+	IPA_CMD_UNREGISTER_LOCAL_ADDR	= 0xd2,
+	IPA_CMD_UNKNOWN			= 0x00
 };
 
 enum qeth_ip_ass_cmds {
 	IPA_CMD_ASS_START	= 0x0001,
 	IPA_CMD_ASS_STOP	= 0x0002,
-	IPA_CMD_ASS_CONFIGURE 	= 0x0003,
-	IPA_CMD_ASS_ENABLE 	= 0x0004,
+	IPA_CMD_ASS_CONFIGURE	= 0x0003,
+	IPA_CMD_ASS_ENABLE	= 0x0004,
 };
 
 enum qeth_arp_process_subcmds {
-	IPA_CMD_ASS_ARP_SET_NO_ENTRIES 	= 0x0003,
-	IPA_CMD_ASS_ARP_QUERY_CACHE 	= 0x0004,
-	IPA_CMD_ASS_ARP_ADD_ENTRY 	= 0x0005,
-	IPA_CMD_ASS_ARP_REMOVE_ENTRY 	= 0x0006,
-	IPA_CMD_ASS_ARP_FLUSH_CACHE 	= 0x0007,
-	IPA_CMD_ASS_ARP_QUERY_INFO 	= 0x0104,
-	IPA_CMD_ASS_ARP_QUERY_STATS 	= 0x0204,
+	IPA_CMD_ASS_ARP_SET_NO_ENTRIES	= 0x0003,
+	IPA_CMD_ASS_ARP_QUERY_CACHE	= 0x0004,
+	IPA_CMD_ASS_ARP_ADD_ENTRY	= 0x0005,
+	IPA_CMD_ASS_ARP_REMOVE_ENTRY	= 0x0006,
+	IPA_CMD_ASS_ARP_FLUSH_CACHE	= 0x0007,
+	IPA_CMD_ASS_ARP_QUERY_INFO	= 0x0104,
+	IPA_CMD_ASS_ARP_QUERY_STATS	= 0x0204,
 };
 
-/* Return Codes for IPA Commands */
+
+/* Return Codes for IPA Commands
+ * according to OSA card Specs */
+
 enum qeth_ipa_return_codes {
-	IPA_RC_SUCCESS             = 0x0000,
-	IPA_RC_NOTSUPP             = 0x0001,
-	IPA_RC_NO_ACCESS           = 0x0002,
-	IPA_RC_FAILED              = 0x0003,
-	IPA_RC_DATA_MISMATCH       = 0xe001,
-	IPA_RC_INVALID_LAN_TYPE    = 0xe003,
-	IPA_RC_INVALID_LAN_NO      = 0xe004,
-	IPA_RC_IPADDR_ALREADY_REG  = 0xe005,
-	IPA_RC_IPADDR_TABLE_FULL   = 0xe006,
-	IPA_RC_IPADDR_ALREADY_USED = 0xe00a,
-	IPA_RC_ASSNO_NOT_SUPP      = 0xe00d,
-	IPA_RC_ASSCMD_START_FAILED = 0xe00e,
-	IPA_RC_ASSCMD_PART_SUCCESS = 0xe00f,
-	IPA_RC_IPADDR_NOT_DEFINED  = 0xe010,
-	IPA_RC_LAN_OFFLINE         = 0xe080,
+	IPA_RC_SUCCESS			= 0x0000,
+	IPA_RC_NOTSUPP			= 0x0001,
+	IPA_RC_IP_TABLE_FULL		= 0x0002,
+	IPA_RC_UNKNOWN_ERROR		= 0x0003,
+	IPA_RC_UNSUPPORTED_COMMAND	= 0x0004,
+	IPA_RC_DUP_IPV6_REMOTE		= 0x0008,
+	IPA_RC_DUP_IPV6_HOME		= 0x0010,
+	IPA_RC_UNREGISTERED_ADDR	= 0x0011,
+	IPA_RC_NO_ID_AVAILABLE		= 0x0012,
+	IPA_RC_ID_NOT_FOUND		= 0x0013,
+	IPA_RC_INVALID_IP_VERSION	= 0x0020,
+	IPA_RC_LAN_FRAME_MISMATCH	= 0x0040,
+	IPA_RC_L2_UNSUPPORTED_CMD	= 0x2003,
+	IPA_RC_L2_DUP_MAC		= 0x2005,
+	IPA_RC_L2_ADDR_TABLE_FULL	= 0x2006,
+	IPA_RC_L2_DUP_LAYER3_MAC	= 0x200a,
+	IPA_RC_L2_GMAC_NOT_FOUND	= 0x200b,
+	IPA_RC_L2_MAC_NOT_FOUND		= 0x2010,
+	IPA_RC_L2_INVALID_VLAN_ID	= 0x2015,
+	IPA_RC_L2_DUP_VLAN_ID		= 0x2016,
+	IPA_RC_L2_VLAN_ID_NOT_FOUND	= 0x2017,
+	IPA_RC_DATA_MISMATCH		= 0xe001,
+	IPA_RC_INVALID_MTU_SIZE		= 0xe002,
+	IPA_RC_INVALID_LANTYPE		= 0xe003,
+	IPA_RC_INVALID_LANNUM		= 0xe004,
+	IPA_RC_DUPLICATE_IP_ADDRESS	= 0xe005,
+	IPA_RC_IP_ADDR_TABLE_FULL	= 0xe006,
+	IPA_RC_LAN_PORT_STATE_ERROR	= 0xe007,
+	IPA_RC_SETIP_NO_STARTLAN	= 0xe008,
+	IPA_RC_SETIP_ALREADY_RECEIVED	= 0xe009,
+	IPA_RC_IP_ADDR_ALREADY_USED	= 0xe00a,
+	IPA_RC_MULTICAST_FULL		= 0xe00b,
+	IPA_RC_SETIP_INVALID_VERSION	= 0xe00d,
+	IPA_RC_UNSUPPORTED_SUBCMD	= 0xe00e,
+	IPA_RC_ARP_ASSIST_NO_ENABLE	= 0xe00f,
+	IPA_RC_PRIMARY_ALREADY_DEFINED	= 0xe010,
+	IPA_RC_SECOND_ALREADY_DEFINED	= 0xe011,
+	IPA_RC_INVALID_SETRTG_INDICATOR	= 0xe012,
+	IPA_RC_MC_ADDR_ALREADY_DEFINED	= 0xe013,
+	IPA_RC_LAN_OFFLINE		= 0xe080,
+	IPA_RC_INVALID_IP_VERSION2	= 0xf001,
+	IPA_RC_FFFF			= 0xffff
 };
 
 /* IPA function flags; each flag marks availability of respective function */
@@ -182,7 +210,9 @@ enum qeth_ipa_funcs {
 	IPA_SETADAPTERPARMS     = 0x00000400L,
 	IPA_VLAN_PRIO           = 0x00000800L,
 	IPA_PASSTHRU            = 0x00001000L,
+	IPA_FLUSH_ARP_SUPPORT   = 0x00002000L,
 	IPA_FULL_VLAN           = 0x00004000L,
+	IPA_INBOUND_PASSTHRU    = 0x00008000L,
 	IPA_SOURCE_MAC          = 0x00010000L,
 	IPA_OSA_MC_ROUTER       = 0x00020000L,
 	IPA_QUERY_ARP_ASSIST	= 0x00040000L,
@@ -203,31 +233,30 @@ enum qeth_ipa_setdelip_flags {
 /* SETADAPTER IPA Command: ****************************************************/
 enum qeth_ipa_setadp_cmd {
 	IPA_SETADP_QUERY_COMMANDS_SUPPORTED	= 0x01,
-	IPA_SETADP_ALTER_MAC_ADDRESS 		= 0x02,
-	IPA_SETADP_ADD_DELETE_GROUP_ADDRESS 	= 0x04,
-	IPA_SETADP_ADD_DELETE_FUNCTIONAL_ADDR 	= 0x08,
-	IPA_SETADP_SET_ADDRESSING_MODE 		= 0x10,
-	IPA_SETADP_SET_CONFIG_PARMS 		= 0x20,
-	IPA_SETADP_SET_CONFIG_PARMS_EXTENDED 	= 0x40,
-	IPA_SETADP_SET_BROADCAST_MODE 		= 0x80,
-	IPA_SETADP_SEND_OSA_MESSAGE 		= 0x0100,
-	IPA_SETADP_SET_SNMP_CONTROL 		= 0x0200,
-	IPA_SETADP_READ_SNMP_PARMS 		= 0x0400,
+	IPA_SETADP_ALTER_MAC_ADDRESS		= 0x02,
+	IPA_SETADP_ADD_DELETE_GROUP_ADDRESS	= 0x04,
+	IPA_SETADP_ADD_DELETE_FUNCTIONAL_ADDR	= 0x08,
+	IPA_SETADP_SET_ADDRESSING_MODE		= 0x10,
+	IPA_SETADP_SET_CONFIG_PARMS		= 0x20,
+	IPA_SETADP_SET_CONFIG_PARMS_EXTENDED	= 0x40,
+	IPA_SETADP_SET_BROADCAST_MODE		= 0x80,
+	IPA_SETADP_SEND_OSA_MESSAGE		= 0x0100,
+	IPA_SETADP_SET_SNMP_CONTROL		= 0x0200,
+	IPA_SETADP_QUERY_CARD_INFO		= 0x0400,
 	IPA_SETADP_SET_PROMISC_MODE		= 0x0800,
-	IPA_SETADP_QUERY_CARD_INFO 		= 0x1000,
 };
 enum qeth_ipa_mac_ops {
-	CHANGE_ADDR_READ_MAC 		= 0,
-	CHANGE_ADDR_REPLACE_MAC 	= 1,
-	CHANGE_ADDR_ADD_MAC 		= 2,
-	CHANGE_ADDR_DEL_MAC 		= 4,
-	CHANGE_ADDR_RESET_MAC 		= 8,
+	CHANGE_ADDR_READ_MAC		= 0,
+	CHANGE_ADDR_REPLACE_MAC		= 1,
+	CHANGE_ADDR_ADD_MAC		= 2,
+	CHANGE_ADDR_DEL_MAC		= 4,
+	CHANGE_ADDR_RESET_MAC		= 8,
 };
 enum qeth_ipa_addr_ops {
-	CHANGE_ADDR_READ_ADDR 		= 0,
-	CHANGE_ADDR_ADD_ADDR 		= 1,
-	CHANGE_ADDR_DEL_ADDR 		= 2,
-	CHANGE_ADDR_FLUSH_ADDR_TABLE 	= 4,
+	CHANGE_ADDR_READ_ADDR		= 0,
+	CHANGE_ADDR_ADD_ADDR		= 1,
+	CHANGE_ADDR_DEL_ADDR		= 2,
+	CHANGE_ADDR_FLUSH_ADDR_TABLE	= 4,
 };
 enum qeth_ipa_promisc_modes {
 	SET_PROMISC_MODE_OFF		= 0,
@@ -406,15 +435,15 @@ struct qeth_ipacmd_hdr {
 struct qeth_ipa_cmd {
 	struct qeth_ipacmd_hdr hdr;
 	union {
-		struct qeth_ipacmd_setdelip4   		setdelip4;
-		struct qeth_ipacmd_setdelip6   		setdelip6;
+		struct qeth_ipacmd_setdelip4		setdelip4;
+		struct qeth_ipacmd_setdelip6		setdelip6;
 		struct qeth_ipacmd_setdelipm		setdelipm;
-		struct qeth_ipacmd_setassparms 		setassparms;
-		struct qeth_ipacmd_layer2setdelmac  	setdelmac;
-		struct qeth_ipacmd_layer2setdelvlan 	setdelvlan;
-		struct qeth_create_destroy_address 	create_destroy_addr;
-		struct qeth_ipacmd_setadpparms 		setadapterparms;
-		struct qeth_set_routing 		setrtg;
+		struct qeth_ipacmd_setassparms		setassparms;
+		struct qeth_ipacmd_layer2setdelmac	setdelmac;
+		struct qeth_ipacmd_layer2setdelvlan	setdelvlan;
+		struct qeth_create_destroy_address	create_destroy_addr;
+		struct qeth_ipacmd_setadpparms		setadapterparms;
+		struct qeth_set_routing			setrtg;
 	} data;
 } __attribute__ ((packed));
 
@@ -432,6 +461,12 @@ enum qeth_ipa_arp_return_codes {
 	QETH_IPA_ARP_RC_Q_NO_DATA    = 0x0008,
 };
 
+
+extern char *
+qeth_get_ipa_msg(enum qeth_ipa_return_codes rc);
+extern char *
+qeth_get_ipa_cmd_name(enum qeth_ipa_cmds cmd);
+
 #define QETH_SETASS_BASE_LEN (sizeof(struct qeth_ipacmd_hdr) + \
 			       sizeof(struct qeth_ipacmd_setassparms_hdr))
 #define QETH_IPA_ARP_DATA_POS(buffer) (buffer + IPA_PDU_HEADER_SIZE + \
@@ -520,7 +555,7 @@ extern unsigned char DM_ACT[];
 extern unsigned char IDX_ACTIVATE_READ[];
 extern unsigned char IDX_ACTIVATE_WRITE[];
 
-#define IDX_ACTIVATE_SIZE 	0x22
+#define IDX_ACTIVATE_SIZE	0x22
 #define QETH_IDX_ACT_ISSUER_RM_TOKEN(buffer) (buffer+0x0c)
 #define QETH_IDX_NO_PORTNAME_REQUIRED(buffer) ((buffer)[0x0b]&0x80)
 #define QETH_IDX_ACT_FUNC_LEVEL(buffer) (buffer+0x10)
-- 
1.5.1.2

