From: Dan Williams <dcbw@redhat.com>
Subject: Re: [d80211 rfc] link master interface from wiphy
Date: Mon, 14 Aug 2006 08:01:02 -0400
Message-ID: <1155556862.2885.8.camel@localhost.localdomain>
References: <44E02F41.2060300@sipsolutions.net>
	 <44E03051.8030808@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jouni Malinen <jkm@devicescape.com>,
	Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:27013 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1751821AbWHNN5t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2006 09:57:49 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <44E03051.8030808@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-08-14 at 10:12 +0200, Johannes Berg wrote:
> I'd like to see a link from the wiphy to the master interface that 
> belongs to it so one can tell this easily on systems that have multiple 
> wireless devices. wpa_supplicant could use this, I guess. I think 
> another link to wlan#ap should be created (or does wpa_supplicant set 
> the name of that so it knows which one it will get?), or something like 
> that anyway.

HAL can certainly use this as well.  Two of the most useful things for
HAL (and by extension NetworkManager) were the 'device' and 'driver'
links, and this is certainly in the same class as those two.

Dan

> Here's a patch to just create the master link:
> 
> --- wireless-dev.orig/net/d80211/ieee80211.c    2006-08-11 
> 20:54:09.409674798 +0200
> +++ wireless-dev/net/d80211/ieee80211.c    2006-08-11 21:26:22.629674798 
> +0200
> @@ -4449,6 +4449,7 @@ int ieee80211_register_hw(struct net_dev
>          rtnl_unlock();
>          goto fail_dev;
>      }
> +    sysfs_create_link(&local->class_dev.kobj, &dev->class_dev.kobj, 
> "master");
>      result = ieee80211_sysfs_add_netdevice(dev);
>      rtnl_unlock();
>      if (result < 0)
> 
> 
> On the other hand, is there any real reason we have this code:
>         ndev->base_addr = dev->base_addr;
>         ndev->irq = dev->irq;
>         ndev->mem_start = dev->mem_start;
>         ndev->mem_end = dev->mem_end;
>         ndev->flags = dev->flags & IFF_MULTICAST;
>         SET_NETDEV_DEV(ndev, dev->class_dev.dev);
> 
> in ieee80211_if_add? Maybe we should make the virtual devices all 
> children of the wiphy (struct ieee80211_local) instead of making them 
> children of the physical device? I don't really know though. This is too 
> dark magic for me ;)
> 
> However, I do know that I can trivially rename the wmaster0 interface 
> using just 'ip link set wmaster0 name wlan3' and things will probably be 
> very confusing for any program that relies on the naming to know which 
> device is which. Hence, I think we need some symlinks here to be able to 
> tell which device is which. Or maybe we should directly surface the 
> ifindex in some sysfs attributes ;)
> 
> Comments welcome. Userspace comments as well, I'm programming something 
> that'll use a bunch of interfaces (wmaster, a monitor one and a sta one 
> probably) and I want the user to just select the physical interface, not 
> all these three logical ones... (in fact, I'm creating the logical 
> monitor interface myself in code).
> 
> johannes
> 
> PS: Yes, I do realize that doing
> ip link set wlan0 name xxx
> ip link set wmaster0 name wlan0
> ip link set xxx name wmaster0
> 
> is confusing. But since it is possible things shouldn't fall over if the 
> user decides for some weird local device naming. And wpa_supplicant 
> shouldn't need to require being configured all the device names either. 
> In fact IMHO just giving it a physical device (say via mac address) 
> ought to be enough...
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

