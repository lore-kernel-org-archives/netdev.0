From: Daniel Mack <zonque@gmail.com>
Subject: [PATCH] net: smsc911x: handle suspend/resume for mii bus
Date: Wed, 13 Aug 2014 22:03:17 +0200
Message-ID: <1407960197-5342-1-git-send-email-zonque@gmail.com>
Cc: f.fainelli@gmail.com, ezequiel.garcia@free-electrons.com,
	netdev@vger.kernel.org, Daniel Mack <zonque@gmail.com>,
	<stable@vger.kernel.org>
To: davem@davemloft.net
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since commit a71e3c37960c ("net: phy: Set the driver when registering
an MDIO bus device"), the ->driver pointers of all mii buses are set to
the parent device's driver. This means that smsc911x_{suspend,resume}
will be called for the MII bus at suspend time now, in addition to the
actual netdev suspend callbacks.

These functions currently assume they are only called for the netdev,
and don't check whether they get back a valid pointer from
dev_get_drvdata().

Fix this by bailing out early if dev_get_drvdata() returns NULL.

Signed-off-by: Daniel Mack <zonque@gmail.com>
Cc: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Cc: <stable@vger.kernel.org>    [3.16+]
---
 drivers/net/ethernet/smsc/smsc911x.c | 20 ++++++++++++++++++--
 1 file changed, 18 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index 5e13fa5..2ba6590 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -2555,7 +2555,15 @@ out_0:
 static int smsc911x_suspend(struct device *dev)
 {
 	struct net_device *ndev = dev_get_drvdata(dev);
-	struct smsc911x_data *pdata = netdev_priv(ndev);
+	struct smsc911x_data *pdata;
+
+	/* We are called for the mii bus as well, in which case
+	 * drvdata is unset.
+	 */
+	if (!ndev)
+		return 0;
+
+	pdata = netdev_priv(ndev);
 
 	/* enable wake on LAN, energy detection and the external PME
 	 * signal. */
@@ -2569,9 +2577,17 @@ static int smsc911x_suspend(struct device *dev)
 static int smsc911x_resume(struct device *dev)
 {
 	struct net_device *ndev = dev_get_drvdata(dev);
-	struct smsc911x_data *pdata = netdev_priv(ndev);
+	struct smsc911x_data *pdata;
 	unsigned int to = 100;
 
+	if (!ndev)
+		return 0;
+
+	/* We are called for the mii bus as well, in which case
+	 * drvdata is unset.
+	 */
+	pdata = netdev_priv(ndev);
+
 	/* Note 3.11 from the datasheet:
 	 * 	"When the LAN9220 is in a power saving state, a write of any
 	 * 	 data to the BYTE_TEST register will wake-up the device."
-- 
2.0.4
