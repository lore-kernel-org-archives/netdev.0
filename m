From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next v2 1/3] net: dsa: use slave device phydev
Date: Fri, 22 Sep 2017 16:11:46 -0400
Message-ID: <87r2uymr25.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170922194045.18814-1-vivien.didelot@savoirfairelinux.com> <20170922194045.18814-2-vivien.didelot@savoirfairelinux.com> <2262f266-6fb9-cce4-f83a-933dd41b9062@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2262f266-6fb9-cce4-f83a-933dd41b9062@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Florian,

Florian Fainelli <f.fainelli@gmail.com> writes:

> On 09/22/2017 12:40 PM, Vivien Didelot wrote:
>> There is no need to store a phy_device in dsa_slave_priv since
>> net_device already provides one. Simply s/p->phy/dev->phydev/.
>
> You can therefore remove the phy_device from dsa_slave_priv, see below
> for more comments. I will have to regress test the heck out of this,
> this should take a few hours.

OK, since this is a sensible topic, I will respin a v3 without this
patch, so that a future patchset can address your comments below and
also gives you time to test this one patch alone.

>>  static int dsa_slave_port_attr_set(struct net_device *dev,
>> @@ -435,12 +433,10 @@ static int
>>  dsa_slave_get_link_ksettings(struct net_device *dev,
>>  			     struct ethtool_link_ksettings *cmd)
>>  {
>> -	struct dsa_slave_priv *p = netdev_priv(dev);
>> +	if (!dev->phydev)
>> +		return -ENODEV;
>>  
>> -	if (!p->phy)
>> -		return -EOPNOTSUPP;
>> -
>> -	phy_ethtool_ksettings_get(p->phy, cmd);
>> +	phy_ethtool_ksettings_get(dev->phydev, cmd);
>
> This can be replaced by phy_ethtool_get_link_ksettings()
>
>>  
>>  	return 0;
>>  }
>> @@ -449,12 +445,10 @@ static int
>>  dsa_slave_set_link_ksettings(struct net_device *dev,
>>  			     const struct ethtool_link_ksettings *cmd)
>>  {
>> -	struct dsa_slave_priv *p = netdev_priv(dev);
>> +	if (!dev->phydev)
>> +		return -ENODEV;
>>  
>> -	if (p->phy != NULL)
>> -		return phy_ethtool_ksettings_set(p->phy, cmd);
>> -
>> -	return -EOPNOTSUPP;
>> +	return phy_ethtool_ksettings_set(dev->phydev, cmd);
>>  }
>
> This can disappear and you can assign this ethtool operation to
> phy_ethtool_set_link_ksettings()
>
>>  
>>  static void dsa_slave_get_drvinfo(struct net_device *dev,
>> @@ -488,24 +482,20 @@ dsa_slave_get_regs(struct net_device *dev, struct ethtool_regs *regs, void *_p)
>>  
>>  static int dsa_slave_nway_reset(struct net_device *dev)
>>  {
>> -	struct dsa_slave_priv *p = netdev_priv(dev);
>> +	if (!dev->phydev)
>> +		return -ENODEV;
>>  
>> -	if (p->phy != NULL)
>> -		return genphy_restart_aneg(p->phy);
>> -
>> -	return -EOPNOTSUPP;
>> +	return genphy_restart_aneg(dev->phydev);
>>  }
>
> This can now disappear and you can use phy_ethtool_nway_reset() directly
> in ethtool_ops
>
>>  
>>  static u32 dsa_slave_get_link(struct net_device *dev)
>>  {
>> -	struct dsa_slave_priv *p = netdev_priv(dev);
>> +	if (!dev->phydev)
>> +		return -ENODEV;
>>  
>> -	if (p->phy != NULL) {
>> -		genphy_update_link(p->phy);
>> -		return p->phy->link;
>> -	}
>> +	genphy_update_link(dev->phydev);
>>  
>> -	return -EOPNOTSUPP;
>> +	return dev->phydev->link;
>>  }
>
> This should certainly be just ethtool_op_get_link(), not sure why we
> kept that around here...

Haaa, good to read that! I wasn't sure about this, but with this patch
the slave phy ethtool functions seemed indeed quite generic...


Thanks,

        Vivien
