From: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Subject: Re: [PATCH net-next 4/5] net: phy: bcm7xxx: Add support for
 downshift/Wirespeed
Date: Wed, 23 Nov 2016 12:45:12 +0100
Message-ID: <20161123114512.GB25778@microsemi.com>
References: <20161122194058.29820-1-f.fainelli@gmail.com>
 <20161122194058.29820-5-f.fainelli@gmail.com>
 <20161122200228.GG14947@lunn.ch>
 <1902f0f0-46e5-d3b3-90c1-10867f4fb826@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: Andrew Lunn <andrew@lunn.ch>, <netdev@vger.kernel.org>,
        <davem@davemloft.net>, <bcm-kernel-feedback-list@broadcom.com>,
        <raju.lakkaraju@microsemi.com>,
        <vivien.didelot@savoirfairelinux.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0072.outbound.protection.outlook.com ([104.47.34.72]:37376
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1755058AbcKWLpV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 23 Nov 2016 06:45:21 -0500
Content-Disposition: inline
In-Reply-To: <1902f0f0-46e5-d3b3-90c1-10867f4fb826@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 22/11/16 12:07, Florian Fainelli wrote:
> On 11/22/2016 12:02 PM, Andrew Lunn wrote:
> >> +static int bcm7xxx_28nm_set_tunable(struct phy_device *phydev,
> >> +                                struct ethtool_tunable *tuna,
> >> +                                const void *data)
> >> +{
> >> +    u8 count = *(u8 *)data;
> >> +    int ret;
> >> +
> >> +    switch (tuna->id) {
> >> +    case ETHTOOL_PHY_DOWNSHIFT:
> >> +            ret = bcm_phy_downshift_set(phydev, count);
> >> +            break;
> >> +    default:
> >> +            return -EOPNOTSUPP;
> >> +    }
> >> +
> >> +    if (ret)
> >> +            return ret;
> >> +
> >> +    /* Disable EEE advertisment since this prevents the PHY
> >> +     * from successfully linking up, trigger auto-negotiation restart
> >> +     * to let the MAC decide what to do.
> >> +     */
> >> +    ret = bcm_phy_set_eee(phydev, count == DOWNSHIFT_DEV_DISABLE);
> >> +    if (ret)
> >> +            return ret;
> >> +
> >> +    return genphy_restart_aneg(phydev);
> >> +}
> >
> > Hi Florian
> >
> > Is the locking O.K. here? The core code does not take the phy lock.
> > But i think your shadow register accesses at least need to be
> > protected by the lock?
> 
> There should be some kind of protection, but I was expecting it to be
> done at the caller level, so that when {get,set}_tunable run, they are
> serialized with respect to each other, clearly, by looking at the code,
> this is not the case.
> 
> >
> > Maybe we should think about this locking a bit. It is normal for the
> > lock to be held when using ops in the phy driver structure. The
> > exception is suspend/resume. Maybe we should also take the lock before
> > calling the phydev->drv->get_tunable() and phydev->drv->set_tunable()?
> 
> Yes, that certainly seems like a good approach to me, let me cook a
> patch doing that.

Just for my understanding (such that I will not make the same mistake again)...

Why is it that phy functions such as get_wol needs to take the phy_lock and
others like get_tunable does not.

I do understand the arguments on why the lock should be held by the caller of
get_tunable, but I do not understand why the same argument does not apply for
get_wol.

/Allan
