From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: PATCH 2.6.17-rc5 tulip free_irq() called too late
Date: Thu, 08 Jun 2006 10:43:04 -0400
Message-ID: <44883778.8000209@pobox.com>
References: <20060531195234.GA4967@colo.lackof.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Val Henson <val.henson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:51403 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S964846AbWFHOnJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2006 10:43:09 -0400
To: Grant Grundler <grundler@parisc-linux.org>,
	Andrew Morton <akpm@osdl.org>
In-Reply-To: <20060531195234.GA4967@colo.lackof.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


(CC'ing our newly minted tulip maintainer, Val)

Grant Grundler wrote:
> Jeff,
> SLES10 testing exposed an MCA that was confirmed to be a DMA IO TLB miss.
> This means tulip device was attempting to DMA to memory that was already
> unmapped. The test was crashing in the "ifconfig down" step when a 4-port
> tulip card was under this work load:
> 
> while :
> do
> 	ifconfig eth24 up
> 	ifconfig eth25 up
> 	ifconfig eth26 up
> 	ifconfig eth27 up
>         # Pound both interfaces with ethtool
>         for i in `seq 1000`
>         do
>                 ethtool eth24 &>/dev/null
>                 ethtool eth25 &>/dev/null
>                 ethtool eth26 &>/dev/null
>                 ethtool eth27 &>/dev/null
>         done
> 
> 	# Bring interfaces down
>         echo ifconfig $nic1 down
>         ifconfig eth24 down
>         ifconfig eth25 down
>         ifconfig eth26 down
>         ifconfig eth27 down
> 
>         sleep 5
> done
> 
> 
> [ And yes, I know tulip doesn't support ethtool. Don't ask.
>   It's still a sore point at the moment. Just consider it 
>   a delay loop or use "sleep 5" instead. ]
> 
> The real "network load" comes from another box(en) running 4 instances
> of "ping -f -s 1450 192.168.x.y" where "x.y" is the subnet/IP of eth24-27.
> The parisc and ia64 machines will crash in minutes.
> 
> I believe the problem is a race condition between an interrupt coming
> in and the tulip_down() code path. Moving the "free_irq()" to before
> tulip_down() call fixes the problem. I've been able to run the above
> test for several hours now.

NAK.  This is a band-aid, and one that creates new problems even as it 
attempts to solve problems.

Calling free_irq() while the chip is still active is just a bad idea, 
because the chip could raise an interrupt, creating a 
screaming-interrupts situation.  Consider especially the case of shared 
interrupts here, as a concrete example of how this won't work.

Perhaps cp_close() in 8139cp.c could be an example of a good ordering? 
It stops the chip, syncs irqs, frees irq, then frees [thus unmapping] 
the rings.

	Jeff




