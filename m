From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next RFC 5/9] net: dsa: forward hardware timestamping
 ioctls to switch driver
Date: Sun, 8 Oct 2017 09:12:59 -0400
Message-ID: <20171008131259.6rgk36exnr2bmmbh@localhost>
References: <1506612341-18061-1-git-send-email-brandon.streiff@ni.com>
 <1506612341-18061-6-git-send-email-brandon.streiff@ni.com>
 <cb36aecc-3649-e22a-0fd4-0babbb691c8c@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Brandon Streiff <brandon.streiff@ni.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Erik Hons <erik.hons@ni.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cb36aecc-3649-e22a-0fd4-0babbb691c8c@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 28, 2017 at 10:25:34AM -0700, Florian Fainelli wrote:
> This echoes back to Andrew's comments in patch 2, but we may have to
> prefer PHY timestamping over MAC timestamping if both are available?
> Richard, is that usually how the preference should be made?

No, if the MAC supports time stamping, then it will take precedence,
because the MAC driver doesn't know that the PHY also supports this.
In the case where a board design includes the PHYTER (the one and only
PHY PHC) and a MAC PHC, the user must de-select the MAC support in the
Kconfig in order to use the PHYTER.

So in general, we don't support PHC/timestamping simultaneously in the
MAC and PHY.  It would be a lot of work to support this, and the user
timestamping API would have to be extended yet again, and so I think
it is not worth the effort.

Getting back to this patch, it should fall back to PHY timestamping
when the switch device doesn't support timestamping:

	case SIOCGHWTSTAMP:
		if (ds->ops->port_hwtstamp_get)
			return ds->ops->port_hwtstamp_get(ds, port, ifr);
		else
			return phy_mii_ioctl(dev->phydev, ifr, cmd);

That way, if someone combines a PHYTER with a non-PTP capable switch,
it will just work.

Thanks,
Richard
