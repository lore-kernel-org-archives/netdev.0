From: Shannon Nelson <shannon.nelson@intel.com>
Subject: [PATCH 1/3] ixgbe: replace module options with configuration through
 request_firmware
Date: Thu, 10 Jan 2013 18:02:29 -0800
Message-ID: <20130111020226.15463.18498.stgit@starfish.jf.intel.com>
References: <20130111020046.15463.72333.stgit@starfish.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, dwmw2@infradead.org,
	jeffrey.t.kirsher@intel.com, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130111020046.15463.72333.stgit@starfish.jf.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace the use of module parameters with data read from an ASCII parameter
file found through the request_firmware() framework.

The parameter file is an ASCII data file with lines in the form of
     <label>  <option>=<val>[,<option>=<val>...]
where the <label> specifies the driver name and/or a specific configuration
line to use and the following options define that configuration.  Blank
lines are ignored, as are line comments that start with '#'.

The parameter file is tagged as MODULE_FIRMWARE to be sure it gets
included when pulling the driver into an initrd image.  The possible
config options are tagged using MODULE_INFO to be sure there is still
some discoverability in configuration options.

Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Cc: David Woodhouse <dwmw2@infradead.org>
---

 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |  229 ++++++++++++++++++++++---
 1 files changed, 203 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 20d6764..1670fc7 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -47,13 +47,16 @@
 #include <linux/if_bridge.h>
 #include <linux/prefetch.h>
 #include <scsi/fc/fc_fcoe.h>
+#include <linux/firmware.h>
+#include <linux/parser.h>
 
 #include "ixgbe.h"
 #include "ixgbe_common.h"
 #include "ixgbe_dcb_82599.h"
 #include "ixgbe_sriov.h"
 
-char ixgbe_driver_name[] = "ixgbe";
+#define IXGBE_DRIVER_NAME "ixgbe"
+char ixgbe_driver_name[] = IXGBE_DRIVER_NAME;
 static const char ixgbe_driver_string[] =
 			      "Intel(R) 10 Gigabit PCI Express Network Driver";
 #ifdef IXGBE_FCOE
@@ -127,28 +130,202 @@ static struct notifier_block dca_notifier = {
 };
 #endif
 
-#ifdef CONFIG_PCI_IOV
-static unsigned int max_vfs;
-module_param(max_vfs, uint, 0);
-MODULE_PARM_DESC(max_vfs,
-		 "Maximum number of virtual functions to allocate per physical function - default is zero and maximum value is 63");
-#endif /* CONFIG_PCI_IOV */
-
-static unsigned int allow_unsupported_sfp;
-module_param(allow_unsupported_sfp, uint, 0);
-MODULE_PARM_DESC(allow_unsupported_sfp,
-		 "Allow unsupported and untested SFP+ modules on 82599-based adapters");
-
 #define DEFAULT_MSG_ENABLE (NETIF_MSG_DRV|NETIF_MSG_PROBE|NETIF_MSG_LINK)
-static int debug = -1;
-module_param(debug, int, 0);
-MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
 
 MODULE_AUTHOR("Intel Corporation, <linux.nics@intel.com>");
 MODULE_DESCRIPTION("Intel(R) 10 Gigabit PCI Express Network Driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_VERSION);
 
+/*
+ * Firmware parameter processing
+ *
+ * This requests a parameter configuration file through the kernel
+ * firmware management service.  The parameter file is an ASCII data
+ * file with lines in the form of
+ *      <label>  <option>=<val>[,<option>=<val>...]
+ * where the <label> specifies a specific configuration to use
+ * and the following options define that configuration.  Blank lines
+ * are ignored, as are line comments that start with '#'.
+ *
+ * For this driver, we use the driver name as the label for the basic
+ * configuration, then use the port MAC address for port specific
+ * override configuration.
+ */
+#define IXGBE_FIRMWARE_FILE        IXGBE_DRIVER_NAME ".conf"
+MODULE_FIRMWARE(IXGBE_FIRMWARE_FILE);
+
+#define xstr(s) str(s)
+#define str(s)  #s
+
+enum {
+	Opt_debug,
+	Opt_allow_unsupported_sfp,
+#ifdef CONFIG_PCI_IOV
+	Opt_max_vfs,
+#endif
+};
+
+static const match_table_t tokens = {
+	{ Opt_debug, "debug=%u" },
+	{ Opt_allow_unsupported_sfp, "allow_unsupported_sfp" },
+#ifdef CONFIG_PCI_IOV
+	{ Opt_max_vfs, "max_vfs=%u" },
+#endif
+
+	/* terminator token */
+	{ 0, NULL },
+};
+MODULE_INFO(fw_option, "debug=N : Debug level (0=none,...,16=all)");
+MODULE_INFO(fw_option, "allow_unsupported_sfp : Allow unsupported and untested SFP+ modules on 82599-based adapters");
+MODULE_INFO(fw_option,
+	    "max_vfs=N : Maximum number of virtual functions per physical function (default=0) - 0 <= N < "
+	    xstr(IXGBE_MAX_VF_FUNCTIONS));
+
+/**
+ * ixgbe_parse_option_line - find ixgbe options
+ * @adapter: pointer to ixgbe_adapter
+ * @config_line: line of option information
+ * @line_len: length of the config line
+ *
+ **/
+static void ixgbe_parse_option_line(struct ixgbe_adapter *adapter,
+				    char *config_line, int line_len)
+{
+	char *p;
+	char *next_option = config_line;
+	substring_t args[MAX_OPT_ARGS];
+	int value;
+
+	if (!config_line)
+		return;
+
+	while ((p = strsep(&next_option, ", \t\n")) != NULL) {
+		int token;
+
+		if (((p - config_line) >= line_len) || *p == '\0' || *p == '#')
+			break;
+
+		/*
+		 * Initialize args struct so we know whether arg was
+		 * found; some options take optional arguments.
+		 */
+		args[0].to = args[0].from = NULL;
+		token = match_token(p, tokens, args);
+		switch (token) {
+
+		case Opt_debug:
+			if (match_int(args, &value))
+				goto parse_error;
+			adapter->msg_enable = netif_msg_init(value,
+							    DEFAULT_MSG_ENABLE);
+			break;
+
+		case Opt_allow_unsupported_sfp:
+			adapter->hw.allow_unsupported_sfp = true;
+			break;
+
+#ifdef CONFIG_PCI_IOV
+		case Opt_max_vfs:
+			if (match_int(args, &value))
+				goto parse_error;
+
+			if (adapter->hw.mac.type != ixgbe_mac_82598EB) {
+				if (value < IXGBE_MAX_VF_FUNCTIONS)
+					adapter->num_vfs = value;
+				else
+					goto parse_error;
+			}
+			break;
+
+#endif
+		default:
+			goto parse_error;
+			break;
+		}
+	}
+
+	return;
+
+parse_error:
+	e_dev_err("options error '%s'\n", p);
+	return;
+}
+
+/**
+ * ixgbe_find_config_line - scan config file for labeled option line
+ * @fw: pointer to firmware data
+ * @label: label to search for
+ *
+ * Returns pointer to the configuration options found, or NULL
+ **/
+static char *ixgbe_find_config_line(const struct firmware *fw,
+				    const char *label)
+{
+	const char *p = fw->data;
+	const char *p_end = fw->data + fw->size;
+	int label_len = strlen(label);
+
+	while (p < p_end) {
+		/* ignore spaces and line comments */
+		p = skip_spaces(p);
+		if (p >= p_end)
+			break;
+		if (*p == '#')
+			goto scan_to_eol;
+
+		/* find tag match? */
+		if (!strncmp(p, label, min_t(int, label_len, (p_end - p)))) {
+
+			/* skip over the tag to find the options */
+			p += label_len;
+			p = skip_spaces(p);
+			if (p >= p_end)
+				break;
+			if (*p != '#')
+				return (char *)p;
+		}
+
+scan_to_eol:
+		while (p < p_end && *p != '\n')
+			p++;
+		if (p < p_end && *p == '\n')
+			p++;
+	}
+
+	return NULL;
+}
+
+/**
+ * ixgbe_check_options - find and check configuration parameters
+ * @adapter: pointer to ixgbe_adapter
+ * @label: the configuration tag to search for
+ **/
+void ixgbe_check_options(struct ixgbe_adapter *adapter, const char *label)
+{
+	char *config_line;
+	char *line_end;
+	int line_len, remaining;
+	int ret;
+	const struct firmware *fw;
+
+	ret = request_firmware(&fw, IXGBE_FIRMWARE_FILE, &adapter->pdev->dev);
+	if (ret)
+		return;
+
+	config_line = ixgbe_find_config_line(fw, label);
+	if (config_line) {
+		remaining = fw->size - (config_line - (char *)fw->data);
+		line_end = strnchr(config_line, remaining, '\n');
+		if (line_end)
+			line_len = line_end - config_line;
+		else
+			line_len = remaining;
+		ixgbe_parse_option_line(adapter, config_line, line_len);
+	}
+	release_firmware(fw);
+}
+
 static void ixgbe_service_event_schedule(struct ixgbe_adapter *adapter)
 {
 	if (!test_bit(__IXGBE_DOWN, &adapter->state) &&
@@ -4572,12 +4749,6 @@ static int ixgbe_sw_init(struct ixgbe_adapter *adapter)
 	hw->fc.disable_fc_autoneg =
 		(ixgbe_device_supports_autoneg_fc(hw) == 0) ? false : true;
 
-#ifdef CONFIG_PCI_IOV
-	/* assign number of SR-IOV VFs */
-	if (hw->mac.type != ixgbe_mac_82598EB)
-		adapter->num_vfs = (max_vfs > 63) ? 0 : max_vfs;
-
-#endif
 	/* enable itr by default in dynamic mode */
 	adapter->rx_itr_setting = 1;
 	adapter->tx_itr_setting = 1;
@@ -7197,6 +7368,7 @@ static int ixgbe_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	u8 part_str[IXGBE_PBANUM_LENGTH];
 	unsigned int indices = num_possible_cpus();
 	unsigned int dcb_max = 0;
+	char mac_str[20];
 #ifdef IXGBE_FCOE
 	u16 device_caps;
 #endif
@@ -7279,7 +7451,7 @@ static int ixgbe_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	adapter->pdev = pdev;
 	hw = &adapter->hw;
 	hw->back = adapter;
-	adapter->msg_enable = netif_msg_init(debug, DEFAULT_MSG_ENABLE);
+	adapter->msg_enable = netif_msg_init(-1, DEFAULT_MSG_ENABLE);
 
 	hw->hw_addr = ioremap(pci_resource_start(pdev, 0),
 			      pci_resource_len(pdev, 0));
@@ -7324,6 +7496,9 @@ static int ixgbe_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (err)
 		goto err_sw_init;
 
+	/* look for generic options in userland config file */
+	ixgbe_check_options(adapter, ixgbe_driver_name);
+
 	/* Make it possible the adapter to be woken up via WOL */
 	switch (adapter->hw.mac.type) {
 	case ixgbe_mac_82599EB:
@@ -7344,12 +7519,14 @@ static int ixgbe_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 			e_crit(probe, "Fan has stopped, replace the adapter\n");
 	}
 
-	if (allow_unsupported_sfp)
-		hw->allow_unsupported_sfp = allow_unsupported_sfp;
-
 	/* reset_hw fills in the perm_addr as well */
 	hw->phy.reset_if_overtemp = true;
 	err = hw->mac.ops.reset_hw(hw);
+
+	/* look for mac specific options in userland config file */
+	snprintf(mac_str, sizeof(mac_str)-1, "%pM", adapter->hw.mac.addr);
+	ixgbe_check_options(adapter, mac_str);
+
 	hw->phy.reset_if_overtemp = false;
 	if (err == IXGBE_ERR_SFP_NOT_PRESENT &&
 	    hw->mac.type == ixgbe_mac_82598EB) {
