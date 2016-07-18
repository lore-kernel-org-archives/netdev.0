From: kan.liang@intel.com
Subject: [RFC PATCH 13/30] i40e/netpolicy: add three new net policies
Date: Sun, 17 Jul 2016 23:56:07 -0700
Message-ID: <1468824984-65318-14-git-send-email-kan.liang@intel.com>
References: <1468824984-65318-1-git-send-email-kan.liang@intel.com>
Cc: jeffrey.t.kirsher@intel.com, mingo@redhat.com,
	peterz@infradead.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	akpm@linux-foundation.org, keescook@chromium.org,
	viro@zeniv.linux.org.uk, gorcunov@openvz.org,
	john.stultz@linaro.org, aduyck@mirantis.com, ben@decadent.org.uk,
	decot@googlers.com, jesse.brandeburg@intel.com,
	andi@firstfloor.org, Kan Liang <kan.liang@intel.com>
To: davem@davemloft.net, linux-kernel@vger.kernel.org,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1468824984-65318-1-git-send-email-kan.liang@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kan Liang <kan.liang@intel.com>

Introduce three net policies for i40e driver.
CPU policy: configure for higher throughput and lower CPU%.
BULK policy: configure for highest throughput.
LATENCY policy: configure for lowest latency.

Lots of tests are done for net policy on platforms with Intel Xeon E5 V2
and XL710 40G NIC. The baseline test is with Linux 4.6.0 kernel.
Netperf is used to evaluate the throughput and latency performance for
these three net policies.
For "BULK" policy, the throughput performance is on average ~1.26X than
baseline.
For "CPU" policy, the throughput performance is on average ~1.20X than
baseline, and has lower CPU% (on average ~5% lower than "BULK" policy).
For "LATENCY" policy, the latency is on average 53.5% less than the
baseline.

Signed-off-by: Kan Liang <kan.liang@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 10 ++++++++++
 include/linux/netpolicy.h                   |  3 +++
 net/core/netpolicy.c                        |  5 ++++-
 3 files changed, 17 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 3336373..11b921b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -8961,12 +8961,22 @@ static netdev_features_t i40e_features_check(struct sk_buff *skb,
 }
 
 #ifdef CONFIG_NETPOLICY
+/* Interrupt moderation in microseconds */
+#define NET_POLICY_CPU_RX	125
+#define NET_POLICY_CPU_TX	250
+#define NET_POLICY_BULK_RX	50
+#define NET_POLICY_BULK_TX	125
+#define NET_POLICY_LATENCY_RX	5
+#define NET_POLICY_LATENCY_TX	10
 
 #define NET_POLICY_NOT_SUPPORT	-2
 #define NET_POLICY_END		-3
 static int policy_param[NET_POLICY_MAX + 1][2] = {
 	/* rx-usec, tx-usec */
 	{0, 0},
+	{NET_POLICY_CPU_RX, NET_POLICY_CPU_TX},		/* CPU policy */
+	{NET_POLICY_BULK_RX, NET_POLICY_BULK_TX},	/* BULK policy */
+	{NET_POLICY_LATENCY_RX, NET_POLICY_LATENCY_TX},	/* LATENCY policy */
 
 	{NET_POLICY_END, NET_POLICY_END},
 };
diff --git a/include/linux/netpolicy.h b/include/linux/netpolicy.h
index b1d9277..3d348a7 100644
--- a/include/linux/netpolicy.h
+++ b/include/linux/netpolicy.h
@@ -18,6 +18,9 @@
 
 enum netpolicy_name {
 	NET_POLICY_NONE		= 0,
+	NET_POLICY_CPU,
+	NET_POLICY_BULK,
+	NET_POLICY_LATENCY,
 	NET_POLICY_MAX,
 };
 
diff --git a/net/core/netpolicy.c b/net/core/netpolicy.c
index 8112839..71e9163 100644
--- a/net/core/netpolicy.c
+++ b/net/core/netpolicy.c
@@ -223,7 +223,10 @@ static int netpolicy_enable(struct net_device *dev)
 }
 
 const char *policy_name[NET_POLICY_MAX] = {
-	"NONE"
+	"NONE",
+	"CPU",
+	"BULK",
+	"LATENCY"
 };
 
 static u32 cpu_to_queue(struct net_device *dev,
-- 
2.5.5
