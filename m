From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] bna: avoid writing uninitialized data into hw registers
Date: Thu, 23 Mar 2017 17:07:26 +0100
Message-ID: <20170323160734.2029105-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Rasesh Mody <rasesh.mody@cavium.com>,
        Sudarsana Kalluru <sudarsana.kalluru@cavium.com>,
        Dept-GELinuxNICDev@cavium.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The latest gcc-7 snapshot warns about bfa_ioc_send_enable/bfa_ioc_send_disable
writing undefined values into the hardware registers:

drivers/net/ethernet/brocade/bna/bfa_ioc.c: In function 'bfa_iocpf_sm_disabling_entry':
arch/arm/include/asm/io.h:109:22: error: '*((void *)&disable_req+4)' is used uninitialized in this function [-Werror=uninitialized]
arch/arm/include/asm/io.h:109:22: error: '*((void *)&disable_req+8)' is used uninitialized in this function [-Werror=uninitialized]

The two functions look like they should do the same thing, but only one
of them initializes the time stamp and clscode field. The fact that we
only get a warning for one of the two functions seems to be arbitrary,
based on the inlining decisions in the compiler.

To address this, I'm making both functions do the same thing:

- set the clscode from the ioc structure in both
- set the time stamp from ktime_get_real_seconds (which also
  avoids the signed-integer overflow in 2038 and extends the
  well-defined behavior until 2106).
- zero-fill the reserved field

Fixes: 8b230ed8ec96 ("bna: Brocade 10Gb Ethernet device driver")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/brocade/bna/bfa_ioc.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bfa_ioc.c b/drivers/net/ethernet/brocade/bna/bfa_ioc.c
index 9e59663a6ead..0f6811860ad5 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_ioc.c
+++ b/drivers/net/ethernet/brocade/bna/bfa_ioc.c
@@ -1930,13 +1930,13 @@ static void
 bfa_ioc_send_enable(struct bfa_ioc *ioc)
 {
 	struct bfi_ioc_ctrl_req enable_req;
-	struct timeval tv;
 
 	bfi_h2i_set(enable_req.mh, BFI_MC_IOC, BFI_IOC_H2I_ENABLE_REQ,
 		    bfa_ioc_portid(ioc));
 	enable_req.clscode = htons(ioc->clscode);
-	do_gettimeofday(&tv);
-	enable_req.tv_sec = ntohl(tv.tv_sec);
+	enable_req.rsvd = htons(0);
+	/* overflow in 2106 */
+	enable_req.tv_sec = ntohl(ktime_get_real_seconds());
 	bfa_ioc_mbox_send(ioc, &enable_req, sizeof(struct bfi_ioc_ctrl_req));
 }
 
@@ -1947,6 +1947,10 @@ bfa_ioc_send_disable(struct bfa_ioc *ioc)
 
 	bfi_h2i_set(disable_req.mh, BFI_MC_IOC, BFI_IOC_H2I_DISABLE_REQ,
 		    bfa_ioc_portid(ioc));
+	disable_req.clscode = htons(ioc->clscode);
+	disable_req.rsvd = htons(0);
+	/* overflow in 2106 */
+	disable_req.tv_sec = ntohl(ktime_get_real_seconds());
 	bfa_ioc_mbox_send(ioc, &disable_req, sizeof(struct bfi_ioc_ctrl_req));
 }
 
-- 
2.9.0
