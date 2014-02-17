From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v4 net-next 07/12] bonding: use the new options to correctly set last_arp_rx
Date: Mon, 17 Feb 2014 15:41:23 +0100
Message-ID: <1392648088-21336-8-git-send-email-vfalico@redhat.com>
References: <1392648088-21336-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Rob Landley <rob@landley.net>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Ding Tianhong <dingtianhong@huawei.com>,
	Neil Horman <nhorman@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51452 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753883AbaBQOqE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Feb 2014 09:46:04 -0500
In-Reply-To: <1392648088-21336-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that the options are in place - arp_validate can be set to receive all
the traffic or only arp packets to verify if the slave is up, when the
slave isn't validated.

CC: Rob Landley <rob@landley.net>
CC: "David S. Miller" <davem@davemloft.net>
CC: Nikolay Aleksandrov <nikolay@redhat.com>
CC: Ding Tianhong <dingtianhong@huawei.com>
CC: Neil Horman <nhorman@tuxdriver.com>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_main.c | 15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 257ee7f..3fe81cd 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2255,15 +2255,16 @@ int bond_arp_rcv(const struct sk_buff *skb, struct bonding *bond,
 	struct arphdr *arp = (struct arphdr *)skb->data;
 	unsigned char *arp_ptr;
 	__be32 sip, tip;
-	int alen;
+	int alen, is_arp = skb->protocol == __cpu_to_be16(ETH_P_ARP);
 
-	slave->last_arp_rx = jiffies;
-
-	if (skb->protocol != __cpu_to_be16(ETH_P_ARP))
+	if (!slave_do_arp_validate(bond, slave)) {
+		if ((slave_do_arp_validate_only(bond, slave) && is_arp) ||
+		    !slave_do_arp_validate_only(bond, slave))
+			slave->last_arp_rx = jiffies;
 		return RX_HANDLER_ANOTHER;
-
-	if (!slave_do_arp_validate(bond, slave))
-		goto out_unlock;
+	} else if (!is_arp) {
+		return RX_HANDLER_ANOTHER;
+	}
 
 	alen = arp_hdr_len(bond->dev);
 
-- 
1.8.4
