From: weiyj_lk@163.com
Subject: [PATCH v2] ibmvnic: fix to use list_for_each_safe() when delete items
Date: Mon, 27 Jun 2016 20:48:53 +0800
Message-ID: <1467031733-13137-1-git-send-email-weiyj_lk@163.com>
References: <20160625.120241.1521209512436530662.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <yongjun_wei@trendmicro.com.cn>,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Thomas Falcon <tlfalcon@linux.vnet.ibm.com>,
	John Allen <jallen@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-15.163.com ([220.181.12.15]:40177 "EHLO m12-15.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751639AbcF0Mte (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jun 2016 08:49:34 -0400
In-Reply-To: <20160625.120241.1521209512436530662.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Since we will remove items off the list using list_del() we need
to use a safe version of the list_for_each() macro aptly named
list_for_each_safe().

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/ethernet/ibm/ibmvnic.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 864cb21..ecdb685 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -2121,7 +2121,7 @@ static void handle_error_info_rsp(union ibmvnic_crq *crq,
 				  struct ibmvnic_adapter *adapter)
 {
 	struct device *dev = &adapter->vdev->dev;
-	struct ibmvnic_error_buff *error_buff;
+	struct ibmvnic_error_buff *error_buff, *tmp;
 	unsigned long flags;
 	bool found = false;
 	int i;
@@ -2133,7 +2133,7 @@ static void handle_error_info_rsp(union ibmvnic_crq *crq,
 	}
 
 	spin_lock_irqsave(&adapter->error_list_lock, flags);
-	list_for_each_entry(error_buff, &adapter->errors, list)
+	list_for_each_entry_safe(error_buff, tmp, &adapter->errors, list)
 		if (error_buff->error_id == crq->request_error_rsp.error_id) {
 			found = true;
 			list_del(&error_buff->list);
@@ -3141,14 +3141,14 @@ static void handle_request_ras_comp_num_rsp(union ibmvnic_crq *crq,
 
 static void ibmvnic_free_inflight(struct ibmvnic_adapter *adapter)
 {
-	struct ibmvnic_inflight_cmd *inflight_cmd;
+	struct ibmvnic_inflight_cmd *inflight_cmd, *tmp1;
 	struct device *dev = &adapter->vdev->dev;
-	struct ibmvnic_error_buff *error_buff;
+	struct ibmvnic_error_buff *error_buff, *tmp2;
 	unsigned long flags;
 	unsigned long flags2;
 
 	spin_lock_irqsave(&adapter->inflight_lock, flags);
-	list_for_each_entry(inflight_cmd, &adapter->inflight, list) {
+	list_for_each_entry_safe(inflight_cmd, tmp1, &adapter->inflight, list) {
 		switch (inflight_cmd->crq.generic.cmd) {
 		case LOGIN:
 			dma_unmap_single(dev, adapter->login_buf_token,
@@ -3165,8 +3165,8 @@ static void ibmvnic_free_inflight(struct ibmvnic_adapter *adapter)
 			break;
 		case REQUEST_ERROR_INFO:
 			spin_lock_irqsave(&adapter->error_list_lock, flags2);
-			list_for_each_entry(error_buff, &adapter->errors,
-					    list) {
+			list_for_each_entry_safe(error_buff, tmp2,
+						 &adapter->errors, list) {
 				dma_unmap_single(dev, error_buff->dma,
 						 error_buff->len,
 						 DMA_FROM_DEVICE);
