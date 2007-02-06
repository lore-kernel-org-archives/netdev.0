From: Ishizaki Kou <kou.ishizaki@toshiba.co.jp>
Subject: Re: spidernet: dynamic phy setup code
Date: Tue, 06 Feb 2007 19:42:30 +0900 (JST)
Message-ID: <200702061042.l16AgVXP027762@toshiba.co.jp>
References: <200702010754.l117s2T8003383@toshiba.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: jens@de.ibm.com, benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from imx12.toshiba.co.jp ([61.202.160.132]:53236 "EHLO
	imx12.toshiba.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751462AbXBFKnE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Feb 2007 05:43:04 -0500
In-Reply-To: <200702010754.l117s2T8003383@toshiba.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben-san, Jens-san

Thanks for your comments and advices.
First, we should apologize to you that some troubles which we informed
about spidernet auto-negotiation are caused by our mistake.
We used wrong MACRO for "advertise" variable to
phy->def->ops->setup_aneg(). 

We will post the revised patch for spider_net.
Following are the current status of troubles we informed.

(1)
>- if (card->aneg_count > 10) {
>-  /* timeout */
>-  card->aneg_count = 0;
>-  is1000 = !is1000;
>-  goto re_setup;
>- if (phy->speed == 1000 && !is1000) {
>-  is1000 = 1;
>-  goto re_setup;
>- } else if(phy->speed != 1000 && is1000) {
>-  is1000 = 0;
>-  goto re_setup;
>- }
> We need to use different auto-neg initial settings between
> for 10/100Mbps ethernet switches and for Gbps ethernet switches.
> Driver don't know which type of network switch is connected to
> network card, so we try both settings alternately in auto negtiation
> sequences by using a variable "is1000".
> Furthermore, we have a problem that poll_link() may succeed even when
> the auto-neg initial setting is for different network switch type,
> and the network card does not work on this case. We retry auto-neg
> with the another initial setting on this case.
Solved.

We are now able to use Gbps switches and 10/100Mbps switches with 
the same advertise setting and we don't need to use is1000.
The re_setup is not necessary and they are removed in the revised patch.

2.
>> - spider_net_write_reg(card, SPIDER_NET_GMACST,
>> -        spider_net_read_reg(card, SPIDER_NET_GMACST));
>> - spider_net_write_reg(card, SPIDER_NET_GMACINTEN, 0x4);
>
> These codes are enabling LINK status interrupt which is disabled
> at the beginning of auto-neg.
> Without this operation, auto negotiation works only when a connection
> detected for the first time, and auto negotiation will not work 
> when an ethernet cable is unpluged or pluged.
Pending(No problem, if they don't cause any trouble on Cell Blades).

By the way, why do you suggest to use polling for auto-neg, Ben-san? 
Is there a merit to use polling, or is there a problem to use interrupt?
Sorry, we couldn't find the reason why sungem use polling for auto-neg. 

They might not be necessary, if we use polling to handle LINK status as
Ben-san said.

3
>> - mii_phy_probe(phy, phy->mii_id);
> It seems that PHY reset is necessary before auto negotiation,
> in the case that ethernet card is disconnected from an ethernet switch
> then connected to another ethernet switch.
> We can't call directly reset routine from driver, so we call
mii_phy_probe().
Pending.

After all, we need phy reset.
> If you really need to reset it, then change sungem_phy.c to export the
> reset function. But I'm surprised you need that. Another option is to
> reset the PHY in your PHY's setup_aneg() function.
We still wonder which is the best way, and mii_phy_probe() still remains
so far.

Best regards,
Kou Ishizaki
