From: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Subject: Re: [Kgdb-bugreport] [PATCH 2.6.20-rc7] 8139too KGDBoE fix
Date: Wed, 14 Mar 2007 16:42:32 +0300
Message-ID: <45F7FBC8.9050700@ru.mvista.com>
References: <200701312144.56497.sshtylyov@ru.mvista.com> <45DDBD96.10000@ru.mvista.com> <45DDC7C0.8050100@ru.mvista.com> <200702231238.40474.amitkale@linsyssoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Mithlesh Thukral <mithlesh@linsyssoft.com>,
	Vitaly Wool <vwool@ru.mvista.com>, Mark Huth <mhuth@mvista.com>
To: "Amit S. Kale" <amitkale@linsyssoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway-1237.mvista.com ([63.81.120.155]:15874 "EHLO
	imap.sh.mvista.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S933094AbXCNNmw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Mar 2007 09:42:52 -0400
In-Reply-To: <200702231238.40474.amitkale@linsyssoft.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

Amit S. Kale wrote:

> This thread came up on kgdb-bugreport mailing list. Could you please suggest 
> us what's the correct way of fixing this problem?

> 1. When running a kgdb on RTL8139 ethernet interface: 8139too driver prints 
> too many "Out-of-sync dirty pointer" messages on console and gdb can't 
> connect to kgdb stub. These messages can be suppressed, though it still 
> results in connection failures frequently. 

> 2. Here is how kgdb uses polling mechanism for communication to gdb.  kgdb 
> calls netpoll_set_trap(1) just before entering a loop where it communicates 
> to gdb. It calls netpoll_set_trap(0) after it is done and wants to resume a 
> kernel. The communication to gdb goes through netpoll_poll (which calls kgdb 
> rx_hook) and netpoll_send_udp functions.

> 3. A queue for an interface may have been stopped by it's driver by calling 
> netif_stop_queue. After this if kgdb attempts to enter communication with 
> gdb, it'll call netpoll_set_trap(1), after which the queue can't be started 
> again. This is a potential deadlock situation. Is there a way out of this?

> 4. Is it necessary to call netpoll_set_trap(1) at all before entering gdb 
> communication loop? Even if a driver stops the queue in middle of the 
> communication netpoll_poll and netpoll_send_udp calls can recover from that 
> by calling driver's interrupt and poll routines. Is this a valid statement?

    I'd like to return to this again (having received no feedback)...
    The idea is to change how CONFIG_NETPOLL_TRAP is implemented: instead of
completely bypassing queue locking after netpoll_set_trap(1) has been called, 
how about we set and chack some other flag (internal to netpoll) telling it 
that the queue is frozen, i.e. watch the queue state using a separate 
mechanism when traffic trapping is engaged?  This certainly would avoid TX 
queue overflows in drivers while also avoiding any dev->state changes and even 
worse evil __netif_schedule() call, i.e. things that CONFIG_NETPOLL_TRAP is 
currectly trying to avoid, AFAIU...

> Thanks a lot.
> -Amit

WBR, Sergei
