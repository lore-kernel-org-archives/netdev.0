From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 0/4] tcp: better smp listener behavior
Date: Fri, 09 Oct 2015 07:29:58 -0700
Message-ID: <1444400998.27760.60.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1444318627-27883-1-git-send-email-edumazet@google.com>
	 <CALx6S35NOaLyqmWbgcRdV9Swm1NVVSFkoShW0ywMi7V21jhtYQ@mail.gmail.com>
	 <1444387845.27760.55.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	"David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Tobias Klauser <tklauser@distanz.ch>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:36685 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755088AbbJIOaB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2015 10:30:01 -0400
Received: by pablk4 with SMTP id lk4so88460116pab.3
        for <netdev@vger.kernel.org>; Fri, 09 Oct 2015 07:30:01 -0700 (PDT)
In-Reply-To: <1444387845.27760.55.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-10-09 at 03:50 -0700, Eric Dumazet wrote:
> On Thu, 2015-10-08 at 20:42 -0700, Tom Herbert wrote:
> > On Thu, Oct 8, 2015 at 8:37 AM, Eric Dumazet <edumazet@google.com> wrote:
> > > As promised in last patch series, we implement a better SO_REUSEPORT
> > > strategy, based on cpu affinities if selected by the application.
> > >
> > > We also moved sk_refcnt out of the cache line containing the lookup
> > > keys, as it was considerably slowing down smp operations because
> > > of false sharing. This was simpler than converting listen sockets
> > > to conventional RCU (to avoid sk_refcnt dirtying)
> > >
> > > Could process 6.0 Mpps SYN instead of 4.2 Mpps on my test server.
> > >
> > Is this IPv4, IPv6, or some combination of the two ? :-)
> 
> IPv4 only (mostly because I was using trafgen and its csumtcp() only
> deals with IPv4 and I am lazy)
> 
> I guess IPv6 one might hit some issues before reaching TCP stack, I do
> not see anything performance related in TCP itself.
> 
> 

So the answer is : about 800,000 SYN per second in IPV6 with purely DDOS attack

We hit neighbor cache badly.

  377.188231] neighbour: ndisc_cache: neighbor table overflow!
[  377.188234] neighbour: ndisc_cache: neighbor table overflow!
[  382.193043] net_ratelimit: 36622 callbacks suppressed
[  382.193046] neighbour: ndisc_cache: neighbor table overflow!
[  382.193051] neighbour: ndisc_cache: neighbor table overflow!
[  382.193054] neighbour: ndisc_cache: neighbor table overflow!

    59.79%  [kernel]  [k] queued_spin_lock_slowpath 
     4.94%  [kernel]  [k] queued_write_lock_slowpath
     2.12%  [kernel]  [k] sha_transform             
     1.93%  [kernel]  [k] ip6_pol_route.isra.47     
     1.58%  [kernel]  [k] __neigh_create            
     1.30%  [kernel]  [k] inet6_lookup_listener     
     1.19%  [kernel]  [k] memcpy_erms               
     1.09%  [kernel]  [k] _raw_read_lock_bh         
     0.88%  [kernel]  [k] memset_erms               
     0.85%  [kernel]  [k] __inet6_lookup_established
     0.84%  [kernel]  [k] ndisc_constructor         
     0.78%  [kernel]  [k] fib6_get_table            
     0.71%  [kernel]  [k] ip6t_do_table             
     0.71%  [kernel]  [k] _raw_read_unlock_bh       
     0.66%  [kernel]  [k] _raw_write_lock_bh        
     0.62%  [kernel]  [k] fib6_lookup               
     0.54%  [kernel]  [k] tcp_make_synack           
     0.54%  [kernel]  [k] tcp_conn_request          
