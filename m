From: Junchang Wang <junchangwang@gmail.com>
Subject: [PATCH net-next-2.6] pktgen: adding prefetchw() call
Date: Thu, 9 Dec 2010 10:55:16 +0800
Message-ID: <20101209025511.GC5379@Desktop-Junchang>
References: <20101206063349.GA6147@Desktop-Junchang>
 <20101208.101743.112598404.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, robert.olsson@its.uu.se,
	john.r.fastabend@intel.com, andy.shevchenko@gmail.com,
	netdev@vger.kernel.org, wangjc@mail.ustc.edu.cn
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:36735 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756721Ab0LIDAs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 22:00:48 -0500
Received: by pva4 with SMTP id 4so409422pva.19
        for <netdev@vger.kernel.org>; Wed, 08 Dec 2010 19:00:47 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20101208.101743.112598404.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 08, 2010 at 10:17:43AM -0800, David Miller wrote:
>Your patch was corrupted by your email client, please fix this up
>and resubmit.
Sorry. I'll avoid this next time.  Here's a new version, and I had tested it.
Thanks David and Eric.


We know for sure pktgen is going to write skb->data right after
*_alloc_skb, causing unnecessary cache misses.

Idea is to add a prefetchw() call to prefetch the first cache line
indicated by skb->data. On systems with Adjacent Cache Line Prefetch,
it's probably two cache lines are prefetched.

With this patch, pktgen on Intel SR1625 server with two E5530 
quad-core processors and a single ixgbe-based NIC went from 8.63Mpps
to 9.03Mpps, with 4.6% improvement.


Signed-off-by: Junchang Wang <junchangwang@gmail.com>
Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
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
