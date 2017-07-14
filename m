From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Subject: [PATCH v2] iwlwifi: mvm: Fix a memory leak in an error handling path in 'iwl_mvm_sar_get_wgds_table()'
Date: Fri, 14 Jul 2017 12:06:59 +0200
Message-ID: <20170714100659.26369-1-christophe.jaillet@wanadoo.fr>
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
v2: rebase after 7fe90e0e3d60 ("iwlwifi: mvm: refactor geo init")


Moreovern a comment in '/drivers/acpi/acpica/utalloc.c' states that:
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
index 79e7a7a285dc..82863e9273eb 100644
--- a/drivers/net/wireless/intel/iwlwifi/mvm/fw.c
+++ b/drivers/net/wireless/intel/iwlwifi/mvm/fw.c
@@ -1275,8 +1275,10 @@ static int iwl_mvm_sar_get_wgds_table(struct iwl_mvm *mvm)
 
 			entry = &wifi_pkg->package.elements[idx++];
 			if ((entry->type != ACPI_TYPE_INTEGER) ||
-			    (entry->integer.value > U8_MAX))
-				return -EINVAL;
+			    (entry->integer.value > U8_MAX)) {
+				ret = -EINVAL;
+				goto out_free;
+			}
 
 			mvm->geo_profiles[i].values[j] = entry->integer.value;
 		}
-- 
2.11.0
