From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next v3 11/16] sfc: Add ndo_get_vf_config() function for
 EF10
Date: Wed, 20 May 2015 11:11:18 +0100
Message-ID: <555C5DC6.9020602@solarflare.com>
References: <555C5C91.4000004@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:3428 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752908AbbETKLY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 06:11:24 -0400
In-Reply-To: <555C5C91.4000004@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rtnetlink calls ndo_get_vf_config when compiling information
about a network interface, so that the VFs associated with a PF
can be listed (eg: ip link show).
Implement a response to this entry point and return PF-set MAC
address for VF in ndo_get_vf_config

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10_sriov.c | 24 ++++++++++++++++++++++++
 drivers/net/ethernet/sfc/ef10_sriov.h |  7 ++-----
 2 files changed, 26 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10_sriov.c b/drivers/net/ethernet/sfc/ef10_sriov.c
index 42a3b16..d9c2ea4 100644
--- a/drivers/net/ethernet/sfc/ef10_sriov.c
+++ b/drivers/net/ethernet/sfc/ef10_sriov.c
@@ -521,3 +521,27 @@ fail:
 	memset(vf->mac, 0, ETH_ALEN);
 	return rc;
 }
+
+int efx_ef10_sriov_get_vf_config(struct efx_nic *efx, int vf_i,
+				 struct ifla_vf_info *ivf)
+{
+	struct efx_ef10_nic_data *nic_data = efx->nic_data;
+	struct ef10_vf *vf;
+
+	if (vf_i >= efx->vf_count)
+		return -EINVAL;
+
+	if (!nic_data->vf)
+		return -EOPNOTSUPP;
+
+	vf = nic_data->vf + vf_i;
+
+	ivf->vf = vf_i;
+	ivf->min_tx_rate = 0;
+	ivf->max_tx_rate = 0;
+	ether_addr_copy(ivf->mac, vf->mac);
+	ivf->vlan = 0;
+	ivf->qos = 0;
+
+	return 0;
+}
diff --git a/drivers/net/ethernet/sfc/ef10_sriov.h b/drivers/net/ethernet/sfc/ef10_sriov.h
index 7f12942..8c92a8d 100644
--- a/drivers/net/ethernet/sfc/ef10_sriov.h
+++ b/drivers/net/ethernet/sfc/ef10_sriov.h
@@ -55,11 +55,8 @@ static inline int efx_ef10_sriov_set_vf_spoofchk(struct efx_nic *efx, int vf,
 	return -EOPNOTSUPP;
 }
 
-static inline int efx_ef10_sriov_get_vf_config(struct efx_nic *efx, int vf,
-					       struct ifla_vf_info *ivf)
-{
-	return -EOPNOTSUPP;
-}
+int efx_ef10_sriov_get_vf_config(struct efx_nic *efx, int vf_i,
+				 struct ifla_vf_info *ivf);
 
 int efx_ef10_vswitching_probe_pf(struct efx_nic *efx);
 int efx_ef10_vswitching_probe_vf(struct efx_nic *efx);
