From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next 4/6] bonding: don't validate arp if we don't have to
Date: Wed, 19 Jun 2013 19:34:44 +0200
Message-ID: <1371663286-12518-5-git-send-email-vfalico@redhat.com>
Cc: vfalico@redhat.com, fubar@us.ibm.com, andy@greyhouse.net,
	davem@davemloft.net, linux@8192.net, nicolas.2p.debian@free.fr,
	rick.jones2@hp.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36688 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756847Ab3FSRef (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Jun 2013 13:34:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, we validate all the incoming arps if arp_validate not 0.
However, we don't have to validate backup slaves if arp_validate == active
and vice versa, so return early in bond_arp_rcv() in these cases.

It works correctly now because we verify arp_validate in slave_last_rx(),
however we're just doing useless work in bond_arp_rcv().

Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_main.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index b69c7f0..2cfbb2e 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2624,6 +2624,10 @@ static int bond_arp_rcv(const struct sk_buff *skb, struct bonding *bond,
 		return RX_HANDLER_ANOTHER;
 
 	read_lock(&bond->lock);
+
+	if (!slave_do_arp_validate(bond, slave))
+		goto out_unlock;
+
 	alen = arp_hdr_len(bond->dev);
 
 	pr_debug("bond_arp_rcv: bond %s skb->dev %s\n",
-- 
1.7.1
