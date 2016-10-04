From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Subject: Re: [PATCH net-next 2/2] net: phy: Add PHY Auto/Mdi/Mdix set driver
 for Microsemi PHYs.
Date: Tue, 4 Oct 2016 20:01:24 +0530
Message-ID: <20161004143122.GC29274@microsemi.com>
References: <1475064078-22310-1-git-send-email-Raju.Lakkaraju@microsemi.com>
 <1475064078-22310-3-git-send-email-Raju.Lakkaraju@microsemi.com>
 <20160928202451.GC30728@lunn.ch>
Reply-To: <Raju.Lakkaraju@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <f.fainelli@gmail.com>,
        <Allan.Nielsen@microsemi.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0061.outbound.protection.outlook.com ([104.47.41.61]:48064
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751802AbcJDObh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 4 Oct 2016 10:31:37 -0400
Content-Disposition: inline
In-Reply-To: <20160928202451.GC30728@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Thank you for code review and valuable comments.

On Wed, Sep 28, 2016 at 10:24:51PM +0200, Andrew Lunn wrote:
> EXTERNAL EMAIL
> 
> 
> > +     reg_val = phy_read(phydev, MSCC_PHY_BYPASS_CONTROL);
> > +     if ((mdix == ETH_TP_MDI) || (mdix == ETH_TP_MDI_X)) {
> > +             reg_val |= (DISABLE_PAIR_SWAP_CORR_MASK |
> > +                         DISABLE_POLARITY_CORR_MASK  |
> > +                         DISABLE_HP_AUTO_MDIX_MASK);
> > +     } else {
> > +             reg_val &= ~(DISABLE_PAIR_SWAP_CORR_MASK |
> > +                          DISABLE_POLARITY_CORR_MASK  |
> > +                          DISABLE_HP_AUTO_MDIX_MASK);
> > +     }
> > +     rc = phy_write(phydev, MSCC_PHY_BYPASS_CONTROL, reg_val);
> > +     if (rc != 0)
> > +             goto out_unlock;
> > +
> > +     rc = vsc85xx_phy_page_set(phydev, MSCC_PHY_PAGE_EXTENDED);
> > +     if (rc != 0)
> > +             goto out_unlock;
> > +
> > +     reg_val = phy_read(phydev, MSCC_PHY_EXT_MODE_CNTL);
> > +     reg_val &= ~(FORCE_MDI_CROSSOVER_MASK);
> > +     if (mdix == ETH_TP_MDI)
> > +             reg_val |= FORCE_MDI_CROSSOVER_MDI;
> > +     else if (mdix == ETH_TP_MDI_X)
> > +             reg_val |= FORCE_MDI_CROSSOVER_MDIX;
> > +     rc = phy_write(phydev, MSCC_PHY_EXT_MODE_CNTL, reg_val);
> > +     if (rc != 0)
> > +             goto out_unlock;
> > +
> > +     rc = vsc85xx_phy_page_set(phydev, MSCC_PHY_PAGE_STANDARD);
> > +
> > +out_unlock:
> 
> out_unlock seems a bit of an odd name, since you are not unlocking
> anything.
> 

It's my mistake. Mutex should be there. I will add mutex.

> I also wonder if you should try to reset to MSCC_PHY_PAGE_STANDARD in
> the error condition?
> 

> > +
> > +     return rc;
> > +}
> > +
> >  static int vsc85xx_wol_set(struct phy_device *phydev,
> >                          struct ethtool_wolinfo *wol)
> >  {
> > @@ -227,6 +281,7 @@ static int vsc85xx_default_config(struct phy_device *phydev)
> >       int rc;
> >       u16 reg_val;
> >
> > +     phydev->mdix = ETH_TP_MDI_AUTO;
> 
> Humm, interesting. The only other driver supporting mdix is the
> Marvell one. It does not do this, it leaves it to its default value of
> ETH_TP_MDI_INVALID. It does however interpret ETH_TP_MDI_INVALID as
> meaning as ETH_TP_MDI_AUTO.
> 
> There needs to be consistency here. You either need to do the same as
> the Marvell driver, or you need to modify the Marvell driver to also
> set phydev->mdix to ETH_TP_MDI_AUTO.
> 
In Ethtool two variable i.e. eth_tp_mdix_ctrl, eth_tp_mdix use to update
the status. But, driver header is having one variable i.e. mdix.
Driver header should also have another variabl like mdix_ctrl.
Then, Ethtool can get/set the Auto MDIX/MDI.
In case, mdix is not configure with ETH_TP_MDI_AUTO, Ethtool shows error as
"setting MDI not supported"

Please suggest me if you have any better method to fix this issue.

> I don't yet know which of these two is the right thing to do.
> 
> Florian?
> 
>         Andrew

---
Thanks,
Raju.
