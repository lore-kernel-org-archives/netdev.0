From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH net-next v3 5/5] net-next: dsa: add dsa support for
 Mediatek MT7530 switch
Date: Thu, 30 Mar 2017 01:12:51 +0200
Message-ID: <20170329231251.GH28922@lunn.ch>
References: <1490780303-18598-1-git-send-email-sean.wang@mediatek.com>
 <1490780303-18598-6-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, vivien.didelot-4ysUXcep3aM1wj+D4I0NRVaTQe2KTcn/@public.gmane.org,
        matthias.bgg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, Landen.Chao-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org, keyhaede-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        objelf-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1490780303-18598-6-git-send-email-sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> +static struct mt7530_priv *lpriv;

Hi Sean

Why do you need this global variable? What if somebody has two
switches connected?

> +static void mt7530_port_disable(struct dsa_switch *ds, int port,
> +				struct phy_device *phy);
> +static int mt7530_cpu_port_enable(struct mt7530_priv *priv,
> +				  int port);

It is better to move the functions around than have forward
declarations.

> +static u32
> +_mt7530_read(u32 reg)
> +{
> +	struct mt7530_priv	*priv = lpriv;
> +	struct mii_bus		*bus = priv->bus;
> +	u32 val;
> +
> +	mutex_lock_nested(&bus->mdio_lock, MDIO_MUTEX_NESTED);
> +
> +	val = mt7530_mii_read(priv, reg);
> +
> +	mutex_unlock(&bus->mdio_lock);
> +
> +	return val;
> +}
> +
> +static u32
> +mt7530_read(struct mt7530_priv *priv, u32 reg)
> +{
> +	return _mt7530_read(reg);
> +}

So here you would pass priv to _mt7530_read().

> +static int
> +mt7530_fdb_cmd(struct mt7530_priv *priv, enum mt7530_fdb_cmd cmd, u32 *rsp)
> +{
> +	u32 val;
> +	int ret;
> +
> +	/* Set the command operating upon the MAC address entries */
> +	val = ATC_BUSY | ATC_MAT(0) | cmd;
> +	mt7530_write(priv, MT7530_ATC, val);
> +
> +	ret = readx_poll_timeout(_mt7530_read, MT7530_ATC, val,
> +				 !(val & ATC_BUSY), 20, 20000);

This is where your need for lpriv comes, you can only pass a single
argument. But you can work around it. readx_poll_timeout is a
#define. So there is no type check for _mt7530_read, or the arg passed
to it. So pass a struct containing the address and priv.

I think you can then kill of your global lpriv.

  Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
