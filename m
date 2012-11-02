From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next PATCH v2 1/3] net: create generic bridge ops
Date: Fri, 2 Nov 2012 22:32:55 +0000
Message-ID: <1351895575.2703.5.camel@bwh-desktop.uk.solarflarecom.com>
References: <20121024181033.14378.33097.stgit@jf-dev1-dcblab>
	 <20121024181257.14378.41548.stgit@jf-dev1-dcblab>
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
Received: from webmail.solarflare.com ([12.187.104.25]:7468 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752199Ab2KBWdB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Nov 2012 18:33:01 -0400
In-Reply-To: <20121024181257.14378.41548.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-10-24 at 11:12 -0700, John Fastabend wrote:
> The PF_BRIDGE:RTM_{GET|SET}LINK nlmsg family and type are
> currently embedded in the ./net/bridge module. This prohibits
> them from being used by other bridging devices. One example
> of this being hardware that has embedded bridging components.
> 
> In order to use these nlmsg types more generically this patch
> adds two net_device_ops hooks. One to set link bridge attributes
> and another to dump the current bride attributes.
> 
> 	ndo_bridge_setlink()
> 	ndo_bridge_getlink()
[...]

Do you have any userland code for this?

[...]
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -2252,6 +2252,83 @@ static int rtnl_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb)
>  	return skb->len;
>  }
>  
> +static int rtnl_bridge_getlink(struct sk_buff *skb, struct netlink_callback *cb)
> +{
> +	struct net *net = sock_net(skb->sk);
> +	struct net_device *dev;
> +	int idx = 0;
> +	u32 portid = NETLINK_CB(cb->skb).portid;
> +	u32 seq = cb->nlh->nlmsg_seq;
> +
> +	rcu_read_lock();
> +	for_each_netdev_rcu(net, dev) {
> +		const struct net_device_ops *ops = dev->netdev_ops;
> +		struct net_device *master = dev->master;
> +
> +		if (idx < cb->args[0])
> +			continue;
[...]

This is wrong, as idx will not be incremented and continued iteration
won't work at all.  Since this has already been applied, I'll send a
patch for this.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
