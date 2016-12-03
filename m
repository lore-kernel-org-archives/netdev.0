From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH net] geneve: avoid use-after-free of skb->data
Date: Sat, 3 Dec 2016 01:33:26 +0100
Message-ID: <20161203003326.GA27610@bistromath.localdomain>
References: <027c88dd060f5ca4535cb346db125829b2181a88.1480675406.git.sd@queasysnail.net>
 <20161202.140925.1784959728501874377.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linville@tuxdriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53696 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753440AbcLCAds (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Dec 2016 19:33:48 -0500
Content-Disposition: inline
In-Reply-To: <20161202.140925.1784959728501874377.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2016-12-02, 14:09:25 -0500, David Miller wrote:
> From: Sabrina Dubroca <sd@queasysnail.net>
> Date: Fri,  2 Dec 2016 16:49:29 +0100
> 
> > geneve{,6}_build_skb can end up doing a pskb_expand_head(), which
> > makes the ip_hdr(skb) reference we stashed earlier stale. Since it's
> > only needed as an argument to ip_tunnel_ecn_encap(), move this
> > directly in the function call.
> > 
> > Fixes: 08399efc6319 ("geneve: ensure ECN info is handled properly in all tx/rx paths")
> > Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
> 
> Applied and queued up for -stable, thanks.
> 
> This bug happens so many times that I think it might be time for
> a debugging mode for pskb_expand_head() that unconditionally
> reallocates the skb->data buffer regardless of whether it's
> necessary or not and somehow unmaps the previous buffer to
> force a trap on stale pointers.

The problem with that is you'd need to enable the "debugging mode" in
all wrappers, so that they don't bypass the actual call to
pskb_expand_head(). And that still leaves all the direct calls to
pskb_expand_head() that are guarded by some kind of check (just two
random hits without even looking very hard:
net/core/pktgen.c:process_ipsec, net/ipv4/ip_gre.c:gre_fb_xmit).

Then I think we could just rely on KASAN (that's how I noticed this
bug).


> Better ideas welcome, of course :)

May not be better ;)  but at least another idea:

I'd like to try something based on static analysis. We'd need a way to
tag cached pointers to skb->data (via ip_hdr() or whatever), and
propagate the notion that pskb_expand_head() makes these cached
pointers stale through layers of function calls.  I don't know how
feasible this is with the tools we have.

-- 
Sabrina
