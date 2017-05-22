From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v3 net-next 3/5] dsa: add DSA switch driver for Microchip
 KSZ9477
Date: Mon, 22 May 2017 23:27:57 +0200
Message-ID: <20170522212757.GS29447@lunn.ch>
References: <9235D6609DB808459E95D78E17F2E43D40A7C023@CHN-SV-EXMX02.mchp-main.com>
 <20170522143134.GC29447@lunn.ch>
 <9235D6609DB808459E95D78E17F2E43D40A81210@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f.fainelli@gmail.com, vivien.didelot@savoirfairelinux.com,
        sergei.shtylyov@cogentembedded.com, netdev@vger.kernel.org,
        davem@davemloft.net, UNGLinuxDriver@microchip.com
To: Woojung.Huh@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:40391 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933607AbdEVV2B (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 22 May 2017 17:28:01 -0400
Content-Disposition: inline
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D40A81210@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 22, 2017 at 09:21:28PM +0000, Woojung.Huh@microchip.com wrote:
> Hi Andres,
> 
> > > +static struct {
> > > +	int index;
> > > +	char string[ETH_GSTRING_LEN];
> > 
> > Hi Woojung
> > 
> > Since you need to respin for the skb_put_padto(), please make this
> > const.
> OK.
> 
> > > +static int get_vlan_table(struct dsa_switch *ds, u16 vid, u32 *vlan_table)
> > > +{
> > > +	struct ksz_device *dev = ds->priv;
> > > +	u8 data;
> > > +	int timeout = 1000;
> > > +
> > > +	ksz_write16(dev, REG_SW_VLAN_ENTRY_INDEX__2, vid &
> > VLAN_INDEX_M);
> > > +	ksz_write8(dev, REG_SW_VLAN_CTRL, VLAN_READ | VLAN_START);
> > > +
> > > +	/* wait to be cleared */
> > > +	data = 0;
> > > +	do {
> > > +		ksz_read8(dev, REG_SW_VLAN_CTRL, &data);
> > > +		if (!(data & VLAN_START))
> > > +			break;
> > > +		usleep_range(1, 10);
> > > +	} while (timeout-- > 0);
> > > +
> > > +	if (!timeout)
> > > +		return -ETIMEDOUT;
> > > +
> > > +	ksz_read32(dev, REG_SW_VLAN_ENTRY__4, &vlan_table[0]);
> > > +	ksz_read32(dev, REG_SW_VLAN_ENTRY_UNTAG__4,
> > &vlan_table[1]);
> > > +	ksz_read32(dev, REG_SW_VLAN_ENTRY_PORTS__4, &vlan_table[2]);
> > > +
> > > +	ksz_write8(dev, REG_SW_VLAN_CTRL, 0);
> > > +
> > > +	return 0;
> > > +}
> > > +
> > > +static int set_vlan_table(struct dsa_switch *ds, u16 vid, u32 *vlan_table)
> > > +{
> > > +	struct ksz_device *dev = ds->priv;
> > > +	u8 data;
> > > +	int timeout = 1000;
> > > +
> > > +	ksz_write32(dev, REG_SW_VLAN_ENTRY__4, vlan_table[0]);
> > > +	ksz_write32(dev, REG_SW_VLAN_ENTRY_UNTAG__4, vlan_table[1]);
> > > +	ksz_write32(dev, REG_SW_VLAN_ENTRY_PORTS__4, vlan_table[2]);
> > > +
> > > +	ksz_write16(dev, REG_SW_VLAN_ENTRY_INDEX__2, vid &
> > VLAN_INDEX_M);
> > > +	ksz_write8(dev, REG_SW_VLAN_CTRL, VLAN_START | VLAN_WRITE);
> > > +
> > > +	do {
> > > +		ksz_read8(dev, REG_SW_VLAN_CTRL, &data);
> > > +		if (!(data & VLAN_START))
> > > +			break;
> > > +		usleep_range(1, 10);
> > > +	} while (timeout-- > 0);
> > > +
> > > +	if (!timeout)
> > > +		return -ETIMEDOUT;
> > > +
> > > +	ksz_write8(dev, REG_SW_VLAN_CTRL, 0);
> > > +
> > > +	mutex_lock(&dev->vlancache_mutex);
> > 
> > Humm. I think this is wrong. Shouldn't you hold the mutex while you
> > change the hardware as well as the cache. Otherwise there is a risk
> > your cache could be different to the hardware when you get a race
> > between two threads?
> Thanks for pointing this out.
> Rather than two separate mutex (H/W and vlancache), will put one HW access mutex
> around get_vlan_table and set_vlan_table to cover vlancache access too. Even though
> little bit overhead. How do you think?

I would move the mutex_lock(&dev->vlancache_mutex) to be beginning of
the function. It then protects both the hardware and the vlan cache,
and keeps them synchronised.

    Andrew
