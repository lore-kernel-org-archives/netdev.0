From: Junchang Wang <junchangwang@gmail.com>
Subject: [PATCH net-next-2.6] pktgen: adding prefetchw() call
Date: Mon, 6 Dec 2010 14:33:52 +0800
Message-ID: <20101206063349.GA6147@Desktop-Junchang>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, eric.dumazet@gmail.com,
	robert.olsson@its.uu.se, john.r.fastabend@intel.com,
	andy.shevchenko@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:51970 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751260Ab0LFGeI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Dec 2010 01:34:08 -0500
Received: by iwn6 with SMTP id 6so2985820iwn.19
        for <netdev@vger.kernel.org>; Sun, 05 Dec 2010 22:34:08 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


We know for sure pktgen is going to write skb->data right after
*_alloc_skb, causing unnecessary cache misses.

Idea is to add a prefetchw() call to prefetch the first cache line
indicated by skb->data. On systems with Adjacent Cache Line Prefetch,
it's probably two cache lines are prefetched.

With this prefetch, pktgen on Intel SR1625 server with two E5530 
quad-core processors and a single ixgbe-based NIC went from 8.63Mpps
to 9.03Mpps, with 4.6% improvement.


Signed-off-by: Junchang Wang <junchangwang@gmail.com>
---
 net/core/pktgen.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 2953b2a..18fe20d 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2660,6 +2660,7 @@ static struct sk_buff *fill_packet_ipv4(struct net_device *odev,
 		sprintf(pkt_dev->result, "No memory");
 		return NULL;
 	}
+	prefetchw(skb->data);
 
 	skb_reserve(skb, datalen);
 
@@ -3007,6 +3008,7 @@ static struct sk_buff *fill_packet_ipv6(struct net_device *odev,
 		sprintf(pkt_dev->result, "No memory");
 		return NULL;
 	}
+	prefetchw(skb->data);
 
 	skb_reserve(skb, 16);
--

--Junchang 
