From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 4/4] macvlan: export macvlan mode through netlink
Date: Tue, 24 Nov 2009 11:53:34 +0100
Message-ID: <4B0BBB2E.8020502@trash.net>
References: <1259024166-28158-1-git-send-email-arnd@arndb.de> <1259024166-28158-5-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Patrick Mullaney <pmullaney@novell.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Edge Virtual Bridging <evb@yahoogroups.com>,
	Anna Fischer <anna.fischer@hp.com>,
	bridge@lists.linux-foundation.org,
	virtualization@lists.linux-foundation.org,
	Jens Osterkamp <jens@linux.vnet.ibm.com>,
	Gerhard Stenzel <gerhard.stenzel@de.ibm.com>,
	Mark Smith <lk-netdev@lk-netdev.nosense.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932782AbZKXKxc@vger.kernel.org>
In-Reply-To: <1259024166-28158-5-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnd Bergmann wrote:
> @@ -600,6 +594,18 @@ static int macvlan_validate(struct nlattr *tb[], struct nlattr *data[])
>  		if (!is_valid_ether_addr(nla_data(tb[IFLA_ADDRESS])))
>  			return -EADDRNOTAVAIL;
>  	}
> +
> +	if (data && data[IFLA_MACVLAN_MODE]) {
> +		u32 mode = nla_get_u32(data[IFLA_MACVLAN_MODE]);
> +		switch (mode) {
> +		case MACVLAN_MODE_PRIVATE:
> +		case MACVLAN_MODE_VEPA:
> +		case MACVLAN_MODE_BRIDGE:
> +			break;
> +		default:
> +			return -EINVAL;

EINVAL is quite unspecific. In this case I think EOPNOTSUPP would
be fine and provide more information.

> +		}
> +	}
>  	return 0;
>  }
> @@ -664,6 +670,13 @@ static int macvlan_newlink(struct net *src_net, struct net_device *dev,
>  	vlan->dev      = dev;
>  	vlan->port     = port;
>  
> +	vlan->mode     = MACVLAN_MODE_VEPA;
> +	if (data && data[IFLA_MACVLAN_MODE]) {
> +		u32 mode = nla_get_u32(data[IFLA_MACVLAN_MODE]);
> +
> +		vlan->mode     = mode;

This looks a bit strange, like cut-and-paste without reformatting :)
I'd suggest to simply use "vlan->mode = nla_get_u32(...)".

> +	}
> +
>  	err = register_netdevice(dev);
>  	if (err < 0)
>  		return err;
> @@ -685,6 +698,39 @@ static void macvlan_dellink(struct net_device *dev, struct list_head *head)
>  		macvlan_port_destroy(port->dev);
>  }
>  
> +static int macvlan_changelink(struct net_device *dev,
> +		struct nlattr *tb[], struct nlattr *data[])
> +{
> +	struct macvlan_dev *vlan = netdev_priv(dev);
> +	if (data && data[IFLA_MACVLAN_MODE]) {
> +		u32 mode = nla_get_u32(data[IFLA_MACVLAN_MODE]);
> +		vlan->mode     = mode;

Same here.

> +	}
> +
> +	return 0;
> +}
