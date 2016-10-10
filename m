From: Chris Rorvick <chris@rorvick.com>
Subject: [PATCH] iwlwifi: pcie: reduce "unsupported splx" to a warning
Date: Mon, 10 Oct 2016 02:19:43 -0500
Message-ID: <20161010071943.4717-1-chris@rorvick.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Chris Rorvick <chris@rorvick.com>
To: Intel Linux Wireless <linuxwifi@intel.com>,
        Luca Coelho <luciano.coelho@intel.com>,
        Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
        Johannes Berg <johannes.berg@intel.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        Oren Givon <oren.givon@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit bcb079a14d75 ("iwlwifi: pcie: retrieve and parse ACPI power
limitations") looks for a specific structure in the ACPI tables for
setting the default power limit.  The data returned for at least some
dual band chipsets is not recognized, though.  For example, the AC 8260
reports the following:

        Name (SPLX, Package (0x04)
        {
            Zero,
            Package (0x03)
            {
                0,
                1200,
                1000
            },
            Package (0x03)
            {
                0,
                1200,
                1000
            },
            Package (0x03)
            {
                0,
                1200,
                1000
            }
        })

The current logic expects exactly two elements in the outer package,
causing the above to be ignored and the power limit unset.

Despite the interface being fully functional after initialization, the
above condition is reported as an error.  Knock the message down to a
warning and provide better context for understanding its consequence.

Signed-off-by: Chris Rorvick <chris@rorvick.com>
---
 drivers/net/wireless/intel/iwlwifi/pcie/drv.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/intel/iwlwifi/pcie/drv.c b/drivers/net/wireless/intel/iwlwifi/pcie/drv.c
index 78cf9a7..19b531f 100644
--- a/drivers/net/wireless/intel/iwlwifi/pcie/drv.c
+++ b/drivers/net/wireless/intel/iwlwifi/pcie/drv.c
@@ -540,7 +540,7 @@ static u64 splx_get_pwr_limit(struct iwl_trans *trans, union acpi_object *splx)
 	    splx->package.count != 2 ||
 	    splx->package.elements[0].type != ACPI_TYPE_INTEGER ||
 	    splx->package.elements[0].integer.value != 0) {
-		IWL_ERR(trans, "Unsupported splx structure\n");
+		IWL_WARN(trans, "Unsupported splx structure, not limiting WiFi power\n");
 		return 0;
 	}
 
-- 
2.10.1
