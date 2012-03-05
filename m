From: Hans Schillstrom <hans@schillstrom.com>
Subject: Re: [v9 PATCH 2/3] NETFILTER module xt_hmark, new target for HASH based fwmark
Date: Mon, 5 Mar 2012 21:33:54 +0100
Message-ID: <201203052133.54604.hans@schillstrom.com>
References: <1329387672-23683-1-git-send-email-hans.schillstrom@ericsson.com> <201203051109.48817.hans.schillstrom@ericsson.com> <20120305182248.GA29022@1984>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>,
	"kaber@trash.net" <kaber@trash.net>,
	"jengelh@medozas.de" <jengelh@medozas.de>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120305182248.GA29022@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,
On Monday, March 05, 2012 19:22:48 Pablo Neira Ayuso wrote:
> Let me trim off parts that have been already discussed.
> 
> On Mon, Mar 05, 2012 at 11:09:46AM +0100, Hans Schillstrom wrote:
> [...]
> > ...
> > > > +
> > > > +/*
> > > > + * ICMP, get header offset if icmp error
> > > > + */
> > > > +static int get_inner_hdr(struct sk_buff *skb, int iphsz, int nhoff)
> > > > +{
> > > > +     const struct icmphdr *icmph;
> > > > +     struct icmphdr _ih;
> > > > +
> > > > +     /* Not enough header? */
> > > > +     icmph = skb_header_pointer(skb, nhoff + iphsz, sizeof(_ih), &_ih);
> > > > +     if (icmph == NULL)
> > > > +             return nhoff;
> > > 
> > > I think this has to return -1 in this case.
> > 
> > No, it must return the unchanged value of nhoffs.
> > Unless I change the usge of it as described later.
> 
> I see, you're defaulting on the original header if you cannot get the
> ICMP header (eg. fragment case).
> 
> > > > +
> > > > +     if (icmph->type > NR_ICMP_TYPES)
> > > > +             return nhoff;
> > > 
> > > Same thing.
> > 
> > Same comment.
> 
> So if you get an unsupportted ICMP message, you rely on the original
> IP header.
>

Yes, thats right.

>
[snip]
> 
> I think you can do like in other parts of netfilter:
> 
> union hmark_ports _uports = { ... };
> union hmark_ports *uports;
> 
> uports = skb_header_pointer(skb, nhoffs + poff, sizeof(_uports), &_uports);
> if (uports == NULL)
>         return XT_CONTINUE;
> 
> Then use uports->v32 in the rest of the code.

If I do so, the original packet might be altered which is very bad.
i.e. if skb_header_pointer() return skb->data + offset; then I will write
right into the skb :-(

> 
> > > > +
[snip]

> > > > +static unsigned int
> > > > +hmark_v4(struct sk_buff *skb, const struct xt_action_param *par)
> > > > +{
> > > > +     struct xt_hmark_info *info = (struct xt_hmark_info *)par->targinfo;
> > > > +     int nhoff, poff, frag = 0;
> > > > +     struct iphdr *ip, _ip;
> > > > +     u8 ip_proto;
> > > > +     u32 addr1, addr2, hash;
> > > > +     u16 snatport = 0, dnatport = 0;
> > > > +     union hmark_ports uports;
> > > > +     enum ip_conntrack_info ctinfo;
> > > > +     struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
> > > 
> > > You spend cycles initializing this variable, but you may not use it.
> > 
> > Yes, it can be improved ...
> > 
> > > For the conntrack case, you can make in the very beginning:
> > > 
> > > if (info->flags & XT_HMARK_CT) {
> > >         struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
> > > 
> > >         if (ct && !nf_ct_is_untracked(ct)) {
> > >                 struct nf_conntrack_tuple *otuple =
> > >                         &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple;
> > >                 struct nf_conntrack_tuple *rtuple =
> > >                         &ct->tuplehash[IP_CT_DIR_REPLY].tuple;
> > > 
> > >                 addr_src = (__force u32) otuple->src.u3.in.s_addr;
> > >                 port_src = otuple->src.u.all;
> > >                 addr_dst = (__force u32) rtuple->src.u3.in.s_addr;
> > >                 port_dst = rtuple->src.u.all;
> > >         } else
> > >                 return XT_CONTINUE;
> > > }
> > > 
> > > With SNAT/masquerade:
> > > original: A -> B
> > > reply: B -> FW
> > > 
> > > With DNAT:
> > > original: A -> FW
> > > reply: B -> A
> > > 
> > > So real addresses are always source for the original tuple and source
> > > for the reply tuple.
> > > 
> > > I think it's better just to tell HMARK to use CT, no need to specify
> > > what part of it, it's simple and the user will not get confused
> > > selecting wrong configurations.
> > > 
> > We discussed that and you wrote:
> > 
> > "My opinion is that the user must have total control on the target
> >  behaviour through the configuration options."
> > ...
> > "I'm fine if you allow to select what tuple you want to use to hash."
> > 
> > Have you changed you opinion ?
> > From my point of view it doesn't matter.
> 
> To add what I've already said, I think it's also good if we can avoid
> that users make wrong decisions.
>

OK, I'll do that, this needs to be documented. I will write some new lines 
in the man page and see if my colleagues can understand it before poting it...
  
[snip]

Thanks
/Hans 
