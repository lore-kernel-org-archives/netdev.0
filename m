From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipv4: Cache source address in nexthop entries.
Date: Wed, 9 Mar 2011 02:49:49 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1103090157400.2880@ja.ssi.bg>
References: <20110307.205815.193699096.davem@davemloft.net> <alpine.LFD.2.00.1103081030090.1529@ja.ssi.bg> <20110308.103801.193702247.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:58737 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756767Ab1CIApO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Mar 2011 19:45:14 -0500
In-Reply-To: <20110308.103801.193702247.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


 	Hello,

On Tue, 8 Mar 2011, David Miller wrote:

>> As the addresses have nothing to do with the link
>> state, I don't think it is correct to call fib_update_nh_saddrs
>> for DEV events.
>
> fib_update_nh_saddrs() gets called for "DEV" events since those
> are what are emitted when addresses are addded and removed.

 	But we still need to propagate the address events
to nexthops on all devices. Even if it is slow, I see it in
this way (not tested):

static inline void update_nh_saddr(const struct in_ifaddr *ifa,
 				   struct net_device *dev,
 				   struct fib_nh *nexthop_nh,
 				   unsigned long event)
{
 	if (event == NETDEV_UP) {
 		if (ifa->ifa_local == nexthop_nh->nh_saddr)
 			return;
 	} else {
 		if (ifa->ifa_local != nexthop_nh->nh_saddr)
 			return;
 	}
 	if (ifa->ifa_scope > nexthop_nh->nh_cfg_scope)
 		return;
 	if (dev != nexthop_nh->nh_dev && ifa->ifa_scope >= RT_SCOPE_LINK)
 		return;
 	if (nexthop_nh->nh_flags & RTNH_F_DEAD)
 		return;
 	nexthop_nh->nh_saddr = inet_select_addr(nexthop_nh->nh_dev,
 						nexthop_nh->nh_gw,
 						nexthop_nh->nh_cfg_scope);
}

void fib_update_nh_saddrs(const struct in_ifaddr *ifa, unsigned long event)
{
 	struct net_device *dev = ifa->ifa_dev->dev;
 	int i;

 	for (i = 0; i < fib_hash_size; i++) {
 		struct hlist_head *head = &fib_info_hash[i];
 		struct hlist_node *node;
 		struct fib_info *fi;

 		hlist_for_each_entry(fi, node, head, fib_hash) {
 			if (fi->fib_prefsrc)
 				continue;
 			change_nexthops(fi) {
 				if (!nexthop_nh->nh_dev)
 					continue;
 				update_nh_saddr(ifa, dev, nexthop_nh, event);
 			} endfor_nexthops(fi);
 		}
 	}
}

 	Then may be fib_sync_up() should also refresh nh_saddr,
so that all alive nexthops get actual source address which
was not possible while device was down.

Regards

--
Julian Anastasov <ja@ssi.bg>
