From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: [RFC][PATCH] ns: Syscalls for better namespace sharing control.
Date: Sat, 06 Mar 2010 15:47:55 +0100
Message-ID: <4B926B1B.5070207@free.fr>
References: <4B88E431.6040609@parallels.com>	<m1bpfbqajn.fsf@fess.ebiederm.org> <4B894564.7080104@parallels.com>	<m1iq9io5sc.fsf@fess.ebiederm.org> <4B89727C.9040602@parallels.com>	<m1ljeempk6.fsf@fess.ebiederm.org> <4B8AE8C1.1030305@free.fr>	<4B8D28CF.8060304@parallels.com> <20100302211942.GA17816@us.ibm.com>	<m1y6iaqsmm.fsf@fess.ebiederm.org> <20100303000743.GA13744@us.ibm.com>	<m1ocj6qljj.fsf@fess.ebiederm.org> <4B8E9370.3050300@parallels.com>	<m17hptjh3m.fsf@fess.ebiederm.org> <4B9158F5.5040205@parallels.com> <m1vdda1pmx.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pavel Emelyanov <xemul@parallels.com>,
	Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>,
	Serge Hallyn <serue@us.ibm.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	containers@lists.linux-foundation.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Ben Greear <greearb@candelatech.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.17.164]:35566 "EHLO
	mtagate4.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753485Ab0CFOsC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Mar 2010 09:48:02 -0500
In-Reply-To: <m1vdda1pmx.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric W. Biederman wrote:
> Pavel Emelyanov <xemul@parallels.com> writes:
>
>   
>>> 2 parallel enters?  I meant you have pid 0 in the entered pid namespace.
>>> You have pid 0 because your pid simply does not map.
>>>       
>> Oh, I see.
>>
>>     
>>> There is nothing that makes to parallel enters impossible in that.
>>> Even today we have one thread per cpu that has task->pid == &init_struct_pid
>>> which is pid 0.
>>>       
>> How about the forked processes then? Who will be their parent?
>>     
>
> The normal rules of parentage apply.   So the child will see simply
> see it's parent as ppid == 0.  If that child daemonizes it will become
> a child of the pid namespaces init.
>
> This is a lot like something that gets started from call_usermodehelper.  It's
> parent process is not a descendant of init either.
>
>
> The implementation of the join is to simply change current->nsproxy->pid_ns.
> Then to use it you simply fork to get a child in the target pid namespace.
>   
If the normal rules of parentage apply, that means pid 0 has to wait 
it's child.
If we are in the scenario of pid 0, it's child pid 1234 and we kill the 
pid 1 of the pid namespace, I suppose pid 1234 will be killed too.
The pid 0 will stay in the pid namespace and will able to fork again a 
new pid 1.

I think Serge already reported that...

That sounds good :)
>>> For the case of unshare where we are designed to be used with PAM I don't
>>> think my proposed semantics work.  For a join needed an extra fork before
>>> you are really in the pid namespace should be minor.
>>>       
>> Hm... One more proposal - can we adopt the planned new fork_with_pids system
>> call to fork the process right into a new pid namespace?
>>     
>
> In a lot of ways I like this idea of sys_hijack/sys_cloneat, and I
> don't think anything I am doing fundamentally undermines it.  The use
> case of doing things in fork is that there is automatic inheritance of
> everything.  All of the namespaces and all of the control groups, and
> possibly also the parent process.  
And also the rootfs for executing the command inside the container (eg. 
shutdown), the uid/gid (if there is a user namespace), the mount points, ...
But I suppose we can do the same with setns for all the namespaces and 
chrooting within the container rootfs.

What I see is a problem with the tty. For example, we cloneat the init 
process of the container which is usually /sbin/init but this one has 
its tty mapped to /dev/console, so the output of the exec'ed command 
will go to the console.
> It does have the high cost that the
> process we are copying from must be stopped because there are no locks
> that let us take everything.  I haven't looked at the recent proposals
> to see if anyone has solved that problem cleanly.
>   
Right.

> If we can do a sys_hijack/sys_cloneat style of join, that means we can
> afford a fork.  At which point the my proposed pid namespace semantics
> should be fine.
>
> aka:
> setns(NSTYPE_PID);
> pid = fork();
> if (pid == 0) {
> 	getpid() == 2; /* Or whatever the first free pid is joined pid namespace */
>         getppid() == 0;
> } else {
> 	pid == 6400; /* Or whatever the first free pid is in the original pid namespace */
> 	waitpid(pid);
> }
>
>   
>>> That doesn't handle the case of cached struct pids.  A good example is
>>> waitpid, where it waits for a specific struct pid.  Which means that
>>> allocating a new struct pid and changing task->pid will cause
>>> waitpid(pid) to wait forever...
>>>       
>> OK. Good example. Thanks.
>>
>>     
>>> To change struct pid would require the refcount on struct pid to show
>>> no references from anywhere except the task_struct.
>>>       
>> I think this is OK to return -EBUSY for this. And fix the waitpid
>> respectively not to block this common case. All the others I think
>> can be stayed as is.
>>     
>
> That would probably work.  setsid() and setpgrp() have similar sorts
> of restrictions.  That is both more challenging and more limiting than
> the semantics that come out of my unshare(CLONE_NEWPID) patch.  So I
> would prefer to keep this sort of thing as a last resort.
>
>   
>>> At the cost of a little memory we can solve that problem for unshare
>>> if we have a an extra upid in struct pid, how we verify there is space
>>> in struct pid I'm not certain.
>>>
>>> I do think that at least until someone calls exec the namespace pids are
>>> reported to the process itself should not change.  That is kill and
>>>       
>> Wait a second - in that case the wait will be blocked too! No?
>>     
>
> If all we do is populate an unused struct upid in struct pid there
> isn't a chance of a problem.  
>
>   
>>> waitpid etc.  Which suggests an implementation the opposite of what
>>> I proposed.  With ns_of_pid(task_pid(current)) being used as the
>>> pid namespace of children, and current->nsproxy->pid_ns not changing
>>> in the case of unshare.
>>>
>>> Shrug.
>>>
>>> Or perhaps this is a case where we use we can implement join with
>>> an extra process but we can't implement unshare, because the effect
>>> cannot be immediate.
>>>       
>> Well, I'm talking only about the join now.
>>     
>
> Overall it sounds like the semantics I have proposed with
> unshare(CLONE_NEWPID) are workable, and simple to implement.  The
> extra fork is a bit surprising but it certainly does not
> look like a show stopper for implementing a pid namespace join.
>   
I agree, it's some kind of "ghost" process.
IMO, with a bit of userspace code it would be possible to enter or exec 
a command inside a container with nsfd, setns.

+1 to test your patchset Eric :)

Just a mindless suggestion, the "nsopen" / "nsattach" syscall names 
should be more clear no ?

Jumping back, one question about the nsfd and the poll for waiting the 
end of the namespace.
If we have an openened file descriptor on a specific namespace, we grab 
a reference on this one, so the namespace won't be destroyed until we 
close the fd which is used to poll the end of the namespace, no ? Did I 
miss something ?

Thanks
  -- Daniel
