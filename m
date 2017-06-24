From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH NET v3 1/2] net: phy: Add phy loopback support in net phy
 framework
Date: Sat, 24 Jun 2017 15:50:04 +0200
Message-ID: <20170624135004.GK4875@lunn.ch>
References: <1498211042-240816-1-git-send-email-linyunsheng@huawei.com>
 <1498211042-240816-2-git-send-email-linyunsheng@huawei.com>
 <20170624031231.GG4875@lunn.ch>
 <0fa5d2df-741e-06ba-96f3-567f47f82e3e@huawei.com>
 <13778697-eebb-0787-33dc-a57112f45046@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f.fainelli@gmail.com, liguozhu@hisilicon.com, linuxarm@huawei.com,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        davem@davemloft.net, tremyfr@gmail.com
To: Yunsheng Lin <linyunsheng@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:33909 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751276AbdFXNuM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 24 Jun 2017 09:50:12 -0400
Content-Disposition: inline
In-Reply-To: <13778697-eebb-0787-33dc-a57112f45046@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> phy_resume call phydrv->resume without take mutex.
> if phy driver implement resume function, for example marvell_resume, then
> 
> static int marvell_resume(struct phy_device *phydev)
> {
> 	int err;
> 
> 	/* Resume the fiber mode first */
> 	if (!(phydev->supported & SUPPORTED_FIBRE)) {
> 		err = phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_FIBER);
> 		if (err < 0)
> 			goto error;
> 
> 		/* With the page set, use the generic resume */
> 		err = genphy_resume(phydev);
> 		if (err < 0)
> 			goto error;
> 
> 		/* Then, the copper link */
> 		err = phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_COPPER);
> 		if (err < 0)
> 			goto error;
> 	}
> 
> the code above executes without holding a mutex expect genphy_resume
> 
> 	/* With the page set, use the generic resume */
> 	return genphy_resume(phydev);
> 
> error:
> 	phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_COPPER);
> 	return err;
> }
> 
> So I think the correct way to hold a lock is in phy_* function, not in genphy_*,
> and current genphy_resume and phy_resume is broken in this way.

Suspend and resume are a bit odd. As you found out, everywhere else,
the core takes the mutex before calling into the driver function.

The general rule of thumb, is that many driver writers don't
understand locking. So it is better to do the locking in the core,
which is generally written by people who do understand locking. And
core code gets used more, so bugs tend to be found.

     Andrew
