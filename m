From: James Chapman <jchapman@katalix.com>
Subject: [PATCH net-2.6.24] e100: fix driver init lockup on
	e100_up()
Date: Mon, 27 Aug 2007 18:06:58 +0100
Message-ID: <200708271706.l7RH6wT0024567@quickie.katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Recent NAPI changes require that napi_enable() is always matched with
a napi_disable(). This patch makes sure that this invariant holds for
e100. It also moves the netif_napi_add() call until after private
pointers have been intialized, though this might only be significant
for cases where netpoll is being used.

Signed-off-by: James Chapman <jchapman@katalix.com>

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index e25f5ec..48996a4 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -2575,11 +2575,12 @@ static int __devinit e100_probe(struct pci_dev *pdev,
 	strncpy(netdev->name, pci_name(pdev), sizeof(netdev->name) - 1);
 
 	nic = netdev_priv(netdev);
-	netif_napi_add(netdev, &nic->napi, e100_poll, E100_NAPI_WEIGHT);
 	nic->netdev = netdev;
 	nic->pdev = pdev;
 	nic->msg_enable = (1 << debug) - 1;
 	pci_set_drvdata(pdev, netdev);
+	netif_napi_add(netdev, &nic->napi, e100_poll, E100_NAPI_WEIGHT);
+	napi_disable(&nic->napi);
 
 	if((err = pci_enable_device(pdev))) {
 		DPRINTK(PROBE, ERR, "Cannot enable PCI device, aborting.\n");

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
