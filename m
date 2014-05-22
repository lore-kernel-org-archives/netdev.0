From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [net] WARNING: CPU: 1 PID: 1 at
 net/batman-adv/hard-interface.c:92 batadv_is_on_batman_iface()
Date: Thu, 22 May 2014 10:29:20 +0200
Message-ID: <20140522082919.GF32371@secunet.com>
References: <537D8030.8010403@intel.com>
 <CAHA+R7Mhd2KYaU8THAd+O4HzQNRLxhpGccvEPOqWJRKAwZbpgQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Jet Chen <jet.chen@intel.com>, netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Fengguang Wu <fengguang.wu@intel.com>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:44217 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750861AbaEVI3b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2014 04:29:31 -0400
Content-Disposition: inline
In-Reply-To: <CAHA+R7Mhd2KYaU8THAd+O4HzQNRLxhpGccvEPOqWJRKAwZbpgQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 21, 2014 at 11:12:36PM -0700, Cong Wang wrote:
> 
> batman needs to fix:
> 
> diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
> index b851cc5..fbda6b5 100644
> --- a/net/batman-adv/hard-interface.c
> +++ b/net/batman-adv/hard-interface.c
> @@ -83,7 +83,7 @@ static bool batadv_is_on_batman_iface(const struct
> net_device *net_dev)
>                 return true;
> 
>         /* no more parents..stop recursion */
> -       if (net_dev->iflink == net_dev->ifindex)
> +       if (net_dev->iflink == 0 || net_dev->iflink == net_dev->ifindex)
>                 return false;
> 
>         /* recurse over the parent device */

Right, I think this is the correct fix.
Please do a proper patch submission for this.

I wondered why this issue does not show up with ipv6 tunnels
and it appears to be a bug :)

When a ipv6 tunnel interface is created, ip6_tnl_create2()
calls ip6_tnl_dev_init() which calls ip6_tnl_link_config().
ip6_tnl_link_config() sets dev->iflink.

Then register_netdev() overwrites this setting with
dev->iflink = dev->ifindex.

The output of the 'ip a' command looks like this:


9: ip6tnl0: <NOARP> mtu 1452 qdisc noop state DOWN                              
    link/tunnel6 :: brd ::
11: ip6tunnel1: <POINTOPOINT,NOARP> mtu 1452 qdisc noop state DOWN              
    link/tunnel6 2001:470:1f00:ffff::191 peer 2001:470:1f00:ffff::189


When I change to avoid the overwriting of dev->iflink it looks
like this:

9: ip6tnl0@NONE: <NOARP> mtu 1452 qdisc noop state DOWN                         
    link/tunnel6 :: brd :: 
12: ip6tunnel1@eth0: <POINTOPOINT,NOARP> mtu 1452 qdisc noop state DOWN         
    link/tunnel6 2001:470:1f00:ffff::191 peer 2001:470:1f00:ffff::189

So I think dev->iflink should be set in the ndo_init() function
of the tunnel, then register_netdev() leaves dev->iflink alone.

Thoughts, comments?
