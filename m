From: Doug Berger <opendmb@gmail.com>
Subject: Re: [PATCH net-next 02/12] net: phy: bcm7xxx: add support for 28nm
 EPHY
Date: Mon, 13 Mar 2017 19:06:25 -0700
Message-ID: <3e5f7ac9-7e97-60f1-3986-4045522a65f5@gmail.com>
References: <20170314004142.4746-1-opendmb@gmail.com>
 <20170314004142.4746-3-opendmb@gmail.com> <20170314010651.GO15842@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, robh+dt@kernel.org, mark.rutland@arm.com,
        davem@davemloft.net, rafal@milecki.pl, xow@google.com,
        joel@jms.id.au, jon.mason@broadcom.com, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        pgynther@google.com, jaedon.shin@gmail.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170314010651.GO15842@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/13/2017 06:06 PM, Andrew Lunn wrote:
> On Mon, Mar 13, 2017 at 05:41:32PM -0700, Doug Berger wrote:
>> +static int bcm7xxx_28nm_ephy_01_afe_config_init(struct phy_device *phydev)
>> +{
>> +	int ret;
>> +
>> +	/* set shadow mode 2 */
>> +	ret = phy_set_clr_bits(phydev, MII_BCM7XXX_TEST,
>> +			       MII_BCM7XXX_SHD_MODE_2, 0);
>> +	if (ret < 0)
>> +		return ret;
>> +
>> +	/* Set current trim values INT_trim = -1, Ext_trim =0 */
>> +	ret = phy_write(phydev, MII_BCM7XXX_SHD_2_BIAS_TRIM, 0x3BE0);
>> +	if (ret < 0)
>> +		goto reset_shadow_mode;
>> +
>> +	/* Cal reset */
>> +	ret = phy_write(phydev, MII_BCM7XXX_SHD_2_ADDR_CTRL,
>> +			MII_BCM7XXX_SHD_3_TL4);
>> +	if (ret < 0)
>> +		goto reset_shadow_mode;
> 
> Hi Doug
> 
> It would be nice to have a few blank lines here and there...
> 
Thanks for taking the time to review this.

In general I try to keep lines of related functionality together and use
the blank lines to help identify boundaries.  In this particular case, I
believe it is clearer to keep the code that may return an error code
together with the code that tests for the error.

Perhaps this would be a better alternative:
+	/* Set current trim values INT_trim = -1, Ext_trim =0 */
+	if (phy_write(phydev, MII_BCM7XXX_SHD_2_BIAS_TRIM, 0x3BE0) < 0)
+		goto reset_shadow_mode;
+
+	/* Cal reset */
+	if (phy_write(phydev, MII_BCM7XXX_SHD_2_ADDR_CTRL,
+		      MII_BCM7XXX_SHD_3_TL4) < 0)
+		goto reset_shadow_mode;

>> +	ret = phy_set_clr_bits(phydev, MII_BCM7XXX_SHD_2_CTRL_STAT,
>> +			       MII_BCM7XXX_TL4_RST_MSK, 0);
>> +	if (ret < 0)
>> +		goto reset_shadow_mode;
>> +
>> +	/* Cal reset disable */
>> +	ret = phy_write(phydev, MII_BCM7XXX_SHD_2_ADDR_CTRL,
>> +			MII_BCM7XXX_SHD_3_TL4);
>> +	if (ret < 0)
>> +		goto reset_shadow_mode;
> 
> ... just to break things up into readable chunks.
> 
Maybe:
+	if (phy_set_clr_bits(phydev, MII_BCM7XXX_SHD_2_CTRL_STAT,
+			     MII_BCM7XXX_TL4_RST_MSK, 0) < 0)
+		goto reset_shadow_mode;
+
+	/* Cal reset disable */
+	if (phy_write(phydev, MII_BCM7XXX_SHD_2_ADDR_CTRL,
+		      MII_BCM7XXX_SHD_3_TL4) < 0)
+		goto reset_shadow_mode;

>> +	ret = phy_set_clr_bits(phydev, MII_BCM7XXX_SHD_2_CTRL_STAT,
>> +			       0, MII_BCM7XXX_TL4_RST_MSK);
>> +	if (ret < 0)
>> +		goto reset_shadow_mode;
>> +
>> +reset_shadow_mode:
>> +	/* reset shadow mode 2 */
>> +	ret = phy_set_clr_bits(phydev, MII_BCM7XXX_TEST, 0,
>> +			       MII_BCM7XXX_SHD_MODE_2);
>> +	if (ret < 0)
>> +		return ret;
>> +
>> +	return 0;
> 
> How about:
> 
> 	return phy_set_clr_bits(phydev, MII_BCM7XXX_TEST, 0,
> 	       		        MII_BCM7XXX_SHD_MODE_2);
> 
The trouble here is that currently the phy_set_clr_bits() function
returns the value written or a negative error and the function
bcm7xxx_28nm_ephy_01_afe_config_init() is supposed to return 0 on
success and non-zero on failure so this would not have the same
functionality.  I suppose we could change the phy_set_clr_bits() API to
return 0 on success to make this work, but I wasn't trying to change
preexisting functionality in this file.

>> +/* The 28nm EPHY does not support Clause 45 (MMD) used by bcm-phy-lib */
>> +static int bcm7xxx_28nm_ephy_apd_enable(struct phy_device *phydev)
>> +{
>> +	int ret;
>> +
>> +	/* set shadow mode 1 */
>> +	ret = phy_set_clr_bits(phydev, MII_BRCM_FET_BRCMTEST,
>> +			       MII_BRCM_FET_BT_SRE, 0);
>> +	if (ret < 0)
>> +		return ret;
>> +
>> +	/* Enable auto-power down */
>> +	ret = phy_set_clr_bits(phydev, MII_BRCM_FET_SHDW_AUXSTAT2,
>> +			       MII_BRCM_FET_SHDW_AS2_APDE, 0);
>> +	if (ret < 0)
>> +		return ret;
>> +
>> +	/* reset shadow mode 1 */
>> +	ret = phy_set_clr_bits(phydev, MII_BRCM_FET_BRCMTEST, 0,
>> +			       MII_BRCM_FET_BT_SRE);
>> +	if (ret < 0)
>> +		return ret;
>> +
>> +	return 0;
> 
> How about just
> 
>     return phy_set_clr_bits(phydev, MII_BRCM_FET_BRCMTEST, 0,
>     	   		       MII_BRCM_FET_BT_SRE);
> 
Same remark as above.

>> +}
>> +
>> +static int bcm7xxx_28nm_ephy_eee_enable(struct phy_device *phydev)
>> +{
>> +	int ret;
>> +
>> +	/* set shadow mode 2 */
>> +	ret = phy_set_clr_bits(phydev, MII_BCM7XXX_TEST,
>> +			       MII_BCM7XXX_SHD_MODE_2, 0);
>> +	if (ret < 0)
>> +		return ret;
>> +
>> +	/* Advertise supported modes */
>> +	ret = phy_write(phydev, MII_BCM7XXX_SHD_2_ADDR_CTRL,
>> +			MII_BCM7XXX_SHD_3_AN_EEE_ADV);
>> +	if (ret < 0)
>> +		goto reset_shadow_mode;
> 
> blank...
> 
>> +	ret = phy_write(phydev, MII_BCM7XXX_SHD_2_CTRL_STAT,
>> +			MDIO_EEE_100TX);
>> +	if (ret < 0)
>> +		goto reset_shadow_mode;
Here the two phy_write() calls are required to "/* Advertise supported
modes */" (one sets an address and the other specifies the data to write
to that address) so I kept them together to imply an association with
the preceding comment.  If new code in the future came between them it
would be "bad" so closing the space helps indicate that it is not a safe
coding boundary for inserting code.

>> +
>> +	/* Restore Defaults */
>> +	ret = phy_write(phydev, MII_BCM7XXX_SHD_2_ADDR_CTRL,
>> +			MII_BCM7XXX_SHD_3_PCS_CTRL_2);
>> +	if (ret < 0)
>> +		goto reset_shadow_mode;
>> +	ret = phy_write(phydev, MII_BCM7XXX_SHD_2_CTRL_STAT,
>> +			MII_BCM7XXX_PCS_CTRL_2_DEF);
>> +	if (ret < 0)
>> +		goto reset_shadow_mode;
Same here.

>> +
>> +	ret = phy_write(phydev, MII_BCM7XXX_SHD_2_ADDR_CTRL,
>> +			MII_BCM7XXX_SHD_3_EEE_THRESH);
>> +	if (ret < 0)
>> +		goto reset_shadow_mode;
>> +	ret = phy_write(phydev, MII_BCM7XXX_SHD_2_CTRL_STAT,
>> +			MII_BCM7XXX_EEE_THRESH_DEF);
>> +	if (ret < 0)
>> +		goto reset_shadow_mode;
Here...

>> +
>> +	/* Enable EEE autonegotiation */
>> +	ret = phy_write(phydev, MII_BCM7XXX_SHD_2_ADDR_CTRL,
>> +			MII_BCM7XXX_SHD_3_AN_STAT);
>> +	if (ret < 0)
>> +		goto reset_shadow_mode;
>> +	ret = phy_write(phydev, MII_BCM7XXX_SHD_2_CTRL_STAT,
>> +			(MII_BCM7XXX_AN_NULL_MSG_EN | MII_BCM7XXX_AN_EEE_EN));
>> +	if (ret < 0)
>> +		goto reset_shadow_mode;
and here.

>> +
>> +reset_shadow_mode:
>> +	/* reset shadow mode 2 */
>> +	ret = phy_set_clr_bits(phydev, MII_BCM7XXX_TEST, 0,
>> +			       MII_BCM7XXX_SHD_MODE_2);
>> +	if (ret < 0)
>> +		return ret;
>> +
>> +	/* Restart autoneg */
>> +	phy_write(phydev, MII_BMCR,
>> +		  (BMCR_SPEED100 | BMCR_ANENABLE | BMCR_ANRESTART));
>> +
>> +	return 0;
> 
>   return phy_write(.....); ?
> 
I would feel more comfortable with this if the return value of the
struct mii_bus write member function was more clearly defined.  In our
case, we return 0 on success so I would consider this change, but I
would prefer a consensus that all mii_bus write functions return 0 on
success before doing so.

>> +}
> 
>   Andrew
> 
Thanks again,
    Doug
