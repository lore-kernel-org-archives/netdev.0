From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 01/13] nfp: add nfp_cppcore_pcie_unit() helper
Date: Fri, 19 May 2017 15:01:43 -0700
Message-ID: <20170519220155.27857-2-jakub.kicinski@netronome.com>
References: <20170519220155.27857-1-jakub.kicinski@netronome.com>
Cc: kubakici@wp.pl, oss-drivers@netronome.com,
        Simon Horman <simon.horman@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:32790 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932080AbdESWCW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 18:02:22 -0400
Received: by mail-pg0-f43.google.com with SMTP id u187so43649095pgb.0
        for <netdev@vger.kernel.org>; Fri, 19 May 2017 15:02:21 -0700 (PDT)
In-Reply-To: <20170519220155.27857-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <simon.horman@netronome.com>

Add nfp_cppcore_pcie_unit() helper to retrieve the PCIE unit of a CPP
handle and use the new helper as appropriate.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
Reviewed-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c    | 16 ++++------------
 drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cpp.h | 11 +++++++++++
 2 files changed, 15 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
index 8cb87cbe1120..16115973112c 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
@@ -190,15 +190,11 @@ nfp_net_find_port(struct nfp_eth_table *eth_tbl, unsigned int id)
 static unsigned int nfp_net_pf_get_num_ports(struct nfp_pf *pf)
 {
 	char name[256];
-	u16 interface;
-	int pcie_pf;
 	int err = 0;
 	u64 val;
 
-	interface = nfp_cpp_interface(pf->cpp);
-	pcie_pf = NFP_CPP_INTERFACE_UNIT_of(interface);
-
-	snprintf(name, sizeof(name), "nfd_cfg_pf%d_num_ports", pcie_pf);
+	snprintf(name, sizeof(name), "nfd_cfg_pf%u_num_ports",
+		 nfp_cppcore_pcie_unit(pf->cpp));
 
 	val = nfp_rtsym_read_le(pf->cpp, name, &err);
 	/* Default to one port */
@@ -241,13 +237,9 @@ static u8 __iomem *nfp_net_pf_map_ctrl_bar(struct nfp_pf *pf)
 	const struct nfp_rtsym *ctrl_sym;
 	u8 __iomem *ctrl_bar;
 	char pf_symbol[256];
-	u16 interface;
-	int pcie_pf;
-
-	interface = nfp_cpp_interface(pf->cpp);
-	pcie_pf = NFP_CPP_INTERFACE_UNIT_of(interface);
 
-	snprintf(pf_symbol, sizeof(pf_symbol), "_pf%d_net_bar0", pcie_pf);
+	snprintf(pf_symbol, sizeof(pf_symbol), "_pf%u_net_bar0",
+		 nfp_cppcore_pcie_unit(pf->cpp));
 
 	ctrl_sym = nfp_rtsym_lookup(pf->cpp, pf_symbol);
 	if (!ctrl_sym) {
diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cpp.h b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cpp.h
index edecc0a27485..154b0b594184 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cpp.h
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cpp.h
@@ -289,6 +289,17 @@ int nfp_cpp_mutex_lock(struct nfp_cpp_mutex *mutex);
 int nfp_cpp_mutex_unlock(struct nfp_cpp_mutex *mutex);
 int nfp_cpp_mutex_trylock(struct nfp_cpp_mutex *mutex);
 
+/**
+ * nfp_cppcore_pcie_unit() - Get PCI Unit of a CPP handle
+ * @cpp:	CPP handle
+ *
+ * Return: PCI unit for the NFP CPP handle
+ */
+static inline u8 nfp_cppcore_pcie_unit(struct nfp_cpp *cpp)
+{
+	return NFP_CPP_INTERFACE_UNIT_of(nfp_cpp_interface(cpp));
+}
+
 struct nfp_cpp_explicit;
 
 struct nfp_cpp_explicit_command {
-- 
2.11.0
