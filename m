From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] iwlwifi: mvm: fix iwl_mvm_sar_find_wifi_pkg corner case
Date: Tue, 27 Jun 2017 17:24:17 +0200
Message-ID: <20170627152458.1103403-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
        Intel Linux Wireless <linuxwifi@intel.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        Sara Sharon <sara.sharon@intel.com>,
        Golan Ben-Ami <golan.ben.ami@intel.com>,
        Liad Kaufman <liad.kaufman@intel.com>,
        Haim Dreyfuss <haim.dreyfuss@intel.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Johannes Berg <johannes.berg@intel.com>,
        Luca Coelho <luciano.coelho@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

gcc warns about what it thinks is an uninitialized variable
access:

drivers/net/wireless/intel/iwlwifi/mvm/fw.c: In function 'iwl_mvm_sar_find_wifi_pkg.isra.14':
drivers/net/wireless/intel/iwlwifi/mvm/fw.c:1102:5: error: 'wifi_pkg' may be used uninitialized in this function [-Werror=maybe-uninitialized]

That problem cannot really happen, as we check data->package.count
to ensure that the loop is entered at least once.
However, something that can indeed happen is returning an incorrect
wifi_pkg pointer in case none of the elements are what we are looking
for.

This modifies the loop again, to only return a correct object, and
to shut up that warning.

Fixes: c386dacb4ed6 ("iwlwifi: mvm: refactor SAR init to prepare for dynamic SAR")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/wireless/intel/iwlwifi/mvm/fw.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/wireless/intel/iwlwifi/mvm/fw.c b/drivers/net/wireless/intel/iwlwifi/mvm/fw.c
index 24cc406d87ef..730c7f68c0b3 100644
--- a/drivers/net/wireless/intel/iwlwifi/mvm/fw.c
+++ b/drivers/net/wireless/intel/iwlwifi/mvm/fw.c
@@ -1094,14 +1094,12 @@ static union acpi_object *iwl_mvm_sar_find_wifi_pkg(struct iwl_mvm *mvm,
 		domain = &wifi_pkg->package.elements[0];
 		if (domain->type == ACPI_TYPE_INTEGER &&
 		    domain->integer.value == ACPI_WIFI_DOMAIN)
-			break;
-
-		wifi_pkg = NULL;
+			goto found;
 	}
 
-	if (!wifi_pkg)
-		return ERR_PTR(-ENOENT);
+	return ERR_PTR(-ENOENT);
 
+found:
 	return wifi_pkg;
 }
 
-- 
2.9.0
