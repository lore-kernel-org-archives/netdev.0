From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: Re: [PATCH 40/45] powerpc, irq: Use GFP_ATOMIC allocations in atomic
 context
Date: Wed, 26 Jun 2013 00:50:01 +0530
Message-ID: <51C9ED61.1060306@linux.vnet.ibm.com>
References: <20130623133642.19094.16038.stgit@srivatsabhat.in.ibm.com> <20130623134657.19094.93687.stgit@srivatsabhat.in.ibm.com> <20130625020842.GD14051@concordia> <1372126384.3944.177.camel@pasglop> <20130625025858.GE14051@concordia> <1372130007.3944.185.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Michael Ellerman <michael@ellerman.id.au>, tglx@linutronix.de,
	peterz@infradead.org, tj@kernel.org, oleg@redhat.com,
	paulmck@linux.vnet.ibm.com, rusty@rustcorp.com.au,
	mingo@kernel.org, akpm@linux-foundation.org, namhyung@kernel.org,
	walken@google.com, vincent.guittot@linaro.org,
	laijs@cn.fujitsu.com, rostedt@goodmis.org,
	wangyun@linux.vnet.ibm.com, xiaoguangrong@linux.vnet.ibm.com,
	sbw@mit.edu, fweisbec@gmail.com, zhong@linux.vnet.ibm.com,
	nikunj@linux.vnet.ibm.com, linux-pm@vger.kernel.org,
	linux-arch@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Paul Mackerras <paulus@samba.org>,
	Ian Munsie <imunsie@au1.ibm.com>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp06.in.ibm.com ([122.248.162.6]:45513 "EHLO
	e28smtp06.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751698Ab3FYTXY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jun 2013 15:23:24 -0400
Received: from /spool/local
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Wed, 26 Jun 2013 00:45:53 +0530
In-Reply-To: <1372130007.3944.185.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/25/2013 08:43 AM, Benjamin Herrenschmidt wrote:
> On Tue, 2013-06-25 at 12:58 +1000, Michael Ellerman wrote:
>> On Tue, Jun 25, 2013 at 12:13:04PM +1000, Benjamin Herrenschmidt wrote:
>>> On Tue, 2013-06-25 at 12:08 +1000, Michael Ellerman wrote:
>>>> We're not checking for allocation failure, which we should be.
>>>>
>>>> But this code is only used on powermac and 85xx, so it should probably
>>>> just be a TODO to fix this up to handle the failure.
>>>
>>> And what can we do if they fail ?
>>
>> Fail up the chain and not unplug the CPU presumably.
> 
> BTW. Isn't Srivatsa series removing the need to stop_machine() for
> unplug ? 

Yes.

That should mean we should be able to use GFP_KERNEL no ?

No, because whatever code was being executed in stop_machine() context
would still be executed with interrupts disabled. So allocations that
can sleep would continue to be forbidden in this path.

In the CPU unplug sequence, the CPU_DYING notifications (and the surrounding
code) is guaranteed to be run:
a. _on_ the CPU going offline
b. with interrupts disabled on that CPU.

My patchset will retain these guarantees even after removing stop_machine().
And these are required for the correct execution of the code in this path,
since they rely on these semantics.

So I guess I'll retain the patch as it is. Thank you!

Regards,
Srivatsa S. Bhat
