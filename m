From: Brian Haley <brian.haley@hp.com>
Subject: Re: BNX2: Kernel crashes with 2.6.31 and 2.6.31.9
Date: Thu, 11 Mar 2010 14:40:04 -0500
Message-ID: <4B994714.2040108@hp.com>
References: <1268263973.9775.95.camel@nseg_linux_HP1.broadcom.com> <4B9850DC.9060703@hp.com> <1268329796.9775.125.camel@nseg_linux_HP1.broadcom.com> <20100311.100519.124285161.davem@davemloft.net> <1268332738.9775.133.camel@nseg_linux_HP1.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"bonbons@linux-vserver.org" <bonbons@linux-vserver.org>,
	Benjamin Li <benli@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1268332738.9775.133.camel@nseg_linux_HP1.broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Chan wrote:
> On Thu, 2010-03-11 at 10:05 -0800, David Miller wrote:
>> From: "Michael Chan" <mchan@broadcom.com>
>> Date: Thu, 11 Mar 2010 09:49:56 -0800
>>
>>> On Wed, 2010-03-10 at 18:09 -0800, Brian Haley wrote:
>>>>>> I'm able to cause a netdev_watchdog timeout by changing the coalesce
>>>>>> settings on my bnx2, I built a little test program for it:
>>>>> Do you run this program in a loop?  How quickly do you see the NETDEV
>>>>> WATCHDOG?
>>>> It's run once, and we see it almost immediately after ETHTOOL_SCOALESCE.
>>> What's the difference between running the test program and doing ethtool
>>> -C?  Do you see the issue in either case?  I don't see the issue here
>>> with ethtool -C.
>> Probably because the independent program runs faster and thus
>> can trigger races more easily.

A customer provided some test code that triggered this hang, so
I've just been using it.  I just used ethtool and it happened too:

# ethtool -C eth0 rx-usecs 0 rx-frames 1 rx-usecs-irq 0 rx-frames-irq 1

If the interface is down, no problem.

> That's what I thought, I thought he was running it in a loop and
> triggering some race condition.  But he said he only ran it once.  His
> program gets the coalesce settings, sleeps for 5 seconds, and then sets
> the coalesce settings.

The 5 seconds was there only because this was a snippet from a larger
function that was doing a lot of ETHTOOL ioctl()'s, and I wanted to
wait between each call to see which was causing this.  Removing the
sleep() still triggers the watchdog.

>> In any case, you should be trying to reproduce his problem with
>> his test program since he went through the effort of providing
>> one.
> 
> I just tried it and cannot reproduce the problem.
> 
> Brian, please provide more information.  Thanks.

I can only reproduce this on one system out of many, so it's either a
race condition or bad hardware.  The only thing I can confirm at the
moment is that it's the code at the bottom of bnx2_set_coalesce()
that's causing it, I'm trying to go through all those codepaths now.

# lspci -vv -s 04:00
04:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM5708 Gigabit Ethernet (rev 12)
	Subsystem: Hewlett-Packard Company NC373i Integrated Multifunction Gigabit Server Adapter
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr+ Stepping- SERR+ FastB2B- DisINTx+
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 64 (16000ns min), Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 65
	Region 0: Memory at f6000000 (64-bit, non-prefetchable) [size=32M]
	[virtual] Expansion ROM at d0200000 [disabled] [size=2K]
	Capabilities: [40] PCI-X non-bridge device
		Command: DPERE- ERO- RBC=512 OST=8
		Status: Dev=04:00.0 64bit+ 133MHz+ SCD- USC- DC=simple DMMRBC=512 DMOST=8 DMCRS=32 RSCEM- 266MHz- 533MHz-
	Capabilities: [48] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=1 PME-
	Capabilities: [50] Vital Product Data <?>
	Capabilities: [58] Message Signalled Interrupts: Mask- 64bit+ Queue=0/0 Enable+
		Address: 00000000fee0100c  Data: 4182
	Kernel driver in use: bnx2
	Kernel modules: bnx2

# ethtool -i eth0
driver: bnx2
version: 2.0.2
firmware-version: 1.9.6
bus-info: 0000:04:00.0

What other info would help?

-Brian
