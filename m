From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] ethtool.h: Add #defines for unidirectional
 ethernet duplex
Date: Sat, 28 Aug 2010 16:03:57 -0700 (PDT)
Message-ID: <20100828.160357.102557054.davem@davemloft.net>
References: <1282938138-17844-1-git-send-email-Kyle.D.Moffett@boeing.com>
	<1282938138-17844-2-git-send-email-Kyle.D.Moffett@boeing.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kyle@moffetthome.net,
	shemminger@linux-foundation.org, netdev@vger.kernel.org
To: Kyle.D.Moffett@boeing.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34047
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751244Ab0H1XDl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Aug 2010 19:03:41 -0400
In-Reply-To: <1282938138-17844-2-git-send-email-Kyle.D.Moffett@boeing.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kyle Moffett <Kyle.D.Moffett@boeing.com>
Date: Fri, 27 Aug 2010 15:42:17 -0400

> A large variety of fiber ethernet PHYs and some copper ethernet PHYs
> support forced "unidirectional link" modes.  Some signalling modes are
> designed for last-mile ethernet plants while others are designed for
> strict security isolation (fiber with no return-path).
> 
> In order to configure those kinds of forced modes from userspace, we
> need to add additional options to the "ethtool" interface.  As such
> "unidirectional" ethernet modes most closely resemble ethernet "duplex",
> we add two additional DUPLEX_* defines to the ethtool interface:
> 
>   #define DUPLEX_TXONLY 0x02
>   #define DUPLEX_RXONLY 0x03
> 
> Most ethernet PHYs will still need to be configured internally in a mode
> with autoneg off and duplex full, except for a few model-specific PHY
> register adjustments.
> 
> Most PHYs can simply use a regular forced-mode for rx-only configuration,
> but it may be useful in the ethernet driver to completely disable the TX
> queues or similar.
> 
> Signed-off-by: Kyle Moffett <Kyle.D.Moffett@boeing.com>

A fine idea, but you're really going to have to audit all of the networking
drivers to clean up the existing uses that assume this thing is a bitmap
and that there are only essentially two values ('0' and '1').  For example:

drivers/net/e1000/e1000_main.c:	case SPEED_10 + DUPLEX_HALF:
drivers/net/e1000/e1000_main.c:	case SPEED_100 + DUPLEX_HALF:
drivers/net/e1000/e1000_main.c:	case SPEED_1000 + DUPLEX_HALF: /* not supported */
drivers/net/e1000e/ethtool.c:	case SPEED_10 + DUPLEX_HALF:
drivers/net/e1000e/ethtool.c:	case SPEED_100 + DUPLEX_HALF:
drivers/net/e1000e/ethtool.c:	case SPEED_1000 + DUPLEX_HALF: /* not supported */
drivers/net/igb/igb_main.c:	case SPEED_10 + DUPLEX_HALF:
drivers/net/igb/igb_main.c:	case SPEED_100 + DUPLEX_HALF:
drivers/net/igb/igb_main.c:	case SPEED_1000 + DUPLEX_HALF: /* not supported */
drivers/net/sungem_phy.c:		phy->duplex |=  DUPLEX_HALF;
drivers/net/sungem_phy.c:		phy->duplex |=  DUPLEX_HALF;

Also, drivers/net/mii.c does stuff like:

			ecmd->duplex = !!(nego & ADVERTISED_1000baseT_Full);

It also (probably correctly, I don't know, you'll have to decide)
rejects anything other than the existing values.

	if (ecmd->duplex != DUPLEX_HALF && ecmd->duplex != DUPLEX_FULL)
		return -EINVAL;

Finally, phy_ethtool_sset() does this too, so with your patch applied even
phylib would reject the new settings:

	if (cmd->autoneg == AUTONEG_DISABLE &&
	    ((cmd->speed != SPEED_1000 &&
	      cmd->speed != SPEED_100 &&
	      cmd->speed != SPEED_10) ||
	     (cmd->duplex != DUPLEX_HALF &&
	      cmd->duplex != DUPLEX_FULL)))
		return -EINVAL;

making it impossible to add support for TX-only or RX-only in a phylib
using driver.

There are probably other similar dragons hiding in various drivers, you'll
really have to do a full audit of how every driver stores and makes use of
duplex settings before we can seriously apply this patch.

Thanks!
