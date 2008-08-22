From: Tux <gentuu@gmail.com>
Subject: Re: PATCH: NATed replies support in cls_flow
Date: Fri, 22 Aug 2008 05:13:27 +0300
Message-ID: <200808220513.27432.gentuu@gmail.com>
References: <200808192005.16752.gentuu@gmail.com> <48AD53F7.4020407@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.233]:48328 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756544AbYHVCOS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 22:14:18 -0400
Received: by rv-out-0506.google.com with SMTP id k40so225903rvb.1
        for <netdev@vger.kernel.org>; Thu, 21 Aug 2008 19:14:18 -0700 (PDT)
In-Reply-To: <48AD53F7.4020407@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Patrick and all,

Thursday 21 August 2008 14:39:35 Patrick wrote:
> Nick wrote:
> > Hi Patrick!
> >
> > This patch adds ability to classify reply packets of NAT'ed connections
> > entering _into_ an interface (for the actual entering I'm using mirring).
> >
> > @@ -197,7 +198,23 @@ static u32 flow_get_nfct(const struct sk_buff *skb)
> >  #define CTTUPLE(skb, member)                                           \
> >  ({                                                                     \
> >         enum ip_conntrack_info ctinfo;                                  \
> > +       struct nf_conntrack_tuple tuple;                                \
> > +       struct nf_conntrack_tuple_hash *h;                              \
> >         struct nf_conn *ct = nf_ct_get(skb, &ctinfo);                   \
> > +       /* Check if this is reply for a NAT'ed connection. */           \
> > +       if (!ct) {                                                      \
> > +               if (nf_ct_get_tuplepr(skb, skb_network_offset(skb),     \
> > +                   skb->protocol==htons(ETH_P_IP)?AF_INET:AF_INET6,    \
> > +                   &tuple)) {                                          \
> > +                       rcu_read_lock();                                \
> > +                       h = __nf_conntrack_find(&tuple);                \
> > +                       if (h) {                                        \
> > +                               ct = nf_ct_tuplehash_to_ctrack(h);      \
> > +                               ctinfo = IP_CT_NEW;                     \
> > +                       }                                               \
> > +                       rcu_read_unlock();                              \
> > +               }                                                       \
>
> I agree that this would be useful. Adding a dependency on the conntrack
> module is not an option however.
Why don't you think adding configurable dependency (#ifdef/#endif) on the 
conntrack is not a right way?
1. This is correct (as for me): we are trying to search for some info that is 
stored in the conntrack module - so we may add dependency on it (sure, 
optional)
2. cls_flow.c module already has the dependency (optional, with #ifdef/#endif)


> Its also not valid to call the header 
> parsing functions in this context since they rely on a couple of
> validations performed by ip_rcv()/ip6_rcv().
Yes, I didn't dig so deep - so didn't see such requirements.
We surely can start using the validation and even don't add additional 
dependencies to cls_flow (IPv4 proto shaper is impossible without IPv4 proto 
support ;)

But, guess I have a better idea...


> I can't see a clean way to do this right now, but I'm open to
> suggestions (please CC netfilter-devel and netdev though).

All I see here - is the "initial" limitation of the shaper: it can 
shape/schedule only outgoing packets (on egress).

But here we need (well, at least I need ;) shaping/scheduling and on ingress 
too, which is impossible for now.

As we are starting to add needed crutches to achieve the things at ingress - 
we are starting to use 'mirring' (yes, we have HTB and HFSC qdiscs with 
this!). But we still unable to track connections - so we add another 
functionality to classifying subsystem. As we doing something 
_already_existing_ (like finding the packet's tuple hash) we are coping the 
functionality from other subsystems (causing duplications...). If we need 
anything else to be done on ingress - we are _copying_ some kernel parts 
again and again...

That's a wrong way as for me.

I see two ways for this:
1. (the hard one) I see no a real reason _not_ to have on ingress just the 
same functionality as on egress. It doesn't matter that a packet already 
entered system and "we have no reasons to shape it now when it's here!". 
Possible there were no reasons in 90's. But now we do need to have such 
possibility. As a packet entered an interface - it doesn't mean it's already 
at the destination system.
But this way needs either:
- to copy every action done to validate/track/etc a packet from ingress to 
PREROUTING iptables chain (figuratively) - to a place before calling QoS by 
an interface on entered packet
- or to move the ingress processing _after_ these all checks


2. (the flexible one) To create an iptables target (for example: "SHAPE") to 
pass a packet to a shaper entity (ie tc rules hierarchy of ifb0 .. ifbN) 
wherever we need to.
This could be pretty like "CLASSIFY" target, but should do the actual shaping 
work here. Immediately we have a question here: should the target be 
terminating (it's easier as for me: we accept a packet and forwarding it to 
the selected ifbN's egress) or not? In the last case we will have to inject 
the shaped packet back to the firewall at the next rule after our "SHAPE" 
target. Not sure what is easier though.

So, I will be thankful for any thoughts about all this.

Thanks
Nick
