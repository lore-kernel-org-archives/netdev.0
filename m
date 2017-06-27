From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 02/14] nfp: move area mapping helper into nfpcore
Date: Tue, 27 Jun 2017 00:50:16 -0700
Message-ID: <20170627075028.4009-3-jakub.kicinski@netronome.com>
References: <20170627075028.4009-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:36608 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752343AbdF0HvI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 03:51:08 -0400
Received: by mail-pg0-f45.google.com with SMTP id u62so11961262pgb.3
        for <netdev@vger.kernel.org>; Tue, 27 Jun 2017 00:51:08 -0700 (PDT)
In-Reply-To: <20170627075028.4009-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

nfp_net_map_area() is a helper for mapping areas of NFP memory
defined in nfp_net_main.c.  Move it to nfpcore to allow reuse
and rename accordingly.  Create an additional helper -
nfp_cpp_area_alloc_acquire() the opposite of already existing
nfp_cpp_area_release_free().

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c  | 56 +---------------------
 .../net/ethernet/netronome/nfp/nfpcore/nfp_cpp.h   |  7 +++
 .../ethernet/netronome/nfp/nfpcore/nfp_cppcore.c   | 35 ++++++++++++++
 .../ethernet/netronome/nfp/nfpcore/nfp_cpplib.c    | 40 ++++++++++++++++
 4 files changed, 84 insertions(+), 54 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
index 3169400dd474..16ee904db0cd 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
@@ -81,58 +81,6 @@ static int nfp_is_ready(struct nfp_pf *pf)
 }
 
 /**
- * nfp_net_map_area() - Help function to map an area
- * @cpp:    NFP CPP handler
- * @name:   Name for the area
- * @target: CPP target
- * @addr:   CPP address
- * @size:   Size of the area
- * @area:   Area handle (returned).
- *
- * This function is primarily to simplify the code in the main probe
- * function. To undo the effect of this functions call
- * @nfp_cpp_area_release_free(*area);
- *
- * Return: Pointer to memory mapped area or ERR_PTR
- */
-static u8 __iomem *nfp_net_map_area(struct nfp_cpp *cpp,
-				    const char *name, int isl, int target,
-				    unsigned long long addr, unsigned long size,
-				    struct nfp_cpp_area **area)
-{
-	u8 __iomem *res;
-	u32 dest;
-	int err;
-
-	dest = NFP_CPP_ISLAND_ID(target, NFP_CPP_ACTION_RW, 0, isl);
-
-	*area = nfp_cpp_area_alloc_with_name(cpp, dest, name, addr, size);
-	if (!*area) {
-		err = -EIO;
-		goto err_area;
-	}
-
-	err = nfp_cpp_area_acquire(*area);
-	if (err < 0)
-		goto err_acquire;
-
-	res = nfp_cpp_area_iomem(*area);
-	if (!res) {
-		err = -EIO;
-		goto err_map;
-	}
-
-	return res;
-
-err_map:
-	nfp_cpp_area_release(*area);
-err_acquire:
-	nfp_cpp_area_free(*area);
-err_area:
-	return (u8 __iomem *)ERR_PTR(err);
-}
-
-/**
  * nfp_net_get_mac_addr() - Get the MAC address.
  * @pf:       NFP PF handle
  * @port:     NFP port structure
@@ -242,7 +190,7 @@ nfp_net_pf_map_rtsym(struct nfp_pf *pf, const char *name, const char *sym_fmt,
 		return (u8 __iomem *)ERR_PTR(-EINVAL);
 	}
 
-	mem = nfp_net_map_area(pf->cpp, name, sym->domain, sym->target,
+	mem = nfp_cpp_map_area(pf->cpp, name, sym->domain, sym->target,
 			       sym->addr, sym->size, area);
 	if (IS_ERR(mem)) {
 		nfp_err(pf->cpp, "Failed to map PF symbol %s: %ld\n",
@@ -617,7 +565,7 @@ static int nfp_net_pci_map_mem(struct nfp_pf *pf)
 		pf->vf_cfg_mem = NULL;
 	}
 
-	mem = nfp_net_map_area(pf->cpp, "net.qc", 0, 0,
+	mem = nfp_cpp_map_area(pf->cpp, "net.qc", 0, 0,
 			       NFP_PCIE_QUEUE(0), NFP_QCP_QUEUE_AREA_SZ,
 			       &pf->qc_area);
 	if (IS_ERR(mem)) {
diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cpp.h b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cpp.h
index 25a967158ce9..235dd023d9b9 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cpp.h
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cpp.h
@@ -230,6 +230,9 @@ struct nfp_cpp_area *nfp_cpp_area_alloc_with_name(struct nfp_cpp *cpp,
 struct nfp_cpp_area *nfp_cpp_area_alloc(struct nfp_cpp *cpp, u32 cpp_id,
 					unsigned long long address,
 					unsigned long size);
+struct nfp_cpp_area *
+nfp_cpp_area_alloc_acquire(struct nfp_cpp *cpp, const char *name, u32 cpp_id,
+			   unsigned long long address, unsigned long size);
 void nfp_cpp_area_free(struct nfp_cpp_area *area);
 int nfp_cpp_area_acquire(struct nfp_cpp_area *area);
 int nfp_cpp_area_acquire_nonblocking(struct nfp_cpp_area *area);
@@ -278,6 +281,10 @@ int nfp_cpp_readq(struct nfp_cpp *cpp, u32 cpp_id,
 int nfp_cpp_writeq(struct nfp_cpp *cpp, u32 cpp_id,
 		   unsigned long long address, u64 value);
 
+u8 __iomem *
+nfp_cpp_map_area(struct nfp_cpp *cpp, const char *name, int domain, int target,
+		 u64 addr, unsigned long size, struct nfp_cpp_area **area);
+
 struct nfp_cpp_mutex;
 
 int nfp_cpp_mutex_init(struct nfp_cpp *cpp, int target,
diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cppcore.c b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cppcore.c
index 9b69dcf87be9..7d5d7293efed 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cppcore.c
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cppcore.c
@@ -361,6 +361,41 @@ nfp_cpp_area_alloc(struct nfp_cpp *cpp, u32 dest,
 }
 
 /**
+ * nfp_cpp_area_alloc_acquire() - allocate a new CPP area and lock it down
+ * @cpp:	CPP handle
+ * @name:	Name of region
+ * @dest:	CPP id
+ * @address:	Start address on CPP target
+ * @size:	Size of area
+ *
+ * Allocate and initialize a CPP area structure, and lock it down so
+ * that it can be accessed directly.
+ *
+ * NOTE: @address and @size must be 32-bit aligned values.
+ *
+ * NOTE: The area must also be 'released' when the structure is freed.
+ *
+ * Return: NFP CPP Area handle, or NULL
+ */
+struct nfp_cpp_area *
+nfp_cpp_area_alloc_acquire(struct nfp_cpp *cpp, const char *name, u32 dest,
+			   unsigned long long address, unsigned long size)
+{
+	struct nfp_cpp_area *area;
+
+	area = nfp_cpp_area_alloc_with_name(cpp, dest, name, address, size);
+	if (!area)
+		return NULL;
+
+	if (nfp_cpp_area_acquire(area)) {
+		nfp_cpp_area_free(area);
+		return NULL;
+	}
+
+	return area;
+}
+
+/**
  * nfp_cpp_area_free() - free up the CPP area
  * @area:	CPP area handle
  *
diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cpplib.c b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cpplib.c
index 0ba0379b8f75..ab86bceb93f2 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cpplib.c
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cpplib.c
@@ -279,3 +279,43 @@ int nfp_cpp_explicit_write(struct nfp_cpp *cpp, u32 cpp_id, u64 addr,
 
 	return err;
 }
+
+/**
+ * nfp_cpp_map_area() - Helper function to map an area
+ * @cpp:    NFP CPP handler
+ * @name:   Name for the area
+ * @domain: CPP domain
+ * @target: CPP target
+ * @addr:   CPP address
+ * @size:   Size of the area
+ * @area:   Area handle (output)
+ *
+ * Map an area of IOMEM access.  To undo the effect of this function call
+ * @nfp_cpp_area_release_free(*area).
+ *
+ * Return: Pointer to memory mapped area or ERR_PTR
+ */
+u8 __iomem *
+nfp_cpp_map_area(struct nfp_cpp *cpp, const char *name, int domain, int target,
+		 u64 addr, unsigned long size, struct nfp_cpp_area **area)
+{
+	u8 __iomem *res;
+	u32 dest;
+
+	dest = NFP_CPP_ISLAND_ID(target, NFP_CPP_ACTION_RW, 0, domain);
+
+	*area = nfp_cpp_area_alloc_acquire(cpp, name, dest, addr, size);
+	if (!*area)
+		goto err_eio;
+
+	res = nfp_cpp_area_iomem(*area);
+	if (!res)
+		goto err_release_free;
+
+	return res;
+
+err_release_free:
+	nfp_cpp_area_release_free(*area);
+err_eio:
+	return (u8 __iomem *)ERR_PTR(-EIO);
+}
-- 
2.11.0
