From: Peter Senna Tschudin <peter.senna@gmail.com>
Subject: [PATCH 20/20 V2] drivers/net/ethernet/marvell/sky2.c: fix error return code
Date: Sat,  6 Oct 2012 00:40:56 +0200
Message-ID: <1349476856-16075-5-git-send-email-peter.senna@gmail.com>
References: <1349476856-16075-1-git-send-email-peter.senna@gmail.com>
Cc: shemminger@vyatta.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	Peter Senna Tschudin <peter.senna@gmail.com>
To: mlindner@marvell.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1349476856-16075-1-git-send-email-peter.senna@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Peter Senna Tschudin <peter.senna@gmail.com>

The function sky2_probe() return 0 for success and negative value
for most of its internal tests failures. There are two exceptions
that are error cases going to err_out*:. For this two cases, the
function abort its success execution path, but returns non negative
value, making it dificult for a caller function to notice the error.

This patch fixes the error cases that do not return negative values.

This was found by Coccinelle, but the code change was made by hand.
This patch is not robot generated.

A simplified version of the semantic match that finds this problem is
as follows: (http://coccinelle.lip6.fr/)

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
Change from V1:
        Updated commit message. See:
        http://www.kernelhub.org/?p=2&msg=139319

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
