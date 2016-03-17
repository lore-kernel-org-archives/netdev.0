From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv6: Fix the pmtu path for connected UDP socket
Date: Wed, 16 Mar 2016 17:22:07 -0700
Message-ID: <1458174127.7353.11.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1457989187-92851-1-git-send-email-tracywwnj@gmail.com>
	 <20160316.195341.68257764618999441.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: weiwan@google.com, edumazet@google.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:34608 "EHLO
	mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754180AbcCQAWK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 20:22:10 -0400
Received: by mail-pf0-f172.google.com with SMTP id x3so95037762pfb.1
        for <netdev@vger.kernel.org>; Wed, 16 Mar 2016 17:22:09 -0700 (PDT)
In-Reply-To: <20160316.195341.68257764618999441.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-03-16 at 19:53 -0400, David Miller wrote:
> From: Wei Wang <weiwan@google.com>
> Date: Mon, 14 Mar 2016 13:59:47 -0700
> 
> > From: Wei Wang <weiwan@google.com>
> > 
> > When ICMPV6_PKT_TOOBIG message is received by a connected UDP socket,
> > the new mtu value is not properly updated in the dst_entry associated
> > with the socket.
> > This leads to the issue that the mtu value returned by getsockopt(sockfd,
> > IPPROTO_IPV6, IPV6_MTU, ...) is wrong.
> > The fix is to update sk->sk_dst_cache and other corresponding fields
> > when a new routing cache is allocated for the new pmtu in UDP connected
> > socket case.
> > 
> > Signed-off-by: Wei Wang <weiwan@google.com>
> 
> Wait a second:
> 
> >  		if (nrt6) {
> >  			rt6_do_update_pmtu(nrt6, mtu);
> > -
> > -			/* ip6_ins_rt(nrt6) will bump the
> > -			 * rt6->rt6i_node->fn_sernum
> > -			 * which will fail the next rt6_check() and
> > -			 * invalidate the sk->sk_dst_cache.
> > -			 */
> > +			if (sk)
> > +				ip6_dst_store(sk, &nrt6->dst, daddr, saddr);
> >  			ip6_ins_rt(nrt6);
> >  		}
> >  	}
> 
> I still haven't seen a satisfactory answer as to why the as-designed
> invalidation mechanism using fn_sernum is not working.
> 
> If that's broken, then a lot of other things won't work properly
> either.
> 
> I've read the ip6_ins_rt() code path several times, and it always
> increments the serial number, and therefore the next dst->check() call
> (which every cached route usage should invoke) should invalide
> this socket's route and lookup the new one.
> 
> Why does this not work?


One of the issue is that IPV6_MTU getsockopt() will not check the dst,
but simply use __sk_dst_get() : It will then report old mtu.

Not sure we want to use the full check and then if dst appears to be
obsolete, do another route lookup ?
