From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: RE: [RFC PATCH] bnx2x: fix tx queue locking and memory barriers
Date: Thu, 25 Feb 2010 07:49:48 -0800
Message-ID: <8628FE4E7912BF47A96AE7DD7BAC0AADCB46A2ADC5@SJEXCHCCR02.corp.ad.broadcom.com>
References: <20100225140834.0169e9f2@dhcp-lab-109.englab.brq.redhat.com>
 <20100225.021822.66777947.davem@davemloft.net>
 <20100225164015.3991ab5e@dhcp-lab-109.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"dhowells@redhat.com" <dhowells@redhat.com>
To: "Stanislaw Gruszka" <sgruszka@redhat.com>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1938 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759037Ab0BYPuB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2010 10:50:01 -0500
In-Reply-To: <20100225164015.3991ab5e@dhcp-lab-109.englab.brq.redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In bnx2x_start_xmit(): right after the "stop queue" there is an smp_mb(), which will bring the cpu0 cache and a fresh fp->tx_bd_cons value to cpu1 and the following if() will return true and the queue will be released from bnx2x_start_xmit() flow.

No deadlock here.

vlad

> -----Original Message-----
> From: Stanislaw Gruszka [mailto:sgruszka@redhat.com] 
> Sent: Thursday, February 25, 2010 5:40 PM
> To: David Miller
> Cc: netdev@vger.kernel.org; Vladislav Zolotarov; Eilon 
> Greenstein; dhowells@redhat.com
> Subject: Re: [RFC PATCH] bnx2x: fix tx queue locking and 
> memory barriers
> 
> On Thu, 25 Feb 2010 02:18:22 -0800 (PST)
> David Miller <davem@davemloft.net> wrote:
> 
> > > Memory barriers here IMHO, prevent to make queue 
> permanently stopped
> > > when on one cpu bnx2x_tx_int() make queue empty, whereas on other
> > > cpu bnx2x_start_xmit() see it full and make stop it, such cause
> > > queue will be stopped forever.
> > 
> > Instead of having an opinion, please show the exact sequence
> > of events that can lead to this situation.  With such facts
> > inhand, you will have no need for an opinion :-)
> 
> Ok, here is the story:
> 
> Queue (4000 elements) is almost full: fp->tx_bd_prod = 3980, 
> fp->tx_bd_cons = 0,
> Packets ware already transmitted by device, but that was not 
> reported to
> the driver because interrupts where disabled. We are 
> transmitting new skb
> with 20 fragments.
> 
> cpu0: (in bnx2x_poll)                   cpu1: (transferring data)
> 
> bnx2x_tx_int():                         bnx2x_start_xmit():
> local fp->tx_bd_cons = 3980;            send more data to device
> return
> 
> bnx2x_tx_int():                         local fp->tx_bd_prod = 4000
> local fp->tx_bd_cons = 4000;            local fp->tx_bd_cons still 0
> queue not stopped                       no avail space in queue
> return;                                 stop queue
>                                         smp_mb() - not 
> paired, cpu1 does not "see" cpu0 caches changes
>                                         local fp->tx_bd_cons still 0
>                                         no wake
> 					
> Finally queue is sopped and device will not generate interrupt nor
> call bnx2x_tx_int() from bnx2x_poll() since bnx2x_has_tx_work() will
> return false.
> 
> 
