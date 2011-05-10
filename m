From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Subject: [PATCH net-next-2.6 1/5] be2net: Handle error completion in Lancer
Date: Tue, 10 May 2011 20:42:17 +0530
Message-ID: <410ae1f9-34cc-4957-8faa-4c3c36f9839f@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:11240 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755715Ab1EJPNC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 11:13:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In Lancer if a frame is DMAed partially due to lack of RX buffers,
an error completion is sent with packet size as zero and num_recvd
indicating number of used buffers. These buffers need to be freed
and packet dropped.

Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
---
 drivers/net/benet/be_main.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 7b19931..b1beb31 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -1754,12 +1754,15 @@ static int be_poll_rx(struct napi_struct *napi, int budget)
 			break;
 
 		/* Ignore flush completions */
-		if (rxcp->num_rcvd) {
+		if (rxcp->num_rcvd && rxcp->pkt_size) {
 			if (do_gro(rxcp))
 				be_rx_compl_process_gro(adapter, rxo, rxcp);
 			else
 				be_rx_compl_process(adapter, rxo, rxcp);
+		} else if (rxcp->pkt_size == 0) {
+			be_rx_compl_discard(adapter, rxo, rxcp);
 		}
+
 		be_rx_stats_update(rxo, rxcp);
 	}
 
-- 
1.6.0.2

