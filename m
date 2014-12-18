From: "Varlese, Marco" <marco.varlese@intel.com>
Subject: RE: [RFC PATCH net-next v2 1/1] net: Support for switch port
 configuration
Date: Thu, 18 Dec 2014 15:20:26 +0000
Message-ID: <C4896FB061E7DE4AAC93031BDCA044B104AD9EC4@IRSMSX108.ger.corp.intel.com>
References: <C4896FB061E7DE4AAC93031BDCA044B104AD7B82@IRSMSX108.ger.corp.intel.com>
 <20141218114145.GH28766@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Fastabend, John R" <john.r.fastabend@intel.com>,
	Jiri Pirko <jiri@resnulli.us>,
	"roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141218114145.GH28766@casper.infradead.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Thomas Graf [mailto:tgr@infradead.org] On Behalf Of Thomas Graf
> Sent: Thursday, December 18, 2014 11:42 AM
> To: Varlese, Marco
> Cc: netdev@vger.kernel.org; Fastabend, John R; Jiri Pirko;
> roopa@cumulusnetworks.com; sfeldma@gmail.com; linux-
> kernel@vger.kernel.org
> Subject: Re: [RFC PATCH net-next v2 1/1] net: Support for switch port
> configuration
> 
> On 12/18/14 at 11:29am, Varlese, Marco wrote:
> > diff --git a/include/uapi/linux/if_link.h
> > b/include/uapi/linux/if_link.h index f7d0d2d..19cb51a 100644
> > --- a/include/uapi/linux/if_link.h
> > +++ b/include/uapi/linux/if_link.h
> > @@ -146,6 +146,7 @@ enum {
> >  	IFLA_PHYS_PORT_ID,
> >  	IFLA_CARRIER_CHANGES,
> >  	IFLA_PHYS_SWITCH_ID,
> > +	IFLA_SWITCH_PORT_CFG,
> >  	__IFLA_MAX
> >  };
> 
> Needs an entry in ifla_policy[]
> 
>         [IFLA_SWITCH_PORT_CFG] = { .type = NLA_NESTED },
> 
> > @@ -603,4 +604,18 @@ enum {
> >
> >  #define IFLA_HSR_MAX (__IFLA_HSR_MAX - 1)
> >
> > +/* Switch Port Attributes section */
> > +
> > +enum {
> > +	IFLA_ATTR_UNSPEC,
> > +	IFLA_ATTR_LEARNING,
> > +	IFLA_ATTR_LOOPBACK,
> > +	IFLA_ATTR_BCAST_FLOODING,
> > +	IFLA_ATTR_UCAST_FLOODING,
> > +	IFLA_ATTR_MCAST_FLOODING,
> > +	__IFLA_ATTR_MAX
> > +};
> > +
> > +#define IFLA_ATTR_MAX (__IFLA_ATTR_MAX - 1)
> 
> Change the prefix to IFLA_SW_* since it's switch specific?
> 
> >
> > +#ifdef CONFIG_NET_SWITCHDEV
> > +static int do_setswcfg(struct net_device *dev, struct nlattr *attr) {
> > +	int rem, err = -EINVAL;
> > +	struct nlattr *v;
> > +	const struct net_device_ops *ops = dev->netdev_ops;
> > +
> > +	nla_for_each_nested(v, attr, rem) {
> > +		u32 op = nla_type(v);
> > +		u64 value = 0;
> > +
> > +		switch (op) {
> > +		case IFLA_ATTR_LEARNING:
> > +		case IFLA_ATTR_LOOPBACK:
> > +		case IFLA_ATTR_BCAST_FLOODING:
> > +		case IFLA_ATTR_UCAST_FLOODING:
> > +		case IFLA_ATTR_MCAST_FLOODING: {
> > +			if (nla_len(v) < sizeof(value)) {
> > +				err = -EINVAL;
> > +				break;
> > +			}
> 
> You should validate the message before you start applying the changes.
> Otherwise if the 3rd attribute is too short you've already applied some
> changes and the user has not idea how much has been applied.
> 
> nla_parse_nested() can help here.
> 
> 
> > +
> > +			value = nla_get_u64(v);
> > +			err = ops->ndo_switch_port_set_cfg(dev,
> > +							   op,
> > +							   value);
> 
> This avoids having individual ndos but wastes a lot of space in the Netlink
> message. Not a problem when setting configuration but you likely want to
> dump these attributes as well and we need 12 bytes for each attribute even
> though some are merely flags which could fit in 4 bytes.
> 
> >  static int do_setvfinfo(struct net_device *dev, struct nlattr *attr)
> > {
> >  	int rem, err = -EINVAL;
> > @@ -1740,6 +1780,20 @@ static int do_setlink(const struct sk_buff *skb,
> >  			status |= DO_SETLINK_NOTIFY;
> >  		}
> >  	}
> > +#ifdef CONFIG_NET_SWITCHDEV
> > +	if (tb[IFLA_SWITCH_PORT_CFG]) {
> > +		err = -EOPNOTSUPP;
> > +		if (!ops->ndo_switch_port_set_cfg)
> > +			goto errout;
> > +		if (!ops->ndo_switch_parent_id_get)
> > +			goto errout;
> > +		err = do_setswcfg(dev, tb[IFLA_SWITCH_PORT_CFG]);
> > +		if (err < 0)
> > +			goto errout;
> > +
> > +		status |= DO_SETLINK_NOTIFY;
> > +	}
> > +#endif
> 
> Should return -EOPNOTSUPP if IFLA_SWITCH_PORT_CFG is provided but
> CONFIG_NET_SWITCHDEV is not set.
> 

I think I've addressed your comments Thomas. Thanks for your suggestions. I'm going to resubmit the patch now.

Thanks,
Marco
