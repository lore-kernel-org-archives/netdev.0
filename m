From: David Witbrodt <dawitbro@sbcglobal.net>
Subject: Re: HPET regression in 2.6.26 versus 2.6.25 -- why Yinghai's revert may have failed
Date: Thu, 14 Aug 2008 05:20:43 -0700 (PDT)
Message-ID: <990549.89300.qm@web82101.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, netdev <netdev@vger.kernel.org>
To: Yinghai Lu <yhlu.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web82101.mail.mud.yahoo.com ([209.191.84.214]:23866 "HELO
	web82101.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752171AbYHNMUo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2008 08:20:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> > I used 'git apply --check ' first, and got no errors, so
> > I applied it, built, installed, and rebooted.
> 
> that patch revert to use request_resource, so there is some other problem
> 
> YH

I finished experimenting last night with trying to find the last commit
in the gittree that would let me revert the problem successfully...
and I got completely raped.

The bisecting took me all the way back to the first commit introducing
the problem on these motherboards:  3def3d6d...

Considering these 3 consecutive commits (according to 'git log')from late
Feb. 2008, between kernel versions 2.6.25 and 2.6.26-rc1:
---------------------------------------------------------

700efc1b...:  the last kernel I can build and run just fine.

3def3d6d...:  this one builds, but locks up in inet_init() once the sequence
of function calls reaches synchronize_rcu().  Reverting here works, but is
trivial and silly, just reproducing 700efc1b...

1e934dda...:  attempting to revert the changes from 3def3d6d... (just one
commit before!) already fails.
---------------------------------------------------------

This last commit has an effect on my machine that prevents attempts to
revert 3def3d6d... from working as intended.  This may explain why
Yinghai's patch providing the revert for 2.6.27-rc3 did not work.
(Hopefully none of the other changes between Feb. and Aug. would also keep
the revert from working, but I wouldn't bet my life on it....)

The 3d... and 1e... commits are quite small, touching only 4 files total,
and both commits involve calls to insert_resource().  Something on my 2
problem machines is behaving badly in this area.

Reminder:  disabling HPET with "hpet=disable" allows any kernel with the
lockup problem to boot just fine.

Further note: Before my first LKML post about this problem, I had also 
tried turning off all CONFIG_HPET* features that I could reach via 
'make menuconfig', but that did not work and I still had to use 
"hpet=disable" to get the kernel to boot.


SUGGESTION

When my kernels lock up, it is always a chain of calls beginning with
inet_init() and ending up here (in net/core/dev.c):

void synchronize_net(void)
{
    might_sleep();
    synchronize_rcu();
}

If anyone wants to print diagnostic info before my kernel locks up, this 
would be a really good place to do it (so that it doesn't scroll away
before I can write it down):

void synchronize_net(void)
{
    might_sleep();
    /* Insert printk's or diagnostic function here */
    synchronize_rcu();
}


Thanks,
Dave W.
