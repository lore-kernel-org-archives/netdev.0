From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [RFC PATCH] bnx2x: fix tx queue locking and memory barriers
Date: Thu, 25 Feb 2010 17:16:54 +0100
Message-ID: <20100225171654.3cdeb854@dhcp-lab-109.englab.brq.redhat.com>
References: <20100225164015.3991ab5e@dhcp-lab-109.englab.brq.redhat.com>
	<8628FE4E7912BF47A96AE7DD7BAC0AADCB46A2ADC5@SJEXCHCCR02.corp.ad.broadcom.com>
	<20100225170308.6294aa1a@dhcp-lab-109.englab.brq.redhat.com>
	<20100225.080624.203625652.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: vladz@broadcom.com, netdev@vger.kernel.org, eilong@broadcom.com,
	dhowells@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1208 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932831Ab0BYQPU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Feb 2010 11:15:20 -0500
In-Reply-To: <20100225.080624.203625652.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 25 Feb 2010 08:06:24 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> > If I understand correctly what is written in Documentation/memory-barriers.txt
> > this smp_mb() need to have another "paired" smp_{w}mb() on cpu0 to make value
> > be updated on cpu1, which is missing.
> 
> The invocation of ->hard_start_xmit() creates an implicit memory
> barrier because all such invocations take the netdev spinlock.

But barrier is missing on cpu which call bnx2x_pull(), how spinlock
before bnx2x_start_xmit() helps with that? Below again the whole
picture:

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
