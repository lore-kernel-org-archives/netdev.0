From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next PATCH v2 2/3] net: set and query VEB/VEPA bridge mode
 via PF_BRIDGE
Date: Fri, 2 Nov 2012 22:38:43 +0000
Message-ID: <1351895923.2703.11.camel@bwh-desktop.uk.solarflarecom.com>
References: <20121024181033.14378.33097.stgit@jf-dev1-dcblab>
	 <20121024181303.14378.78253.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <shemminger@vyatta.com>, <buytenh@wantstofly.org>,
	<davem@davemloft.net>, <vyasevic@redhat.com>, <jhs@mojatatu.com>,
	<chrisw@redhat.com>, <krkumar2@in.ibm.com>, <samudrala@us.ibm.com>,
	<peter.p.waskiewicz.jr@intel.com>, <jeffrey.t.kirsher@intel.com>,
	<netdev@vger.kernel.org>, <gregory.v.rose@intel.com>,
	<eilong@broadcom.com>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:9056 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754663Ab2KBWis (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Nov 2012 18:38:48 -0400
In-Reply-To: <20121024181303.14378.78253.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-10-24 at 11:13 -0700, John Fastabend wrote:
> Hardware switches may support enabling and disabling the
> loopback switch which puts the device in a VEPA mode defined
> in the IEEE 802.1Qbg specification. In this mode frames are
> not switched in the hardware but sent directly to the switch.
> SR-IOV capable NICs will likely support this mode I am
> aware of at least two such devices. Also I am told (but don't
> have any of this hardware available) that there are devices
> that only support VEPA modes. In these cases it is important
> at a minimum to be able to query these attributes.
> 
> This patch adds an additional IFLA_BRIDGE_MODE attribute that can be
> set and dumped via the PF_BRIDGE:{SET|GET}LINK operations. Also
> anticipating bridge attributes that may be common for both embedded
> bridges and software bridges this adds a flags attribute
> IFLA_BRIDGE_FLAGS currently used to determine if the command or event
> is being generated to/from an embedded bridge or software bridge.
> Finally, the event generation is pulled out of the bridge module and
> into rtnetlink proper.
[...]
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
[...]
> +static int rtnl_bridge_notify(struct net_device *dev, u16 flags)
> +{
> +	struct net *net = dev_net(dev);
> +	struct net_device *master = dev->master;
> +	struct sk_buff *skb;
> +	int err = -EOPNOTSUPP;
> +
> +	skb = nlmsg_new(bridge_nlmsg_size(), GFP_ATOMIC);
> +	if (!skb) {
> +		err = -ENOMEM;
> +		goto errout;
> +	}
> +
> +	if (!flags && master && master->netdev_ops->ndo_bridge_getlink)
> +		err = master->netdev_ops->ndo_bridge_getlink(skb, 0, 0, dev);
> +	else if (dev->netdev_ops->ndo_bridge_getlink)
> +		err = dev->netdev_ops->ndo_bridge_getlink(skb, 0, 0, dev);

This doesn't make sense.  If flags == BRIDGE_FLAGS_MASTER then we only
send the 'self' information.  If flags == BRIDGE_FLAGS_MASTER |
BRIDGE_FLAGS_SELF then we only send the master information.

[...]
>  static int rtnl_bridge_setlink(struct sk_buff *skb, struct nlmsghdr *nlh,
>  			       void *arg)
>  {
>  	struct net *net = sock_net(skb->sk);
>  	struct ifinfomsg *ifm;
>  	struct net_device *dev;
> -	int err = -EINVAL;
> +	struct nlattr *br_spec, *attr = NULL;
> +	int rem, err = -EOPNOTSUPP;
> +	u16 flags = 0;
>  
>  	if (nlmsg_len(nlh) < sizeof(*ifm))
>  		return -EINVAL;
> @@ -2316,15 +2363,45 @@ static int rtnl_bridge_setlink(struct sk_buff *skb, struct nlmsghdr *nlh,
>  		return -ENODEV;
>  	}
>  
> -	if (dev->master && dev->master->netdev_ops->ndo_bridge_setlink) {
> +	br_spec = nlmsg_find_attr(nlh, sizeof(struct ifinfomsg), IFLA_AF_SPEC);
> +	if (br_spec) {
> +		nla_for_each_nested(attr, br_spec, rem) {
> +			if (nla_type(attr) == IFLA_BRIDGE_FLAGS) {
> +				flags = nla_get_u16(attr);
> +				break;
> +			}
> +		}
> +	}
> +
> +	if (!flags || (flags & BRIDGE_FLAGS_MASTER)) {
> +		if (!dev->master ||
> +		    !dev->master->netdev_ops->ndo_bridge_setlink) {
> +			err = -EOPNOTSUPP;
> +			goto out;
> +		}
> +
>  		err = dev->master->netdev_ops->ndo_bridge_setlink(dev, nlh);
>  		if (err)
>  			goto out;
> +
> +		flags &= ~BRIDGE_FLAGS_MASTER;
>  	}
>  
> -	if (dev->netdev_ops->ndo_bridge_setlink)
> -		err = dev->netdev_ops->ndo_bridge_setlink(dev, nlh);
> +	if ((flags & BRIDGE_FLAGS_SELF)) {
> +		if (!dev->netdev_ops->ndo_bridge_setlink)
> +			err = -EOPNOTSUPP;
> +		else
> +			err = dev->netdev_ops->ndo_bridge_setlink(dev, nlh);
> +
> +		if (!err)
> +			flags &= ~BRIDGE_FLAGS_SELF;
> +	}
>  
> +	if (attr && nla_type(attr) == IFLA_BRIDGE_FLAGS)

This condition is wrong; attr will *not* be NULL if the
nla_for_each_nested() loop terminates without finding an
IFLA_BRIDGE_FLAGS attribute.

> +		memcpy(nla_data(attr), &flags, sizeof(flags));
> +	/* Generate event to notify upper layer of bridge change */
> +	if (!err)
> +		err = rtnl_bridge_notify(dev, flags);

flags has been modified above; surely we want to use the original value
here?

Ben.

>  out:
>  	return err;
>  }
> 

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
