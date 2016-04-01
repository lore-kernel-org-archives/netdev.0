From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net 4/4] tcp: various missing rcu_read_lock around
 __sk_dst_get
Date: Fri, 1 Apr 2016 06:33:19 +0200
Message-ID: <56FDFA0F.5070104@stressinduktion.org>
References: <1459466982-20432-5-git-send-email-hannes@stressinduktion.org>
 <1459467595.6473.233.camel@edumazet-glaptop3.roam.corp.google.com>
 <56FDBA6E.5030508@stressinduktion.org>
 <1459469572.6473.239.camel@edumazet-glaptop3.roam.corp.google.com>
 <56FDBF0E.8020309@stressinduktion.org>
 <1459473592.6473.243.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160401014516.GA11017@ast-mbp.thefacebook.com>
 <1459479818.6473.265.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160401040442.GA14661@ast-mbp.thefacebook.com>
 <56FDF541.6070106@stressinduktion.org>
 <20160401042655.GA16500@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, sasha.levin@oracle.com,
	daniel@iogearbox.net, mkubecek@suse.cz
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:54054 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750741AbcDAEdZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 00:33:25 -0400
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id BCA37209B7
	for <netdev@vger.kernel.org>; Fri,  1 Apr 2016 00:33:22 -0400 (EDT)
In-Reply-To: <20160401042655.GA16500@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01.04.2016 06:26, Alexei Starovoitov wrote:
> On Fri, Apr 01, 2016 at 06:12:49AM +0200, Hannes Frederic Sowa wrote:
>> On 01.04.2016 06:04, Alexei Starovoitov wrote:
>>> On Thu, Mar 31, 2016 at 08:03:38PM -0700, Eric Dumazet wrote:
>>>> On Thu, 2016-03-31 at 18:45 -0700, Alexei Starovoitov wrote:
>>>>
>>>>> Eric, what's your take on Hannes's patch 2 ?
>>>>> Is it more accurate to ask lockdep to check for actual lock
>>>>> or lockdep can rely on owned flag?
>>>>> Potentially there could be races between setting the flag and
>>>>> actual lock... but that code is contained, so unlikely.
>>>>> Will we find the real issues with this 'stronger' check or
>>>>> just spend a ton of time adapting to new model like your other
>>>>> patch for release_sock and whatever may need to come next...
>>>>
>>>> More precise lockdep checks are certainly good, I only objected to 4/4
>>>> trying to work around another bug.
>>>>
>>>> But why do we rush for 'net' tree ?
>>>>
>>>> This looks net-next material to me.
>>>>
>>>> Locking changes are often subtle, lets take the time to do them
>>>> properly.
>>>
>>> completely agree. I think only first patch belongs in net.
>>> Everything else is net-next material.
>>
>> Problem with first patch is that it uses lock_sock_fast, thus the current
>> sock_owned_by_user check doesn't get rid the lockdep warning. :/
>>
>> Thus we would need to go with the two first patches. Do you think it is
>> acceptable? I actually didn't see a problem and testing showed no problems
>> so far.
>
> I see. right. the patch 1 only makes sense when coupled with 2.
> but now I'm not so sure that lockdep_is_held(&sk->sk_lock.slock)
> is a valid check, since current sock_owned_by_user() is equivalent
> to lockdep_is_held(&sk->sk_lock) only.
> I would go with Daniel's approach. Much simpler to reason about.

IMHO we should treat sk_lock and sk_lock.slock the same as they are 
encapsulated by socket lock api.

I was rather afraid that we call those changed functions from within 
release_sock and thus would have the same problem again, where we get 
splats because of the time where we actually have user ownership but not 
the mark in the lockdep data structures. But this seems not to be the 
case as the functions are only directly called on behalf of user space.

Daniel, what do you think? I would be fine with your patch for net and 
we clean this up a bit in net-next then.

Bye,
Hannes
