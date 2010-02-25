From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [RFC PATCH] bnx2x: fix tx queue locking and memory barriers
Date: Thu, 25 Feb 2010 16:40:15 +0100
Message-ID: <20100225164015.3991ab5e@dhcp-lab-109.englab.brq.redhat.com>
References: <20100225140834.0169e9f2@dhcp-lab-109.englab.brq.redhat.com>
	<20100225.021822.66777947.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vladz@broadcom.com, eilong@broadcom.com,
	dhowells@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63318 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759190Ab0BYPik (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Feb 2010 10:38:40 -0500
In-Reply-To: <20100225.021822.66777947.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 25 Feb 2010 02:18:22 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> > Memory barriers here IMHO, prevent to make queue permanently stopped
> > when on one cpu bnx2x_tx_int() make queue empty, whereas on other
> > cpu bnx2x_start_xmit() see it full and make stop it, such cause
> > queue will be stopped forever.
> 
> Instead of having an opinion, please show the exact sequence
> of events that can lead to this situation.  With such facts
> inhand, you will have no need for an opinion :-)

Ok, here is the story:

Queue (4000 elements) is almost full: fp->tx_bd_prod = 3980, fp->tx_bd_cons = 0,
Packets ware already transmitted by device, but that was not reported to
the driver because interrupts where disabled. We are transmitting new skb
with 20 fragments.

cpu0: (in bnx2x_poll)                   cpu1: (transferring data)

bnx2x_tx_int():                         bnx2x_start_xmit():
local fp->tx_bd_cons = 3980;            send more data to device
return

bnx2x_tx_int():                         local fp->tx_bd_prod = 4000
local fp->tx_bd_cons = 4000;            local fp->tx_bd_cons still 0
queue not stopped                       no avail space in queue
return;                                 stop queue
                                        smp_mb() - not paired, cpu1 does not "see" cpu0 caches changes
                                        local fp->tx_bd_cons still 0
                                        no wake
					
Finally queue is sopped and device will not generate interrupt nor
call bnx2x_tx_int() from bnx2x_poll() since bnx2x_has_tx_work() will
return false.
