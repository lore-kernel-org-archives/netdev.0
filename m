From: "Amit S. Kale" <amitkale@linsyssoft.com>
Subject: Re: [Kgdb-bugreport] [PATCH 2.6.20-rc7] 8139too KGDBoE fix
Date: Fri, 23 Feb 2007 12:38:40 +0530
Message-ID: <200702231238.40474.amitkale@linsyssoft.com>
References: <200701312144.56497.sshtylyov@ru.mvista.com> <45DDBD96.10000@ru.mvista.com> <45DDC7C0.8050100@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Sergei Shtylyov <sshtylyov@ru.mvista.com>,
	Mithlesh Thukral <mithlesh@linsyssoft.com>,
	Vitaly Wool <vwool@ru.mvista.com>, Mark Huth <mhuth@mvista.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from svr68.ehostpros.com ([67.15.48.48]:36781 "EHLO
	svr68.ehostpros.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752148AbXBWHwW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Feb 2007 02:52:22 -0500
In-Reply-To: <45DDC7C0.8050100@ru.mvista.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Net Gurus,

This thread came up on kgdb-bugreport mailing list. Could you please suggest 
us what's the correct way of fixing this problem?

1. When running a kgdb on RTL8139 ethernet interface: 8139too driver prints 
too many "Out-of-sync dirty pointer" messages on console and gdb can't 
connect to kgdb stub. These messages can be suppressed, though it still 
results in connection failures frequently. 

2. Here is how kgdb uses polling mechanism for communication to gdb.  kgdb 
calls netpoll_set_trap(1) just before entering a loop where it communicates 
to gdb. It calls netpoll_set_trap(0) after it is done and wants to resume a 
kernel. The communication to gdb goes through netpoll_poll (which calls kgdb 
rx_hook) and netpoll_send_udp functions.

3. A queue for an interface may have been stopped by it's driver by calling 
netif_stop_queue. After this if kgdb attempts to enter communication with 
gdb, it'll call netpoll_set_trap(1), after which the queue can't be started 
again. This is a potential deadlock situation. Is there a way out of this?

4. Is it necessary to call netpoll_set_trap(1) at all before entering gdb 
communication loop? Even if a driver stops the queue in middle of the 
communication netpoll_poll and netpoll_send_udp calls can recover from that 
by calling driver's interrupt and poll routines. Is this a valid statement?

Thanks a lot.
-Amit



On Thursday 22 February 2007 22:11, Sergei Shtylyov wrote:
> Hello, I wrote:
> >>>>>>>Even with this patch, the packets probably get stuck somewhere in
> >>>>>>> the driver, as cross-gdb sees tail of the $g packet reply only in
> >>>>>>> reply to next packet...
> >>>
> >>>  This wasn;t happeing on x86 probably because the register packet
> >>> should be much shorted there than on PPC...
> >>>
> >>>>>>  Argh! That's all because of the CONFIG_NETPOLL_TRAP that
> >>>>>>CONFIG_KGDBOE* options select -- since the initial breakpoint enables
> >>>>>>trapping via KGDBoE's pre_exception() handler,
> >>>>>> netif_{stop/wake}_queue() stop to work and that causes KGDBoE to
> >>>>>> literally flood 8139too with packets (although it can't queue up
> >>>>>> more than 4). Looks like a general design issue to me... :-/
> >>>>>
> >>>>> Well, maybe not. But many drivers are surely unprepared to their
> >>>>>hard_start_xmit() method being called with queue alraedy stopped and
> >>>>>those with small TX queue (like natsemi with which we're also having
> >>>>>trouble) would get flooded as well. I'm going to submit a patch to
> >>>>>netdev adding extra check for TX ring being full -- after/if it gets
> >>>>>accepted, this patch won't be needed anymore.
> >>>>
> >>>>Here is what comes to my mind right away. It might need some more
> >>>>polishing or cleaning up:
> >>>>
> >>>>A potential solution will be to check the if hard_start_xmit() returns
> >>>>NETDEV_TX_BUSY. In case transmit queue is busy (due to lot of threads
> >>>> or queue getting full), we should wait in netpoll_send_skb(), call a
> >>>> cleanup through poll() and then retry sending packet.
> >>>
> >>>   This is already being done by netpoll iself. The thing is that
> >>>hard_start_xmit() doesdn't return NETDEV_TX_BUSY in those drivers. :-/
> >>
> >>In addition to that we set trapped. I wonder whether it is possible that
> >> a queue is stopped and we enter kgdb. It would be a deadlock.
> >>-Amit
> >
> >     Why? Netpoll does call the driver's interrupt and NAPI handlers in
> > that case (until the retry count is 0).
>
>     Ah, got it -- since the traffic trapping (when enabled) effectively
> bypasses netif_wake_queue(), a queue would never be actually woken up.
> Maybe it's worth to always return 0 from netif_queue_stopped() in this
> case? Or maybe the correct thing to do when trapping is to just thiddle the
> __LINK_STATE_XOFF bit, bypassing call to netif_schedule()?
>
> >>>>Regards,
> >>>>Mithlesh Thukral
>
> WBR, Sergei
>
> -------------------------------------------------------------------------
> Take Surveys. Earn Cash. Influence the Future of IT
> Join SourceForge.net's Techsay panel and you'll get the chance to share
> your opinions on IT & business topics through brief surveys-and earn cash
> http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
> _______________________________________________
> Kgdb-bugreport mailing list
> Kgdb-bugreport@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/kgdb-bugreport
