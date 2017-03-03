From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net 1/2] sfc: avoid max() in array size
Date: Fri, 3 Mar 2017 15:22:09 +0000
Message-ID: <a7968205-58b6-a8e5-e3f7-757cf9ec46f6@solarflare.com>
References: <0750d060-35d1-c221-f866-fba825e3947e@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: <linux-net-drivers@solarflare.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:63136 "EHLO
        nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752332AbdCCPXO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Mar 2017 10:23:14 -0500
In-Reply-To: <0750d060-35d1-c221-f866-fba825e3947e@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It confuses sparse, which thinks the size isn't constant.  Let's achieve
 the same thing with a BUILD_BUG_ON, since we know which one should be
 bigger and don't expect them ever to change.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 92e1c6d..4d88e85 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -828,9 +828,7 @@ static int efx_ef10_alloc_piobufs(struct efx_nic *efx, unsigned int n)
 static int efx_ef10_link_piobufs(struct efx_nic *efx)
 {
 	struct efx_ef10_nic_data *nic_data = efx->nic_data;
-	_MCDI_DECLARE_BUF(inbuf,
-			  max(MC_CMD_LINK_PIOBUF_IN_LEN,
-			      MC_CMD_UNLINK_PIOBUF_IN_LEN));
+	MCDI_DECLARE_BUF(inbuf, MC_CMD_LINK_PIOBUF_IN_LEN);
 	struct efx_channel *channel;
 	struct efx_tx_queue *tx_queue;
 	unsigned int offset, index;
@@ -839,8 +837,6 @@ static int efx_ef10_link_piobufs(struct efx_nic *efx)
 	BUILD_BUG_ON(MC_CMD_LINK_PIOBUF_OUT_LEN != 0);
 	BUILD_BUG_ON(MC_CMD_UNLINK_PIOBUF_OUT_LEN != 0);
 
-	memset(inbuf, 0, sizeof(inbuf));
-
 	/* Link a buffer to each VI in the write-combining mapping */
 	for (index = 0; index < nic_data->n_piobufs; ++index) {
 		MCDI_SET_DWORD(inbuf, LINK_PIOBUF_IN_PIOBUF_HANDLE,
@@ -920,6 +916,10 @@ static int efx_ef10_link_piobufs(struct efx_nic *efx)
 	return 0;
 
 fail:
+	/* inbuf was defined for MC_CMD_LINK_PIOBUF.  We can use the same
+	 * buffer for MC_CMD_UNLINK_PIOBUF because it's shorter.
+	 */
+	BUILD_BUG_ON(MC_CMD_LINK_PIOBUF_IN_LEN < MC_CMD_UNLINK_PIOBUF_IN_LEN);
 	while (index--) {
 		MCDI_SET_DWORD(inbuf, UNLINK_PIOBUF_IN_TXQ_INSTANCE,
 			       nic_data->pio_write_vi_base + index);
