From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [PATCH] netdev: simple_tx_hash shouldn't hash inside fragments
Date: Thu, 18 Sep 2008 17:43:37 -0700
Message-ID: <20080919004337.10035.3409.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:43790 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755822AbYISAnj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Sep 2008 20:43:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently simple_tx_hash is hashing inside of udp fragments.  As a result
packets are getting getting sent to all queues when they shouldn't be.
This causes a serious performance regression which can be seen by sending
UDP frames larger than mtu on multiqueue devices.  This change will make
it so that fragments are hashed only as IP datagrams w/o any protocol
information.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

 net/core/dev.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 60c51f7..5d9fa1e 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -122,6 +122,7 @@
 #include <linux/if_arp.h>
 #include <linux/if_vlan.h>
 #include <linux/ip.h>
+#include <net/ip.h>
 #include <linux/ipv6.h>
 #include <linux/in.h>
 #include <linux/jhash.h>
@@ -1667,7 +1668,7 @@ static u16 simple_tx_hash(struct net_device *dev, struct sk_buff *skb)
 {
 	u32 addr1, addr2, ports;
 	u32 hash, ihl;
-	u8 ip_proto;
+	u8 ip_proto = 0;
 
 	if (unlikely(!simple_tx_hashrnd_initialized)) {
 		get_random_bytes(&simple_tx_hashrnd, 4);
@@ -1676,7 +1677,8 @@ static u16 simple_tx_hash(struct net_device *dev, struct sk_buff *skb)
 
 	switch (skb->protocol) {
 	case __constant_htons(ETH_P_IP):
-		ip_proto = ip_hdr(skb)->protocol;
+		if (!(ip_hdr(skb)->frag_off & htons(IP_MF | IP_OFFSET)))
+			ip_proto = ip_hdr(skb)->protocol;
 		addr1 = ip_hdr(skb)->saddr;
 		addr2 = ip_hdr(skb)->daddr;
 		ihl = ip_hdr(skb)->ihl;

