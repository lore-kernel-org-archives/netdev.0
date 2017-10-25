From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] drivers/net: netronome: Convert timers to use timer_setup()
Date: Wed, 25 Oct 2017 03:51:38 -0700
Message-ID: <20171025105138.GA146561@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Simon Horman <simon.horman@netronome.com>,
        oss-drivers@netronome.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Jiri Pirko <jiri@mellanox.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: Simon Horman <simon.horman@netronome.com>
Cc: oss-drivers@netronome.com
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/ethernet/netronome/nfp/bpf/main.c       | 5 +++--
 drivers/net/ethernet/netronome/nfp/bpf/main.h       | 3 ++-
 drivers/net/ethernet/netronome/nfp/bpf/offload.c    | 9 ++++-----
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 7 +++----
 4 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/bpf/main.c b/drivers/net/ethernet/netronome/nfp/bpf/main.c
index fa0ac90ed956..f15a186f6c87 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/main.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/main.c
@@ -97,8 +97,9 @@ nfp_bpf_vnic_alloc(struct nfp_app *app, struct nfp_net *nn, unsigned int id)
 
 	nn->app_priv = priv;
 	spin_lock_init(&priv->rx_filter_lock);
-	setup_timer(&priv->rx_filter_stats_timer,
-		    nfp_net_filter_stats_timer, (unsigned long)nn);
+	priv->nn = nn;
+	timer_setup(&priv->rx_filter_stats_timer,
+		    nfp_net_filter_stats_timer, 0);
 
 	ret = nfp_app_nic_vnic_alloc(app, nn, id);
 	if (ret)
diff --git a/drivers/net/ethernet/netronome/nfp/bpf/main.h b/drivers/net/ethernet/netronome/nfp/bpf/main.h
index 86edc0691a5f..bc604030ff6c 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/main.h
+++ b/drivers/net/ethernet/netronome/nfp/bpf/main.h
@@ -209,10 +209,11 @@ struct nfp_net_bpf_priv {
 	struct nfp_stat_pair rx_filter, rx_filter_prev;
 	unsigned long rx_filter_change;
 	struct timer_list rx_filter_stats_timer;
+	struct nfp_net *nn;
 	spinlock_t rx_filter_lock;
 };
 
 int nfp_net_bpf_offload(struct nfp_net *nn, struct tc_cls_bpf_offload *cls_bpf);
-void nfp_net_filter_stats_timer(unsigned long data);
+void nfp_net_filter_stats_timer(struct timer_list *t);
 
 #endif
diff --git a/drivers/net/ethernet/netronome/nfp/bpf/offload.c b/drivers/net/ethernet/netronome/nfp/bpf/offload.c
index fbca1ca1f39b..63c8f7847054 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/offload.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/offload.c
@@ -51,14 +51,13 @@
 #include "../nfp_net_ctrl.h"
 #include "../nfp_net.h"
 
-void nfp_net_filter_stats_timer(unsigned long data)
+void nfp_net_filter_stats_timer(struct timer_list *t)
 {
-	struct nfp_net *nn = (void *)data;
-	struct nfp_net_bpf_priv *priv;
+	struct nfp_net_bpf_priv *priv = from_timer(priv, t,
+						   rx_filter_stats_timer);
+	struct nfp_net *nn = priv->nn;
 	struct nfp_stat_pair latest;
 
-	priv = nn->app_priv;
-
 	spin_lock_bh(&priv->rx_filter_lock);
 
 	if (nn->dp.ctrl & NFP_NET_CFG_CTRL_BPF)
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 2c9109b09faf..eddf850a6a7f 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -177,9 +177,9 @@ static int nfp_net_reconfig_wait(struct nfp_net *nn, unsigned long deadline)
 	return timed_out ? -EIO : 0;
 }
 
-static void nfp_net_reconfig_timer(unsigned long data)
+static void nfp_net_reconfig_timer(struct timer_list *t)
 {
-	struct nfp_net *nn = (void *)data;
+	struct nfp_net *nn = from_timer(nn, t, reconfig_timer);
 
 	spin_lock_bh(&nn->reconfig_lock);
 
@@ -3537,8 +3537,7 @@ struct nfp_net *nfp_net_alloc(struct pci_dev *pdev, bool needs_netdev,
 	spin_lock_init(&nn->reconfig_lock);
 	spin_lock_init(&nn->link_status_lock);
 
-	setup_timer(&nn->reconfig_timer,
-		    nfp_net_reconfig_timer, (unsigned long)nn);
+	timer_setup(&nn->reconfig_timer, nfp_net_reconfig_timer, 0);
 
 	return nn;
 }
-- 
2.7.4


-- 
Kees Cook
Pixel Security
