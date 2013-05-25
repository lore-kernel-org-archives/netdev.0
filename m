From: Shawn Bohrer <shawn.bohrer@gmail.com>
Subject: Re: 3.10.0-rc2 mlx4 not receiving packets for some multicast groups
Date: Sat, 25 May 2013 10:13:47 -0500
Message-ID: <20130525151347.GB25744@lintop.rgmadvisors.com>
References: <20130524154931.GA9245@sbohrermbp13-local.rgmadvisors.com>
 <20130524163446.GC9245@sbohrermbp13-local.rgmadvisors.com>
 <CAJZOPZJwe6xAj7xRK5_BnWN2wNT+oVS329+iYtE4hYTqPMLwJQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Hadar Hen Zion <hadarh@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:57486 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756762Ab3EYPNv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 May 2013 11:13:51 -0400
Received: by mail-ob0-f178.google.com with SMTP id v19so6473823obq.23
        for <netdev@vger.kernel.org>; Sat, 25 May 2013 08:13:50 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAJZOPZJwe6xAj7xRK5_BnWN2wNT+oVS329+iYtE4hYTqPMLwJQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 25, 2013 at 06:41:05AM +0300, Or Gerlitz wrote:
> On Fri, May 24, 2013 at 7:34 PM, Shawn Bohrer <shawn.bohrer@gmail.com> wrote:
> > On Fri, May 24, 2013 at 10:49:31AM -0500, Shawn Bohrer wrote:
> > > I just started testing the 3.10 kernel, previously we were on 3.4 so
> > > there is a fairly large jump.  I've additionally applied the following
> > > four patches to the 3.10.0-rc2 kernel that I'm testing:
> > >
> > > https://patchwork.kernel.org/patch/2484651/
> > > https://patchwork.kernel.org/patch/2484671/
> > > https://patchwork.kernel.org/patch/2484681/
> > > https://patchwork.kernel.org/patch/2484641/
> > >
> >> I don't know if those patches are related to my issues or not but I
> >> plan on trying to reproduce without them soon.
> 
> > I've reverted the four patches above from my test kernel and still see
> > the issue so they don't appear to be the cause.
> 
> Hi Shawn,
> 
> So 3.4 works, 3.10-rc2 breaks? its indeed a fairly large gap, maybe
> try to bisec that? just to make sure, did use touch any mlx4
> non-default config? specifically did you turn DMFS (Device Managed
> Flow Steering) on using the  set the mlx4_core module param of
> log_num_mgm_entry_size or you were using B0 steering (the default)?

Initially my goal is to sanity check 3.10 before I start playing with
the knobs, so I haven't explicitly changed any new mlx4 settings yet.
We do however set some non-default values but I'm doing that on both
kernels:

mlx4_core log_num_vlan=7
mlx4_en pfctx=0xff pfcrx=0xff

I may indeed try to bisect this, but first I need to see how easily I
can reproduce it.  I did some more testing last night that left me
feeling certifiably insane.  I'll explain what I saw with hopes that
either it will confirm I'm insane or maybe actually make sense to
someone...  My testing of 3.10 has basically gone like this:

1. I have 40 test machines.  I installed 3.10.0-rc2 on machine 1,
rebooted, and it came back without any fireworks so I installed
3.10.0-rc2 on the remaining 39 machines and rebooted them all in one
shot.
2. I then started my test applications which appeared everything was
functioning correctly on all machines.  There were some pretty
significant end-to-end latency regressions in our system so I started
to narrow down where the added latency might be coming from
(interrupts, memory, disk, scheduler, send/receive...).
3. 6 of my 40 machines are configured to receive the same data on
approximately 350 multicast groups.  I picked machine #1 built a new
kernel disabling the new adaptive NO_HZ and RCU no CB settings and
rebooted that machine.  When I re-ran my application machine #1 was
now only receiving data on a small fraction of the multicast groups.
4. After puzzling over machine #1 I decided to reboot machine #2 to
see if it was the reboot or the new kernel or maybe something else.
When machine #2 came back it was in the same state as machine #1 and
only received multicast data on a small number of the 350 groups.
This meant it wasn't my config change but the reboot that triggered
the issue.
5. Debugging I noticed that tcpdump on machine #1 or #2 caused them to
suddenly receive data, and simply putting the interface in promiscuous
mode had the same result.  I rebooted both machine #1 and #2 several
times and each time they had the same issue.  I then rebooted them
back into 3.4 and they both functioned as expected and received data
on all 350 groups.  Rebooted them both back into 3.10 and they were
both still broken.  This is when I sent my initial email to netdev.

*Here is where I went insane*
6. I still had 6 machines all configured the same and receiving the
same data.  #1 and #2 were still broken so I decided to see what would
happen if I simply rebooted #3.  I rebooted #3 started my application
and as I sort of expected #3 no longer received data on most of the
multicast groups.  The crazy part was that machine #1 was now working!
I didn't touch that machine at all, just stopped, and restarted my
application.
7. Confused I rebooted #4.  Again machine #4 was now broken, and
magically machine #2 started working.
8. When I rebooted machine #5 it came back and received all of the
data, but it also magically fixed #3.
9. At this point my brain was fried and it was time to go home so I
rebooted all machines back to 3.4 and gave up.

I'll revisit this again next week.

Thanks,
Shawn
