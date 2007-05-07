From: Michael-Luke Jones <mlj28@cam.ac.uk>
Subject: Re: [PATCH 3/3] Intel IXP4xx network drivers
Date: Mon, 7 May 2007 19:14:53 +0100
Message-ID: <86D26EBE-5899-468F-9C79-23E83E0DE04B@cam.ac.uk>
References: <m3abwhcy74.fsf@maximus.localdomain> <m3vef5biob.fsf@maximus.localdomain> <5BB7E1AB-5CE1-43C8-8CE3-E0DE0236BD09@cam.ac.uk> <m3hcqoa772.fsf@maximus.localdomain>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, Russell King <rmk@arm.linux.org.uk>,
	lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	ARM Linux Mailing List
	<linux-arm-kernel@lists.arm.linux.org.uk>,
	Lennert Buytenhek <buytenh@wantstofly.org>
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S966190AbXEGSSl@vger.kernel.org>
In-Reply-To: <m3hcqoa772.fsf@maximus.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[Added Lennert Buytenhek to CC list]

Hey again,

>> Code placement:
>> Queue Manager & NPE code => arch/arm/mach-ixp4xx
>> WAN driver code => drivers/net/wan
>> Eth code => drivers/net/arm
>
> Why would you want such placement?
> Potential problems: header files would have to be moved to
> include/asm-arm = headers pollution.

Headers for ixp4xx-specific hardware can surely live in the include/ 
asm-arm/arch-ixp4xx/ quite happily.

> All 4 drivers are, in fact, network (related) drivers.

Despite their name, Network Processing Engines are independent  
coprocessors which are only coincidentally attached to MACs for  
ethernet / WAN purposes. If Intel would allow us to compile code for  
these coprocessors, we could get them to do lots of things other than  
networking.

In fact, we already kind of can. Crypto is not networking, and if the  
kernel gains ixp4xx crypto support, that should be possible to enable  
independently of networking. They can also function as DMA engines,  
which should also be independent of networking functionality.

So, the NPE driver (which is basically ixp4xx specific) should be,  
for practical purposes, networking-code agnostic. As it is a lump of  
code talking to an architecture specific piece of hardware, it should  
live in arch/arm/ rather than arch-independent drivers/

(NB: the publically reviewed version of Christian's ixp4xx_net driver  
had exactly this file layout, see below)

>> Ethernet & HSS code should probably select NPE and QMGR (rather than
>> depend)
>
> Actually, that's exactly what this patch do.
>
>> but these options should still be exposed in arch/arm/mach-
>> ixp4xx/Kconfig

Sorry, unclear. That sentence was meant as a coherent whole -  
agreeing with you that the NPE dependency should use select but then  
pointing out that you should still be able to turn NPE support on in  
arch/arm/mach/ixp4xx/Kconfig even without selecting any of the  
network drivers.

> Why exactly? They are network devices, who would expect them there?
> How about the dependency mess (NET_ETHERNET etc.) that would be
> created?

For networking devices point, see above.

I don't fully understand the specifics, but Christian appeared to  
avoid any dependency mess in the publically reviewed version of his  
driver (as below).

As I understand it, functions to talk to the NPE should appear in the  
NPE driver. The NPE driver should then be called by ethernet/wan/ 
crypto/dma(?) drivers to carry out the specific firmware-dependent  
tasks. I haven't reviewed your code in detail, so I can't comment on  
whether this is what you actually do or not.

==Links to the review of Christian's driver==
[1/7] Register & NPE definitions:
http://lists.arm.linux.org.uk/pipermail/linux-arm-kernel/2007-January/ 
038082.html
[2/7] Platform devices (thought unnecessary by Lennert in his review):
http://lists.arm.linux.org.uk/pipermail/linux-arm-kernel/2007-January/ 
038086.html
[3/7] Stub for Data/Address-Coherent mode setup:
http://lists.arm.linux.org.uk/pipermail/linux-arm-kernel/2007-January/ 
038083.html
[4/7] QMGR driver:
http://lists.arm.linux.org.uk/pipermail/linux-arm-kernel/2007-January/ 
038278.html
[5/7] NPE driver:
http://lists.arm.linux.org.uk/pipermail/linux-arm-kernel/2007-January/ 
038085.html
[6/7] Ethernet driver:
http://lists.arm.linux.org.uk/pipermail/linux-arm-kernel/2007-January/ 
038087.html
[7/7] Documentation:
http://lists.arm.linux.org.uk/pipermail/linux-arm-kernel/2007-January/ 
038088.html

Sorry if I'm stating the obvious, but this is a public discussion and  
I want to make sure everyone who reads this can see what I mean. If  
they disagree with me despite this, so be it :)

Mike-Luke
