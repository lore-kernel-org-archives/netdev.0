From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 02/15] nfp: fail graciously when someone tries to grab global lock
Date: Tue, 21 Mar 2017 17:59:08 -0700
Message-ID: <20170322005921.10965-3-jakub.kicinski@netronome.com>
References: <20170322005921.10965-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:34481 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758257AbdCVBHo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 21:07:44 -0400
Received: by mail-pf0-f177.google.com with SMTP id p189so63580503pfp.1
        for <netdev@vger.kernel.org>; Tue, 21 Mar 2017 18:07:43 -0700 (PDT)
In-Reply-To: <20170322005921.10965-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The global device lock is acquired to search the resource table.
The lock is actually itself part of the table (entry 0).
Therefore if someone asks for resource 0 we would deadlock since
double locking is no longer allowed.

Currently the driver doesn't try to lock that resource so let's
simply make sure we fail graciously and not add special handling
of this case until really need.  Hide the relevant defines in
the source file.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfpcore/nfp.h          |  9 +--------
 drivers/net/ethernet/netronome/nfp/nfpcore/nfp_resource.c | 15 ++++++++++++---
 2 files changed, 13 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp.h b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp.h
index 42cb720b696d..f7ca8e374923 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp.h
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp.h
@@ -66,14 +66,7 @@ int nfp_nsp_write_eth_table(struct nfp_nsp *state,
 
 /* Implemented in nfp_resource.c */
 
-#define NFP_RESOURCE_TBL_TARGET		NFP_CPP_TARGET_MU
-#define NFP_RESOURCE_TBL_BASE		0x8100000000ULL
-
-/* NFP Resource Table self-identifier */
-#define NFP_RESOURCE_TBL_NAME		"nfp.res"
-#define NFP_RESOURCE_TBL_KEY		0x00000000 /* Special key for entry 0 */
-
-/* All other keys are CRC32-POSIX of the 8-byte identification string */
+/* All keys are CRC32-POSIX of the 8-byte identification string */
 
 /* ARM/PCI vNIC Interfaces 0..3 */
 #define NFP_RESOURCE_VNIC_PCI_0		"vnic.p0"
diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_resource.c b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_resource.c
index a2850344f8b4..2d15a7c9d0de 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_resource.c
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_resource.c
@@ -45,6 +45,13 @@
 #include "nfp_cpp.h"
 #include "nfp6000/nfp6000.h"
 
+#define NFP_RESOURCE_TBL_TARGET		NFP_CPP_TARGET_MU
+#define NFP_RESOURCE_TBL_BASE		0x8100000000ULL
+
+/* NFP Resource Table self-identifier */
+#define NFP_RESOURCE_TBL_NAME		"nfp.res"
+#define NFP_RESOURCE_TBL_KEY		0x00000000 /* Special key for entry 0 */
+
 #define NFP_RESOURCE_ENTRY_NAME_SZ	8
 
 /**
@@ -100,9 +107,11 @@ static int nfp_cpp_resource_find(struct nfp_cpp *cpp, struct nfp_resource *res)
 	strncpy(name_pad, res->name, sizeof(name_pad));
 
 	/* Search for a matching entry */
-	key = NFP_RESOURCE_TBL_KEY;
-	if (memcmp(name_pad, NFP_RESOURCE_TBL_NAME "\0\0\0\0\0\0\0\0", 8))
-		key = crc32_posix(name_pad, sizeof(name_pad));
+	if (!memcmp(name_pad, NFP_RESOURCE_TBL_NAME "\0\0\0\0\0\0\0\0", 8)) {
+		nfp_err(cpp, "Grabbing device lock not supported\n");
+		return -EOPNOTSUPP;
+	}
+	key = crc32_posix(name_pad, sizeof(name_pad));
 
 	for (i = 0; i < NFP_RESOURCE_TBL_ENTRIES; i++) {
 		u64 addr = NFP_RESOURCE_TBL_BASE +
-- 
2.11.0
