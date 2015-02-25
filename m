From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Subject: Re: Questions about the sh_eth driver and hardware
Date: Wed, 25 Feb 2015 02:15:42 +0000
Message-ID: <1424830542.4443.41.camel@xylophone.i.decadent.org.uk>
References: <1421861078.1222.271.camel@xylophone.i.decadent.org.uk>
	 <SIXPR06MB333899AF34FC0BBADA5A29ED82D0@SIXPR06MB333.apcprd06.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>,
	MITSUHIRO KIMURA <mitsuhiro.kimura.kc@renesas.com>,
	"HISASHI NAKAMURA(Retired)" <a5077047@renesasgroup.onmicrosoft.com>,
	Yoshihiro Kaneko <ykaneko0929@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	ct-linux-kernel <linux-kernel@codethink.co.uk>
To: yoshihiro shimoda <yoshihiro.shimoda.uh@renesas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:35761 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752317AbbBYCPt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 21:15:49 -0500
In-Reply-To: <SIXPR06MB333899AF34FC0BBADA5A29ED82D0@SIXPR06MB333.apcprd06.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-02-19 at 04:41 +0000, yoshihiro shimoda wrote:
> Hi Ben,
> 
> This is Shimoda of Renesas. I'm a software engineer.
> I asked hardware team about your questions.

Thank you.

[...]
> > 2. In case of a Receive Descriptor Empty error (RDE), we currently read
> > the RDFAR register to find the next descriptor the DMA engine will use.
> > But this register is not documented for the R8A7790 and the driver does
> > not define an offset for it on R-Car chips.  The manual doesn't say how
> > to set the address of the next descriptor to use.  Maybe we should
> > assume that R-Car chips will never skip descriptors after RDE?
> 
> They said that software should find the next descriptor without RDFAR register somehow
> after RDE. However, I checked this driver handling on the R-Car M2, and the following
> code didn't run actually.

Is that because the hardware doesn't actually set RDE?  Otherwise, I
don't see what would prevent this code from running.

> So, we should assume the R-Car chips will never skip descriptors
> after RDE.

OK.

> < sh_eth.c: sh_eth_rx() >
> 	if (!(sh_eth_read(ndev, EDRRR) & EDRRR_R)) {
> 		/* fix the values for the next receiving if RDE is set */
> 		if (intr_status & EESR_RDE) {
> /*vvvvvvv The code below didn't run on R-Car Gen2 vvvvvvv*/
> 			u32 count = (sh_eth_read(ndev, RDFAR) -
> 				     sh_eth_read(ndev, RDLAR)) >> 4;
> 
> 			mdp->cur_rx = count;
> 			mdp->dirty_rx = count;
> /*^^^^^^^ The code above didn't run on R-Car Gen2 ^^^^^^^*/
> 		}
> 		sh_eth_write(ndev, EDRRR_R, EDRRR);
> 	}
> 
> < Test method >
>  Host PC $ sudo ping -f -l 128 <the board's ip address>

I've tried things like that, but the CPU cores seem to be fast enough to
handle a few gigabits per second.  I think we would need to slow down
the CPUs or inject memory allocation failures to provoke an RDE.

Ben.
