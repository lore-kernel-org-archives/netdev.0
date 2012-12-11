From: Rasesh Mody <rmody@brocade.com>
Subject: [net-next 5/7] bna: Add RX State
Date: Tue, 11 Dec 2012 14:24:54 -0800
Message-ID: <1355264696-8927-6-git-send-email-rmody@brocade.com>
References: <1355264696-8927-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <bhutchings@solarflare.com>, <David.Laight@ACULAB.COM>,
	<adapter_linux_open_src_team@brocade.com>,
	Rasesh Mody <rmody@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:38630 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754980Ab2LKWZe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2012 17:25:34 -0500
In-Reply-To: <1355264696-8927-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change Details:
 -      BNA state machine for Rx in start_wait state moves it to stop_wait on
        receipt of RX_E_STOP. In Rx stop_wait state, on receipt of
                RX_E_STARTED event does enet stop
                RX_E_STOPPED event does rx_cleanup_cbfn
        rx_cleanup_cbfn in this case is called without post_cbfn. post_cbfn
        happens only after RX_E_STARTED event is received in start_wait. Without
        doing post_cbfn, NAPI remains disabled and in cleanup we try to disable
        again causing endless wait. ifconfig process and other workers can thus
        get stuck.
 -      Introducing start_stop_wait state for Rx. This state handles the case of
        if post_cbfn is not done simply do stop without the cleanup.

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/ethernet/brocade/bna/bna_tx_rx.c |   27 +++++++++++++++++++++++++-
 1 files changed, 26 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bna_tx_rx.c b/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
index 4df6d4b..ea6f4a0 100644
--- a/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
+++ b/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
@@ -1355,6 +1355,8 @@ bfa_fsm_state_decl(bna_rx, stopped,
 	struct bna_rx, enum bna_rx_event);
 bfa_fsm_state_decl(bna_rx, start_wait,
 	struct bna_rx, enum bna_rx_event);
+bfa_fsm_state_decl(bna_rx, start_stop_wait,
+	struct bna_rx, enum bna_rx_event);
 bfa_fsm_state_decl(bna_rx, rxf_start_wait,
 	struct bna_rx, enum bna_rx_event);
 bfa_fsm_state_decl(bna_rx, started,
@@ -1432,7 +1434,7 @@ static void bna_rx_sm_start_wait(struct bna_rx *rx,
 {
 	switch (event) {
 	case RX_E_STOP:
-		bfa_fsm_set_state(rx, bna_rx_sm_stop_wait);
+		bfa_fsm_set_state(rx, bna_rx_sm_start_stop_wait);
 		break;
 
 	case RX_E_FAIL:
@@ -1488,6 +1490,29 @@ bna_rx_sm_rxf_stop_wait(struct bna_rx *rx, enum bna_rx_event event)
 
 }
 
+static void
+bna_rx_sm_start_stop_wait_entry(struct bna_rx *rx)
+{
+}
+
+static void
+bna_rx_sm_start_stop_wait(struct bna_rx *rx, enum bna_rx_event event)
+{
+	switch (event) {
+	case RX_E_FAIL:
+	case RX_E_STOPPED:
+		bfa_fsm_set_state(rx, bna_rx_sm_stopped);
+		break;
+
+	case RX_E_STARTED:
+		bna_rx_enet_stop(rx);
+		break;
+
+	default:
+		bfa_sm_fault(event);
+	}
+}
+
 void
 bna_rx_sm_started_entry(struct bna_rx *rx)
 {
-- 
1.7.1
