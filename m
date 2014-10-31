From: "Lennart Sorensen" <lsorense@csclub.uwaterloo.ca>
Subject: drivers: net: cpsw: Fix broken loop condition in switch mode
Date: Fri, 31 Oct 2014 13:28:54 -0400
Message-ID: <20141031172854.GJ24110@csclub.uwaterloo.ca>
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

0d961b3b52f566f823070ce2366511a7f64b928c (drivers: net: cpsw: fix buggy
loop condition) accidentally fixed a loop comparison in too many places
while fixing a real bug.

It was correct to fix the dual_emac mode section since there 'i' is used
as an index into priv->slaves which is a 0 based array.

However the other two changes (which are only used in switch mode)
are wrong since there 'i' is actually the ALE port number, and port 0
is the host port, while port 1 and up are the slave ports.

Putting the loop condition back in the switch mode section fixes it.

A comment has been added to point out the intent clearly to avoid future
confusion.  Also a comment is fixed that said the opposite of what was
actually happening.

Signed-off-by: Len Sorensen <lsorense@csclub.uwaterloo.ca>
Acked-by: Heiko Schocher <hs@denx.de>

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
