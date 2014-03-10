From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: Re: [PATCH] net: phy: fix uninitalized WOL parameters in phy_ethtool_get_wol
Date: Mon, 10 Mar 2014 10:49:53 +0000
Message-ID: <531D98D1.4000707@gmail.com>
References: <1394413270-7169-1-git-send-email-sebastian.hesselbarth@gmail.com> <1394419893.15968.88.camel@deadeye.wl.decadent.org.uk>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394419893.15968.88.camel@deadeye.wl.decadent.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/10/2014 02:51 AM, Ben Hutchings wrote:
> On Mon, 2014-03-10 at 02:01 +0100, Sebastian Hesselbarth wrote:
>> phy_ethtool_get_wol is a helper to get current WOL settings from
>> a phy device. When using this helper on a PHY without .get_wol
>> callback, struct ethtool_wolinfo is never set-up correctly and
>> may contain misleading information about WOL status.
>>
>> To fix this, always zero relevant fields of struct ethtool_wolinfo
>> regardless of .get_wol callback availability.
>
> I think it's the caller's responsibility to zero out struct
> ethtool_wolinfo.  That is what ethtool_get_wol() does.

Actually, phy_ethtool_get_wol is the caller here. This belongs to
a set of helpers that deal with phy_device, not netdev.

> Maybe you could split ethtool_get_wol() like we did
> ethtool_get_settings(), to support in-kernel invocation of ETHTOOL_GWOL?

Looking at the other users of phy_ethtool_get_wol (mv643xx_eth and
cpsw), both drivers use this helper to determine what to pass back
on the corresponding ethtool_get_wol call.

BTW, both drivers above do zero ethtool_wolinfo before calling
phy_ethtool_get_wol. I can either zero it in phy_suspend too or we
deal with it properly in phy_ethtool_get_wol instead:

void phy_ethtool_get_wol(struct phy_device *phydev, struct 
ethtool_wolinfo *wol)
{
	memset(wol, 0, sizeof(*wol));

	if (phydev && phydev->drv->get_wol)
		phydev->drv->get_wol(phydev, wol);
}

That would also simplify above drivers down to e.g:

static void cpsw_get_wol(struct net_device *ndev, struct ethtool_wolinfo 
*wol)
{
	struct cpsw_priv *priv = netdev_priv(ndev);
	int slave_no = cpsw_slave_index(priv);
	phy_ethtool_get_wol(priv->slaves[slave_no].phy, wol);
}

instead of:

static void cpsw_get_wol(struct net_device *ndev, struct ethtool_wolinfo 
*wol)
{
	struct cpsw_priv *priv = netdev_priv(ndev);
	int slave_no = cpsw_slave_index(priv);

	wol->supported = 0;
	wol->wolopts = 0;

	if (priv->slaves[slave_no].phy)
		phy_ethtool_get_wol(priv->slaves[slave_no].phy, wol);
}

>> Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
>> ---
>> Cc: David Miller <davem@davemloft.net>
>> Cc: Florian Fainelli <f.fainelli@gmail.com>
>> Cc: netdev@vger.kernel.org
>> Cc: linux-arm-kernel@lists.infradead.org
>> Cc: linux-kernel@vger.kernel.org
>> ---
>>   drivers/net/phy/phy.c | 1 +
>>   1 file changed, 1 insertion(+)
>>
>> diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
>> index 19c9eca0ef26..62a7cd401e1c 100644
>> --- a/drivers/net/phy/phy.c
>> +++ b/drivers/net/phy/phy.c
>> @@ -1092,6 +1092,7 @@ EXPORT_SYMBOL(phy_ethtool_set_wol);
>>
>>   void phy_ethtool_get_wol(struct phy_device *phydev, struct ethtool_wolinfo *wol)
>>   {
>> +	wol->supported = wol->wolopts = 0;
>>   	if (phydev->drv->get_wol)
>>   		phydev->drv->get_wol(phydev, wol);
>>   }
>
