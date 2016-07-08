From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC 5/7] net: Add allocation flag to rtnl_unicast()
Date: Fri, 08 Jul 2016 04:56:31 +0200
Message-ID: <1467946591.1273.45.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1467764916-4983-1-git-send-email-masashi.honma@gmail.com>
	 <1467764916-4983-6-git-send-email-masashi.honma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	linux-wireless@vger.kernel.org, linux-rdma@vger.kernel.org,
	linux-audit@redhat.com, cluster-devel@redhat.com,
	davem@davemloft.net, johannes@sipsolutions.net,
	pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	dledford@redhat.com, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, paul@paul-moore.com, eparis@redhat.com,
	zbr@ioremap.net, pshelar@nicira.com, ccaulfie@redhat.com,
	teigland@redhat.com, bsingharora@gmail.com
To: Masashi Honma <masashi.honma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35125 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753487AbcGHC4k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 22:56:40 -0400
In-Reply-To: <1467764916-4983-6-git-send-email-masashi.honma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-07-06 at 09:28 +0900, Masashi Honma wrote:
> Signed-off-by: Masashi Honma <masashi.honma@gmail.com>
> ---


> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index a1f6b7b..2b0b994 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -628,7 +628,7 @@ static int inet6_netconf_get_devconf(struct sk_buff *in_skb,
>  		kfree_skb(skb);
>  		goto errout;
>  	}
> -	err = rtnl_unicast(skb, net, NETLINK_CB(in_skb).portid);
> +	err = rtnl_unicast(skb, net, NETLINK_CB(in_skb).portid, GFP_ATOMIC);
>  errout:
>  	return err;
>  }
> @@ -4824,7 +4824,7 @@ static int inet6_rtm_getaddr(struct sk_buff *in_skb, struct nlmsghdr *nlh)
>  		kfree_skb(skb);
>  		goto errout_ifa;
>  	}
> -	err = rtnl_unicast(skb, net, NETLINK_CB(in_skb).portid);
> +	err = rtnl_unicast(skb, net, NETLINK_CB(in_skb).portid, GFP_KERNEL);
>  errout_ifa:
>  	in6_ifa_put(ifa);
>  errout:


Managing to mix GFP_ATOMIC and GFP_KERNEL almost randomly as you did in
this patch is definitely not good.

Further more, RTNL is a mutex, held in control path, designed to allow
schedules and waiting for memory under pressure.

We do not want to encourage GFP_ATOMIC usage in control path.

Your patch series gives the wrong signal to developers.

I will send a patch against net/ipv4/devinet.c so that we remove
GFP_ATOMIC usage there.
