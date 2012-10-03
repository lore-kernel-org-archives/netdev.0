From: Peter Senna Tschudin <peter.senna@gmail.com>
Subject: [PATCH 20/20] drivers/net/ethernet/marvell/sky2.c: fix error return code
Date: Wed,  3 Oct 2012 18:18:09 +0200
Message-ID: <1349281090-10013-19-git-send-email-peter.senna@gmail.com>
Cc: kernel-janitors@vger.kernel.org, shemminger@vyatta.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: mlindner@marvell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:39029 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965084Ab2JCQSg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2012 12:18:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Senna Tschudin <peter.senna@gmail.com>

Convert a nonnegative error return code to a negative one, as returned
elsewhere in the function.

A simplified version of the semantic match that finds this problem is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
(
if@p1 (\(ret < 0\|ret != 0\))
 { ... return ret; }
|
ret@p1 = 0
)
... when != ret = e1
    when != &ret
*if(...)
{
  ... when != ret = e2
      when forall
 return ret;
}
// </smpl>

Signed-off-by: Peter Senna Tschudin <peter.senna@gmail.com>

---
 drivers/net/ethernet/marvell/sky2.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
index 2b0748d..78946fe 100644
--- a/drivers/net/ethernet/marvell/sky2.c
+++ b/drivers/net/ethernet/marvell/sky2.c
@@ -4924,6 +4924,7 @@ static int __devinit sky2_probe(struct pci_dev *pdev,
 
 	if (~reg == 0) {
 		dev_err(&pdev->dev, "PCI configuration read error\n");
+		err = -EIO;
 		goto err_out;
 	}
 
@@ -4993,8 +4994,10 @@ static int __devinit sky2_probe(struct pci_dev *pdev,
 	hw->st_size = hw->ports * roundup_pow_of_two(3*RX_MAX_PENDING + TX_MAX_PENDING);
 	hw->st_le = pci_alloc_consistent(pdev, hw->st_size * sizeof(struct sky2_status_le),
 					 &hw->st_dma);
-	if (!hw->st_le)
+	if (!hw->st_le) {
+		err = -ENOMEM;
 		goto err_out_reset;
+	}
 
 	dev_info(&pdev->dev, "Yukon-2 %s chip revision %d\n",
 		 sky2_name(hw->chip_id, buf1, sizeof(buf1)), hw->chip_rev);
