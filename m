From: Hannes Frederic Sowa <hannes@redhat.com>
Subject: Re: [PATCH net-next v4] net: ipv6: Make address flushing on ifdown optional
Date: Thu, 08 Oct 2015 21:25:01 +0200
Message-ID: <877fmxf9iq.fsf@stressinduktion.org>
References: <1444231059-14830-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nicolas.dichtel@6wind.com, David Ahern <dsa@cumulusnetworks.com>
To: David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53427 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753181AbbJHTZF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Oct 2015 15:25:05 -0400
In-Reply-To: <1444231059-14830-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

David Ahern <dsa@cumulusnetworks.com> writes:

> Currently, all ipv6 addresses are flushed when the interface is configured
> down, including global, static addresses:
>
>     $ ip -6 addr add dev eth1 2000:11:1:1::1/64
>     $ ip addr show dev eth1
>     3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
>         link/ether 02:04:11:22:33:01 brd ff:ff:ff:ff:ff:ff
>         inet6 2000:11:1:1::1/64 scope global tentative
>            valid_lft forever preferred_lft forever
>     $ ip link set dev eth1 up
>     $ ip link set dev eth1 down
>     $ ip addr show dev eth1
>     3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast state DOWN group default qlen 1000
>         link/ether 02:04:11:22:33:01 brd ff:ff:ff:ff:ff:ff
>
> Add a new sysctl to make this behavior optional. The new setting defaults to
> flush all addresses to maintain backwards compatibility. When the setting is
> reset global addresses with no expire times are not flushed:
>
>     $ echo 0 > /proc/sys/net/ipv6/conf/eth1/flush_addr_on_down
>     $ ip -6 addr add dev eth1 2000:11:1:1::1/64
>     $ ip addr show dev eth1
>     3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast state DOWN group default qlen 1000
>         link/ether 02:04:11:22:33:01 brd ff:ff:ff:ff:ff:ff
>         inet6 2000:11:1:1::1/64 scope global tentative
>            valid_lft forever preferred_lft forever
>     $ ip link set dev eth1 up
>     $ ip link set dev eth1 down
>     $ ip addr show dev eth1
>     3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast state DOWN group default qlen 1000
>         link/ether 02:04:11:22:33:01 brd ff:ff:ff:ff:ff:ff
>         inet6 2000:11:1:1::1/64 scope global
>            valid_lft forever preferred_lft forever
>         inet6 fe80::4:11ff:fe22:3301/64 scope link
>            valid_lft forever preferred_lft forever
>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
> It has been 8 months since the last version:
>    http://lists.openwall.net/netdev/2015/02/12/33
>
> but wanted to revive it. This current version addresses the last round of
> comments and verifies all routes are deleted and re-added correctly
>
> Nicolas: I ran 'ip monitor' on a link down and link up cycle and you can
>          see the neighbor and route deletes on a down and routes added on
>          an up.
>
> v4:
> - rebased to top of tree
>
> - updated to clear all routes on admin down and re-added on admin up
>
> - verified the route tables (main and local) on a link down have *no*
>   remnants of the configured, global address. On a link up all routes
>   are restored -- multicast, linklocal, local routes and connected.
>
> v3:
> - fix local variable ordering and comment style per Dave's comment
> - consistency in DEVCONF naming per Brian Haley's comment
> - added entry to Documentation/networking/ip-sysctl.txt
>
> v2:
> - only keep static addresses as suggested by Hannes
> - added new managed flag to track configured addresses
> - on ifdown do not remove from configured address from inet6_addr_lst
> - on ifdown reset the TENTATIVE flag and set state to DAD so that DAD is
>   redone when link is brought up again
>
>  Documentation/networking/ip-sysctl.txt |  6 +++
>  include/linux/ipv6.h                   |  1 +
>  include/net/if_inet6.h                 |  1 +
>  include/uapi/linux/ipv6.h              |  1 +
>  net/ipv6/addrconf.c                    | 91 +++++++++++++++++++++++++++++-----
>  5 files changed, 87 insertions(+), 13 deletions(-)
>
> diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
> index ebe94f2cab98..51c60f58f7ec 100644
> --- a/Documentation/networking/ip-sysctl.txt
> +++ b/Documentation/networking/ip-sysctl.txt
> @@ -1432,6 +1432,12 @@ dad_transmits - INTEGER
>  	The amount of Duplicate Address Detection probes to send.
>  	Default: 1
>  
> +flush_addr_on_down - BOOLEAN
> +	Flush all IPv6 addresses on an interface down event. If disabled
> +	static global addresses with no expiration time are not flushed.
> +
> +	Default: enabled
> +
>  forwarding - INTEGER
>  	Configure interface-specific Host/Router behaviour.
>  
> diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
> index 0ef2a97ccdb5..112a18940ab2 100644
> --- a/include/linux/ipv6.h
> +++ b/include/linux/ipv6.h
> @@ -60,6 +60,7 @@ struct ipv6_devconf {
>  		struct in6_addr secret;
>  	} stable_secret;
>  	__s32		use_oif_addrs_only;
> +	__s32		flush_addr_on_down;
>  	void		*sysctl;
>  };
>  
> diff --git a/include/net/if_inet6.h b/include/net/if_inet6.h
> index 1c8b6820b694..f190a14148ab 100644
> --- a/include/net/if_inet6.h
> +++ b/include/net/if_inet6.h
> @@ -72,6 +72,7 @@ struct inet6_ifaddr {
>  	int			regen_count;
>  
>  	bool			tokenized;
> +	bool			managed;

IMHO the naming of the bool is a bit too vague. ;) Would you mind
renaming it to something like puuh... user_managed, non_autoconf,
manual_conf etc.?  'managed' seems so often used in the context of
temporary addresses, I first thought about that.

enum { USER_SPACE, KERNEL_AUTOCONF } managed_by;

>  
>  	struct rcu_head		rcu;
>  	struct in6_addr		peer_addr;
> diff --git a/include/uapi/linux/ipv6.h b/include/uapi/linux/ipv6.h
> index 38b4fef20219..7c514f7cd209 100644
> --- a/include/uapi/linux/ipv6.h
> +++ b/include/uapi/linux/ipv6.h
> @@ -174,6 +174,7 @@ enum {
>  	DEVCONF_USE_OIF_ADDRS_ONLY,
>  	DEVCONF_ACCEPT_RA_MIN_HOP_LIMIT,
>  	DEVCONF_IGNORE_ROUTES_WITH_LINKDOWN,
> +	DEVCONF_FLUSH_ADDR_ON_DOWN,
>  	DEVCONF_MAX
>  };
>  
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index f0326aae7a02..e07b1fb52131 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -216,6 +216,7 @@ static struct ipv6_devconf ipv6_devconf __read_mostly = {
>  	},
>  	.use_oif_addrs_only	= 0,
>  	.ignore_routes_with_linkdown = 0,
> +	.flush_addr_on_down	= 1,
>  };
>  
>  static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
> @@ -260,6 +261,7 @@ static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
>  	},
>  	.use_oif_addrs_only	= 0,
>  	.ignore_routes_with_linkdown = 0,
> +	.flush_addr_on_down	= 1,
>  };
>  
>  /* Check if a valid qdisc is available */
> @@ -955,6 +957,7 @@ ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr,
>  	ifa->prefered_lft = prefered_lft;
>  	ifa->cstamp = ifa->tstamp = jiffies;
>  	ifa->tokenized = false;
> +	ifa->managed = false;
>  
>  	ifa->rt = rt;
>  
> @@ -2689,6 +2692,9 @@ static int inet6_addr_add(struct net *net, int ifindex,
>  			    valid_lft, prefered_lft);
>  
>  	if (!IS_ERR(ifp)) {
> +		if (!expires)
> +			ifp->managed = true;
> +

This assumes that user space managed addresses don't time out. This is
in fact not true. I am not sure if it matters a lot, as most addresses
added from user space with a timeout most probably will be added because
of autoconf, but they are not managed by kernel autoconf. Not sure if we
want to make this more explicit, certainly it would avoid surprises.

Otherwise the patch looks fine and useful!

Thanks,
Hannes
