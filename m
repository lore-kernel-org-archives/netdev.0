From: Yan Seiner <yan@seiner.com>
Subject: Re: mcp55 forcedeth woes
Date: Wed, 15 Apr 2009 06:54:45 -0700
Message-ID: <49E5E725.2040400@seiner.com>
References: <e3e0f4f0ca9fdce35c24b30559d10f31.squirrel@www.datavault.us> <20090413164548.f241ec1e.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Ayaz Abdulla <aabdulla@nvidia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from flatoutfitness.com ([66.178.130.209]:41841 "EHLO seiner.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752151AbZDONyt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Apr 2009 09:54:49 -0400
In-Reply-To: <20090413164548.f241ec1e.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote:
> (suitable cc's added)
>
> On Mon, 13 Apr 2009 15:13:05 -0700 (PDT)
> "Yan Seiner" <yan@seiner.com> wrote:
>
>   
>> I have a few Asus M2N-SLI deluxe mobos.  These mobos have the MCP55
>> chipset and two 1gb ethernet ports.  Occasionally, and for no reason that
>> I can figure out, these ports will die.  There are various ways to try and
>> fix these; they seem to be about 50% effective, and approach something
>> akin to voodoo.
>>
>> Based on this discussion here:
>>
>> http://patchwork.kernel.org/patch/16212/
>>
>> I've gotten the ability to turn the ports on and off somewhat.
>>
>> For port 0,
>>
>> ethtool -s eth0 autoneg off speed 10 duplex full
>>
>> turns on the link, and gets me half-duplex, 10mb/sec. Not much, granted.
>>
>> ethtool -s eth0 autoneg off speed 100 duplex full
>>
>> causes the link to go up and down on about a 2 second cycle.
>>
>> ethtool -s eth0 autoneg on
>>
>> causes the link to drop.
>>
>> For port 1, the behavior is similar, except that I can get a stable 100
>> mbit connection.
>>
>> So the problem is in the autoneg code. It's a driver issue as this is
>> reported widely to work under windows of various flavors.
>>
>> I'm running 2.6.29.1; I'm ok with patching and building kernels, but I'm
>> not a kernel hacker.
>>
>> What, if anything, can I provide and do to fix this?
>>
>>     
>
>
>   
I've been reading the forcedeth.c code. 

So far I've established that it does recognize the Marvell PHY.  AFAIK, 
the PHY on the board is 88E1116, so that much is right.  OK, not much 
progress.

In nv_probe, there are some lines that should turn on the PHY.  I stuck 
some printk in there to see what's happening.  Turns out nothing is 
happening.....  powerstate remains 0?  Does this mean that the power is 
already on?  Or that we're reading/writing the wrong register?

    if (id->driver_data & DEV_HAS_POWER_CNTRL) {

        /* take phy and nic out of low power mode */
        powerstate = readl(base + NvRegPowerState2);
        printk(KERN_INFO "Turning on power: 0x%04x.\n",powerstate);
        powerstate &= ~NVREG_POWERSTATE2_POWERUP_MASK;
        if ((id->device == PCI_DEVICE_ID_NVIDIA_NVENET_12 ||
             id->device == PCI_DEVICE_ID_NVIDIA_NVENET_13) &&
            pci_dev->revision >= 0xA3)
            powerstate |= NVREG_POWERSTATE2_POWERUP_REV_A3;
        printk(KERN_INFO "Writing powerstate: 0x%04x.\n",powerstate);
        writel(powerstate, base + NvRegPowerState2);
        powerstate = readl(base + NvRegPowerState2);
        printk(KERN_INFO "Powerstate 0x%04x.\n",powerstate);
    }

[ 3936.277196] forcedeth: Reverse Engineered nForce ethernet driver. 
Version 0.64.
[ 3936.277223] forcedeth 0000:00:08.0: PCI INT A -> Link[APCH] -> GSI 22 
(level, low) -> IRQ 22
[ 3936.277230] forcedeth 0000:00:08.0: setting latency timer to 64
[ 3936.277331] nv_probe: set workaround bit for reversed mac addr
[ 3936.277337] Turning on power: 0x0000.
[ 3936.277339] Writing powerstate: 0x0000.
[ 3936.277343] Powerstate 0x0000.
[ 3936.278352] 0000:00:08.0: open: Found PHY 5040:0003 at address 19.
[ 3936.796061] 0000:00:08.0: phy reset
[ 3937.316809] forcedeth 0000:00:08.0: ifname eth0, PHY OUI 0x5043 @ 19, 
addr 00:1e:8c:6f:a5:27
[ 3937.316816] forcedeth 0000:00:08.0: highdma csum vlan pwrctl mgmt 
gbit lnktim msi desc-v3
[ 3937.317113] forcedeth 0000:00:09.0: PCI INT A -> Link[AMC1] -> GSI 20 
(level, low) -> IRQ 20
[ 3937.317120] forcedeth 0000:00:09.0: setting latency timer to 64
[ 3937.317200] nv_probe: set workaround bit for reversed mac addr
[ 3937.317206] Turning on power: 0x0000.
[ 3937.317209] Writing powerstate: 0x0000.
[ 3937.317213] Powerstate 0x0000.
[ 3937.318317] 0000:00:09.0: open: Found PHY 5040:0003 at address 19.
[ 3937.379044] forcedeth 0000:00:08.0: irq 29 for MSI/MSI-X
[ 3937.379236] eth0: no link during initialization.
[ 3937.836062] 0000:00:09.0: phy reset
[ 3938.356857] forcedeth 0000:00:09.0: ifname eth1, PHY OUI 0x5043 @ 19, 
addr 00:1e:8c:6f:be:40
[ 3938.356864] forcedeth 0000:00:09.0: highdma csum vlan pwrctl mgmt 
gbit lnktim msi desc-v3
[ 3938.417202] forcedeth 0000:00:09.0: irq 30 for MSI/MSI-X
[ 3938.417396] eth1: no link during initialization.

(this is getting more urgent; I rebooted the machine and lost both 
network ports.  Instead of dual-gigabit I'm running off an ancient PCI 
card.  I'm willing to test/build/debug, but I need some input from those 
who understand the forcedeth code....)

-- 
Yan Seiner 

Support my bid for the 4J School Board.
Visit http://www.seiner.com/schoolboard


