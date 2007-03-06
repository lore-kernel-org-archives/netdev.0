From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: linux 2.6 Ipv4 routing enhancement (fwd)
Date: Tue, 6 Mar 2007 12:04:54 +0100
Message-ID: <17901.19158.878755.883322@robur.slu.se>
References: <Pine.LNX.4.62.0703050953090.24653@alpha.cflinux.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Robert.Olsson@data.slu.se
To: Richard Kojedzinszky <krichy@cflinux.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:44655 "EHLO mx1.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964931AbXCFLE4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 06:04:56 -0500
Received: from robur.slu.se (robur.slu.se [130.238.98.12])
	by mx1.slu.se (8.13.7/8.13.6) with ESMTP id l26B4scZ011344
	for <netdev@vger.kernel.org>; Tue, 6 Mar 2007 12:04:55 +0100
In-Reply-To: <Pine.LNX.4.62.0703050953090.24653@alpha.cflinux.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Richard Kojedzinszky writes:

 > traffic, and also update the routing table (from BGP), the route cache 
 > seemed to be the bottleneck, as upon every fib update the whole route 
 > cache is flushed, and sometimes it took as many cpu cycles to let some 
 > packets being dropped. Meanwhile i knew that *BSD systems do not use such 
 > a cache, and of course without it a router can provide a constant 
 > performance, not depending on the number of different ip flows, and 
 > updating the fib does not take such a long time.

 Hmm I think there is cache is *BSD* too  

 Anyway you're correct the that the GC and insert/deletion of routes
 flushes the cache and can causes packets drops when all flows has
 to get recreated. Yes it's something thats needs to be addressed but
 it's not that common that people use dynamic routing protocols.

 Anyway Dave and Alexey started to look into this some time ago I got 
 involved later there were some idea how deal with this. This work 
 didn't come an end. So if you want to contribute I think we all be 
 happy. 

 > For this to be solved, i have played with ipv4 routing in linux kernel a 
 > bit. I have done two separate things:
 > - developed a new fib algorithm in fib_trie's place for ipv4
 > - rewrote the kernel not to use it's dst cache

 Just for routing?

 > The fib algorithm is like cisco's CEF (at least if my knowledge is correct), 
 > but first I use a 16-branching tree, to look up the address by 4 bit steps, and 
 > each node in this tree contains a simple sub-tree which is a radix tree, of 
 > course with maximum possible height 4. I think this is very simple, and is 
 > nearly 3 times faster than fib_trie. Now it has a missing feature: it does not 
 > export the fib in /proc/net/route.

 Full semantic match... . 
 
 The LC-trie scales tree brancing automatically so looking into linux 
 router running full BGP feed with 204300 prefixes we see:
   
 1: 27567  2: 10127  3: 8149  4: 3630  5: 1529  6: 558  7: 197  8: 53  16: 1

 Root node is 16-bit too and   Aver depth:     2.60
 So 3 times faster than fib_trie thats full sensation. How do you test?

 > The second thing i have done to minimize the cpu cycles during the forwarding 
 > phase, rewriting ip_input.c, route.c and some others to lef.c, and having a 
 > minimal functionality. I mean, for example, when a packet gets through the lef 
 > functions, ipsec policies are not checked.

  It would be nice to see a profile before and with your patch 

 > And to be more efficient, I attached a neighbour pointer to each fib entry, and 
 > using this the lookup + forwarding code is very fast.

 > Of course, the route cache needs very little time to forward packets when there 
 > are a small number of different ip flows, but when dealing with traffic in an 
 > ISP at core level, this cannot be stated.

 > So I have done tests with LEF, and compared them to the original linux kernel's 
 > performance.
 > With the worst case, LEF performed nearly 90% of the linux kernel with the most 
 > optimal case. Of course original linux performs poorly with the worst case.

 Send them and with profiles is possible...

 Cheers.

						--ro
