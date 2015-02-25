From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH 0/4] fib_trie: Remove leaf_info structure
Date: Wed, 25 Feb 2015 11:05:55 -0800
Message-ID: <20150225185658.1747.99188.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46298 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753603AbbBYTGH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2015 14:06:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set removes the leaf_info structure from the IPv4 fib_trie.  The
general idea is that the leaf_info structure itself only held about 6
actual bits of data, beyond that it was mostly just waste.  As such we can
drop the structure, move the 1 byte representing the prefix/suffix length
into the fib_alias and just link it all into one list.

My testing shows that this saves somewhere between 4 to 10ns depending on
the type of test performed.  I'm suspecting that this represents 1 to 2 L1
cache misses saved per look-up.

One side effect of this change is that semantic_match_miss will now only
increment once per leaf instead of once per leaf_info miss.  However the
stat is already skewed now that we perform a preliminary check on the leaf
as a part of the look-up.

I also have gone through and addressed a number of ordering issues in the
first patch since I had misread the behavior of list_add_tail.

I have since run some additional testing and verified the resulting lists
are in the same order when combining multiple prefix length and tos values
in a single leaf.

---

Alexander Duyck (4):
      fib_trie: Convert fib_alias to hlist from list
      fib_trie: Replace plen with slen in leaf_info
      fib_trie: Add slen to fib alias
      fib_trie: Remove leaf_info


 include/net/ip_fib.h     |    2 
 net/ipv4/fib_lookup.h    |    3 
 net/ipv4/fib_semantics.c |    4 
 net/ipv4/fib_trie.c      |  489 ++++++++++++++++------------------------------
 4 files changed, 176 insertions(+), 322 deletions(-)

--
