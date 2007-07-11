From: "Daniel J Blueman" <daniel.blueman@gmail.com>
Subject: Re: sky2 hangs without any messages
Date: Wed, 11 Jul 2007 23:55:29 +0100
Message-ID: <6278d2220707111555i6b6cee71qb37894ab2beed247@mail.gmail.com>
References: <6278d2220707020315q7c3df1cci5c7bb52316ad6081@mail.gmail.com>
	 <6278d2220707031402o7b13e45egc564076a1114b6f5@mail.gmail.com>
	 <6278d2220707050609s3579915bo50cf259ba73712f4@mail.gmail.com>
	 <20070705101046.542c1f8e@freepuppy.localdomain.hemminger.net>
	 <6278d2220707110315h55b69c69r66420377afa703da@mail.gmail.com>
	 <20070711082733.603f6540@freepuppy.rosehill.hemminger.net>
	 <6278d2220707110843i16d3a325nebec8cb766a40a5e@mail.gmail.com>
	 <6278d2220707111439r5ea69a29v51cdbef1cbb7ab25@mail.gmail.com>
	 <20070711144553.6c89dc3a@freepuppy.rosehill.hemminger.net>
	 <6278d2220707111521m520ee651k5536652986c86e5e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Linux Netdev" <netdev@vger.kernel.org>
To: "Stephen Hemminger" <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:64378 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934729AbXGKWzb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 18:55:31 -0400
Received: by ug-out-1314.google.com with SMTP id j3so221802ugf
        for <netdev@vger.kernel.org>; Wed, 11 Jul 2007 15:55:30 -0700 (PDT)
In-Reply-To: <6278d2220707111521m520ee651k5536652986c86e5e@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/07/07, Daniel J Blueman <daniel.blueman@gmail.com> wrote:
> On 11/07/07, Stephen Hemminger <shemminger@linux-foundation.org> wrote:
> > On Wed, 11 Jul 2007 22:39:49 +0100
> > "Daniel J Blueman" <daniel.blueman@gmail.com> wrote:
> >
> > > On 11/07/07, Daniel J Blueman <daniel.blueman@gmail.com> wrote:
> > > > > > On 05/07/07, Stephen Hemminger <shemminger@linux-foundation.org> wrote:
> > > > > > > Well, it didn't fix my test, but it made it better.  The following seemed
> > > > > > > to work longer...
> > > > > > >
> > > > > > > --- a/drivers/net/sky2.c        2007-07-05 09:09:45.000000000 -0700
> > > > > > > +++ b/drivers/net/sky2.c        2007-07-05 09:09:51.000000000 -0700
> > > > > > > @@ -2490,6 +2490,13 @@ static int sky2_poll(struct net_device *
> > > > > > >
> > > > > > >         work_done = sky2_status_intr(hw, work_limit);
> > > > > > >         if (work_done < work_limit) {
> > > > > > > +               /* Bug/Errata workaround?
> > > > > > > +                * Need to kick the TX irq moderation timer.
> > > > > > > +                */
> > > > > > > +               if (sky2_read8(hw, STAT_TX_TIMER_CTRL) == TIM_START) {
> > > > > > > +                       sky2_write8(hw, STAT_TX_TIMER_CTRL, TIM_STOP);
> > > > > > > +                       sky2_write8(hw, STAT_TX_TIMER_CTRL, TIM_START);
> > > > > > > +               }
> > > > > > >                 netif_rx_complete(dev0);
> > > > > > >
> > > > > > >                 /* end of interrupt, re-enables also acts as I/O synchronization */
> > > > > >
> > > > > > I spoke too soon on this. With the above patch on 2.6.22-rc7, it
> > > > > > failed much sooner than the previous patch with the
> > > > > > read32(B0_Y2_SP_LISR); I'll try to reproduce with the older patch.
> > > > > >
> > > > > > Note the ifconfig error/dropped/frame count at the time of failure:
> > > [snip]
> > > > > The last message means some how frame was received with checksum for count
> > > > > wrong. I have only seen it when coalescing is messed up.
> > > > >
> > > > > I ran for 2+ days with the patch, and only 20min without. Usually my ISP connection
> > > > > gives up after that because of crappy DSL box, and that makes DNS not work.
> > > >
> > > > It wedged when I was copying a few GBs of data from my server to a
> > > > local disk at the time, and running rsync over ssh on a large file on
> > > > my server to my laptop's disk.
> > > >
> > > > This would be the typical load that would cause the NIC to lockup from
> > > > missing an IRQ or otherwise, however, it did feel like the new code
> > > > didn't un-wedge the Yukon-EC's bus master unit.
> > > >
> > > > What other tricks can be used to reset the Yukon-EC's bus master unit?
> > > >
> > > > I'll try the read32(B0_Y2_SP_LISR) trick, as before.
> > >
> > > Nope, this still locks up as you found.
> > >
> > > I have a reliable reproducer:
> > >
> > > 1. export directory over NFS TCP on server
> > > 2. mount directory on client
> > > 3. run 'iozone -a' in directory on client
> > >
> > > I'm reproducing this with NFSv4 (with callbacks working) with 1500
> > > octet MTU with one client, all gigabit. It would be good to hear if
> > > you can reproduce the problem there.
> > >
> > > Daniel
> >
> > Please try again with post 2.6.22 git version (1.16)?
>
> Reproduced with 2.6.22 w/ sky2 1.16 from git. We observe this
> characteristic failure on the NFS server (always around 2-3GB of
> transmit):
>
> $ ifconfig lan0
> lan0      Link encap:Ethernet  HWaddr 00:03:2D:05:9C:27
>           inet addr:192.168.0.250  Bcast:192.168.0.255  Mask:255.255.255.0
>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>           RX packets:24007220 errors:1 dropped:1 overruns:0 frame:1
>           TX packets:13886495 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:1000
>           RX bytes:171026170 (163.1 MiB)  TX bytes:2262910580 (2.1 GiB)
>           Interrupt:16
>
> I'll rebuild with debugfs and grab the debug you've exported.

In quiescent state [1] and in failure state [2]. This time, 2 framing
failures [3]; took 3.6GB of transmit to hit the window.

Daniel

--- [1]

# cat sky2/lan0
IRQ src=0 mask=c000001d control=0
Status ring (empty)
Tx ring pending=191...191 report=191 done=191

Rx ring hw get=956 put=61 last=1023

--- [2]

# cat sky2/lan0
IRQ src=0 mask=c000001d control=0
Status ring (empty)
Tx ring pending=251...251 report=251 done=251

Rx ring hw get=1020 put=160 last=1023

--- [3]

$ ifconfig lan0
lan0      Link encap:Ethernet  HWaddr 00:03:2D:05:9C:27
          inet addr:192.168.0.250  Bcast:192.168.0.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:13304841 errors:1 dropped:1 overruns:0 frame:2
          TX packets:7493765 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:232720755 (221.9 MiB)  TX bytes:3964088142 (3.6 GiB)
          Interrupt:16
-- 
Daniel J Blueman
