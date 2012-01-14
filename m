From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Race condition in ipv6 code
Date: Fri, 13 Jan 2012 21:46:45 -0800
Message-ID: <m139biesze.fsf@fess.ebiederm.org>
References: <CA+HUmGhJ-YvFMRnKzb8RqH6COZ=erp1SajVcb1rq1vi2k9OBGw@mail.gmail.com>
	<1326349911.2741.1.camel@edumazet-laptop>
	<m1pqeov4u1.fsf@fess.ebiederm.org>
	<1326434549.2617.14.camel@edumazet-laptop>
	<m1ipkgqccb.fsf@fess.ebiederm.org> <4F10642E.2040302@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Francesco Ruggeri <fruggeri@aristanetworks.com>,
	netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:36596 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751219Ab2ANFoY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jan 2012 00:44:24 -0500
In-Reply-To: <4F10642E.2040302@candelatech.com> (Ben Greear's message of "Fri,
	13 Jan 2012 09:04:46 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Greear <greearb@candelatech.com> writes:

> On 01/12/2012 11:40 PM, Eric W. Biederman wrote:
>
>> So I really think the best solution to avoid the locking craziness is to
>> have a wrapper that gets the value from userspace and calls
>> schedule_work to get another thread to actually process the change.  I
>> don't see any problems with writing a helper function for that.  The
>> only downside with using schedule_work is that we return to userspace
>> before the change has been fully installed in the kernel.  I don't
>> expect that would be a problem but stranger things have happened.
>
> That sounds a bit risky to me.  If something sets a value, and then
> queries it, it should always show the proper result for the previous
> calls.

Which is easy to do if you keep two values.  One integer
for the userspace control and another integer for the internal
kernel state.

The problem is that we have exactly one integer currently.

> If the queries also went through the the same sched-work queue
> then maybe it would be OK.

We can't want for anything that has to take the rtnl_lock.  That would
be the same as taking the rtnl_lock from a locking perspective.

I expect I would use something like:
struct rtnl_protected_knob {
	struct work_struct work;
        int userspace_value;
        int *kernel_var;
        void (*func)(int new_value, *kernel_var);
};

userspace_value would be what userspace sees, and kernel_var would be a
pointer to the value that we manipulate in the kernel.

Eric
