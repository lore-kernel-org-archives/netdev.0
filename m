From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC][PATCH] ns: Syscalls for better namespace sharing control.
Date: Tue, 02 Mar 2010 14:13:37 -0800
Message-ID: <m1y6iaqsmm.fsf@fess.ebiederm.org>
References: <4B88D80A.8010701@parallels.com>
	<m1mxyvrqvk.fsf@fess.ebiederm.org> <4B88E431.6040609@parallels.com>
	<m1bpfbqajn.fsf@fess.ebiederm.org> <4B894564.7080104@parallels.com>
	<m1iq9io5sc.fsf@fess.ebiederm.org> <4B89727C.9040602@parallels.com>
	<m1ljeempk6.fsf@fess.ebiederm.org> <4B8AE8C1.1030305@free.fr>
	<4B8D28CF.8060304@parallels.com> <20100302211942.GA17816@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pavel Emelyanov <xemul@parallels.com>,
	Daniel Lezcano <daniel.lezcano@free.fr>,
	Linux Netdev List <netdev@vger.kernel.org>,
	containers@lists.linux-foundation.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Ben Greear <greearb@candelatech.com>
To: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:45266 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753531Ab0CBWNn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Mar 2010 17:13:43 -0500
In-Reply-To: <20100302211942.GA17816@us.ibm.com> (Sukadev Bhattiprolu's message of "Tue\, 2 Mar 2010 13\:19\:42 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com> writes:

> Pavel Emelyanov [xemul@parallels.com] wrote:
> | > I agree with all the points you and Pavel you talked about but I don't 
> | > feel comfortable to have the current process to switch the pid namespace 
> | > because of the process tree hierarchy (what will be the parent of the 
> | > process when you enter the pid namespace for example).
> | 
> | The answer is - the one, that used to be. I see no problems with it.
> | Do you?
>
> Just to be clear, when a process unshares its pid namespace, it takes
> on additional pid nr (== 1) in the new namespace but retains its original
> pid nr(s) in the parent (ancestor) namespaces right ?
>
> i.e the process becomes the container-init of the new namespace. When it
> exits, all its children belonging to the new namespace are killed too,
> but any children in the parent namespace (i.e children created before
> unshare()) are not killed.
>
> After the unshare() the process will not be able to signal any children
> it created before the unshare() (bc their active pid namespaces are
> different)

The only case that I see as being simple and unsurprising worked a bit
differently:

We currently have:

ns_of_pid(task_pid(tsk))
tsk->nsproxy->pid_ns


I would reduce the usage of tsk->nsproxy->pid_ns as much as possible,
and use ns_of_pid(task_pid(tsk)) for all of the routine things that
need to know the pid namespace of a process.  Possibly even to the point
or reversing the order of the upid array so using it is more efficient.

I would leave tsk->nsproxy->pid_ns for use by fork/clone when allocating
a childs pid number.

The unsharing process would have to become the child reaper.  I think the first
child would become pid 1 in that pid namespace.


>From an implementation point of view who gets pid 1 when the child_reaper is
not visible inside the pid namespace doesn't make much difference but we would
want to carefully look at the details so we minimize userspace confusion.


I don't think a process tree rooted at pid 0 is a show stopper.  It is
somewhat confusing but we already have a forked process tree today,
and user space certainly hasn't fallen over.  In the case of a join if you want
to live in properly in the process tree you can daemonize and become a child
of init.




I think replacing a struct pid for another struct pid allocated in
descendant pid_namespace (but has all of the same struct upid values
as the first struct pid) is a disastrous idea.  It destroys the
uniqueness of struct pid and we have a lot of places where we check
that for equality of pid pointers, and that now would be broken.
Otherthings like proc directories also used a cached struct pid and
would start thinking the process was gone when it was not.

Eric
