From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [PATCH net 0/2] netns: audit netdevice creation with
 IFLA_NET_NS_[PID|FD]
Date: Tue, 27 Jan 2015 13:51:31 +0100
Message-ID: <20150127125130.GB4338@omega>
References: <1422307694-10079-1-git-send-email-nicolas.dichtel@6wind.com>
 <20150127093425.GA2698@omega>
 <54C7694C.2060709@6wind.com>
 <20150127122340.GA4338@omega>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, davem@davemloft.net, arvid.brodin@alten.se,
	linux-wpan@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:57229 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932328AbbA0Mvg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 07:51:36 -0500
Content-Disposition: inline
In-Reply-To: <20150127122340.GA4338@omega>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 27, 2015 at 01:23:40PM +0100, Alexander Aring wrote:
...
> Summarize:
> 
> I would add the dev->features |= NETIF_F_NETNS_LOCAL; while wpan
> interface generation and add only the !net_eq(src_net, &init_net) check
> above. I suppose that src_net is the net namespace from "underlaying"
> interface wpan by calling:
> 
> $ ip link add link wpan0 name lowpan0 type lowpan
> 

should look something like:

diff --git a/net/ieee802154/6lowpan/core.c b/net/ieee802154/6lowpan/core.c
index 055fbb7..a44963c 100644
--- a/net/ieee802154/6lowpan/core.c
+++ b/net/ieee802154/6lowpan/core.c
@@ -148,10 +148,11 @@ static int lowpan_newlink(struct net *src_net, struct net_device *dev,
 
        pr_debug("adding new link\n");
 
-       if (!tb[IFLA_LINK])
+       if (!tb[IFLA_LINK] |
+           !net_eq(src_net, &init_net))
                return -EINVAL;
        /* find and hold real wpan device */
-       real_dev = dev_get_by_index(src_net, nla_get_u32(tb[IFLA_LINK]));
+       real_dev = dev_get_by_index(&init_net, nla_get_u32(tb[IFLA_LINK]));
        if (!real_dev)
                return -ENODEV;
        if (real_dev->type != ARPHRD_IEEE802154) {
diff --git a/net/ieee802154/core.c b/net/ieee802154/core.c
index 18bc7e7..161f0e5 100644
--- a/net/ieee802154/core.c
+++ b/net/ieee802154/core.c
@@ -229,6 +229,8 @@ static int cfg802154_netdev_notifier_call(struct notifier_block *nb,
                list_add_rcu(&wpan_dev->list, &rdev->wpan_dev_list);
                rdev->devlist_generation++;
 
+               /* can only change netns with wpan_phy */
+               dev->features |= NETIF_F_NETNS_LOCAL;
                wpan_dev->netdev = dev;
                break;
        case NETDEV_DOWN:
--


In ieee802154/core.c we set (like wireless it also does) the
dev->features |= NETIF_F_NETNS_LOCAL; for wpan interface.


In net/ieee802154/6lowpan/core.c, we only check if the wpan interface
belongs to !net_eq(src_net, &init_net).


On 6LoWPAN 802.15.4 interfaces it should be still possible to change
the net namespace.

- Alex
