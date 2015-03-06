From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH v2 00/10] The rest of the FIB patches (add
 key_vector to fib_table)
Date: Fri, 06 Mar 2015 09:53:49 -0800
Message-ID: <20150306174814.2452.18308.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45305 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753429AbbCFRxv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Mar 2015 12:53:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series is the rest of what I had originally planned for this kernel
release.  It adds a structure called key_vector which is embedded within
every tnode, leaf, and the trie root itself.  By doing this we can navigate
from any point within the trie to any other point fairly quickly and
avoiding NULL pointer checks in the case of a backtrace.  As a result we
can pipeline things a bit further since we don't have to worry about
dereferencing NULL in a backtrace.  This can amount to significant savings
on a long backtrace.

I decided to drop the up-level code as that conflicts with combining the
main and local tries.  I have one patch as an RFC that currently combines
the tries however it still needs some work as we have to split the local
and main tries in the event of custom rules being defined.  As such we are
probably going to be doing some more hacking on fib_table_flush_external as
that will also need to flush the local entries from the main trie and place
them back in the local trie.

v2: Rebased on the switchdev FIB offload work

---

Alexander Duyck (10):
      fib_trie: Minor cleanups to fib_table_flush_external
      fib_trie: Return pointer to tnode pointer in resize/inflate/halve
      fib_trie: Rename tnode to key_vector
      fib_trie: replace tnode_get_child functions with get_child macros
      fib_trie: Rename tnode_child_length to child_length
      fib_trie: Add tnode struct as a container for fields not needed in key_vector
      fib_trie: Move rcu from key_vector to tnode, add accessors.
      fib_trie: Pull empty_children and full_children into tnode
      fib_trie: Move parent from key_vector to tnode
      fib_trie: Add key vector to root, return parent key_vector in resize


 net/ipv4/fib_trie.c |  807 +++++++++++++++++++++++++--------------------------
 1 file changed, 401 insertions(+), 406 deletions(-)

--
