From: David Witbrodt <dawitbro@sbcglobal.net>
Subject: Re: HPET regression in 2.6.26 versus 2.6.25 -- connection between HPET and lockups found
Date: Tue, 19 Aug 2008 05:49:23 -0700 (PDT)
Message-ID: <452065.84245.qm@web82105.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Yinghai Lu <yhlu.kernel@gmail.com>, linux-kernel@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, netdev <netdev@vger.kernel.org>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754720AbYHSMth@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> Just to make sure: on a working kernel, do you get the HPET messages? 
> I.e. does the hpet truly work in that case?

On the "fileserver", where 2.6.25 works but 2.6.26 locks up, the HPET
_does_ work on a working kernel:

$ uname -r
2.6.26.revert1

$ dmesg | grep -i hpet
ACPI: HPET 77FE80C0, 0038 (r1 RS690  AWRDACPI 42302E31 AWRD       98)
ACPI: HPET id: 0x10b9a201 base: 0xfed00000
hpet clockevent registered
hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0
hpet0: 4 32-bit timers, 14318180 Hz
hpet_resources: 0xfed00000 is busy


What I didn't realize is that the "desktop" machine, where 2.6.26 has
always "worked", does NOT have a working HPET after all, even though 
I have enabled all HPET options in .config:

$ uname -r
2.6.26.080801.desktop.uvesafb

$ dmesg | grep -i hpet
$ 


This means I misunderstood my situation on "desktop".  I believed HPET
was working on all of my machines, but now I am not certain that it 
ever worked on "desktop" since I built it (May 2007).  The question 
never arose before, and because I enabled the HPET option in .config,
I just assumed that HPET was working.  (Duh...)  I failed to look into
this until now.

At any rate, my subject line is still accurate:  there _is_ an HPET
regression on "fileserver" (and "webserver"), since it worked on
2.6.25 kernels but causes lockups on 2.6.2[67] kernels.

(I don't know what is going on with "desktop":  does the motherboard
lack HPET, or does the Linux kernel not support the HPET hardware on 
the motherboard?)

BTW:  the 'dmesg' output above is the same on "desktop" with 2.6.25
and 2.6.26 -- I just checked to be sure.  For "fileserver", I checked
an old 2.6.25 kernel just now, and the output is identical.


Another experiment:  I just tried this...

static __init int hpet_insert_resource(void)
{
-     if (!hpet_res)
+     /* if (!hpet_res) */
         return 1;

-    return insert_resource(&iomem_resource, hpet_res);
+    /* return insert_resource(&iomem_resource, hpet_res); */
}

... and the lock up still occurs.  So, the memory is allocated but
the resource info is not inserted into the tree.  Whether the
dynamic memory for hpet_res is being damaged or not has no bearing
on the lockups, it would seem.  Looks like I was barking up the
wrong tree....


Dave W.
