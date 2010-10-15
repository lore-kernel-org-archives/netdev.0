From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 1/7] drivers/net/irda/irtty-sir.c: Return -ENOMEM on memory allocation failure
Date: Fri, 15 Oct 2010 15:00:04 +0200
Message-ID: <1287147610-8041-1-git-send-email-julia@diku.dk>
Cc: kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Samuel Ortiz <samuel@sortiz.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>

In this code, 0 is returned on memory allocation failure, even though other
failures return -ENOMEM or other similar values.

The initial value of ret as 0 is never used, so drop the initialization.

A simplified version of the semantic match that finds the first problem is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
@@
expression ret;
expression x,e1,e2,e3;
@@

ret = 0
... when != ret = e1
*x = \(kmalloc\|kcalloc\|kzalloc\)(...)
... when != ret = e2
if (x == NULL) { ... when != ret = e3
  return ret;
}
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 drivers/net/irda/irtty-sir.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff -u -p a/drivers/net/irda/irtty-sir.c b/drivers/net/irda/irtty-sir.c
--- a/drivers/net/irda/irtty-sir.c
+++ b/drivers/net/irda/irtty-sir.c
@@ -426,7 +426,7 @@ static int irtty_open(struct tty_struct 
 {
 	struct sir_dev *dev;
 	struct sirtty_cb *priv;
-	int ret = 0;
+	int ret;
 
 	/* Module stuff handled via irda_ldisc.owner - Jean II */
 
@@ -459,8 +459,10 @@ static int irtty_open(struct tty_struct 
 
 	/* allocate private device info block */
 	priv = kzalloc(sizeof(*priv), GFP_KERNEL);
-	if (!priv)
+	if (!priv) {
+		ret = -ENOMEM;
 		goto out_put;
+	}
 
 	priv->magic = IRTTY_MAGIC;
 	priv->tty = tty;
