From: Benjamin LaHaise <bcrl@kvack.org>
Subject: [PATCH 1/2] Fix IPv4 multicast over network namespaces
Date: Tue, 27 Mar 2012 20:44:22 -0400
Message-ID: <20120328004422.GA9894@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:56671 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755999Ab2C1AoW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Mar 2012 20:44:22 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When using multicast over a local bridge feeding a number of LXC guests
using veth, the LXC guests are unable to get a response from other guests
when pinging 224.0.0.1.  Multicast packets did not appear to be getting
delivered to the network namespaces of the guest hosts, and further
inspection showed that the incoming route was pointing to the loopback
device of the host, not the guest.  This lead to the wrong network namespace
being picked up by sockets (like ICMP).  Fix this by using the correct
network namespace when creating the inbound route entry.

Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>
---
 net/ipv4/route.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 12ccf88..3b110a4 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2042,7 +2042,7 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 		if (err < 0)
 			goto e_err;
 	}
-	rth = rt_dst_alloc(init_net.loopback_dev,
+	rth = rt_dst_alloc(dev_net(dev)->loopback_dev,
 			   IN_DEV_CONF_GET(in_dev, NOPOLICY), false);
 	if (!rth)
 		goto e_nobufs;
-- 
1.7.4.1


-- 
"Thought is the essence of where you are now."
