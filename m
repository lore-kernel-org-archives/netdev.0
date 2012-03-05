From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [v9 PATCH 2/3] NETFILTER module xt_hmark, new target for HASH
 based fwmark
Date: Mon, 5 Mar 2012 19:22:48 +0100
Message-ID: <20120305182248.GA29022@1984>
References: <1329387672-23683-1-git-send-email-hans.schillstrom@ericsson.com>
 <1329387672-23683-3-git-send-email-hans.schillstrom@ericsson.com>
 <20120304184459.GA24338@1984>
 <201203051109.48817.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "kaber@trash.net" <kaber@trash.net>,
	"jengelh@medozas.de" <jengelh@medozas.de>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"hans@schillstrom.com" <hans@schillstrom.com>
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201203051109.48817.hans.schillstrom@ericsson.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Let me trim off parts that have been already discussed.

On Mon, Mar 05, 2012 at 11:09:46AM +0100, Hans Schillstrom wrote:
[...]
> ...
> > > +
> > > +/*
> > > + * ICMP, get header offset if icmp error
> > > + */
> > > +static int get_inner_hdr(struct sk_buff *skb, int iphsz, int nhoff)
> > > +{
> > > +     const struct icmphdr *icmph;
> > > +     struct icmphdr _ih;
> > > +
> > > +     /* Not enough header? */
> > > +     icmph = skb_header_pointer(skb, nhoff + iphsz, sizeof(_ih), &_ih);
> > > +     if (icmph == NULL)
> > > +             return nhoff;
> > 
> > I think this has to return -1 in this case.
> 
> No, it must return the unchanged value of nhoffs.
> Unless I change the usge of it as described later.

I see, you're defaulting on the original header if you cannot get the
ICMP header (eg. fragment case).

> > > +
> > > +     if (icmph->type > NR_ICMP_TYPES)
> > > +             return nhoff;
> > 
> > Same thing.
> 
> Same comment.

So if you get an unsupportted ICMP message, you rely on the original
IP header.

> > > +
> > > +     /* Error message? */
> > > +     if (icmph->type != ICMP_DEST_UNREACH &&
> > > +         icmph->type != ICMP_SOURCE_QUENCH &&
> > > +         icmph->type != ICMP_TIME_EXCEEDED &&
> > > +         icmph->type != ICMP_PARAMETERPROB &&
> > > +         icmph->type != ICMP_REDIRECT)
> > > +             return nhoff;
> > > +
> > > +     return nhoff + iphsz + sizeof(_ih);
> > > +}
> > > +
> > > +#if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
> > > +/*
> > > + * Get ipv6 header offset if icmp error
> > > + */
> > > +static int get_inner6_hdr(struct sk_buff *skb, int *offset)
> > 
> > I'd suggest to return the offset like in get_inner_hdr, not need for
> > one extra parameter then.
> 
> get_inner6_hdr() must return true/false not an offset
> 
> It's hard to make IPv4 & IPv6 the same due to the more complex header finding in IPv6,
> Maybe IPv4 can get more like IPv6,
>
> static int get_inner_hdr(struct sk_buff *skb, int *nhoff)
> {
> 	const struct icmphdr *icmph;
> 	struct icmphdr _ih;
> 	int iphz = ((struct iphdr *)skb_network_header(skb))->ihl * 4;
> 
> 	/* Not enough header? */
> 	icmph = skb_header_pointer(skb, *nhoff + iphsz, sizeof(_ih), &_ih);
> 	if (icmph == NULL || icmph->type > NR_ICMP_TYPES)
> 		return 0;
>
> 	/* Error message? */
> 	if (icmph->type != ICMP_DEST_UNREACH &&
> 	    icmph->type != ICMP_SOURCE_QUENCH &&
> 	    icmph->type != ICMP_TIME_EXCEEDED &&
> 	    icmph->type != ICMP_PARAMETERPROB &&
> 	    icmph->type != ICMP_REDIRECT)
> 		return 0
> 
> 	    *nhoff += iphsz + sizeof(_ih);
> 		return 1;

I only suggested to change the return value, no need to modify the
function, I liked how it was.

> }
>
> 
> ...
> 
> 	if (ip->protocol == IPPROTO_ICMP) {
> 		/* calc hash on inner header if an icmp error */
> 		if (get_inner_hdr(skb, &nhoff)) {
> 			ip = skb_header_pointer(skb, nhoff, sizeof(_ip), &_ip);

I prefer this chunk.

> 			if (!ip)
> 				return XT_CONTINUE;
> 		}
> 	}
>
> 
> instead of :
> 
> 	if (ip->protocol == IPPROTO_ICMP) {
> 		/* calc hash on inner header if an icmp error */
> 		nhoff = get_inner_hdr(skb, ip->ihl * 4, nhoff);
> 		ip = skb_header_pointer(skb, nhoff, sizeof(_ip), &_ip);
> 		if (!ip)
> 			return XT_CONTINUE;
> 	}
> 
> I don't see why this should be done, maintenance ?

It seems more readable to me.

> > 
> > > +{
> > > +     struct icmp6hdr *icmp6h, _ih6;
> > > +
> > > +     icmp6h = skb_header_pointer(skb, *offset, sizeof(_ih6), &_ih6);
> > > +     if (icmp6h == NULL)
> > > +             return 0;
> > > +
> > > +     if (icmp6h->icmp6_type && icmp6h->icmp6_type < 128) {
> > > +             *offset +=  sizeof(struct icmp6hdr);
> >                           ^^
> > extra space there.
> > 
> > > +             return 1;
> > > +     }
> > > +     return 0;
> > > +}
> > > +/*
> > > + * Calculate hash based fw-mark, on the five tuple if possible.
> > > + * special cases :
> > > + *  - Fragments do not use ports not even on the first fragment,
> > > + *    nf_defrag_ipv6.ko don't defrag for us like it do in ipv4.
> > > + *    This might be changed in the future.
> > > + *  - On ICMP errors the inner header will be used.
> > > + *  - Tunnels no ports
> > > + *  - ESP & AH uses SPI
> > > + * @returns XT_CONTINUE
> > > + */
> > > +static unsigned int
> > > +hmark_v6(struct sk_buff *skb, const struct xt_action_param *par)
> > > +{
> > > +     struct xt_hmark_info *info = (struct xt_hmark_info *)par->targinfo;
> > > +     struct ipv6hdr *ip6, _ip6;
> > > +     int poff, flag = IP6T_FH_F_AUTH; /* Ports offset, find_hdr flags */
> > > +     u32 addr1, addr2, hash, nhoffs = 0;
> > > +     u8 nexthdr;
> > > +     union hmark_ports uports = { .v32 = 0 };
> > 
> > I think that this can be: union hmark_ports uports = {};
> 
> I think moving the init further down is better, since there is a couple of returns before.

I don't mind. It was just one suggestion.

> 
>  +     uport.v32 = 0;
>  +     if ((info->flags & XT_F_HMARK_METHOD_L3) ||
>  +         (nexthdr == IPPROTO_ICMPV6))
>  +             goto no6ports;
> 
> > 
> > > +     unsigned short fragoff = 0;
> > > +
> > > +     ip6 = (struct ipv6hdr *) (skb->data + skb_network_offset(skb));
> > > +
> > > +     nexthdr = ipv6_find_hdr(skb, &nhoffs, -1, &fragoff, &flag);
> > > +     if (nexthdr < 0)
> > > +             return XT_CONTINUE;
> > > +     /* No need to check for icmp errors on fragments */
> > > +     if ((flag & IP6T_FH_F_FRAG) || (nexthdr != IPPROTO_ICMPV6))
> > > +             goto noicmp;
> > > +     /* if an icmp error, use the inner header */
> > > +     if (get_inner6_hdr(skb, &nhoffs)) {
> > 
> > I think you have to check that nexthdr == IPPROTO_ICMPV6 here,
> > otherwise non-icmp packets will be passed to get_inner6_hdr.
> > 
> 
> I do, (4 lines up)
>  +     if ((flag & IP6T_FH_F_FRAG) || (nexthdr != IPPROTO_ICMPV6))
>  +             goto noicmp;

Right.

> 
> > > +             ip6 = skb_header_pointer(skb, nhoffs, sizeof(_ip6), &_ip6);
> > > +             if (!ip6)
> > > +                     return XT_CONTINUE;
> > > +             /* Treat AH as ESP */
> > 
> > This comments means: try to find auth headers if possible, right?
> No, It might be a litle bit unclean but earlier Patric, you and I brought it up,
> - the descending into AH and port searching.
> 
> I think the comment should be some thing like,
>   /* Treat AH as ESP, use SPI nothing else. */

It's fine.

> > 
> > > +             flag = IP6T_FH_F_AUTH;
> > > +             nexthdr = ipv6_find_hdr(skb, &nhoffs, -1, &fragoff, &flag);
> > > +             if (nexthdr < 0)
> > > +                     return XT_CONTINUE;
> > > +     }
> > > +noicmp:
> > > +     addr1 = (__force u32)
> > > +             (ip6->saddr.s6_addr32[0] & info->smask.in6.s6_addr32[0]) ^
> > > +             (ip6->saddr.s6_addr32[1] & info->smask.in6.s6_addr32[1]) ^
> > > +             (ip6->saddr.s6_addr32[2] & info->smask.in6.s6_addr32[2]) ^
> > > +             (ip6->saddr.s6_addr32[3] & info->smask.in6.s6_addr32[3]);
> > > +     addr2 = (__force u32)
> > > +             (ip6->daddr.s6_addr32[0] & info->dmask.in6.s6_addr32[0]) ^
> > > +             (ip6->daddr.s6_addr32[1] & info->dmask.in6.s6_addr32[1]) ^
> > > +             (ip6->daddr.s6_addr32[2] & info->dmask.in6.s6_addr32[2]) ^
> > > +             (ip6->daddr.s6_addr32[3] & info->dmask.in6.s6_addr32[3]);
> > > +
> > > +     if ((info->flags & XT_F_HMARK_METHOD_L3) ||
> > > +         (nexthdr == IPPROTO_ICMPV6))
> > > +             goto no6ports;
> > > +     /* Is next header valid for port or SPI calculation ? */
> > > +     poff = proto_ports_offset(nexthdr);
> > > +     if ((flag & IP6T_FH_F_FRAG) || poff < 0)
> > > +             return XT_CONTINUE;
> > > +
> > > +     nhoffs += poff;
> > > +     /* Since uports is modified, skb_header_pointer() can't be used */
> > 
> > Why not? You can pass &uports to skb_header_pointer, it takes a
> > generic pointer.
> 
> uports is a local var that will written into later (swap and mask),
> The comment is there becuse of that.
> 
> > 
> > > +     if (!pskb_may_pull(skb, nhoffs + 4))
> > > +             return XT_CONTINUE;
> > > +     uports.v32 = * (__force u32 *) (skb->data + nhoffs);

I think you can do like in other parts of netfilter:

union hmark_ports _uports = { ... };
union hmark_ports *uports;

uports = skb_header_pointer(skb, nhoffs + poff, sizeof(_uports), &_uports);
if (uports == NULL)
        return XT_CONTINUE;

Then use uports->v32 in the rest of the code.

> > > +
> > > +     if ((nexthdr == IPPROTO_ESP) || (nexthdr == IPPROTO_AH))
> > > +             uports.v32 = (uports.v32 & info->spimask) | info->spiset;
> > > +     else {
> > > +             uports.v32 = (uports.v32 & info->pmask.v32) | info->pset.v32;
> > > +             /* get a consistent hash (same value on both flow directions) */
> > > +             if (uports.p16.dst < uports.p16.src)
> > > +                     swap(uports.p16.dst, uports.p16.src);
> > > +     }
> > > +
> > > +no6ports:
> > > +     nexthdr &= info->prmask;
> > > +     /* get a consistent hash (same value on both flow directions) */
> > > +     if (addr2 < addr1)
> > > +             swap(addr1, addr2);
> > > +
> > > +     hash = jhash_3words(addr1, addr2, uports.v32, info->hashrnd) ^ nexthdr;
> > > +     skb->mark = (hash % info->hmod) + info->hoffs;
> > > +     return XT_CONTINUE;
> > > +}
> > > +#endif
> > > +/*
> > > + * Calculate hash based fw-mark, on the five tuple if possible.
> > > + * special cases :
> > > + *  - Fragments do not use ports not even on the first fragment,
> > > + *    unless nf_defrag_xx.ko is used.
> > > + *  - On ICMP errors the inner header will be used.
> > > + *  - Tunnels no ports
> > > + *  - ESP & AH uses SPI
> > > + * @returns XT_CONTINUE
> > > + */
> > > +static unsigned int
> > > +hmark_v4(struct sk_buff *skb, const struct xt_action_param *par)
> > > +{
> > > +     struct xt_hmark_info *info = (struct xt_hmark_info *)par->targinfo;
> > > +     int nhoff, poff, frag = 0;
> > > +     struct iphdr *ip, _ip;
> > > +     u8 ip_proto;
> > > +     u32 addr1, addr2, hash;
> > > +     u16 snatport = 0, dnatport = 0;
> > > +     union hmark_ports uports;
> > > +     enum ip_conntrack_info ctinfo;
> > > +     struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
> > 
> > You spend cycles initializing this variable, but you may not use it.
> 
> Yes, it can be improved ...
> 
> > For the conntrack case, you can make in the very beginning:
> > 
> > if (info->flags & XT_HMARK_CT) {
> >         struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
> > 
> >         if (ct && !nf_ct_is_untracked(ct)) {
> >                 struct nf_conntrack_tuple *otuple =
> >                         &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple;
> >                 struct nf_conntrack_tuple *rtuple =
> >                         &ct->tuplehash[IP_CT_DIR_REPLY].tuple;
> > 
> >                 addr_src = (__force u32) otuple->src.u3.in.s_addr;
> >                 port_src = otuple->src.u.all;
> >                 addr_dst = (__force u32) rtuple->src.u3.in.s_addr;
> >                 port_dst = rtuple->src.u.all;
> >         } else
> >                 return XT_CONTINUE;
> > }
> > 
> > With SNAT/masquerade:
> > original: A -> B
> > reply: B -> FW
> > 
> > With DNAT:
> > original: A -> FW
> > reply: B -> A
> > 
> > So real addresses are always source for the original tuple and source
> > for the reply tuple.
> > 
> > I think it's better just to tell HMARK to use CT, no need to specify
> > what part of it, it's simple and the user will not get confused
> > selecting wrong configurations.
> > 
> We discussed that and you wrote:
> 
> "My opinion is that the user must have total control on the target
>  behaviour through the configuration options."
> ...
> "I'm fine if you allow to select what tuple you want to use to hash."
> 
> Have you changed you opinion ?
> From my point of view it doesn't matter.

To add what I've already said, I think it's also good if we can avoid
that users make wrong decisions.

> > Note that if you didn't not select to use conntrack, we default on the
> > packet-based version for HMARK which makes all the fragmentation
> > handling and so on.
> > 
> > Again, I'm proposing you to use addr_src and addr_dst instead of addr1
> > and addr2 for readability.
> > 
> > And remove the extra white extra line here below.
> > 
> > > +
> > > +
> > > +     nhoff = skb_network_offset(skb);
> > > +     uports.v32 = 0;
> > 
> > Better initialize this in the variable definition.
> 
> or beter,  move it to just before:
> 
>  +     uports.v32 = 0;
>  +     if ((info->flags & XT_F_HMARK_METHOD_L3) || (ip_proto == IPPROTO_ICMP))
>  +             goto noports;

OK.
