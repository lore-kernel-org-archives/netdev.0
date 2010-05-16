From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: bnx2/BCM5709: why 5 interrupts on a 4 core system
 (2.6.33.3)
Date: Sun, 16 May 2010 13:00:44 -0700
Message-ID: <C27F8246C663564A84BB7AB3439772421B7814753A@IRVEXCHCCR01.corp.ad.broadcom.com>
References: <4BF0465A.5030307@ans.pl>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "'Krzysztof Oledzki'" <ole@ans.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1726 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751664Ab0EPUAw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 May 2010 16:00:52 -0400
In-Reply-To: <4BF0465A.5030307@ans.pl>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Krzysztof Oledzki wrote:

> On 2010-05-16 20:51, Michael Chan wrote:
> > Krzysztof Oledzki wrote:
> >
> >>
> >> Why the driver registers 5 interrupts instead of 4? How to
> >> limit it to 4?
> >>
> >
> > The first vector (eth0-0) handles link interrupt and other slow
> > path events.  It also has an RX ring for non-IP packets that are
> > not hashed by the RSS hash.  The majority of the rx packets should
> > be hashed to the rx rings eth0-1 - eth0-4, so I would assign these
> > vectors to different CPUs.
>
> Thank you for your prompt response.
>
> In my case the first vector must be handling something more:
>  - "ping -f 192.168.0.1" increases interrupts on both eth1-0
> and eth1-4
>  - "ping -f 192.168.0.2" increases interrupts on both eth1-0
> and eth1-3
>  - "ping -f 192.168.0.3" increases interrupts on both eth1-0
> and eth1-1
>  - "ping -f 192.168.0.7" increases interrupts on both eth1-0
> and eth1-2
>
>             CPU0       CPU1       CPU2       CPU3
>   67:    1563979          0          0          0
> PCI-MSI-edge      eth1-0
>   68:    1072869          0          0          0
> PCI-MSI-edge      eth1-1
>   69:     137905          0          0          0
> PCI-MSI-edge      eth1-2
>   70:     259246          0          0          0
> PCI-MSI-edge      eth1-3
>   71:     760252          0          0          0
> PCI-MSI-edge      eth1-4
>
> As you can see, eth1-1 + eth1-2 + eth1-3 + eth1-4 ~= eth1-0.

I think that ICMP ping packets will always go to ring 0 (eth1-0)
because they are non-IP packets.  I need to double check tomorrow
on how exactly the hashing works on RX.  Can you try running IP
traffic?  IP packets should theoretically go to rings 1 - 4.

>
> So, it seems that TX or RX is always handled by the first vector.
> I'll try to find if it is TX or RX.
>
> BTW: I'm using .1Q vlans over bonding, does it change anything?

That should not matter, as the VLAN tag is stripped before hashing.


