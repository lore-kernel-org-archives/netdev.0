From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net 0/2] netns: audit netdevice creation with IFLA_NET_NS_[PID|FD]
Date: Mon, 26 Jan 2015 22:28:12 +0100
Message-ID: <1422307694-10079-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, dmitry.tarnyagin@lockless.no,
	arvid.brodin@alten.se, alex.aring@gmail.com,
	linux-wpan@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:41143 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753568AbbAZV2k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 16:28:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


When one of these attributes is set, the netdevice is created into the netns
pointed by IFLA_NET_NS_[PID|FD] (see the call to rtnl_create_link() in
rtnl_newlink()). Let's call this netns the dest_net. After this creation, if the
newlink handler exists, it is called with a netns argument that points to the
netns where the netlink message has been received (called src_net in the code)
which is the link netns.
Hence, with one of these attributes, it's possible to create a x-netns
netdevice.

Here is the result of my code review:
- all ip tunnels (sit, ipip, ip6_tunnels, gre[tap][v6], ip_vti[6]) does not
  really allows to use this feature: the netdevice is created in the dest_net
  and the src_net is completely ignored in the newlink handler.
- VLAN properly handles this x-netns creation.
- bridge ignores src_net, which seems fine (NETIF_F_NETNS_LOCAL is set).
- CAIF subsystem is not clear for me (I don't know how it works), but it seems
  to wrongly use src_net. Patch #1 tries to fix this, but it was done only by
  code review (and only compile-tested), so please carefully review it. I may
  miss something.
- HSR subsystem uses src_net to parse IFLA_HSR_SLAVE[1|2], but the netdevice has
  the flag NETIF_F_NETNS_LOCAL, so the question is: does this netdevice really
  supports x-netns? If not, the newlink handler should use the dest_net instead
  of src_net, I can provide the patch.
- ieee802154 uses also src_net and does not have NETIF_F_NETNS_LOCAL. Same
  question: does this netdevice really supports x-netns?
- bonding ignores src_net and flag NETIF_F_NETNS_LOCAL is set, ie x-netns is not
  supported. Fine.
- CAN does not support rtnl/newlink, ok.
- ipvlan uses src_net and does not have NETIF_F_NETNS_LOCAL. After looking at
  the code, it seems that this drivers support x-netns. Am I right?
- macvlan/macvtap uses src_net and seems to have x-netns support.
- team ignores src_net and has the flag NETIF_F_NETNS_LOCAL, ie x-netns is not
  supported. Ok.
- veth uses src_net and have x-netns support ;-) Ok.
- VXLAN didn't properly handle this. The link netns (vxlan->net) is the src_net
  and not dest_net (see patch #2). Note that it was already possible to create a
  x-netns vxlan before the commit f01ec1c017de ("vxlan: add x-netns support")
  but the nedevice remains broken.

To summarize:
 - CAIF patch must be carefully reviewed
 - for HSR, ieee802154, ipvlan: is x-netns supported?

 drivers/net/caif/caif_hsi.c |  1 -
 drivers/net/vxlan.c         | 10 +++++-----
 net/caif/chnl_net.c         |  1 -
 3 files changed, 5 insertions(+), 7 deletions(-)

Regards,
Nicolas
