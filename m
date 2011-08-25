From: Glauber Costa <glommer@parallels.com>
Subject: Re: [RFC] per-containers tcp buffer limitation
Date: Thu, 25 Aug 2011 15:05:03 -0300
Message-ID: <4E568ECF.1030302@parallels.com>
References: <4E558137.5020900@parallels.com> <m1k4a2qqew.fsf@fess.ebiederm.org> <4E55A55B.8090608@parallels.com> <20110825104956.41c4b60e.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Containers <containers@lists.osdl.org>,
	<netdev@vger.kernel.org>, David Miller <davem@davemloft.net>,
	Pavel Emelyanov <xemul@parallels.com>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.parallels.com ([64.131.90.16]:59377 "EHLO mx2.parallels.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755044Ab1HYSFg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Aug 2011 14:05:36 -0400
In-Reply-To: <20110825104956.41c4b60e.kamezawa.hiroyu@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/24/2011 10:49 PM, KAMEZAWA Hiroyuki wrote:
> On Wed, 24 Aug 2011 22:28:59 -0300
> Glauber Costa<glommer@parallels.com>  wrote:
>
>> On 08/24/2011 09:35 PM, Eric W. Biederman wrote:
>>> Glauber Costa<glommer@parallels.com>   writes:
>>>
>>>> Hello,
>>>>
>>>> This is a proof of concept of some code I have here to limit tcp send and
>>>> receive buffers per-container (in our case). At this phase, I am more concerned
>>>> in discussing my approach, so please curse my family no further than the 3rd
>>>> generation.
>>>>
>>>> The problem we're trying to attack here, is that buffers can grow and fill
>>>> non-reclaimable kernel memory. When doing containers, we can't afford having a
>>>> malicious container pinning kernel memory at will, therefore exhausting all the
>>>> others.
>>>>
>>>> So here a container will be seen in the host system as a group of tasks, grouped
>>>> in a cgroup. This cgroup will have files allowing us to specify global
>>>> per-cgroup limits on buffers. For that purpose, I created a new sockets cgroup -
>>>> didn't really think any other one of the existing would do here.
>>>>
>>>> As for the network code per-se, I tried to keep the same code that deals with
>>>> memory schedule as a basis and make it per-cgroup.
>>>> You will notice that struct proto now take function pointers to values
>>>> controlling memory pressure and will return per-cgroup data instead of global
>>>> ones. So the current behavior is maintained: after the first threshold is hit,
>>>> we enter memory pressure. After that, allocations are suppressed.
>>>>
>>>> Only tcp code was really touched here. udp had the pointers filled, but we're
>>>> not really controlling anything. But the fact that this lives in generic code,
>>>> makes it easier to do the same for other protocols in the future.
>>>>
>>>> For this patch specifically, I am not touching - just provisioning -
>>>> rmem and wmem specific knobs. I should also #ifdef a lot of this, but hey,
>>>> remember: rfc...
>>>>
>>>> One drawback of this approach I found, is that cgroups does not really work well
>>>> with modules. A lot of the network code is modularized, so this would have to be
>>>> fixed somehow.
>>>>
>>>> Let me know what you think.
>>>
>>> Can you implement this by making the existing network sysctls per
>>> network namespace?
>>>
>>> At a quick skim it looks to me like you can make the existing sysctls
>>> per network namespace and solve the issues you are aiming at solving and
>>> that should make the code much simpler, than your proof of concept code.
>>>
>>> Any implementation of this needs to answer the question how much
>>> overhead does this extra accounting add.  I don't have a clue how much
>>> overhead you are adding but you are making structures larger and I
>>> suspect adding at least another cache line miss, so I suspect your
>>> changes will impact real world socket performance.
>>
>> Hi Eric,
>>
>> Thanks for your attention.
>>
>> So, this that you propose was my first implementation. I ended up
>> throwing it away after playing with it for a while.
>>
>> One of the first problems that arise from that, is that the sysctls are
>> a tunable visible from inside the container. Those limits, however, are
>> to be set from the outside world. The code is not much better than that
>> either, and instead of creating new cgroup structures and linking them
>> to the protocol, we end up doing it for net ns. We end up increasing
>> structures just the same...
>>
>> Also, since we're doing resource control, it seems more natural to use
>> cgroups. Now, the fact that there are no correlation whatsoever between
>> cgroups and namespaces does bother me. But that's another story, much
>> more broader and general than this patch.
>>
>
> I think using cgroup makes sense. A question in mind is whehter it is
> better to integrate this kind of 'memory usage' controls to memcg or not.
>
> How do you think ? IMHO, having cgroup per class of object is messy.
> ...
> How about adding
> 	memory.tcp_mem
> to memcg ?
>
> Or, adding kmem cgroup ?

I don't really care which cgroup do we use. I choosed a new socket one,
because they are usually not like other objects. People love tweaking 
network aspects, and it is not hard to imagine people wanting to extend it.

Now, if all of this will ever belong to cgroup, is of course a different 
matter.

Between your two suggestions, I like kmem better. It makes it then 
absolutely clear that we will handle kernel objects only...

>> About overhead, since this is the first RFC, I did not care about
>> measuring. However, it seems trivial to me to guarantee that at least
>> that it won't impose a significant performance penalty when it is
>> compiled out. If we're moving forward with this implementation, I will
>> include data in the next release so we can discuss in this basis.
>>
>
> IMHO, you should show performance number even if RFC. Then, people will
> see patch with more interests.

Let's call this one pre-RFC then.
