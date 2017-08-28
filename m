From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/15] i40e: force VMDQ device name truncation
Date: Sun, 27 Aug 2017 17:15:54 -0700
Message-ID: <20170828001603.75876-7-jeffrey.t.kirsher@intel.com>
References: <20170828001603.75876-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:55214 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751663AbdH1AQT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 27 Aug 2017 20:16:19 -0400
In-Reply-To: <20170828001603.75876-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

In new versions of GCC since 7.x a new warning exists which warns when
a string is truncated before all of the format can be completed.

When we setup VMDQ netdev names we are copying a pre-existing interface
name which could be up to 15 characters in length. Since we also add
4 bytes, v, the literal %, the d and a \0 null, we would overrun the
available size unless snprintf truncated for us.

The snprintf call will of course truncate on the end, so lets instead
modify the code to force truncation of the copied netdev name by
4 characters, to create enough space for the 4 bytes we're adding.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index b0ccd3c2eec6..3a6a752c6c58 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -9690,8 +9690,13 @@ static int i40e_config_netdev(struct i40e_vsi *vsi)
 		i40e_add_mac_filter(vsi, mac_addr);
 		spin_unlock_bh(&vsi->mac_filter_hash_lock);
 	} else {
-		/* relate the VSI_VMDQ name to the VSI_MAIN name */
-		snprintf(netdev->name, IFNAMSIZ, "%sv%%d",
+		/* Relate the VSI_VMDQ name to the VSI_MAIN name. Note that we
+		 * are still limited by IFNAMSIZ, but we're adding 'v%d\0' to
+		 * the end, which is 4 bytes long, so force truncation of the
+		 * original name by IFNAMSIZ - 4
+		 */
+		snprintf(netdev->name, IFNAMSIZ, "%.*sv%%d",
+			 IFNAMSIZ - 4,
 			 pf->vsi[pf->lan_vsi]->netdev->name);
 		random_ether_addr(mac_addr);
 
-- 
2.14.1
