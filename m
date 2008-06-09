From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH 1/3] [NET-NEXT]: Add DCB netlink interface definition
Date: Mon, 9 Jun 2008 15:11:15 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC3290538B15D@orsmsx414.amr.corp.intel.com>
References: <20080527141339.12851.98781.stgit@localhost.localdomain> <20080527141346.12851.2280.stgit@localhost.localdomain> <4847E75D.9080609@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <jeff@garzik.org>, <davem@davemloft.net>, <netdev@vger.kernel.org>,
	"Thomas Graf" <tgraf@suug.ch>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:64081 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754566AbYFIWLN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2008 18:11:13 -0400
Content-class: urn:content-classes:message
In-Reply-To: <4847E75D.9080609@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> For these and the other numbered attributes: is the maximum 
> number fixed and/or defined somewhere? If not, I'd suggest to 
> use lists of attributes.

I think we want to define a maximum number.  I can fix that.

> 
> And in this case lists of nested attributes consisting of 
> Priority and Bandwidth, since they seem to belong together.

I'll see what I can come up with when I move this implementation to
rtnetlink.

> > +struct dcbnl_genl_ops {
> > +	u8   (*getstate)(struct net_device *);
> > +	void (*setstate)(struct net_device *, u8);
> > +	void (*getpermhwaddr)(struct net_device *, u8 *);
> 
> "getpermhwaddr" doesn't seem to belong in this interface but 
> in rtnetlink and/or ethtool instead.

This was a feature in ethtool, but it was removed at some point.  I can
add it to rtnetlink though if people think it'll be useful to have.

> > +static int dcbnl_getperm_hwaddr(struct sk_buff *skb, 
> struct genl_info 
> > +*info) {
> > ...
> > +	dcbnl_skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
> > +	if (!dcbnl_skb)
> > +		goto err_out;
> > ...
> > +err:
> > +	kfree(dcbnl_skb);
> 
> ^^^ kfree_skb
> 
> The same error is present multiple times

Good catch.  I'll fix that.

> > +static int __dcbnl_pg_setcfg(struct genl_info *info, int dir) {
> > +	struct net_device *netdev = NULL;
> > +	struct nlattr *pg_tb[DCB_PG_ATTR_MAX + 1];
> > +	struct nlattr *param_tb[DCB_TC_ATTR_PARAM_MAX + 1];
> > +	int ret = -EINVAL;
> > +	int i;
> > +	u8 prio = 0, bwg_id = 0, bw_pct = 0, up_map = 0;
> > +
> > +	if (!info->attrs[DCB_ATTR_IFNAME] || 
> !info->attrs[DCB_ATTR_PG_CFG])
> > +		return ret;
> > +
> > +	netdev = dev_get_by_name(&init_net,
> > +				 
> nla_data(info->attrs[DCB_ATTR_IFNAME]));
> 
> 
> The fact that you do this in every handler makes me wonder 
> whether rtnetlink wouldn't be the better choice, if only 
> because it uses the rtnl_mutex and configuration changes are 
> thus serialized with other networking configuration changes.
> 
> For example I don't see anything preventing concurrent 
> changes to the DCB configuration while it is copied between 
> the temporary configuration and the real one. In one cases 
> its done in a path holding the rtnl_mutex, in another case 
> its done with holding the genl_mutex in a genetlink callback.

When we wrote this, we didn't know enough about rtnetlink to know what
to choose.  The general trend seemed to be moving towards genetlink for
subsystem changes in the kernel, so we chose that.  But this
serialization issue is a nice catch, and I think we'll move this
implementation to use rtnetlink.

Cheers,
-PJ Waskiewicz
