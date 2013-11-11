From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net] core/dev: do not ignore dmac in dev_forward_skb()
Date: Mon, 11 Nov 2013 13:52:15 -0800
Message-ID: <1384206735-4226-1-git-send-email-ast@plumgrid.com>
Cc: Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	Maciej Zenczykowski <zenczykowski@gmail.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:44092 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752311Ab3KKVwU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 16:52:20 -0500
Received: by mail-pd0-f169.google.com with SMTP id y13so2912072pdi.0
        for <netdev@vger.kernel.org>; Mon, 11 Nov 2013 13:52:20 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 06a23fe31ca3
("core/dev: set pkt_type after eth_type_trans() in dev_forward_skb()")
and refactoring 64261f230a91
("dev: move skb_scrub_packet() after eth_type_trans()")

are forcing pkt_type to be PACKET_HOST when skb traverses veth.

which means that ip forwarding will kick in inside netns
even if skb->eth->h_dest != dev->dev_addr

Revert offending commit

Fixes: 06a23fe31ca3 ("core/dev: set pkt_type after eth_type_trans() in dev_forward_skb()")
CC: Maciej Zenczykowski <zenczykowski@gmail.com>
CC: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---

commit-06a23fe31ca3's testcase is still working,
since pkt_type is now set by ip tunnel

the diff is for 3.12
imo the bug is severe enough that worth queueing for 3.11

 net/core/dev.c |    6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 3430b1e..2afc521 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1691,13 +1691,9 @@ int dev_forward_skb(struct net_device *dev, struct sk_buff *skb)
 		kfree_skb(skb);
 		return NET_RX_DROP;
 	}
-	skb->protocol = eth_type_trans(skb, dev);
 
-	/* eth_type_trans() can set pkt_type.
-	 * call skb_scrub_packet() after it to clear pkt_type _after_ calling
-	 * eth_type_trans().
-	 */
 	skb_scrub_packet(skb, true);
+	skb->protocol = eth_type_trans(skb, dev);
 
 	return netif_rx(skb);
 }
-- 
1.7.9.5
