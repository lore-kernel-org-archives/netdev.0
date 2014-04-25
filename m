From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [PATCH net-next 1/6] qlcnic: Optimize MAC learning code
Date: Fri, 25 Apr 2014 17:43:56 -0400
Message-ID: <1398462241-15478-2-git-send-email-jitendra.kalsaria@qlogic.com>
References: <1398462241-15478-1-git-send-email-jitendra.kalsaria@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <shahed.shaikh@qlogic.com>,
	<Dept-HSGLinuxNICDev@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:9299 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751834AbaDYWV7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2014 18:21:59 -0400
In-Reply-To: <1398462241-15478-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

* Use rx_mac_learn instead of mac_learn and eSwitch flag check in Rx path of
  82xx adapter.
* Check for MAC filter overrun only after driver scans through cached MAC address list.
  This will help to update the time stamp of cached MAC addresses even if
  adapter runs out of MAC address filter limit.
* Remove expensive log thrown by driver when MAC address filters are exhausted

Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c | 19 +++++++------------
 1 file changed, 7 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
index 173b3d1..deb2278 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
@@ -305,7 +305,6 @@ static void qlcnic_send_filter(struct qlcnic_adapter *adapter,
 {
 	struct vlan_ethhdr *vh = (struct vlan_ethhdr *)(skb->data);
 	struct ethhdr *phdr = (struct ethhdr *)(skb->data);
-	struct net_device *netdev = adapter->netdev;
 	u16 protocol = ntohs(skb->protocol);
 	struct qlcnic_filter *fil, *tmp_fil;
 	struct hlist_head *head;
@@ -330,13 +329,6 @@ static void qlcnic_send_filter(struct qlcnic_adapter *adapter,
 			return;
 	}
 
-	if (adapter->fhash.fnum >= adapter->fhash.fmax) {
-		adapter->stats.mac_filter_limit_overrun++;
-		netdev_info(netdev, "Can not add more than %d mac-vlan filters, configured %d\n",
-			    adapter->fhash.fmax, adapter->fhash.fnum);
-		return;
-	}
-
 	memcpy(&src_addr, phdr->h_source, ETH_ALEN);
 	hval = qlcnic_mac_hash(src_addr, vlan_id);
 	hindex = hval & (adapter->fhash.fbucket_size - 1);
@@ -353,6 +345,11 @@ static void qlcnic_send_filter(struct qlcnic_adapter *adapter,
 		}
 	}
 
+	if (unlikely(adapter->fhash.fnum >= adapter->fhash.fmax)) {
+		adapter->stats.mac_filter_limit_overrun++;
+		return;
+	}
+
 	fil = kzalloc(sizeof(struct qlcnic_filter), GFP_ATOMIC);
 	if (!fil)
 		return;
@@ -1216,8 +1213,7 @@ qlcnic_process_rcv(struct qlcnic_adapter *adapter,
 	if (!skb)
 		return buffer;
 
-	if (adapter->drv_mac_learn &&
-	    (adapter->flags & QLCNIC_ESWITCH_ENABLED)) {
+	if (adapter->rx_mac_learn) {
 		t_vid = 0;
 		is_lb_pkt = qlcnic_82xx_is_lb_pkt(sts_data0);
 		qlcnic_add_lb_filter(adapter, skb, is_lb_pkt, t_vid);
@@ -1293,8 +1289,7 @@ qlcnic_process_lro(struct qlcnic_adapter *adapter,
 	if (!skb)
 		return buffer;
 
-	if (adapter->drv_mac_learn &&
-	    (adapter->flags & QLCNIC_ESWITCH_ENABLED)) {
+	if (adapter->rx_mac_learn) {
 		t_vid = 0;
 		is_lb_pkt = qlcnic_82xx_is_lb_pkt(sts_data0);
 		qlcnic_add_lb_filter(adapter, skb, is_lb_pkt, t_vid);
-- 
1.8.1.4
