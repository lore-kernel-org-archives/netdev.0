From: Bert Kenward <bkenward@solarflare.com>
Subject: [PATCH net] sfc: disable RSS when unsupported
Date: Mon, 25 Apr 2016 16:51:00 +0100
Message-ID: <571E3CE4.6010808@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Jon Cooper <jcooper@solarflare.com>,
	"Solarflare Linux maintainers" <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:2391 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751197AbcDYP6n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 11:58:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Cooper <jcooper@solarflare.com>

When certain firmware variants are selected (via the sfboot utility) the
SFC7000 and SFC8000 series NICs don't support RSS. The driver still
tries (and fails) to insert filters with the RSS flag, and the NIC fails
to pass traffic.

When the firmware reports RSS_LIMITED suppress allocating a default RSS
context. The absence of an RSS context is picked up in filter insertion
and RSS flags are discarded.

Signed-off-by: Bert Kenward <bkenward@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 15 +++++++++++++--
 1 file changed, 13 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 98d33d4..1681084 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -1920,6 +1920,10 @@ static int efx_ef10_alloc_rss_context(struct efx_nic *efx, u32 *context,
 		return 0;
 	}
 
+	if (nic_data->datapath_caps &
+	    1 << MC_CMD_GET_CAPABILITIES_OUT_RX_RSS_LIMITED_LBN)
+		return -EOPNOTSUPP;
+
 	MCDI_SET_DWORD(inbuf, RSS_CONTEXT_ALLOC_IN_UPSTREAM_PORT_ID,
 		       nic_data->vport_id);
 	MCDI_SET_DWORD(inbuf, RSS_CONTEXT_ALLOC_IN_TYPE, alloc_type);
@@ -2923,9 +2927,16 @@ static void efx_ef10_filter_push_prep(struct efx_nic *efx,
 				      bool replacing)
 {
 	struct efx_ef10_nic_data *nic_data = efx->nic_data;
+	u32 flags = spec->flags;
 
 	memset(inbuf, 0, MC_CMD_FILTER_OP_IN_LEN);
 
+	/* Remove RSS flag if we don't have an RSS context. */
+	if (flags & EFX_FILTER_FLAG_RX_RSS &&
+	    spec->rss_context == EFX_FILTER_RSS_CONTEXT_DEFAULT &&
+	    nic_data->rx_rss_context == EFX_EF10_RSS_CONTEXT_INVALID)
+		flags &= ~EFX_FILTER_FLAG_RX_RSS;
+
 	if (replacing) {
 		MCDI_SET_DWORD(inbuf, FILTER_OP_IN_OP,
 			       MC_CMD_FILTER_OP_IN_OP_REPLACE);
@@ -2985,10 +2996,10 @@ static void efx_ef10_filter_push_prep(struct efx_nic *efx,
 		       spec->dmaq_id == EFX_FILTER_RX_DMAQ_ID_DROP ?
 		       0 : spec->dmaq_id);
 	MCDI_SET_DWORD(inbuf, FILTER_OP_IN_RX_MODE,
-		       (spec->flags & EFX_FILTER_FLAG_RX_RSS) ?
+		       (flags & EFX_FILTER_FLAG_RX_RSS) ?
 		       MC_CMD_FILTER_OP_IN_RX_MODE_RSS :
 		       MC_CMD_FILTER_OP_IN_RX_MODE_SIMPLE);
-	if (spec->flags & EFX_FILTER_FLAG_RX_RSS)
+	if (flags & EFX_FILTER_FLAG_RX_RSS)
 		MCDI_SET_DWORD(inbuf, FILTER_OP_IN_RX_CONTEXT,
 			       spec->rss_context !=
 			       EFX_FILTER_RSS_CONTEXT_DEFAULT ?
-- 
2.5.5
