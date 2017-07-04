From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net 3/3] nfp: default to chained metadata prepend format
Date: Tue,  4 Jul 2017 02:27:21 -0700
Message-ID: <20170704092721.780-4-jakub.kicinski@netronome.com>
References: <20170704092721.780-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:35073 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751631AbdGDJ2i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Jul 2017 05:28:38 -0400
Received: by mail-pg0-f44.google.com with SMTP id j186so107610294pge.2
        for <netdev@vger.kernel.org>; Tue, 04 Jul 2017 02:28:38 -0700 (PDT)
In-Reply-To: <20170704092721.780-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ABI 4.x introduced the chained metadata format and made it the
only one possible.  There are cases, however, where the old
format is preferred - mostly to make interoperation with VFs
using ABI 3.x easier for the datapath.  In ABI 5.x we allowed
for more flexibility by selecting the metadata format based
on capabilities.  The default was left to non-chained.

In case of fallback traffic, there is no capability telling the
driver there may be chained metadata.  With a very stripped-
-down FW the default old metadata format would be selected
making the driver drop all fallback traffic.

This patch changes the default selection in the driver. It
should not hurt with old firmwares, because if they don't
advertise RSS they will not produce metadata anyway.  New
firmwares advertising ABI 5.x, however, can depend on the
driver defaulting to chained format.

Fixes: f9380629fafc ("nfp: advertise support for NFD ABI 0.5")
Suggested-by: Michael Rapson <michael.rapson@netronome.com>
Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 30f82b41d400..18750ff0ede6 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -3719,10 +3719,17 @@ int nfp_net_init(struct nfp_net *nn)
 	nn->cap = nn_readl(nn, NFP_NET_CFG_CAP);
 	nn->max_mtu = nn_readl(nn, NFP_NET_CFG_MAX_MTU);
 
-	/* Chained metadata is signalled by capabilities except in version 4 */
+	/* ABI 4.x and ctrl vNIC always use chained metadata, in other cases
+	 * we allow use of non-chained metadata if RSS(v1) is the only
+	 * advertised capability requiring metadata.
+	 */
 	nn->dp.chained_metadata_format = nn->fw_ver.major == 4 ||
 					 !nn->dp.netdev ||
+					 !(nn->cap & NFP_NET_CFG_CTRL_RSS) ||
 					 nn->cap & NFP_NET_CFG_CTRL_CHAIN_META;
+	/* RSS(v1) uses non-chained metadata format, except in ABI 4.x where
+	 * it has the same meaning as RSSv2.
+	 */
 	if (nn->dp.chained_metadata_format && nn->fw_ver.major != 4)
 		nn->cap &= ~NFP_NET_CFG_CTRL_RSS;
 
-- 
2.11.0
