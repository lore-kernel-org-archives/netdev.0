From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [RFC PATCH 00/29] Phase 2 of fib_trie updates
Date: Tue, 24 Feb 2015 12:47:55 -0800
Message-ID: <20150224202837.26106.87623.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45511 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750925AbbBXUr5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Feb 2015 15:47:57 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id t1OKlusf021620
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 15:47:56 -0500
Received: from [192.168.122.173] (ovpn-112-73.phx2.redhat.com [10.3.112.73])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t1OKlu86014020
	for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 15:47:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series implements the second phase of the fib_trie changes.  I
presented on these and the previous changes at Netdev01 and netconf.  The
slides for the Netdev01 presentation can be found at
https://www.netdev01.org/docs/duyck-fib-trie.pdf.

I'm currently debating if I should just submit the entire patch-set as-is
or if I should hold off on submitting the last 10 patches as they currently
have a potential performance impact in the case of a large number of
entries placed in the local table.  Specifically I have seen that removing
an interface in the case of 8K local subnets being configured on it
resulted in the time for a dummy interface being removed increasing from
about .6 seconds to 2.4 seconds.  I am not sure how common of a use-case
something like this would be.  I have not seen the same issue if I assign
8K routes to the interface as I believe the fib_table_flush aggregates them
all in to one resize action.

The entire series reduces the total look-up time by another 20-35% versus
what is currently in the 4.0-rc1 kernel.  So for example a set of routing
look-ups which took 140ns in the 4.0-rc1 kernel will now only take about
105ns after these patches.

---

Alexander Duyck (29):
      fib_trie: Convert fib_alias to hlist from list
      fib_trie: Replace plen with slen in leaf_info
      fib_trie: Add slen to fib alias
      fib_trie: Remove leaf_info
      fib_trie: Only resize N/2 times instead N * log(N) times in fib_table_flush
      fib_trie: Fib walk rcu should take a tnode and key instead of a trie and a leaf
      fib_trie: Fib find node should return parent
      fib_trie: Update insert and delete to make use of tp from find_node
      fib_trie: Make fib_table rcu safe
      fib_trie: Return pointer to tnode pointer in resize/inflate/halve
      fib_trie: Rename tnode to key_vector
      fib_trie: move leaf and tnode to occupy the same spot in the key vector
      fib_trie: replace tnode_get_child functions with get_child macros
      fib_trie: Rename tnode_child_length to child_length
      fib_trie: Add tnode struct as a container for fields not needed in key_vector
      fib_trie: Move rcu from key_vector to tnode, add accessors.
      fib_trie: Pull empty_children and full_children into tnode
      fib_trie: Move parent from key_vector to tnode
      fib_trie: Add key vector to root, return parent key_vector in resize
      fib_trie: Push net pointer down into fib_trie insert/delete/flush calls
      fib_trie: Rewrite handling of RCU to include parent in replacement
      fib_trie: Allocate tnode as array of key_vectors instead of key_vector as array of tnode pointers
      fib_trie: Add leaf_init
      fib_trie: Update tnode_new to drop use of put_child_root
      fib_trie: Add function for dropping children from trie
      fib_trie: Use put_child to only copy key_vectors instead of pointers
      fib_trie: Move key and pos into key_vector from tnode
      fib_trie: Move slen from tnode to key vector
      fib_trie: Push bits up one level, and move leaves up into parent key_vector array


 include/net/ip_fib.h     |   80 +-
 include/net/netns/ipv4.h |    7 
 net/ipv4/fib_frontend.c  |   89 ++
 net/ipv4/fib_lookup.h    |    3 
 net/ipv4/fib_semantics.c |    4 
 net/ipv4/fib_trie.c      | 1974 ++++++++++++++++++++++++----------------------
 6 files changed, 1152 insertions(+), 1005 deletions(-)

--
