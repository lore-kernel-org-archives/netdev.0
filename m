From: Peter Senna Tschudin <peter.senna@gmail.com>
Subject: [PATCH 19/20 V2] drivers/net/ethernet/marvell/skge.c: fix error return code
Date: Sat,  6 Oct 2012 00:40:55 +0200
Message-ID: <1349476856-16075-4-git-send-email-peter.senna@gmail.com>
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

The function skge_probe() return 0 for success and negative value
for most of its internal tests failures. There is one exception
that is error case going to err_out_led_off:. For this error case, the
function abort its success execution path, but returns non negative
value, making it difficult for a caller function to notice the error.

This patch fixes the error case that do not return negative value.

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

 drivers/net/ethernet/marvell/skge.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/skge.c b/drivers/net/ethernet/marvell/skge.c
index 5a30bf8..91836b5 100644
--- a/drivers/net/ethernet/marvell/skge.c
+++ b/drivers/net/ethernet/marvell/skge.c
@@ -3945,8 +3945,10 @@ static int __devinit skge_probe(struct pci_dev *pdev,
 		skge_board_name(hw), hw->chip_rev);
 
 	dev = skge_devinit(hw, 0, using_dac);
-	if (!dev)
+	if (!dev) {
+		err = -ENOMEM;
 		goto err_out_led_off;
+	}
 
 	/* Some motherboards are broken and has zero in ROM. */
 	if (!is_valid_ether_addr(dev->dev_addr))
