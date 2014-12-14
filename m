From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net] net: Disallow providing non zero VLAN ID for NIC drivers FDB add flow
Date: Sun, 14 Dec 2014 18:19:05 +0200
Message-ID: <1418573945-27840-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, jiri@resnulli.us,
	gospo@cumulusnetworks.com, jhs@mojatatu.com,
	john.r.fastabend@intel.com, Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:35825 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750824AbaLNQTN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 Dec 2014 11:19:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current implementations all use dev_uc_add_excl() and such whose API
doesn't support vlans, so we can't make it with NICs HW for now.

Fixes: f6f6424ba773 ('net: make vid as a parameter for ndo_fdb_add/ndo_fdb_del')
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c |    5 +++++
 net/core/rtnetlink.c                        |    5 +++++
 2 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 0a7ea4c..a5f2660 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -7549,6 +7549,11 @@ static int i40e_ndo_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 	if (!(pf->flags & I40E_FLAG_SRIOV_ENABLED))
 		return -EOPNOTSUPP;
 
+	if (vid) {
+		pr_info("%s: vlans aren't supported yet for dev_uc|mc_add()\n", dev->name);
+		return -EINVAL;
+	}
+
 	/* Hardware does not support aging addresses so if a
 	 * ndm_state is given only allow permanent addresses
 	 */
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index d06107d..9cf6fe9 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2368,6 +2368,11 @@ int ndo_dflt_fdb_add(struct ndmsg *ndm,
 		return err;
 	}
 
+	if (vid) {
+		pr_info("%s: vlans aren't supported yet for dev_uc|mc_add()\n", dev->name);
+		return err;
+	}
+
 	if (is_unicast_ether_addr(addr) || is_link_local_ether_addr(addr))
 		err = dev_uc_add_excl(dev, addr);
 	else if (is_multicast_ether_addr(addr))
-- 
1.7.1
