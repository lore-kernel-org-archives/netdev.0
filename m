From: Chris Metcalf <cmetcalf@ezchip.com>
Subject: Re: [PATCH] nohz: prevent tilegx network driver interrupts
Date: Fri, 10 Jul 2015 15:05:02 -0400
Message-ID: <55A0175E.2010200@ezchip.com>
References: <1436549624-16104-1-git-send-email-cmetcalf@ezchip.com> <20150710182406.GC26428@lerouge>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Frederic Weisbecker <fweisbec@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150710182406.GC26428@lerouge>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/10/2015 02:24 PM, Frederic Weisbecker wrote:
> On Fri, Jul 10, 2015 at 01:33:44PM -0400, Chris Metcalf wrote:
>> In nohz_full mode, by default distribute networking shim
>> interrupts across the housekeeping cores, not all the cores.
> I can't really tell, I have no idea what this driver does. It seems
> to be about networking CPUs but I have no idea what we are affining
> here. Whether it is task, interrupt, ... And what those affine things do,
> if it is safe to do that reduce affinity etc..
>
> I looked at the driver but I can't make my way there. I think you
> need a more detailed changelog :-)

Fair enough! :-)  See updated changelog to follow.

>> Signed-off-by: Chris Metcalf <cmetcalf@ezchip.com>
>> ---
>> The alternate approaches to this might be:
>>
>> 1. "#define housekeeping_mask cpu_online_mask" in the non-nohz_full
>>     arm in <linux/tick.h>, then just unconditionally use
>>     "housekeeping_mask".
> Indeed we are doing more and more references on housekeeping_mask, so
> we should probably think about an off-case.
>
> Now the nohz-full off-case should rather be cpu_possible_mask than
> cpu_online_mask. housekeeping_mask doesn't take into account onlining
> at all.

That suggests that in this case, we might want to default to
something like "housekeeping_mask & cpu_online_mask",
since you really don't want to send irqs to offline cores to
process your packets :-)

The tilegx chips typically don't do cpu offlining anyway, since
we've never really found a usecase, so whatever you boot with
you always have available.  We do have support for a bare-metal
mode which you can run on some of the cores, so you may start
with fewer than cpu_possible actually running, but it will always
be that same set of cores.

So this does suggest that my original patch is wrong for that
same reason.

>> 2. Provide an accessor that returns the cpumask to use for housekeeping
>>     chores and implement it in the obvious ways for both nohz_full
>>     and non-nohz_full.
>>
>> The latter seems like arguably the most satisfying approach, but
>> the patch below is, if nothing else, suitable to push for 4.3
>> without any further API development work.
> I don't know. 1) looks easier.

On reflection, the problem with (1) is that if you are in NO_HZ_FULL
mode but !tick_nohz_full_enabled(), you want to fall back to just
using cpu_possible_mask anyway.  So I think a simple accessor that
returns an appropriate cpumask pointer is probably the best bet
(along the lines of the existing is_housekeeping_cpu() accessor).

-- 
Chris Metcalf, EZChip Semiconductor
http://www.ezchip.com
