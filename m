From: Isaku Yamahata <yamahata@valinux.co.jp>
Subject: Re: [PATCH] loopback: set pkt_type to PACKET_HOST explicitly
Date: Wed, 26 Jun 2013 18:37:51 +0900
Message-ID: <20130626093751.GB8524@valinux.co.jp>
References: <0cd1047a2432736459fabbe97a8fb81c449fd827.1372232028.git.yamahata@valinux.co.jp> <1372236022.3301.128.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, murphy.mccauley@gmail.com,
	Pravin B Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@nicira.com>, dev@openvswitch.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.valinux.co.jp ([210.128.90.3]:60631 "EHLO
	mail.valinux.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752091Ab3FZJhw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jun 2013 05:37:52 -0400
Content-Disposition: inline
In-Reply-To: <1372236022.3301.128.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 26, 2013 at 01:40:22AM -0700, Eric Dumazet wrote:
> On Wed, 2013-06-26 at 16:34 +0900, Isaku Yamahata wrote:
> > Reset pkt_type to PACKET_HOST when loopback device receives packet
> > before calling eth_type_trans()
> > 
> > ip-encapsulated packets can be handled by localhost. But skb->pkt_type
> > can be PACKET_OTHERHOST when packet comes into ip tunnel device. In that case,
> > the packet is dropped by ip_rcv() because loopback_xmit() doesn't set
> > skb->pkt_type to PACKET_HOST.
> > 
> > netns A |                     root netns                      | netns B
> >    veth<->veth=bridge=gretap <-loop back-> gretap=bridge=veth<->veth
> > 
> > arp packet ->
> > pkt_type
> >          BROADCAST----loopback_xmit()-->ip_rcv()------------------->
> > 
> >                                                              <- arp reply
> >                                                                 pkt_type
> >                        ip_rcv()<---loopback_xmit()-----OTHERHOST
> >                        drop
> > 
> > sample operations
> >   ip link add tapa type gretap remote 172.17.107.4 local 172.17.107.3
> >   ip link add tapb type gretap remote 172.17.107.3 local 172.17.107.4
> >   ip link set tapa up
> >   ip link set tapb up
> >   ip address add 172.17.107.3 dev tapa
> >   ip address add 172.17.107.4 dev tapb
> >   ip route get 172.17.107.3
> >   > local 172.17.107.3 dev lo  src 172.17.107.3
> >   >    cache <local>
> >   ip route get 172.17.107.4
> >   > local 172.17.107.4 dev lo  src 172.17.107.4
> >   >    cache <local>
> >   ip link add vetha type veth peer name vetha-peer
> >   ip link add vethb type veth peer name vethb-peer
> >   brctl addbr bra
> >   brctl addbr brb
> >   brctl addif bra tapa
> >   brctl addif bra vetha-peer
> >   brctl addif brb tapb
> >   brctl addif brb vethb-peer
> >   brctl show
> >   > bridge name     bridge id               STP enabled     interfaces
> >   > bra             8000.6ea21e758ff1       no              tapa
> >   >                                                         vetha-peer
> >   > brb             8000.420020eb92d5       no              tapb
> >   >                                                         vethb-peer
> >   ip link set vetha-peer up
> >   ip link set vethb-peer up
> >   ip link set bra up
> >   ip link set brb up
> >   ip netns add a
> >   ip netns add b
> >   ip link set vetha netns a
> >   ip link set vethb netns b
> >   ip netns exec a ip address add 10.0.0.3/24 dev vetha
> >   ip netns exec b ip address add 10.0.0.4/24 dev vethb
> >   ip netns exec a ip link set vetha up
> >   ip netns exec b ip link set vethb up
> >   ip netns exec a arping -I vetha 10.0.0.4
> >   ARPING 10.0.0.4 from 10.0.0.3 vetha
> >   ^CSent 2 probes (2 broadcast(s))
> >   Received 0 response(s)
> > 
> > Cc: Pravin B Shelar <pshelar@nicira.com>
> > Cc: Jesse Gross <jesse@nicira.com>
> > Cc: dev@openvswitch.org
> > Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
> > ---
> >  drivers/net/loopback.c |    6 ++++++
> >  1 file changed, 6 insertions(+)
> > 
> > diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
> > index fcbf680..2694638 100644
> > --- a/drivers/net/loopback.c
> > +++ b/drivers/net/loopback.c
> > @@ -82,6 +82,12 @@ static netdev_tx_t loopback_xmit(struct sk_buff *skb,
> >  	 */
> >  	skb_dst_force(skb);
> >  
> > +	/* pkt_type is not always PACKET_HOST because
> > +	 * this skb comes from  other components.
> > +	 * Since eth_type_trans() sets pkt_type _except_ PACKET_HOST case,
> > +	 * set it explicitly.
> > +	 */
> > +	skb->pkt_type = PACKET_HOST;
> >  	skb->protocol = eth_type_trans(skb, dev);
> >  
> >  	/* it's OK to use per_cpu_ptr() because BHs are off */
> 
> 
> It sounds really strange to me.
> 
> This is not loopback duty to change pkt_type.
> 
> Where (and why) exactly pkt_type is set to PACKET_OTHERHOST ?

veth does. vethb-peer in the above example.
(veth_xmit() -> dev_forward_skb() -> eth_type_trans())
The destination mac address of arp reply is set to the one of
vetha (!= vethb-peer). So vethb-peer sets pkt_type to OTHERHOST.
bridge and gretap doesn't touch skb->pkt_type.
-- 
yamahata
