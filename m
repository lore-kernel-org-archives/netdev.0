From: David Miller <davem@davemloft.net>
Subject: Re: Netfilter: kernel panic with REDIRECT target. (2.6.23 and
 2.6.23.8)
Date: Tue, 20 Nov 2007 04:09:58 -0800 (PST)
Message-ID: <20071120.040958.253666556.davem@davemloft.net>
References: <20071119193143.GA12640@2ka.mipt.ru>
	<4741EB07.50706@unsolicited.net>
	<20071120115520.GB30752@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: david@unsolicited.net, kaber@trash.net, ismail@pardus.org.tr,
	netdev@vger.kernel.org
To: johnpol@2ka.mipt.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48340
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753150AbXKTMJ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 07:09:59 -0500
In-Reply-To: <20071120115520.GB30752@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Tue, 20 Nov 2007 14:55:20 +0300

> > >> Ok, let's try it hard way.
> > >> Please check attached patch and tell if it helped (it will produce
> > >> some debug though).
> > >
> > > With both patches applied - one Patrick showed and this one.
> > >   
> > Now works, with this in dmesg
> > 
> > conntrack: ea94159c, new: ead4d7c4, old: ead4d7d0, ct: 00000000.
> 
> David (Miller :), please apply attached patch, which also needed to fix
> netfilter connection tracking bug.
> When connection tracking entry (nf_conn) is about to copy itself it can
> have some of its extension users (like nat) as being already freed and
> thus not required to be copied.
> Frankly saying, it can be not the correct fix, but from code observation
> and test, perfomed by David <david@unsolicited.net> it is.
> 
> Actually looking at this function I suspect it was copied from
> nf_nat_setup_info() and thus bug was introduced.
> 
> Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

Evgeniy, thanks for figuring this out.

I think it is fair to let Patrick take a quick look at this
before it is applied (and Linus is away until next week
anyways so there is no rush :-)

I suspect this error might live elsewhere too, so perhaps a good
audit should be done for this kind of thing as well so we can
kill all such gremlins now.

Thanks again.

> diff --git a/net/ipv4/netfilter/nf_nat_core.c b/net/ipv4/netfilter/nf_nat_core.c
> index 70e7997..86b465b 100644
> --- a/net/ipv4/netfilter/nf_nat_core.c
> +++ b/net/ipv4/netfilter/nf_nat_core.c
> @@ -607,13 +607,10 @@ static void nf_nat_move_storage(struct nf_conn *conntrack, void *old)
>  	struct nf_conn_nat *new_nat = nf_ct_ext_find(conntrack, NF_CT_EXT_NAT);
>  	struct nf_conn_nat *old_nat = (struct nf_conn_nat *)old;
>  	struct nf_conn *ct = old_nat->ct;
> -	unsigned int srchash;
>  
> -	if (!(ct->status & IPS_NAT_DONE_MASK))
> +	if (!ct || !(ct->status & IPS_NAT_DONE_MASK))
>  		return;
>  
> -	srchash = hash_by_src(&ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple);
> -
>  	write_lock_bh(&nf_nat_lock);
>  	hlist_replace_rcu(&old_nat->bysource, &new_nat->bysource);
>  	new_nat->ct = ct;
> 
> -- 
> 	Evgeniy Polyakov
