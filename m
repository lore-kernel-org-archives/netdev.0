From: Andy Fleming <afleming@freescale.com>
Subject: Re: RFC: au1000_etc.c phylib rewrite
Date: Thu, 4 May 2006 19:36:33 -0500
Message-ID: <87D75728-B63F-445C-A4F8-7DA3A2619459@freescale.com>
References: <5.1.0.14.2.20060501144633.025e4e20@205.166.54.3> <1146510542.16643.10.camel@localhost.localdomain> <1146510542.16643.10.camel@localhost.localdomain> <5.1.0.14.2.20060501144633.025e4e20@205.166.54.3> <5.1.0.14.2.20060502095256.01fd4210@205.166.54.3> <1146674056.31241.18.camel@localhost.localdomain>
Mime-Version: 1.0 (Apple Message framework v749.3)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mark Schank <mschank@dcbnet.com>, ppopov@embeddedalley.com,
	sshtylyov@ru.mvista.com, linux-mips@linux-mips.org,
	jgarzik@pobox.com, netdev@vger.kernel.org,
	Ralf Baechle <ralf@linux-mips.org>,
	"Robin H. Johnson" <robbat2@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:46810 "EHLO
	az33egw01.freescale.net") by vger.kernel.org with ESMTP
	id S1030313AbWEEAhK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 May 2006 20:37:10 -0400
In-Reply-To: <1146674056.31241.18.camel@localhost.localdomain>
To: Herbert Valerio Riedel <hvr@gnu.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On May 3, 2006, at 11:34, Herbert Valerio Riedel wrote:

> hello *
>
> On Tue, 2006-05-02 at 11:20 -0500, Mark Schank wrote:
>> At 08:23 AM 5/2/06 +0200, Herbert Valerio Riedel wrote:
>>> On Mon, 2006-05-01 at 15:09 -0500, Mark Schank wrote:
>>>> The Cogent CSB655 used the Broadcom Dual Phy.  They eventually  
>>>> redesigned
>>>> the board and switched to two single Broadcom phys, but they  
>>>> continued to
>>>> control both phys through MAC0, which is the actual purpose of the
>>> dual-phy
>>>> hack.  I am a user of the CSB655, so I sort of care.
>>>>
>>>> Will the new PHY framework allow a second PHY for a second MAC  
>>>> (MAC1) be
>>>> controlled from the first MAC's (MAC0) mdio interface?

That definitely isn't a problem (though it looks like you've probably  
figured that out).  The original user (gianfar) has a similar setup,  
where all 2-4 NICs use TSEC0's MII interface to control the PHYs.  It  
was actually one of the reasons for writing it in the first place--to  
more cleanly share that interface between several different device  
instances.

>>>
>>> should'nt be a problem (as opposed to the bosporus case... see  
>>> below)...
>>> I assume the phy-addresses on which the boarcom dual phy is  
>>> configured
>>> are the same for all Cogent CSB655 boards?
>>
>> Dual PHY configuration:
>>      MAC0 - phy addr 4
>>      MAC1 - phy addr 3
>> Single PHY configuration:
>>      MAC0 - phy addr 1
>>      MAC1 - phy addr 0
>
> while at it, does anyone happen to know what the phy-addr/MAC  
> assignment
> on the XXS1500 is?
>
>>> does this need to be autodetected dynamically at runtime, or can  
>>> we rely
>>> on a compile time Kconfig-conditional to set a static phy-addr<- 
>>> >eth%
>>> d-phy mapping for this board-specific case? Or de we really need  
>>> such a
>>> complex mii_probe() function to detect weird scenarios? :)
>>
>> The compile time Kconfig-conditional should be okay.  The driver  
>> need to
>> handle the fact that the MAC1's phy is controlled by MAC0's mdio
>> interface.  This means that MAC0 controller can not be disabled  
>> when the
>> associated eth% device is down, otherwise you lose the ability to  
>> control
>> MAC1's phy.
>
> ...or at least, the MAC associated with the particular MII bus  
> should be
> brought up if necessary before any mdio access (that's what I'm
> implementing right now)
>
> but one thing that seems strange to me; CONFIG_BCM5222_DUAL_PHY  
> doesn't
> seem to be defined anywhere; shouldn't that be at least defined in  
> some
> Kconfig file, especially if the XXS1550 board is supposed to make  
> use of
> it?
>
> btw, is the CSB655 supported at all in the 2.6 linux-mips branch, I
> couldn't find any mention of it in Kconfig files either?
>
>>> using static phy addr mappings would also allow for setting
>>> board-specific phy-irq assignments, which would then be handled  
>>> by the
>>> phylib facilities, instead of polling the status of phy with a  
>>> timer;
>>> (and in case we don't have any board-specific compile time  
>>> setting, we
>>> can still fall back to search the phy-addresses for a PHY at  
>>> runtime as
>>> the generic case)
>>
>> Will the phylib facilities handle the case where two phys share a  
>> single IRQ?
>
> afaics from the source, it doesn't handle the case of multiplexed phy
> notification irqs; although the interrupt is requested with the  
> SA_SHIRQ
> flag, the first phy-interrupt-handler to be called already returns
> IRQ_HANDLED... doesn't feel right in some way ;-)

The PHY layer does handle multiplexed interrupts (I've got boards  
with 4 PHYs sharing the same IRQ).  While I'm not sure returning  
IRQ_HANDLED is the perfect implementation, I'm not sure there are any  
options.  I've worked pretty hard to ensure that PHY transactions  
don't occur in interrupt context so that it's possible to implement a  
driver that has an interrupt signal the end of a transaction.  As  
such, reading the PHY interrupt status cannot happen in the interrupt  
handler, which means the interrupt handler doesn't have the ability  
to determine whether any particular invocation is handling the actual  
cause of the interrupt.

 From what I've seen of the interrupt code, this is only an issue if  
a spurious interrupt starts troubling the same line the PHY is  
using.  Does anyone disagree, or have some better suggestion for how  
to handle this?


