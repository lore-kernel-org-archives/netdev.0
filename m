From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [Kgdb-bugreport] [PATCH 2.6.20-rc7] 8139too KGDBoE fix
Date: Fri, 23 Feb 2007 11:04:51 -0800
Message-ID: <20070223110451.44066f09@freekitty>
References: <200701312144.56497.sshtylyov@ru.mvista.com>
	<45DDBD96.10000@ru.mvista.com>
	<45DDC7C0.8050100@ru.mvista.com>
	<200702231238.40474.amitkale@linsyssoft.com>
	<45DF2E20.305@mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Amit S. Kale" <amitkale@linsyssoft.com>, netdev@vger.kernel.org,
	Sergei Shtylyov <sshtylyov@ru.mvista.com>,
	Mithlesh Thukral <mithlesh@linsyssoft.com>,
	Vitaly Wool <vwool@ru.mvista.com>
To: Mark Huth <mhuth@mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:53851 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933177AbXBWTFZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Feb 2007 14:05:25 -0500
In-Reply-To: <45DF2E20.305@mvista.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 23 Feb 2007 11:10:40 -0700
Mark Huth <mhuth@mvista.com> wrote:

> Amit S. Kale wrote:
> > Hi Net Gurus,
> >
> > This thread came up on kgdb-bugreport mailing list. Could you please suggest 
> > us what's the correct way of fixing this problem?
> >
> > 1. When running a kgdb on RTL8139 ethernet interface: 8139too driver prints 
> > too many "Out-of-sync dirty pointer" messages on console and gdb can't 
> > connect to kgdb stub. These messages can be suppressed, though it still 
> > results in connection failures frequently. 
> >   
> We think this comes from calling the driver while the queue is stopped.  
> Drivers should not do horrible things when hard start is called with the 
> queue stopped, but unfortunately, at this time, at least some drivers 
> do  explode or complain under that condition.

The kernel is built on a set of assumptions about calling context. Your
out of tree code is violating one of them. Why not check for stopped queue
and do some action to try and clear it, that is what netconsole does.

> > 2. Here is how kgdb uses polling mechanism for communication to gdb.  kgdb 
> > calls netpoll_set_trap(1) just before entering a loop where it communicates 
> > to gdb. It calls netpoll_set_trap(0) after it is done and wants to resume a 
> > kernel. The communication to gdb goes through netpoll_poll (which calls kgdb 
> > rx_hook) and netpoll_send_udp functions.
> >
> > 3. A queue for an interface may have been stopped by it's driver by calling 
> > netif_stop_queue. After this if kgdb attempts to enter communication with 
> > gdb, it'll call netpoll_set_trap(1), after which the queue can't be started 
> > again. This is a potential deadlock situation. Is there a way out of this?
> >   
> We are trying without setting the CONFIG_NETPOLL_TRAP option.  This 
> option is what turns off the function of the netif_stop/wake_queue 
> calls, which breaks the usual flow control mechanism used by netpoll 
> transmit function.  It also prevents the netif_schedule call, which will 
> puts the device on the tx softirq queue.  However, in the case where 
> interupts are off and scheduling is not allowed - which would be the 
> netpoll_set_trap(1) condition, the softirq will not run until netpoll is 
> done and the user of netpoll returns the system to normal operation.  So 
> I am unclear that allowing the schedule is a problem.  There may be some 
> obscure race conditions on smp, so we are trying to analyze that part, 
> but for the moment are testing with the netif_schedule call allowed in 
> the event of queuing the device.
> > 4. Is it necessary to call netpoll_set_trap(1) at all before entering gdb 
> > communication loop? Even if a driver stops the queue in middle of the 
> > communication netpoll_poll and netpoll_send_udp calls can recover from that 
> > by calling driver's interrupt and poll routines. Is this a valid statement?
> >   
> netpoll_set_trap() is necessary, as it informs the netpoll code to 
> respond to arp requests on behalf of the netpoll user, as well as making 
> sure that skbs are freed without needing the completion queue stuff to 
> run (I think)
> > Thanks a lot.
> > -Amit


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
