From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 v2 5/7] ixgbe: DDP last buffer size work around
Date: Fri, 28 Jan 2011 04:29:01 -0800
Message-ID: <1296217743-30093-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1296217743-30093-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Amir Hanania <amir.hanania@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:55113 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754954Ab1A1M3K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Jan 2011 07:29:10 -0500
In-Reply-To: <1296217743-30093-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Hanania <amir.hanania@intel.com>

We found a hardware erratum on 82599 hardware that can lead to buffer
overwriting if the last buffer in FCoE DDP is exactly PAGE_SIZE.
If this is the case, we will make sure that there is no HW access to
this buffer.

Please see the 82599 Specification Update for more information.

Signed-off-by: Amir Hanania <amir.hanania@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_fcoe.c |   19 +++++++++++++++++++
 1 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_fcoe.c b/drivers/net/ixgbe/ixgbe_fcoe.c
index 6342d48..ffac3f6 100644
--- a/drivers/net/ixgbe/ixgbe_fcoe.c
+++ b/drivers/net/ixgbe/ixgbe_fcoe.c
@@ -254,6 +254,25 @@ int ixgbe_fcoe_ddp_get(struct net_device *netdev, u16 xid,
 	/* only the last buffer may have non-full bufflen */
 	lastsize = thisoff + thislen;
 
+	/*
+	 * lastsize can not be PAGE_SIZE.
+	 * If it is then adding another buffer with lastsize = 1.
+	 * Since lastsize is 1 there will be no HW access to this buffer.
+	 */
+	if (lastsize == PAGE_SIZE) {
+		if (j == (IXGBE_BUFFCNT_MAX - 1)) {
+			e_err(drv, "xid=%x:%d,%d,%d:addr=%llx "
+				"not enough descriptors only since lastsize "
+				"is PAGE_SIZE\n",
+				xid, i, j, dmacount, (u64)addr);
+			goto out_noddp_free;
+		}
+
+		ddp->udl[j+1] = ddp->udl[j];
+		j++;
+		lastsize = 1;
+	}
+
 	fcbuff = (IXGBE_FCBUFF_4KB << IXGBE_FCBUFF_BUFFSIZE_SHIFT);
 	fcbuff |= ((j & 0xff) << IXGBE_FCBUFF_BUFFCNT_SHIFT);
 	fcbuff |= (firstoff << IXGBE_FCBUFF_OFFSET_SHIFT);
-- 
1.7.3.5

