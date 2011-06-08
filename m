From: Esa-Pekka Pyokkimies <esa-pekka.pyokkimies@stonesoft.com>
Subject: [PATCH] ixgbe: Report PAUSE flags to ethtool
Date: Wed, 8 Jun 2011 09:33:19 +0300
Message-ID: <op.vwqu5trx6ywr33@esapekka-pc.rad1>
References: <op.vwnklt0q6ywr33@esapekka-pc.rad1>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hki-smtp-1b.stonesoft.com ([84.34.144.100]:59965 "EHLO
	hki-smtp-1b.stonesoft.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753344Ab1FHGzB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2011 02:55:01 -0400
Received: from hki-smtp-1b.stonesoft.com (hki-smtp-1b.stonesoft.com [127.0.0.1])
	by localhost.stonesoft.com (Postfix) with ESMTP id E658CD8CB36
	for <netdev@vger.kernel.org>; Wed,  8 Jun 2011 09:33:19 +0300 (EEST)
Received: from outlook.stonesoft.com (unknown [172.16.40.22])
	(using TLSv1 with cipher AES128-SHA (128/128 bits))
	(No client certificate requested)
	by hki-smtp-1b.stonesoft.com (Postfix) with ESMTP id D9803D8CABC
	for <netdev@vger.kernel.org>; Wed,  8 Jun 2011 09:33:19 +0300 (EEST)
In-Reply-To: <op.vwnklt0q6ywr33@esapekka-pc.rad1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

I noticed that ixgbe driver doesn't report SUPPORTED_Pause and
ADVERTISED_Pause flags to ethtool. This means that ethtool
always reports:
	Supported pause frame use: No
	Advertised pause frame use: No
I added reporting for capabilities and advertising.
I tested it with our ixgbe card and latest ethtool
   from git repo. I also need to add capability to
change advertising parameters with "ethtool -s advertise %x",
but will send in a different patch if this patch looks ok.

Signed-off-by: Esa-Pekka Pyokkimies <esa-pekka.pyokkimies@stonesoft.com>
---
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c
b/drivers/net/ixgbe/ixgbe_ethtool.c
index cb1555b..6005116 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -150,6 +150,7 @@ static int ixgbe_get_settings(struct net_device
*netdev,
    	bool link_up;

    	ecmd->supported = SUPPORTED_10000baseT_Full;
+	ecmd->supported |= SUPPORTED_Pause;
    	ecmd->autoneg = AUTONEG_ENABLE;
    	ecmd->transceiver = XCVR_EXTERNAL;
    	if ((hw->phy.media_type == ixgbe_media_type_copper) ||
@@ -231,6 +232,21 @@ static int ixgbe_get_settings(struct net_device
*netdev,
    		ecmd->autoneg = AUTONEG_DISABLE;
    	}

+	if (hw->fc.current_mode == ixgbe_fc_full) {
+		ecmd->advertising |= ADVERTISED_Pause;
+	} else if (hw->fc.current_mode == ixgbe_fc_rx_pause) {
+		ecmd->advertising |= ADVERTISED_Pause;
+		ecmd->advertising |= ADVERTISED_Asym_Pause;
+	} else if (hw->fc.current_mode == ixgbe_fc_tx_pause) {
+		ecmd->advertising |= ADVERTISED_Asym_Pause;
+	} else if (hw->fc.current_mode == ixgbe_fc_none) {
+		/* Correctly initialized */
+	} else if (hw->fc.current_mode == ixgbe_fc_pfc) {
+		/* Ethtool doesn't know about this mode */
+	} else {
+		/* Future modes */
+	}
+
    	/* Get PHY type */
    	switch (adapter->hw.phy.type) {
    	case ixgbe_phy_tn:


-- 
Using Opera's revolutionary email client: http://www.opera.com/mail/
