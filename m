From: Vernon Mauery <vernux@us.ibm.com>
Subject: Re: High contention on the sk_buff_head.lock
Date: Wed, 18 Mar 2009 14:07:32 -0700
Message-ID: <49C16294.8050101@us.ibm.com>
References: <49C12E64.1000301@us.ibm.com> <87prge1rhu.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	rt-users <linux-rt-users@vger.kernel.org>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <linux-rt-users-owner@vger.kernel.org>
In-Reply-To: <87prge1rhu.fsf@basil.nowhere.org>
Sender: linux-rt-users-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:
> Vernon Mauery <vernux@us.ibm.com> writes:
>> So while this issue really hits -rt kernels hard, it has a real effect on
>> mainline kernels as well.  The contention of the spinlocks is amplified
>> when they get turned into rt-mutexes, which causes a double context switch.
> 
> The new adaptive spin heuristics that have been discussed some time
> ago didn't help? Unsurprisingly making locks a lot more expensive
> has drawbacks as you discovered.

Yes.  Well, while the adaptive spinlocks did great things for the
network throughput last time I tested them, they also didn't quite
give the determinism in other areas.  It would be nice to be able to
target a handful of trouble locks with adaptive spinlocks.

Even so, though I saw dramatic throughput increases with adaptive
spinlocks, they would still be bound by this same lock contention
that I am seeing when the locks are true spinlocks.

>>    &list->lock#3:      24517307       24643791           0.71        1286.62      56516392.42       34834296       44904018           0.60        164.79    31314786.02
>>     -------------
>>    &list->lock#3       15596927    [<ffffffff812474da>] dev_queue_xmit+0x2ea/0x468
> 
> The real "fix" would be probably to use a multi queue capable NIC
> and a NIC driver that sets up multiple queues for TX (normally they
> only do for RX). Then cores or a set of cores (often the number
> of cores is larger than the number of NIC queues) could avoid this
> problem. Disadvantage: more memory use.

Hmmm.  So do either the netxen_nic or bnx2x drivers support multiple
queues?  (that is the HW that I have access to right now).  And do I
need to do anything to set them up?

> But then again I'm not sure it's  worth it if the problem only
> happens in out of tree RT.

The effects of the high contention are not quite so pronounced in the
vanilla kernel, but I think we are still limited by this lock.  In the
-rt kernel, it is obvious that the lock contention is causing lots of
trouble.

--Vernon
