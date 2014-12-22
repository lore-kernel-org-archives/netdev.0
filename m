From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 02/17] fib_trie: Make leaf and tnode more uniform
Date: Mon, 22 Dec 2014 16:50:15 -0500 (EST)
Message-ID: <20141222.165015.1694288362513627826.davem@davemloft.net>
References: <20141222174105.1119.71598.stgit@ahduyck-vm-fedora20>
	<20141222.133353.2244861758408916536.davem@davemloft.net>
	<54986915.6050906@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: alexander.h.duyck@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43856 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754900AbaLVVuR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2014 16:50:17 -0500
In-Reply-To: <54986915.6050906@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@redhat.com>
Date: Mon, 22 Dec 2014 10:55:17 -0800

> The thing is I don't think we would actually be saving any space. The
> slub allocator will round us up anyway.  On a 32b system the size is
> 28B if I recall correctly.  Dropping it to 24B would mean only a 2
> child node could be allocated from the 32B slab.  Anything larger than
> that it wouldn't matter.

Indeed, you even mention this in the commit messages of your
series.

> My real concern with all of this is the fact that we have to do 2
> separate memory reads per node, one for the key info and one for the
> child pointer.  I really think we need to get this down to 1 in order
> to get there, but the overhead is the tricky part for that. What I
> would look at doing is splitting the tnode into two parts. One would
> be a key vector (key, pos, bits, seq) paired with a pointer to either
> a tnode_info or leaf_info, the other would be something like a
> tnode_info (rcu, parent pointer, full_children, empty_children, key
> vector array[0]) that provides a means of backtracing and stores the
> nodes.  The problem is it makes insertion/deletion and backtracking
> more complicated and doubles (64b) or quadruples (32b) the memory
> needed as such I am still just throwing the idea around and haven't
> gotten into implementation yet.

I think calling into this code twice for every non-local FIB lookup
has costs as well.

And yes I agree with you that the memory references matter a lot.
