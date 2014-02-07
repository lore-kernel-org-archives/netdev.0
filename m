From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH v3 net 3/9] bridge: Fix the way to find old local fdb entries in br_fdb_change_mac_address
Date: Fri,  7 Feb 2014 16:48:20 +0900
Message-ID: <1391759306-24956-4-git-send-email-makita.toshiaki@lab.ntt.co.jp>
References: <1391759306-24956-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
To: "David S . Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:46704 "EHLO
	tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751610AbaBGHsp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Feb 2014 02:48:45 -0500
In-Reply-To: <1391759306-24956-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have been always failed to delete the old entry at
br_fdb_change_mac_address() because br_set_mac_address() updates
dev->dev_addr before calling br_fdb_change_mac_address() and
br_fdb_change_mac_address() uses dev->dev_addr to find the old entry.

That update of dev_addr is completely unnecessary because the same work
is done in br_stp_change_bridge_id() which is called right away after
calling br_fdb_change_mac_address().

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Acked-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/bridge/br_device.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index e4401a5..5f655b6 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -187,8 +187,8 @@ static int br_set_mac_address(struct net_device *dev, void *p)
 
 	spin_lock_bh(&br->lock);
 	if (!ether_addr_equal(dev->dev_addr, addr->sa_data)) {
-		memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
 		br_fdb_change_mac_address(br, addr->sa_data);
+		/* Mac address will be changed in br_stp_change_bridge_id(). */
 		br_stp_change_bridge_id(br, addr->sa_data);
 	}
 	spin_unlock_bh(&br->lock);
-- 
1.8.1.2
