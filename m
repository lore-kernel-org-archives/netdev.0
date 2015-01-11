From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] alx: fix alx_poll()
Date: Sun, 11 Jan 2015 10:32:18 -0800
Message-ID: <1421001138.5947.100.camel@edumazet-glaptop2.roam.corp.google.com>
References: <54B18DFF.80400@amd.com>
	 <1420923485.5947.85.camel@edumazet-glaptop2.roam.corp.google.com>
	 <54B199EB.1080004@amd.com>
	 <1420926614.5947.89.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes.berg@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Willem de Bruijn <willemb@google.com>,
	"Bridgman, John" <John.Bridgman@amd.com>,
	"Elifaz, Dana" <Dana.Elifaz@amd.com>
To: Oded Gabbay <oded.gabbay@amd.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:53966 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750780AbbAKScV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jan 2015 13:32:21 -0500
Received: by mail-ie0-f171.google.com with SMTP id ar1so22335451iec.2
        for <netdev@vger.kernel.org>; Sun, 11 Jan 2015 10:32:20 -0800 (PST)
In-Reply-To: <1420926614.5947.89.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Commit d75b1ade567f ("net: less interrupt masking in NAPI") uncovered
wrong alx_poll() behavior.

A NAPI poll() handler is supposed to return exactly the budget when/if
napi_complete() has not been called.

It is also supposed to return number of frames that were received, so
that netdev_budget can have a meaning.

Also, in case of TX pressure, we still have to dequeue received
packets : alx_clean_rx_irq() has to be called even if
alx_clean_tx_irq(alx) returns false, otherwise device is half duplex.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Fixes: d75b1ade567f ("net: less interrupt masking in NAPI")
Reported-by: Oded Gabbay <oded.gabbay@amd.com>
Bisected-by: Oded Gabbay <oded.gabbay@amd.com>
Tested-by: Oded Gabbay <oded.gabbay@amd.com>
---
 drivers/net/ethernet/atheros/alx/main.c |   24 +++++++++++-----------
 1 file changed, 13 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/atheros/alx/main.c b/drivers/net/ethernet/atheros/alx/main.c
index e398eda07298..c8af3ce3ea38 100644
--- a/drivers/net/ethernet/atheros/alx/main.c
+++ b/drivers/net/ethernet/atheros/alx/main.c
@@ -184,15 +184,16 @@ static void alx_schedule_reset(struct alx_priv *alx)
 	schedule_work(&alx->reset_wk);
 }
 
-static bool alx_clean_rx_irq(struct alx_priv *alx, int budget)
+static int alx_clean_rx_irq(struct alx_priv *alx, int budget)
 {
 	struct alx_rx_queue *rxq = &alx->rxq;
 	struct alx_rrd *rrd;
 	struct alx_buffer *rxb;
 	struct sk_buff *skb;
 	u16 length, rfd_cleaned = 0;
+	int work = 0;
 
-	while (budget > 0) {
+	while (work < budget) {
 		rrd = &rxq->rrd[rxq->rrd_read_idx];
 		if (!(rrd->word3 & cpu_to_le32(1 << RRD_UPDATED_SHIFT)))
 			break;
@@ -203,7 +204,7 @@ static bool alx_clean_rx_irq(struct alx_priv *alx, int budget)
 		    ALX_GET_FIELD(le32_to_cpu(rrd->word0),
 				  RRD_NOR) != 1) {
 			alx_schedule_reset(alx);
-			return 0;
+			return work;
 		}
 
 		rxb = &rxq->bufs[rxq->read_idx];
@@ -243,7 +244,7 @@ static bool alx_clean_rx_irq(struct alx_priv *alx, int budget)
 		}
 
 		napi_gro_receive(&alx->napi, skb);
-		budget--;
+		work++;
 
 next_pkt:
 		if (++rxq->read_idx == alx->rx_ringsz)
@@ -258,21 +259,22 @@ next_pkt:
 	if (rfd_cleaned)
 		alx_refill_rx_ring(alx, GFP_ATOMIC);
 
-	return budget > 0;
+	return work;
 }
 
 static int alx_poll(struct napi_struct *napi, int budget)
 {
 	struct alx_priv *alx = container_of(napi, struct alx_priv, napi);
 	struct alx_hw *hw = &alx->hw;
-	bool complete = true;
 	unsigned long flags;
+	bool tx_complete;
+	int work;
 
-	complete = alx_clean_tx_irq(alx) &&
-		   alx_clean_rx_irq(alx, budget);
+	tx_complete = alx_clean_tx_irq(alx);
+	work = alx_clean_rx_irq(alx, budget);
 
-	if (!complete)
-		return 1;
+	if (!tx_complete || work == budget)
+		return budget;
 
 	napi_complete(&alx->napi);
 
@@ -284,7 +286,7 @@ static int alx_poll(struct napi_struct *napi, int budget)
 
 	alx_post_write(hw);
 
-	return 0;
+	return work;
 }
 
 static irqreturn_t alx_intr_handle(struct alx_priv *alx, u32 intr)
