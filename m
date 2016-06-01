From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH v2] qed: fix qed_fill_link() error handling
Date: Wed, 01 Jun 2016 15:29:13 +0200
Message-ID: <11393820.LSE4DkNrNd@wuerfel>
References: <1464623197-2084229-1-git-send-email-arnd@arndb.de> <8209894.K472MDjuEr@wuerfel> <CO2PR11MB00885CC1028BFEAD9CD85E8397470@CO2PR11MB0088.namprd11.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: David Miller <davem@davemloft.net>,
	Manish Chopra <manish.chopra@qlogic.com>,
	Sudarsana Kalluru <Sudarsana.Kalluru@qlogic.com>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Ariel Elior <Ariel.Elior@qlogic.com>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CO2PR11MB00885CC1028BFEAD9CD85E8397470@CO2PR11MB0088.namprd11.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

gcc warns about qed_fill_link possibly accessing uninitialized data:

drivers/net/ethernet/qlogic/qed/qed_main.c: In function 'qed_fill_link':
drivers/net/ethernet/qlogic/qed/qed_main.c:1170:35: error: 'link_caps' may be used uninitialized in this function [-Werror=maybe-uninitialized]

While this warning is only about the specific case of CONFIG_QED_SRIOV
being disabled but the function getting called for a VF (which should
never happen), another possibility is that qed_mcp_get_*() fails without
returning data.

This rearranges the code so we bail out in either of the two cases
and print a warning instead of accessing the uninitialized data.

The qed_link_output structure remains untouched in this case, but
all callers first call memset() on it, so at least we are not leaking
stack data then.

As discussed, we also use a compile-time check to ensure we never
use any of the VF code if CONFIG_QED_SRIOV is disabled, and the
PCI device table is updated to no longer bind to virtual functions
in that configuration.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>

---
On Wednesday, June 1, 2016 11:10:30 AM CEST Yuval Mintz wrote:
> Actually, I think VF probe should gracefully fail in that case,
> as qed_vf_hw_prepare() would simply return -EINVAL.
> But I can honestly say I've never tested this flow, and I agree there's
> no reason to allow VF probe in case we're not supporting SRIOV.

ok

> So I guess removing the PCI ID and defining IS_PF to be true in case
> CONFIG_QED_SRIOV isn't set is the right way to go.
> Do you want to revise your patch, or do you want me to do it?

I've done the patch below now, please either Ack or modify it the way
you like and forward it.

Thanks,

	Arnd

diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
index 753064679bde..61cc6869fa65 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_main.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
@@ -1105,6 +1105,39 @@ static int qed_get_port_type(u32 media_type)
 	return port_type;
 }
 
+static int qed_get_link_data(struct qed_hwfn *hwfn,
+			     struct qed_mcp_link_params *params,
+			     struct qed_mcp_link_state *link,
+			     struct qed_mcp_link_capabilities *link_caps)
+{
+	void *p;
+
+	if (!IS_PF(hwfn->cdev)) {
+		qed_vf_get_link_params(hwfn, params);
+		qed_vf_get_link_state(hwfn, link);
+		qed_vf_get_link_caps(hwfn, link_caps);
+
+		return 0;
+	}
+
+	p = qed_mcp_get_link_params(hwfn);
+	if (!p)
+		return -ENXIO;
+	memcpy(params, p, sizeof(*params));
+
+	p = qed_mcp_get_link_state(hwfn);
+	if (!p)
+		return -ENXIO;
+	memcpy(link, p, sizeof(*link));
+
+	p = qed_mcp_get_link_capabilities(hwfn);
+	if (!p)
+		return -ENXIO;
+	memcpy(link_caps, p, sizeof(*link_caps));
+
+	return 0;
+}
+
 static void qed_fill_link(struct qed_hwfn *hwfn,
 			  struct qed_link_output *if_link)
 {
@@ -1116,15 +1149,9 @@ static void qed_fill_link(struct qed_hwfn *hwfn,
 	memset(if_link, 0, sizeof(*if_link));
 
 	/* Prepare source inputs */
-	if (IS_PF(hwfn->cdev)) {
-		memcpy(&params, qed_mcp_get_link_params(hwfn), sizeof(params));
-		memcpy(&link, qed_mcp_get_link_state(hwfn), sizeof(link));
-		memcpy(&link_caps, qed_mcp_get_link_capabilities(hwfn),
-		       sizeof(link_caps));
-	} else {
-		qed_vf_get_link_params(hwfn, &params);
-		qed_vf_get_link_state(hwfn, &link);
-		qed_vf_get_link_caps(hwfn, &link_caps);
+	if (qed_get_link_data(hwfn, &params, &link, &link_caps)) {
+		dev_warn(&hwfn->cdev->pdev->dev, "no link data available\n");
+		return;
 	}
 
 	/* Set the link parameters to pass to protocol driver */
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.h b/drivers/net/ethernet/qlogic/qed/qed_sriov.h
index c8667c65e685..c90b2b6ad969 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sriov.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.h
@@ -12,11 +12,13 @@
 #include "qed_vf.h"
 #define QED_VF_ARRAY_LENGTH (3)
 
+#ifdef CONFIG_QED_SRIOV
 #define IS_VF(cdev)             ((cdev)->b_is_vf)
 #define IS_PF(cdev)             (!((cdev)->b_is_vf))
-#ifdef CONFIG_QED_SRIOV
 #define IS_PF_SRIOV(p_hwfn)     (!!((p_hwfn)->cdev->p_iov_info))
 #else
+#define IS_VF(cdev)             (0)
+#define IS_PF(cdev)             (1)
 #define IS_PF_SRIOV(p_hwfn)     (0)
 #endif
 #define IS_PF_SRIOV_ALLOC(p_hwfn)       (!!((p_hwfn)->pf_iov_info))
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index 5d00d1404bfc..5733d1888223 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -87,7 +87,9 @@ static const struct pci_device_id qede_pci_tbl[] = {
 	{PCI_VDEVICE(QLOGIC, PCI_DEVICE_ID_57980S_100), QEDE_PRIVATE_PF},
 	{PCI_VDEVICE(QLOGIC, PCI_DEVICE_ID_57980S_50), QEDE_PRIVATE_PF},
 	{PCI_VDEVICE(QLOGIC, PCI_DEVICE_ID_57980S_25), QEDE_PRIVATE_PF},
+#ifdef CONFIG_QED_SRIOV
 	{PCI_VDEVICE(QLOGIC, PCI_DEVICE_ID_57980S_IOV), QEDE_PRIVATE_VF},
+#endif
 	{ 0 }
 };
 
