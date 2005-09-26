From: Luca Maranzano <liuk001@gmail.com>
Subject: Re: ipvs_syncmaster brings cpu to 100%
Date: Mon, 26 Sep 2005 16:44:09 +0200
Message-ID: <68559cef05092607441dd8e961@mail.gmail.com>
References: <68559cef050908090657fc2599@mail.gmail.com>
	 <68559cef05092207022f1f0df4@mail.gmail.com>
	 <498263350509230815eb08a73@mail.gmail.com>
	 <20050926032807.GI18357@verge.net.au>
	 <20050926043400.GD5079@us.ibm.com>
	 <20050926080508.GF11027@verge.net.au>
	 <20050926081229.GA23755@verge.net.au>
	 <20050926131104.GA7532@us.ibm.com>
	 <68559cef05092606521cc13f9a@mail.gmail.com>
	 <20050926142109.GD7532@us.ibm.com>
Reply-To: Luca Maranzano <liuk001@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Nishanth Aravamudan <nacc@us.ibm.com>,
        "LinuxVirtualServer.org users mailing list." <lvs-users@linuxvirtualserver.org>
In-Reply-To: <20050926142109.GD7532@us.ibm.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

[trimmed Cc to avoid spamming...]

Ok, just to summarize the long thread from the beginning:

The goal: setting up a Local Director with IPVS with state
synchronization, failover and failback.

The hardware: 1 CPU Intel Xeon 3,4 Ghz - HP DL380G4 on 2 identical boxes

The problems (please note that all kernel versions are *Debian* kernels):
1. Kernel 2.6.8: got a system lock of the standby node when simulating
a failover. The load average as reported from "top" or "w" is always
0.00.

2. Kernel 2.6.11 and Kernel 2.6.12: failover and failback works fine,
but the load average as reported from "top" or "w" is always
systematically at 2.00 or more with both sync thread started
(ipvs_syncmaster and ipvs_syncbackup). Load average from top is 1.00
or mroe with only one thread (i.e. ipvs_syncmaster). Horms reported
that he was not able to reproduce this on a non-Xeon system.

That's all, let me know if you need more info.
Regards,
Luca


On 26/09/05, Nishanth Aravamudan <nacc@us.ibm.com> wrote:
> On 26.09.2005 [15:52:02 +0200], Luca Maranzano wrote:
> > On 26/09/05, Nishanth Aravamudan <nacc@us.ibm.com> wrote:
> > > On 26.09.2005 [17:12:32 +0900], Horms wrote:
> > > > On Mon, Sep 26, 2005 at 05:05:10PM +0900, Horms wrote:
> > > >
> > > > [snip]
> > > >
> > > > > > > > > Furthermore, if I make an "rgrep" in the source tree of kernel 2.6.12
> > > > > > > > > the function schedule_timeout() is more used than the ssleep() (517
> > > > > > > > > occurrencies vs. 43), so why in ip_vs_sync.c there was this change?
> > > > > > > > >
> > > > > > > > > The other oddity is that Horms reported on this list that on non Xeon
> > > > > > > > > CPU the same version of kernel of mine does not present the problem.
> > > > > > > > >
> > > > > > > > > I'm getting crazy :-)
> > > > > > >
> > > > > > > I've prepared a patch, which reverts the change which was introduced
> > > > > > > by Nishanth Aravamudan in February.
> > > > > >
> > > > > > Was the 100% cpu utilization only occurring on Xeon processors?
> > > > >
> > > > > That seems to be the only case where were this problem has been
> > > > > observed. I don't have such a processor myself, so I haven't actually
> > > > > been able to produce the problem locally.
> > > > >
> > > > > One reason I posted this issue to netdev was to get some more
> > > > > eyes on the problem as it is puzzling to say the least.
> > > > >
> > > > > > Care to try to use msleep_interruptible() instead of ssleep(), as
> > > > > > opposed to schedule_timeout()?
> > > > >
> > > > > I will send a version that does that shortly, Luca, can
> > > > > you plase check that too?
> > > >
> > > > Here is that version of the patch. Nishanth, I take it that I do not
> > > > need to set TASK_INTERRUPTABLE before calling msleep_interruptible(),
> > > > please let me know if I am wrong.
> > >
> > > Yes, exactly. I'm just trying to narrow it down to see if it's the task
> > > state that's causing the issue (which, to be honest, doesn't make a lot
> > > of sense to me -- with ssleep() your load average will go up as the task
> > > will be UNINTERRUPTIBLE state, but I am not sure why utilisation would
> > > rise, as you are still sleeping...)
>
> [trimmed lvs-users from my reply, as it is a closed list]
>
> > Just to add more info, please note the output of "ps":
> >
> > debld1:~# ps aux|grep ipvs
> > root      3748  0.0  0.0      0     0 ?        D    12:09   0:00
> > [ipvs_syncmaster]
> > root      3757  0.0  0.0      0     0 ?        D    12:09   0:00
> > [ipvs_syncbackup]
> >
> > Note the D status, i.e. (from ps(1) man page): Uninterruptible sleep
> > (usually IO)
>
> The msleep_interruptible() change should fix that.
>
> But that does not show 100% CPU utilisation at all, it shows 0. Did you
> mean to say your load increases?
>
> I'm still unclear what the problem is. Horms initial Cc trimmed some
> important information. It would be very useful to "start over" -- at
> least from the perspective of what the problem actually is.
>
> > I hope to have a Xeon machine to make some more tests in the next
> > days, in the mean time I'll try to reproduce my setup on a couple of
> > VMWare Workstation machines.
>
> Please don't top-most. It makes it really hard to write sane replies...
>
> Thanks,
> Nish
>
