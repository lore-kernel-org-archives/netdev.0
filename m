From: Arnaud Patard (Rtp) <arnaud.patard@rtp-net.org>
Subject: Re: [patch 2/2] Try to fix mvneta when compiled as module
Date: Mon, 24 Jun 2013 09:43:55 +0200
Message-ID: <87txko9cn8.fsf@lebrac.rtp-net.org>
References: <20130620220644.715387300@rtp-net.org>
	<20130620221008.551534830@rtp-net.org> <20130623100617.1457a2a8@skate>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Lior Amsalem <alior@marvell.com>,
	Gregory =?utf-8?Q?Cl=C3=A9ment?=
	<gregory.clement@free-electrons.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lebrac.rtp-net.org ([88.191.135.105]:37407 "EHLO
	lebrac.rtp-net.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752813Ab3FXHov (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 03:44:51 -0400
In-Reply-To: <20130623100617.1457a2a8@skate> (Thomas Petazzoni's message of
	"Sun, 23 Jun 2013 10:06:17 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thomas Petazzoni <thomas.petazzoni@free-electrons.com> writes:

> Dear Arnaud Patard (Rtp),
>
> On Fri, 21 Jun 2013 00:06:46 +0200, Arnaud Patard (Rtp) wrote:
>
>> This patch sets the "sgmii serdes configuration" register to a magical value
>> found in:
>> https://github.com/yellowback/ubuntu-precise-armadaxp/blob/master/arch/arm/mach-armadaxp/armada_xp_family/ctrlEnv/mvCtrlEnvLib.c
>
> According to the Armada XP functional datasheet, this magical value
> 0xCC7 is the one to be used to configure a SERDES interface to use the
> "Protocol Generation Setting" SGMII. There are other magical values for
> DRSGMII, SQGMII, SATA Gen I and SATA Gen II. So you could really do:
>
> #define    MVNETA_SGMII_SERDES_PROTO	0xcc7
>

ok.

>> With this change, the interrupts are working/generated and ethernet is
>> working.
>> 
>> Signed-off-by: Arnaud Patard <arnaud.patard@rtp-net.org>
>> 
>> Index: linux-next/drivers/net/ethernet/marvell/mvneta.c
>> ===================================================================
>> --- linux-next.orig/drivers/net/ethernet/marvell/mvneta.c	2013-06-20 23:39:37.485391949 +0200
>> +++ linux-next/drivers/net/ethernet/marvell/mvneta.c	2013-06-20 23:39:37.481391949 +0200
>> @@ -88,6 +88,8 @@
>>  #define      MVNETA_TX_IN_PRGRS                  BIT(1)
>>  #define      MVNETA_TX_FIFO_EMPTY                BIT(8)
>>  #define MVNETA_RX_MIN_FRAME_SIZE                 0x247c
>> +#define MVETH_SGMII_SERDES_CFG			 0x24A0
>> +#define MVETH_SGMII_SERDES_STAT			 0x24A4
>
> You are not using this last define in your patch. Please also use
> MVNETA_ prefix for those defines, like all the other ones.
>
> However, there is one thing that I am not understanding completely. The
> C code you pointed above seems to do the following:
>
> 	pRegAddr[3] = SGMII_SERDES_CFG_REG(sgmiiPort);
> 	pRegAddr[4] = SGMII_SERDES_STAT_REG(sgmiiPort);
> 	[..]
> 	pRegVal[3] = (pSerdesInfo->busSpeed & (1 << serdesLineNum)) != 0 ? 0x1547 : 0xCC7;
> 	pRegVal[4] = 0x7;
>
> So:
>
>  1) In some conditions, it will use the 0x1547 value in some cases, and
>     0xCC7 in the other ones. And interestingly, the datasheet doesn't
>     mention what the 0x1547 magical value is.

The problem I got was that I didn't understand how to 'translate' the
(1 << serdesLineNum) part, so I removed it. Moreover, dumping the
registers when everything built-in (aka 'working'), I read a value
corresponding to the 0xcc7 case but not the other one so it seemed to me
it was safer to not use the 0x1547 case.

>
>  2) It writes 0x7 to the SGMII_SERDES_STAT_REG register, but the
>     datasheet mentions this register as a read-only register.

weird. Can be remains of code for old tape outs or something wrong on
the doc, 'fixed' in some pdf about erratas.

Thanks,
Arnaud
