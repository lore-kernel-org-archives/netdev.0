From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: [PATCH] af_unix: Use kfree for addresses in unix_bind
Date: Thu, 14 Jan 2016 19:05:18 +0000
Message-ID: <87lh7svv69.fsf@doppelsaurus.mobileactivedefense.com>
References: <87y4bsw2q5.fsf@doppelsaurus.mobileactivedefense.com>
	<1452794435.1223.104.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tiger.mobileactivedefense.com ([217.174.251.109]:52756 "EHLO
	tiger.mobileactivedefense.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1161029AbcANTFa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jan 2016 14:05:30 -0500
In-Reply-To: <1452794435.1223.104.camel@edumazet-glaptop2.roam.corp.google.com>
	(Eric Dumazet's message of "Thu, 14 Jan 2016 10:00:35 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:
> On Thu, 2016-01-14 at 16:22 +0000, Rainer Weikusat wrote:
>> Use kfree instead of unix_release_addr when freeing newly-allocated
>> unix_address structures after binding the socket failed. The second
>> function does an atomic_dec_and_test in order to free the address once
>> its reference count falls to zero which isn't necessary for the
>> unix_bind error path as the new structure wasn't published yet. 'Using
>> kfree' is also how unix_autobind handles this case.
>> 
>> Signed-off-by: Rainer Weikusat <rweikusat@mobileactivedefense.com>
>> ---
>
> This looks net-next material ?

The patch was against net-next. But it's not exactly a new feature.

> net-next tree is closed during merge window.

Sorry, I didn't know that.

> Not sure what you gain by optimizing error paths ...

What does the error path gain by being differently implemented in
two functionally closely related functions (unix_bind and unix_autobind)?
I already lost the (small amount of) time it took to determine that
there's no reason why unix_release_addr should be called in one case but
not in the other. But this may well help someone else avoid the effort
in future.

With a little more perspective: Something I'd like to do is to shrink
the u->readlock protected critical sections in _bind and _autobind
somewhat. At least the memory allocations certainly don't need to be
protected by the lock. This would mean moving the allocation code and
consequently, the freeing code, too. And changing the code of one
function but keeping the unix_release_lock, perhaps with a comment a la

/* This is useless. But it always grew here. */

while doing the same with the kfree in the other just felt too bizarre.

NB: That's "my" answer: It adds entropy to the code for no gain. One
could also argue that the error path shouldn't execute atomic
instructions for no purpose.
