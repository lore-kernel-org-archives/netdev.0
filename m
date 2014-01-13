From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] net: avoid reference counter overflows on fib_rules
 in multicast forwarding
Date: Mon, 13 Jan 2014 07:18:34 -0800
Message-ID: <1389626314.31367.217.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140109201411.317040@gmx.com>
	 <20140110063638.GA17866@order.stressinduktion.org>
	 <1389337306.31367.94.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140110071049.GB17866@order.stressinduktion.org>
	 <1389339179.31367.98.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140110074325.GC17866@order.stressinduktion.org>
	 <20140110075005.GD17866@order.stressinduktion.org>
	 <20140112074245.GF6586@order.stressinduktion.org>
	 <1389574560.31367.197.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140113014522.GH6586@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Bob Falken <NetFestivalHaveFun@gmx.com>,
	Julian Anastasov <ja@ssi.bg>, netdev@vger.kernel.org,
	kaber@trash.net, tgraf@suug.ch
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:59531 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751396AbaAMPSg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 10:18:36 -0500
Received: by mail-pb0-f45.google.com with SMTP id rp16so7434558pbb.32
        for <netdev@vger.kernel.org>; Mon, 13 Jan 2014 07:18:36 -0800 (PST)
In-Reply-To: <20140113014522.GH6586@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-01-13 at 02:45 +0100, Hannes Frederic Sowa wrote:
> Bob Falken reported that after 4G packets, multicast forwarding stopped
> working. This was because of a rule reference counter overflow which
> freed the rule as soon as the overflow happend.
> 
> This patch solves this by adding the FIB_LOOKUP_NOREF flag to
> fib_rules_lookup calls. This is safe even from non-rcu locked sections
> as in this case the flag only implies not taking a reference to the rule,
> which we don't need at all.

We need to not forget this when/if we remove FIB_LOOKUP_NOREF flag,
as all callers use it : We'll have to keep rcu_read_lock() in
fib_rules_lookup()
> 
> Rules only hold references to the namespace, which are guaranteed to be
> available during the call of the non-rcu protected function reg_vif_xmit
> because of the interface reference which itself holds a reference to
> the net namespace.
> 
> Fixes: f0ad0860d01e47 ("ipv4: ipmr: support multiple tables")
> Fixes: d1db275dd3f6e4 ("ipv6: ip6mr: support multiple tables")
> Reported-by: Bob Falken <NetFestivalHaveFun@gmx.com>
> Cc: Patrick McHardy <kaber@trash.net>
> Cc: Thomas Graf <tgraf@suug.ch>
> Cc: Julian Anastasov <ja@ssi.bg>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
> Bob Falken already tested this patch, as it is similar to my first
> attempt but the additional and similar fix for ipv6.
> 
> We need an additional fix for kernels without FIB_LOOKUP_NOREF, but I'll
> move that to tomorrow, as it is already late here.

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks !
