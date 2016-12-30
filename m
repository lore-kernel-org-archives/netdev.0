From: Thomas Preisner <thomas.preisner+linux@fau.de>
Subject: [PATCH v4 1/2] net: 3com: typhoon: typhoon_init_one: fix incorrect return values
Date: Fri, 30 Dec 2016 03:37:53 +0100
Message-ID: <1483065474-11512-2-git-send-email-thomas.preisner+linux@fau.de>
References: <1482873453.20986.4.camel@dillow-glaptop.roam.corp.google.com>
 <1483065474-11512-1-git-send-email-thomas.preisner+linux@fau.de>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-kernel@i4.cs.fau.de, milan.stephan+linux@fau.de,
        thomas.preisner+linux@fau.de, sergei.shtylyov@cogentembedded.com,
        davem@davemloft.net
To: dave@thedillows.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1483065474-11512-1-git-send-email-thomas.preisner+linux@fau.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In a few cases the err-variable is not set to a negative error code if a
function call in typhoon_init_one() fails and thus 0 is returned
instead.
It may be better to set err to the appropriate negative error
code before returning.

Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=188841

Reported-by: Pan Bian <bianpan2016@163.com>
Signed-off-by: Thomas Preisner <thomas.preisner+linux@fau.de>
Signed-off-by: Milan Stephan <milan.stephan+linux@fau.de>
---
 drivers/net/ethernet/3com/typhoon.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/3com/typhoon.c b/drivers/net/ethernet/3com/typhoon.c
index 9fe3990..25f2e92 100644
--- a/drivers/net/ethernet/3com/typhoon.c
+++ b/drivers/net/ethernet/3com/typhoon.c
@@ -2402,8 +2402,9 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	*(__be16 *)&dev->dev_addr[0] = htons(le16_to_cpu(xp_resp[0].parm1));
 	*(__be32 *)&dev->dev_addr[2] = htonl(le32_to_cpu(xp_resp[0].parm2));
 
-	if(!is_valid_ether_addr(dev->dev_addr)) {
+	if (!is_valid_ether_addr(dev->dev_addr)) {
 		err_msg = "Could not obtain valid ethernet address, aborting";
+		err = -EIO;
 		goto error_out_reset;
 	}
 
@@ -2411,7 +2412,8 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	 * later when we print out the version reported.
 	 */
 	INIT_COMMAND_WITH_RESPONSE(&xp_cmd, TYPHOON_CMD_READ_VERSIONS);
-	if(typhoon_issue_command(tp, 1, &xp_cmd, 3, xp_resp) < 0) {
+	err = typhoon_issue_command(tp, 1, &xp_cmd, 3, xp_resp);
+	if (err < 0) {
 		err_msg = "Could not get Sleep Image version";
 		goto error_out_reset;
 	}
@@ -2453,7 +2455,8 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	dev->features = dev->hw_features |
 		NETIF_F_HW_VLAN_CTAG_RX | NETIF_F_RXCSUM;
 
-	if(register_netdev(dev) < 0) {
+	err = register_netdev(dev);
+	if (err < 0) {
 		err_msg = "unable to register netdev";
 		goto error_out_reset;
 	}
-- 
2.7.4
