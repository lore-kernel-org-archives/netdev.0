From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Subject: [PATCH] iwlwifi: mvm: Fix a memory leak in an error handling path in 'iwl_mvm_sar_get_wgds_table()'
Date: Wed, 12 Jul 2017 07:17:38 +0200
Message-ID: <20170712051738.21646-1-christophe.jaillet@wanadoo.fr>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
        Christophe JAILLET <christophe.jaillet@wanadoo.fr>
To: johannes.berg@intel.com, emmanuel.grumbach@intel.com,
        luciano.coelho@intel.com, linuxwifi@intel.com,
        kvalo@codeaurora.org, sara.sharon@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We should free 'wgds.pointer' here as done a few lines above in another
error handling path.
It was allocated within 'acpi_evaluate_object()'.

Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
---
A comment in '/drivers/acpi/acpica/utalloc.c' states that:
/* [...] Note: The caller should use acpi_os_free to free this
 * buffer created via ACPI_ALLOCATE_BUFFER.
 */

So, at the end of this function:
	out_free:
		kfree(wgds.pointer);
should maybe be:
	out_free:
		acpi_os_free(wgds.pointer);

If correct, several places should be fixed accordingly.
---
 drivers/net/wireless/intel/iwlwifi/mvm/fw.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/intel/iwlwifi/mvm/fw.c b/drivers/net/wireless/intel/iwlwifi/mvm/fw.c
index 24cc406d87ef..56d535ab696f 100644
--- a/drivers/net/wireless/intel/iwlwifi/mvm/fw.c
+++ b/drivers/net/wireless/intel/iwlwifi/mvm/fw.c
@@ -1287,8 +1287,10 @@ static int iwl_mvm_sar_get_wgds_table(struct iwl_mvm *mvm,
 
 		entry = &wifi_pkg->package.elements[i + 1];
 		if ((entry->type != ACPI_TYPE_INTEGER) ||
-		    (entry->integer.value > U8_MAX))
-			return -EINVAL;
+		    (entry->integer.value > U8_MAX)) {
+			ret = -EINVAL;
+			goto out_free;
+		}
 
 		geo_table->values[i] = entry->integer.value;
 	}
-- 
2.11.0
