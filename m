From: Patrick McHardy <kaber@trash.net>
Subject: Re: ipv6 fragmentation-related panic in netfilter
Date: Fri, 1 Nov 2013 09:25:37 +0000
Message-ID: <20131101092536.GA17499@macbook.localnet>
References: <2060a7d2-c307-4e30-b1d4-0bd26c904d6f@gmail.com>
 <20131030000701.GB25469@macbook.localnet>
 <20131101084529.GL31491@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tomas Hlavacek <tmshlvck@gmail.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42003 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755135Ab3KAJZn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Nov 2013 05:25:43 -0400
Content-Disposition: inline
In-Reply-To: <20131101084529.GL31491@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 01, 2013 at 09:45:29AM +0100, Steffen Klassert wrote:
> On Wed, Oct 30, 2013 at 12:07:11AM +0000, Patrick McHardy wrote:
> > 
> > The problem is that the reassembled packet is referenced by the individual
> > fragments, so we trigger the BUG_ON in pskb_expand_head(). In this
> > particular case the case we BUG() on is actually OK, but I'm looking at
> > a way we can fix this without special casing. Hope to have a patch for
> > testing in the next hours.
> 
> Just for the record. I'm observing similar, quite reproducable crashes when
> receiving fragmented icmp echo request packets on an IPsec gateway with
> nf_conntrack_ipv6.
> 
> Since git commit 58a317f10 ("netfilter: ipv6: add IPv6 NAT support")
> netfilter might insert a reassembled ipv6 packet with a shared skb and
> local_df = 1 to the ok function. In case of xfrm, __xfrm6_output()
> fragments the packet again and when adjusting the headroom later, we
> crash because of a shared skb.
> 
> I can fix it by checking for a shared skb in ip6_fragment() and do
> slow path fragmentation then. But we never needed such a check in
> ip6_fragment(), so it's maybe better to fix it in netfilter.

So what seems to be happening is that this case in __ipv6_conntrack_in()
triggers:

        /* Conntrack helpers need the entire reassembled packet in the
         * POST_ROUTING hook. In case of unconfirmed connections NAT
         * might reassign a helper, so the entire packet is also
         * required.
         */
        ct = nf_ct_get(reasm, &ctinfo);
        if (ct != NULL && !nf_ct_is_untracked(ct)) {
                help = nfct_help(ct);
                if ((help && help->helper) || !nf_ct_is_confirmed(ct)) {
                        nf_conntrack_get_reasm(reasm);
                        NF_HOOK_THRESH(NFPROTO_IPV6, hooknum, reasm,
                                       (struct net_device *)in,
                                       (struct net_device *)out,        
                                       okfn, NF_IP6_PRI_CONNTRACK + 1);

Since this code is called while walking through the fragment chain, we have
extra references to the reassembled skb. So I think what we need to do is
to release the fragment chain before calling NF_HOOK_THRESH() and indicate
this to nf_ct_frag6_output() so it will stop processing the chain immediately.

I'll give it a try, will let you know when I have a patch for testing.
