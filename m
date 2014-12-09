From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH] fib_trie: Fix /proc/net/fib_trie when
 CONFIG_IP_MULTIPLE_TABLES is not defined
Date: Mon, 08 Dec 2014 21:14:59 -0500 (EST)
Message-ID: <20141208.211459.962962459399411790.davem@davemloft.net>
References: <20141202185238.1540.48554.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: alexander.h.duyck@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59385 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755257AbaLICPC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2014 21:15:02 -0500
In-Reply-To: <20141202185238.1540.48554.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@redhat.com>
Date: Tue, 02 Dec 2014 10:58:21 -0800

> In recent testing I had disabled CONFIG_IP_MULTIPLE_TABLES and as a result
> when I ran "cat /proc/net/fib_trie" the main trie was displayed multiple
> times.  I found that the problem line of code was in the function
> fib_trie_seq_next.  Specifically the line below caused the indexes to go in
> the opposite direction of our traversal:
> 
> 	h = tb->tb_id & (FIB_TABLE_HASHSZ - 1);
> 
> This issue was that the RT tables are defined such that RT_TABLE_LOCAL is ID
> 255, while it is located at TABLE_LOCAL_INDEX of 0, and RT_TABLE_MAIN is 254
> with a TABLE_MAIN_INDEX of 1.  This means that the above line will return 1
> for the local table and 0 for main.  The result is that fib_trie_seq_next
> will return NULL at the end of the local table, fib_trie_seq_start will
> return the start of the main table, and then fib_trie_seq_next will loop on
> main forever as h will always return 0.
> 
> The fix for this is to reverse the ordering of the two tables.  It has the
> advantage of making it so that the tables now print in the same order
> regardless of if multiple tables are enabled or not.  In order to make the
> definition consistent with the multiple tables case I simply masked the to
> RT_TABLE_XXX values by (FIB_TABLE_HASHSZ - 1).  This way the two table
> layouts should always stay consistent.
> 
> Fixes: 93456b6 ("[IPV4]: Unify access to the routing tables")
> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>

Applied and queued up for -stable, thanks!
