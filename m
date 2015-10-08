From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH RFC] net: mvneta: add ethtool statistics
Date: Thu, 8 Oct 2015 16:42:12 +0100
Message-ID: <20151008154211.GG32532@n2100.arm.linux.org.uk>
References: <20151006165208.GE3557@lunn.ch>
 <E1ZjZ2q-00087d-Im@rmk-PC.arm.linux.org.uk>
 <20151007230333.GL17952@lunn.ch>
 <20151008085141.GA32532@n2100.arm.linux.org.uk>
 <20151008153257.GT17952@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.arm.linux.org.uk ([78.32.30.218]:48245 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934072AbbJHPmS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 11:42:18 -0400
Content-Disposition: inline
In-Reply-To: <20151008153257.GT17952@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 08, 2015 at 05:32:57PM +0200, Andrew Lunn wrote:
> > > This would suggest the driver is not clearing the statistics when it
> > > loads. Should it?
> > 
> > That's an interesting question, one which I have no answer for.
> 
> So i took a look at the other Marvell drivers. mv643xx_eth.c, skge and
> sky2.c all have code to clear the statistics. So for consistency, i
> think nvneta should as well.
> 
> But it gets stranger. mvneta has:
> 
> static void mvneta_mib_counters_clear(struct mvneta_port *pp)
> {
>         int i;
>         u32 dummy;
> 
>         /* Perform dummy reads from MIB counters */
>         for (i = 0; i < MVNETA_MIB_LATE_COLLISION; i += 4)
>                 dummy = mvreg_read(pp, (MVNETA_MIB_COUNTERS_BASE + i));
> }

That's called from mvneta_port_up(), which is called every time the link
comes up or the MTU is changed.  That's really not nice.  However, it
seems ineffectual because it's not accessing any documented registers:

#define MVNETA_MIB_COUNTERS_BASE                 0x3080
#define      MVNETA_MIB_LATE_COLLISION           0x7c

However, the documented counters are from 0x3000 to 0x307c.

> Looks like somebody did not finish this?

All you need to do is to read the counter to clear it, so the above
should result in it being cleared as above.

Maybe the above code can be fixed to read the proper counters, and
called from a more appropriate place (driver initialisation?)

-- 
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
