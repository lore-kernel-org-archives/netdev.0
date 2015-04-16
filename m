From: Denys Vlasenko <dvlasenk@redhat.com>
Subject: Re: [PATCH] netns: deinline net_generic()
Date: Thu, 16 Apr 2015 13:14:14 +0200
Message-ID: <552F9986.30207@redhat.com>
References: <1429014311-19868-1-git-send-email-dvlasenk@redhat.com> <20150414.143747.1155055158701231768.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, jengelh@medozas.de, jpirko@redhat.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150414.143747.1155055158701231768.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David, Eric,

As you may have surmised, this patch wasn't a result of me looking
at networking code; rather, it is a result of semi-automated search
for huge inlines.

The last step of this process would be the submission of patches.
I am expecting a range of responses from maintainers: enthusiastic,
"no reply", "go away, I don't care about code size",
and everything in between.

I can't invest a large amount of effort trying to push
every deinlining patch through. If someone, for example, would
flat out refuse to fix a huge inline in his driver, so be it.

I will be happy to run at least a few iterations over a patch
if maintainers do see a merit in deinlining, but have some
reservations wrt performance.

Your response falls into the latter case (you aren't refusing the patch
outright, but want it to be changed in some way).

It would help if you tell me how I should change the patches.

(I also hope to have a semi-generic way of addressing
performance concerns for future deinlining
patch submissions.)


On 04/14/2015 08:37 PM, David Miller wrote:
> From: Denys Vlasenko <dvlasenk@redhat.com>
> Date: Tue, 14 Apr 2015 14:25:11 +0200
> 
>> On x86 allyesconfig build:
>> The function compiles to 130 bytes of machine code.
>> It has 493 callsites.
>> Total reduction of vmlinux size: 27906 bytes.
>>
>>    text      data      bss       dec     hex filename
>> 82447071 22255384 20627456 125329911 77861f7 vmlinux4
>> 82419165 22255384 20627456 125302005 777f4f5 vmlinux5
>>
>> Signed-off-by: Denys Vlasenko <dvlasenk@redhat.com>
> 
> That BUG_ON() was added 7 years ago, and I don't remember it ever
> triggering or helping us diagnose something, so just remove it and
> keep the function inlined.

There are two BUG_ONs. I'll remove both of them in v2.
Let me know if you want something else.

However, without BUG_ONs, function is still a bit big
on PREEMPT configs.

Among almost 500 users, many probably aren't hot paths.

How about having an inlined version, say, "fast_net_generic()",
and a deinlined one, and using one or another as appropriate.
Is this ok with you?


On 04/14/2015 03:19 PM, Eric Dumazet wrote:
> On Tue, 2015-04-14 at 14:25 +0200, Denys Vlasenko wrote:
>> On x86 allyesconfig build:
>> The function compiles to 130 bytes of machine code.
>> It has 493 callsites.
>> Total reduction of vmlinux size: 27906 bytes.
>>
>>    text	     data      bss       dec     hex filename
>> 82447071 22255384 20627456 125329911 77861f7 vmlinux4
>> 82419165 22255384 20627456 125302005 777f4f5 vmlinux5
>
> This sounds a big hammer to me.
>
> These savings probably comes from the BUG_ON() that could simply be
> removed.
> The second one for sure has no purpose. First one looks defensive.
>
> For a typical (non allyesconfig) kernel, net_generic() would translate
> to :
>
> return net->gen[id - 1]
>
> Tunnels need this in fast path, so I presume we could introduce
> net_generic_rcu() to keep this stuff inlined where it matters.
>
> static inline void *net_generic_rcu(const struct net *net, int id)
> {
> 	struct net_generic *ng = rcu_dereference(net->gen);
>
> 	return ng->ptr[id - 1];
> }

I looked at the code and I'm not feeling confident enough
to find places where replacing net_generic() with
net_generic_rcu() is okay.

Would it be okay if I add net_generic_rcu() as you suggest,
but leave it to you (network people) to switch to it where
appropriate?

-- 
vda
