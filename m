From: Daniel Mack <daniel@zonque.org>
Subject: [PATCH v2 0/2] bpf: add longest prefix match map
Date: Thu, 12 Jan 2017 18:29:20 +0100
Message-ID: <20170112172922.16636-1-daniel@zonque.org>
Cc: dh.herrmann@gmail.com, daniel@iogearbox.net,
        netdev@vger.kernel.org, davem@davemloft.net,
        Daniel Mack <daniel@zonque.org>
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:57048 "EHLO mail.zonque.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750845AbdALR3a (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 12 Jan 2017 12:29:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set adds a longest prefix match algorithm that can be used
to match IP addresses to a stored set of ranges. It is exposed as a
bpf map type.
   
Internally, data is stored in an unbalanced tree of nodes that has a
maximum height of n, where n is the prefixlen the trie was created
with.
 
Not that this has nothing to do with fib or fib6 and is in no way meant
to replace or share code with it. It's rather a much simpler
implementation that is specifically written with bpf maps in mind.
 
Patch 1/2 adds the implementation, and 2/2 an extensive test suite.

We didn't yet get around to augment the tests for non 2^n bit depths
and benchmarks. We'll add that later.
 
Feedback is much appreciated.
 
 
Thanks,
Daniel

Changelog:

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
 kernel/bpf/lpm_trie.c                      | 499 +++++++++++++++++++++++++++++
 tools/testing/selftests/bpf/.gitignore     |   1 +
 tools/testing/selftests/bpf/Makefile       |   4 +-
 tools/testing/selftests/bpf/test_lpm_map.c | 358 +++++++++++++++++++++
 6 files changed, 868 insertions(+), 3 deletions(-)
 create mode 100644 kernel/bpf/lpm_trie.c
 create mode 100644 tools/testing/selftests/bpf/test_lpm_map.c

-- 
2.9.3
