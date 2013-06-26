From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: oops in udpv6_sendmsg
Date: Wed, 26 Jun 2013 02:22:37 -0700
Message-ID: <1372238557.3301.145.camel@edumazet-glaptop>
References: <20130329184006.GA23893@redhat.com>
	 <1364582958.5113.49.camel@edumazet-glaptop>
	 <1364865839.5113.165.camel@edumazet-glaptop>
	 <20130417010213.GA9027@redhat.com>
	 <1366164132.3205.21.camel@edumazet-glaptop>
	 <20130417141138.GA17648@redhat.com>
	 <1366208856.3205.23.camel@edumazet-glaptop>
	 <1366214751.3205.29.camel@edumazet-glaptop>
	 <20130625212851.GA20081@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dave Jones <davej@redhat.com>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f53.google.com ([74.125.83.53]:43369 "EHLO
	mail-ee0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751619Ab3FZJWh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jun 2013 05:22:37 -0400
Received: by mail-ee0-f53.google.com with SMTP id c41so7372143eek.12
        for <netdev@vger.kernel.org>; Wed, 26 Jun 2013 02:22:35 -0700 (PDT)
In-Reply-To: <20130625212851.GA20081@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-06-25 at 23:28 +0200, Hannes Frederic Sowa wrote:
> On Wed, Apr 17, 2013 at 09:05:51AM -0700, Eric Dumazet wrote:
> > On Wed, 2013-04-17 at 07:27 -0700, Eric Dumazet wrote:
> > > On Wed, 2013-04-17 at 10:11 -0400, Dave Jones wrote:
> > > > On Tue, Apr 16, 2013 at 07:02:12PM -0700, Eric Dumazet wrote:
> > > 
> > > > good news is that with some changes, I was able to make current
> > > > trinity reproduce this in seconds rather than hours..
> > > > 
> > > > ./trinity -q -l off -n -c sendmsg -c connect 
> > > > 
> > > > on current tree seems to reliably trigger it for me.
> > > 
> > > Good new indeed, I got a crash in 2 seconds
> > > 
> > > (have to reproduce it because I lost the console output)
> > > 
> > > 
> > 
> > Hmm, sk_dst_get() assumes dst are always freed after RCU grace period,
> > but it seems not the case with IPv6.
> > 
> > We should atomically set dst->__refcnt to -1 before RCU grace period and
> > final destruction, then sk_dst_get should do something like :
> > 
> > rcu_read_lock();
> > dst = rcu_dereference(sk->sk_dst_cache); 
> > if (dst && !atomic_add_unless(&dst->__refcnt, 1, -1))
> > 	dst = NULL;
> > rcu_read_unlock();
> > 
> > Ie we should not increment dst->__refcnt if the dst is in dismantle
> > phase.
> 
> I just took a look at this bug and enhanced the dst_hold etc. functions
> with some debugging printks. I wanted to share this early, because perhaps
> someone can see some irregularities (some more comments below this dump):
> 

Thanks !

> [   93.978053] dst_hold: dst ffff880114068000 refcnt 22 function ip6_pol_route
> [   93.988850] dst_hold: dst ffff880114068000 refcnt 23 function ip6_pol_route
> [   93.998861] dst_release: dst ffff880114068000 refcnt 22 function xfrm_lookup
> [   94.004164] dst_hold: dst ffff880114068000 refcnt 23 function ip6_append_data
> [   94.012453] dst_clone: dst ffff880114068000 refcnt 24 function ip6_push_pending_frames
> [   94.026899] dst_release: dst ffff880114068000 refcnt 23 function ip6_cork_release
> [   94.030852] dst_release: dst ffff880114068000 refcnt 22 function icmp6_send
> [   94.036985] dst_release: dst ffff880114068000 refcnt 21 function refdst_drop
> [   94.055102] dst_release: dst ffff880114068000 refcnt 20 function ip6_cork_release
> [   94.059135] dst_release: dst ffff880114068000 refcnt 19 function refdst_drop
> [   94.065347] __sk_dst_set: old           (null) new ffff880114068000 function sk_setup_caps
> [   94.084732] __sk_dst_set: old           (null) new           (null) function __sk_dst_reset
> [   94.089431] dst_hold: dst ffff8800d8804b40 refcnt 14 function __mkroute_output
> [   94.098050] dst_release: dst ffff8800d8804b40 refcnt 13 function ip_rt_put
> [   94.104430] dst_hold: dst ffff8800d8804b40 refcnt 14 function __mkroute_output
> [   94.113920] __sk_dst_set: old           (null) new ffff8800d8804b40 function ip4_datagram_connect
> [   94.125054] __sk_dst_get: dst ffff8800d8804b40 refcnt 14 function ip4_datagram_release_cb
> [   94.128609] __sk_dst_get: dst ffff8800d8804b40 refcnt 14 function __sk_dst_check
> [   94.150443] dst_hold: dst ffff8800d8804b40 refcnt 15 function _sk_dst_get
> [   94.156309] sk_dst_get: dst ffff8800d8804b40 refcnt 15 function sk_dst_check
> [   94.160462] dst_release: dst ffff8800d8804b40 refcnt 14 function ip6_sk_dst_check
> [   94.164943] dst_hold: dst ffff88011466bb10 refcnt 2 function ip6_pol_route
> [   94.177854] dst_release: dst ffff88011466bb10 refcnt 1 function ip6_rt_put

Oh well...

It sounds we mix ipv4/ipv6 dst on an IPV6 socket.

So an IPV4 actor thinks he got a "struct rtable" pointer and messes
critical fields which overlay struct rt6_info components, for example
rt6i_node

rt6_inode  shares the same storage with : 

rt_type/rt_is_input/rt_uses_gateway/rt_iif

In my case, rt_iif is 0

CC Steffen Klassert, because of commit
8141ed9fcedb278f4a3a78680591bef1e55f75fb
("ipv4: Add a socket release callback for datagram sockets")
