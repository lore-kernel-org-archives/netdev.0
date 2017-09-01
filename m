From: Bjorn Andersson <bjorn.andersson@linaro.org>
Subject: [PATCH 2/2] Bluetooth: btqcomsmd: BD address setup
Date: Fri,  1 Sep 2017 13:41:18 -0700
Message-ID: <20170901204118.17123-3-bjorn.andersson@linaro.org>
References: <20170901204118.17123-1-bjorn.andersson@linaro.org>
Cc: "David S. Miller" <davem@davemloft.net>,
        linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org,
        Loic Poulain <loic.poulain@linaro.org>
To: Marcel Holtmann <marcel@holtmann.org>,
        Gustavo Padovan <gustavo@padovan.org>,
        Johan Hedberg <johan.hedberg@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170901204118.17123-1-bjorn.andersson@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Loic Poulain <loic.poulain@linaro.org>

Bluetooth BD address can be retrieved in the same way as
for wcnss-wlan MAC address. This patch mainly stores the
local-mac-address property and sets the BD address during
hci device setup.

Signed-off-by: Loic Poulain <loic.poulain@linaro.org>
Signed-off-by: Bjorn Andersson <bjorn.andersson@linaro.org>
---
 drivers/bluetooth/btqcomsmd.c | 28 ++++++++++++++++++++++++++++
 1 file changed, 28 insertions(+)

diff --git a/drivers/bluetooth/btqcomsmd.c b/drivers/bluetooth/btqcomsmd.c
index d00c4fdae924..443bb2099329 100644
--- a/drivers/bluetooth/btqcomsmd.c
+++ b/drivers/bluetooth/btqcomsmd.c
@@ -26,6 +26,7 @@
 struct btqcomsmd {
 	struct hci_dev *hdev;
 
+	const bdaddr_t *addr;
 	struct rpmsg_endpoint *acl_channel;
 	struct rpmsg_endpoint *cmd_channel;
 };
@@ -100,6 +101,27 @@ static int btqcomsmd_close(struct hci_dev *hdev)
 	return 0;
 }
 
+static int btqcomsmd_setup(struct hci_dev *hdev)
+{
+	struct btqcomsmd *btq = hci_get_drvdata(hdev);
+	struct sk_buff *skb;
+
+	skb = __hci_cmd_sync(hdev, HCI_OP_RESET, 0, NULL, HCI_INIT_TIMEOUT);
+	if (IS_ERR(skb))
+		return PTR_ERR(skb);
+	kfree_skb(skb);
+
+	if (btq->addr) {
+		bdaddr_t bdaddr;
+
+		/* btq->addr stored with most significant byte first */
+		baswap(&bdaddr, btq->addr);
+		return qca_set_bdaddr_rome(hdev, &bdaddr);
+	}
+
+	return 0;
+}
+
 static int btqcomsmd_probe(struct platform_device *pdev)
 {
 	struct btqcomsmd *btq;
@@ -123,6 +145,11 @@ static int btqcomsmd_probe(struct platform_device *pdev)
 	if (IS_ERR(btq->cmd_channel))
 		return PTR_ERR(btq->cmd_channel);
 
+	btq->addr = of_get_property(pdev->dev.of_node, "local-mac-address",
+				    &ret);
+	if (ret != sizeof(bdaddr_t))
+		btq->addr = NULL;
+
 	hdev = hci_alloc_dev();
 	if (!hdev)
 		return -ENOMEM;
@@ -135,6 +162,7 @@ static int btqcomsmd_probe(struct platform_device *pdev)
 	hdev->open = btqcomsmd_open;
 	hdev->close = btqcomsmd_close;
 	hdev->send = btqcomsmd_send;
+	hdev->setup = btqcomsmd_setup;
 	hdev->set_bdaddr = qca_set_bdaddr_rome;
 
 	ret = hci_register_dev(hdev);
-- 
2.12.0
