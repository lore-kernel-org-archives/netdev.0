From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] ifb: support more features
Date: Sun, 08 May 2016 09:08:32 -0700
Message-ID: <1462723712.23934.18.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1462578076.13075.63.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1462583999.13075.67.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1462686072.23934.4.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <aduyck@mirantis.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:33725 "EHLO
	mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750832AbcEHQIf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2016 12:08:35 -0400
Received: by mail-pf0-f175.google.com with SMTP id 206so67263721pfu.0
        for <netdev@vger.kernel.org>; Sun, 08 May 2016 09:08:35 -0700 (PDT)
In-Reply-To: <1462686072.23934.4.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2016-05-07 at 22:41 -0700, Eric Dumazet wrote:
> On Fri, 2016-05-06 at 18:19 -0700, Eric Dumazet wrote:
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > When using ifb+netem on ingress on SIT/IPIP/GRE traffic,
> > GRO packets are not properly processed.
> > 
> > Segmentation should not be forced, since ifb is already adding
> > quite a performance hit.
> > 
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > ---
> >  drivers/net/ifb.c |    3 +++
> >  1 file changed, 3 insertions(+)
> > 
> > diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
> > index cc56fac3c3f8..66c0eeafcb5d 100644
> > --- a/drivers/net/ifb.c
> > +++ b/drivers/net/ifb.c
> > @@ -196,6 +196,7 @@ static const struct net_device_ops ifb_netdev_ops = {
> >  
> >  #define IFB_FEATURES (NETIF_F_HW_CSUM | NETIF_F_SG  | NETIF_F_FRAGLIST	| \
> >  		      NETIF_F_TSO_ECN | NETIF_F_TSO | NETIF_F_TSO6	| \
> > +		      NETIF_F_GSO_ENCAP_ALL 				| \
> >  		      NETIF_F_HIGHDMA | NETIF_F_HW_VLAN_CTAG_TX		| \
> >  		      NETIF_F_HW_VLAN_STAG_TX)
> >  
> > @@ -224,6 +225,8 @@ static void ifb_setup(struct net_device *dev)
> >  	dev->tx_queue_len = TX_Q_LIMIT;
> >  
> >  	dev->features |= IFB_FEATURES;
> > +	dev->hw_features |= dev->features;
> > +	dev->hw_enc_features |= dev->features;
> >  	dev->vlan_features |= IFB_FEATURES & ~(NETIF_F_HW_VLAN_CTAG_TX |
> >  					       NETIF_F_HW_VLAN_STAG_TX);
> >  
> > 
> 
> 
> BTW, encapsulated GRO traffic going through mirred+ifb is dropped
> because segments get an incorrect skb->mac_len 
> 
> (If TSO/GSO is disabled on ifb, as before the above patch)
> 
> SIT traffic for example : segments get mac_len set to 34 instead of 14
> 
> What do you think of :
> 
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index e561f9f07d6d..bec5c32b2fe9 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -3176,7 +3176,7 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
>  		__copy_skb_header(nskb, head_skb);
>  
>  		skb_headers_offset_update(nskb, skb_headroom(nskb) - headroom);
> -		skb_reset_mac_len(nskb);
> +		nskb->mac_len = head_skb->mac_len;
>  
>  		skb_copy_from_linear_data_offset(head_skb, -tnl_hlen,
>  						 nskb->data - tnl_hlen,
> 


Hmm... looking at history this went wrong in linux-3.17 [1]

So we probably need to make sure the network header is properly set for
the segments. Then skb_reset_mac_len(nskb); would work as intended.

Since skb_segment() is called from the deepest point in GSO path,
it always see the inner network header.

Sounds like skb_reset_network_header() calls done in inet_gso_segment()
and ipv6_gso_segment() should only be done for the outer header, (when
SKB_GSO_CB(skb)->encap_level == 0), or even better, only done in 
skb_mac_gso_segment()

Then we need to use the proper (inner) network header in
tcp4_gso_segment() and tcp6_gso_segment(), as they currently use
ip_hdr() and ipv6_hdr()

[1] : commit fcdfe3a7fa4cb74391d42b6a26dc07c20dab1d82
Author: Vlad Yasevich <vyasevic@redhat.com>
Date:   Thu Jul 31 10:33:06 2014 -0400

    net: Correctly set segment mac_len in skb_segment().
    
    When performing segmentation, the mac_len value is copied right
    out of the original skb.  However, this value is not always set correctly
    (like when the packet is VLAN-tagged) and we'll end up copying a bad
    value.
    
    One way to demonstrate this is to configure a VM which tags
    packets internally and turn off VLAN acceleration on the forwarding
    bridge port.  The packets show up corrupt like this:
    16:18:24.985548 52:54:00:ab:be:25 > 52:54:00:26:ce:a3, ethertype 802.1Q
    (0x8100), length 1518: vlan 100, p 0, ethertype 0x05e0,
            0x0000:  8cdb 1c7c 8cdb 0064 4006 b59d 0a00 6402 ...|...d@.....d.
            0x0010:  0a00 6401 9e0d b441 0a5e 64ec 0330 14fa ..d....A.^d..0..
            0x0020:  29e3 01c9 f871 0000 0101 080a 000a e833)....q.........3
            0x0030:  000f 8c75 6e65 7470 6572 6600 6e65 7470 ...unetperf.netp
            0x0040:  6572 6600 6e65 7470 6572 6600 6e65 7470 erf.netperf.netp
            0x0050:  6572 6600 6e65 7470 6572 6600 6e65 7470 erf.netperf.netp
            0x0060:  6572 6600 6e65 7470 6572 6600 6e65 7470 erf.netperf.netp
            ...
    
    This also leads to awful throughput as GSO packets are dropped and
    cause retransmissions.
    
    The solution is to set the mac_len using the values already available
    in then new skb.  We've already adjusted all of the header offset, so we
    might as well correctly figure out the mac_len using skb_reset_mac_len().
    After this change, packets are segmented correctly and performance
    is restored.
    
    CC: Eric Dumazet <edumazet@google.com>
    Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index c1a33033cbe2..58ff88edbefd 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2976,9 +2976,9 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
                tail = nskb;
 
                __copy_skb_header(nskb, head_skb);
-               nskb->mac_len = head_skb->mac_len;
 
                skb_headers_offset_update(nskb, skb_headroom(nskb) - headroom);
+               skb_reset_mac_len(nskb);
 
                skb_copy_from_linear_data_offset(head_skb, -tnl_hlen,
                                                 nskb->data - tnl_hlen,
