From: "Yinghai Lu" <yhlu.kernel@gmail.com>
Subject: Re: HPET regression in 2.6.26 versus 2.6.25 -- revert for 2.6.26-rc1 failed
Date: Thu, 14 Aug 2008 10:39:45 -0700
Message-ID: <86802c440808141039o4b55887eke9e487e817af0d90@mail.gmail.com>
References: <998851.29384.qm@web82103.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Bill Fink" <billfink@mindspring.com>,
	linux-kernel@vger.kernel.org, "Ingo Molnar" <mingo@elte.hu>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	"Peter Zijlstra" <peterz@infradead.org>,
	"Thomas Gleixner" <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, netdev <netdev@vger.kernel.org>
To: "David Witbrodt" <dawitbro@sbcglobal.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759333AbYHNRkB@vger.kernel.org>
In-Reply-To: <998851.29384.qm@web82103.mail.mud.yahoo.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 14, 2008 at 5:03 AM, David Witbrodt <dawitbro@sbcglobal.net> wrote:
>
>
>> > I'm not sure Yinghai's revert patch is completely equivalent to
>> > a revert of the original problematic commit, by a side-by-side
>> > comparison of the original commit with his recent revert patch,
>> > but then I don't really know that code at all.
>> >
>> > In the original code there was a section (in e820_reserve_resources()):
>> >
>> > #ifdef CONFIG_KEXEC
>> >                   if (crashk_res.start != crashk_res.end)
>> >                           request_resource(res, &crashk_res);
>> > #endif
>> >
>> > If you don't have CONFIG_KEXEC defined in your .config, which is
>> > probably the case, then you would never request a crashk_res resource.
>> > But in the code after the original commit, it unconditionally calls
>> > (in reserve_crashkernel()):
>> >
>> >           crashk_res.start = crash_base;
>> >           crashk_res.end   = crash_base + crash_size - 1;
>> >           insert_resource(&iomem_resource, &crashk_res);
>> >
>> > And after Yinghai's revert patch it still does (in reserve_crashkernel()):
>> >
>> >        crashk_res.start = crash_base;
>> >        crashk_res.end   = crash_base + crash_size - 1;
>> >        crashk_res_ptr = &crashk_res;
>> >
>> > and (in setup_arch()):
>> >
>> >        num_res = 3;
>> >        if (crashk_res_ptr) {
>> >                res_kernel[num_res] = crashk_res_ptr;
>> >                num_res++;
>> >        }
>> >        e820_reserve_resources(res_kernel, num_res);
>> >
>> > then (in e820_reserve_resources()):
>> >
>> >                        for (j = 0; j < nr_res_k; j++) {
>> >                                if (!res_kernel[j])
>> >                                        continue;
>> >                                request_resource(res, res_kernel[j]);
>> >                        }
>> >
>> > which for j == 3 is:
>> >
>> >        request_resource(res, &crashk_res);
>> >
>> > Now it would appear that the new:
>> >
>> >        insert_resource(&iomem_resource, &crashk_res);
>> >
>> > or new:
>> >
>> >        request_resource(res, &crashk_res);
>> >
>> > should be noops.  But if for any reason crash_size is not zero,
>> > then there could be a difference.  I have no idea if this is at all
>> > significant, but I thought I'd point it out just in case.
>>
>> why oops ?
>
> I think he meant no-op's.
>
>
>> if not valid crash kernel size etc is input, crashk_res_ptr will be null
>>
>> >        if (crashk_res_ptr) {
>> >                res_kernel[num_res] = crashk_res_ptr;
>> >                num_res++;
>> >        }
>>
>> it that is not appended to res_kernel...
>
> So your patch code protects against problem that Bill is mentioning
> without using "#ifdef CONFIG_KEXEC", right Yinghai?

can you try enable kexec and kdump in you .config.

it should works. my .config have config_kexec

> Some experiments I did last night may render these questions moot, though.
> My problem is very specific to the hardware on two of my machines, and it
> has something to do with setting up the system resources that
> insert_resource() touches.

please try to bisect on current tree. and every time apply the revert patch...

YH
