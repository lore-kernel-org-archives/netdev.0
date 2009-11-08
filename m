From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH 0/8 net-next-2.6] udp: optimisations
Date: Sun, 08 Nov 2009 21:16:56 +0100
Message-ID: <4AF72738.7020606@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Lucian Adrian Grijincu <lgrijincu@ixiacom.com>,
	Octavian Purdila <opurdila@ixiacom.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:39123 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754516AbZKHURB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Nov 2009 15:17:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series address UDP scalability problems, we failed to solve in 2007
(commit 6aaf47fa48d3c44 INET : IPV4 UDP lookups converted to a 2 pass algo)
we had to revert a bit later.

One of the problem of UDP is its use of a single hash table, with
a key based on local port value only. When many IP addresses are used,
it is possible to have a chain with very large number N of sockets,
lookup time being N/2 in average.

Size of hash table has no effect on this, since all sockets are
chained in one particular slot.

It seems Lucian Adrian Grijincu & Octavian Purdila from IXIACOM have 
real workloads hitting hard this problem and posted a preliminary
patch/RFC, using a second hash, but based on (local address).

I took part of Lucian ideas and my previous patches, and cooked
a clean upgrade path.

With following patches, we might handle 1.000.000+ udp sockets
in linux without major slowdown, and no penalty for common cases.

Thanks

[PATCH 1/8] udp: add a counter into udp_hslot

Adds a counter in udp_hslot to keep an accurate count
of sockets present in chain.

This will permit to upcoming UDP lookup algo to chose
the shortest chain when secondary hash is added.

[PATCH 2/8] udp: split sk_hash into two u16 hashes

nion sk_hash with two u16 hashes for udp (no extra memory taken)

One 16 bits hash on (local port) value (the previous udp 'hash')

One 16 bits hash on (local address, local port) values, initialized
but not yet used. This second hash is using jenkin hash for better
distribution.

Because the 'port' is xored later, a partial hash is performed
on local address + net_hash_mix(net)

[PATCH 3/8] udp: secondary hash on (local port, local address)

Extends udp_table to contain a secondary hash table.

socket anchor for this second hash is free, because UDP
doesnt use skc_bind_node : We define an union to hold
both skc_bind_node & a new hlist_nulls_node udp_portaddr_node

udp_lib_get_port() inserts sockets into second hash chain
(additional cost of one atomic op)

udp_lib_unhash() deletes socket from second hash chain
(additional cost of one atomic op)

Note : No special lockdep annotation is needed, because
lock for the secondary hash chain is always get after
lock for primary hash chain.

[PATCH 4/8] ipv4: udp: optimize unicast RX path

We first locate the (local port) hash chain head
If few sockets are in this chain, we proceed with previous lookup algo.

If too many sockets are listed, we take a look at the secondary
(port, address) hash chain.

We choose the shortest chain and proceed with a RCU lookup on the elected chain.

But, if we chose (port, address) chain, and fail to find a socket on given address,
 we must try another lookup on (port, INADDR_ANY) chain to find sockets not bound
to a particular IP.

-> No extra cost for typical setups, where the first lookup will probabbly
be performed.

RCU lookups everywhere, we dont acquire spinlock.

[PATCH 5/8] ipv6: udp: optimize unicast RX path

Same algo than patch 4, but for ipv6


[PATCH 6/8] ipv4: udp: Optimise multicast reception

UDP multicast rx path is a bit complex and can hold a spinlock
for a long time.

Using a small (32 or 64 entries) stack of socket pointers can help
to perform expensive operations (skb_clone(), udp_queue_rcv_skb())
outside of the lock, in most cases.

It's also a base for a future RCU conversion of multicast recption.


[PATCH 7/8] ipv6: udp: Optimise multicast reception

Same optimisation, but for ipv6

[PATCH 8/8] udp: multicast RX should increment SNMP/sk_drops counter in allocation failures

When skb_clone() fails, we should increment sk_drops and SNMP counters.
This fix is not urgent and better done after previous patches.

-------------------------------------------------------------------------------------

Furthers patches could be :

udp: bind() optimisations
udp: multicast uses of secondary hash 
udp: multicast path uses RCU  
