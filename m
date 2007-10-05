From: Matt Mackall <mpm@selenic.com>
Subject: Re: netconsole problems
Date: Thu, 4 Oct 2007 19:27:54 -0500
Message-ID: <20071005002754.GH19691@waste.org>
References: <47052A0A.2080100@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Tina Yang <tina.yang@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([66.93.16.53]:35930 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755266AbXJEA3O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Oct 2007 20:29:14 -0400
Content-Disposition: inline
In-Reply-To: <47052A0A.2080100@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 04, 2007 at 10:59:38AM -0700, Tina Yang wrote:
> We recently run into a few problems with netconsole
> in at least 2.6.9, 2.6.18 and 2.6.23.  It either panicked
> at netdevice.h:890 or hung the system, and sometimes depending
> on which NIC we are using, the following console message,
> e1000:
>      "e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang"
> tg3:
>      "NETDEV WATCHDOG: eth4: transmit timed out"
>      "tg3: eth4: transmit timed out, resetting"
> 
> The postmortem vmcore analysis indicated race between normal
> network stack (net_rx_action) and netpoll, and disabling the
> following code segment cures all the problems.

That doesn't tell us much. Can you provide any more details? Like the
call chains on both sides?
 
> netpoll.c
>    178         /* Process pending work on NIC */
>    179         np->dev->poll_controller(np->dev);
>    180         if (np->dev->poll)
>    181                 poll_napi(np);

There are a couple different places this gets called, and for
different reasons. If we have a -large- netconsole dump (like
sysrq-t), we'll swallow up all of our SKB pool and may get stuck waiting
for the NIC to send them (because it's waiting to hand packets back to
the kernel and has no free buffers for outgoing packets).

> Big or small, there seems to be several race windows in the code,
> and fixing them probably has consequence on overall system performance.

Yes, the networking layer goes to great lengths to avoid having any
locking in its fast paths and we don't want to undo any of that
effort.

> Maybe this code should only run when the machine is single-threaded ?

In the not-very-distant future, such machines will be extremely rare.

-- 
Mathematics is the supreme nostalgia of our time.
