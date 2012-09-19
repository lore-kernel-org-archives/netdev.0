From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 11/11] sfc: Avoid generating over-length
 MC_CMD_FLUSH_RX_QUEUES request
Date: Wed, 19 Sep 2012 20:18:49 +0100
Message-ID: <1348082329.2636.26.camel@bwh-desktop.uk.solarflarecom.com>
References: <1348081775.2636.15.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:20258 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932495Ab2ISTSw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2012 15:18:52 -0400
In-Reply-To: <1348081775.2636.15.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MCDI supports requests up to 252 bytes long, which is only enough to
pass 63 RX queue IDs to MC_CMD_FLUSH_RX_QUEUES.  However a VF may have
up to 64 RX queues, and if we try to flush them all we will generate
an over-length request and BUG() in efx_mcdi_copyin().  Currently
all VF drivers limit themselves to 32 RX queues, so reducing the
limit to 63 does no harm.

Also add a BUILD_BUG_ON in efx_mcdi_flush_rxqs() so we remember to
deal with the same problem there if EFX_MAX_CHANNELS is increased.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi.c        |    3 +++
 drivers/net/ethernet/sfc/siena_sriov.c |    7 +++++++
 2 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index e855f4c..aea43cb 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -1195,6 +1195,9 @@ int efx_mcdi_flush_rxqs(struct efx_nic *efx)
 	__le32 *qid;
 	int rc, count;
 
+	BUILD_BUG_ON(EFX_MAX_CHANNELS >
+		     MC_CMD_FLUSH_RX_QUEUES_IN_QID_OFST_MAXNUM);
+
 	qid = kmalloc(EFX_MAX_CHANNELS * sizeof(*qid), GFP_KERNEL);
 	if (qid == NULL)
 		return -ENOMEM;
diff --git a/drivers/net/ethernet/sfc/siena_sriov.c b/drivers/net/ethernet/sfc/siena_sriov.c
index 9cb3b84..a8f48a4 100644
--- a/drivers/net/ethernet/sfc/siena_sriov.c
+++ b/drivers/net/ethernet/sfc/siena_sriov.c
@@ -21,6 +21,9 @@
 /* Number of longs required to track all the VIs in a VF */
 #define VI_MASK_LENGTH BITS_TO_LONGS(1 << EFX_VI_SCALE_MAX)
 
+/* Maximum number of RX queues supported */
+#define VF_MAX_RX_QUEUES 63
+
 /**
  * enum efx_vf_tx_filter_mode - TX MAC filtering behaviour
  * @VF_TX_FILTER_OFF: Disabled
@@ -578,6 +581,7 @@ static int efx_vfdi_init_rxq(struct efx_vf *vf)
 	efx_oword_t reg;
 
 	if (bad_vf_index(efx, vf_evq) || bad_vf_index(efx, vf_rxq) ||
+	    vf_rxq >= VF_MAX_RX_QUEUES ||
 	    bad_buf_count(buf_count, EFX_MAX_DMAQ_SIZE)) {
 		if (net_ratelimit())
 			netif_err(efx, hw, efx->net_dev,
@@ -683,6 +687,9 @@ static int efx_vfdi_fini_all_queues(struct efx_vf *vf)
 	__le32 *rxqs;
 	int rc;
 
+	BUILD_BUG_ON(VF_MAX_RX_QUEUES >
+		     MC_CMD_FLUSH_RX_QUEUES_IN_QID_OFST_MAXNUM);
+
 	rxqs = kmalloc(count * sizeof(*rxqs), GFP_KERNEL);
 	if (rxqs == NULL)
 		return VFDI_RC_ENOMEM;
-- 
1.7.7.6


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
