From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [PATCH net 0/2] netns: audit netdevice creation with
 IFLA_NET_NS_[PID|FD]
Date: Tue, 27 Jan 2015 10:34:28 +0100
Message-ID: <20150127093425.GA2698@omega>
References: <1422307694-10079-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	dmitry.tarnyagin@lockless.no, arvid.brodin@alten.se,
	linux-wpan@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:47665 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753717AbbA0Jej (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 04:34:39 -0500
Content-Disposition: inline
In-Reply-To: <1422307694-10079-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Mon, Jan 26, 2015 at 10:28:12PM +0100, Nicolas Dichtel wrote:
> 
> When one of these attributes is set, the netdevice is created into the netns
> pointed by IFLA_NET_NS_[PID|FD] (see the call to rtnl_create_link() in
> rtnl_newlink()). Let's call this netns the dest_net. After this creation, if the
> newlink handler exists, it is called with a netns argument that points to the
> netns where the netlink message has been received (called src_net in the code)
> which is the link netns.
> Hence, with one of these attributes, it's possible to create a x-netns
> netdevice.
> 
> Here is the result of my code review:
> - all ip tunnels (sit, ipip, ip6_tunnels, gre[tap][v6], ip_vti[6]) does not
>   really allows to use this feature: the netdevice is created in the dest_net
>   and the src_net is completely ignored in the newlink handler.
> - VLAN properly handles this x-netns creation.
> - bridge ignores src_net, which seems fine (NETIF_F_NETNS_LOCAL is set).
> - CAIF subsystem is not clear for me (I don't know how it works), but it seems
>   to wrongly use src_net. Patch #1 tries to fix this, but it was done only by
>   code review (and only compile-tested), so please carefully review it. I may
>   miss something.
> - HSR subsystem uses src_net to parse IFLA_HSR_SLAVE[1|2], but the netdevice has
>   the flag NETIF_F_NETNS_LOCAL, so the question is: does this netdevice really
>   supports x-netns? If not, the newlink handler should use the dest_net instead
>   of src_net, I can provide the patch.
> - ieee802154 uses also src_net and does not have NETIF_F_NETNS_LOCAL. Same
>   question: does this netdevice really supports x-netns?

I am not sure if I understand exactly what you mean. First of all, I
didn't test anything about net namespaces for the ieee802154 branch.
In 802.15.4 branch we have two interfaces: wpan and 6LoWPAN.

After running "grep -r "src_net" net" I found this is used in:

net/ieee802154/6lowpan/core.c [0]

This file handles the IEEE 802.15.4 6LoWPAN interface to offering a
IPv6 interface with an IEEE 802.15.4 6LoWPAN adaption layer.

To the codeline "dev_get_by_index(src_net, nla_get_u32(tb[IFLA_LINK]));".
By calling "ip link add link wpan0 name lowpan0 type lowpan" the
lowpan_newlink function will be called and we need to find the wpan interface
(returned as real_dev in this case).

Namespace setting in wpan interface:

Currently we don't use any net namespace settings there, also we don't
change the net namespace. The default net namespace for a wpan shoule be
"init_net".

So this line could be also written as (I found also some others code which search
the wpan interface in &init_net):

diff --git a/net/ieee802154/6lowpan/core.c b/net/ieee802154/6lowpan/core.c
index 9dbe0d69..495c6ad 100644
--- a/net/ieee802154/6lowpan/core.c
+++ b/net/ieee802154/6lowpan/core.c
@@ -151,7 +151,7 @@ static int lowpan_newlink(struct net *src_net, struct net_device *dev,
        if (!tb[IFLA_LINK])
                return -EINVAL;
        /* find and hold real wpan device */
-       real_dev = dev_get_by_index(src_net, nla_get_u32(tb[IFLA_LINK]));
+       real_dev = dev_get_by_index(&init_net, nla_get_u32(tb[IFLA_LINK]));
        if (!real_dev)
                return -ENODEV;
        if (real_dev->type != ARPHRD_IEEE802154) {



The above code is for finding the wpan interface (the real 802.15.4 L2 interface).
For the IEEE 802.15.4 6LoWPAN interface the whole IPv6 implementation is
used. This interface will be created inside function "newlink".

Running "grep -r "src_net" net/ipv6" reports me alot uses of "src_net".
Don't know if this information is really necessary.

Should I set now the NETIF_F_NETNS_LOCAL for both interface types?

- Alex

[0] http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/tree/net/ieee802154/6lowpan/core.c#n154
