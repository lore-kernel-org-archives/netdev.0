From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [RFC PATCH 00/17] fib_trie: Reduce time spent in fib_table_lookup
 by 35 to 75%
Date: Mon, 22 Dec 2014 09:40:52 -0800
Message-ID: <20141222172632.1119.51469.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39502 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754621AbaLVRkx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Dec 2014 12:40:53 -0500
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sBMHernn012619
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Mon, 22 Dec 2014 12:40:53 -0500
Received: from [192.168.122.173] (ovpn-112-82.phx2.redhat.com [10.3.112.82])
	by int-mx14.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id sBMHeqqW007314
	for <netdev@vger.kernel.org>; Mon, 22 Dec 2014 12:40:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches are meant to address several performance issues I have seen 
in the fib_trie implementation, and fib_table_lookup specifically.  With 
these changes in place I have seen a reduction of up to 35 to 75% for the 
total time spent in fib_table_lookup depending on the type of search being 
performed.

On a VM running in my Corei7-4930K system with a trie of maximum depth of 7 
this resulted in a reduction of over 370ns per packet in the total time to 
process packets received from an ixgbe interface and route them to a dummy 
interface.  This represents a failed lookup in the local trie followed by 
a successful search in the main trie.

				Baseline	Refactor
  ixgbe->dummy routing		1.20Mpps	2.21Mpps
  ------------------------------------------------------------
  processing time per packet		835ns		453ns
  fib_table_lookup		50.1%	418ns	25.0%	113ns
  check_leaf.isra.9		 7.9%	 66ns	   --	 --
  ixgbe_clean_rx_irq		 5.3%	 44ns	 9.8%	 44ns
  ip_route_input_noref		 2.9%	 25ns	 4.6%	 21ns
  pvclock_clocksource_read	 2.6%	 21ns	 4.6%	 21ns
  ip_rcv			 2.6%	 22ns	 4.0%	 18ns

In the simple case of receiving a frame and dropping it before it can reach 
the socket layer I saw a reduction of 40ns per packet.  This represents a 
trip through the local trie with the correct leaf found with no need for 
any backtracing.

				Baseline	Refactor
  ixgbe->local receive		2.65Mpps	2.96Mpps
  ------------------------------------------------------------
  processing time per packet		377ns		337ns
  fib_table_lookup		25.1%	 95ns	25.8%	 87ns
  ixgbe_clean_rx_irq		 8.7%	 33ns	 9.0%	 30ns
  check_leaf.isra.9		 7.2%	 27ns	   --	 --
  ip_rcv			 5.7%	 21ns	 6.5%	 22ns

These changes have resulted in several functions being inlined such as 
check_leaf and fib_find_node, but due to the code simplification the 
overall size of the code has been reduced.

   text	   data	    bss	    dec	    hex	filename
  16932	    376	     16	  17324	   43ac	net/ipv4/fib_trie.o - before
  15259	    376	      8	  15643	   3d1b	net/ipv4/fib_trie.o - after

---

Alexander Duyck (17):
      fib_trie: Update usage stats to be percpu instead of global variables
      fib_trie: Make leaf and tnode more uniform
      fib_trie: Merge tnode_free and leaf_free into node_free
      fib_trie: Merge leaf into tnode
      fib_trie: Optimize fib_table_lookup to avoid wasting time on loops/variables
      fib_trie: Optimize fib_find_node
      fib_trie: Optimize fib_table_insert
      fib_trie: Update meaning of pos to represent unchecked bits
      fib_trie: Use unsigned long for anything dealing with a shift by bits
      fib_trie: Push rcu_read_lock/unlock to callers
      fib_trie: Move resize to after inflate/halve
      fib_trie: Add functions should_inflate and should_halve
      fib_trie: Push assignment of child to parent down into inflate/halve
      fib_trie: Push tnode flushing down to inflate/halve
      fib_trie: inflate/halve nodes in a more RCU friendly way
      fib_trie: Remove checks for index >= tnode_child_length from tnode_get_child
      fib_trie: Add tracking value for suffix length


 include/net/ip_fib.h    |   50 +
 net/ipv4/fib_frontend.c |   29 -
 net/ipv4/fib_rules.c    |   22 -
 net/ipv4/fib_trie.c     | 1915 ++++++++++++++++++++++-------------------------
 4 files changed, 945 insertions(+), 1071 deletions(-)

--
