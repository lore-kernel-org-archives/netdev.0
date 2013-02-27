From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: Re: [PATCH v6 04/46] percpu_rwlock: Implement the core design of
 Per-CPU Reader-Writer Locks
Date: Thu, 28 Feb 2013 02:49:53 +0530
Message-ID: <512E7879.20109@linux.vnet.ibm.com>
References: <20130218123714.26245.61816.stgit@srivatsabhat.in.ibm.com> <20130218123856.26245.46705.stgit@srivatsabhat.in.ibm.com> <CANN689F9S7c1M8+cEpz3tsxGF34+NTRBLvxgPUOtbvav5u+RRA@mail.gmail.com> <5122551E.1080703@linux.vnet.ibm.com>	<51226B46.9080707@linux.vnet.ibm.com> <CANN689FSxOz+0Cu7EG_yKD8ZE1OpT4kyT+ybLfXSqaifodJRpw@mail.gmail.com> <51226F91.7000108@linux.vnet.ibm.com> <CACvQF53bdh4_BxF0y1fnTVR+T2OmRc0jmWQYftsvx92-fg-Lug@mail.gmail.com> <512BBAD8.8010006@linux.vnet.ibm.com> <CACvQF51jCxk5jUqmhD=QBBtUsBkQWZzakacrKO4Gsk=w61rNwQ@mail.gmail.com> <512C7A38.8060906@linux.vnet.ibm.com> <CACvQF51RvhM8XNqu3-1OTQ=cZUZ=pAX+_zx0a29+W67N1X+BgQ@mail.gmail.com> <512CC509.1050000@linux.vnet.ibm.com> <CACvQF50UgiqPpDk3HCmV86zKSf6tPjqr0bZowfPEOJs0g0r0MQ@mail.gmail.com> <512D0D67.9010609@linux.vnet
 .ibm.com> <CACvQF53ph2ixdM-otzetjM5cR+2kcZj6sckOp3TnzzA_x-EZ8w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Michel Lespinasse <walken@google.com>, linux-doc@vger.kernel.org,
	peterz@infradead.org, fweisbec@gmail.com,
	linux-kernel@vger.kernel.org, namhyung@kernel.org,
	mingo@kernel.org, linux-arch@vger.kernel.org,
	linux@arm.linux.org.uk, xiaoguangrong@linux.vnet.ibm.com,
	wangyun@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com,
	nikunj@linux.vnet.ibm.com, linux-pm@vger.kernel.org,
	rusty@rustcorp.com.au, rostedt@goodmis.org, rjw@sisk.pl,
	vincent.guittot@linaro.org, tglx@linutronix.de,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	oleg@redhat.com, sbw@mit.edu, tj@kernel.org,
	akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org
To: Lai Jiangshan <eag0628@gmail.com>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <CACvQF53ph2ixdM-otzetjM5cR+2kcZj6sckOp3TnzzA_x-EZ8w@mail.gmail.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/27/2013 06:03 AM, Lai Jiangshan wrote:
> On Wed, Feb 27, 2013 at 3:30 AM, Srivatsa S. Bhat
> <srivatsa.bhat@linux.vnet.ibm.com> wrote:
>> On 02/26/2013 09:55 PM, Lai Jiangshan wrote:
>>> On Tue, Feb 26, 2013 at 10:22 PM, Srivatsa S. Bhat
>>> <srivatsa.bhat@linux.vnet.ibm.com> wrote:
>>>>
>>>> Hi Lai,
>>>>
>>>> I'm really not convinced that piggy-backing on lglocks would help
>>>> us in any way. But still, let me try to address some of the points
>>>> you raised...
>>>>
>>>> On 02/26/2013 06:29 PM, Lai Jiangshan wrote:
>>>>> On Tue, Feb 26, 2013 at 5:02 PM, Srivatsa S. Bhat
>>>>> <srivatsa.bhat@linux.vnet.ibm.com> wrote:
>>>>>> On 02/26/2013 05:47 AM, Lai Jiangshan wrote:
>>>>>>> On Tue, Feb 26, 2013 at 3:26 AM, Srivatsa S. Bhat
>>>>>>> <srivatsa.bhat@linux.vnet.ibm.com> wrote:
>>>>>>>> Hi Lai,
>>>>>>>>
>>>>>>>> On 02/25/2013 09:23 PM, Lai Jiangshan wrote:
>>>>>>>>> Hi, Srivatsa,
>>>>>>>>>
>>>>>>>>> The target of the whole patchset is nice for me.
>>>>>>>>
>>>>>>>> Cool! Thanks :-)
>>>>>>>>
>>>>>> [...]
>>>>>>
>>>>>> Unfortunately, I see quite a few issues with the code above. IIUC, the
>>>>>> writer and the reader both increment the same counters. So how will the
>>>>>> unlock() code in the reader path know when to unlock which of the locks?
>>>>>
>>>>> The same as your code, the reader(which nested in write C.S.) just dec
>>>>> the counters.
>>>>
>>>> And that works fine in my case because the writer and the reader update
>>>> _two_ _different_ counters.
>>>
>>> I can't find any magic in your code, they are the same counter.
>>>
>>>         /*
>>>          * It is desirable to allow the writer to acquire the percpu-rwlock
>>>          * for read (if necessary), without deadlocking or getting complaints
>>>          * from lockdep. To achieve that, just increment the reader_refcnt of
>>>          * this CPU - that way, any attempt by the writer to acquire the
>>>          * percpu-rwlock for read, will get treated as a case of nested percpu
>>>          * reader, which is safe, from a locking perspective.
>>>          */
>>>         this_cpu_inc(pcpu_rwlock->rw_state->reader_refcnt);
>>>
>>
>> Whoa! Hold on, were you really referring to _this_ increment when you said
>> that, in your patch you would increment the refcnt at the writer? Then I guess
>> there is a major disconnect in our conversations. (I had assumed that you were
>> referring to the update of writer_signal, and were just trying to have a single
>> refcnt instead of reader_refcnt and writer_signal).
> 
> https://github.com/laijs/linux/commit/53e5053d5b724bea7c538b11743d0f420d98f38d
> 
> Sorry the name "fallback_reader_refcnt" misled you.
> 
[...]

>>> All I was considered is "nested reader is seldom", so I always
>>> fallback to rwlock when nested.
>>> If you like, I can add 6 lines of code, the overhead is
>>> 1 spin_try_lock()(fast path)  + N  __this_cpu_inc()
>>>
>>
>> I'm assuming that calculation is no longer valid, considering that
>> we just discussed how the per-cpu refcnt that you were using is quite
>> unnecessary and can be removed.
>>
>> IIUC, the overhead with your code, as per above discussion would be:
>> 1 spin_try_lock() [non-nested] + N read_lock(global_rwlock).
> 
> https://github.com/laijs/linux/commit/46334544bb7961550b7065e015da76f6dab21f16
> 
> Again, I'm so sorry the name "fallback_reader_refcnt" misled you.
> 

At this juncture I really have to admit that I don't understand your
intentions at all. What are you really trying to prove? Without giving
a single good reason why my code is inferior, why are you even bringing
up the discussion about a complete rewrite of the synchronization code?
http://article.gmane.org/gmane.linux.kernel.cross-arch/17103
http://article.gmane.org/gmane.linux.power-management.general/31345

I'm beginning to add 2 + 2 together based on the kinds of questions you
have been asking...

You posted a patch in this thread and started a discussion around it without
even establishing a strong reason to do so. Now you point me to your git
tree where your patches have even more traces of ideas being borrowed from
my patchset (apart from my own ideas/code, there are traces of others' ideas
being borrowed too - for example, it was Oleg who originally proposed the
idea of splitting up the counter into 2 parts and I'm seeing that it is
slowly crawling into your code with no sign of appropriate credits).
http://article.gmane.org/gmane.linux.network/260288

And in reply to my mail pointing out the performance implications of the
global read_lock at the reader side in your code, you said you'll come up
with a comparison between that and my patchset.
http://article.gmane.org/gmane.linux.network/260288
The issue has been well-documented in my patch description of patch 4.
http://article.gmane.org/gmane.linux.kernel/1443258

Are you really trying to pit bits and pieces of my own ideas/versions
against one another and claiming them as your own?

You projected the work involved in handling the locking issues pertaining
to CPU_DYING notifiers etc as a TODO, despite the fact that I had explicitly
noted in my cover letter that I had audited and taken care of all of them.
http://article.gmane.org/gmane.linux.documentation/9727
http://article.gmane.org/gmane.linux.documentation/9520

You failed to acknowledge (on purpose?) that I had done a tree-wide
conversion despite the fact that you were replying to the very thread which
had the 46 patches which did exactly that (and I had also mentioned it
explicitly in my cover letter).
http://article.gmane.org/gmane.linux.documentation/9727
http://article.gmane.org/gmane.linux.documentation/9520

You then started probing more and more about the technique I used to do
the tree-wide conversion.
http://article.gmane.org/gmane.linux.kernel.cross-arch/17111

You also retorted saying you did go through my patch descriptions, so
its not like you have missed reading them.
http://article.gmane.org/gmane.linux.power-management.general/31345

Each of these when considered individually, might appear like innocuous and
honest attempts at evaluating my code. But when put together, I'm beginning
to sense a whole different angle to it altogether, as if you are trying
to spin your own patch series, complete with the locking framework _and_
the tree-wide conversion, heavily borrowed from mine. At the beginning of
this discussion, I predicted that the lglock version that you are proposing
would end up being either less efficient than my version or look very similar
to my version. http://article.gmane.org/gmane.linux.kernel/1447139

I thought it was just the former till now, but its not hard to see how it
is getting closer to becoming the latter too. So yeah, I'm not amused.

Maybe (and hopefully) you are just trying out different ideas on your own,
and I'm just being paranoid. I really hope that is the case. If you are just
trying to review my code, then please stop sending patches with borrowed ideas
with your sole Signed-off-by, and purposefully ignoring the work already done
in my patchset, because it is really starting to look suspicious, at least
to me.

Don't get me wrong - I'll whole-heartedly acknowledge and appreciate if
_your_ code is better than mine. I just don't like the idea of somebody
plagiarizing my ideas/code (or even others' ideas for that matter).
However, I sincerely apologize in advance if I misunderstood/misjudged your
intentions; I just wanted to voice my concerns out loud at this point,
considering the bad feeling I got by looking at your responses collectively.

Regards,
Srivatsa S. Bhat
