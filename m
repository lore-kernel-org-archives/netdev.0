From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: /proc/net/sockstat invalid memory accounting or memory leak in
 latest =?UTF-8?Q?kernels=3F=20=28trying=20to=20debug=29?=
Date: Wed, 12 Nov 2014 19:07:48 +0200
Message-ID: <2adbf5346b4dd2bebe1915096c1c567c@visp.net.lb>
References: <40bc2b5fcda47d790f1fd247bc409041@visp.net.lb>
 <1405597918.10255.76.camel@edumazet-glaptop2.roam.corp.google.com>
 <37e25a5815a18a2da507a5b20b58427d@visp.net.lb>
 <1405604568.10255.80.camel@edumazet-glaptop2.roam.corp.google.com>
 <a927787503c2f0d71c330b879303b14f@visp.net.lb>
 <1405672897.10255.95.camel@edumazet-glaptop2.roam.corp.google.com>
 <1405676214.10255.96.camel@edumazet-glaptop2.roam.corp.google.com>
 <0b0b74ab8d2222fa85b23e06c6e992ec@visp.net.lb>
 <1405849675.10255.100.camel@edumazet-glaptop2.roam.corp.google.com>
 <6fc086a122bc3ac728a7aec9e812310f@visp.net.lb>
 <1406016045.10255.122.camel@edumazet-glaptop2.roam.corp.google.com>
 <3f463c3912608f7959481edaa6d7668d@visp.net.lb>
 <1406194817.3363.70.camel@edumazet-glaptop2.roam.corp.google.com>
 <8f138d88e3b850130eb9bb15e3e27069@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:50689 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753009AbaKLROw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2014 12:14:52 -0500
Received: from hosting.visp.net.lb (localhost [127.0.0.1])
	by hosting.visp.net.lb (Postfix) with ESMTP id 628B14809B6
	for <netdev@vger.kernel.org>; Wed, 12 Nov 2014 19:07:48 +0200 (EET)
In-Reply-To: <8f138d88e3b850130eb9bb15e3e27069@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi


I've been able to trace invalid memory shown for sk_forward_alloc. Not 
sure if it is related to bug when all tcp stack are wrecked on highload 
servers (i had even such crash on server with plain torrents, not that 
much of them).
First they were appearing in ss output as f4294966016, but in tc it 
shows as unsigned integer, while in kernel it is signed integer. Should 
i provide patch for iproute2?
After changing value to correct one, here is what is got:
          skmem:(r0,rb359040,t0,tb46080,f-1280,w1280,o0,bl0)
          skmem:(r0,rb349440,t0,tb46080,f-1280,w1280,o0,bl0)
          skmem:(r0,rb349440,t0,tb46080,f-1280,w1280,o0,bl0)
          skmem:(r0,rb349440,t0,tb46080,f-1280,w1280,o0,bl0)
          skmem:(r0,rb357120,t0,tb46080,f-1280,w1280,o0,bl0)
          skmem:(r0,rb349440,t0,tb46080,f-1280,w1280,o0,bl0)
          skmem:(r0,rb357120,t0,tb46080,f-1280,w1280,o0,bl0)
          skmem:(r0,rb349440,t0,tb46080,f-1280,w1280,o0,bl0)
          skmem:(r0,rb357120,t0,tb46080,f-1280,w1280,o0,bl0)
          skmem:(r0,rb349440,t0,tb46080,f-1280,w1280,o0,bl0)
          skmem:(r0,rb349440,t0,tb46080,f-1280,w1280,o0,bl0)
          skmem:(r0,rb349440,t0,tb46080,f-1280,w1280,o0,bl0)
          skmem:(r0,rb349440,t0,tb46080,f-1280,w1280,o0,bl0)
          skmem:(r0,rb357120,t0,tb46080,f-1280,w1280,o0,bl0)
          skmem:(r0,rb357120,t0,tb46080,f-1280,w1280,o0,bl0)
          skmem:(r0,rb357120,t0,tb46080,f-1280,w1280,o0,bl0)
          skmem:(r0,rb357120,t0,tb46080,f-1280,w1280,o0,bl0)
          skmem:(r0,rb349440,t0,tb46080,f-1280,w1280,o0,bl0)
          skmem:(r0,rb349440,t0,tb46080,f-1280,w1280,o0,bl0)
          skmem:(r0,rb357120,t0,tb46080,f-1280,w1280,o0,bl0)

So as it is signed integer, it is actually appears a lot as -1280 bytes.
After placing several WARN_ON_ONCE on fall functions involving 
sk_forward_alloc, where negative value may
appear i traced down at least to tcp_connect_queue_skb().
[   13.094561] WARNING: CPU: 4 PID: 2855 at include/net/sock.h:1476 
tcp_connect_queue_skb+0x9f/0xd0()
After adding some debug values, it was confirmed:


skb_header_release(skb);
__tcp_add_write_queue_tail(sk, skb);
sk->sk_wmem_queued += skb->truesize;
sk_mem_charge(sk, skb->truesize); <<<< sk->sk_forward_alloc often is 0, 
and skb->truesize is 1280, so -1280 is result
tp->write_seq = tcb->end_seq;
tp->packets_out += tcp_skb_pcount(skb);

Maybe it should not be subtracted here? Or maybe logic are inverted all 
over the code?
Please help :)
