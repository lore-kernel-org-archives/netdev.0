From: frank.blaschka@de.ibm.com
Subject: [patch 3/5] [PATCH] qeth: support z/VM VSWITCH Port Isolation
Date: Wed, 20 May 2009 09:38:39 +0200
Message-ID: <20090520073927.953030000@de.ibm.com>
References: <20090520073836.897878000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.de.ibm.com ([195.212.29.157]:64313 "EHLO
	mtagate8.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754563AbZETHj2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2009 03:39:28 -0400
Content-Disposition: inline; filename=614-qeth-port-isolation.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

z/VM Virtual Switch Port Isolation allows guests on a VLAN UNAWARE
virtual switch to be isolated from other guests on the VSWITCH.
(See z/VM Apars VM64281 and VM64463).
The Linux qeth driver is affected, because it has to handle new
error codes introduced with the z/VM VSWITCH Port Isolation support.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_core_mpc.c |    2 ++
 drivers/s390/net/qeth_core_mpc.h |    2 ++
 drivers/s390/net/qeth_l2_main.c  |   26 +++++++++++++++++++++++++-
 3 files changed, 29 insertions(+), 1 deletion(-)

diff -urpN linux-2.6/drivers/s390/net/qeth_core_mpc.c linux-2.6-patched/drivers/s390/net/qeth_core_mpc.c
--- linux-2.6/drivers/s390/net/qeth_core_mpc.c	2009-03-24 00:12:14.000000000 +0100
+++ linux-2.6-patched/drivers/s390/net/qeth_core_mpc.c	2009-05-20 08:56:42.000000000 +0200
@@ -181,6 +181,8 @@ static struct ipa_rc_msg qeth_ipa_rc_msg
 	{IPA_RC_L2_ADDR_TABLE_FULL,	"Layer2 address table full"},
 	{IPA_RC_L2_DUP_LAYER3_MAC,	"Duplicate with layer 3 MAC"},
 	{IPA_RC_L2_GMAC_NOT_FOUND,	"GMAC not found"},
+	{IPA_RC_L2_MAC_NOT_AUTH_BY_HYP,	"L2 mac not authorized by hypervisor"},
+	{IPA_RC_L2_MAC_NOT_AUTH_BY_ADP,	"L2 mac not authorized by adapter"},
 	{IPA_RC_L2_MAC_NOT_FOUND,	"L2 mac address not found"},
 	{IPA_RC_L2_INVALID_VLAN_ID,	"L2 invalid vlan id"},
 	{IPA_RC_L2_DUP_VLAN_ID,		"L2 duplicate vlan id"},
diff -urpN linux-2.6/drivers/s390/net/qeth_core_mpc.h linux-2.6-patched/drivers/s390/net/qeth_core_mpc.h
--- linux-2.6/drivers/s390/net/qeth_core_mpc.h	2009-03-24 00:12:14.000000000 +0100
+++ linux-2.6-patched/drivers/s390/net/qeth_core_mpc.h	2009-05-20 08:56:42.000000000 +0200
@@ -168,6 +168,8 @@ enum qeth_ipa_return_codes {
 	IPA_RC_L2_ADDR_TABLE_FULL	= 0x2006,
 	IPA_RC_L2_DUP_LAYER3_MAC	= 0x200a,
 	IPA_RC_L2_GMAC_NOT_FOUND	= 0x200b,
+	IPA_RC_L2_MAC_NOT_AUTH_BY_HYP	= 0x200c,
+	IPA_RC_L2_MAC_NOT_AUTH_BY_ADP	= 0x200d,
 	IPA_RC_L2_MAC_NOT_FOUND		= 0x2010,
 	IPA_RC_L2_INVALID_VLAN_ID	= 0x2015,
 	IPA_RC_L2_DUP_VLAN_ID		= 0x2016,
diff -urpN linux-2.6/drivers/s390/net/qeth_l2_main.c linux-2.6-patched/drivers/s390/net/qeth_l2_main.c
--- linux-2.6/drivers/s390/net/qeth_l2_main.c	2009-05-20 08:56:42.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_l2_main.c	2009-05-20 08:56:42.000000000 +0200
@@ -130,7 +130,7 @@ static int qeth_l2_send_setgroupmac_cb(s
 	cmd = (struct qeth_ipa_cmd *) data;
 	mac = &cmd->data.setdelmac.mac[0];
 	/* MAC already registered, needed in couple/uncouple case */
-	if (cmd->hdr.return_code == 0x2005) {
+	if (cmd->hdr.return_code ==  IPA_RC_L2_DUP_MAC) {
 		QETH_DBF_MESSAGE(2, "Group MAC %pM already existing on %s \n",
 			  mac, QETH_CARD_IFNAME(card));
 		cmd->hdr.return_code = 0;
@@ -502,6 +502,30 @@ static int qeth_l2_send_setmac_cb(struct
 	if (cmd->hdr.return_code) {
 		QETH_DBF_TEXT_(TRACE, 2, "L2er%x", cmd->hdr.return_code);
 		card->info.mac_bits &= ~QETH_LAYER2_MAC_REGISTERED;
+		switch (cmd->hdr.return_code) {
+		case IPA_RC_L2_DUP_MAC:
+		case IPA_RC_L2_DUP_LAYER3_MAC:
+			dev_warn(&card->gdev->dev,
+				"MAC address "
+				"%2.2x:%2.2x:%2.2x:%2.2x:%2.2x:%2.2x "
+				"already exists\n",
+				card->dev->dev_addr[0], card->dev->dev_addr[1],
+				card->dev->dev_addr[2], card->dev->dev_addr[3],
+				card->dev->dev_addr[4], card->dev->dev_addr[5]);
+			break;
+		case IPA_RC_L2_MAC_NOT_AUTH_BY_HYP:
+		case IPA_RC_L2_MAC_NOT_AUTH_BY_ADP:
+			dev_warn(&card->gdev->dev,
+				"MAC address "
+				"%2.2x:%2.2x:%2.2x:%2.2x:%2.2x:%2.2x "
+				"is not authorized\n",
+				card->dev->dev_addr[0], card->dev->dev_addr[1],
+				card->dev->dev_addr[2], card->dev->dev_addr[3],
+				card->dev->dev_addr[4], card->dev->dev_addr[5]);
+			break;
+		default:
+			break;
+		}
 		cmd->hdr.return_code = -EIO;
 	} else {
 		card->info.mac_bits |= QETH_LAYER2_MAC_REGISTERED;

