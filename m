From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH 0/3] net: RCU lookups for UDP, DCCP and TCP protocol
Date: Thu, 13 Nov 2008 14:13:20 +0100
Message-ID: <491C27F0.8000507@cosmosbay.com>
References: <4908627C.6030001@acm.org> <490874F2.2060306@cosmosbay.com> <49088288.6050805@acm.org> <49088AD1.7040805@cosmosbay.com> <20081029163739.GB6732@linux.vnet.ibm.com> <49089BE5.3090705@acm.org> <4908A134.4040705@cosmosbay.com> <4908AB3F.1060003@acm.org> <20081029185200.GE6732@linux.vnet.ibm.com> <4908C0CD.5050406@cosmosbay.com> <20081029201759.GF6732@linux.vnet.ibm.com> <4908DEDE.5030706@cosmosbay.com> <4909D551.9080309@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Corey Minyard <minyard@acm.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	benny+usenet@amorsen.dk,
	Linux Netdev List <netdev@vger.kernel.org>,
	Christoph Lameter <cl@linux-foundation.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Christian Bell <christian@myri.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:43279 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751658AbYKMNOG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2008 08:14:06 -0500
In-Reply-To: <4909D551.9080309@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all

Here is a serie of three patches (based on net-next-2.6), to continue work
with RCU on UDP/TCP/DCCP stacks

Many thanks for all usefull reviews and comments, especially from Paul and Corey.

1) Introduce hlist_nulls variant of hlist

   hlist uses NULL value to finish a chain.
   hlist_nulls variant use the low order bit set to 1 to signal an end marker.
   This allows to store many different end markers, so that some RCU lockless
   algos (used in TCP/UDP stack for example) can save some memory barriers in
   fast paths.

2) Use hlist_nulls in UDP RCU code

   This is a straightforward patch, using hlist_nulls infrastructure.
   RCU-ification already done on UDP two weeks ago, so hlist_nulls
   permits us to avoid some memory barriers, both at lookup time
   and delete time. Patch is large because it adds new macros to
   include/net/sock.h. These macros will be used by TCP & DCCP too.

3) Convert TCP & DCCP hash tables to use RCU & hlist_nulls

   RCU was added to UDP lookups, using a fast infrastructure :
   - sockets kmem_cache use SLAB_DESTROY_BY_RCU and dont pay the
     price of call_rcu() at freeing time.
   - hlist_nulls permits to use few memory barriers.

   This patch uses same infrastructure for TCP/DCCP established
   and timewait sockets.

   Thanks to SLAB_DESTROY_BY_RCU, no slowdown for applications
   using short lived TCP connections. A followup patch, converting
   rwlocks to spinlocks will even speedup this case.

   __inet_lookup_established() is pretty fast now we dont have to
   dirty a contended cache line (read_lock/read_unlock)

   Only established and timewait hashtable are converted to RCU
  (bind table and listen table are still using traditional locking)


Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
