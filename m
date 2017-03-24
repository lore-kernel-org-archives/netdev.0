From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/10] i40e: restore default input set for each flow type
Date: Thu, 23 Mar 2017 22:14:25 -0700
Message-ID: <20170324051432.79216-4-jeffrey.t.kirsher@intel.com>
References: <20170324051432.79216-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:53066 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751601AbdCXFOi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 24 Mar 2017 01:14:38 -0400
In-Reply-To: <20170324051432.79216-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Ensure that the default input set is correctly reprogrammed when
cleaning up after disabling flow director support. This ensures that the
programmed value will be in a clean state.

Although we do not yet have support for SCTPv4 filters, a future patch
will add support for this protocol, so we will correctly restore the
SCTPv4 input set here as well. Note that strictly speaking the default
hardware value for SCTP includes matching the verification tag. However,
the ethtool API does not have support for specifying this value, so
there is no reason to keep the verification field enabled.

This patch is the next step on the way to enabling partial tuple filters
which will be implemented in a following patch.

Change-Id: Ic22e1c267ae37518bb036aca4a5694681449f283
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h      | 18 ++++++++++++++++++
 drivers/net/ethernet/intel/i40e/i40e_main.c | 19 +++++++++++++++++++
 2 files changed, 37 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 0cd21ea48e1d..95b1a1e7b906 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -753,6 +753,24 @@ static inline u64 i40e_read_fd_input_set(struct i40e_pf *pf, u16 addr)
 	return val;
 }
 
+/**
+ * i40e_write_fd_input_set - writes value into flow director input set register
+ * @pf: pointer to the PF struct
+ * @addr: register addr
+ * @val: value to be written
+ *
+ * This function writes specified value to the register specified by 'addr'.
+ * This register is input set register based on flow-type.
+ **/
+static inline void i40e_write_fd_input_set(struct i40e_pf *pf,
+					   u16 addr, u64 val)
+{
+	i40e_write_rx_ctl(&pf->hw, I40E_PRTQF_FD_INSET(addr, 1),
+			  (u32)(val >> 32));
+	i40e_write_rx_ctl(&pf->hw, I40E_PRTQF_FD_INSET(addr, 0),
+			  (u32)(val & 0xFFFFFFFFULL));
+}
+
 /* needed by i40e_ethtool.c */
 int i40e_up(struct i40e_vsi *vsi);
 void i40e_down(struct i40e_vsi *vsi);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index caccb8e97f1b..3fbecaa10286 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5759,6 +5759,25 @@ static void i40e_fdir_filter_exit(struct i40e_pf *pf)
 	pf->fd_tcp4_filter_cnt = 0;
 	pf->fd_udp4_filter_cnt = 0;
 	pf->fd_ip4_filter_cnt = 0;
+
+	/* Reprogram the default input set for TCP/IPv4 */
+	i40e_write_fd_input_set(pf, I40E_FILTER_PCTYPE_NONF_IPV4_TCP,
+				I40E_L3_SRC_MASK | I40E_L3_DST_MASK |
+				I40E_L4_SRC_MASK | I40E_L4_DST_MASK);
+
+	/* Reprogram the default input set for UDP/IPv4 */
+	i40e_write_fd_input_set(pf, I40E_FILTER_PCTYPE_NONF_IPV4_UDP,
+				I40E_L3_SRC_MASK | I40E_L3_DST_MASK |
+				I40E_L4_SRC_MASK | I40E_L4_DST_MASK);
+
+	/* Reprogram the default input set for SCTP/IPv4 */
+	i40e_write_fd_input_set(pf, I40E_FILTER_PCTYPE_NONF_IPV4_SCTP,
+				I40E_L3_SRC_MASK | I40E_L3_DST_MASK |
+				I40E_L4_SRC_MASK | I40E_L4_DST_MASK);
+
+	/* Reprogram the default input set for Other/IPv4 */
+	i40e_write_fd_input_set(pf, I40E_FILTER_PCTYPE_NONF_IPV4_OTHER,
+				I40E_L3_SRC_MASK | I40E_L3_DST_MASK);
 }
 
 /**
-- 
2.12.0
