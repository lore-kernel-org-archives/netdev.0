From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCHv2 NEXT 4/8] qlcnic: fix endianess for lro
Date: Mon,  4 Oct 2010 07:20:12 -0700
Message-ID: <1286202016-18026-5-git-send-email-amit.salecha@qlogic.com>
References: <1286202016-18026-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:63897 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1754312Ab0JDOUS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Oct 2010 10:20:18 -0400
In-Reply-To: <1286202016-18026-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>

ipaddress in ifa->ifa_address field are in big endian format.
Also device requires ip address in big endian only.

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h    |    7 ++++++-
 drivers/net/qlcnic/qlcnic_hw.c |    6 ++++--
 2 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index 4667463..7af3c6c 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -898,6 +898,11 @@ struct qlcnic_mac_req {
 	u8 mac_addr[6];
 };
 
+struct qlcnic_ipaddr {
+	__be32 ipv4;
+	__be32 ipv6[4];
+};
+
 #define QLCNIC_MSI_ENABLED		0x02
 #define QLCNIC_MSIX_ENABLED		0x04
 #define QLCNIC_LRO_ENABLED		0x08
@@ -1286,7 +1291,7 @@ void qlcnic_free_mac_list(struct qlcnic_adapter *adapter);
 int qlcnic_nic_set_promisc(struct qlcnic_adapter *adapter, u32);
 int qlcnic_config_intr_coalesce(struct qlcnic_adapter *adapter);
 int qlcnic_config_rss(struct qlcnic_adapter *adapter, int enable);
-int qlcnic_config_ipaddr(struct qlcnic_adapter *adapter, u32 ip, int cmd);
+int qlcnic_config_ipaddr(struct qlcnic_adapter *adapter, __be32 ip, int cmd);
 int qlcnic_linkevent_request(struct qlcnic_adapter *adapter, int enable);
 void qlcnic_advert_link_change(struct qlcnic_adapter *adapter, int linkup);
 
diff --git a/drivers/net/qlcnic/qlcnic_hw.c b/drivers/net/qlcnic/qlcnic_hw.c
index c198df9..68d5693 100644
--- a/drivers/net/qlcnic/qlcnic_hw.c
+++ b/drivers/net/qlcnic/qlcnic_hw.c
@@ -676,9 +676,10 @@ int qlcnic_config_rss(struct qlcnic_adapter *adapter, int enable)
 	return rv;
 }
 
-int qlcnic_config_ipaddr(struct qlcnic_adapter *adapter, u32 ip, int cmd)
+int qlcnic_config_ipaddr(struct qlcnic_adapter *adapter, __be32 ip, int cmd)
 {
 	struct qlcnic_nic_req req;
+	struct qlcnic_ipaddr *ipa;
 	u64 word;
 	int rv;
 
@@ -689,7 +690,8 @@ int qlcnic_config_ipaddr(struct qlcnic_adapter *adapter, u32 ip, int cmd)
 	req.req_hdr = cpu_to_le64(word);
 
 	req.words[0] = cpu_to_le64(cmd);
-	req.words[1] = cpu_to_le64(ip);
+	ipa = (struct qlcnic_ipaddr *)&req.words[1];
+	ipa->ipv4 = ip;
 
 	rv = qlcnic_send_cmd_descs(adapter, (struct cmd_desc_type0 *)&req, 1);
 	if (rv != 0)
-- 
1.6.3.3

