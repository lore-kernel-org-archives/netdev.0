From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 2/2] Prefix List and O/M flags against 2.5.73
Date: Sat, 19 Jul 2003 09:33:16 +0200 (CEST)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030719.093316.45294671.yoshfuji@linux-ipv6.org>
References: <20030718.004701.11546819.yoshfuji@linux-ipv6.org>
	<Pine.LNX.4.44.0307171716160.9419-100000@DYN318430.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, davem@redhat.com, netdev@oss.sgi.com,
	linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: krkumar@us.ibm.com
In-Reply-To: <Pine.LNX.4.44.0307171716160.9419-100000@DYN318430.beaverton.ibm.com>
List-Id: netdev.vger.kernel.org

In article <Pine.LNX.4.44.0307171716160.9419-100000@DYN318430.beaverton.ibm.com> (at Thu, 17 Jul 2003 17:37:18 -0700 (PDT)), Krishna Kumar <krkumar@us.ibm.com> says:

> > Anyway, it seems we're reaching consensus.
> 
> Great! Glad we have reached consensus because I am exhausted! Since you
> have agreed to the above proposal, the prefix list patch has to be applied
> before the O/M flags patch. I have kept the RTM_GETLNKINFO and specified
> a new option to get the flags information, this can be extended later to
> add more options for other paramters.

We're reaching consensus, but hot have reached. :-p
First part (prefixlist) seems ok to me.
Second part does not.

> -------- Patch for O/M flags against 2.5.73 (dependent on previous patch -----
> diff -ruN linux-2.5.73.org/include/linux/rtnetlink.h test/linux-2.5.73/include/linux/rtnetlink.h
> --- linux-2.5.73.org/include/linux/rtnetlink.h	2003-06-22 11:33:07.000000000 -0700
> +++ test/linux-2.5.73/include/linux/rtnetlink.h	2003-07-17 16:57:52.000000000 -0700
> @@ -47,7 +47,9 @@
>  #define	RTM_DELTFILTER	(RTM_BASE+29)
>  #define	RTM_GETTFILTER	(RTM_BASE+30)
> 
> -#define	RTM_MAX		(RTM_BASE+31)
> +#define	RTM_GETLNKINFO	(RTM_BASE+34)
> +
> +#define	RTM_MAX		(RTM_GETLNKINFO+1)
> 
>  /*
>     Generic structure for encapsulation of optional route information.

This is what we don't have consensus.
We need to decide whether to create new RTM_xxxIFACE or
to reuse RTM_xxxLINK (and activate ifi_family :-)).


> @@ -61,6 +63,13 @@
>  	unsigned short	rta_type;
>  };
> 
> +/* Structure to return per interface device flags */
> +struct ifp_if6info
> +{
> +	int ifindex;
> +	int flags;
> +};
> +
>  /* Macros to handle rtattributes */
> 
>  #define RTA_ALIGNTO	4

ditto.

> @@ -331,6 +340,7 @@
>  	IFA_LABEL,
>  	IFA_BROADCAST,
>  	IFA_ANYCAST,
> +	IFA_IFFLAGS,
>  	IFA_CACHEINFO
>  };

Don't change values.

> diff -ruN linux-2.5.73.org/net/ipv6/addrconf.c test/linux-2.5.73/net/ipv6/addrconf.c
> --- linux-2.5.73.org/net/ipv6/addrconf.c	2003-06-22 11:33:17.000000000 -0700
> +++ test/linux-2.5.73/net/ipv6/addrconf.c	2003-07-17 16:59:17.000000000 -0700
> @@ -2451,6 +2451,43 @@
>  	netlink_broadcast(rtnl, skb, 0, RTMGRP_IPV6_IFADDR, GFP_ATOMIC);
>  }
> 
> +int inet6_dump_linkinfo(struct sk_buff *skb, struct netlink_callback *cb)
> +{
> +	int ifindex, flags;
> +	struct net_device *dev;
:
>  static struct rtnetlink_link inet6_rtnetlink_table[RTM_MAX - RTM_BASE + 1] = {
>  	[RTM_NEWADDR - RTM_BASE] = { .doit	= inet6_rtm_newaddr, },
>  	[RTM_DELADDR - RTM_BASE] = { .doit	= inet6_rtm_deladdr, },
> @@ -2459,6 +2496,7 @@
>  	[RTM_DELROUTE - RTM_BASE] = { .doit	= inet6_rtm_delroute, },
>  	[RTM_GETROUTE - RTM_BASE] = { .doit	= inet6_rtm_getroute,
>  				      .dumpit	= inet6_dump_fib, },
> +	[RTM_GETLNKINFO - RTM_BASE] = {.dumpit	= inet6_dump_linkinfo, },
>  };
> 

same as first comment for this part.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
