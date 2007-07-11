From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: sky2 hangs without any messages
Date: Wed, 11 Jul 2007 14:45:53 -0700
Message-ID: <20070711144553.6c89dc3a@freepuppy.rosehill.hemminger.net>
References: <6278d2220707020315q7c3df1cci5c7bb52316ad6081@mail.gmail.com>
	<20070703123546.5d41410b@freepuppy.localdomain.hemminger.net>
	<6278d2220707031402o7b13e45egc564076a1114b6f5@mail.gmail.com>
	<6278d2220707050609s3579915bo50cf259ba73712f4@mail.gmail.com>
	<20070705101046.542c1f8e@freepuppy.localdomain.hemminger.net>
	<6278d2220707110315h55b69c69r66420377afa703da@mail.gmail.com>
	<20070711082733.603f6540@freepuppy.rosehill.hemminger.net>
	<6278d2220707110843i16d3a325nebec8cb766a40a5e@mail.gmail.com>
	<6278d2220707111439r5ea69a29v51cdbef1cbb7ab25@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Linux Netdev" <netdev@vger.kernel.org>
To: "Daniel J Blueman" <daniel.blueman@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:60396 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752004AbXGKVqD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 17:46:03 -0400
In-Reply-To: <6278d2220707111439r5ea69a29v51cdbef1cbb7ab25@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 11 Jul 2007 22:39:49 +0100
"Daniel J Blueman" <daniel.blueman@gmail.com> wrote:

> On 11/07/07, Daniel J Blueman <daniel.blueman@gmail.com> wrote:
> > > > On 05/07/07, Stephen Hemminger <shemminger@linux-foundation.org> wrote:
> > > > > Well, it didn't fix my test, but it made it better.  The following seemed
> > > > > to work longer...
> > > > >
> > > > > --- a/drivers/net/sky2.c        2007-07-05 09:09:45.000000000 -0700
> > > > > +++ b/drivers/net/sky2.c        2007-07-05 09:09:51.000000000 -0700
> > > > > @@ -2490,6 +2490,13 @@ static int sky2_poll(struct net_device *
> > > > >
> > > > >         work_done = sky2_status_intr(hw, work_limit);
> > > > >         if (work_done < work_limit) {
> > > > > +               /* Bug/Errata workaround?
> > > > > +                * Need to kick the TX irq moderation timer.
> > > > > +                */
> > > > > +               if (sky2_read8(hw, STAT_TX_TIMER_CTRL) == TIM_START) {
> > > > > +                       sky2_write8(hw, STAT_TX_TIMER_CTRL, TIM_STOP);
> > > > > +                       sky2_write8(hw, STAT_TX_TIMER_CTRL, TIM_START);
> > > > > +               }
> > > > >                 netif_rx_complete(dev0);
> > > > >
> > > > >                 /* end of interrupt, re-enables also acts as I/O synchronization */
> > > >
> > > > I spoke too soon on this. With the above patch on 2.6.22-rc7, it
> > > > failed much sooner than the previous patch with the
> > > > read32(B0_Y2_SP_LISR); I'll try to reproduce with the older patch.
> > > >
> > > > Note the ifconfig error/dropped/frame count at the time of failure:
> [snip]
> > > The last message means some how frame was received with checksum for count
> > > wrong. I have only seen it when coalescing is messed up.
> > >
> > > I ran for 2+ days with the patch, and only 20min without. Usually my ISP connection
> > > gives up after that because of crappy DSL box, and that makes DNS not work.
> >
> > It wedged when I was copying a few GBs of data from my server to a
> > local disk at the time, and running rsync over ssh on a large file on
> > my server to my laptop's disk.
> >
> > This would be the typical load that would cause the NIC to lockup from
> > missing an IRQ or otherwise, however, it did feel like the new code
> > didn't un-wedge the Yukon-EC's bus master unit.
> >
> > What other tricks can be used to reset the Yukon-EC's bus master unit?
> >
> > I'll try the read32(B0_Y2_SP_LISR) trick, as before.
> 
> Nope, this still locks up as you found.
> 
> I have a reliable reproducer:
> 
> 1. export directory over NFS TCP on server
> 2. mount directory on client
> 3. run 'iozone -a' in directory on client
> 
> I'm reproducing this with NFSv4 (with callbacks working) with 1500
> octet MTU with one client, all gigabit. It would be good to hear if
> you can reproduce the problem there.
> 
> Daniel

Please try again with post 2.6.22 git version (1.16)?

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
