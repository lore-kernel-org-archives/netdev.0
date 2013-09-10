From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH net 3/4] bridge: Fix the way the PVID is referenced
Date: Tue, 10 Sep 2013 19:37:31 +0900
Message-ID: <1378809451.3988.11.camel@ubuntu-vm-makita>
References: <1378808874.3988.2.camel@ubuntu-vm-makita>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
To: "David S. Miller" <davem@davemloft.net>,
	Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama500.ecl.ntt.co.jp ([129.60.39.148]:57470 "EHLO
	tama500.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750758Ab3IJKhh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Sep 2013 06:37:37 -0400
In-Reply-To: <1378808874.3988.2.camel@ubuntu-vm-makita>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We are using the VLAN_TAG_PRESENT bit to detect whether the PVID is
set or not at br_get_pvid(), while we don't care about the bit in
adding/deleting the PVID, which makes it impossible to forward any
incomming untagged frame with vlan_filtering enabled.

Since vid 0 cannot be used for the PVID, we can use vid 0 to indicate
that the PVID is not set, which is slightly more efficient than using
the VLAN_TAG_PRESENT.

Fix the problem by getting rid of using the VLAN_TAG_PRESENT.

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
---
 net/bridge/br_private.h | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 598cb0b..435ca4d 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -646,9 +646,7 @@ static inline u16 br_get_pvid(const struct net_port_vlans *v)
 	 * vid wasn't set
 	 */
 	smp_rmb();
-	return (v->pvid & VLAN_TAG_PRESENT) ?
-			(v->pvid & ~VLAN_TAG_PRESENT) :
-			VLAN_N_VID;
+	return v->pvid ?: VLAN_N_VID;
 }
 
 #else
-- 
1.8.1.2
