From: Patrick McHardy <kaber@trash.net>
Subject: Re: [net-next-2.6 V9 PATCH 1/2] Add netlink support for virtual port
 management (was iovnl)
Date: Thu, 20 May 2010 16:24:22 +0200
Message-ID: <4BF54616.1020508@trash.net>
References: <20100518054330.21787.29398.stgit@savbu-pc100.cisco.com> <20100518054833.21787.45456.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, chrisw@redhat.com,
	arnd@arndb.de
To: Scott Feldman <scofeldm@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:53588 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751475Ab0ETOYW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 May 2010 10:24:22 -0400
In-Reply-To: <20100518054833.21787.45456.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Scott Feldman wrote:
> From: Scott Feldman <scofeldm@cisco.com>
> 
> Add new netdev ops ndo_{set|get}_vf_port to allow setting of
> port-profile on a netdev interface.  Extends netlink socket RTM_SETLINK/
> RTM_GETLINK with two new sub msgs called IFLA_VF_PORTS and IFLA_PORT_SELF
> (added to end of IFLA_cmd list).  These are both nested atrtibutes
> using this layout:
> 
>...

Appologies for the delay, my mailserver failed me once again :|

This version looks very good to me, just one question:

> +static int rtnl_vf_ports_fill(struct sk_buff *skb, struct net_device *dev)
> +{
> +	struct nlattr *vf_ports;
> +	struct nlattr *vf_port;
> +	int vf;
> +	int err;
> +
> +	vf_ports = nla_nest_start(skb, IFLA_VF_PORTS);
> +	if (!vf_ports)
> +		return -EMSGSIZE;
> +
> +	for (vf = 0; vf < dev_num_vf(dev->dev.parent); vf++) {
> +		vf_port = nla_nest_start(skb, IFLA_VF_PORT);
> +		if (!vf_port) {
> +			nla_nest_cancel(skb, vf_ports);
> +			return -EMSGSIZE;
> +		}
> +		NLA_PUT_U32(skb, IFLA_PORT_VF, vf);
> +		err = dev->netdev_ops->ndo_get_vf_port(dev, vf, skb);
> +		if (err) {
> +nla_put_failure:
> +			nla_nest_cancel(skb, vf_port);
> +			continue;

Are you sure you want to continue here? During a full dump
this means that the last VF port fitting in the skb will most
likely be incomplete since the higher layer code won't
notice that the size was exceeded and the entry should be
dumped into another skb.

> +		}
> +		nla_nest_end(skb, vf_port);
> +	}
> +
> +	nla_nest_end(skb, vf_ports);
> +
> +	return 0;
> +}
