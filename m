From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH 2/3] net: expose ebridge FDB with priv flag
 IFF_OFFLOADED_FDB
Date: Fri, 2 Mar 2012 19:56:33 +0000
Message-ID: <1330718193.2611.36.camel@bwh-desktop>
References: <20120229070418.10937.8692.stgit@jf-dev1-dcblab>
	 <20120229071719.10937.68718.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <jhs@mojatatu.com>, <shemminger@vyatta.com>,
	<kernel@wantstofly.org>, <hadi@cyberus.ca>, <roprabhu@cisco.com>,
	<mst@redhat.com>, <netdev@vger.kernel.org>,
	<gregory.v.rose@intel.com>, <davem@davemloft.net>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:6235 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756144Ab2CBT4i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Mar 2012 14:56:38 -0500
In-Reply-To: <20120229071719.10937.68718.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-02-28 at 23:17 -0800, John Fastabend wrote:
> This adds a new private interface flag IFF_OFFLOADED_FDB and an
> additional ndmsg flag NTF_EMBEDDED.
> 
> The private flag IFF_OFFLOADED_FDB should be set on devices to
> indicate an embedded bridging component exists with a forwarding
> database.
> 
> With this set PF_BRIDGE:{RTM_NEWNEIGH|RTM_DELNEIGH|RTM_GETNEIGH}
> netlink msgs can manage the unicast address list on these devices
> by setting the NTF_EMBEDDED flag in ndm_flags.
> 
> These commands are compatible with the SW bridge allowing the same
> user space tools to be used with both SW bridges and HW bridges.
[...]
> index 9e70191..7b1a581 100644
> --- a/net/bridge/br_netlink.c
> +++ b/net/bridge/br_netlink.c
> @@ -211,6 +211,57 @@ static int br_validate(struct nlattr *tb[], struct nlattr *data[])
>  	return 0;
>  }
>  
> +static int rtnl_offloaded_fdb_add(struct nlmsghdr *nlh, struct net_device *dev)
> +{
> +	struct ndmsg *ndm;
> +	struct netdev_hw_addr *ha;
> +	struct nlattr *tb[NDA_MAX+1];
> +	__u8 *addr;
> +	int err;
> +
> +	ASSERT_RTNL();
> +
> +	if (!(dev->priv_flags & IFF_OFFLOADED_FDB))
> +		return -ENODEV;

EOPNOTSUPP

> +	err = nlmsg_parse(nlh, sizeof(*ndm), tb, NDA_MAX, NULL);
> +	if (err < 0)
> +		return err;
> +
> +	ndm = nlmsg_data(nlh);
> +	if (!tb[NDA_LLADDR] || nla_len(tb[NDA_LLADDR]) != ETH_ALEN) {
> +		pr_info("fdb_add: RTM_NEWNEIGH with invalid address\n");
> +		return -EINVAL;
> +	}
> +
> +	addr = nla_data(tb[NDA_LLADDR]);
> +	if (!is_valid_ether_addr(addr)) {
> +		pr_info("fdb_add: RTM_NEWNEIGH with invalid ether address\n");
> +		return -EINVAL;
> +	}
> +
> +	if (ndm->ndm_state & NUD_PERMANENT) {
> +		pr_info("fdb_add: RTM_NEWNEIGH with invalid state %#x\n",
> +			ndm->ndm_state);
> +		return -EINVAL;
> +	}
> +
> +	if (is_multicast_ether_addr(addr))
> +		return -EINVAL;

There is a pending change to the ndo_validate_addr interface which I
think would allow us to replace the Ethernet-specific checks with a
check against dev->addr_len and a call to ndo_validate_addr.  Not that I
really care about anything other than Ethernet, but it would be a little
more elegant.

> +	netif_addr_lock_bh(dev);
> +	list_for_each_entry(ha, &dev->uc.list, list) {
> +		if (!compare_ether_addr(ha->addr, addr)) {
> +			netif_addr_unlock_bh(dev);
> +			return -EEXIST;
> +		}
> +	}
> +	netif_addr_unlock_bh(dev);
> +
> +	err = dev_uc_add(dev, addr);
[...]

The software bridge makes the duplicate check conditional on NLM_F_EXCL.
Shouldn't this be consistent?

Also, this seems racy.  If all manipulation of the UC address list is
serialised by RTNL (which I think in practice it is) then there is no
race and we also don't need to take the netif_addr_lock(), but if we're
not allowed to assume that then we shouldn't drop the lock.  Perhaps the
check can be moved into a dev_uc_add_exclusive() or something like that.

General comment: why should the software bridge code be loaded in order
to control a hardware bridge?  (It's not even the only software bridge
we have!)  It would perhaps be neater to have separate modules for the
software bridge, the rtnetlink bridge ops, and the glue functions for
hardware bridges.  But that could be done later.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
