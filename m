From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 0/20] Batch network namespace cleanup
Date: Mon, 30 Nov 2009 16:55:37 -0800
Message-ID: <m1bpijjywm.fsf@fess.ebiederm.org>
References: <m1ljhodbtw.fsf@fess.ebiederm.org>
	<20091130.163454.192638570.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, hadi@cyberus.ca, dlezcano@fr.ibm.com,
	adobriyan@gmail.com, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:47097 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751793AbZLAAzl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 19:55:41 -0500
In-Reply-To: <20091130.163454.192638570.davem@davemloft.net> (David Miller's message of "Mon\, 30 Nov 2009 16\:34\:54 -0800 \(PST\)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Sun, 29 Nov 2009 17:46:03 -0800
>
>> Recently Jamal and Daniel perform some experiments and found that
>> large numbers of network namespace exiting simultaneously is very
>> inefficient.  24+ minutes in some configurations.  The cpu overhead
>> was negligible but it results in long hold times of net_mutex, and
>> memory being consumed a long time after the last user has gone away.
>> 
>> I looked into it and discovered that by batching network namespace
>> cleanups I can reduce the time for 4k network namespaces exiting from
>> 5-7 minutes in my configuration to 44 seconds.
>> 
>> This patch series is my set of changes to the network namespace core
>> and associated cleanups to allow for network namespace batching.
>
> All applied, and assuming all of the build checks pass I'll
> push this out to net-next-2.6
>
> I should look into that inet_twsk_purge performance issue you mention
> when tearing down a namespace.  It walks the entire hash table and
> takes a lock for every hash chain.
>
> Eric, is it possible for us to at least slightly optimize this by
> doing a peek at whether the head pointer of each chain is NULL and
> bypass the spinlock and everything else in that case?  Or is this
> not legal with sk_nulls?
>
> Something like:
>
> 	if (hlist_nulls_empty(&head->twchain))
> 		continue;
>
> right before the 'restart' label?

I haven't had a chance to wrap my head around that case fully yet.

After playing with a few ideas I think what we want to do algorithmically
is to have a batched flush like we do for the routing table cache.  That
should get the cost down to only about 100ms.  Which is much better when
you have a lot of them but is still a lot of time.

>From my preliminary investigation I believe we don't need to take any
locks to traverse the hash table.  I think we can do the entire hash
table traversal under simple rcu protection, and only take the lock on
the individual time wait entries to delete them.

....

Also for best batching we have ipip, ipgre, ip6_tunnel, sit, vlan,
and bridging that need to be taught to use rtnl_link_ops and let
the generic code delete their devices.  

The changes for the vlan code are simple.  The rest I haven't finished
wrapping my head around the drivers individual requirements for.   Still
the changes should not be sweeping.

Eric
