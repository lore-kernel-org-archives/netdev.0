From: Luca Coelho <luca@coelho.fi>
Subject: [PATCH] iwlwifi: pcie: fix SPLC structure parsing
Date: Thu, 13 Oct 2016 13:21:55 +0300
Message-ID: <20161013102155.14547-1-luca@coelho.fi>
References: <1476349269.3880.18.camel@coelho.fi>
Cc: linuxwifi@intel.com, emmanuel.grumbach@intel.com,
        johannes@sipsolutions.net, kvalo@codeaurora.org,
        oren.givon@intel.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: linux-wireless@vger.kernel.org, chris@rorvick.com,
        pebolle@tiscali.nl
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1476349269.3880.18.camel@coelho.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Luca Coelho <luciano.coelho@intel.com>

The SPLC data parsing is too restrictive and was not trying find the
correct element for WiFi.  This causes problems with some BIOSes where
the SPLC method exists, but doesn't have a WiFi entry on the first
element of the list.  The domain type values are also incorrect
according to the specification.

Fix this by complying with the actual specification.

Additionally, replace all occurrences of SPLX to SPLC, since SPLX is
only a structure internal to the ACPI tables, and may not even exist.

Fixes: bcb079a14d75 ("iwlwifi: pcie: retrieve and parse ACPI power limitations")
Reported-by: Chris Rorvick <chris@rorvick.com>
Signed-off-by: Luca Coelho <luciano.coelho@intel.com>
---

Paul, Chris,

Could you please give this a spin? I have tested it with some handmade
ACPI tables in QEMU and it seems to work fine now.

Thanks!


drivers/net/wireless/intel/iwlwifi/pcie/drv.c | 79 ++++++++++++++++-----------
 1 file changed, 48 insertions(+), 31 deletions(-)

diff --git a/drivers/net/wireless/intel/iwlwifi/pcie/drv.c b/drivers/net/wireless/intel/iwlwifi/pcie/drv.c
index 001be40..da4810f 100644
--- a/drivers/net/wireless/intel/iwlwifi/pcie/drv.c
+++ b/drivers/net/wireless/intel/iwlwifi/pcie/drv.c
@@ -541,48 +541,64 @@ static const struct pci_device_id iwl_hw_card_ids[] = {
 MODULE_DEVICE_TABLE(pci, iwl_hw_card_ids);
 
 #ifdef CONFIG_ACPI
-#define SPL_METHOD		"SPLC"
-#define SPL_DOMAINTYPE_MODULE	BIT(0)
-#define SPL_DOMAINTYPE_WIFI	BIT(1)
-#define SPL_DOMAINTYPE_WIGIG	BIT(2)
-#define SPL_DOMAINTYPE_RFEM	BIT(3)
+#define ACPI_SPLC_METHOD	"SPLC"
+#define ACPI_SPLC_DOMAIN_WIFI	(0x07)
 
-static u64 splx_get_pwr_limit(struct iwl_trans *trans, union acpi_object *splx)
+static u64 splc_get_pwr_limit(struct iwl_trans *trans, union acpi_object *splc)
 {
-	union acpi_object *limits, *domain_type, *power_limit;
-
-	if (splx->type != ACPI_TYPE_PACKAGE ||
-	    splx->package.count != 2 ||
-	    splx->package.elements[0].type != ACPI_TYPE_INTEGER ||
-	    splx->package.elements[0].integer.value != 0) {
-		IWL_ERR(trans, "Unsupported splx structure\n");
+	union acpi_object *data_pkg, *dflt_pwr_limit;
+	int i;
+
+	/* We need at least two elemets, one for the revision and one
+	 * for the data itself.  Also check that the revision is
+	 * supported (currently only revision 0).
+	*/
+	if (splc->type != ACPI_TYPE_PACKAGE ||
+	    splc->package.count < 2 ||
+	    splc->package.elements[0].type != ACPI_TYPE_INTEGER ||
+	    splc->package.elements[0].integer.value != 0) {
+		IWL_DEBUG_INFO(trans,
+			       "Unsupported structure returned by the SPLC method.  Ignoring.\n");
 		return 0;
 	}
 
-	limits = &splx->package.elements[1];
-	if (limits->type != ACPI_TYPE_PACKAGE ||
-	    limits->package.count < 2 ||
-	    limits->package.elements[0].type != ACPI_TYPE_INTEGER ||
-	    limits->package.elements[1].type != ACPI_TYPE_INTEGER) {
-		IWL_ERR(trans, "Invalid limits element\n");
-		return 0;
+	/* loop through all the packages to find the one for WiFi */
+	for (i = 1; i < splc->package.count; i++) {
+		union acpi_object *domain;
+
+		data_pkg = &splc->package.elements[i];
+
+		/* Skip anything that is not a package with the right
+		 * amount of elements (i.e. at least 2 integers).
+		 */
+		if (data_pkg->type != ACPI_TYPE_PACKAGE ||
+		    data_pkg->package.count < 2 ||
+		    data_pkg->package.elements[0].type != ACPI_TYPE_INTEGER ||
+		    data_pkg->package.elements[1].type != ACPI_TYPE_INTEGER)
+			continue;
+
+		domain = &data_pkg->package.elements[0];
+		if (domain->integer.value == ACPI_SPLC_DOMAIN_WIFI)
+			break;
+
+		data_pkg = NULL;
 	}
 
-	domain_type = &limits->package.elements[0];
-	power_limit = &limits->package.elements[1];
-	if (!(domain_type->integer.value & SPL_DOMAINTYPE_WIFI)) {
-		IWL_DEBUG_INFO(trans, "WiFi power is not limited\n");
+	if (!data_pkg) {
+		IWL_DEBUG_INFO(trans,
+			       "No element for the WiFi domain returned by the SPLC method.\n");
 		return 0;
 	}
 
-	return power_limit->integer.value;
+	dflt_pwr_limit = &data_pkg->package.elements[1];
+	return dflt_pwr_limit->integer.value;
 }
 
 static void set_dflt_pwr_limit(struct iwl_trans *trans, struct pci_dev *pdev)
 {
 	acpi_handle pxsx_handle;
 	acpi_handle handle;
-	struct acpi_buffer splx = {ACPI_ALLOCATE_BUFFER, NULL};
+	struct acpi_buffer splc = {ACPI_ALLOCATE_BUFFER, NULL};
 	acpi_status status;
 
 	pxsx_handle = ACPI_HANDLE(&pdev->dev);
@@ -593,23 +609,24 @@ static void set_dflt_pwr_limit(struct iwl_trans *trans, struct pci_dev *pdev)
 	}
 
 	/* Get the method's handle */
-	status = acpi_get_handle(pxsx_handle, (acpi_string)SPL_METHOD, &handle);
+	status = acpi_get_handle(pxsx_handle, (acpi_string)ACPI_SPLC_METHOD,
+				 &handle);
 	if (ACPI_FAILURE(status)) {
-		IWL_DEBUG_INFO(trans, "SPL method not found\n");
+		IWL_DEBUG_INFO(trans, "SPLC method not found\n");
 		return;
 	}
 
 	/* Call SPLC with no arguments */
-	status = acpi_evaluate_object(handle, NULL, NULL, &splx);
+	status = acpi_evaluate_object(handle, NULL, NULL, &splc);
 	if (ACPI_FAILURE(status)) {
 		IWL_ERR(trans, "SPLC invocation failed (0x%x)\n", status);
 		return;
 	}
 
-	trans->dflt_pwr_limit = splx_get_pwr_limit(trans, splx.pointer);
+	trans->dflt_pwr_limit = splc_get_pwr_limit(trans, splc.pointer);
 	IWL_DEBUG_INFO(trans, "Default power limit set to %lld\n",
 		       trans->dflt_pwr_limit);
-	kfree(splx.pointer);
+	kfree(splc.pointer);
 }
 
 #else /* CONFIG_ACPI */
-- 
2.9.3
