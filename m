From: Nils Holland <nholland@tisys.org>
Subject: Re: [bisected] tg3 broken in 3.18.0?
Date: Sat, 13 Dec 2014 22:02:51 +0100
Message-ID: <20141213210251.GA12812@teela.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-pci@vger.kernel.org,
	rajatxjain@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from celine.tisys.org ([85.25.117.166]:45541 "EHLO celine.tisys.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754347AbaLMVCz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Dec 2014 16:02:55 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rajatxjain@gmail.com
Bcc: 
Subject: Re: [bisected] tg3 broken in 3.18.0?
Reply-To: 
In-Reply-To: <20141212.201831.186234837340644301.davem@davemloft.net>

On Fri, Dec 12, 2014 at 08:18:31PM -0500, David Miller wrote:
> From: Nils Holland <nholland@tisys.org>
> Date: Sat, 13 Dec 2014 02:14:08 +0100
> 
> > 
> > My bisect exercise suggests that the following commit is the culprit:
> > 
> > 89665a6a71408796565bfd29cfa6a7877b17a667 (PCI: Check only the Vendor
> > ID to identify Configuration Request Retry)
> 
> You definitely need to bring this up with the author of that change
> and the relevent list for the PCI subsystem and/or linux-kernel.

I've now already sent an inquiry to Rajat Jain, the author of the
patch in question, and this message here is now also CC'd to
linux-pci@.

With this message, I'd like to add one last result of investigation
I've done today, in the hope that it will aid the folks with more
knowledge to go after the issue.

Basically, I've added a little debug output to tg3.c in the function
tg3_poll_fw(), as that function contained the code that would print
out the "No firmware running" line that was visible in dmesg on those
kernels where tg3 would not work for me. So, I basically had this:

static int tg3_poll_fw(struct tg3 *tp)
{
        int i;
        u32 val;

        netdev_info(tp->dev, "XX: Boom!\n");
        [...]
}

Now, I was looking through dmesg searching for occurances of this
debug output, using a standard 3.18.0 kernel (where my tg3 doesn't
work) as well as using a 3.18.0 kernel with
89665a6a71408796565bfd29cfa6a7877b17a667 reverted (where my tg3
works). Here's the results:

[standard 3.18.0 (=problematic)]:
[    2.197653] libphy: tg3 mdio bus: probed
[    2.257488] tg3 0000:02:00.0 eth0:
        Tigon3 [partno(BCM57780) rev 57780001] (PCI Express) MAC address
        00:19:99:ce:13:a6
[    2.259589] tg3 0000:02:00.0 eth0:
        attached PHY driver [Broadcom BCM57780] (mii_bus:phy_addr=200:01)
[    2.261740] tg3 0000:02:00.0 eth0:
        RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] TSOcap[1]
[    2.263912] tg3 0000:02:00.0 eth0:
        dma_rwctrl[76180000] dma_mask[64-bit]
[...]
[   10.028002] tg3 0000:02:00.0: irq 25 for MSI/MSI-X
[   10.028247] tg3 0000:02:00.0 enp2s0: XX: Boom!
[   12.157034] tg3 0000:02:00.0 enp2s0: No firmware running


[3.18.0 without above mentioned patch, 3.17.3 is the same, both result
in a working tg3]:
[    1.397167] libphy: tg3 mdio bus: probed
[    1.456473] tg3 0000:02:00.0
        (unnamed net_device) (uninitialized): XX: Boom!
[    1.464987] tg3 0000:02:00.0 eth0:
        Tigon3 [partno(BCM57780) rev 57780001] (PCI Express) MAC address
        00:19:99:ce:13:a6
[    1.467118] tg3 0000:02:00.0 eth0:
        attached PHY driver [Broadcom BCM57780] (mii_bus:phy_addr=200:01)
[    1.469311] tg3 0000:02:00.0 eth0:
        RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] TSOcap[1]
[    1.471500] tg3 0000:02:00.0 eth0:
        dma_rwctrl[76180000] dma_mask[64-bit]
[...]
[    9.631629] tg3 0000:02:00.0: irq 25 for MSI/MSI-X
[    9.631962] tg3 0000:02:00.0 enp2s0: XX: Boom!
[    9.634339] tg3 0000:02:00.0 enp2s0: XX: Boom!
[    9.642741] IPv6:
        ADDRCONF(NETDEV_UP): enp2s0: link is not ready
[   10.479636] tg3 0000:02:00.0
        enp2s0: Link is down
[   11.484498] tg3 0000:02:00.0
        enp2s0: Link is up at 100 Mbps, full duplex

As can be seen, there are two tg3-related sections in my dmesg in both
the working and non-working scenarios: At about 1 - 2 secs, the card
seems to begin initializing, and at about 9 - 10 seconds it is (or
should be) ready to establish a network connection.

My debug section, or tg3.c's tg3_poll_fw(), seems to be called thrice
in the working situation: The first hit occurs at 1.456473 where the tg3
device is still reported as "(unnamed net_device) (uninitialized)".
Then, the section gets hit twice again at around 9.63 - at this point
the driver already reports the card as initialized / by its real name.

In the non-working situation, the debug sections seems to be hit only
once, at 10.028247. At this point, the tg3 is already reported as
initialized - just like when it's hit the second and third time in the
working situation.

Bottom line is that commit 89665a6a71408796565bfd29cfa6a7877b17a667
really makes a difference regarding the way the tg3 card is
initialized, which seems to cause the problem.

Greetings,
Nils
