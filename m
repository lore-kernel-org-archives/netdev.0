From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 1/2] net: ethtool: Add back transceiver type
Date: Wed, 20 Sep 2017 15:52:13 -0700
Message-ID: <20170920225214.21974-2-f.fainelli@gmail.com>
References: <20170920225214.21974-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, linville@tuxdriver.com, decot@googlers.com,
        tremyfr@gmail.com, andrew@lunn.ch,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:34615 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751647AbdITWwW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 18:52:22 -0400
Received: by mail-qk0-f195.google.com with SMTP id d70so2596285qkc.1
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 15:52:21 -0700 (PDT)
In-Reply-To: <20170920225214.21974-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 3f1ac7a700d0 ("net: ethtool: add new ETHTOOL_xLINKSETTINGS API")
deprecated the ethtool_cmd::transceiver field, which was fine in
premise, except that the PHY library was actually using it to report the
type of transceiver: internal or external.

Use the first word of the reserved field to put this __u8 transceiver
field back in. It is made read-only, and we don't expect the
ETHTOOL_xLINKSETTINGS API to be doing anything with this anyway, so this
is mostly for the legacy path where we do:

ethtool_get_settings()
-> dev->ethtool_ops->get_link_ksettings()
   -> convert_link_ksettings_to_legacy_settings()

to have no information loss compared to the legacy get_settings API.

Fixes: 3f1ac7a700d0 ("net: ethtool: add new ETHTOOL_xLINKSETTINGS API")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/uapi/linux/ethtool.h | 6 +++++-
 net/core/ethtool.c           | 2 ++
 2 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index 9c041dae8e2c..5bd1b1de4ea0 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -1753,6 +1753,8 @@ enum ethtool_reset_flags {
  *	%ethtool_link_mode_bit_indices for the link modes, and other
  *	link features that the link partner advertised through
  *	autonegotiation; 0 if unknown or not applicable.  Read-only.
+ * @transceiver: Used to distinguish different possible PHY types,
+ *	reported consistently by PHYLIB.  Read-only.
  *
  * If autonegotiation is disabled, the speed and @duplex represent the
  * fixed link mode and are writable if the driver supports multiple
@@ -1804,7 +1806,9 @@ struct ethtool_link_settings {
 	__u8	eth_tp_mdix;
 	__u8	eth_tp_mdix_ctrl;
 	__s8	link_mode_masks_nwords;
-	__u32	reserved[8];
+	__u8	transceiver;
+	__u8	reserved1[3];
+	__u32	reserved[7];
 	__u32	link_mode_masks[0];
 	/* layout of link_mode_masks fields:
 	 * __u32 map_supported[link_mode_masks_nwords];
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 6a582ae4c5d9..3228411ada0f 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -525,6 +525,8 @@ convert_link_ksettings_to_legacy_settings(
 		= link_ksettings->base.eth_tp_mdix;
 	legacy_settings->eth_tp_mdix_ctrl
 		= link_ksettings->base.eth_tp_mdix_ctrl;
+	legacy_settings->transceiver
+		= link_ksettings->base.transceiver;
 	return retval;
 }
 
-- 
2.9.3
