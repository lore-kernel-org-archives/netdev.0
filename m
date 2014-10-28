From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net] inet: frags: fix a race between inet_evict_bucket
 and inet_frag_kill
Date: Tue, 28 Oct 2014 11:03:15 +0100
Message-ID: <20141028100315.GA14863@breakpoint.cc>
References: <1414455409.4845.1.camel@edumazet-glaptop2.roam.corp.google.com>
 <1414488634-28412-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McLean <chutzpah@gentoo.org>
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:59046 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752758AbaJ1KDR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2014 06:03:17 -0400
Content-Disposition: inline
In-Reply-To: <1414488634-28412-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nikolay Aleksandrov <nikolay@redhat.com> wrote:
> When the evictor is running it adds some chosen frags to a local list to
> be evicted once the chain lock has been released but at the same time
> the *frag_queue can be running for some of the same queues and it
> may call inet_frag_kill which will wait on the chain lock and
> will then delete the queue from the wrong list since it was added in the
> eviction one.

I had to read that twice...

cpu1						cpu2
inet_evict_bucket				inet_frag_kill
  chain_lock()                                    chain_lock() ..
  for_each_frag_queue                               spin
    set fragqueue INET_FRAG_EVICTED flag [A]        .
    hlist_del()                                     spin
    hlist_add (to private list)                     .
                                                    spin
  chain_unlock                                      .
						    chain_lock returns
  for_each_frag_queue_on_private_list		    hlist_del() [B]
     frag_expire(fq) // destroy/free queue

[B] we may delete entry on the evictors private list.

since [A] is only set with chainlock held, other cpus
killing an entry can use INET_FRAG_EVICTED to test if the
entry is about to be removed by the evictor.

> The fix is simple - check if the queue has the evict flag
> set under the chain lock before deleting it, this is safe because the
> evict flag is set only under that lock and having the flag set also means
> that the queue has been detached from the chain list, so no need to delete
> it again.

Right, thanks everyone.
> ---
> A few more eyes to confirm all of this would be much appreciated.

Looks correct,
Reviewed-by: Florian Westphal <fw@strlen.de>
