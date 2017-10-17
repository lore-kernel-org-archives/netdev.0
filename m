From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 25/58] net: amd8111e: Convert timers to use timer_setup()
Date: Mon, 16 Oct 2017 17:29:09 -0700
Message-ID: <1508200182-104605-26-git-send-email-keescook@chromium.org>
References: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Cc: Kees Cook <keescook@chromium.org>,
        Eric Dumazet <edumazet@google.com>,
        Jarod Wilson <jarod@redhat.com>,
        Philippe Reynes <tremyfr@gmail.com>, netdev@vger.kernel.org,
        Thomas Gleixner <tglx@linutronix.de>,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1508200182-104605-1-git-send-email-keescook@chromium.org>
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
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/ethernet/amd/amd8111e.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/amd/amd8111e.c b/drivers/net/ethernet/amd/amd8111e.c
index 7f22af6e37e0..358f7ab77c70 100644
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
@@ -1883,8 +1883,7 @@ static int amd8111e_probe_one(struct pci_dev *pdev,
 
 	/* Initialize software ipg timer */
 	if(lp->options & OPTION_DYN_IPG_ENABLE){
-		setup_timer(&lp->ipg_data.ipg_timer,
-			    (void *)&amd8111e_config_ipg, (unsigned long)dev);
+		timer_setup(&lp->ipg_data.ipg_timer, amd8111e_config_ipg, 0);
 		lp->ipg_data.ipg_timer.expires = jiffies +
 						 IPG_CONVERGE_JIFFIES;
 		lp->ipg_data.ipg = DEFAULT_IPG;
-- 
2.7.4
