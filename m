From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next PATCH v1 3/7] net: add fdb generic dump routine
Date: Wed, 11 Apr 2012 04:45:01 +0100
Message-ID: <1334115901.7150.371.camel@deadeye>
References: <20120409215419.3288.50790.stgit@jf-dev1-dcblab>
	 <20120409220030.3288.31389.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <roprabhu@cisco.com>, <mst@redhat.com>,
	<stephen.hemminger@vyatta.com>, <davem@davemloft.net>,
	<hadi@cyberus.ca>, <jeffrey.t.kirsher@intel.com>,
	<netdev@vger.kernel.org>, <gregory.v.rose@intel.com>,
	<krkumar2@in.ibm.com>, <sri@us.ibm.com>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:16951 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756255Ab2DKDpI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 23:45:08 -0400
In-Reply-To: <20120409220030.3288.31389.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-04-09 at 15:00 -0700, John Fastabend wrote:
> This adds a generic dump routine drivers can call. It
> should be sufficient to handle any bridging model that
> uses the unicast address list. This should be most SR-IOV
> enabled NICs.
[...]
> +static int nlmsg_populate_fdb(struct sk_buff *skb,
> +			      struct netlink_callback *cb,
> +			      struct net_device *dev,
> +			      int *idx,
> +			      struct netdev_hw_addr_list *list)
> +{
> +	struct netdev_hw_addr *ha;
> +	struct ndmsg *ndm;
> +	struct nlmsghdr *nlh;
> +	u32 pid, seq;
> +
> +	pid = NETLINK_CB(cb->skb).pid;
> +	seq = cb->nlh->nlmsg_seq;
> +
> +	list_for_each_entry(ha, &list->list, list) {
> +		if (*idx < cb->args[0])
> +			goto skip;
> +
> +		nlh = nlmsg_put(skb, pid, seq,
> +				RTM_NEWNEIGH, sizeof(*ndm), NLM_F_MULTI);
> +		if (!nlh)
> +			break;

This break is effectively return 0, but shouldn't we return an error?
In practice this does no harm because any subsequent invocation of
nlmsg_populate_fdb() for the same skb is also going to fail here with no
change to *idx.  But it would be more obviously correct to return an
error.

[...]
> +	}
> +	return 0;
> +nla_put_failure:
> +	nlmsg_cancel(skb, nlh);
> +	return -ENOMEM;
> +}
[...]

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
