From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 2/6] drivers/net/can/softing/softing_main.c: ensure a consistent return value in error case
Date: Sat, 14 Jul 2012 18:43:04 +0200
Message-ID: <1342284188-19176-3-git-send-email-Julia.Lawall@lip6.fr>
References: <1342284188-19176-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1342284188-19176-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>

Typically, the return value desired for the failure of a function with an
integer return value is a negative integer.  In these cases, the return
value is sometimes a negative integer and sometimes 0, due to a subsequent
initialization of the return variable within the loop.

A simplified version of the semantic match that finds this problem is:
(http://coccinelle.lip6.fr/)

//<smpl>
@r exists@
identifier ret;
position p;
constant C;
expression e1,e3,e4;
statement S;
@@

ret = -C
... when != ret = e3
    when any
if@p (...) S
... when any
if (\(ret != 0\|ret < 0\|ret > 0\) || ...) { ... return ...; }
... when != ret = e3
    when any
*if@p (...)
{
  ... when != ret = e4
  return ret;
}
//</smpl>

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 drivers/net/can/softing/softing_main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/can/softing/softing_main.c b/drivers/net/can/softing/softing_main.c
index a7c77c7..f2a221e 100644
--- a/drivers/net/can/softing/softing_main.c
+++ b/drivers/net/can/softing/softing_main.c
@@ -826,12 +826,12 @@ static __devinit int softing_pdev_probe(struct platform_device *pdev)
 		goto sysfs_failed;
 	}
 
-	ret = -ENOMEM;
 	for (j = 0; j < ARRAY_SIZE(card->net); ++j) {
 		card->net[j] = netdev =
 			softing_netdev_create(card, card->id.chip[j]);
 		if (!netdev) {
 			dev_alert(&pdev->dev, "failed to make can[%i]", j);
+			ret = -ENOMEM;
 			goto netdev_failed;
 		}
 		priv = netdev_priv(card->net[j]);

