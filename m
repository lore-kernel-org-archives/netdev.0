From: amit.salecha@qlogic.com
Subject: [PATCH NEXT 3/8] qlcnic: fix mac address mgmt
Date: Tue, 22 Jun 2010 06:19:00 -0700
Message-ID: <1277212745-26857-4-git-send-email-amit.salecha@qlogic.com>
References: <1277212745-26857-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	Amit Kumar Salecha <amit.salecha@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:37636 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1754899Ab0FVNTH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jun 2010 09:19:07 -0400
In-Reply-To: <1277212745-26857-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kumar Salecha <amit.salecha@qlogic.com>

We first add mac address in driver local list and then send command to
fw to add same. There are checks in driver to ensure send command doesn't fail
before adding mac address in local list.

But instead fix should be:
Add mac address in fw and if it succeeds, add it in driver local list.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_hw.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_hw.c b/drivers/net/qlcnic/qlcnic_hw.c
index 10ba723..ad12425 100644
--- a/drivers/net/qlcnic/qlcnic_hw.c
+++ b/drivers/net/qlcnic/qlcnic_hw.c
@@ -413,10 +413,15 @@ static int qlcnic_nic_add_mac(struct qlcnic_adapter *adapter, u8 *addr)
 		return -ENOMEM;
 	}
 	memcpy(cur->mac_addr, addr, ETH_ALEN);
-	list_add_tail(&cur->list, &adapter->mac_list);
 
-	return qlcnic_sre_macaddr_change(adapter,
-				cur->mac_addr, QLCNIC_MAC_ADD);
+	if (qlcnic_sre_macaddr_change(adapter,
+				cur->mac_addr, QLCNIC_MAC_ADD)) {
+		kfree(cur);
+		return -EIO;
+	}
+
+	list_add_tail(&cur->list, &adapter->mac_list);
+	return 0;
 }
 
 void qlcnic_set_multi(struct net_device *netdev)
-- 
1.6.0.2

