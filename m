From: frank.blaschka@de.ibm.com
Subject: [patch 6/7] [PATCH] qeth: meaningful return code for set_mac_address
Date: Wed, 07 Mar 2012 13:06:28 +0100
Message-ID: <20120307120708.147245783@de.ibm.com>
References: <20120307120622.922387262@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp17.uk.ibm.com ([195.75.94.113]:43412 "EHLO
	e06smtp17.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755584Ab2CGMH1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2012 07:07:27 -0500
Received: from /spool/local
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Wed, 7 Mar 2012 12:07:26 -0000
Content-Disposition: inline; filename=613-qeth-rc-set-mac.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

Setting an invalid mac-address for a qeth layer2 device returns
with a strange error code:
# ip link set hsi1 address 00:00:00:00:00:01
   RTNETLINK answers: Unknown error 18446744073709486085
Problem is caused by wrong usage of the return_code field within
structure qeth_ipa_cmd.
With this patch the ip command above returns
   SIOCSIFHWADDR: Invalid argument

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_core_main.c |    6 +++---
 drivers/s390/net/qeth_core_mpc.c  |    1 +
 drivers/s390/net/qeth_core_mpc.h  |    1 +
 drivers/s390/net/qeth_l2_main.c   |    4 +---
 drivers/s390/net/qeth_l3_main.c   |    2 +-
 5 files changed, 7 insertions(+), 7 deletions(-)

--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -2945,8 +2945,8 @@ static int qeth_query_ipassists_cb(struc
 		card->options.ipa6.enabled_funcs = cmd->hdr.ipa_enabled;
 	}
 	QETH_DBF_TEXT(SETUP, 2, "suppenbl");
-	QETH_DBF_TEXT_(SETUP, 2, "%x", cmd->hdr.ipa_supported);
-	QETH_DBF_TEXT_(SETUP, 2, "%x", cmd->hdr.ipa_enabled);
+	QETH_DBF_TEXT_(SETUP, 2, "%08x", (__u32)cmd->hdr.ipa_supported);
+	QETH_DBF_TEXT_(SETUP, 2, "%08x", (__u32)cmd->hdr.ipa_enabled);
 	return 0;
 }
 
@@ -4322,7 +4322,7 @@ static int qeth_snmp_command_cb(struct q
 	/* check if there is enough room in userspace */
 	if ((qinfo->udata_len - qinfo->udata_offset) < data_len) {
 		QETH_CARD_TEXT_(card, 4, "scer3%i", -ENOMEM);
-		cmd->hdr.return_code = -ENOMEM;
+		cmd->hdr.return_code = IPA_RC_ENOMEM;
 		return 0;
 	}
 	QETH_CARD_TEXT_(card, 4, "snore%i",
--- a/drivers/s390/net/qeth_core_mpc.c
+++ b/drivers/s390/net/qeth_core_mpc.c
@@ -207,6 +207,7 @@ static struct ipa_rc_msg qeth_ipa_rc_msg
 	{IPA_RC_MC_ADDR_ALREADY_DEFINED, "Multicast address already defined"},
 	{IPA_RC_LAN_OFFLINE,		"STRTLAN_LAN_DISABLED - LAN offline"},
 	{IPA_RC_INVALID_IP_VERSION2,	"Invalid IP version"},
+	{IPA_RC_ENOMEM,			"Memory problem"},
 	{IPA_RC_FFFF,			"Unknown Error"}
 };
 
--- a/drivers/s390/net/qeth_core_mpc.h
+++ b/drivers/s390/net/qeth_core_mpc.h
@@ -190,6 +190,7 @@ enum qeth_ipa_return_codes {
 	IPA_RC_MC_ADDR_ALREADY_DEFINED	= 0xe013,
 	IPA_RC_LAN_OFFLINE		= 0xe080,
 	IPA_RC_INVALID_IP_VERSION2	= 0xf001,
+	IPA_RC_ENOMEM			= 0xfffe,
 	IPA_RC_FFFF			= 0xffff
 };
 /* for DELIP */
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -576,7 +576,6 @@ static int qeth_l2_send_setmac_cb(struct
 		default:
 			break;
 		}
-		cmd->hdr.return_code = -EIO;
 	} else {
 		card->info.mac_bits |= QETH_LAYER2_MAC_REGISTERED;
 		memcpy(card->dev->dev_addr, cmd->data.setdelmac.mac,
@@ -605,7 +604,6 @@ static int qeth_l2_send_delmac_cb(struct
 	cmd = (struct qeth_ipa_cmd *) data;
 	if (cmd->hdr.return_code) {
 		QETH_CARD_TEXT_(card, 2, "err%d", cmd->hdr.return_code);
-		cmd->hdr.return_code = -EIO;
 		return 0;
 	}
 	card->info.mac_bits &= ~QETH_LAYER2_MAC_REGISTERED;
@@ -682,7 +680,7 @@ static int qeth_l2_set_mac_address(struc
 	rc = qeth_l2_send_delmac(card, &card->dev->dev_addr[0]);
 	if (!rc)
 		rc = qeth_l2_send_setmac(card, addr->sa_data);
-	return rc;
+	return rc ? -EINVAL : 0;
 }
 
 static void qeth_l2_set_multicast_list(struct net_device *dev)
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -2430,7 +2430,7 @@ static int qeth_l3_arp_query_cb(struct q
 
 		if ((qinfo->udata_len - qinfo->udata_offset) < esize) {
 			QETH_CARD_TEXT_(card, 4, "qaer3%i", -ENOMEM);
-			cmd->hdr.return_code = -ENOMEM;
+			cmd->hdr.return_code = IPA_RC_ENOMEM;
 			goto out_error;
 		}
 
