From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Hardware flow control on RTL8169
Date: Mon, 8 May 2006 21:46:25 +0200
Message-ID: <20060508194625.GA15174@electric-eye.fr.zoreil.com>
References: <1147099047.445f57a7874d4@ssl0.ovh.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:11985 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1750731AbWEHTrM
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 May 2006 15:47:12 -0400
To: s.munaut@intopix.com
Content-Disposition: inline
In-Reply-To: <1147099047.445f57a7874d4@ssl0.ovh.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

s.munaut@intopix.com <s.munaut@intopix.com> :
[...]
> I'm using a kurobox (www.kurobox.com) with a 2.6.15 kernel and I'd like to use
> hardware flow control with it. However it seems the driver doesn't support it,
> is that correct ?
> 
> At least I see the device continue sending even when the other device is
> sending PAUSE frames with 0xffff pausetime continuously.
> 
> I've tried adding RTL_W16(TBI_ANAR, 0x00a0); to the hw_start function but
> that doesn't seem to have any effect ...
> 
> Any clue ?

- use netdev@vger.kernel.org instead of netdev@oss.sgi.com
- don't trim the Cc: (just a remainder...);
- try the hack below with and without the first hunk. Use 'ethtool -s ethX'
  to see what the device reports. It may not settle immediately.

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 0ad3310..bc702be 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -769,6 +769,8 @@ static int rtl8169_set_speed_xmii(struct
 			auto_nego &= ~(PHY_Cap_10_Half | PHY_Cap_100_Half);
 	}
 
+	auto_nego |= ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM;
+
 	tp->phy_auto_nego_reg = auto_nego;
 	tp->phy_1000_ctrl_reg = giga_ctrl;
 
@@ -960,6 +962,11 @@ static void rtl8169_gset_xmii(struct net
 	else if (status & _10bps)
 		cmd->speed = SPEED_10;
 
+	if (status & TxFlowCtrl)
+		cmd->advertising |= ADVERTISED_Asym_Pause;
+	if (status & RxFlowCtrl)
+		cmd->advertising |= ADVERTISED_Pause;
+
 	cmd->duplex = ((status & _1000bpsF) || (status & FullDup)) ?
 		      DUPLEX_FULL : DUPLEX_HALF;
 }
