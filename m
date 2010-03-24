From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH] ixgbe: Don't allow user buffer count to exceed 256
Date: Wed, 24 Mar 2010 13:02:04 -0700
Message-ID: <20100324200204.6384.63977.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Robert Love <robert.w.love@intel.com>,
	Yi Zou <yi.zou@intel.com>,
	Frank Zhang <frank_1.zhang@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta13.westchester.pa.mail.comcast.net ([76.96.59.243]:39651
	"EHLO qmta13.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756278Ab0CXUC1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Mar 2010 16:02:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Love <robert.w.love@intel.com>

If the user buffer count was 256 the shift would place a 1
in the offset region leading to errors. It also overwrites
the uers buffer list. This patch makes sure that at most
256 user buffers are allowed for DDP and the buffer count
is masked properly such that it doesn't overwrite the offset
when shifting the bits.

Signed-off-by: Robert Love <robert.w.love@intel.com>
Signed-off-by: Yi Zou <yi.zou@intel.com>
Signed-off-by: Frank Zhang <frank_1.zhang@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_fcoe.c |   18 ++++++++++--------
 1 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_fcoe.c b/drivers/net/ixgbe/ixgbe_fcoe.c
index 700cfc0..e1978da 100644
--- a/drivers/net/ixgbe/ixgbe_fcoe.c
+++ b/drivers/net/ixgbe/ixgbe_fcoe.c
@@ -202,6 +202,15 @@ int ixgbe_fcoe_ddp_get(struct net_device *netdev, u16 xid,
 		addr = sg_dma_address(sg);
 		len = sg_dma_len(sg);
 		while (len) {
+			/* max number of buffers allowed in one DDP context */
+			if (j >= IXGBE_BUFFCNT_MAX) {
+				netif_err(adapter, drv, adapter->netdev,
+					  "xid=%x:%d,%d,%d:addr=%llx "
+					  "not enough descriptors\n",
+					  xid, i, j, dmacount, (u64)addr);
+				goto out_noddp_free;
+			}
+
 			/* get the offset of length of current buffer */
 			thisoff = addr & ((dma_addr_t)bufflen - 1);
 			thislen = min((bufflen - thisoff), len);
@@ -227,20 +236,13 @@ int ixgbe_fcoe_ddp_get(struct net_device *netdev, u16 xid,
 			len -= thislen;
 			addr += thislen;
 			j++;
-			/* max number of buffers allowed in one DDP context */
-			if (j > IXGBE_BUFFCNT_MAX) {
-				DPRINTK(DRV, ERR, "xid=%x:%d,%d,%d:addr=%llx "
-					"not enough descriptors\n",
-					xid, i, j, dmacount, (u64)addr);
-				goto out_noddp_free;
-			}
 		}
 	}
 	/* only the last buffer may have non-full bufflen */
 	lastsize = thisoff + thislen;
 
 	fcbuff = (IXGBE_FCBUFF_4KB << IXGBE_FCBUFF_BUFFSIZE_SHIFT);
-	fcbuff |= (j << IXGBE_FCBUFF_BUFFCNT_SHIFT);
+	fcbuff |= ((j & 0xff) << IXGBE_FCBUFF_BUFFCNT_SHIFT);
 	fcbuff |= (firstoff << IXGBE_FCBUFF_OFFSET_SHIFT);
 	fcbuff |= (IXGBE_FCBUFF_VALID);
 

