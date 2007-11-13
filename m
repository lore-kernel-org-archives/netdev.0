From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Strange delays / what usually happens every 10 min?
Date: Tue, 13 Nov 2007 17:23:29 +0100
Message-ID: <4739CF81.8050704@cosmosbay.com>
References: <fhcc39$51b$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Florian Boelstler <kernel@boelstler.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2e.orange.fr ([80.12.242.111]:57905 "EHLO smtp2e.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753840AbXKMQXj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 11:23:39 -0500
Received: from me-wanadoo.net (localhost [127.0.0.1])
	by mwinf2e01.orange.fr (SMTP Server) with ESMTP id ED44E7000044
	for <netdev@vger.kernel.org>; Tue, 13 Nov 2007 17:23:37 +0100 (CET)
In-Reply-To: <fhcc39$51b$1@ger.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46lorian Boelstler a =E9crit :
> Hi,
>
> this issue has been already discussed on the kernelnewbies mailing=20
> list [1],[2] and suggested to be further discussed here.
>
> I am currently working on a MPC8540-based custom board, which runs Li=
nux
> 2.6.15 (arch/ppc). The original Linux sources have been modified to=20
> support that custom board. (Additional patches to support LTT are=20
> applied as well, though disabled in the running kernel)
>
> I set up a periodically running kernel thread, which is delayed for a
> single jiffy using schedule_timeout() in an infinite loop. It is used=
 to
> measure delays between invocations of that thread. For measuring the
> distance in time the PPC's time base lower half register is used
> (obtained using get_cycles() defined in asm/timex.h).
>
> The thread calculates the delay to the previous run and only outputs =
the
> result if a new maximum value has been determined (in respect to all
> previous cycles). Further the thread outputs a warning if a very "hig=
h"
> delay was determined. I.e. a delay greater than 5ms.
>
> While running that test driver a delay of about 10ms _exactly_ occurs
> every 10 minutes.
>
> The kernel is configured using CONFIG_HZ=3D1000 and CONFIG_PREEMPT.
> The CCB is at 333MHz, whereas the TBR update rate is 333 MHz / 8, i.e=
=2E
> 41,625 MHz.
> Kernel configuration as a whole is found here:=20
> http://nopaste.info/5e4d0283bb.html
>
> And now the funny part starts.
> I got a response from Bruce Rowen on kernelnewbies, telling me that h=
e=20
> came across the same problem. He increased his AMD-Geode-based=20
> platform to 1GB of RAM (256MB before) and also hit the=20
> 10-minutes-issue a few month ago (using Linux 2.6.13).
> Going back to 256MB cured the problem. I did the same thing by=20
> instructing the boot loader in order to only use 256 MB of RAM=20
> (instead of 512MB) and yes, the 10-minutes-issue was gone as well.
>
> Apart of some kernel threads almost all user processes have been kill=
ed
> during the test. Only SSH and a bash were running (whereas a test wit=
h=20
> network interfaces completely disabled and only operated from a seria=
l=20
> console turned out the same results).
> The kernel comes with compiled in CIFS support, some kernel debugging
> features like soft-lockup detection and preemption debugging. I.e. ps
> lists the kernel threads ksoftirqd, watchdog, events, khelper, kthrea=
d,
> kblockd, pdflush, aio, cifsoplockd and cifsdnotifyd.
>
> An appropriate userspace test tool based on nanosleep() determined th=
e
> same results like the kernel thread:
>
> root@mpc0:/# /tmp/wait.rt
> looping 1 milli seconds nanosleep ...
> 15:26:16: #1 FRAME MAX 1996 us (at 4139773004 ticks)
> 15:26:16: #2 FRAME MAX 2002 us (at 4139856360 ticks)
> 15:26:16: #155 FRAME MAX 2102 us (at 4152597854 ticks)
> 15:41:37: #460398 FRAME MAX 8941 us (at 3813406605 ticks)
> 15:41:37: #460398 FRAME HIGH 8941 us (at 3813406605 ticks)
> 15:51:37: #760394 FRAME MAX 9936 us (at 3018602602 ticks)
> 15:51:37: #760394 FRAME HIGH 9936 us (at 3018602602 ticks)
> 16:01:37: #1060390 FRAME HIGH 9935 us (at 2223798809 ticks)
> 16:11:37: #1360386 FRAME HIGH 9934 us (at 1428994989 ticks)
> 16:21:37: #1660382 FRAME HIGH 9935 us (at 634191241 ticks)
> [...]
>
> Thanks for any help!
>
> Cheers,
>
>   Florian
>
> [1] http://thread.gmane.org/gmane.linux.kernel.kernelnewbies/23419
> [2] http://thread.gmane.org/gmane.linux.kernel.kernelnewbies/23426
>

Hi Florian

I think you hit the periodic flush of IP route cache, which is fired=20
every 600 seconds per default.

(Check /proc/sys/net/ipv4/route/secret_interval )

=46or a 1GB machine, this hash table is so big that a full scan might t=
ake=20
more than 10 ms, even if empty.

Instead of using less RAM, you could just boot with rhash_entries=3D102=
4=20
to lower the size of this table.

Or just change secret_interval to 2000000 for example (not much more=20
because * HZ could overflow)

Eric




