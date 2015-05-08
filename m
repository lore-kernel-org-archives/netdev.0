From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC PATCH net-next 00/11] netns: don't switch namespace while creating kernel sockets
Date: Fri, 08 May 2015 06:15:36 -0500
Message-ID: <87ioc39v6v.fsf@x220.int.ebiederm.org>
References: <1430988770-28907-1-git-send-email-ying.xue@windriver.com>
	<87wq0kcqlm.fsf@x220.int.ebiederm.org>
	<CAHA+R7NuxGDnCSfVXJ4tcqYNZGu6RetYLvtrMo4SSqRFHKCFPg@mail.gmail.com>
	<871tisckgr.fsf@x220.int.ebiederm.org>
	<CAHA+R7POE-X0Tbn6XEGSta=tDZQ_+EDg0ruSxy3qMFNm9Rd0oQ@mail.gmail.com>
	<87twvob4fe.fsf@x220.int.ebiederm.org>
	<CAHA+R7N9BuJGnA1r_K886pr45EP6ry85T2pbr2u8neJs-ROrYw@mail.gmail.com>
	<87lhh0b1j1.fsf@x220.int.ebiederm.org>
	<554C7D91.3050906@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Cong Wang <cwang@twopensource.com>,
	netdev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Pavel Emelyanov <xemul@openvz.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>, <maxk@qti.qualcomm.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Thomas Graf <tgraf@suug.ch>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Tom Herbert <tom@herbertland.com>,
	James Chapman <jchapman@katalix.com>,
	Erik Hugne <erik.hugne@ericsson.com>, <jon.maloy@ericsson.com>,
	Simon Horman <horms@verge.net.au>
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:59677 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752065AbbEHLUM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2015 07:20:12 -0400
In-Reply-To: <554C7D91.3050906@windriver.com> (Ying Xue's message of "Fri, 8
	May 2015 17:10:41 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ying Xue <ying.xue@windriver.com> writes:

> On 05/08/2015 04:01 AM, Eric W. Biederman wrote:
>> Cong Wang <cwang@twopensource.com> writes:
>> 
>>> On Thu, May 7, 2015 at 11:58 AM, Eric W. Biederman
>>> <ebiederm@xmission.com> wrote:
>>>> Cong Wang <cwang@twopensource.com> writes:
>>>>
>>>>> On Thu, May 7, 2015 at 11:26 AM, Eric W. Biederman
>>>>> <ebiederm@xmission.com> wrote:
>>>>>> Cong Wang <cwang@twopensource.com> writes:
>>>>>>
>>>>>>>
>>>>>>> Why does this have to be so complicated? We can simply avoid
>>>>>>> calling ops_init() by skipping those in cleanup_list, no?
>>>>>>
>>>>>> The problem is that there is a single list of methods to call and if you
>>>>>> simply skip calling the initialization methods for a struct net and add
>>>>>> yourself to the list cleanup_net will then call the cleanup methods
>>>>>> without calling the cleanup methods.
>>>>>
>>>>> If you mean pernet_list, ops->list has been already added before
>>>>> for_each_net().
>>>>>
>>>>>>
>>>>>> Simply limiting new network namespace registrations to a point when
>>>>>> network namespaces are not being registered or unregisted seems like
>>>>>> the simplest way to achieve this effect.
>>>>>>
>>>>>
>>>>> Literally, any point before ops_init().
>>>>
>>>> Think about what that what it means to add a set of operations to the
>>>> pernet_list and then to skip a network namespace with a count of 0 and
>>>> then to have that network namespace exit with those methods on
>>>> pernet_list.
>>>>
>>>
>>> That is easy to solve, isn't it?
>> 
>> Nope.  That doesn't work.
>> 
>
> Cong, although I don't know why Eric confirmed your solution did not work, in my
> view it really exists a bit fault especially in locking policy. For instance,
> net->cleanup_list may be linked to cleanup_list list and probably it's inserted
> in net_kill_list too, and the both global lists are protected by two different
> locks respectively. But when we check list_empty(&net->cleanup_list), any lock
> is not held.
>
> However, except for the point, overall, I think your idea is workable.
>
> So, Eric, can you please further explain why Cong's proposal doesn't
> work?

Because changing where the list assignment happens under the net_mutex
does not affect anything, and I already explained why it did not work
once.

In particular it is possible to call the cleanup methods on a network
namespace where the initialization methods where not called.

If we want to avoid the complexity required to wait for no network
namespaces to be exiting that was implicit in my version of
lock_network_namespace() we need to allocate some per network namespace
per network operations state.  To remember if the per network namespace
operations have been initialized on a network namespace.  Essentially
creating a per network namespace copy of the pernet_list.

My end game would be to work towards reducing the scope of the net_mutex
so potentially we could have two network namespaces exiting at the same
time.

Eric
