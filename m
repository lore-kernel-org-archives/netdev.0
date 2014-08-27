From: Andreea-Cristina Bernat <bernat.ada@gmail.com>
Subject: [PATCH] bonding: bond_alb: Replace rcu_dereference() with
 rcu_access_pointer()
Date: Wed, 27 Aug 2014 17:18:27 +0300
Message-ID: <20140827141827.GA11520@ada>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: paulmck@linux.vnet.ibm.com
To: j.vosburgh@gmail.com, vfalico@gmail.com, andy@greyhouse.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:41191 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934828AbaH0OSj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 10:18:39 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The "curr_active_slave" local variable obtained through the rcu_dereference()
call it is not dereferenced in the rest of the function.
Therefore, it is recommended to use rcu_access_pointer() instead of
rcu_dereference().
This patch makes the replacement.

The first step to detect this was made with the following Coccinelle semantic
patch:
@@
identifier p;
@@

* p = rcu_dereference(...)
... when any
    when != p
(
* if( (<+...p...+>) ) { ... }
|
* while( (<+...p...+>) ) { ... }
)
... when != p

After the analysis of the output, the change was made manually.

Signed-off-by: Andreea-Cristina Bernat <bernat.ada@gmail.com>
---
 drivers/net/bonding/bond_alb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 1319c5b..6621ac2 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -659,7 +659,7 @@ static struct slave *rlb_choose_channel(struct sk_buff *skb, struct bonding *bon
 
 	_lock_rx_hashtbl(bond);
 
-	curr_active_slave = rcu_dereference(bond->curr_active_slave);
+	curr_active_slave = rcu_access_pointer(bond->curr_active_slave);
 
 	hash_index = _simple_hash((u8 *)&arp->ip_dst, sizeof(arp->ip_dst));
 	client_info = &(bond_info->rx_hashtbl[hash_index]);
-- 
1.9.1
