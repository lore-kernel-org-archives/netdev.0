From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH 1/3] qlcnic: fix mac learning
Date: Tue, 26 Oct 2010 20:53:07 -0700
Message-ID: <1288151589-32431-2-git-send-email-amit.salecha@qlogic.com>
References: <1288151589-32431-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:28576 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1752597Ab0J0DxL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Oct 2010 23:53:11 -0400
In-Reply-To: <1288151589-32431-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In failover bonding case, same mac address can be programmed on other slave function.
Fw will delete old entry (original func) associated with that mac address.
Need to reporgram mac address, if failover again happen to original function.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h      |    1 +
 drivers/net/qlcnic/qlcnic_main.c |    5 +++++
 2 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index 26c37d3..a60ff17 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -942,6 +942,7 @@ struct qlcnic_ipaddr {
 #define QLCNIC_LOOPBACK_TEST		2
 
 #define QLCNIC_FILTER_AGE	80
+#define QLCNIC_READD_AGE	20
 #define QLCNIC_LB_MAX_FILTERS	64
 
 struct qlcnic_filter {
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index f047c7c..5a3ce08 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -1860,6 +1860,11 @@ qlcnic_send_filter(struct qlcnic_adapter *adapter,
 	hlist_for_each_entry_safe(tmp_fil, tmp_hnode, n, head, fnode) {
 		if (!memcmp(tmp_fil->faddr, &src_addr, ETH_ALEN) &&
 			    tmp_fil->vlan_id == vlan_id) {
+
+			if (jiffies >
+			    (QLCNIC_READD_AGE * HZ + tmp_fil->ftime))
+				qlcnic_change_filter(adapter, src_addr, vlan_id,
+								tx_ring);
 			tmp_fil->ftime = jiffies;
 			return;
 		}
-- 
1.6.0.2

