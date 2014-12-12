From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net PATCH] fib_trie: Fix trie balancing issue if new node pushes
 down existing node
Date: Fri, 12 Dec 2014 07:55:02 -0800
Message-ID: <548B0FD6.8040105@gmail.com>
References: <20141211054815.1357.36977.stgit@ahduyck-vm-fedora20> <20141211.213216.1630491264342423219.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, alexander.h.duyck@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:60882 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967761AbaLLPzE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2014 10:55:04 -0500
Received: by mail-pd0-f176.google.com with SMTP id r10so5386117pdi.7
        for <netdev@vger.kernel.org>; Fri, 12 Dec 2014 07:55:04 -0800 (PST)
In-Reply-To: <20141211.213216.1630491264342423219.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/11/2014 06:32 PM, David Miller wrote:
> From: Alexander Duyck <alexander.h.duyck@redhat.com>
> Date: Wed, 10 Dec 2014 21:49:22 -0800
>
>> This patch addresses an issue with the level compression of the fib_trie.
>> Specifically in the case of adding a new leaf that triggers a new node to
>> be added that takes the place of the old node.  The result is a trie where
>> the 1 child tnode is on one side and one leaf is on the other which gives
>> you a very deep trie.  Below is the script I used to generate a trie on
>> dummy0 with a 10.X.X.X family of addresses.
>  ...
>> What this fix does is start the rebalance at the newly created tnode
>> instead of at the parent tnode.  This way if there is a gap between the
>> parent and the new node it doesn't prevent the new tnode from being
>> coalesced with any pre-existing nodes that may have been pushed into one
>> of the new nodes child branches.
>>
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
> One has to be mindful with this code that what it's doing now might
> be intentional.  For example, it might be doing things this way
> on purpose in order to minimize rebalancing during route flaps.
>
> Barring anything like that, I think your change is fine.

I'm fairly certain that this isn't intentional.  If we replace a NULL
pointer in an existing tnode then we rebalance starting at that tnode,
it is only when there is no room in the trie and we have to add a new
tnode that the issue occurs where we rebalance at the parent and not the
tnode that the leaf was added to.

- Alex
