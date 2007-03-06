From: Richard Kojedzinszky <krichy@cflinux.hu>
Subject: Re: linux 2.6 Ipv4 routing enhancement (fwd)
Date: Tue, 6 Mar 2007 15:42:18 +0100 (CET)
Message-ID: <Pine.LNX.4.62.0703061539380.17441@alpha.cflinux.hu>
References: <Pine.LNX.4.62.0703050953090.24653@alpha.cflinux.hu>
 <17901.19158.878755.883322@robur.slu.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
To: Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alpha.cflinux.hu ([80.95.81.35]:33294 "HELO alpha.cflinux.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S965083AbXCFOmU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 09:42:20 -0500
In-Reply-To: <17901.19158.878755.883322@robur.slu.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear Robert,

Sorry for sending the tgz with .svn included. And i did not send 
instructions.
To do a test with fib_trie, issue
$ make clean all ROUTE_ALG=TRIE & ./try a
with fib_radix:
$ make clean all ROUTE_ALG=RADIX & ./try a
with fib_lef:
$ make clean all ROUTE_ALG=LEF SBBITS=4 & ./try a

This last is to use 4 bits per main tree nodes. It could be chosen 
arbitrarily, but 4 seemed to be the best choice.

Regards,
Richard Kojedzinszky

On Tue, 6 Mar 2007, Robert Olsson wrote:

>
> Richard Kojedzinszky writes:
>
> > traffic, and also update the routing table (from BGP), the route cache
> > seemed to be the bottleneck, as upon every fib update the whole route
> > cache is flushed, and sometimes it took as many cpu cycles to let some
> > packets being dropped. Meanwhile i knew that *BSD systems do not use such
> > a cache, and of course without it a router can provide a constant
> > performance, not depending on the number of different ip flows, and
> > updating the fib does not take such a long time.
>
> Hmm I think there is cache is *BSD* too
>
> Anyway you're correct the that the GC and insert/deletion of routes
> flushes the cache and can causes packets drops when all flows has
> to get recreated. Yes it's something thats needs to be addressed but
> it's not that common that people use dynamic routing protocols.
>
> Anyway Dave and Alexey started to look into this some time ago I got
> involved later there were some idea how deal with this. This work
> didn't come an end. So if you want to contribute I think we all be
> happy.
>
> > For this to be solved, i have played with ipv4 routing in linux kernel a
> > bit. I have done two separate things:
> > - developed a new fib algorithm in fib_trie's place for ipv4
> > - rewrote the kernel not to use it's dst cache
>
> Just for routing?
>
> > The fib algorithm is like cisco's CEF (at least if my knowledge is correct),
> > but first I use a 16-branching tree, to look up the address by 4 bit steps, and
> > each node in this tree contains a simple sub-tree which is a radix tree, of
> > course with maximum possible height 4. I think this is very simple, and is
> > nearly 3 times faster than fib_trie. Now it has a missing feature: it does not
> > export the fib in /proc/net/route.
>
> Full semantic match... .
>
> The LC-trie scales tree brancing automatically so looking into linux
> router running full BGP feed with 204300 prefixes we see:
>
> 1: 27567  2: 10127  3: 8149  4: 3630  5: 1529  6: 558  7: 197  8: 53  16: 1
>
> Root node is 16-bit too and   Aver depth:     2.60
> So 3 times faster than fib_trie thats full sensation. How do you test?
>
> > The second thing i have done to minimize the cpu cycles during the forwarding
> > phase, rewriting ip_input.c, route.c and some others to lef.c, and having a
> > minimal functionality. I mean, for example, when a packet gets through the lef
> > functions, ipsec policies are not checked.
>
>  It would be nice to see a profile before and with your patch
>
> > And to be more efficient, I attached a neighbour pointer to each fib entry, and
> > using this the lookup + forwarding code is very fast.
>
> > Of course, the route cache needs very little time to forward packets when there
> > are a small number of different ip flows, but when dealing with traffic in an
> > ISP at core level, this cannot be stated.
>
> > So I have done tests with LEF, and compared them to the original linux kernel's
> > performance.
> > With the worst case, LEF performed nearly 90% of the linux kernel with the most
> > optimal case. Of course original linux performs poorly with the worst case.
>
> Send them and with profiles is possible...
>
> Cheers.
>
> 						--ro
>
