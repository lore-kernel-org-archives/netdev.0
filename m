From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the rdma tree
Date: Wed, 15 Feb 2017 11:30:03 +1100
Message-ID: <20170215113003.4c730d86@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        Michael Chan <michael.chan@broadcom.com>,
        Selvin Xavier <selvin.xavier@broadcom.com>,
        Eddie Wai <eddie.wai@broadcom.com>,
        Devesh Sharma <devesh.sharma@broadcom.com>,
        Somnath Kotur <somnath.kotur@broadcom.com>,
        Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
To: Doug Ledford <dledford@redhat.com>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Doug,

After merging the rdma tree, today's linux-next build (x86_64
allmodconfig) failed like this:

drivers/infiniband/hw/bnxt_re/main.c: In function 'bnxt_re_net_ring_free':
drivers/infiniband/hw/bnxt_re/main.c:231:18: error: 'RING_ALLOC_REQ_RING_TYPE_CMPL' undeclared (first use in this function)
  req.ring_type = RING_ALLOC_REQ_RING_TYPE_CMPL;
                  ^
drivers/infiniband/hw/bnxt_re/main.c:231:18: note: each undeclared identifier is reported only once for each function it appears in
drivers/infiniband/hw/bnxt_re/main.c: In function 'bnxt_re_net_ring_alloc':
drivers/infiniband/hw/bnxt_re/main.c:271:18: error: 'RING_ALLOC_REQ_RING_TYPE_CMPL' undeclared (first use in this function)
  req.ring_type = RING_ALLOC_REQ_RING_TYPE_CMPL;
                  ^

Caused by commit

  1ac5a4047975 ("RDMA/bnxt_re: Add bnxt_re RoCE driver")

interacting with commit

  bac9a7e0f5d6 ("bnxt_en: Update to firmware interface spec 1.7.0.")

from the net-next tree.

I added this merge fix patch:

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Wed, 15 Feb 2017 11:23:25 +1100
Subject: [PATCH] RDMA/bnxt_re: fix for "bnxt_en: Update to firmware interface spec 1.7.0."

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/infiniband/hw/bnxt_re/main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/infiniband/hw/bnxt_re/main.c b/drivers/infiniband/hw/bnxt_re/main.c
index 6b9f1178050f..bd452a92b386 100644
--- a/drivers/infiniband/hw/bnxt_re/main.c
+++ b/drivers/infiniband/hw/bnxt_re/main.c
@@ -228,7 +228,7 @@ static int bnxt_re_net_ring_free(struct bnxt_re_dev *rdev, u16 fw_ring_id,
 	}
 
 	bnxt_re_init_hwrm_hdr(rdev, (void *)&req, HWRM_RING_FREE, -1, -1);
-	req.ring_type = RING_ALLOC_REQ_RING_TYPE_CMPL;
+	req.ring_type = RING_ALLOC_REQ_RING_TYPE_L2_CMPL;
 	req.ring_id = cpu_to_le16(fw_ring_id);
 	bnxt_re_fill_fw_msg(&fw_msg, (void *)&req, sizeof(req), (void *)&resp,
 			    sizeof(resp), DFLT_HWRM_CMD_TIMEOUT);
@@ -268,7 +268,7 @@ static int bnxt_re_net_ring_alloc(struct bnxt_re_dev *rdev, dma_addr_t *dma_arr,
 	/* Association of ring index with doorbell index and MSIX number */
 	req.logical_id = cpu_to_le16(map_index);
 	req.length = cpu_to_le32(ring_mask + 1);
-	req.ring_type = RING_ALLOC_REQ_RING_TYPE_CMPL;
+	req.ring_type = RING_ALLOC_REQ_RING_TYPE_L2_CMPL;
 	req.int_mode = RING_ALLOC_REQ_INT_MODE_MSIX;
 	bnxt_re_fill_fw_msg(&fw_msg, (void *)&req, sizeof(req), (void *)&resp,
 			    sizeof(resp), DFLT_HWRM_CMD_TIMEOUT);
-- 
2.10.2

-- 
Cheers,
Stephen Rothwell
