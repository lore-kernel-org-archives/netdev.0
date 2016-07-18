From: kan.liang@intel.com
Subject: [RFC PATCH 23/30] i40e/ethtool: support RX_CLS_LOC_ANY
Date: Sun, 17 Jul 2016 23:56:17 -0700
Message-ID: <1468824984-65318-24-git-send-email-kan.liang@intel.com>
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

The existing special location RX_CLS_LOC_ANY flag is designed for the
case which the caller does not know/care about the location. Now, this
flag is only handled in ethtool user space. If the kernel directly calls
the ETHTOOL_SRXCLSRLINS interface with RX_CLS_LOC_ANY flag set, it will
error out.
This patch implements the RX_CLS_LOC_ANY support for i40e driver. It
finds the available location from the end of the list.

Signed-off-by: Kan Liang <kan.liang@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 38 ++++++++++++++++++++++++--
 1 file changed, 35 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 1f3537e..4276ed7 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -2552,6 +2552,32 @@ static int i40e_del_fdir_entry(struct i40e_vsi *vsi,
 	return ret;
 }
 
+static int find_empty_slot(struct i40e_pf *pf)
+{
+	struct i40e_fdir_filter *rule;
+	struct hlist_node *node2;
+	__u32 data = i40e_get_fd_cnt_all(pf);
+	unsigned long *slot;
+	int i;
+
+	slot = kzalloc(BITS_TO_LONGS(data) * sizeof(long), GFP_KERNEL);
+	if (!slot)
+		return -ENOMEM;
+
+	hlist_for_each_entry_safe(rule, node2,
+				  &pf->fdir_filter_list, fdir_node) {
+		set_bit(rule->fd_id, slot);
+	}
+
+	for (i = data - 1; i > 0; i--) {
+		if (!test_bit(i, slot))
+			break;
+	}
+	kfree(slot);
+
+	return i;
+}
+
 /**
  * i40e_add_fdir_ethtool - Add/Remove Flow Director filters
  * @vsi: pointer to the targeted VSI
@@ -2588,9 +2614,15 @@ static int i40e_add_fdir_ethtool(struct i40e_vsi *vsi,
 
 	fsp = (struct ethtool_rx_flow_spec *)&cmd->fs;
 
-	if (fsp->location >= (pf->hw.func_caps.fd_filters_best_effort +
-			      pf->hw.func_caps.fd_filters_guaranteed)) {
-		return -EINVAL;
+	if (fsp->location != RX_CLS_LOC_ANY) {
+		if (fsp->location >= (pf->hw.func_caps.fd_filters_best_effort +
+				      pf->hw.func_caps.fd_filters_guaranteed)) {
+			return -EINVAL;
+		}
+	} else {
+		fsp->location = find_empty_slot(pf);
+		if (fsp->location < 0)
+			return -ENOSPC;
 	}
 
 	if ((fsp->ring_cookie != RX_CLS_FLOW_DISC) &&
-- 
2.5.5
