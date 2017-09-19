From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH net 7/7] net: hns3: Fixes the premature exit of loop when matching clients
Date: Tue, 19 Sep 2017 02:06:28 +0100
Message-ID: <20170919010628.175732-8-salil.mehta@huawei.com>
References: <20170919010628.175732-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <yisen.zhuang@huawei.com>,
        <lipeng321@huawei.com>, <mehta.salil.lnk@gmail.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linux-rdma@vger.kernel.org>, <linuxarm@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170919010628.175732-1-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lipeng <lipeng321@huawei.com>

When register/unregister ae_dev, ae_dev should match all client
in the client_list. Enet and roce can co-exists together so we
should continue checking for enet and roce presence together.
So break should not be there.

Above caused problems in loading and unloading of modules.

Signed-off-by: Lipeng <lipeng321@huawei.com>
Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns3/hnae3.c | 43 ++++++-----------------------
 1 file changed, 9 insertions(+), 34 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hnae3.c b/drivers/net/ethernet/hisilicon/hns3/hnae3.c
index 59efbd605416..5bcb2238acb2 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hnae3.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hnae3.c
@@ -37,20 +37,15 @@ static bool hnae3_client_match(enum hnae3_client_type client_type,
 }
 
 static int hnae3_match_n_instantiate(struct hnae3_client *client,
-				     struct hnae3_ae_dev *ae_dev,
-				     bool is_reg, bool *matched)
+				     struct hnae3_ae_dev *ae_dev, bool is_reg)
 {
 	int ret;
 
-	*matched = false;
-
 	/* check if this client matches the type of ae_dev */
 	if (!(hnae3_client_match(client->type, ae_dev->dev_type) &&
 	      hnae_get_bit(ae_dev->flag, HNAE3_DEV_INITED_B))) {
 		return 0;
 	}
-	/* there is a match of client and dev */
-	*matched = true;
 
 	/* now, (un-)instantiate client by calling lower layer */
 	if (is_reg) {
@@ -69,7 +64,6 @@ int hnae3_register_client(struct hnae3_client *client)
 {
 	struct hnae3_client *client_tmp;
 	struct hnae3_ae_dev *ae_dev;
-	bool matched;
 	int ret = 0;
 
 	mutex_lock(&hnae3_common_lock);
@@ -86,7 +80,7 @@ int hnae3_register_client(struct hnae3_client *client)
 		/* if the client could not be initialized on current port, for
 		 * any error reasons, move on to next available port
 		 */
-		ret = hnae3_match_n_instantiate(client, ae_dev, true, &matched);
+		ret = hnae3_match_n_instantiate(client, ae_dev, true);
 		if (ret)
 			dev_err(&ae_dev->pdev->dev,
 				"match and instantiation failed for port\n");
@@ -102,12 +96,11 @@ EXPORT_SYMBOL(hnae3_register_client);
 void hnae3_unregister_client(struct hnae3_client *client)
 {
 	struct hnae3_ae_dev *ae_dev;
-	bool matched;
 
 	mutex_lock(&hnae3_common_lock);
 	/* un-initialize the client on every matched port */
 	list_for_each_entry(ae_dev, &hnae3_ae_dev_list, node) {
-		hnae3_match_n_instantiate(client, ae_dev, false, &matched);
+		hnae3_match_n_instantiate(client, ae_dev, false);
 	}
 
 	list_del(&client->node);
@@ -124,7 +117,6 @@ int hnae3_register_ae_algo(struct hnae3_ae_algo *ae_algo)
 	const struct pci_device_id *id;
 	struct hnae3_ae_dev *ae_dev;
 	struct hnae3_client *client;
-	bool matched;
 	int ret = 0;
 
 	mutex_lock(&hnae3_common_lock);
@@ -151,13 +143,10 @@ int hnae3_register_ae_algo(struct hnae3_ae_algo *ae_algo)
 		 * initialize the figure out client instance
 		 */
 		list_for_each_entry(client, &hnae3_client_list, node) {
-			ret = hnae3_match_n_instantiate(client, ae_dev, true,
-							&matched);
+			ret = hnae3_match_n_instantiate(client, ae_dev, true);
 			if (ret)
 				dev_err(&ae_dev->pdev->dev,
 					"match and instantiation failed\n");
-			if (matched)
-				break;
 		}
 	}
 
@@ -175,7 +164,6 @@ void hnae3_unregister_ae_algo(struct hnae3_ae_algo *ae_algo)
 	const struct pci_device_id *id;
 	struct hnae3_ae_dev *ae_dev;
 	struct hnae3_client *client;
-	bool matched;
 
 	mutex_lock(&hnae3_common_lock);
 	/* Check if there are matched ae_dev */
@@ -187,12 +175,8 @@ void hnae3_unregister_ae_algo(struct hnae3_ae_algo *ae_algo)
 		/* check the client list for the match with this ae_dev type and
 		 * un-initialize the figure out client instance
 		 */
-		list_for_each_entry(client, &hnae3_client_list, node) {
-			hnae3_match_n_instantiate(client, ae_dev, false,
-						  &matched);
-			if (matched)
-				break;
-		}
+		list_for_each_entry(client, &hnae3_client_list, node)
+			hnae3_match_n_instantiate(client, ae_dev, false);
 
 		ae_algo->ops->uninit_ae_dev(ae_dev);
 		hnae_set_bit(ae_dev->flag, HNAE3_DEV_INITED_B, 0);
@@ -212,7 +196,6 @@ int hnae3_register_ae_dev(struct hnae3_ae_dev *ae_dev)
 	const struct pci_device_id *id;
 	struct hnae3_ae_algo *ae_algo;
 	struct hnae3_client *client;
-	bool matched;
 	int ret = 0;
 
 	mutex_lock(&hnae3_common_lock);
@@ -246,13 +229,10 @@ int hnae3_register_ae_dev(struct hnae3_ae_dev *ae_dev)
 	 * initialize the figure out client instance
 	 */
 	list_for_each_entry(client, &hnae3_client_list, node) {
-		ret = hnae3_match_n_instantiate(client, ae_dev, true,
-						&matched);
+		ret = hnae3_match_n_instantiate(client, ae_dev, true);
 		if (ret)
 			dev_err(&ae_dev->pdev->dev,
 				"match and instantiation failed\n");
-		if (matched)
-			break;
 	}
 
 out_err:
@@ -270,7 +250,6 @@ void hnae3_unregister_ae_dev(struct hnae3_ae_dev *ae_dev)
 	const struct pci_device_id *id;
 	struct hnae3_ae_algo *ae_algo;
 	struct hnae3_client *client;
-	bool matched;
 
 	mutex_lock(&hnae3_common_lock);
 	/* Check if there are matched ae_algo */
@@ -279,12 +258,8 @@ void hnae3_unregister_ae_dev(struct hnae3_ae_dev *ae_dev)
 		if (!id)
 			continue;
 
-		list_for_each_entry(client, &hnae3_client_list, node) {
-			hnae3_match_n_instantiate(client, ae_dev, false,
-						  &matched);
-			if (matched)
-				break;
-		}
+		list_for_each_entry(client, &hnae3_client_list, node)
+			hnae3_match_n_instantiate(client, ae_dev, false);
 
 		ae_algo->ops->uninit_ae_dev(ae_dev);
 		hnae_set_bit(ae_dev->flag, HNAE3_DEV_INITED_B, 0);
-- 
2.11.0
