From: Joonwoo Park <joonwpark81@gmail.com>
Subject: [PATCH 3/5] iwlwifi: iwl3945 fix oops while pci
	remove
Date: Wed,  9 Jan 2008 20:02:42 +0900
Message-ID: <1199876562379-git-send-email-joonwpark81@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>,
	Joonwoo Park <joonwpark81@gmail.com>,
	ipw3945-devel@lists.sourceforge.net
To: Zhu Yi <yi.zhu@intel.com>, netdev@vger.kernel.org
Return-path: <ipw3945-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/ipw3945-devel>,
	<mailto:ipw3945-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=ipw3945-devel>
List-Post: <mailto:ipw3945-devel@lists.sourceforge.net>
List-Help: <mailto:ipw3945-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/ipw3945-devel>,
	<mailto:ipw3945-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: ipw3945-devel-bounces@lists.sourceforge.net
Errors-To: ipw3945-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

The nic controller's clock on/off irq (CSR_INT_BIT_MAC_CLK_ACTV) is generated when device goes on/off
Unlikely turning on the device, irq by off the device may cause oops because iwl_pci_remove already freed required resources
The irq_tasklet should not be invoked at that condition

$sudo modprobe -r iwl3945
 BUG: unable to handle kernel paging request at virtual address f8864008
 printing eip: f8b633bd *pdpt = 0000000000003001 *pde = 0000000037c12067 *pte = 0000000000000000
 Oops: 0000 [#1] SMP
 Modules linked in: netconsole iwl3945 e1000

 EIP is at iwl_irq_tasklet+0x82d/0x1010 [iwl3945]
 ...

 Call Trace:
  [<c40053ba>] show_trace_log_lvl+0x1a/0x30
  [<c4005479>] show_stack_log_lvl+0xa9/0xd0
  [<c400556a>] show_registers+0xca/0x1c0
  [<c4005776>] die+0x116/0x230
  [<c4020cbb>] do_page_fault+0x35b/0x7f0
  [<c43eeeda>] error_code+0x72/0x78
  [<c4032ceb>] tasklet_action+0x4b/0xc0
  [<c4032687>] __do_softirq+0x87/0x100
  [<c4032757>] do_softirq+0x57/0x60
  ...
 EIP: [<f8b633bd>] iwl_irq_tasklet+0x82d/0x1010 [iwl3945] SS:ESP 0068:f7c4ff1c
 Kernel panic - not syncing: Fatal exception in interrupt

Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
---
 drivers/net/wireless/iwlwifi/iwl3945-base.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/wireless/iwlwifi/iwl3945-base.c
index 3986aaf..f95f226 100644
--- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
@@ -4867,8 +4867,11 @@ static irqreturn_t iwl_isr(int irq, void *data)
 	IWL_DEBUG_ISR("ISR inta 0x%08x, enabled 0x%08x, fh 0x%08x\n",
 		      inta, inta_mask, inta_fh);
 
+	inta &= ~CSR_INT_BIT_MAC_CLK_ACTV;
+
 	/* iwl_irq_tasklet() will service interrupts and re-enable them */
-	tasklet_schedule(&priv->irq_tasklet);
+	if (likely(inta || inta_fh))
+		tasklet_schedule(&priv->irq_tasklet);
 unplugged:
 	spin_unlock(&priv->lock);
 
-- 
1.5.3.rc5


-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://ad.doubleclick.net/clk;164216239;13503038;w?http://sf.net/marketplace
