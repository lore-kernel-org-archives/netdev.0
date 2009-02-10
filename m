From: Andre Detsch <adetsch@br.ibm.com>
Subject: [PATCH] Fix link test for e1000 and e1000e when iface
	is down
Date: Tue, 10 Feb 2009 14:35:58 -0200
Message-ID: <200902101435.58331.adetsch@br.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


When running ethtool -t on an interface that was just
brought down, the link test was failing. That's because
we need to perform a reset on the interface to be able
to check the link status correctly. There is no problem
on doing such reset right before the test, as the link
test routine is prepared to wait for autoneg to complete
if that is the case.

Signed-off-by: Andre Detsch <adetsch@br.ibm.com>
---

The bug can be produced with the following commands
(assuming eth0 is an e1000 or e1000e iface):
 ifconfig eth0 up;
 ifconfig eth0 down;
 ethtool -t eth0;

 drivers/net/e1000/e1000_ethtool.c |   10 ++++++----
 drivers/net/e1000e/ethtool.c      |   10 +++++-----
 2 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index c854c96..bed7c88 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -1646,16 +1646,18 @@ static void e1000_diag_test(struct net_device *netdev,
 
 		DPRINTK(HW, INFO, "offline testing starting\n");
 
-		/* Link test performed before hardware reset so autoneg doesn't
-		 * interfere with test result */
+		if (!if_running)
+			e1000_reset(adapter);
+
+		/* Due to the reset above, autoneg may be undergoing.
+		 * But link test is prepared to handle such situation.
+		 */
 		if (e1000_link_test(adapter, &data[4]))
 			eth_test->flags |= ETH_TEST_FL_FAILED;
 
 		if (if_running)
 			/* indicate we're in test mode */
 			dev_close(netdev);
-		else
-			e1000_reset(adapter);
 
 		if (e1000_reg_test(adapter, &data[0]))
 			eth_test->flags |= ETH_TEST_FL_FAILED;
diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index e48956d..d14a5be 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -1647,9 +1647,11 @@ static void e1000_diag_test(struct net_device *netdev,
 
 		e_info("offline testing starting\n");
 
-		/*
-		 * Link test performed before hardware reset so autoneg doesn't
-		 * interfere with test result
+		if (!if_running)
+			e1000e_reset(adapter);
+
+		/* Due to the reset above, autoneg may be undergoing.
+		 * But link test is prepared to handle such situation.
 		 */
 		if (e1000_link_test(adapter, &data[4]))
 			eth_test->flags |= ETH_TEST_FL_FAILED;
@@ -1657,8 +1659,6 @@ static void e1000_diag_test(struct net_device *netdev,
 		if (if_running)
 			/* indicate we're in test mode */
 			dev_close(netdev);
-		else
-			e1000e_reset(adapter);
 
 		if (e1000_reg_test(adapter, &data[0]))
 			eth_test->flags |= ETH_TEST_FL_FAILED;
-- 
1.5.4.3


------------------------------------------------------------------------------
Create and Deploy Rich Internet Apps outside the browser with Adobe(R)AIR(TM)
software. With Adobe AIR, Ajax developers can use existing skills and code to
build responsive, highly engaging applications that combine the power of local
resources and data with the reach of the web. Download the Adobe AIR SDK and
Ajax docs to start building applications today-http://p.sf.net/sfu/adobe-com
