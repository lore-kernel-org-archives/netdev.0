From: "Daniel J Blueman" <daniel.blueman@gmail.com>
Subject: Re: sky2 hangs without any messages
Date: Fri, 13 Jul 2007 09:53:04 +0100
Message-ID: <6278d2220707130153h63549c2ck203b372931c0eae5@mail.gmail.com>
References: <6278d2220707020315q7c3df1cci5c7bb52316ad6081@mail.gmail.com>
	 <20070711082733.603f6540@freepuppy.rosehill.hemminger.net>
	 <6278d2220707110843i16d3a325nebec8cb766a40a5e@mail.gmail.com>
	 <6278d2220707111439r5ea69a29v51cdbef1cbb7ab25@mail.gmail.com>
	 <20070711144553.6c89dc3a@freepuppy.rosehill.hemminger.net>
	 <6278d2220707111521m520ee651k5536652986c86e5e@mail.gmail.com>
	 <6278d2220707111555i6b6cee71qb37894ab2beed247@mail.gmail.com>
	 <20070711184659.279f8ea0@freepuppy.rosehill.hemminger.net>
	 <6278d2220707121429o27a53a6cqd68b647957203626@mail.gmail.com>
	 <20070712144334.0bc02b17@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Linux Netdev" <netdev@vger.kernel.org>
To: "Stephen Hemminger" <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:31668 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934727AbXGMIxF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jul 2007 04:53:05 -0400
Received: by ug-out-1314.google.com with SMTP id j3so522882ugf
        for <netdev@vger.kernel.org>; Fri, 13 Jul 2007 01:53:04 -0700 (PDT)
In-Reply-To: <20070712144334.0bc02b17@freepuppy.rosehill.hemminger.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/07/07, Stephen Hemminger <shemminger@linux-foundation.org> wrote:
> On Thu, 12 Jul 2007 22:29:50 +0100
> "Daniel J Blueman" <daniel.blueman@gmail.com> wrote:
>
> > On 12/07/07, Stephen Hemminger <shemminger@linux-foundation.org> wrote:
> > > On Wed, 11 Jul 2007 23:55:29 +0100
> > > "Daniel J Blueman" <daniel.blueman@gmail.com> wrote:
> > >
> > > > > >
> > > > > > Please try again with post 2.6.22 git version (1.16)?
> > > > >
> > > > > Reproduced with 2.6.22 w/ sky2 1.16 from git. We observe this
> > > > > characteristic failure on the NFS server (always around 2-3GB of
> > > > > transmit):
> > > > >
> > > > > $ ifconfig lan0
> > > > > lan0      Link encap:Ethernet  HWaddr 00:03:2D:05:9C:27
> > > > >           inet addr:192.168.0.250  Bcast:192.168.0.255  Mask:255.255.255.0
> > > > >           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
> > > > >           RX packets:24007220 errors:1 dropped:1 overruns:0 frame:1
> > > > >           TX packets:13886495 errors:0 dropped:0 overruns:0 carrier:0
> > > > >           collisions:0 txqueuelen:1000
> > > > >           RX bytes:171026170 (163.1 MiB)  TX bytes:2262910580 (2.1 GiB)
> > > > >           Interrupt:16
> > > > >
> > > > > I'll rebuild with debugfs and grab the debug you've exported.
> > > >
> > > > In quiescent state [1] and in failure state [2]. This time, 2 framing
> > > > failures [3]; took 3.6GB of transmit to hit the window.
> > >
> > > Since the IRQ workaround has a timeout of 100ms. I observed cases where
> > > the TCP connection dropped (because of lost packets), but the network device
> > > then recovered.  Can you ping the other side after it hangs?  Or reconnect?
> > >
> > > Ifconfig lumps a bunch of different errors together so it can confuse the issue.
> > > Preference is for:
> > >         ip -s -s link show eth0
> > > or
> > >         grep -v '^0' /sys/class/net/eth0/statistics/*
> > >
> > > If the framing error does reproduce with the hang, perhaps the chip needs some
> > > receive flush logic to recover. Receive errors normally put a message in syslog
> > > output, did you look there?
> > >
> > > > Daniel
> > > >
> > > > --- [1]
> > > >
> > > > # cat sky2/lan0
> > > > IRQ src=0 mask=c000001d control=0
> > > > Status ring (empty)
> > > > Tx ring pending=191...191 report=191 done=191
> > > >
> > > > Rx ring hw get=956 put=61 last=1023
> > > >
> > > > --- [2]
> > > >
> > > > # cat sky2/lan0
> > > > IRQ src=0 mask=c000001d control=0
> > > > Status ring (empty)
> > > > Tx ring pending=251...251 report=251 done=251
> > > >
> > > > Rx ring hw get=1020 put=160 last=1023
> > > >
> > > > --- [3]
> > > >
> > > > $ ifconfig lan0
> > > > lan0      Link encap:Ethernet  HWaddr 00:03:2D:05:9C:27
> > > >           inet addr:192.168.0.250  Bcast:192.168.0.255  Mask:255.255.255.0
> > > >           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
> > > >           RX packets:13304841 errors:1 dropped:1 overruns:0 frame:2
> > > >           TX packets:7493765 errors:0 dropped:0 overruns:0 carrier:0
> > > >           collisions:0 txqueuelen:1000
> > > >           RX bytes:232720755 (221.9 MiB)  TX bytes:3964088142 (3.6 GiB)
> > > >           Interrupt:16
> > >
> > > You aren't hung because of lost IRQ. When than happens the debugfs output will have
> > > a bunch of Tx packets stuck (not cleaned up), and Status messages, and receive packets.
> >
> > I'll grab the above info when I next get chance.
> >
> > The vendor driver recovery process may be worthwhile taking a look at;
> > I guess you've seen the code near the bottom of skge.c (under 'case
> > SK_DRV_RECOVER')? The driver kicks the chip with
> > SK_PNMI_EVT_XMAC_RESET and calls SkYuk2RestartRxBmu - perhaps
> > something like this sequence is needed for a more targetted approach?
>
> That code triggers (falsely) on an idle or barely active link. It won't work.
> It is covering over a bunch of problems in the vendor driver that like improper
> flow control.

Yes. Although my point was about how it resets the relevant parts of
the chip; the OS just sees a netif_stop_queue and a netif_wake_queue,
rather than marking the interface down etc.

Daniel
-- 
Daniel J Blueman
