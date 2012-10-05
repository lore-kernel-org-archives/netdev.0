From: Peter Senna Tschudin <peter.senna@gmail.com>
Subject: [PATCH 16/20 V2] drivers/net/ethernet/renesas/sh_eth.c: fix error return code
Date: Sat,  6 Oct 2012 00:40:52 +0200
Message-ID: <1349476856-16075-1-git-send-email-peter.senna@gmail.com>
Cc: yoshihiro.shimoda.uh@renesas.com, nobuhiro.iwamatsu.yj@renesas.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org,
	Peter Senna Tschudin <peter.senna@gmail.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Peter Senna Tschudin <peter.senna@gmail.com>

The function sh_eth_drv_probe() return 0 for success and negative value
for most of its internal tests failures. There is one exception
that is error case going to out_release:. For this error case, the
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

 drivers/net/ethernet/renesas/sh_eth.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index bad8f2e..c8bfea0 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -2438,6 +2438,7 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
 		rtsu = platform_get_resource(pdev, IORESOURCE_MEM, 1);
 		if (!rtsu) {
 			dev_err(&pdev->dev, "Not found TSU resource\n");
+			ret = -ENODEV;
 			goto out_release;
 		}
 		mdp->tsu_addr = ioremap(rtsu->start,
