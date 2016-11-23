From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 4/5] net: phy: bcm7xxx: Add support for
 downshift/Wirespeed
Date: Wed, 23 Nov 2016 15:46:36 +0100
Message-ID: <20161123144636.GK14947@lunn.ch>
References: <20161122194058.29820-1-f.fainelli@gmail.com>
 <20161122194058.29820-5-f.fainelli@gmail.com>
 <20161122200228.GG14947@lunn.ch>
 <1902f0f0-46e5-d3b3-90c1-10867f4fb826@gmail.com>
 <20161123114512.GB25778@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
        davem@davemloft.net, bcm-kernel-feedback-list@broadcom.com,
        raju.lakkaraju@microsemi.com, vivien.didelot@savoirfairelinux.com
To: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:49843 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S964895AbcKWOqk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 23 Nov 2016 09:46:40 -0500
Content-Disposition: inline
In-Reply-To: <20161123114512.GB25778@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > > Maybe we should think about this locking a bit. It is normal for the
> > > lock to be held when using ops in the phy driver structure. The
> > > exception is suspend/resume. Maybe we should also take the lock before
> > > calling the phydev->drv->get_tunable() and phydev->drv->set_tunable()?
> > 
> > Yes, that certainly seems like a good approach to me, let me cook a
> > patch doing that.
> 
> Just for my understanding (such that I will not make the same mistake again)...
> 
> Why is it that phy functions such as get_wol needs to take the phy_lock and
> others like get_tunable does not.
> 
> I do understand the arguments on why the lock should be held by the caller of
> get_tunable, but I do not understand why the same argument does not apply for
> get_wol.

Hi Allan

phy_ethtool_get_wol and friends probably should take the
phy_lock. This inconsistency is probably leading to locking
bugs. e.g. at803x_set_wol() does a read-modify-write, and does not
take the lock.

There is no comment in the patch adding phy_ethtool_set_wol() to say
why the lock is not taken, and a quick look at the code does not
suggest a reason why it could not be taken/released by
phy_ethtool_set_wol().

I think it would be a good idea to change this.

phy_suspend()/phy_resume() might have good reasons to avoid the lock,
i've no idea how it is supposed to work. Is there a danger something
else is holding the lock and has already been suspended? I guess not,
otherwise there is little hope suspend would work at all.

	  Andrew
