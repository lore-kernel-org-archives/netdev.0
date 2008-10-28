From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH 0/2] udp: Convert the UDP hash lock to RCU
Date: Tue, 28 Oct 2008 21:37:15 +0100
Message-ID: <490777FB.2070506@cosmosbay.com>
References: <m37i8k3hv1.fsf@ursa.amorsen.dk>	<48EB5D28.7000503@cosmosbay.com>	<20081007160729.60c076c4@speedy> <20081007.135548.56141000.davem@davemloft.net> <48ECBBD8.9060602@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, benny+usenet@amorsen.dk, minyard@acm.org,
	netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com,
	Christoph Lameter <clameter@sgi.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:46938 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752330AbYJ1Uq3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 16:46:29 -0400
In-Reply-To: <48ECBBD8.9060602@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

UDP sockets are hashed in a 128 slots hash table.

This hash table is protected by *one* rwlock.

This rwlock is readlocked each time an incoming UDP message is handled.

This rwlock is writelocked each time a socket must be inserted in
hash table (bind time), or deleted from this table (unbind time)

This is not scalable on SMP machines :

1) Even in read mode, lock() and unlock() are atomic operations and
must dirty a contended cache line, shared by all cpus.

2) A writer might be starved if many readers are 'in flight'. This can
happen on a machine with some NIC receiving many UDP messages. User
process can be delayed a long time at socket creation/dismantle time.


What Corey and I propose is to use RCU to protect this hash table.

Goals are :

1) Optimizing handling of incoming Unicast UDP frames, so that no memory
writes should happen in the fast path. Using an array of rwlocks (one per
slot for example is not an option in this regard)

Note: Multicasts and broadcasts still will need to take a lock,
because doing a full lockless lookup in this case is difficult.

2) No expensive operations in the socket bind/unhash phases :
  - No expensive synchronize_rcu() calls.

  - No added rcu_head in socket structure, increasing memory needs,
  but more important, forcing us to use call_rcu() calls,
  that have the bad property of making sockets structure cold.
  (rcu grace period between socket freeing and its potential reuse
   make this socket being cold in CPU cache).
  David did a previous patch using call_rcu() and noticed a 20%
  impact on TCP connection rates.

  Quoting Cristopher Lameter :
  "Right. That results in cacheline cooldown. You'd want to recycle
   the object as they are cache hot on a per cpu basis. That is screwed
   up by the delayed regular rcu processing. We have seen multiple
   regressions due to cacheline cooldown.
   The only choice in cacheline hot sensitive areas is to deal with the
   complexity that comes with SLAB_DESTROY_BY_RCU or give up on RCU."

  - Because udp sockets are allocated from dedicated kmem_cache,
  use of SLAB_DESTROY_BY_RCU can help here.

Theory of operation :
---------------------

As the lookup is lockfree (using rcu_read_lock()/rcu_read_unlock()),
special attention must be taken by readers and writers.

Use of SLAB_DESTROY_BY_RCU is tricky too, because a socket can be freed,
reused, inserted in a different chain or in worst case in the same chain
while readers could do lookups in the same time.

In order to avoid loops, a reader must check each socket found in a chain
really belongs to the chain the reader was traversing. If it finds a
mismatch, lookup must start again at the begining. This *restart* loop
is the reason we had to use rdlock for the multicast case, because
we dont want to send same message several times to the same socket.

We use RCU only for fast path. Thus, /proc/net/udp still take rdlocks.


Work splited on two patches.

[PATCH 1/2] udp: introduce struct udp_table and multiple rwlocks

Introduction 'struct udp_table and struct udp_hslot',
with one rwlock per chain, instead of a global one.
Some cleanups were done to ease review of next patch.

[PATCH 2/2] udp: RCU handling for Unicast packets.


Tests done on a dual quad core machine (8 cpus) with IPV4 only were
pretty good, since some microbenches ran ten times faster. 

Many thanks to all contributors (David Miller, Christoph Lameter,
Peter Zijlstra, Stephen Hemminger, Paul E. McKenney, Evgeniy Polyakov)
for their review/comments on initial Corey work.
