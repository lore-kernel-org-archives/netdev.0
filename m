From: arno@natisbad.org (Arnaud Ebalard)
Subject: Re: [PATCHv3 net-next-2.6 3/5] XFRM,IPv6: Add IRO src/dst address remapping XFRM types and i/o handlers
Date: Sun, 03 Oct 2010 23:25:44 +0200
Message-ID: <87lj6fvuhz.fsf@small.ssi.corp>
References: <cover.1285749610.git.arno@natisbad.org>
	<fd4eec3c9486c46b535e89ceed479c7536f51fb9.1285749610.git.arno@natisbad.org>
	<20100929.201618.241458205.davem@davemloft.net>
	<87iq1k99vk.fsf@small.ssi.corp>
	<20101002103205.GA3879@gondor.apana.org.au>
	<87iq1j5r7z.fsf@small.ssi.corp>
	<20101003151202.GA11963@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from copper.chdir.org ([88.191.97.87]:36941 "EHLO copper.chdir.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755106Ab0JCVZs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Oct 2010 17:25:48 -0400
In-Reply-To: <20101003151202.GA11963@gondor.apana.org.au> (Herbert Xu's
	message of "Sun, 3 Oct 2010 23:12:02 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Herbert Xu <herbert@gondor.apana.org.au> writes:

> On Sun, Oct 03, 2010 at 03:41:04PM +0200, Arnaud Ebalard wrote:
>>
>> After your reply, I took a (too long) look at the history of
>> xfrm6_input_addr() to understand why it is as it is. If it can spare you
>> some time, here is what I think happened:
>
> ...
>
>>  - Then, as you wrote, the state lock was moved in all input handlers
>>    (commit 0ebea8ef, Nov 13 2007), including RH2/HAO ones:
>
> ...
>
>>    With that commit, I think a deadlock was introduced in MIPv6 code
>>    because xfm6_input_addr() was left unchanged, i.e. x->type->input()
>>    was called with the lock held. Am I correct?
>> 
>>  - The code of xfrm6_input_addr() was then optimized by commit a002c6fd
>>    in such a way that x->type->input() was then put outside the
>>    protection of the lock, which (if I am not mistaken) removed the
>>    deadlock: 
>
> ...
>
>>    I don't know if this is was intentional.
>
> Indeed MIPv6 was completely out of action for three months and
> nobody noticed :)

hehe ;-) Just to correct a missing waypoint in my history, which is in
fact the real fix for the deadlock:

   commit 9473e1f631de339c50bde1e3bd09e1045fe90fd5
   Author: Masahide NAKAMURA <nakam@linux-ipv6.org>
   Date:   Thu Dec 20 20:41:57 2007 -0800
   
       [XFRM] MIPv6: Fix to input RO state correctly.
       
       Disable spin_lock during xfrm_type.input() function.
       Follow design as IPsec inbound does.
    
       Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
       Signed-off-by: David S. Miller <davem@davemloft.net>

>>    But the main question remains on the position of the lock. Here,
>>    checks are done on the status of the state, lock is released,
>>    reacquired in the input handler to do additional check and then
>>    released again, to be reacquired later in the function to act on
>>    statistics. Is my reading of the code correct?
>
> When I moved the lock down I chose the safest option and added
> it to every single input function.  So it may well be the case
> that the lock isn't needed at all on the MIPv6 path.

I don't have any technical argument to support the removal of the locks,
i.e. don't see what would prevent changes during the check. I will try
and spend more time on it, but meanwhile I think it's safe to keep
things the way they are.

Thanks for your time, Herbert.

Cheers,

a+
