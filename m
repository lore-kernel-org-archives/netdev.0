From: Vlad Zakharov <Vladislav.Zakharov@synopsys.com>
Subject: [PATCH] ezchip: nps_enet: check if napi has been completed
Date: Wed, 29 Mar 2017 13:41:46 +0300
Message-ID: <1490784106-14489-1-git-send-email-vzakhar@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Noam Camus <noamca@mellanox.com>, linux-kernel@vger.kernel.org,
 Elad Kanfi <eladkan@mellanox.com>, Eric Dumazet <edumazet@google.com>,
 Vlad Zakharov <Vladislav.Zakharov@synopsys.com>,
 linux-snps-arc@lists.infradead.org, "David S . Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <linux-snps-arc-bounces+gla-linux-snps-arc=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-snps-arc>,
 <mailto:linux-snps-arc-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-snps-arc/>
List-Post: <mailto:linux-snps-arc@lists.infradead.org>
List-Help: <mailto:linux-snps-arc-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-snps-arc>,
 <mailto:linux-snps-arc-request@lists.infradead.org?subject=subscribe>
Sender: "linux-snps-arc" <linux-snps-arc-bounces@lists.infradead.org>
Errors-To: linux-snps-arc-bounces+gla-linux-snps-arc=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

After a new NAPI_STATE_MISSED state was added to NAPI we can get into
this state and in such case we have to reschedule NAPI as some work is
still pending and we have to process it. napi_complete_done() function
returns false if we have to reschedule something (e.g. in case we were
in MISSED state) as current polling have not been completed yet.

nps_enet driver hasn't been verifying the return value of
napi_complete_done() and has been forcibly enabling interrupts. That is
not correct as we should not enable interrupts before we have processed
all scheduled work. As a result we were getting trapped in interrupt
hanlder chain as we had never been able to disabale ethernet
interrupts again.

So this patch makes nps_enet_poll() func verify return value of
napi_complete_done() and enable interrupts only in case all scheduled
work has been completed.

Signed-off-by: Vlad Zakharov <vzakhar@synopsys.com>
---
 drivers/net/ethernet/ezchip/nps_enet.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/ezchip/nps_enet.c b/drivers/net/ethernet/ezchip/nps_enet.c
index 992ebe9..f819843 100644
--- a/drivers/net/ethernet/ezchip/nps_enet.c
+++ b/drivers/net/ethernet/ezchip/nps_enet.c
@@ -189,11 +189,9 @@ static int nps_enet_poll(struct napi_struct *napi, int budget)
 
 	nps_enet_tx_handler(ndev);
 	work_done = nps_enet_rx_handler(ndev);
-	if (work_done < budget) {
+	if ((work_done < budget) && napi_complete_done(napi, work_done)) {
 		u32 buf_int_enable_value = 0;
 
-		napi_complete_done(napi, work_done);
-
 		/* set tx_done and rx_rdy bits */
 		buf_int_enable_value |= NPS_ENET_ENABLE << RX_RDY_SHIFT;
 		buf_int_enable_value |= NPS_ENET_ENABLE << TX_DONE_SHIFT;
-- 
2.7.4
