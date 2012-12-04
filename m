From: Andrew Gallatin <gallatin@myri.com>
Subject: [PATCH net-next] myri10ge: fix most sparse warnings
Date: Tue,  4 Dec 2012 15:17:15 -0500
Message-ID: <1354652235-13174-1-git-send-email-gallatin@myri.com>
Cc: netdev@vger.kernel.org, Andrew Gallatin <gallatin@myri.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gh0-f174.google.com ([209.85.160.174]:50752 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751144Ab2LDURY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2012 15:17:24 -0500
Received: by mail-gh0-f174.google.com with SMTP id g15so671011ghb.19
        for <netdev@vger.kernel.org>; Tue, 04 Dec 2012 12:17:23 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- convert remaining htonl/ntohl +__raw_read/__raw_writel to
  swab32 + readl/writel
- add missing __iomem qualifier in myri10ge_open()
- fix  dubious: x & !y warning by switching from logical to bitwise not

The swab32 conversion fixes a bug in myri10ge_led() where
big-endian machines would write the wrong pattern.

The only remaining warning (lock context imbalance) is due to
the use of __netif_tx_trylock(), and cannot easily be fixed.

Signed-off-by: Andrew Gallatin <gallatin@myri.com>
---
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
index a40234e..f8408d6 100644
--- a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
+++ b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
@@ -1885,7 +1885,7 @@ static int myri10ge_led(struct myri10ge_priv *mgp, int on)
 	}
 	if (!on)
 		pattern = swab32(readl(mgp->sram + pattern_off + 4));
-	writel(htonl(pattern), mgp->sram + pattern_off);
+	writel(swab32(pattern), mgp->sram + pattern_off);
 	return 0;
 }
 
@@ -2294,7 +2294,7 @@ static int myri10ge_open(struct net_device *dev)
 	struct myri10ge_priv *mgp = netdev_priv(dev);
 	struct myri10ge_cmd cmd;
 	int i, status, big_pow2, slice;
-	u8 *itable;
+	u8 __iomem *itable;
 
 	if (mgp->running != MYRI10GE_ETH_STOPPED)
 		return -EBUSY;
@@ -2757,7 +2757,7 @@ again:
 					flags_next |= next_is_first *
 					    MXGEFW_FLAGS_FIRST;
 					rdma_count |= -(chop | next_is_first);
-					rdma_count += chop & !next_is_first;
+					rdma_count += chop & ~next_is_first;
 				} else if (likely(cum_len_next >= 0)) {	/* header ends */
 					int small;
 
@@ -3836,9 +3836,9 @@ static int myri10ge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto abort_with_mtrr;
 	}
 	hdr_offset =
-	    ntohl(__raw_readl(mgp->sram + MCP_HEADER_PTR_OFFSET)) & 0xffffc;
+	    swab32(readl(mgp->sram + MCP_HEADER_PTR_OFFSET)) & 0xffffc;
 	ss_offset = hdr_offset + offsetof(struct mcp_gen_header, string_specs);
-	mgp->sram_size = ntohl(__raw_readl(mgp->sram + ss_offset));
+	mgp->sram_size = swab32(readl(mgp->sram + ss_offset));
 	if (mgp->sram_size > mgp->board_span ||
 	    mgp->sram_size <= MYRI10GE_FW_OFFSET) {
 		dev_err(&pdev->dev,
-- 
1.7.9.5
