From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] via-velocity: FLOW_CNTL_RX does not disable Asymmetric
 pause in set_mii_flow_control()
Date: Mon, 22 Mar 2010 19:58:31 -0700 (PDT)
Message-ID: <20100322.195831.233398454.davem@davemloft.net>
References: <4BA7D22A.6080300@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, davej@redhat.com
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44500
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753359Ab0CWC6K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Mar 2010 22:58:10 -0400
In-Reply-To: <4BA7D22A.6080300@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>
Date: Mon, 22 Mar 2010 21:25:14 +0100

> Asymmetric pause was not disabled in the RX case.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> ---
> I spotted this because In the FLOW_CNTL_RX and FLOW_CNTL_TX_RX
> cases the same code is executed, is the amendment below required?

The bit settings in the MII_ADVERTISE register should be:

1) RX and TX pause both requested

   set only ADVERTISE_PAUSE_CAP

2) Only TX pause requested

   set only ADVERTISE_PAUSE_ASYM

3) Only RX pause requested

   set both ADVERTISE_PAUSE_CAP and ADVERTISE_PAUSE_ASYM

4) Neither TX nor RX pause requested

   set nothing

(drivers/net/tg3.c:tg3_advert_flowctrl_1000t() is a good
 reference point)

It would be easier to compare the VIA driver with the rest of
the world if it used the standard mii.h defines instead of
it's own private ones.  That would be a good change to make at
some point.

Anyways, the correct fix is therefore something like:

diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index 3a486f3..bc278d4 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -812,7 +812,7 @@ static void set_mii_flow_control(struct velocity_info *vptr)
 
 	case FLOW_CNTL_TX_RX:
 		MII_REG_BITS_ON(ANAR_PAUSE, MII_REG_ANAR, vptr->mac_regs);
-		MII_REG_BITS_ON(ANAR_ASMDIR, MII_REG_ANAR, vptr->mac_regs);
+		MII_REG_BITS_OFF(ANAR_ASMDIR, MII_REG_ANAR, vptr->mac_regs);
 		break;
 
 	case FLOW_CNTL_DISABLE:
