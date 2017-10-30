From: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
Subject: Re: [RFC net-next 0/4] net: phy: PHY_HALTED, the return of the state
Date: Mon, 30 Oct 2017 16:44:16 +0100
Message-ID: <75de8a99-9d4f-03b8-a2f7-10d1b89b937f@sigmadesigns.com>
References: <20171025232124.14120-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Andrew Lunn <andrew@lunn.ch>,
        <opendmb@gmail.com>, <slash.tmp@free.fr>, <david.daney@cavium.com>,
        <geert+renesas@glider.be>, Mans Rullgard <mans@mansr.com>,
        Thibaud Cornic <thibaud_cornic@sigmadesigns.com>
To: Florian Fainelli <f.fainelli@gmail.com>,
        netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from us-smtp-delivery-107.mimecast.com ([216.205.24.107]:55062 "EHLO
        us-smtp-delivery-107.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752005AbdJ3Po1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 11:44:27 -0400
In-Reply-To: <20171025232124.14120-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26/10/2017 01:21, Florian Fainelli wrote:

> This patch series tries to address the shortcomings of the previously and then
> quickly reverted commit 7ad813f208533cebfcc32d3d7474dc1677d1b09a ("net: phy:
> Correctly process PHY_HALTED in phy_stop_machine()")
> 
> This time, the empire returns and strikes back with a few additional changes:
> 
> - catch phy_disconnect() calls without prior phy_stop() and warn when that
>   happens since that means a driver is not behaving properly. This is AFAIR
>   the case in which David Daney ran into
> 
> - what David also was running into is that when the PHY state machine was
>   already in PHY_HALTED, its synchronous call in phy_disconnect() would make
>   us re-schedule ourselves at the end. This is unnecessary, and we now take
>   care of that
> 
> - finally, Geert experienced bus errors on smsc911x for a number of reasons,
>   but the primary one is that the driver does not do any management of the
>   PHY state machine during suspend/resume. The last patch corrects that, and
>   also suggests that the driver should be fixed to properly support Wake-on-LAN
>   configuration to possibly suspend the PHY.
> 
> David, Marc and Geert, I would appreciate if you could give this patch series
> a spin on your respective HW and confirm that the desired functionality is
> achieved.

Hello Florian,

Thanks for taking a fresh look at this viper's nest :-)

I applied the patch series on top of v4.14-rc7, and my board had the expected
Ethernet functionality.

The "link down" notification does appear on the console shortly after issuing
the "ip link set eth0 down" command.

A one-minute iperf3 default run shows no particular issue.


I've had something in the back of my mind for a few weeks now: it seems like most
drivers try to disable the Ethernet hardware, and reclaim the packet descriptors,
when the ndo_stop() callback is invoked.

What happens when the HW does not support such a feature?

Case in point, the HW engineer responsible for integrating the Aurora IP told me
that it does not support disabling RX DMA. His exact words are:

> Once a descriptor chain is set by the software, the hardware will use
> them whenever a packet is received. There is no way to reclaim the
> buffers unless you reset the hardware.

So basically, the nb8800_dma_stop() function is a big hack, trying to disable
RX DMA, despite this being unsupported.

If I understand correctly, this is what we should do instead:

* When ndo_stop() is invoked, turn the Ethernet block off.
* Wait for the dust to settle.
* At this point, it should be safe to free the packet descriptors.
* As Mans pointed out, we would need to save the state of the HW block,
since turning it off discards context.

Regards.
