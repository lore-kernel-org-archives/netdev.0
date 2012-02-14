From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [v8 PATCH 2/3] NETFILTER module xt_hmark, new target for HASH
 based fwmark
Date: Tue, 14 Feb 2012 01:44:12 +0100
Message-ID: <20120214004412.GG24194@1984>
References: <1327675303-9059-1-git-send-email-hans.schillstrom@ericsson.com>
 <1327675303-9059-3-git-send-email-hans.schillstrom@ericsson.com>
 <20120208002743.GA29189@1984>
 <201202081507.15489.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "kaber@trash.net" <kaber@trash.net>,
	"jengelh@medozas.de" <jengelh@medozas.de>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"hans@schillstrom.com" <hans@schillstrom.com>
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:45484 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751036Ab2BNAoT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Feb 2012 19:44:19 -0500
Content-Disposition: inline
In-Reply-To: <201202081507.15489.hans.schillstrom@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 08, 2012 at 03:07:13PM +0100, Hans Schillstrom wrote:
[...]
> [snip]
> 
> > > +static unsigned int
> > > +hmark_v4(struct sk_buff *skb, const struct xt_action_param *par)
> > > +{
> > > +     struct xt_hmark_info *info = (struct xt_hmark_info *)par->targinfo;
> > > +     int nhoff, poff, frag = 0;
> > > +     struct iphdr *ip, _ip;
> > > +     u8 ip_proto;
> > > +     u32 addr1, addr2, hash;
> > > +     u16 snatport = 0, dnatport = 0;
> > > +     union hports uports;
> > > +#if defined(CONFIG_NF_NAT)
> > 
> > remove this #if defined, not required at all.
> 
> Yes it is, if you don't want to wase cpu cycles 
> more correct is this:
> #if defined(CONFIG_NF_NAT) || defined(CONFIG_NF_NAT_MODULE)

If you want that #if defined, then check for CONFIG_NF_CONNTRACK
instead.

Still, I don't think you're going to save to much cycle for this and
the code looks better with much less ifdefs.

[...]
> > > +#if defined(CONFIG_NF_NAT)
> > > +     if (ct && test_bit(IP_CT_IS_REPLY, &ct->status)) {
> > > +             struct nf_conntrack_tuple *otuple;
> > > +
> > > +             otuple = &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple;
> > > +             /*
> > > +              * On the "return flow", to get the original address
> > > +              */
> > > +             if ((ct->status & IPS_DST_NAT) &&
> > > +                     (info->flags & XT_HMARK_USE_DNAT)) {
> > > +                     addr1 = (__force u32) otuple->dst.u3.in.s_addr;
> > > +                     dnatport = otuple->dst.u.udp.port;
> > > +             }
> > > +             if ((ct->status & IPS_SRC_NAT) &&
> > > +                     (info->flags & XT_HMARK_USE_SNAT)) {
> > > +                     addr2 = (__force u32) otuple->src.u3.in.s_addr;
> > > +                     snatport = otuple->src.u.udp.port;
> > > +             }
> > 
> > You can make this much more simple.

I mean something like:

#if defined(CONFIG_NF_CONNTRACK)
        if (ct && nf_ct_is_untracked(ct)) {
                addr1 = (__force u32) otuple->src.u3.in.s_addr;
                sport = otuple->src.u.udp.port;
[...]

That's enough to guarantee that you always hash using the same
information for NATted traffic coming in both directions (thus, you
ensure that load balancing is consistent).

> > Allow the user to tell your HMARK target to use the conntrack
> > information instead.
> 
> --hmark--use-conntrack, I think  --hmark-use-ct-orig is more clear
> If I understand you right you mean a change like this:
>
> +             if ((ct->status & IPS_DST_NAT) &&
> +                     (info->flags & XT_HMARK_USE_CT_ORIG_ADDR)) {
> ...
> +             if ((ct->status & IPS_SRC_NAT) &&
> +                     (info->flags & XT_HMARK_USE_CT_ORIG_ADDR)) {

I'm fine if you allow to select what tuple you want to use to hash.

> > My opinion is that the user must have total control on the target
> > behaviour through the configuration options. 
> > The number of internal by-default decisions have to be kept up to the minimum, otherwise
> > the behaviour of the target may seem obscure.
> > 
> 
> I think --hmark-use-ct-orig is more intuitive what is does compared to 
>   --hmark-ct-orig-src and --hmark-ct-orig-dst
> (i.e. you don't have to think about direction.)

OK.
