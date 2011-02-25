From: Andy Gospodarek <andy@greyhouse.net>
Subject: [PATCH net-2.6] bonding: drop frames received with master's source MAC
Date: Fri, 25 Feb 2011 16:13:28 -0500
Message-ID: <1298668408-14849-1-git-send-email-andy@greyhouse.net>
Cc: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Jay Vosburgh <fubar@us.ibm.com>, Jiri Pirko <jpirko@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26101 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753076Ab1BYVN2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Feb 2011 16:13:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I was looking at my system and wondering why I sometimes saw these
DAD messages in my logs:

bond0: IPv6 duplicate address fe80::21b:21ff:fe38:2ec4 detected!

I traced it back and realized the IPv6 Neighbor Solicitations I was
sending were also coming back into the stack on the slave(s) that did
not transmit the frames.  I could not think of a compelling reason to
notify the user that a NS we sent came back, so I set out to just drop
the frame silently in ndisc_recv_ns drop.

That seemed to work well, but when I thought about it I could not
compelling reason to save any of these frames.  Dropping them as soon as
we get them seems like a much better idea as it fixes other issues that
may exist for more than just IPv6 DAD.

I chose to check the incoming frame against the master's MAC address as
that should be the MAC address used anytime a broadcast frame is sent by
the bonding driver that had the chance to make its way back into one of
the other devices.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
Cc: David Miller <davem@davemloft.net>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Jay Vosburgh <fubar@us.ibm.com>
Cc: Jiri Pirko <jpirko@redhat.com>

---

I realize this patch comes right in the middle of Jiri Pirko's attempts
to move this functionality to the bonding driver, but I think this may
be important enough to include now (possibly in 2.6.38 and to -stable)
if others agree.

---
 net/core/dev.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 8ae6631..4a76ccd 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2971,6 +2971,11 @@ static inline void skb_bond_set_mac_by_master(struct sk_buff *skb,
 int __skb_bond_should_drop(struct sk_buff *skb, struct net_device *master)
 {
 	struct net_device *dev = skb->dev;
+	struct ethhdr *eth = eth_hdr(skb);
+
+	/* Drop all frames with the bond master's source address. */
+	if (unlikely(!compare_ether_addr(eth->h_source, master->dev_addr)))
+		return 1;
 
 	if (master->priv_flags & IFF_MASTER_ARPMON)
 		dev->last_rx = jiffies;
-- 
1.7.4

