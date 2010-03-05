From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC][PATCH] ns: Syscalls for better namespace sharing control.
Date: Fri, 05 Mar 2010 12:26:30 -0800
Message-ID: <m1vdda1pmx.fsf@fess.ebiederm.org>
References: <4B88E431.6040609@parallels.com>
	<m1bpfbqajn.fsf@fess.ebiederm.org> <4B894564.7080104@parallels.com>
	<m1iq9io5sc.fsf@fess.ebiederm.org> <4B89727C.9040602@parallels.com>
	<m1ljeempk6.fsf@fess.ebiederm.org> <4B8AE8C1.1030305@free.fr>
	<4B8D28CF.8060304@parallels.com> <20100302211942.GA17816@us.ibm.com>
	<m1y6iaqsmm.fsf@fess.ebiederm.org> <20100303000743.GA13744@us.ibm.com>
	<m1ocj6qljj.fsf@fess.ebiederm.org> <4B8E9370.3050300@parallels.com>
	<m17hptjh3m.fsf@fess.ebiederm.org> <4B9158F5.5040205@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>,
	Daniel Lezcano <daniel.lezcano@free.fr>,
	Serge Hallyn <serue@us.ibm.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	containers@lists.linux-foundation.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Ben Greear <greearb@candelatech.com>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:41582 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753153Ab0CEU0o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Mar 2010 15:26:44 -0500
In-Reply-To: <4B9158F5.5040205@parallels.com> (Pavel Emelyanov's message of "Fri\, 05 Mar 2010 22\:18\:13 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov <xemul@parallels.com> writes:

>> 2 parallel enters?  I meant you have pid 0 in the entered pid namespace.
>> You have pid 0 because your pid simply does not map.
>
> Oh, I see.
>
>> There is nothing that makes to parallel enters impossible in that.
>> Even today we have one thread per cpu that has task->pid == &init_struct_pid
>> which is pid 0.
>
> How about the forked processes then? Who will be their parent?

The normal rules of parentage apply.   So the child will see simply
see it's parent as ppid == 0.  If that child daemonizes it will become
a child of the pid namespaces init.

This is a lot like something that gets started from call_usermodehelper.  It's
parent process is not a descendant of init either.


The implementation of the join is to simply change current->nsproxy->pid_ns.
Then to use it you simply fork to get a child in the target pid namespace.

>> For the case of unshare where we are designed to be used with PAM I don't
>> think my proposed semantics work.  For a join needed an extra fork before
>> you are really in the pid namespace should be minor.
>
> Hm... One more proposal - can we adopt the planned new fork_with_pids system
> call to fork the process right into a new pid namespace?

In a lot of ways I like this idea of sys_hijack/sys_cloneat, and I
don't think anything I am doing fundamentally undermines it.  The use
case of doing things in fork is that there is automatic inheritance of
everything.  All of the namespaces and all of the control groups, and
possibly also the parent process.  It does have the high cost that the
process we are copying from must be stopped because there are no locks
that let us take everything.  I haven't looked at the recent proposals
to see if anyone has solved that problem cleanly.



If we can do a sys_hijack/sys_cloneat style of join, that means we can
afford a fork.  At which point the my proposed pid namespace semantics
should be fine.

aka:
setns(NSTYPE_PID);
pid = fork();
if (pid == 0) {
	getpid() == 2; /* Or whatever the first free pid is joined pid namespace */
        getppid() == 0;
} else {
	pid == 6400; /* Or whatever the first free pid is in the original pid namespace */
	waitpid(pid);
}

>> That doesn't handle the case of cached struct pids.  A good example is
>> waitpid, where it waits for a specific struct pid.  Which means that
>> allocating a new struct pid and changing task->pid will cause
>> waitpid(pid) to wait forever...
>
> OK. Good example. Thanks.
>
>> To change struct pid would require the refcount on struct pid to show
>> no references from anywhere except the task_struct.
>
> I think this is OK to return -EBUSY for this. And fix the waitpid
> respectively not to block this common case. All the others I think
> can be stayed as is.

That would probably work.  setsid() and setpgrp() have similar sorts
of restrictions.  That is both more challenging and more limiting than
the semantics that come out of my unshare(CLONE_NEWPID) patch.  So I
would prefer to keep this sort of thing as a last resort.

>> At the cost of a little memory we can solve that problem for unshare
>> if we have a an extra upid in struct pid, how we verify there is space
>> in struct pid I'm not certain.
>> 
>> I do think that at least until someone calls exec the namespace pids are
>> reported to the process itself should not change.  That is kill and
>
> Wait a second - in that case the wait will be blocked too! No?

If all we do is populate an unused struct upid in struct pid there
isn't a chance of a problem.  

>> waitpid etc.  Which suggests an implementation the opposite of what
>> I proposed.  With ns_of_pid(task_pid(current)) being used as the
>> pid namespace of children, and current->nsproxy->pid_ns not changing
>> in the case of unshare.
>> 
>> Shrug.
>> 
>> Or perhaps this is a case where we use we can implement join with
>> an extra process but we can't implement unshare, because the effect
>> cannot be immediate.
>
> Well, I'm talking only about the join now.

Overall it sounds like the semantics I have proposed with
unshare(CLONE_NEWPID) are workable, and simple to implement.  The
extra fork is a bit surprising but it certainly does not
look like a show stopper for implementing a pid namespace join.

Eric
