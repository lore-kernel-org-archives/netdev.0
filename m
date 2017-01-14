From: Daniel Mack <daniel@zonque.org>
Subject: [PATCH v3 0/2] bpf: add longest prefix match map
Date: Sat, 14 Jan 2017 13:17:25 +0100
Message-ID: <20170114121727.14784-1-daniel@zonque.org>
Cc: dh.herrmann@gmail.com, daniel@iogearbox.net,
        netdev@vger.kernel.org, davem@davemloft.net,
        Daniel Mack <daniel@zonque.org>
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:41029 "EHLO mail.zonque.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751919AbdANMRf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 14 Jan 2017 07:17:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set adds a longest prefix match algorithm that can be used
to match IP addresses to a stored set of ranges. It is exposed as a
bpf map type.
   
Internally, data is stored in an unbalanced tree of nodes that has a
maximum height of n, where n is the prefixlen the trie was created
with.
 
Note that this has nothing to do with fib or fib6 and is in no way meant
to replace or share code with it. It's rather a much simpler
implementation that is specifically written with bpf maps in mind.
 
Patch 1/2 adds the implementation, and 2/2 an extensive test suite.

Feedback is much appreciated.
 
 
Thanks,
Daniel

Changelog:

v2 -> v3:
	* Store both the key match data and the caller provided
	  value in the same byte array attached to a node. This
	  avoids double allocations
	* Bring back node->flags to distinguish between 'real'
	  and intermediate nodes
	* Fix comment style and some typos

v1 -> v2:
	* Turn spin lock into raw spinlock
	* Lock with irqsave options during trie_update_elem()
	* Return -ENOMEM properly from trie_alloc()
	* Force attr->flags == BPF_F_NO_PREALLOC during creation
	* Set trie->map.pages after creation to account for map memory
	* Allow arbitrary value sizes
	* Removed node->flags and denode intermediate nodes through
	  node->value == NULL instead

rfc -> v1:
	* Add __rcu pointer annotations to make sparse happy
	* Fold _lpm_trie_find_target_node() into its only caller
	* Fix some minor documentation issues


Daniel Mack (1):
  bpf: add a longest prefix match trie map implementation

David Herrmann (1):
  bpf: Add tests for the lpm trie map

 include/uapi/linux/bpf.h                   |   7 +
 kernel/bpf/Makefile                        |   2 +-
 kernel/bpf/lpm_trie.c                      | 493 +++++++++++++++++++++++++++++
 tools/testing/selftests/bpf/.gitignore     |   1 +
 tools/testing/selftests/bpf/Makefile       |   4 +-
 tools/testing/selftests/bpf/test_lpm_map.c | 358 +++++++++++++++++++++
 6 files changed, 862 insertions(+), 3 deletions(-)
 create mode 100644 kernel/bpf/lpm_trie.c
 create mode 100644 tools/testing/selftests/bpf/test_lpm_map.c

-- 
2.9.3
