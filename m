From: "Luis R. Rodriguez" <mcgrof@suse.com>
Subject: Re: [PATCH v1 5/5] driver-core: add driver asynchronous probe
	support
Date: Tue, 30 Sep 2014 04:27:51 +0200
Message-ID: <20140930022751.GA14081@wotan.suse.de>
References: <1411768637-6809-1-git-send-email-mcgrof@do-not-panic.com> <1411768637-6809-6-git-send-email-mcgrof@do-not-panic.com> <CAG-2HqWmVODJ6Q46t96mS9ALbeFjRcQ18ypwejY=ug0wCUVv-Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
	Michal Hocko <mhocko@suse.cz>,
	Greg KH <gregkh@linuxfoundation.org>,
	Dmitry Torokhov <dmitry.torokhov@gmail.com>,
	Takashi Iwai <tiwai@suse.de>, Tejun Heo <tj@kernel.org>,
	Arjan van de Ven <arjan@linux.intel.com>,
	Robert Milasan <rmilasan@suse.com>, werner@suse.com,
	Oleg Nesterov <oleg@redhat.com>, hare <hare@suse.com>,
	Benjamin Poirier <bpoirier@suse.de>,
	Santosh Rastapur <santosh@chelsio.com>, pmladek@suse.cz,
	dbueso@suse.com, LKML <linux-kernel@vger.kernel.org>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Joseph Salisbury <joseph.salisbury@canonical.com>,
	Kay Sievers <kay@vrfy.org>,
	One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>,
	Tim Gardner <tim.gardner@canonical.com>,
	Pierre Fersing <pierre-fersing@pierref.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Nagalakshmi Nandigama <nagalakshmi.nandigama@avagotec
To: Tom Gundersen <teg@jklm.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAG-2HqWmVODJ6Q46t96mS9ALbeFjRcQ18ypwejY=ug0wCUVv-Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Sep 28, 2014 at 07:07:24PM +0200, Tom Gundersen wrote:
> On Fri, Sep 26, 2014 at 11:57 PM, Luis R. Rodriguez
> <mcgrof@do-not-panic.com> wrote:
> > From: "Luis R. Rodriguez" <mcgrof@suse.com>
> > Systemd has a general timeout for all workers currently set to 180
> > seconds after which it will send a sigkill signal. Systemd now has a
> > warning which is issued once it reaches 1/3 of the timeout. The original
> > motivation for the systemd timeout was to help track device drivers
> > which do not use asynch firmware loading on init() and the timeout was
> > originally set to 30 seconds.
> 
> Please note that the motivation for the timeout in systemd had nothing
> to do with async firmware loading (that was just the case where
> problems cropped up).

*Part *of the original kill logic, according to the commit log, was actually
due to the assumption that the issues observed *were* synchronous firmware
loading on module init():

commit e64fae5573e566ce4fd9b23c68ac8f3096603314
Author: Kay Sievers <kay.sievers@vrfy.org>
Date:   Wed Jan 18 05:06:18 2012 +0100

    udevd: kill hanging event processes after 30 seconds
    
    Some broken kernel drivers load firmware synchronously in the module init
    path and block modprobe until the firmware request is fulfilled.
    <...>

My point here is not to point fingers but to explain why we went on with
this and how we failed to realize only until later that the driver core
ran probe together with init. When a few folks pointed out the issues
with the kill the issue was punted back to kernel developers and the
assumption even among some kernel maintainers was that it was init paths
with sync behaviour that was causing some delays and they were broken
drivers. It is important to highlight these assumptions ended up setting
us off on the wrong path for a while in a hunt to try to fix this issue
either in driver or elsewhere.

> The motivation was to not allow udev-workers to
> stay around indefinitely, and hence put an upper-bound on
> their duration (initially 180 s). At some point the bound was reduced
> to 30 seconds to make sure module-loading would bail out before the
> kernel's firmware loading timeout would bail out (60s I believe).

Sure, part of it was that, but folks beat on driver developer about
the kill insisting it was drivers that were broken. It was only until
Chelsie folks called bloody murder becuase their delays were on probe
that we realized there was a bit more to this than what was being pushed
back on to driver developers.

> That
> is no longer relevant, which is why it was safe to reset the timeout
> to 180 s.

Indeed :D

> > Since systemd + kernel are heavily tied in for the purposes of this
> > patch it is assumed you have merged on systemd the following
> > commits:
> >
> > 671174136525ddf208cdbe75d6d6bd159afa961f        udev: timeout - warn after a third of the timeout before killing
> > b5338a19864ac3f5632aee48069a669479621dca        udev: timeout - increase timeout
> > 2e92633dbae52f5ac9b7b2e068935990d475d2cd        udev: bump event timeout to 60 seconds
> > be2ea723b1d023b3d385d3b791ee4607cbfb20ca        udev: remove userspace firmware loading support
> > 9f20a8a376f924c8eb5423cfc1f98644fc1e2d1a        udev: fixup commit
> > dd5eddd28a74a49607a8fffcaf960040dba98479        udev: unify event timeout handling
> > 9719859c07aa13539ed2cd4b31972cd30f678543        udevd: add --event-timeout commandline option
> >
> > Since we bundle together serially driver init() and probe()
> > on module initialiation systemd's imposed timeout  put a limit on the
> > amount of time a driver init() and probe routines can take. There's a
> > few overlooked issues with this and the timeout in general:
> >
> > 0) Not all drivers are killed, the signal is just sent and
> >    the kill will only be acted upoon if the driver you loaded
> >    happens to have some code path that either uses kthreads (which
> >    as of 786235ee are now killable), or uses some code which checks for
> >    fatal_signal_pending() on the kernel somewhere -- i.e: pci_read_vpd().
> 
> Shouldn't this be seen as something to be fixed in the kernel?

That's a great question. In practice now after CVE-2012-4398 and its series of
patches added which enabled OOM to kill things followed by 786235ee to also
handle OOM on kthreads it seems imperative we strive towards this, in practive
however if you're getting OOMs on boot you have far more serious issue to be
concerned over than handling CVE-2012-4398. Another issue is that even if we
wanted to address this a critical right now on module loading driver error
paths tend to be pretty buggy and we'd probably end up causing more issues than
fixing anything if the sigkill that triggered this was an arbitrary timeout,
specially if the timeout is not properly justified. Addressing sigkill due
to OOM is important, but as noted if you're running out of memory at load
time you have a bit other problems to be concerned over.

So extending the kill onto more drivers *because* of the timeout is probably
not a good reason as it would probably create more issue than fix anything
right now.

> I mean,
> do we not want userspace to have the possibility to kill udev/modprobe
> even disregarding the worker timeouts (say at shutdown, or before
> switching from the initrd)?

That's a good point and I think the merit to handle a kill due to the
other reasons (shutdown, switching from the initrd) should be addressed
separately. I mean that validating addressing the kill for the other
reasons does not validate the existing kill on timeout for synchronous
probing.

If its important to handle the kill on shutdown / switching initrd
that should be dealt with orthogonally.

> > 1) Since systemd is the only one logging the sigkill debugging that
> >    drivers are not loaded or in the worst case *failed to boot* because
> >    of a sigkill has proven hard to debug.
> 
> Care to clarify this a bit? Are the udev logs somehow unclear? 

Sure, so the problem is that folks debugging were not aware of what systemd was
doing.  Let me be clear that the original 30 second sigkill timeout thing was
passed down onto driver maintainers as a non-documented new kernel policy
slap-in-the-face-you-must-obviously-be-doing-something-wrong (TM) approach.
This was a policy decision passed down as a *reactive* measure, not many folks
were aware of it and of what systemd was doing. What made the situation even worse
was that as noted on 1) even though the sigkill was being sent since commit
e64fae55 (January 2012) on systemd the sigkill was not being picked up on many
drivers. To be clear the sigkill was being picked up if you had a driver that
by chance had some code on init / probe that by chance checked for
fatal_signal_pending(), and even when that triggered folks debugging were in no
way shape or form expecting a sigkill from userspace on modprobe as it was not well
known that this was part of the policy they should follow. Shit started to hit
the fan a bit more widely when kernel commit 786235ee (Nov 2013) was merged
upstream which allowed kthreads to be killed, and more drivers started failing.

An example of an ancient bug that no one handled until recently:

https://bugzilla.kernel.org/show_bug.cgi?id=59581

There is a proper fix to this now but the kill was what was causing this
in the first place. The kill was justified as theese drivers *should*
be using async probe but by no means does that mean the kill was
justified for all subsystems / drivers. The bug also really also sent
people on the wrong track and it was only until  Alexander poked me
about the issue we were seeing on cxbg4 likely being related that we
started to really zeroe in on the real issue.

The first driver reported / studied due to the kill from system was
mptsas:

https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1276705

A full bisect was done to even try to understand what the issue was..
Then there was the tug of war between either reverting the patch that
allowed the kthread to be killed or if this was systemd issue which
required increasing the timeout. This was still a storage driver,
and increasing the timeout arbitrarily really would not have helped
address the root cause of the issue.

The next non-storage driver bug that was reported and heavily
debugged was cxgb4 and it wasn't easy to debug:

https://bugzilla.suse.com/show_bug.cgi?id=877622

Conclusion then is that folks were simply not aware of this new de-facto
policy, it was obviously incorrect but well intentioned, and no one
really was paying attention to systemd-udevd logs. If we want chatty
behaviour that people will pick up we probably instead want a WARN()
on the kernel specially before we kill a driver and even then I'm sure
this can irritate some folks.

> If you think we can improve the logging from udev, please ping me about that
> and I'll sort it out.

I think the logging done on systemd is fine, there are a few issues with the
way things trickled down and what we now need to do. First and foremost there
was general communication issue about this new timing policy and obviously it
would have helped if this also had more design / review from others. Its no
one's fault, but we should learn from it. Design policies on systemd that can
affect the kernel / drivers could likely use some bit more review from a wider
audience and probably include folks who are probably going to be more critical
than those who likely would typically be favorable. Without wider review we
could fail to end up with something like a filter bubble [0] but applied to
engineering, a design filter bubble, if you will. So apart from addressing
logging its important to reflect on this issue and try to aim for having
something like a Red Team [1] on design involving systemd and kernel. This is
specially true if we are to really marry these two together more and more. 
The more critical people can be the better, but of course those need to
provide constructive criticism, not just rants.

In terms of logging:

Do we know if distributions / users are reviewing systemd-udevd logs for
certain types of issues with as much dilligence as they put to kernel logs when
systemd makes decision affecting the kernel? If not we should consider a way so
that that happens. In this case the fact that drivers were being killed while
being loaded was missed since it was unexpected that would happen so folks
didn't know to look for that option, but apart from that the *reason* for the
kill probably could have helped too. To help both of these we have to consider if
we are going to keep the sigkill on systemd on module loading due to a timeout.
As you clarified the goal of the timeout is to avoid having udev workers stay
around indefinitely, but I think we need to give kmod workers a bit more
consideration.  The point of this patch set was partly to give systemd what it
assumed was there, but clearly we can't assume all drivers can be loaded
asynchronously without issues right now. That means that even with this
functionality merged systemd will have to cope with the fact that some drivers
will be loaded with synchronous probe.  A general timeout and specially with a
sigkill is probably not a good idea then, unless of course:

0) those device drivers / subsystem maintainer want a timeout
1) the above decision can distinguish between sync probe / async probe
   being done

To address 0) perhaps one solution is that if subsystem maintainers
feel this is needed they can express this on data structure somewhere,
perhaps on the bus and/or have a driver value override, for example.

For 1) we could expose what we end up doing through sysfs.

Of course userspace could also simply want to put in place some
requirements but in terms of a timeout / kill it would have to also
accept that it cannot get what it might want. For instance we now know
it may be that an async probe is not possible on some drivers.

Perhaps its best to think about this differently and address now a
way to do that efficiently instead of reactively. Apart form having
the ability to let systemd ask for async probe, what else do we want
to accomplish?

[0] http://en.wikipedia.org/wiki/Filter_bubble
[1] http://en.wikipedia.org/wiki/Red_team

> > 2) When and if the signal is received by the driver somehow
> >    the driver may fail at different points in its initialization
> >    and unless all error paths on the driver are implemented
> >    perfectly this could mean leaving a device in a half
> >    initialized state.
> >
> > 3) The timeout is penalizing device drivers that take long on
> >    probe(), this wasn't the original motivation. Systemd seems
> >    to have been under assumption that probe was asynchronous,
> >    this perhaps is true as an *objective* and goal for *some
> >    subsystems* but by no means is it true that we've been on a wide
> >    crusade to ensure this for all device drivers. It may be a good
> >    idea for *many* device drivers but penalizing them with a kill
> >    for taking long on probe is simply unacceptable specially
> >    when the timeout is completely arbitrary.
> 
> The point is really not to "penalize" anything, we just need to make
> sure we put some sort of restrictions on our workers so they don't
> hang around forever.

Thanks for clarifying this, can you explain what issues could arise
from making an exception to allowing kmod workers to hang around
completing init + probe over a certain defined amount of time without
being killed?

  Luis
