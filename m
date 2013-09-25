From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: BUG: MARK in OUTPUT + ip_tunnel causes kernel panic
Date: Wed, 25 Sep 2013 10:59:47 +0200
Message-ID: <20130925085947.GY7660@secunet.com>
References: <CAKfDRXgJwyhE6sg1Ej=S35A+-dnPiU9TBA69zb-n7hGXgG+Sxg@mail.gmail.com>
 <loom.20130925T095425-819@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Konstantin Kuzov <master.nosferatu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:53475 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751267Ab3IYI7u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Sep 2013 04:59:50 -0400
Content-Disposition: inline
In-Reply-To: <loom.20130925T095425-819@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 25, 2013 at 08:31:52AM +0000, Konstantin Kuzov wrote:
> Kristian Evensen <kristian.evensen <at> gmail.com> writes:
> 
> > When trying to tunnel traffic originating from the same machine as the
> > tunnel endpoint, I am experiencing kernel panics for some types of
> > traffic (ICMP and UDP). TCP seems not to be affected by this, at least
> > I have not been able to trigger the panic.
> > 
> > I have one tunnel (without an IP address) and use policy routing to
> > steer some traffic through the tunnels.
> [...]
> > An interesting thing is that I have seen different kernel panics being
> > triggered. The other one I have seen has RIP pointing to
> > e1000_xmit_frame() and the message "protocol 0800 is buggy". However,
> > the one I have posted is by far the most common.
> I'm experiencing the same issue on two different machines. It happens on any 
> kernel starting from 3.10 when ip_tunnel/ip_tunnel_core were introduced.
> 

Can you please try the patch below?
I've posted the same patch already to netdev in the morning.

Subject: [PATCH net 1/2] ip_tunnel: Fix a memory corruption in ip_tunnel_xmit

We might extend the used aera of a skb beyond the total
headroom when we install the ipip header. Fix this by
calling skb_cow_head() unconditionally.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/ip_tunnel.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index ac9fabe..b8ce640 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -641,13 +641,13 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 
 	max_headroom = LL_RESERVED_SPACE(rt->dst.dev) + sizeof(struct iphdr)
 			+ rt->dst.header_len;
-	if (max_headroom > dev->needed_headroom) {
+	if (max_headroom > dev->needed_headroom)
 		dev->needed_headroom = max_headroom;
-		if (skb_cow_head(skb, dev->needed_headroom)) {
-			dev->stats.tx_dropped++;
-			dev_kfree_skb(skb);
-			return;
-		}
+
+	if (skb_cow_head(skb, dev->needed_headroom)) {
+		dev->stats.tx_dropped++;
+		dev_kfree_skb(skb);
+		return;
 	}
 
 	err = iptunnel_xmit(rt, skb, fl4.saddr, fl4.daddr, protocol,
-- 
1.7.9.5
