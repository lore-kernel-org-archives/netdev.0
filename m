From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH 2/2] at803x: double check SGMII side autoneg
Date: Thu, 19 Jan 2017 20:38:15 -0600
Message-ID: <44eb0b95-1868-396b-db6b-18d233eff853@codeaurora.org>
References: <1477305654-11328-1-git-send-email-zefir.kurtisi@neratec.com>
 <1477305654-11328-3-git-send-email-zefir.kurtisi@neratec.com>
 <e063a5fd-a1c5-e9ec-1700-21c6974a7cbe@codeaurora.org>
 <3291b7c1-7bf6-d776-adab-b89c9cd9be38@neratec.com>
 <5763c2fb-7286-15b0-091f-1abf26c0afe7@codeaurora.org>
 <b12e913d-874b-734a-4401-88315b8459dc@neratec.com>
 <7d61d23d-60f5-a77e-42ad-fccf6e8d5878@codeaurora.org>
 <759d6323-ffac-ebe8-b197-4e1165be5673@neratec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, f.fainelli@gmail.com
To: Zefir Kurtisi <zefir.kurtisi@neratec.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:57222 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750916AbdATCiO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 21:38:14 -0500
In-Reply-To: <759d6323-ffac-ebe8-b197-4e1165be5673@neratec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Zefir Kurtisi wrote:
> It always operates at 675MHz, which with two lines gives 1.25Gbps,
> which at 10/8 coding gives exactly 1Gbps net data rate. If the
> at803x's copper side autonegotiates to 1Gbps, the bits traversing
> over the SGMII match the copper side 1:1. In case the copper side
> autonegotiates to e.g. 100Mbps, each bit at the copper side on the
> SGMII bus is replicated and sent 10x times - or 100x times in case of
> 10Mbps. The MAC side of the ETH needs to be aware of how the SGMII
> data has to be interpreted, and this is why you have to set the bits
> you are referring to.

So does this mean that the SGMII link should not be autonegotiated? I 
currently have this code:

     if (phydev->autoneg == AUTONEG_ENABLE) {
         val &= ~(FORCE_AN_RX_CFG | FORCE_AN_TX_CFG);
         val |= AN_ENABLE;
         writel(val, phy->base + EMAC_SGMII_PHY_AUTONEG_CFG2);
     } else {
         ...

So if the external PHY is set to autonegotiate, then the SGMII block is 
set to also negotiate.  Now that I think about it, this seems wrong. 
And in fact, I'm not sure how it works.  It seems that the this only 
makes sense if the SGMII block is configured to act as the only PHY. 
This is an option that the hardware supports but my driver does not.  So 
perhaps I should remove this part, and just do the rest:


	u32 speed_cfg;

	switch (phydev->speed) {
	case SPEED_10:
		speed_cfg = SPDMODE_10;
		break;
	case SPEED_100:
		speed_cfg = SPDMODE_100;
		break;
	case SPEED_1000:
		speed_cfg = SPDMODE_1000;
		break;
	default:
		return -EINVAL;
	}

	if (phydev->duplex == DUPLEX_FULL)
		speed_cfg |= DUPLEX_MODE;

	val &= ~AN_ENABLE;
	writel(speed_cfg, phy->base + EMAC_SGMII_PHY_SPEED_CFG1);
	writel(val, phy->base + EMAC_SGMII_PHY_AUTONEG_CFG2);

Should I be doing this all the time?

> To track down who is causing the additional message, I would proceed
> with following technique that helped me dig down a similar problem:
> since you control the events in question and there is no risk of
> flooding the kernel log, in the top of phy.c::phy_print_status() add
> a dump_stack() call. In the debug log ensure that all of the traces
> end up in the same phydev->adjust_link() callback handler (in your
> case emac_adjust_link()).

That's a good idea, thanks.

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the
Code Aurora Forum, hosted by The Linux Foundation.
