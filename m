From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Subject: [PATCH net-next-2.6 2/4] jme: Fix pci sync
Date: Sat, 28 Feb 2009 11:57:01 +0800
Message-ID: <20090228035701.M35707@cooldavid.org>
References: <20080915165101.M68109@cooldavid.org> <48D27CDA.50501@pobox.com> <20081008215853.M53590@cooldavid.org>
Reply-To: cooldavid@cooldavid.org
Mime-Version: 1.0
Content-Type: text/plain;
	charset=big5
Cc: netdev@vger.kernel.org, Ethan <ethanhsiao@jmicron.com>
To: Jeff Garzik <jgarzik@pobox.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cooldavid.org ([220.133.139.86]:46793 "EHLO cooldavid.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753581AbZB1D6S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Feb 2009 22:58:18 -0500
In-Reply-To: <20081008215853.M53590@cooldavid.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


We should sync ring descriptor to pci device after modifying it.
Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>

diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index 60cb997..f65a09c 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -1833,7 +1833,7 @@ jme_tx_vlan(struct sk_buff *skb, __le16 *vlan, u8 *flags)
 }
 
 static int
-jme_fill_first_tx_desc(struct jme_adapter *jme, struct sk_buff *skb, int idx)
+jme_fill_tx_desc(struct jme_adapter *jme, struct sk_buff *skb, int idx)
 {
 	struct jme_ring *txring = jme->txring;
 	struct txdesc *txdesc;
@@ -1863,6 +1863,7 @@ jme_fill_first_tx_desc(struct jme_adapter *jme, struct sk_buff *skb, int idx)
 	if (jme_tx_tso(skb, &txdesc->desc1.mss, &flags))
 		jme_tx_csum(jme, skb, &flags);
 	jme_tx_vlan(skb, &txdesc->desc1.vlan, &flags);
+	jme_map_tx_skb(jme, skb, idx);
 	txdesc->desc1.flags = flags;
 	/*
 	 * Set tx buffer info after telling NIC to send
@@ -1932,8 +1933,7 @@ jme_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 		return NETDEV_TX_BUSY;
 	}
 
-	jme_map_tx_skb(jme, skb, idx);
-	jme_fill_first_tx_desc(jme, skb, idx);
+	jme_fill_tx_desc(jme, skb, idx);
 
 	jwrite32(jme, JME_TXCS, jme->reg_txcs |
 				TXCS_SELECT_QUEUE0 |

