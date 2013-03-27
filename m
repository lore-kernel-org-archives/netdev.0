From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] net : Fix broken IPv6 routing table after loopback down-up
Date: Wed, 27 Mar 2013 19:55:14 +0900
Message-ID: <5152D012.4030805@linux-ipv6.org>
References: <CAHPKR9KjB+6+WD9R4D81vZ6eFvcwgDJKgHFYvKxQQ2t_T7x9fg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	kaber@trash.net, netdev@vger.kernel.org,
	Balakumaran.Kannan@ap.sony.com, maruthi.thotad@ap.sony.com,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Balakumaran Kannan <kumaran.4353@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:59940 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750958Ab3C0KzT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 06:55:19 -0400
In-Reply-To: <CAHPKR9KjB+6+WD9R4D81vZ6eFvcwgDJKgHFYvKxQQ2t_T7x9fg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Balakumaran Kannan wrote:
> IPv6 Routing table becomes broken once we do ifdown, ifup of the loopback(lo)
> interface. After down-up, routes of other interface's IPv6 addresses through
> 'lo' are lost.
> 
> IPv6 addresses assigned to all interfaces are routed through 'lo' for internal
> communication. Once 'lo' is down, those routing entries are removed from
> routing table. But those removed entries are not being re-created properly when
> 'lo' is brought up. So IPv6 addresses of other interfaces becomes unreachable
> from the same machine. Also this breaks communication with other machines
> because of NDISC packet processing failure.
> 
> This patch fixes this issue by reading all interface's IPv6 addresses and
> adding them to IPv6 routing table while bringing up 'lo'.
> 
> Patch is prepared for Linux-3.9.rc4 kernel.
> 
> Signed-off-by: Balakumaran Kannan <Balakumaran.Kannan@ap.sony.com>
> Signed-off-by: Maruthi Thotad <Maruthi.Thotad@ap.sm.sony.com>
> ---
> ==Testing==
> Before applying the patch:
> $ route -A inet6
> Kernel IPv6 routing table
> Destination                    Next Hop                   Flag Met Ref Use If
> 2000::20/128                   ::                         U    256 0     0 eth0
> fe80::/64                      ::                         U    256 0     0 eth0
> ::/0                           ::                         !n   -1  1     1 lo
> ::1/128                        ::                         Un   0   1     0 lo
> 2000::20/128                   ::                         Un   0   1     0 lo
> fe80::xxxx:xxxx:xxxx:xxxx/128  ::                         Un   0   1     0 lo
> ff00::/8                       ::                         U    256 0     0 eth0
> ::/0                           ::                         !n   -1  1     1 lo
> $ sudo ifdown lo
> $ sudo ifup lo
> $ route -A inet6
> Kernel IPv6 routing table
> Destination                    Next Hop                   Flag Met Ref Use If
> 2000::20/128                   ::                         U    256 0     0 eth0
> fe80::/64                      ::                         U    256 0     0 eth0
> ::/0                           ::                         !n   -1  1     1 lo
> ::1/128                        ::                         Un   0   1     0 lo
> ff00::/8                       ::                         U    256 0     0 eth0
> ::/0                           ::                         !n   -1  1     1 lo
> $
> 
> After applying the patch:
> $ route -A inet6
> Kernel IPv6 routing
> table
> Destination                    Next Hop                   Flag Met Ref Use If
> 2000::20/128                   ::                         U    256 0     0 eth0
> fe80::/64                      ::                         U    256 0     0 eth0
> ::/0                           ::                         !n   -1  1     1 lo
> ::1/128                        ::                         Un   0   1     0 lo
> 2000::20/128                   ::                         Un   0   1     0 lo
> fe80::xxxx:xxxx:xxxx:xxxx/128  ::                         Un   0   1     0 lo
> ff00::/8                       ::                         U    256 0     0 eth0
> ::/0                           ::                         !n   -1  1     1 lo
> $ sudo ifdown lo
> $ sudo ifup lo
> $ route -A inet6
> Kernel IPv6 routing table
> Destination                    Next Hop                   Flag Met Ref Use If
> 2000::20/128                   ::                         U    256 0     0 eth0
> fe80::/64                      ::                         U    256 0     0 eth0
> ::/0                           ::                         !n   -1  1     1 lo
> ::1/128                        ::                         Un   0   1     0 lo
> 2000::20/128                   ::                         Un   0   1     0 lo
> fe80::xxxx:xxxx:xxxx:xxxx/128  ::                         Un   0   1     0 lo
> ff00::/8                       ::                         U    256 0     0 eth0
> ::/0                           ::                         !n   -1  1     1 lo
> $
> ---
> --- linux-3.9-rc4/net/ipv6/addrconf.c.orig	2013-03-27 10:40:26.382569527 +0530
> +++ linux-3.9-rc4/net/ipv6/addrconf.c	2013-03-27 10:56:45.227354856 +0530
> @@ -2529,6 +2529,11 @@ static void sit_add_v4_addrs(struct inet
>  static void init_loopback(struct net_device *dev)
>  {
>  	struct inet6_dev  *idev;
> +	struct net_device *sp_dev;
> +	struct inet6_ifaddr *sp_ifa;
> +	struct list_head *sp_ifap;> 
>  static void addrconf_add_linklocal(struct inet6_dev *idev, const
> struct in6_addr *addr)
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

> +	struct rt6_info *sp_rt;
> +	int i = 1;
> 
>  	/* ::1 */
> 
> @@ -2540,6 +2545,27 @@ static void init_loopback(struct net_dev
>  	}
> 
>  	add_addr(idev, &in6addr_loopback, 128, IFA_HOST);
> +
> +	while ((sp_dev = dev_get_by_index(dev_net(dev), i++))) {
> +

I think this cannot work because we may have missing index.
Why no dev_get_by_name()?

> +		if (!strcmp(sp_dev->name, dev->name)) {
> +			dev_put(sp_dev);
> +			continue;
> +		}
> +
> +		idev = ipv6_find_idev(sp_dev);
> +		dev_put(sp_dev);
> +		if (NULL == idev)
> +			continue;
> +
> +		list_for_each(sp_ifap, &idev->addr_list) {
> +			sp_ifa = list_entry(sp_ifap, struct inet6_ifaddr,
> +						if_list);
> +			sp_rt = addrconf_dst_alloc(idev, &sp_ifa->addr, 0);
> +			if (!IS_ERR(sp_rt))
> +			ip6_ins_rt(sp_rt);
> +		}
> +	}
>  }

lock?

--yoshfuji
