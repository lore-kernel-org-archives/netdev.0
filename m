From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [REGRESSION,BISECTED] mvneta broken in 3.14 on RN2120, RN102
 and RN104 after e3a8786c10e7
Date: Sat, 12 Apr 2014 18:31:12 +0200
Message-ID: <20140412183112.7ca31cb6@skate>
References: <87k3au8qba.fsf@natisbad.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Willy Tarreau <w@1wt.eu>, David Miller <davem@davemloft.net>
To: arno@natisbad.org (Arnaud Ebalard)
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:50385 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754561AbaDLQbQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Apr 2014 12:31:16 -0400
In-Reply-To: <87k3au8qba.fsf@natisbad.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Arnaud Ebalard,

On Sat, 12 Apr 2014 18:28:57 +0200, Arnaud Ebalard wrote:

> Network is broken w/ 3.14 kernel on Netgear ReadyNAS 102 (the SoC is
> an Armada 370 using mvneta driver and rgmii phy): nothing sent, nothing
> received from the interface. This came as a surprise (it was reported by
> two users) as 3.14-rc8 was ok on my side.
> 
> I also checked on a ReadyNAS 104 (Armada 370 using mvneta driver and
> rgmii phy for both interfaces) and a ReadyNAS 2120 (Armada XP using
> mvneta driver and rgmii phy for both interfaces). They are both
> affected too.
> 
> A short bisect session pointed e3a8786c10e7 (net: mvneta: fix usage as a
> module on RGMII configurations). Reverting it put things back in order
> on those three devices.
> 
> I took a quick look at e3a8786c10e7 commit and did some tests to narrow
> the root cause (I do not have A370 functional specification doc at hand
> today so I was not able to check mvneta details):
> 
>     -}
>     -
>      /* Start the Ethernet port RX and TX activity */
>      static void mvneta_port_up(struct mvneta_port *pp)
>      {
>     @@ -2756,12 +2728,15 @@ static void mvneta_port_power_up(struct mvneta_port *pp, int phy_mode)
>             mvreg_write(pp, MVNETA_UNIT_INTR_CAUSE, 0);
>      
>             if (phy_mode == PHY_INTERFACE_MODE_SGMII)
>     -               mvneta_port_sgmii_config(pp);
>     +               mvreg_write(pp, MVNETA_SERDES_CFG, MVNETA_SGMII_SERDES_PROTO);
>     +       else
>     +               mvreg_write(pp, MVNETA_SERDES_CFG, MVNETA_RGMII_SERDES_PROTO);
> 
> 
> I built a first kernel with the 'else' branch above removed (rationale:
> SERDES config was not set for RGMII prior to the patch). The issue
> remained.
>      
>     -       mvneta_gmac_rgmii_set(pp, 1);
>     +       val = mvreg_read(pp, MVNETA_GMAC_CTRL_2);
>     +
>     +       val |= MVNETA_GMAC2_PCS_ENABLE | MVNETA_GMAC2_PORT_RGMII;
> 
> I removed MVNETA_GMAC2_PCS_ENABLE flag setting (rationale: it was only
> done for SGMII prior to the patch and all my platforms have RGMII
> connected PHY). *The issue disappeared on all 3 NAS with that simple
> change*.

Yes, issue known. See https://bugzilla.kernel.org/show_bug.cgi?id=73401.

Unfortunately, at this point I don't have enough informations to fix
both issues: the issue you're having, and the issue of using mvneta as
a module. Since the issue you're having is much more problematic, I'll
send a patch to revert my patch, until I have enough informations to
fix the problem in a proper way.

Thanks for your report!

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
