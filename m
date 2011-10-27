From: Neil Horman <nhorman@tuxdriver.com>
Subject: [RFC PATCH 2/5] net: add FCLONE_SCRATCH use to ipv4 udp path
Date: Thu, 27 Oct 2011 15:53:38 -0400
Message-ID: <1319745221-30880-3-git-send-email-nhorman@tuxdriver.com>
References: <1319745221-30880-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@updev.think-freely.org>,
	Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:38393 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752520Ab1J0TyT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2011 15:54:19 -0400
In-Reply-To: <1319745221-30880-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@updev.think-freely.org>

UDP v4 multicast in a multiple group listener workload is a heavy user of
skb_clone, which can lead to performance problems if memory is constrained and
frame reception rates are high.  Once in the udp path however, we can reserve
the unused storage of the udp datagram and allocate skbs from it quickly.
Modify the udp multicast receive path to reserve storage using the
FCLONE_SCRATCH api to make opportunistic use of this space.

Tested successfully by myself
Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: "David S. Miller" <davem@davemloft.net>
---
 net/ipv4/udp.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index ebaa96b..e1c0b1e 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1489,7 +1489,6 @@ drop:
 	return -1;
 }
 
-
 static void flush_stack(struct sock **stack, unsigned int count,
 			struct sk_buff *skb, unsigned int final)
 {
@@ -1532,6 +1531,8 @@ static int __udp4_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 	int dif;
 	unsigned int i, count = 0;
 
+	skb_make_fclone_scratch(skb);
+
 	spin_lock(&hslot->lock);
 	sk = sk_nulls_head(&hslot->head);
 	dif = skb->dev->ifindex;
-- 
1.7.6.4
