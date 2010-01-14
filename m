From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 2/4] netxen: fix endianness intr coalesce
Date: Thu, 14 Jan 2010 03:53:22 -0800
Message-ID: <1263470004-30008-3-git-send-email-amit.salecha@qlogic.com>
References: <1263470004-30008-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, dhananjay.phadke@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:60079 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1755280Ab0ANLxZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jan 2010 06:53:25 -0500
In-Reply-To: <1263470004-30008-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before sending Interrupt coalesce parameters to device,
convert them in little endian.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/netxen/netxen_nic_hw.c |   13 ++++++++-----
 1 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 0db36f1..9548e59 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -777,17 +777,20 @@ int netxen_p3_nic_set_mac_addr(struct netxen_adapter *adapter, u8 *addr)
 int netxen_config_intr_coalesce(struct netxen_adapter *adapter)
 {
 	nx_nic_req_t req;
-	u64 word;
-	int rv;
+	u64 word[6];
+	int rv, i;
 
 	memset(&req, 0, sizeof(nx_nic_req_t));
+	memset(word, 0, sizeof(word));
 
 	req.qhdr = cpu_to_le64(NX_HOST_REQUEST << 23);
 
-	word = NETXEN_CONFIG_INTR_COALESCE | ((u64)adapter->portnum << 16);
-	req.req_hdr = cpu_to_le64(word);
+	word[0] = NETXEN_CONFIG_INTR_COALESCE | ((u64)adapter->portnum << 16);
+	req.req_hdr = cpu_to_le64(word[0]);
 
-	memcpy(&req.words[0], &adapter->coal, sizeof(adapter->coal));
+	memcpy(&word[0], &adapter->coal, sizeof(adapter->coal));
+	for (i = 0; i < 6; i++)
+		req.words[i] = cpu_to_le64(word[i]);
 
 	rv = netxen_send_cmd_descs(adapter, (struct cmd_desc_type0 *)&req, 1);
 	if (rv != 0) {
-- 
1.6.0.2

