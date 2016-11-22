From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 4/5] net: phy: bcm7xxx: Add support for
 downshift/Wirespeed
Date: Tue, 22 Nov 2016 21:02:28 +0100
Message-ID: <20161122200228.GG14947@lunn.ch>
References: <20161122194058.29820-1-f.fainelli@gmail.com>
 <20161122194058.29820-5-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        bcm-kernel-feedback-list@broadcom.com, allan.nielsen@microsemi.com,
        raju.lakkaraju@microsemi.com, vivien.didelot@savoirfairelinux.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:48903 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755655AbcKVUCb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 22 Nov 2016 15:02:31 -0500
Content-Disposition: inline
In-Reply-To: <20161122194058.29820-5-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +static int bcm7xxx_28nm_set_tunable(struct phy_device *phydev,
> +				    struct ethtool_tunable *tuna,
> +				    const void *data)
> +{
> +	u8 count = *(u8 *)data;
> +	int ret;
> +
> +	switch (tuna->id) {
> +	case ETHTOOL_PHY_DOWNSHIFT:
> +		ret = bcm_phy_downshift_set(phydev, count);
> +		break;
> +	default:
> +		return -EOPNOTSUPP;
> +	}
> +
> +	if (ret)
> +		return ret;
> +
> +	/* Disable EEE advertisment since this prevents the PHY
> +	 * from successfully linking up, trigger auto-negotiation restart
> +	 * to let the MAC decide what to do.
> +	 */
> +	ret = bcm_phy_set_eee(phydev, count == DOWNSHIFT_DEV_DISABLE);
> +	if (ret)
> +		return ret;
> +
> +	return genphy_restart_aneg(phydev);
> +}

Hi Florian

Is the locking O.K. here? The core code does not take the phy lock.
But i think your shadow register accesses at least need to be
protected by the lock?

Maybe we should think about this locking a bit. It is normal for the
lock to be held when using ops in the phy driver structure. The
exception is suspend/resume. Maybe we should also take the lock before
calling the phydev->drv->get_tunable() and phydev->drv->set_tunable()?

	  Andrew
