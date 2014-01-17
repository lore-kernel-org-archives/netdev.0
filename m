From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v2 net-next 01/12] bonding: remove bond->lock from bond_arp_rcv
Date: Fri, 17 Jan 2014 17:58:49 +0100
Message-ID: <1389977940-17084-2-git-send-email-vfalico@redhat.com>
References: <1389977940-17084-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43153 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750937AbaAQREM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jan 2014 12:04:12 -0500
In-Reply-To: <1389977940-17084-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We're always called with rcu_read_lock() held (bond_arp_rcv() is only
called from bond_handle_frame(), which is rx_handler and always called
under rcu from __netif_receive_skb_core() ).

The slave active/passive and/or bonding params can change in-flight, however
we don't really care about that - we only modify the last time packet was
received, which is harmless.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_main.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index f00dd45..479ca56 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2292,8 +2292,6 @@ int bond_arp_rcv(const struct sk_buff *skb, struct bonding *bond,
 	if (skb->protocol != __cpu_to_be16(ETH_P_ARP))
 		return RX_HANDLER_ANOTHER;
 
-	read_lock(&bond->lock);
-
 	if (!slave_do_arp_validate(bond, slave))
 		goto out_unlock;
 
@@ -2350,7 +2348,6 @@ int bond_arp_rcv(const struct sk_buff *skb, struct bonding *bond,
 		bond_validate_arp(bond, slave, tip, sip);
 
 out_unlock:
-	read_unlock(&bond->lock);
 	if (arp != (struct arphdr *)skb->data)
 		kfree(arp);
 	return RX_HANDLER_ANOTHER;
-- 
1.8.4
