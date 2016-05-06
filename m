From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH v9 net-next 4/7] openvswitch: add layer 3 flow/port
 support
Date: Fri, 6 May 2016 14:57:07 +0900
Message-ID: <20160506055705.GA9276@penelope.isobedori.kobe.vergenet.net>
References: <1462347393-22354-1-git-send-email-simon.horman@netronome.com>
 <1462347393-22354-5-git-send-email-simon.horman@netronome.com>
 <CAOrHB_AMC4x=NnLTpGbXdW31Vp0f1R3VoaD9ksST5EesrdGsug@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	ovs dev <dev@openvswitch.org>,
	Lorand Jakab <lojakab@cisco.com>,
	Thomas Morin <thomas.morin@orange.com>,
	Jiri Benc <jbenc@redhat.com>
To: pravin shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:33550 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751053AbcEFF5R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2016 01:57:17 -0400
Received: by mail-pa0-f51.google.com with SMTP id xk12so44269329pac.0
        for <netdev@vger.kernel.org>; Thu, 05 May 2016 22:57:17 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAOrHB_AMC4x=NnLTpGbXdW31Vp0f1R3VoaD9ksST5EesrdGsug@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[CC Jiri Benc]

On Thu, May 05, 2016 at 10:37:08AM -0700, pravin shelar wrote:
> On Wed, May 4, 2016 at 12:36 AM, Simon Horman
> <simon.horman@netronome.com> wrote:
> > From: Lorand Jakab <lojakab@cisco.com>
> >
> > Implementation of the pop_eth and push_eth actions in the kernel, and
> > layer 3 flow support.
> >
> > This doesn't actually do anything yet as no layer 2 tunnel ports are
> > supported yet. The original patch by Lorand was against the Open vSwtich
> > tree which has L2 LISP tunnels but that is not supported in mainline Linux.
> > I (Simon) plan to follow up with support for non-TEB GRE ports based on
> > work by Thomas Morin.
> >
> > Cc: Thomas Morin <thomas.morin@orange.com>
> > Signed-off-by: Lorand Jakab <lojakab@cisco.com>
> > Signed-off-by: Simon Horman <simon.horman@netronome.com>
> >
> > ---
> 
> ...
> 
> > diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
> > index 0ea128eeeab2..6e174ea5f2bb 100644
> > --- a/net/openvswitch/flow.c
> > +++ b/net/openvswitch/flow.c
> > @@ -468,28 +468,31 @@ static int key_extract(struct sk_buff *skb, struct sw_flow_key *key)
> >
> >         skb_reset_mac_header(skb);
> >
> > -       /* Link layer.  We are guaranteed to have at least the 14 byte Ethernet
> > -        * header in the linear data area.
> > -        */
> > -       eth = eth_hdr(skb);
> > -       ether_addr_copy(key->eth.src, eth->h_source);
> > -       ether_addr_copy(key->eth.dst, eth->h_dest);
> > +       /* Link layer. */
> > +       if (key->phy.is_layer3) {
> > +               key->eth.tci = 0;
> > +               key->eth.type = skb->protocol;
> > +       } else {
> > +               eth = eth_hdr(skb);
> > +               ether_addr_copy(key->eth.src, eth->h_source);
> > +               ether_addr_copy(key->eth.dst, eth->h_dest);
> >
> > -       __skb_pull(skb, 2 * ETH_ALEN);
> > -       /* We are going to push all headers that we pull, so no need to
> > -        * update skb->csum here.
> > -        */
> > +               __skb_pull(skb, 2 * ETH_ALEN);
> > +               /* We are going to push all headers that we pull, so no need to
> > +                * update skb->csum here.
> > +                */
> >
> > -       key->eth.tci = 0;
> > -       if (skb_vlan_tag_present(skb))
> > -               key->eth.tci = htons(skb->vlan_tci);
> > -       else if (eth->h_proto == htons(ETH_P_8021Q))
> > -               if (unlikely(parse_vlan(skb, key)))
> > -                       return -ENOMEM;
> > +               key->eth.tci = 0;
> > +               if (skb_vlan_tag_present(skb))
> > +                       key->eth.tci = htons(skb->vlan_tci);
> > +               else if (eth->h_proto == htons(ETH_P_8021Q))
> > +                       if (unlikely(parse_vlan(skb, key)))
> > +                               return -ENOMEM;
> >
> > -       key->eth.type = parse_ethertype(skb);
> > -       if (unlikely(key->eth.type == htons(0)))
> > -               return -ENOMEM;
> > +               key->eth.type = parse_ethertype(skb);
> > +               if (unlikely(key->eth.type == htons(0)))
> > +                       return -ENOMEM;
> > +       }
> >
> >         skb_reset_network_header(skb);
> >         skb_reset_mac_len(skb);
> > @@ -696,11 +699,23 @@ int ovs_flow_key_update(struct sk_buff *skb, struct sw_flow_key *key)
> >  int ovs_flow_key_extract(const struct ip_tunnel_info *tun_info,
> >                          struct sk_buff *skb, struct sw_flow_key *key)
> >  {
> > +       bool is_layer3 = false;
> > +       bool is_teb = false;
> is_layer3 and is_teb are mutually exclusive, so can't we use single
> boolean here?

Sure, I can do something like the following if you prefer.
To my mind it makes things a bit less readable. But I don't feel
strongly about this.

diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index d320c2657627..fc92cf542101 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -701,7 +701,6 @@ int ovs_flow_key_extract(const struct ip_tunnel_info *tun_info,
 			 struct sk_buff *skb, struct sw_flow_key *key)
 {
 	bool is_layer3 = false;
-	bool is_teb = false;
 	int err;
 
 	/* Extract metadata from packet. */
@@ -709,13 +708,9 @@ int ovs_flow_key_extract(const struct ip_tunnel_info *tun_info,
 		key->tun_proto = ip_tunnel_info_af(tun_info);
 		memcpy(&key->tun_key, &tun_info->key, sizeof(key->tun_key));
 
-		if (OVS_CB(skb)->input_vport->dev->type != ARPHRD_ETHER) {
-			if (skb->protocol == htons(ETH_P_TEB))
-				is_teb = true;
-			else
-				is_layer3 = true;
-		}
-
+		if (OVS_CB(skb)->input_vport->dev->type != ARPHRD_ETHER &&
+		    skb->protocol != htons(ETH_P_TEB))
+			is_layer3 = true;
 
 		if (tun_info->options_len) {
 			BUILD_BUG_ON((1 << (sizeof(tun_info->options_len) *
@@ -746,10 +741,12 @@ int ovs_flow_key_extract(const struct ip_tunnel_info *tun_info,
 	if (err < 0)
 		return err;
 
-	if (is_teb)
-		skb->protocol = key->eth.type;
-	else if (is_layer3)
-		key->eth.type = skb->protocol;
+	if (tun_info && OVS_CB(skb)->input_vport->dev->type != ARPHRD_ETHER) {
+		if (is_layer3)
+			key->eth.type = skb->protocol;
+		else
+			skb->protocol = key->eth.type;
+	}
 
 	return err;
 }

> > +       int err;
> > +
> >         /* Extract metadata from packet. */
> >         if (tun_info) {
> >                 key->tun_proto = ip_tunnel_info_af(tun_info);
> >                 memcpy(&key->tun_key, &tun_info->key, sizeof(key->tun_key));
> >
> > +               if (OVS_CB(skb)->input_vport->dev->type != ARPHRD_ETHER) {
> > +                       if (skb->protocol == htons(ETH_P_TEB))
> > +                               is_teb = true;
> > +                       else
> > +                               is_layer3 = true;
> > +               }
> > +
> On transmit side you are using mac_len to detect l3 packet, why not do
> same while extracting the key?

Unfortunately mac_len can't be relied on here, emprically it has the same
value (28 in my tests) for both the TEB and layer3 case above.

Perhaps that could be changed by futher enhancements in the tunneling code
but I think things are symetric as they stand:

* On recieve skb->protocol can be read to distinguish TEB and layer3 packets
* On transmit skb->protocol should be set to distinguish TEB and layer3 packets
