From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Extensible hashing and RCU
Date: Sun, 18 Feb 2007 21:21:30 +0100
Message-ID: <45D8B54A.70903@cosmosbay.com>
References: <20070204074143.26312.qmail@science.horizon.com> <Pine.LNX.4.61.0702050952590.26852@localhost.localdomain> <20070217131302.GA22732@2ka.mipt.ru> <45D89EFE.4080103@cosmosbay.com> <20070218191009.GA28216@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
	format=flowed
Content-Transfer-Encoding: 7BIT
Cc: akepner@sgi.com, linux@horizon.com, davem@davemloft.net,
	netdev@vger.kernel.org, bcrl@linux.intel.com
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:60126 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752044AbXBRU13 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Feb 2007 15:27:29 -0500
In-Reply-To: <20070218191009.GA28216@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov a e'crit :
> On Sun, Feb 18, 2007 at 07:46:22PM +0100, Eric Dumazet (dada1@cosmosbay.com) wrote:
>>> Why anyone do not want to use trie - for socket-like loads it has
>>> exactly constant search/insert/delete time and scales as hell.
>>>
>> Because we want to be *very* fast. You cannot beat hash table.
>>
>> Say you have 1.000.000 tcp connections, with 50.000 incoming packets per 
>> second to *random* streams...
> 
> What is really good in trie, that you may have upto 2^32 connections
> without _any_ difference in lookup performance of random streams.

So are you speaking of one memory cache miss per lookup ?
If not, you loose.

> 
>> With a 2^20 hashtable, a lookup uses one cache line (the hash head pointer) 
>> plus one cache line to get the socket (you need it to access its refcounter)
>>
>> Several attempts were done in the past to add RCU to ehash table (last done 
>> by Benjamin LaHaise last March). I believe this was delayed a bit, because 
>> David would like to be able to resize the hash table...
> 
> This is a theory.

Not theory, but actual practice, on a real machine.

# cat /proc/net/sockstat
sockets: used 918944
TCP: inuse 925413 orphan 7401 tw 4906 alloc 926292 mem 304759
UDP: inuse 9
RAW: inuse 0
FRAG: inuse 9 memory 18360


> Practice includes cost for hashing, locking, and list traversal
> (each pointer is in own cache line btw, which must be fetched) and plus
> the same for time wait sockets (if we are unlucky).
> 
> No need to talk about price of cache miss when there might be more
> serious problems - for example length of the linked list to traverse each 
> time new packet is received.
> 
> For example lookup time in trie with 1.6 millions random 3-dimensional
> 32bit (saddr/daddr/ports) entries is about 1 microsecond on amd athlon64 
> 3500 cpu (test was ran in userspace emulator though).

1 microsecond ? Are you kidding ? We want no more than 50 ns.

You can check on this dual cpu machine, tcp_v4_rcv() uses 2.29 % of cpu.

CPU: AMD64 processors, speed 1992.67 MHz (estimated)
Counted CPU_CLK_UNHALTED events (Cycles outside of halt state) with a unit 
mask of 0x00 (No unit mask) count 100000
samples  %        symbol name
2009510   4.6863  memcpy_c
1668842   3.8918  tg3_start_xmit_dma_bug
1485844   3.4651  tg3_poll
1293558   3.0167  kmem_cache_free
1232862   2.8751  kfree
1131012   2.6376  free_block
1000671   2.3336  ip_route_input
982655    2.2916  tcp_v4_rcv
955554    2.2284  __alloc_skb
863753    2.0143  tcp_ack
863222    2.0131  tcp_recvmsg
834680    1.9465  fget_light
801445    1.8690  lock_sock_nested
793699    1.8510  tcp_sendmsg
764689    1.7833  copy_user_generic_string
743515    1.7339  ip_queue_xmit
712314    1.6612  sock_wfree
650486    1.5170  tcp_rcv_established

