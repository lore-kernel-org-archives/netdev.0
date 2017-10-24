From: Lipeng <lipeng321@huawei.com>
Subject: [PATCH net-next 3/4] net: hns3: fix a bug in hclge_uninit_client_instance
Date: Tue, 24 Oct 2017 21:02:11 +0800
Message-ID: <1508850132-106101-4-git-send-email-lipeng321@huawei.com>
References: <1508850132-106101-1-git-send-email-lipeng321@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linuxarm@huawei.com>, <yisen.zhuang@huawei.com>,
        <salil.mehta@huawei.com>, <lipeng321@huawei.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga06-in.huawei.com ([45.249.212.32]:34639 "EHLO huawei.com"
        rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751935AbdJXMeb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 24 Oct 2017 08:34:31 -0400
In-Reply-To: <1508850132-106101-1-git-send-email-lipeng321@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

HNS3 driver initialize hdev->roce_client and vport->roce.client in
hclge_init_client_instance, and need set hdev->roce_client and
vport->roce.client NULL.

If do not set them NULL when uninit, it will fail in the scene:
insmod hns3.ko, hns-roce.ko, hns-roce-hw-v3.ko successfully, but
rmmod hns3.ko after rmmod hns-roce-hw-v2.ko and hns-roce.ko.
This patch fixes the issue.

Fixes: 46a3df9 (net: hns3: Add HNS3 Acceleration Engine & Compatibility Layer Support)

Signed-off-by: Lipeng <lipeng321@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
index 2c22d3c..d11a9a5 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
@@ -4311,13 +4311,19 @@ static void hclge_uninit_client_instance(struct hnae3_client *client,
 
 	for (i = 0; i < hdev->num_vmdq_vport + 1; i++) {
 		vport = &hdev->vport[i];
-		if (hdev->roce_client)
+		if (hdev->roce_client) {
 			hdev->roce_client->ops->uninit_instance(&vport->roce,
 								0);
+			hdev->roce_client = NULL;
+			vport->roce.client = NULL;
+		}
 		if (client->type == HNAE3_CLIENT_ROCE)
 			return;
-		if (client->ops->uninit_instance)
+		if (client->ops->uninit_instance) {
 			client->ops->uninit_instance(&vport->nic, 0);
+			hdev->nic_client = NULL;
+			vport->nic.client = NULL;
+		}
 	}
 }
 
-- 
1.9.1
