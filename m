From: kou.ishizaki@toshiba.co.jp
Subject: (unknown)
Date: Thu, 01 Feb 2007 16:54:02 +0900 (JST)
Message-ID: <200702010754.l117s2T8003383@toshiba.co.jp>
Cc: linas@austin.ibm.com, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org
To: jens@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from inet-tsb5.toshiba.co.jp ([202.33.96.24]:47392 "EHLO
	inet-tsb5.toshiba.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030568AbXBAHym (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Feb 2007 02:54:42 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jgarzik@pobox.com, jim@jklewis.com
Subject: Re: [Cbe-oss-dev] spidernet: dynamic phy setup code
In-Reply-To: <200701261409.29537.jens@de.ibm.com>
From: Ishizaki Kou <kouish@swc.toshiba.co.jp>
X-Mailer: Mew version 4.2 on Emacs 21.3 / Mule 5.0 (SAKAKI)
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Jens-san

> This patch modifies the patch submitted by Kou Ishizaki to make it
work on the
> blade
(http://marc.theaimsgroup.com/?l=linux-netdev&m=116593424505539&w=2).
> Unfortunately I dont have access to a Celleb so I cannot test it
there.

Thanks for arranging our patch to work on Cell Blade.

This patch partially works on celleb but remains 
following several problems.
1. It doesn't recover once an ethernet cable which is
   connected to a spider_net card is unpluged. 
2. It doesn't work when the spider_net card is connected to 
   a 100Mbps ethernet switch.

To solve these problems, we need to restore some codes
you removed from your patch.

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

We need to use different auto-neg initial settings between
for 10/100Mbps ethernet switches and for Gbps ethernet switches.
Driver don't know which type of network switch is connected to
network card, so we try both settings alternately in auto negtiation
sequences by using a variable "is1000".
Furthermore, we have a problem that poll_link() may succeed even when
the auto-neg initial setting is for different network switch type,
and the network card does not work on this case. We retry auto-neg
with the another initial setting on this case.

#We are commented that "is1000" should be in spider_net_card.
#We fixed it in another patch. Please refer the following.
#http://ozlabs.org/pipermail/linuxppc-dev/2007-January/030203.html

But we don't think this is the best solution, and we are still
developing 
our spidernet driver. If you have a good alternative idea, please tell
us.

(2)
>- spider_net_write_reg(card, SPIDER_NET_GMACST,
>-        spider_net_read_reg(card, SPIDER_NET_GMACST));
>- spider_net_write_reg(card, SPIDER_NET_GMACINTEN, 0x4);

These codes are enabling LINK status interrupt which is disabled
at the beginning of auto-neg.
Without this operation, auto negotiation works only when a connection
detected for the first time, and auto negotiation will not work 
when an ethernet cable is unpluged or pluged.

(3)
>- mii_phy_probe(phy, phy->mii_id);
It seems that PHY reset is necessary before auto negotiation,
after a link once went down.
We can't call directly reset routine from driver, so we call
mii_phy_probe().
We are still developping the patch as we noted, and we are considering
to call mii_phy_probe() from spider_net_setup_aneg(), or to call
reset_one_mii_phy() from bcm54xx_setup_aneg().

We think these (1)-(3) are necessary, but we are afraid that you removed
them
by a reason that they causes some trouble in Cell Blade. If so please
tell us.


Best regards,
Kou Ishizaki
