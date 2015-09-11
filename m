From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] bnx2x: use ktime_get_seconds() for timestamp
Date: Fri, 11 Sep 2015 11:33:01 +0200
Message-ID: <2387233.xmDni0GXyg@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: y2038@lists.linaro.org, Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.10]:56060 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751730AbbIKJdM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2015 05:33:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit c48f350ff5e7 "bnx2x: Add MFW dump support" added the
bnx2x_update_mfw_dump() function that reads the current time and stores
it in a 32-bit field that gets passed into a buffer in a fixed format.

This is potentially broken when the epoch overflows in 2038, and
otherwise overflows in 2106. As we're trying to avoid uses of
struct timeval for this reason, I noticed the addition of this
function, and tried to rewrite it in a way that is more explicit
about the overflow and that will keep working once we deprecate
struct timeval.

I assume that it is not possible to change the ABI any more, otherwise
we should try to use a 64-bit field for the seconds right away.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
Cc: Ariel Elior <Ariel.Elior@qlogic.com>
---
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index e3da2bddf143..89a174fa1300 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -3705,16 +3705,14 @@ out:
 
 void bnx2x_update_mfw_dump(struct bnx2x *bp)
 {
-	struct timeval epoc;
 	u32 drv_ver;
 	u32 valid_dump;
 
 	if (!SHMEM2_HAS(bp, drv_info))
 		return;
 
-	/* Update Driver load time */
-	do_gettimeofday(&epoc);
-	SHMEM2_WR(bp, drv_info.epoc, epoc.tv_sec);
+	/* Update Driver load time, possibly broken in y2038 */
+	SHMEM2_WR(bp, drv_info.epoc, (u32)ktime_get_real_seconds());
 
 	drv_ver = bnx2x_update_mng_version_utility(DRV_MODULE_VERSION, true);
 	SHMEM2_WR(bp, drv_info.drv_ver, drv_ver);
