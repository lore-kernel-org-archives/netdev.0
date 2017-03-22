From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 10/15] nfp: fix nfp_cpp_read()/nfp_cpp_write() error paths
Date: Tue, 21 Mar 2017 17:59:16 -0700
Message-ID: <20170322005921.10965-11-jakub.kicinski@netronome.com>
References: <20170322005921.10965-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:36627 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758558AbdCVBIH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 21:08:07 -0400
Received: by mail-pg0-f43.google.com with SMTP id g2so100804581pge.3
        for <netdev@vger.kernel.org>; Tue, 21 Mar 2017 18:08:06 -0700 (PDT)
In-Reply-To: <20170322005921.10965-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When acquiring an area fails we can't call function doing both
release and free.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cppcore.c | 15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cppcore.c b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cppcore.c
index 2e4796b52b84..e2abba4c3a3f 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cppcore.c
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cppcore.c
@@ -951,12 +951,14 @@ int nfp_cpp_read(struct nfp_cpp *cpp, u32 destination,
 			return -ENOMEM;
 
 		err = nfp_cpp_area_acquire(area);
-		if (err)
-			goto out;
+		if (err) {
+			nfp_cpp_area_free(area);
+			return err;
+		}
 	}
 
 	err = nfp_cpp_area_read(area, offset, kernel_vaddr, length);
-out:
+
 	if (cache)
 		area_cache_put(cpp, cache);
 	else
@@ -993,13 +995,14 @@ int nfp_cpp_write(struct nfp_cpp *cpp, u32 destination,
 			return -ENOMEM;
 
 		err = nfp_cpp_area_acquire(area);
-		if (err)
-			goto out;
+		if (err) {
+			nfp_cpp_area_free(area);
+			return err;
+		}
 	}
 
 	err = nfp_cpp_area_write(area, offset, kernel_vaddr, length);
 
-out:
 	if (cache)
 		area_cache_put(cpp, cache);
 	else
-- 
2.11.0
