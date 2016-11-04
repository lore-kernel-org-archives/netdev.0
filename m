From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 5/5] net: phy: Add downshift get/set support in
 Microsemi PHYs driver
Date: Fri, 4 Nov 2016 13:27:46 +0100
Message-ID: <20161104122746.GK13959@lunn.ch>
References: <1478255742-25693-1-git-send-email-allan.nielsen@microsemi.com>
 <1478255742-25693-6-git-send-email-allan.nielsen@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
        raju.lakkaraju@microsemi.com, cphealy@gmail.com, robh@kernel.org
To: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:36823 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932486AbcKDM1t (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 4 Nov 2016 08:27:49 -0400
Content-Disposition: inline
In-Reply-To: <1478255742-25693-6-git-send-email-allan.nielsen@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Allan

> +static int vsc85xx_downshift_get(struct phy_device *phydev, u8 *count)
> +{
> +	int rc;
> +	u16 reg_val;
> +
> +	mutex_lock(&phydev->lock);
> +	rc = vsc85xx_phy_page_set(phydev, MSCC_PHY_PAGE_EXTENDED);
> +	if (rc != 0)
> +		goto out_unlock;
> +
> +	reg_val = phy_read(phydev, MSCC_PHY_ACTIPHY_CNTL);
> +	reg_val &= DOWNSHIFT_CNTL_MASK;
> +	if (!(reg_val & DOWNSHIFT_EN))
> +		*count = 0;

DOWNSHIFT_DEV_DISABLE

> +	else
> +		*count = ((reg_val & ~DOWNSHIFT_EN) >> DOWNSHIFT_CNTL_POS) + 2;
>
> +	rc = vsc85xx_phy_page_set(phydev, MSCC_PHY_PAGE_STANDARD);
> +
> +out_unlock:
> +	mutex_unlock(&phydev->lock);
> +
> +	return rc;
> +}
> +
> +static int vsc85xx_downshift_set(struct phy_device *phydev, u8 count)
> +{
> +	int rc;
> +	u16 reg_val;
> +
> +	if (count == DOWNSHIFT_DEV_DEFAULT_COUNT) {
> +		/* Default downshift count 3 (i.e. Bit3:2 = 0b01) */
> +		count = ((1 << DOWNSHIFT_CNTL_POS) | DOWNSHIFT_EN);
> +	} else if (count > DOWNSHIFT_COUNT_MAX || count == 1) {
> +		phydev_err(phydev, "Invalid downshift count\n");

Maybe include a hint what is valid?

> +		return -EINVAL;

ERANGE? I don't know error codes too well, so this needs verifying.

> +	} else if (count) {
> +		/* Downshift count is either 2,3,4 or 5 */
> +		count = (((count - 2) << DOWNSHIFT_CNTL_POS) | DOWNSHIFT_EN);

Ah, now i see why + 2. But this means it never does what you ask it to
do. It would be better to round up < 2 to 2, and leave all the others
as is.

> +static int vsc85xx_get_tunable(struct phy_device *phydev,
> +			       struct ethtool_tunable *tuna, void *data)
> +{
> +	switch (tuna->id) {
> +	case ETHTOOL_PHY_DOWNSHIFT:
> +		return vsc85xx_downshift_get(phydev, (u8 *)data);
> +	default:
> +		phydev_err(phydev, "Unsupported PHY tunable id\n");
> +		return -EINVAL;

This is not really a error you should complain about. There could be
many tunables, and some your hardware cannot support. So return
-ENOSUPP and no phydev_err().

> +	}
> +}
> +
> +static int vsc85xx_set_tunable(struct phy_device *phydev,
> +			       struct ethtool_tunable *tuna,
> +			       const void *data)
> +{
> +	switch (tuna->id) {
> +	case ETHTOOL_PHY_DOWNSHIFT:
> +		return vsc85xx_downshift_set(phydev, *(u8 *)data);
> +	default:
> +		phydev_err(phydev, "Unsupported PHY tunable id\n");
> +		return -EINVAL;

Same as above.

     Andrew
