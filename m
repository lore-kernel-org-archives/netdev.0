From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 3/3] bonding: choose the correct vlan proto for alb_send_learning_packets
Date: Tue, 11 Mar 2014 11:43:42 +0800
Message-ID: <1394509422-8704-4-git-send-email-dingtianhong@huawei.com>
References: <1394509422-8704-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <fubar@us.ibm.com>, <vfalico@redhat.com>, <andy@greyhouse.net>,
	<kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:56934 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754158AbaCKDpW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 23:45:22 -0400
In-Reply-To: <1394509422-8704-1-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The vlan support 2 proto: 802.1q and 802.1ad, but the
alb_send_learning_packets could only use proto 802.1q,
add support for 802.1ad

Cc: Jay Vosburgh <fubar@us.ibm.com>
Cc: Veaceslav Falico <vfalico@redhat.com>
Cc: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_alb.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index aaeeacf..ef98bc8 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -995,7 +995,7 @@ static void rlb_clear_vlan(struct bonding *bond, unsigned short vlan_id)
 /*********************** tlb/rlb shared functions *********************/
 
 static void alb_send_lp_vid(struct slave *slave, u8 mac_addr[],
-			    u16 vid)
+			    __be16 proto, u16 vid)
 {
 	struct learning_pkt pkt;
 	struct sk_buff *skb;
@@ -1021,7 +1021,7 @@ static void alb_send_lp_vid(struct slave *slave, u8 mac_addr[],
 	skb->dev = slave->dev;
 
 	if (vid) {
-		skb = vlan_put_tag(skb, htons(ETH_P_8021Q), vid);
+		skb = vlan_put_tag(skb, proto, vid);
 		if (!skb) {
 			pr_err("%s: Error: failed to insert VLAN tag\n",
 			       slave->bond->dev->name);
@@ -1040,13 +1040,14 @@ static void alb_send_learning_packets(struct slave *slave, u8 mac_addr[])
 	struct list_head *iter;
 
 	/* send untagged */
-	alb_send_lp_vid(slave, mac_addr, 0);
+	alb_send_lp_vid(slave, mac_addr, 0, 0);
 
 	/* loop through vlans and send one packet for each */
 	rcu_read_lock();
 	netdev_for_each_all_upper_dev_rcu(bond->dev, upper, iter) {
 		if (upper->priv_flags & IFF_802_1Q_VLAN)
 			alb_send_lp_vid(slave, mac_addr,
+					vlan_dev_vlan_proto(upper),
 					vlan_dev_vlan_id(upper));
 	}
 	rcu_read_unlock();
-- 
1.8.0
