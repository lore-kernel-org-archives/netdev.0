From: Hannes Frederic Sowa <hannes@redhat.com>
Subject: Re: [RFC PATCH] net: ipv6: Make address flushing on ifdown optional
Date: Mon, 19 Jan 2015 16:02:49 +0100
Message-ID: <1421679769.32277.15.camel@redhat.com>
References: <1421263039-96198-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59346 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751479AbbASPCy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jan 2015 10:02:54 -0500
In-Reply-To: <1421263039-96198-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mi, 2015-01-14 at 12:17 -0700, David Ahern wrote:
> Currently, ipv6 addresses are flushed when the interface is configured down:
> 
> [root@f20 ~]# ip -6 addr add dev eth1 2000:11:1:1::1/64
> [root@f20 ~]# ip addr show dev eth1
> 3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
>     link/ether 02:04:11:22:33:01 brd ff:ff:ff:ff:ff:ff
>     inet6 2000:11:1:1::1/64 scope global tentative
>        valid_lft forever preferred_lft forever
> [root@f20 ~]# ip link set dev eth1 up
> [root@f20 ~]# ip link set dev eth1 down
> [root@f20 ~]# ip addr show dev eth1
> 3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast state DOWN group default qlen 1000
>     link/ether 02:04:11:22:33:01 brd ff:ff:ff:ff:ff:ff
> 
> Add a new sysctl to make this behavior optional. Setting defaults to flush
> addresses to maintain backwards compatibility. When reset flushing is bypassed:
> 
> [root@f20 ~]# echo 0 > /proc/sys/net/ipv6/conf/eth1/flush_addr_on_down
> [root@f20 ~]# ip -6 addr add dev eth1 2000:11:1:1::1/64
> [root@f20 ~]# ip addr show dev eth1
> 3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast state DOWN group default qlen 1000
>     link/ether 02:04:11:22:33:01 brd ff:ff:ff:ff:ff:ff
>     inet6 2000:11:1:1::1/64 scope global tentative
>        valid_lft forever preferred_lft forever
> [root@f20 ~]#  ip link set dev eth1 up
> [root@f20 ~]#  ip link set dev eth1 down
> [root@f20 ~]# ip addr show dev eth1
> 3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast state DOWN group default qlen 1000
>     link/ether 02:04:11:22:33:01 brd ff:ff:ff:ff:ff:ff
>     inet6 2000:11:1:1::1/64 scope global
>        valid_lft forever preferred_lft forever
>     inet6 fe80::4:11ff:fe22:3301/64 scope link
>        valid_lft forever preferred_lft forever
> 
> Suggested-by: Hannes Frederic Sowa <hannes@redhat.com>
> Signed-off-by: David Ahern <dsahern@gmail.com>
> Cc: Hannes Frederic Sowa <hannes@redhat.com>
> ---
>  include/linux/ipv6.h      |  1 +
>  include/uapi/linux/ipv6.h |  1 +
>  net/ipv6/addrconf.c       | 15 +++++++++++++++
>  3 files changed, 17 insertions(+)
> 
> diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
> index c694e7baa621..1d726e39f09f 100644
> --- a/include/linux/ipv6.h
> +++ b/include/linux/ipv6.h
> @@ -52,6 +52,7 @@ struct ipv6_devconf {
>  	__s32		force_tllao;
>  	__s32           ndisc_notify;
>  	__s32		suppress_frag_ndisc;
> +	__s32		flush_addr_on_down;
>  	void		*sysctl;
>  };
>  
> diff --git a/include/uapi/linux/ipv6.h b/include/uapi/linux/ipv6.h
> index e863d088b9a5..c7cb79e0f0fe 100644
> --- a/include/uapi/linux/ipv6.h
> +++ b/include/uapi/linux/ipv6.h
> @@ -165,6 +165,7 @@ enum {
>  	DEVCONF_SUPPRESS_FRAG_NDISC,
>  	DEVCONF_ACCEPT_RA_FROM_LOCAL,
>  	DEVCONF_USE_OPTIMISTIC,
> +	DEVCONF_FLUSH_ON_DOWN,
>  	DEVCONF_MAX
>  };
>  
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index f7c8bbeb27b7..5c0d49073cb1 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -201,6 +201,7 @@ static struct ipv6_devconf ipv6_devconf __read_mostly = {
>  	.disable_ipv6		= 0,
>  	.accept_dad		= 1,
>  	.suppress_frag_ndisc	= 1,
> +	.flush_addr_on_down	= 1,
>  };
>  
>  static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
> @@ -238,6 +239,7 @@ static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
>  	.disable_ipv6		= 0,
>  	.accept_dad		= 1,
>  	.suppress_frag_ndisc	= 1,
> +	.flush_addr_on_down	= 1,
>  };
>  
>  /* Check if a valid qdisc is available */
> @@ -3083,6 +3085,9 @@ static int addrconf_ifdown(struct net_device *dev, int how)
>  	if (how && del_timer(&idev->regen_timer))
>  		in6_dev_put(idev);
>  
> +	if (!how && !idev->cnf.flush_addr_on_down)
> +		goto unlock;

I would still prefer that we flush automatically generated addresses and
only keep the static and permanent ones.

What do you think?

Bye,
Hannes
