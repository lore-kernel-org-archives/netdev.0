From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net] ipv4: route: fix inet_rtm_getroute induced crash
Date: Mon, 14 Aug 2017 07:20:14 +0200
Message-ID: <20170814052014.GA5672@breakpoint.cc>
References: <20170813225258.16001-1-fw@strlen.de>
 <17031977-3e7a-9a7f-e53c-538cb030e496@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
        Roopa Prabhu <roopa@cumulusnetworks.com>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:58072 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750878AbdHNFWd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2017 01:22:33 -0400
Content-Disposition: inline
In-Reply-To: <17031977-3e7a-9a7f-e53c-538cb030e496@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Ahern <dsahern@gmail.com> wrote:
> On 8/13/17 4:52 PM, Florian Westphal wrote:
> > "ip route get $daddr iif eth0 from $saddr" causes:
> >  BUG: KASAN: use-after-free in ip_route_input_rcu+0x1535/0x1b50
> >  Call Trace:
> >   ip_route_input_rcu+0x1535/0x1b50
> >   ip_route_input_noref+0xf9/0x190
> >   tcp_v4_early_demux+0x1a4/0x2b0
> >   ip_rcv+0xbcb/0xc05
> >   __netif_receive_skb+0x9c/0xd0
> >   netif_receive_skb_internal+0x5a8/0x890
> > 
> > Problem is that inet_rtm_getroute calls either ip_route_input_rcu (if an
> > iif was provided) or ip_route_output_key_hash_rcu.
> > 
> > But ip_route_input_rcu, unlike ip_route_output_key_hash_rcu, already
> > associates the dst_entry with the skb.  This clears the SKB_DST_NOREF
> > bit (i.e. skb_dst_drop will release/free the entry while it should not).
> > 
> > Thus only set the dst if we called ip_route_output_key_hash_rcu().
> > 
> > I tested this patch by running:
> >  while true;do ip r get 10.0.1.2;done > /dev/null &
> >  while true;do ip r get 10.0.1.2 iif eth0  from 10.0.1.1;done > /dev/null &
> > ... and saw no crash or memory leak.
> > 
> > Cc: Roopa Prabhu <roopa@cumulusnetworks.com>
> > Cc: David Ahern <dsahern@gmail.com>
> > Fixes: ba52d61e0ff ("ipv4: route: restore skb_dst_set in inet_rtm_getroute")
> > Signed-off-by: Florian Westphal <fw@strlen.de>
> 
> Have looked at the change in detail, but are you sure that is the
> correct Fixes?

I'm reasonably sure, yes:

if (iif) {
  ip_route_input_rcu // 1 might get NOREF dst
} else {
  ip_route_output_key_hash_rcu // 2 always takes dst ref
}
skb_dst_set /* 3 loses NOREF in case of 1) */

> Running these:
>   while true;do ip r get 10.1.1.3;done > /dev/null &
>   while true;do ip r get 10.1.1.3 iif eth0  from 192.16.1.1;done >
> /dev/null &
> 
> at various commits:
>   ffe95ecf3a2 - KASAN backtraces

Right, this is broken state (has both ba52d61e0ff and 3765d35ed8b9)

>   374d801522f - works fine

This is fine, it lacks 3765d35ed8b9:
both branches take a reference on dst so '3' above has no side effect.

>   ba52d61e0ff - negative refcnt messages

AFAICS this is before dst gc removal, I guess (but did not
check) that KASAN vs. refcount just comes from this.

>   a5e2ee5da47 - works fine

Should cause a memory leak when iif is not given (ref on dst is
taken but not released in case of 2), ba52d61e0ff cured this but
adds the problem described here).

Does that make it clearer?
