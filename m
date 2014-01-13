From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] net: avoid reference counter overflows on fib_rules in multicast forwarding
Date: Tue, 14 Jan 2014 00:38:19 +0100
Message-ID: <20140113233819.GO6586@order.stressinduktion.org>
References: <20140110063638.GA17866@order.stressinduktion.org> <1389337306.31367.94.camel@edumazet-glaptop2.roam.corp.google.com> <20140110071049.GB17866@order.stressinduktion.org> <1389339179.31367.98.camel@edumazet-glaptop2.roam.corp.google.com> <20140110074325.GC17866@order.stressinduktion.org> <20140110075005.GD17866@order.stressinduktion.org> <20140112074245.GF6586@order.stressinduktion.org> <1389574560.31367.197.camel@edumazet-glaptop2.roam.corp.google.com> <20140113014522.GH6586@order.stressinduktion.org> <1389626314.31367.217.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Bob Falken <NetFestivalHaveFun@gmx.com>,
	Julian Anastasov <ja@ssi.bg>, netdev@vger.kernel.org,
	kaber@trash.net, tgraf@suug.ch
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:33851 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751597AbaAMXiV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 18:38:21 -0500
Content-Disposition: inline
In-Reply-To: <1389626314.31367.217.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 13, 2014 at 07:18:34AM -0800, Eric Dumazet wrote:
> On Mon, 2014-01-13 at 02:45 +0100, Hannes Frederic Sowa wrote:
> > Bob Falken reported that after 4G packets, multicast forwarding stopped
> > working. This was because of a rule reference counter overflow which
> > freed the rule as soon as the overflow happend.
> > 
> > This patch solves this by adding the FIB_LOOKUP_NOREF flag to
> > fib_rules_lookup calls. This is safe even from non-rcu locked sections
> > as in this case the flag only implies not taking a reference to the rule,
> > which we don't need at all.
> 
> We need to not forget this when/if we remove FIB_LOOKUP_NOREF flag,
> as all callers use it : We'll have to keep rcu_read_lock() in
> fib_rules_lookup()

Yes. Also maybe there is a tiny race between ipmr_rules_exit and reg_vif_xmit.
mrt table might get cleaned up while in reg_vif_xmit and initialisation code
has an error and calls ipmr_rules_exit, because mr_tables are not reference
counted and not managed by rcu (but reg_vif_xmit is also not rcuified). This
could happen if an error happens while initialisation I don't think net
namespace destruction is a problem here, as reg_vif_xmit still has a valid
reference to the interface and thus the namespace.

> > Rules only hold references to the namespace, which are guaranteed to be
> > available during the call of the non-rcu protected function reg_vif_xmit
> > because of the interface reference which itself holds a reference to
> > the net namespace.
> > 
> > Fixes: f0ad0860d01e47 ("ipv4: ipmr: support multiple tables")
> > Fixes: d1db275dd3f6e4 ("ipv6: ip6mr: support multiple tables")
> > Reported-by: Bob Falken <NetFestivalHaveFun@gmx.com>
> > Cc: Patrick McHardy <kaber@trash.net>
> > Cc: Thomas Graf <tgraf@suug.ch>
> > Cc: Julian Anastasov <ja@ssi.bg>
> > Cc: Eric Dumazet <eric.dumazet@gmail.com>
> > Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> > ---
> > Bob Falken already tested this patch, as it is similar to my first
> > attempt but the additional and similar fix for ipv6.
> > 
> > We need an additional fix for kernels without FIB_LOOKUP_NOREF, but I'll
> > move that to tomorrow, as it is already late here.
> 
> Acked-by: Eric Dumazet <edumazet@google.com>

Thanks for the review!

I don't think we need an additional patch for this for the longterm kernels
2.6.32 and 2.6.34, as rule support for ipmr and ip6mr only entered in 2.6.35.
RCUification of fib_lookup happened in 2.6.37. So this patch should cover all
current stable kernels.

Greetings,

  Hannes
