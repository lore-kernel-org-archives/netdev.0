From: Chonggang Li <chonggangli@google.com>
Subject: [PATCH net-next v3] bonding: deliver link-local packets with skb->dev set to link that packets arrived on
Date: Mon, 17 Apr 2017 12:19:48 -0700
Message-ID: <20170417191948.89493-1-chonggangli@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Chonggang Li <chonggangli@google.com>,
        Mahesh Bandewar <maheshb@google.com>,
        =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>,
        Jay Vosburgh <jay.vosburgh@canonical.com>
To: j.vosburgh@gmail.com, andy@greyhouse.net, vfalico@gmail.com,
        nikolay@redhat.com, edumazet@google.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:33997 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754147AbdDQTUN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2017 15:20:13 -0400
Received: by mail-pg0-f42.google.com with SMTP id z127so12484346pgb.1
        for <netdev@vger.kernel.org>; Mon, 17 Apr 2017 12:20:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bonding driver changes the skb->dev to the bonding-master before
passing the packet to stack for further processing. This, however
does not make sense for the link-local packets and it loses "the
link info" once its skb->dev is changed to bonding-master.  This
patch changes this behavior for link-local packets by not changing
the skb->dev to the bonding-master and maintaining it as it is,
i.e. the link on which the packet arrived.

Signed-off-by: Chonggang Li <chonggangli@google.com>
Signed-off-by: Mahesh Bandewar <maheshb@google.com>
Signed-off-by: Maciej Żenczykowski <maze@google.com>
Signed-off-by: Jay Vosburgh <jay.vosburgh@canonical.com>
---
Changes in v2:
  - Make the commit message more clearer.
Changes in v3:
  - Fix a typo in commit message.

 drivers/net/bonding/bond_main.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 01e4a69af421..6bd3b50faf48 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1176,6 +1176,9 @@ static rx_handler_result_t bond_handle_frame(struct sk_buff **pskb)
 		}
 	}
 
+	/* don't change skb->dev for link-local packets */
+	if (is_link_local_ether_addr(eth_hdr(skb)->h_dest))
+		return RX_HANDLER_PASS;
 	if (bond_should_deliver_exact_match(skb, slave, bond))
 		return RX_HANDLER_EXACT;
 
-- 
2.12.2.762.g0e3151a226-goog
