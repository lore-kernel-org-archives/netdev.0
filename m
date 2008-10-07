From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 3/3] Convert the UDP hash lock to RCU
Date: Tue, 07 Oct 2008 09:15:00 -0500
Message-ID: <48EB6EE4.8030703@linux-foundation.org>
References: <20081006185026.GA10383@minyard.local>	 <48EA8197.6080502@cosmosbay.com> <1223367480.26330.7.camel@lappy.programming.kicks-ass.net> <48EB2AE3.3080200@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, minyard@acm.org,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, shemminger@vyatta.com,
	paulmck@linux.vnet.ibm.com
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:40757 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752404AbYJGOPh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 10:15:37 -0400
In-Reply-To: <48EB2AE3.3080200@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
>>> Or just add SLAB_DESTROY_BY_RCU to slab creation in proto_register()
>>> for "struct proto udp_prot/udpv6_prot" so that kmem_cache_free() done
>>> in sk_prot_free() can defer freeing to RCU...
>>
>> Be careful!, SLAB_DESTROY_BY_RCU just means the slab page gets
>> RCU-freed, this means that slab object pointers stay pointing to valid
>> memory, but it does _NOT_ mean those slab objects themselves remain
>> valid.
>>
>> The slab allocator is free to re-use those objects at any time -
>> irrespective of the rcu-grace period. Therefore you will have to be able
>> to validate that the object you point to is indeed the object you
>> expect, otherwise strange and wonderful things will happen.
>>
> Thanks for this clarification. I guess we really need a rcu head then :)

No you just need to make sure that the object you located is still active
(f.e. refcount > 0) and that it is really a match (hash pointers may be
updated asynchronously and therefore point to the object that has been reused
for something else).

Generally it is advisable to use SLAB_DESTROY_BY_RCU because it preserves the
cache hot advantages of the objects. Regular RCU freeing will let the object
expire for a tick or so which will result in the cacheline cooling down.


