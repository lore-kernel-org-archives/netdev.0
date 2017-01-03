From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH net-next v2 03/27] ibmvnic: fix accelerated VLAN handling
Date: Tue,  3 Jan 2017 21:52:33 +0100 (CET)
Message-ID: <bc67b93104161cfb873ebcbe4918b4bdd715cb41.1483475202.git.mirq-linux@rere.qmqm.pl>
References: <cover.1483475202.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>,
        John Allen <jallen@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([84.10.57.10]:34674 "EHLO rere.qmqm.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934875AbdACUwh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Jan 2017 15:52:37 -0500
In-Reply-To: <cover.1483475202.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Michał Mirosław <mirq-linux@rere.qmqm.pl>
---
 drivers/net/ethernet/ibm/ibmvnic.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index c12596676bbb..c7664db9019c 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -765,7 +765,7 @@ static int ibmvnic_xmit(struct sk_buff *skb, struct net_device *netdev)
 	tx_crq.v1.sge_len = cpu_to_be32(skb->len);
 	tx_crq.v1.ioba = cpu_to_be64(data_dma_addr);
 
-	if (adapter->vlan_header_insertion) {
+	if (adapter->vlan_header_insertion && skb_vlan_tag_present(skb)) {
 		tx_crq.v1.flags2 |= IBMVNIC_TX_VLAN_INSERT;
 		tx_crq.v1.vlan_id = cpu_to_be16(skb->vlan_tci);
 	}
@@ -964,7 +964,8 @@ static int ibmvnic_poll(struct napi_struct *napi, int budget)
 		skb = rx_buff->skb;
 		skb_copy_to_linear_data(skb, rx_buff->data + offset,
 					length);
-		skb->vlan_tci = be16_to_cpu(next->rx_comp.vlan_tci);
+		if (flags & IBMVNIC_VLAN_STRIPPED)
+			__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), be16_to_cpu(next->rx_comp.vlan_tci));
 		/* free the entry */
 		next->rx_comp.first = 0;
 		remove_buff_from_pool(adapter, rx_buff);
-- 
2.11.0
