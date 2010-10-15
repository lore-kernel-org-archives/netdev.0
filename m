From: Anders Franzen <Anders.Franzen@ericsson.com>
Subject: ip6_tunnel. mtu/pmtu problems.
Date: Fri, 15 Oct 2010 14:40:39 +0200
Message-ID: <1287146439.27134.491.camel@seasc7941.dyn.rnd.as.sw.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw10.se.ericsson.net ([193.180.251.61]:45419 "EHLO
	mailgw10.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754492Ab0JOMzm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Oct 2010 08:55:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi, I've noticed that the ip6_tunnel driver completly ignore to update
the route when a ''bearer'' has a lower mtu then whats expected by the
tunnel device.

Comparing to the ipip tunnel I found that ip6_tunnel is missing the
following line in the ip6_tnl_dev_setup:
   dev->priv_flags &= ~IFF_XMIT_DST_RELEASE

Since it's not there, all code that are dependent on an skb_dst(skb)
returning something, can be removed.
 this is update_pmtu and icmp_send.

Any how adding the flag to tell the device layer not to release skb->dst
at dev_hard_start_xmit, made things better.

But encap limit is on by default and it consumes 8 bytes, so true mtu
for an ip6_tunnel over a 1500 bytes ethernet shall be 1452 not 1460.

Is it is now I loose the first packet everytime a new route is created.

I updated the driver to take encap_limit into account, if enabled, now
it works even better.

But I have one problem left, and I can reproduce it on the ipv4 ipip
tunnel aswell.

With a bit asymmetric routing setup, I can get the driver to generate an
icmp FRAG_NEEDED. If i configure the routing in such a way that the
forwarding towards the src of the oversized packet, is via the tunnel.

This happends:

Dead loop on virtual device vip4, fix it urgently!

It is because the dev layer has taken a lock on the tx queue for the
device selected for the primary packet (the tunnel), and the tunnel
wants to send an icmp, also on the same device, the lock is held for
transmission of the primary packet, and the icmp gets discarded, with a
nasty kernel msg.

I think this case is a valid case, and the Dead loop is just an
implementation limitation.

Maybe we should try to schedule the icmp do delay it until the primary
packet sending has returned and released the lock.



This is the routing setup I use to trigger the Dead loop, both on ipip
tunnels and ip6_tunnels.


      
 We have 4 nodes A,B,C,D


 C is a router, routing AB to/from D

 B has a tunnel toward C
 B has a default route using the tunnel to C

 A has a route to D pointing to B

 I raise the MTU of the tunnel endpoint at B by a couple of bytes, to
simulate the encap_limit 8 bytes effect when left out. Or actually
having a bearer device indicate a lower mtu than was expected.

let A ping -M do -s 1470 D

A sends to B, B forwards to tunnel, which will calculate it's mtu to
1480 (ipv4) based on its own overhead and the route mtu of the bearer
route. Since we set the MTU of the tunnel higher than that, the tunnel
will send an icmp back to A, but the route here says that you reach A
via the tunnel it self, and Dead loop......


If the lock in the device layer shall be there, then I think the icmp
should be run from a kthread or something?

Any comments?

Best regards 
  Anders 




