From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] bridge: fix bridge netlink RCU usage
Date: Tue, 03 Mar 2015 14:33:44 +0100
Message-ID: <1425389624.2450.44.camel@sipsolutions.net>
References: <1425389374-12568-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:55827 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753942AbbCCNdv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Mar 2015 08:33:51 -0500
In-Reply-To: <1425389374-12568-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-03-03 at 13:29 +0000, Johannes Berg wrote:

> @@ -26,12 +26,15 @@ static size_t br_get_link_af_size(const struct net_device *dev)
>  {
>         struct net_port_vlans *pv;
> 
> -       if (br_port_exists(dev))
> -               pv = nbp_get_vlan_info(br_port_get_rtnl(dev));
> -       else if (dev->priv_flags & IFF_EBRIDGE)
> +       if (br_port_exists(dev)) {
> +               rcu_read_lock();
> +               pv = nbp_get_vlan_info(br_port_get_rcu(dev));
> +               rcu_read_unlock();

Note that I'm not entirely sure about the locking for "pv" here. In this
patch I'm basically assuming that nbp_get_vlan_info() is safe in any
context, which actually seems rather unlikely.

This clearly gets rid of the lockdep complaint for me, but I'm not sure
it's actually safe.

johannes
