From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] net: amd8111e: Convert timers to use timer_setup()
Date: Wed, 4 Oct 2017 17:51:39 -0700
Message-ID: <20171005005139.GA23458@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Jarod Wilson <jarod@redhat.com>,
        Philippe Reynes <tremyfr@gmail.com>, netdev@vger.kernel.org,
        Thomas Gleixner <tglx@linutronix.de>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Jarod Wilson <jarod@redhat.com>
Cc: Philippe Reynes <tremyfr@gmail.com>
Cc: netdev@vger.kernel.org
Cc: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Kees Cook <keescook@chromium.org>
---
This requires commit 686fef928bba ("timer: Prepare to change timer
callback argument type") in v4.14-rc3, but should be otherwise
stand-alone.
---
 drivers/net/ethernet/amd/amd8111e.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/amd/amd8111e.c b/drivers/net/ethernet/amd/amd8111e.c
index 7b5df562f30f..358f7ab77c70 100644
--- a/drivers/net/ethernet/amd/amd8111e.c
+++ b/drivers/net/ethernet/amd/amd8111e.c
@@ -1669,9 +1669,9 @@ static int amd8111e_resume(struct pci_dev *pci_dev)
 	return 0;
 }
 
-static void amd8111e_config_ipg(struct net_device *dev)
+static void amd8111e_config_ipg(struct timer_list *t)
 {
-	struct amd8111e_priv *lp = netdev_priv(dev);
+	struct amd8111e_priv *lp = from_timer(lp, t, ipg_data.ipg_timer);
 	struct ipg_info *ipg_data = &lp->ipg_data;
 	void __iomem *mmio = lp->mmio;
 	unsigned int prev_col_cnt = ipg_data->col_cnt;
@@ -1883,9 +1883,7 @@ static int amd8111e_probe_one(struct pci_dev *pdev,
 
 	/* Initialize software ipg timer */
 	if(lp->options & OPTION_DYN_IPG_ENABLE){
-		init_timer(&lp->ipg_data.ipg_timer);
-		lp->ipg_data.ipg_timer.data = (unsigned long) dev;
-		lp->ipg_data.ipg_timer.function = (void *)&amd8111e_config_ipg;
+		timer_setup(&lp->ipg_data.ipg_timer, amd8111e_config_ipg, 0);
 		lp->ipg_data.ipg_timer.expires = jiffies +
 						 IPG_CONVERGE_JIFFIES;
 		lp->ipg_data.ipg = DEFAULT_IPG;
-- 
2.7.4


-- 
Kees Cook
Pixel Security
