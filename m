From: Max Filippov <jcmvbkbc@gmail.com>
Subject: Re: [PATCH v2 4/4] net: ethoc: implement ethtool operations
Date: Thu, 30 Jan 2014 07:04:40 +0400
Message-ID: <CAMo8Bf+9A-yh-_EBmZeJqMhUKrHN5+BPtckFj_gnZ44tfnX__w@mail.gmail.com>
References: <1390975218-13863-1-git-send-email-jcmvbkbc@gmail.com>
	<1390975218-13863-5-git-send-email-jcmvbkbc@gmail.com>
	<1391047176.4405.43.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-xtensa@linux-xtensa.org" <linux-xtensa@linux-xtensa.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Chris Zankel <chris@zankel.net>,
	Marc Gauthier <marc@cadence.com>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1391047176.4405.43.camel@deadeye.wl.decadent.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 30, 2014 at 5:59 AM, Ben Hutchings <ben@decadent.org.uk> wrote:
> On Wed, 2014-01-29 at 10:00 +0400, Max Filippov wrote:
>> The following methods are implemented:
>> - get/set settings;
>> - get registers length/registers;
>> - get link state (standard implementation);
>> - get/set ring parameters;
>> - get timestamping info (standard implementation).
> [...]
>> --- a/drivers/net/ethernet/ethoc.c
>> +++ b/drivers/net/ethernet/ethoc.c
>> [...]
>> +static int ethoc_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
>> +{
>> +     struct ethoc *priv = netdev_priv(dev);
>> +     struct phy_device *phydev = priv->phy;
>> +
>> +     if (!phydev)
>> +             return -ENODEV;
>> +
>> +     return phy_ethtool_gset(phydev, cmd);
>> +}
>> +
>> +static int ethoc_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
>> +{
>> +     struct ethoc *priv = netdev_priv(dev);
>> +     struct phy_device *phydev = priv->phy;
>> +
>> +     if (!phydev)
>> +             return -ENODEV;
>> +
>> +     return phy_ethtool_sset(phydev, cmd);
>> +}
>
> I think these should return -EOPNOTSUPP in the PHY-less case, just as if
> the set_settings pointer was not set.

Ok

> [...]
>> +static void ethoc_get_ringparam(struct net_device *dev,
>> +                             struct ethtool_ringparam *ring)
>> +{
>> +     struct ethoc *priv = netdev_priv(dev);
>> +
>> +     ring->rx_max_pending = priv->num_bd;
>> +     ring->rx_mini_max_pending = 0;
>> +     ring->rx_jumbo_max_pending = 0;
>> +     ring->tx_max_pending = priv->num_bd;
>> +
>> +     ring->rx_pending = priv->num_rx;
>> +     ring->rx_mini_pending = 0;
>> +     ring->rx_jumbo_pending = 0;
>> +     ring->tx_pending = priv->num_tx;
>> +}
>> +
>> +static int ethoc_set_ringparam(struct net_device *dev,
>> +                            struct ethtool_ringparam *ring)
>> +{
>> +     struct ethoc *priv = netdev_priv(dev);
>> +
>> +     if (netif_running(dev))
>> +             return -EBUSY;
>
> This is unhelpful.  Most implementations of this operation will restart
> the interface if it's running.

Ok

>> +     priv->num_tx = rounddown_pow_of_two(ring->tx_pending);
>
> Range check?

May there be requested more than ring->tx_max_pending that we
indicated in the get_ringparam?

>> +     priv->num_rx = priv->num_bd - priv->num_tx;
>> +     if (priv->num_rx > ring->rx_pending)
>> +             priv->num_rx = ring->rx_pending;
>
> So the RX ring may only ever be shrunk?!  Did you mean to compare with
> priv->num_bd instead?

First all non-TX descriptors are made RX, and if that's more than user
requested I trim it.

>> +     return 0;
>> +}
>> +
>> +const struct ethtool_ops ethoc_ethtool_ops = {
>
> static

Ok

-- 
Thanks.
-- Max
