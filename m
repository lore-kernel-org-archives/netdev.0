From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [PATCH net] gre: Fix MTU sizing check for gretap tunnels
Date: Thu, 11 Jul 2013 13:12:22 -0700
Message-ID: <20130711201152.8775.40579.stgit@ahduyck-hc1.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: pshelar@nicira.com, eric.dumazet@gmail.com, jesse@nicira.com,
	davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:56553 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750734Ab3GKUHy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jul 2013 16:07:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change fixes an MTU sizing issue seen with gretap tunnels when non-gso
packets are sent from the interface.

In my case I was able to reproduce the issue by simply sending a ping of
1421 bytes with the gretap interface created on a device with a standard
1500 mtu.

This fix is based on the fact that the tunnel mtu is already adjusted by
dev->hard_header_len so it would make sense that any packets being compared
against that mtu should also be adjusted by hard_header_len and the tunnel
header instead of just the tunnel header.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

 net/ipv4/ip_tunnel.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index 945734b..ca1cb2d 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -476,7 +476,7 @@ static int tnl_update_pmtu(struct net_device *dev, struct sk_buff *skb,
 			    struct rtable *rt, __be16 df)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
-	int pkt_size = skb->len - tunnel->hlen;
+	int pkt_size = skb->len - tunnel->hlen - dev->hard_header_len;
 	int mtu;
 
 	if (df)
