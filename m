From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: IGMP Unsolicited Report Interval too long for IGMPv3?
Date: Mon, 22 Jul 2013 23:51:08 +0200
Message-ID: <20130722215108.GG6538@order.stressinduktion.org>
References: <51ED998D.7000300@youview.com> <20130722211855.GL19643@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: William Manley <william.manley@youview.com>, netdev@vger.kernel.org
To: Benjamin LaHaise <bcrl@kvack.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:33003 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932873Ab3GVVvJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jul 2013 17:51:09 -0400
Content-Disposition: inline
In-Reply-To: <20130722211855.GL19643@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 22, 2013 at 05:18:55PM -0400, Benjamin LaHaise wrote:
> On Mon, Jul 22, 2013 at 09:43:57PM +0100, William Manley wrote:
> > If an IGMP join packet is lost you will not receive data sent to the 
> > multicast group so if no data arrives from that multicast group in a 
> > period of time after the IGMP join a second IGMP join will be sent.  The 
> > delay between joins is the "IGMP Unsolicited Report Interval".
> > 
> > In the kernel this seems to be hard coded to be chosen randomly between 
> > 0-10s.  In our use-case (IPTV) this is too long as it can cause channel 
> > change to be slow in the presence of packet loss.
> > 
> > I would guess that this 10s has come from IGMPv2 RFC2236, which was 
> > reduced to 1s in IGMPv3 RFC3376.
> 
> Reducing the timeout does not solve the problem you are encountering, as 
> any packet loss will still result in a 1 second delay.  I've encountered 
> similar issues dealing with LCP Echo request/replies for keepalive 
> messages on PPP sessions.  The correct approach is to queue the IGMP 
> multicast join with a higher priority than other traffic in the system 
> so that the requests are not lost due to congestion of a single queue.  
> Sending packets with an 802.1p header might be appropriate in your 
> use-case, or perhaps using higher priority internal queues.

Yes, we can do a little bit better. What do you think?

[PATCH net-next] ipv6: send igmpv3/mld packets with TC_PRIO_CONTROL

Reported-by: William Manley <william.manley@youview.com>
Suggested-by: Benjamin LaHaise <bcrl@kvack.org>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/mcast.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 99cd65c..db25b8e 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -44,6 +44,7 @@
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 #include <linux/slab.h>
+#include <linux/pkt_sched.h>
 #include <net/mld.h>
 
 #include <linux/netfilter.h>
@@ -1376,6 +1377,7 @@ static struct sk_buff *mld_newpack(struct inet6_dev *idev, int size)
 	if (!skb)
 		return NULL;
 
+	skb->priority = TC_PRIO_CONTROL;
 	skb_reserve(skb, hlen);
 
 	if (__ipv6_get_lladdr(idev, &addr_buf, IFA_F_TENTATIVE)) {
@@ -1769,7 +1771,7 @@ static void igmp6_send(struct in6_addr *addr, struct net_device *dev, int type)
 		rcu_read_unlock();
 		return;
 	}
-
+	skb->priority = TC_PRIO_CONTROL;
 	skb_reserve(skb, hlen);
 
 	if (ipv6_get_lladdr(dev, &addr_buf, IFA_F_TENTATIVE)) {
-- 
1.8.3.1
