From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 5/8] qeth: OSA version of SETBRIDGEPORT command
Date: Mon, 18 May 2015 14:27:56 +0200
Message-ID: <1431952079-6847-6-git-send-email-ubraun@linux.vnet.ibm.com>
References: <1431952079-6847-1-git-send-email-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	ursula.braun@de.ibm.com, ubraun@linux.vnet.ibm.com,
	Eugene Crosser <Eugene.Crosser@ru.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp12.uk.ibm.com ([195.75.94.108]:39832 "EHLO
	e06smtp12.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754167AbbERM2c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 08:28:32 -0400
Received: from /spool/local
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Mon, 18 May 2015 13:28:30 +0100
In-Reply-To: <1431952079-6847-1-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugene Crosser <Eugene.Crosser@ru.ibm.com>

OSA Ethernet hardware is introducing BRIDGEPORT functionality
similar (but not identical) to HiperSockets BRIDGEPORT. This
patch makes HiperSockets BRIDGEPORT related sysfs attributes
and udev events work with OSA hardware too.

Reviewed-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
Signed-off-by: Eugene Crosser <Eugene.Crosser@ru.ibm.com>
Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
---
 Documentation/s390/qeth.txt       |  4 +--
 drivers/s390/net/qeth_core_main.c |  3 +-
 drivers/s390/net/qeth_core_mpc.c  |  3 +-
 drivers/s390/net/qeth_core_mpc.h  |  3 +-
 drivers/s390/net/qeth_l2_main.c   | 68 +++++++++++++++++++++++++--------------
 5 files changed, 51 insertions(+), 30 deletions(-)

diff --git a/Documentation/s390/qeth.txt b/Documentation/s390/qeth.txt
index 74122ad..aa06fcf 100644
--- a/Documentation/s390/qeth.txt
+++ b/Documentation/s390/qeth.txt
@@ -1,6 +1,6 @@
 IBM s390 QDIO Ethernet Driver
 
-HiperSockets Bridge Port Support
+OSA and HiperSockets Bridge Port Support
 
 Uevents
 
@@ -8,7 +8,7 @@ To generate the events the device must be assigned a role of either
 a primary or a secondary Bridge Port. For more information, see
 "z/VM Connectivity, SC24-6174".
 
-When run on HiperSockets Bridge Capable Port hardware, and the state
+When run on an OSA or HiperSockets Bridge Capable Port hardware, and the state
 of some configured Bridge Port device on the channel changes, a udev
 event with ACTION=CHANGE is emitted on behalf of the corresponding
 ccwgroup device. The event has the following attributes:
diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index 3466d3c..5e20fba 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -645,7 +645,8 @@ static struct qeth_ipa_cmd *qeth_check_ipa_data(struct qeth_card *card,
 					card->info.hwtrap = 2;
 				qeth_schedule_recovery(card);
 				return NULL;
-			case IPA_CMD_SETBRIDGEPORT:
+			case IPA_CMD_SETBRIDGEPORT_IQD:
+			case IPA_CMD_SETBRIDGEPORT_OSA:
 			case IPA_CMD_ADDRESS_CHANGE_NOTIF:
 				if (card->discipline->control_event_handler
 								(card, cmd))
diff --git a/drivers/s390/net/qeth_core_mpc.c b/drivers/s390/net/qeth_core_mpc.c
index 7b55768..beb4bdc 100644
--- a/drivers/s390/net/qeth_core_mpc.c
+++ b/drivers/s390/net/qeth_core_mpc.c
@@ -237,6 +237,7 @@ static struct ipa_cmd_names qeth_ipa_cmd_names[] = {
 	{IPA_CMD_DELGMAC,	"delgmac"},
 	{IPA_CMD_SETVLAN,	"setvlan"},
 	{IPA_CMD_DELVLAN,	"delvlan"},
+	{IPA_CMD_SETBRIDGEPORT_OSA,	"set_bridge_port(osa)"},
 	{IPA_CMD_SETCCID,	"setccid"},
 	{IPA_CMD_DELCCID,	"delccid"},
 	{IPA_CMD_MODCCID,	"modccid"},
@@ -249,7 +250,7 @@ static struct ipa_cmd_names qeth_ipa_cmd_names[] = {
 	{IPA_CMD_DELIP,		"delip"},
 	{IPA_CMD_SETADAPTERPARMS, "setadapterparms"},
 	{IPA_CMD_SET_DIAG_ASS,	"set_diag_ass"},
-	{IPA_CMD_SETBRIDGEPORT,	"set_bridge_port"},
+	{IPA_CMD_SETBRIDGEPORT_IQD,	"set_bridge_port(hs)"},
 	{IPA_CMD_CREATE_ADDR,	"create_addr"},
 	{IPA_CMD_DESTROY_ADDR,	"destroy_addr"},
 	{IPA_CMD_REGISTER_LOCAL_ADDR,	"register_local_addr"},
diff --git a/drivers/s390/net/qeth_core_mpc.h b/drivers/s390/net/qeth_core_mpc.h
index 1558be1..6cccc9a 100644
--- a/drivers/s390/net/qeth_core_mpc.h
+++ b/drivers/s390/net/qeth_core_mpc.h
@@ -92,6 +92,7 @@ enum qeth_ipa_cmds {
 	IPA_CMD_DELGMAC			= 0x24,
 	IPA_CMD_SETVLAN			= 0x25,
 	IPA_CMD_DELVLAN			= 0x26,
+	IPA_CMD_SETBRIDGEPORT_OSA	= 0x2b,
 	IPA_CMD_SETCCID			= 0x41,
 	IPA_CMD_DELCCID			= 0x42,
 	IPA_CMD_MODCCID			= 0x43,
@@ -104,7 +105,7 @@ enum qeth_ipa_cmds {
 	IPA_CMD_DELIP			= 0xb7,
 	IPA_CMD_SETADAPTERPARMS		= 0xb8,
 	IPA_CMD_SET_DIAG_ASS		= 0xb9,
-	IPA_CMD_SETBRIDGEPORT		= 0xbe,
+	IPA_CMD_SETBRIDGEPORT_IQD	= 0xbe,
 	IPA_CMD_CREATE_ADDR		= 0xc3,
 	IPA_CMD_DESTROY_ADDR		= 0xc4,
 	IPA_CMD_REGISTER_LOCAL_ADDR	= 0xd1,
diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index 0ff926d..789377c 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -1028,7 +1028,7 @@ static int __qeth_l2_set_online(struct ccwgroup_device *gdev, int recovery_mode)
 	qeth_bridgeport_query_support(card);
 	if (card->options.sbp.supported_funcs)
 		dev_info(&card->gdev->dev,
-		"The device represents a HiperSockets Bridge Capable Port\n");
+		"The device represents a Bridge Capable Port\n");
 	qeth_trace_features(card);
 
 	if (!card->dev && qeth_l2_setup_netdev(card)) {
@@ -1281,7 +1281,8 @@ static int qeth_l2_control_event(struct qeth_card *card,
 					struct qeth_ipa_cmd *cmd)
 {
 	switch (cmd->hdr.command) {
-	case IPA_CMD_SETBRIDGEPORT:
+	case IPA_CMD_SETBRIDGEPORT_OSA:
+	case IPA_CMD_SETBRIDGEPORT_IQD:
 		if (cmd->data.sbp.hdr.command_code ==
 				IPA_SBP_BRIDGE_PORT_STATE_CHANGE) {
 			qeth_bridge_state_change(card, cmd);
@@ -1567,7 +1568,7 @@ static void qeth_bridge_host_event_worker(struct work_struct *work)
 
 	if (data->hostevs.lost_event_mask) {
 		dev_info(&data->card->gdev->dev,
-"Address notification from the HiperSockets Bridge Port stopped %s (%s)\n",
+"Address notification from the Bridge Port stopped %s (%s)\n",
 			data->card->dev->name,
 			(data->hostevs.lost_event_mask == 0x01)
 			? "Overflow"
@@ -1651,70 +1652,80 @@ static int qeth_bridgeport_makerc(struct qeth_card *card,
 	struct _qeth_sbp_cbctl *cbctl, enum qeth_ipa_sbp_cmd setcmd)
 {
 	int rc;
+	int is_iqd = (card->info.type == QETH_CARD_TYPE_IQD);
 
-	switch (cbctl->ipa_rc) {
-	case IPA_RC_SUCCESS:
+	if ((is_iqd && (cbctl->ipa_rc == IPA_RC_SUCCESS)) ||
+	    (!is_iqd && (cbctl->ipa_rc == cbctl->cmd_rc)))
 		switch (cbctl->cmd_rc) {
 		case 0x0000:
 			rc = 0;
 			break;
+		case 0x2B04:
 		case 0x0004:
 			rc = -ENOSYS;
 			break;
+		case 0x2B0C:
 		case 0x000C: /* Not configured as bridge Port */
 			rc = -ENODEV; /* maybe not the best code here? */
 			dev_err(&card->gdev->dev,
-	"The HiperSockets device is not configured as a Bridge Port\n");
+	"The device is not configured as a Bridge Port\n");
 			break;
+		case 0x2B14:
 		case 0x0014: /* Another device is Primary */
 			switch (setcmd) {
 			case IPA_SBP_SET_PRIMARY_BRIDGE_PORT:
 				rc = -EEXIST;
 				dev_err(&card->gdev->dev,
-	"The HiperSockets LAN already has a primary Bridge Port\n");
+	"The LAN already has a primary Bridge Port\n");
 				break;
 			case IPA_SBP_SET_SECONDARY_BRIDGE_PORT:
 				rc = -EBUSY;
 				dev_err(&card->gdev->dev,
-	"The HiperSockets device is already a primary Bridge Port\n");
+	"The device is already a primary Bridge Port\n");
 				break;
 			default:
 				rc = -EIO;
 			}
 			break;
+		case 0x2B18:
 		case 0x0018: /* This device is currently Secondary */
 			rc = -EBUSY;
 			dev_err(&card->gdev->dev,
-	"The HiperSockets device is already a secondary Bridge Port\n");
+	"The device is already a secondary Bridge Port\n");
 			break;
+		case 0x2B1C:
 		case 0x001C: /* Limit for Secondary devices reached */
 			rc = -EEXIST;
 			dev_err(&card->gdev->dev,
-	"The HiperSockets LAN cannot have more secondary Bridge Ports\n");
+	"The LAN cannot have more secondary Bridge Ports\n");
 			break;
+		case 0x2B24:
 		case 0x0024: /* This device is currently Primary */
 			rc = -EBUSY;
 			dev_err(&card->gdev->dev,
-	"The HiperSockets device is already a primary Bridge Port\n");
+	"The device is already a primary Bridge Port\n");
 			break;
+		case 0x2B20:
 		case 0x0020: /* Not authorized by zManager */
 			rc = -EACCES;
 			dev_err(&card->gdev->dev,
-	"The HiperSockets device is not authorized to be a Bridge Port\n");
+	"The device is not authorized to be a Bridge Port\n");
 			break;
 		default:
 			rc = -EIO;
 		}
-		break;
-	case IPA_RC_NOTSUPP:
-		rc = -ENOSYS;
-		break;
-	case IPA_RC_UNSUPPORTED_COMMAND:
-		rc = -ENOSYS;
-		break;
-	default:
-		rc = -EIO;
-	}
+	else
+		switch (cbctl->ipa_rc) {
+		case IPA_RC_NOTSUPP:
+			rc = -ENOSYS;
+			break;
+		case IPA_RC_UNSUPPORTED_COMMAND:
+			rc = -ENOSYS;
+			break;
+		default:
+			rc = -EIO;
+		}
+
 	if (rc) {
 		QETH_CARD_TEXT_(card, 2, "SBPi%04x", cbctl->ipa_rc);
 		QETH_CARD_TEXT_(card, 2, "SBPc%04x", cbctl->cmd_rc);
@@ -1722,6 +1733,13 @@ static int qeth_bridgeport_makerc(struct qeth_card *card,
 	return rc;
 }
 
+static inline int ipa_cmd_sbp(struct qeth_card *card)
+{
+	return (card->info.type == QETH_CARD_TYPE_IQD) ?
+		IPA_CMD_SETBRIDGEPORT_IQD :
+		IPA_CMD_SETBRIDGEPORT_OSA;
+}
+
 static int qeth_bridgeport_query_support_cb(struct qeth_card *card,
 	struct qeth_reply *reply, unsigned long data)
 {
@@ -1753,7 +1771,7 @@ static void qeth_bridgeport_query_support(struct qeth_card *card)
 	struct _qeth_sbp_cbctl cbctl;
 
 	QETH_CARD_TEXT(card, 2, "brqsuppo");
-	iob = qeth_get_ipacmd_buffer(card, IPA_CMD_SETBRIDGEPORT, 0);
+	iob = qeth_get_ipacmd_buffer(card, ipa_cmd_sbp(card), 0);
 	if (!iob)
 		return;
 	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
@@ -1830,7 +1848,7 @@ int qeth_bridgeport_query_ports(struct qeth_card *card,
 	QETH_CARD_TEXT(card, 2, "brqports");
 	if (!(card->options.sbp.supported_funcs & IPA_SBP_QUERY_BRIDGE_PORTS))
 		return -EOPNOTSUPP;
-	iob = qeth_get_ipacmd_buffer(card, IPA_CMD_SETBRIDGEPORT, 0);
+	iob = qeth_get_ipacmd_buffer(card, ipa_cmd_sbp(card), 0);
 	if (!iob)
 		return -ENOMEM;
 	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
@@ -1897,7 +1915,7 @@ int qeth_bridgeport_setrole(struct qeth_card *card, enum qeth_sbp_roles role)
 	}
 	if (!(card->options.sbp.supported_funcs & setcmd))
 		return -EOPNOTSUPP;
-	iob = qeth_get_ipacmd_buffer(card, IPA_CMD_SETBRIDGEPORT, 0);
+	iob = qeth_get_ipacmd_buffer(card, ipa_cmd_sbp(card), 0);
 	if (!iob)
 		return -ENOMEM;
 	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
-- 
2.3.7
