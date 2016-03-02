From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] ipv4: properly apply change to
 ignore_routes_on_linkdown to all interfaces
Date: Wed, 2 Mar 2016 10:17:19 -0800
Message-ID: <56D72E2F.30207@cumulusnetworks.com>
References: <1456936986-2042-1-git-send-email-gospo@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Andy Gospodarek <gospo@cumulusnetworks.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:36067 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752674AbcCBSRW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 13:17:22 -0500
Received: by mail-pa0-f50.google.com with SMTP id a9so15289181pat.3
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2016 10:17:22 -0800 (PST)
In-Reply-To: <1456936986-2042-1-git-send-email-gospo@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/2/16 8:43 AM, Andy Gospodarek wrote:
>
> +/* called with RTNL locked */
> +static void inet_ignore_routes_change(struct net *net)
> +{
> +	struct net_device *dev;
> +	int on = IPV4_DEVCONF_ALL(net, IGNORE_ROUTES_WITH_LINKDOWN);
> +
> +	IPV4_DEVCONF_DFLT(net, IGNORE_ROUTES_WITH_LINKDOWN) = on;
> +	inet_netconf_notify_devconf(net, NETCONFA_IGNORE_ROUTES_WITH_LINKDOWN,
> +				    NETCONFA_IFINDEX_ALL,
> +				    net->ipv4.devconf_all);
> +	inet_netconf_notify_devconf(net, NETCONFA_IGNORE_ROUTES_WITH_LINKDOWN,
> +				    NETCONFA_IFINDEX_DEFAULT,
> +				    net->ipv4.devconf_dflt);
> +
> +	for_each_netdev(net, dev) {
> +		struct in_device *in_dev;
> +
> +		rcu_read_lock();
> +		in_dev = __in_dev_get_rcu(dev);
> +		if (in_dev) {
> +			IN_DEV_CONF_SET(in_dev,
> +					IGNORE_ROUTES_WITH_LINKDOWN, on);
> +			inet_netconf_notify_devconf(net,
> +						    NETCONFA_IGNORE_ROUTES_WITH_LINKDOWN,
> +						    dev->ifindex, &in_dev->cnf);
> +		}
> +		rcu_read_unlock();
> +	}
> +}
> +

This seems wrong -- changing the 'all' and 'default' settings for a 
sysctl should not require walking the interface list.
