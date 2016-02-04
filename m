From: Amitoj Kaur Chawla <amitoj1606@gmail.com>
Subject: [PATCH 1/3] net: cavium: liquidio: Return correct error code
Date: Thu, 4 Feb 2016 19:25:13 +0530
Message-ID: <20160204135512.GA8297@amitoj-Inspiron-3542>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: julia.lawall@lip6.fr
To: derek.chickles@caviumnetworks.com,
	satananda.burla@caviumnetworks.com,
	felix.manlunas@caviumnetworks.com,
	raghu.vatsavayi@caviumnetworks.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The return value of vmalloc on failure of allocation of memory should
be -ENOMEM and not -1.

Found using Coccinelle. A simplified version of the semantic patch
used is:

//<smpl>
@@
expression *e;
identifier l1;
position p,q;
@@

e@q = vmalloc(...);
if@p (e == NULL) {
...
goto l1;
}
l1:
...
return -1
+ -ENOMEM
;
//</smpl

The single call site of the containing function checks whether the
returned value is -1, so this check is changed as well. The single call 
site of this call site, however, only checks whether the value is not 0,
so no further change was required.

Signed-off-by: Amitoj Kaur Chawla <amitoj1606@gmail.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 2 +-
 drivers/net/ethernet/cavium/liquidio/octeon_droq.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index f683d97..0bf03b1 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -1685,7 +1685,7 @@ static int octeon_setup_droq(struct octeon_device *oct, int q_no, int num_descs,
 	dev_dbg(&oct->pci_dev->dev, "Creating Droq: %d\n", q_no);
 	/* droq creation and local register settings. */
 	ret_val = octeon_create_droq(oct, q_no, num_descs, desc_size, app_ctx);
-	if (ret_val == -1)
+	if (ret_val < 0)
 		return ret_val;
 
 	if (ret_val == 1) {
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_droq.c b/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
index 4dba86e..174072b 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
@@ -983,5 +983,5 @@ int octeon_create_droq(struct octeon_device *oct,
 
 create_droq_fail:
 	octeon_delete_droq(oct, q_no);
-	return -1;
+	return -ENOMEM;
 }
-- 
1.9.1
