From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 05/17] fib_trie: Optimize fib_table_lookup to avoid
 wasting time on loops/variables
Date: Mon, 22 Dec 2014 13:30:19 -0500 (EST)
Message-ID: <20141222.133019.716786364937152211.davem@davemloft.net>
References: <20141222172632.1119.51469.stgit@ahduyck-vm-fedora20>
	<20141222174123.1119.28780.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: alexander.h.duyck@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41965 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754355AbaLVSaV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2014 13:30:21 -0500
In-Reply-To: <20141222174123.1119.28780.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@redhat.com>
Date: Mon, 22 Dec 2014 09:41:24 -0800

> This patch is meant to reduce the complexity of fib_table_lookup by reducing
> the number of variables to the bare minimum while still keeping the same if
> not improved functionality versus the original.
> 
> Most of this change was started off by the desire to rid the function of
> chopped_off and current_prefix_length as they actually added very little to
> the function since they only applied when computing the cindex.  I was able
> to replace them mostly with just a check for the prefix match.  As long as
> the prefix between the key and the node being tested was the same we know
> we can search the tnode fully versus just testing cindex 0.
> 
> The second portion of the change ended up being a massive reordering.
> Originally the calls to check_leaf were up near the start of the loop, and
> the backtracing and descending into lower levels of tnodes was later.  This
> didn't make much sense as the structure of the tree means the leaves are
> always the last thing to be tested.  As such I reordered things so that we
> instead have a loop that will delve into the tree and only exit when we
> have either found a leaf or we have exhausted the tree.  The advantage of
> rearranging things like this is that we can fully inline check_leaf since
> there is now only one reference to it in the function.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>

I really like this change, in particular that you got rid of the
__fls().

That's unfortunately expensive on older sparcs, so when I was
micro-benchmarking the routing cache changes it would show up in
perf.
