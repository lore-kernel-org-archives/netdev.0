From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [patch 2/2] Try to fix mvneta when compiled as module
Date: Sun, 23 Jun 2013 10:06:17 +0200
Message-ID: <20130623100617.1457a2a8@skate>
References: <20130620220644.715387300@rtp-net.org>
	<20130620221008.551534830@rtp-net.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Lior Amsalem <alior@marvell.com>,
	Gregory =?UTF-8?B?Q2zDqW1lbnQ=?=
	<gregory.clement@free-electrons.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: Arnaud Patard (Rtp) <arnaud.patard@rtp-net.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([94.23.35.102]:60337 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750877Ab3FWIGU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Jun 2013 04:06:20 -0400
In-Reply-To: <20130620221008.551534830@rtp-net.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Arnaud Patard (Rtp),

On Fri, 21 Jun 2013 00:06:46 +0200, Arnaud Patard (Rtp) wrote:

> This patch sets the "sgmii serdes configuration" register to a magical value
> found in:
> https://github.com/yellowback/ubuntu-precise-armadaxp/blob/master/arch/arm/mach-armadaxp/armada_xp_family/ctrlEnv/mvCtrlEnvLib.c

According to the Armada XP functional datasheet, this magical value
0xCC7 is the one to be used to configure a SERDES interface to use the
"Protocol Generation Setting" SGMII. There are other magical values for
DRSGMII, SQGMII, SATA Gen I and SATA Gen II. So you could really do:

#define    MVNETA_SGMII_SERDES_PROTO	0xcc7

> With this change, the interrupts are working/generated and ethernet is
> working.
> 
> Signed-off-by: Arnaud Patard <arnaud.patard@rtp-net.org>
> 
> Index: linux-next/drivers/net/ethernet/marvell/mvneta.c
> ===================================================================
> --- linux-next.orig/drivers/net/ethernet/marvell/mvneta.c	2013-06-20 23:39:37.485391949 +0200
> +++ linux-next/drivers/net/ethernet/marvell/mvneta.c	2013-06-20 23:39:37.481391949 +0200
> @@ -88,6 +88,8 @@
>  #define      MVNETA_TX_IN_PRGRS                  BIT(1)
>  #define      MVNETA_TX_FIFO_EMPTY                BIT(8)
>  #define MVNETA_RX_MIN_FRAME_SIZE                 0x247c
> +#define MVETH_SGMII_SERDES_CFG			 0x24A0
> +#define MVETH_SGMII_SERDES_STAT			 0x24A4

You are not using this last define in your patch. Please also use
MVNETA_ prefix for those defines, like all the other ones.

However, there is one thing that I am not understanding completely. The
C code you pointed above seems to do the following:

	pRegAddr[3] = SGMII_SERDES_CFG_REG(sgmiiPort);
	pRegAddr[4] = SGMII_SERDES_STAT_REG(sgmiiPort);
	[..]
	pRegVal[3] = (pSerdesInfo->busSpeed & (1 << serdesLineNum)) != 0 ? 0x1547 : 0xCC7;
	pRegVal[4] = 0x7;

So:

 1) In some conditions, it will use the 0x1547 value in some cases, and
    0xCC7 in the other ones. And interestingly, the datasheet doesn't
    mention what the 0x1547 magical value is.

 2) It writes 0x7 to the SGMII_SERDES_STAT_REG register, but the
    datasheet mentions this register as a read-only register.

Best regards,

Thomas
-- 
Thomas Petazzoni, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
