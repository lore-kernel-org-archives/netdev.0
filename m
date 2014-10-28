From: "Lennart Sorensen" <lsorense@csclub.uwaterloo.ca>
Subject: Mistake in commit 0d961b3b52f566f823070ce2366511a7f64b928c breaks
 cpsw non dual_emac mode.
Date: Tue, 28 Oct 2014 13:02:42 -0400
Message-ID: <20141028170242.GA24112@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Heiko Schocher <hs@denx.de>,
	Len Sorensen <lsorense@csclub.uwaterloo.ca>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I believe commit 0d961b3b52f566f823070ce2366511a7f64b928c made a mistake
while correcting a bug.

It was correct to fix (which applies only in dual_emac mode):

@@ -554,7 +554,7 @@ static void cpsw_set_promiscious(struct net_device *ndev, bool enable)
                 * common for both the interface as the interface shares
                 * the same hardware resource.
                 */
-               for (i = 0; i <= priv->data.slaves; i++)
+               for (i = 0; i < priv->data.slaves; i++)
                        if (priv->slaves[i].ndev->flags & IFF_PROMISC)
                                flag = true;

since there i is used as an index into priv->slaves which is a 0 based array.

However the other two changes (which are only in non dual_emac mode):

@@ -578,7 +578,7 @@ static void cpsw_set_promiscious(struct net_device *ndev, bool enable)
                        unsigned long timeout = jiffies + HZ;
 
                        /* Disable Learn for all ports */
-                       for (i = 0; i <= priv->data.slaves; i++) {
+                       for (i = 0; i < priv->data.slaves; i++) {
                                cpsw_ale_control_set(ale, i,
                                                     ALE_PORT_NOLEARN, 1);
                                cpsw_ale_control_set(ale, i,
@@ -606,7 +606,7 @@ static void cpsw_set_promiscious(struct net_device *ndev, bool enable)
                        cpsw_ale_control_set(ale, 0, ALE_P0_UNI_FLOOD, 0);
 
                        /* Enable Learn for all ports */
-                       for (i = 0; i <= priv->data.slaves; i++) {
+                       for (i = 0; i < priv->data.slaves; i++) {
                                cpsw_ale_control_set(ale, i,
                                                     ALE_PORT_NOLEARN, 0);
                                cpsw_ale_control_set(ale, i,

are wrong since there i is actually the ALE port number, and port 0 is
the host port, while port 1 and up are the slave ports.

This should correct it back to working in non dual_emac mode.

Also make the comment point this out clearly to avoid future confusion
and fix a comment that was missing a "Don't".

Signed-off-by: lsorense@csclub.uwaterloo.ca

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 952e1e4..4683196 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -591,8 +591,8 @@ static void cpsw_set_promiscious(struct net_device *ndev, bool enable)
 		if (enable) {
 			unsigned long timeout = jiffies + HZ;
 
-			/* Disable Learn for all ports */
-			for (i = 0; i < priv->data.slaves; i++) {
+			/* Disable Learn for all ports (host is port 0 and slaves are port 1 and up */
+			for (i = 0; i <= priv->data.slaves; i++) {
 				cpsw_ale_control_set(ale, i,
 						     ALE_PORT_NOLEARN, 1);
 				cpsw_ale_control_set(ale, i,
@@ -616,11 +616,11 @@ static void cpsw_set_promiscious(struct net_device *ndev, bool enable)
 			cpsw_ale_control_set(ale, 0, ALE_P0_UNI_FLOOD, 1);
 			dev_dbg(&ndev->dev, "promiscuity enabled\n");
 		} else {
-			/* Flood All Unicast Packets to Host port */
+			/* Don't Flood All Unicast Packets to Host port */
 			cpsw_ale_control_set(ale, 0, ALE_P0_UNI_FLOOD, 0);
 
-			/* Enable Learn for all ports */
-			for (i = 0; i < priv->data.slaves; i++) {
+			/* Enable Learn for all ports (host is port 0 and slaves are port 1 and up */
+			for (i = 0; i <= priv->data.slaves; i++) {
 				cpsw_ale_control_set(ale, i,
 						     ALE_PORT_NOLEARN, 0);
 				cpsw_ale_control_set(ale, i,
-- 
Len Sorensen
