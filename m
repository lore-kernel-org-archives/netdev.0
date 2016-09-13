From: John Crispin <john@phrozen.org>
Subject: Re: [PATCH 3/3] net-next: dsa: add new driver for qca8xxx family
Date: Tue, 13 Sep 2016 10:04:49 +0200
Message-ID: <7f9c1463-1cc0-e230-e7fe-dbb434427251@phrozen.org>
References: <1473669337-21221-1-git-send-email-john@phrozen.org>
 <1473669337-21221-4-git-send-email-john@phrozen.org>
 <20160913004047.GB3585@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        qsdk-review@qca.qualcomm.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160913004047.GB3585@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 13/09/2016 02:40, Andrew Lunn wrote:
>> > +static int
>> > +qca8k_get_eee(struct dsa_switch *ds, int port,
>> > +	      struct ethtool_eee *e)
>> > +{
>> > +	struct qca8k_priv *priv = qca8k_to_priv(ds);
>> > +	struct ethtool_eee *p = &priv->port_sts[qca8k_phy_to_port(port)].eee;
>> > +	u32 lp, adv, supported;
>> > +	u16 val;
>> > +
>> > +	/* The switch has no way to tell the result of the AN so we need to
>> > +	 * read the result directly from the PHYs MMD registers
>> > +	 */
>> > +	val = qca8k_phy_mmd_read(priv, port, MDIO_MMD_PCS, MDIO_PCS_EEE_ABLE);
>> > +	supported = mmd_eee_cap_to_ethtool_sup_t(val);
>> > +
>> > +	val = qca8k_phy_mmd_read(priv, port, MDIO_MMD_AN, MDIO_AN_EEE_ADV);
>> > +	adv = mmd_eee_adv_to_ethtool_adv_t(val);
>> > +
>> > +	val = qca8k_phy_mmd_read(priv, port, MDIO_MMD_AN, MDIO_AN_EEE_LPABLE);
>> > +	lp = mmd_eee_adv_to_ethtool_adv_t(val);
>> > +
>> > +	e->eee_enabled = p->eee_enabled;
>> > +	e->eee_active = !!(supported & adv & lp);
>> > +
>> > +	return 0;
>> > +}
> Couldn't you just call phy_ethtool_get_eee(phydev)? Then you don't
> need qca8k_phy_mmd_read()?

Hi Andrew,

this function does indeed duplicate the functionality of
phy_ethtool_get_eee() with the small difference, that e->eee_active is
also set which phy_ethtool_get_eee() does not set.

dsa_slave_get_eee() will call phy_ethtool_get_eee() right after the
get_eee() op has been called. would it be ok to move the code setting
eee_active to  phy_ethtool_get_eee(). if thats possible then we could
just have a stub inside the dsa driver with a note saying that the dsa
layer will do the magic for us.

	John
