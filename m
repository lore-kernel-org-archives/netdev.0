From: Oren Laadan <orenl@cs.columbia.edu>
Subject: Re: [RFC][PATCH] ns: Syscalls for better namespace sharing control.
Date: Wed, 03 Mar 2010 15:59:05 -0500
Message-ID: <4B8ECD99.3040107@cs.columbia.edu>
References: <4B4F24AC.70105@trash.net> <m13a0tf17t.fsf@fess.ebiederm.org>	<1266875729.3673.12.camel@bigi> <m1wry46es9.fsf@fess.ebiederm.org>	<1266931623.3973.643.camel@bigi> <m1iq9ocafv.fsf@fess.ebiederm.org>	<1266934817.3973.654.camel@bigi> <m1r5obbu2w.fsf@fess.ebiederm.org>	<1266966581.3973.675.camel@bigi>	<m1pr3t2fvl.fsf_-_@fess.ebiederm.org>	<4B883987.6090408@parallels.com> <m1bpfbwuze.fsf@fess.ebiederm.org>	<4B883E6F.1060907@parallels.com> <m13a0nwu6p.fsf@fess.ebiederm.org>	<4B88D80A.8010701@parallels.com> <m1mxyvrqvk.fsf@fess.ebiederm.org>	<4B88E431.6040609@parallels.com> <m1bpfbqajn.fsf@fess.ebiederm.org>	<4B894564.7080104@parallels.com> <m1iq9io5sc.fsf@fess.ebiederm.org>	<4B89727C.9040602@parallels.com> <m1ljeempk6.fsf@fess.ebiederm.org> <4B8AE8C1.1030305@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Pavel Emelyanov <xemul@parallels.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	containers@lists.linux-foundation.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Ben Greear <greearb@candelatech.com>
To: Daniel Lezcano <daniel.lezcano@free.fr>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4B8AE8C1.1030305@free.fr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Daniel Lezcano wrote:
> Eric W. Biederman wrote:
>> Pavel Emelyanov <xemul@parallels.com> writes:
>>
>>> Eric W. Biederman wrote:
>>>> Pavel Emelyanov <xemul@parallels.com> writes:
>>>>
>>>>> Eric W. Biederman wrote:
>>>>>> Pavel Emelyanov <xemul@parallels.com> writes:
>>>>>>
>>>>>>> Thanks. What's the problem with setns?
>>>>>> joining a preexisting namespace is roughly the same problem as
>>>>>> unsharing a namespace.  We simply haven't figure out how to do it
>>>>>> safely for the pid and the uid namespaces.
>>>>> The pid may change after this for sure. What problems do you know
>>>>> about it? What if we try to allocate the same PID in a new space
>>>>> or return -EBUSY? This will be a good starting point. If we manage
>>>>> to fix it later this will not break the API at all.
>>>> Parentage.  The pid is the identity of a process and all kinds of things
>>>> make assumptions in all kinds of strange places.  I don't see how
>>>> waitpid can work if you change the pid.
>>> Agree. But what if we enter a pid space, which is a subnamespace of a current
>>> one? In that case parent will still see the task by its old pid. We can restrict
>>> first version of entering with this rule as well and this restriction will not
>>> block us in typical usecase (I mean enter a container from a host).
>> When I was thinking about pid namespaces and unshare last time.  The idea I came
>> to was we unshare of the pid namespace should only affect which pid namespace
>> your children are in.
>>
>> I remember that do that there were a few cases where you would have to access
>> task->pid->pid_ns instead of task->nsproxy->pid_ns, but essentially it was pretty
>> simple.
>>
>>>> glibc doesn't cope if you change someones pid.
>>> OK, but what if we try to allocate the same pid returning -EBUSY on failure?
>>>
>>> My aim is to provide even a restricted enter. For most of the cases this
>>> should work and make our lives easier. So two restrictions currently:
>>> a) enter a sub namespace
>>> b) allocate the same pid as we have now
>>>
>>> Hm? :)
>> Replacing struct pid is guaranteed to do all kinds of nasty things with
>> signal handling and the like, de_thread is nasty enough and you are talking
>> something worse.  So if we can change pid namespaces without changing
>> the pid I am for it.
> 
> I agree with all the points you and Pavel you talked about but I don't 
> feel comfortable to have the current process to switch the pid namespace 
> because of the process tree hierarchy (what will be the parent of the 
> process when you enter the pid namespace for example). What is the 
> difference with the sys_bindns or the sys_hijack, proposed a couple of 
> years ago ?
> 
> I did a suggestion some weeks ago about a new syscall 'cloneat' where 
> the child process becomes the child of the targeted process specified in 
> the syscall. Maybe it would be interesting to replace the 'setns' by, or 
> add, a 'cloneat' syscall with the file descriptor passed as parameter. 
> The copy_process function shall not use the nsproxy of the caller but 
> the one provided in the fd argument.
> 
> The newly created process becomes the child of the process where we 
> retrieve the namespace with nsfd and this one have to 'waitpid' it, (the 
> caller of 'cloneat' can not wait it). It's a bit similar with the 
> CLONE_PARENT flag, except the creation order is inverted (the father 
> creates for the child).
> 
> So when entering the container, we specify the pid 1 of the container 
> which is usually a child reaper.
> 
> Does it make sense ?

For what it's worth, I think that this suggestion (cloneat) is the
so far the cleanest to allow a process to enter an existing namespace.

Oren.

