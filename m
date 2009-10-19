From: Atis Elsts <atis@mikrotik.com>
Subject: Re: [PATCH] Add sk_mark route lookup support for IPv4 listening sockets, and for IPv4 multicast forwarding
Date: Mon, 19 Oct 2009 14:38:26 +0300
Message-ID: <200910191438.27328.atis@mikrotik.com>
References: <20091007.223928.34412707.davem@davemloft.net> <55a4f86e0910141133y4decdeb4v43d9168687bbb724@mail.gmail.com> <20091019082033.GB27230@fogou.chygwyn.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Maciej =?utf-8?q?=C5=BBenczykowski?= <zenczykowski@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	panther@balabit.hu, eric.dumazet@gmail.com, brian.haley@hp.com
To: steve@chygwyn.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from bute.mt.lv ([159.148.172.196]:49567 "EHLO bute.mt.lv"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755899AbZJSLhG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Oct 2009 07:37:06 -0400
In-Reply-To: <20091019082033.GB27230@fogou.chygwyn.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 19 October 2009 11:20:33 steve@chygwyn.com wrote:
>
> Another potential use case would be to segregate traffic into different
> routing domains (and thus being able to change the mark when moving from
> one routing domain to another might be useful).

I agree. Actually, one of our  users recenlty requested adding matcher in 
firewall that would match outgoing the packets by the routing table that was 
used to route them. (For now we found a workaround using tclassid, but that 
requires manual configuration.) So yes, it's an useful feature even excluding 
the tunnel cases.

I don't like the idea of using skb->mark for storing that information though, 
because I think these multiple uses of the same field would be too confusing 
for users, even if the default behavior remained the same as now. Also, 
consider the case when someone watch to match packets in post routing chain 
*both* by the mark that was set in prerouting chain, and routing table used 
to route the packet?

There already is free space (padding fieds) in struct dst_entry, so why not 
use this space to store the routing table? Speed is also not an issue, 
because the field only needs to be filled in slowpath routing lookup, and 
will be used only
1) if iptables are explicitly configured to match by it;
2) (?) in tunnel routing lookups. (no idea which is the best option here)

I see that struct rt6_info already has field
    struct fib6_table		*rt6i_table
so this matcher already can be made for IPv6 firewall. But IPv4 still is more 
imporant at the moment :)

Atis
