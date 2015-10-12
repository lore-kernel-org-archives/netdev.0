From: Sathya Perla <sathya.perla@avagotech.com>
Subject: [PATCH 5/5] be2net: remove vlan promisc capability from VF's profile descriptors
Date: Mon, 12 Oct 2015 03:47:21 -0400
Message-ID: <1444636041-4727-6-git-send-email-sathya.perla@avagotech.com>
References: <1444636041-4727-1-git-send-email-sathya.perla@avagotech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:50637 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752076AbbJLH51 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 03:57:27 -0400
In-Reply-To: <1444636041-4727-1-git-send-email-sathya.perla@avagotech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kalesh AP <kalesh.purayil@avagotech.com>

The commit 435452aa8847 ("Prevent VFs from enabling VLAN promiscuous mode")
fixed the PF driver to not include the VLAN promisc capability while
provisioning the interface for a VF. But the fix did not remove this
capability from the profile descriptor of the VF. This causes the VF
driver to request this capability when it tries to create it's interface
at probe time.  This could potentailly cause the VF probe to fail if the
FW enforces strict checking of the flags based on what was provisoned
by the PF.  This strict checking is not being done by FW currently but
will be fixed in a future version. This patch fixes this issue by updating
the VF's profile descriptor so that they match the interface capability
flags provisioned by the PF.

Fixes: 435452aa8847 ("Prevent VFs from enabling VLAN promiscuous mode")
Signed-off-by: Kalesh AP <kalesh.purayil@avagotech.com>
Signed-off-by: Sathya Perla <sathya.perla@avagotech.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 790284d..1795c93 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -1987,6 +1987,8 @@ int be_cmd_rx_filter(struct be_adapter *adapter, u32 flags, u32 value)
 			 be_if_cap_flags(adapter));
 	}
 	flags &= be_if_cap_flags(adapter);
+	if (!flags)
+		return -ENOTSUPP;
 
 	return __be_cmd_rx_filter(adapter, flags, value);
 }
@@ -3932,12 +3934,16 @@ static void be_fill_vf_res_template(struct be_adapter *adapter,
 			vf_if_cap_flags &= ~(BE_IF_FLAGS_RSS |
 					     BE_IF_FLAGS_DEFQ_RSS);
 		}
-
-		nic_vft->cap_flags = cpu_to_le32(vf_if_cap_flags);
 	} else {
 		num_vf_qs = 1;
 	}
 
+	if (res_mod.vf_if_cap_flags & BE_IF_FLAGS_VLAN_PROMISCUOUS) {
+		nic_vft->flags |= BIT(IF_CAPS_FLAGS_VALID_SHIFT);
+		vf_if_cap_flags &= ~BE_IF_FLAGS_VLAN_PROMISCUOUS;
+	}
+
+	nic_vft->cap_flags = cpu_to_le32(vf_if_cap_flags);
 	nic_vft->rq_count = cpu_to_le16(num_vf_qs);
 	nic_vft->txq_count = cpu_to_le16(num_vf_qs);
 	nic_vft->rssq_count = cpu_to_le16(num_vf_qs);
-- 
2.4.1
