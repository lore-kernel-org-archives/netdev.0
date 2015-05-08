From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next v2 0/7] netns: ease netlink use with a lot of netns
Date: Fri, 08 May 2015 07:02:17 -0500
Message-ID: <874mnn9t12.fsf@x220.int.ebiederm.org>
References: <1430906288-5108-1-git-send-email-nicolas.dichtel@6wind.com>
	<1430989373-4515-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, tgraf@suug.ch, davem@davemloft.net
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:35817 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750968AbbEHMGu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2015 08:06:50 -0400
In-Reply-To: <1430989373-4515-1-git-send-email-nicolas.dichtel@6wind.com>
	(Nicolas Dichtel's message of "Thu, 7 May 2015 11:02:46 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


So I am dense.  I have read through the patches and I don't see where
you tag packets from other network namespaces with a network namespace
id.

In fact I don't even see an attribute that is approrpriate for such
tagging.

Your comment below indicates such tagging is taking place but I am dense
and I am not seeing it.

Eric

Nicolas Dichtel <nicolas.dichtel@6wind.com> writes:

> This idea was informally discussed in Ottawa / netdev0.1. The goal is to
> ease the use/scalability of netns, from a userland point of view.
> Today, users need to open one netlink socket per family and per netns.
> Thus, when the number of netns inscreases (for example 5K or more), the
> number of sockets needed to manage them grows a lot.
>
> The goal of this series is to be able to monitor netlink events, for a
> specified family, for a set of netns, with only one netlink socket. For
> this purpose, a netlink socket option is added: NETLINK_LISTEN_ALL_NSID.
> When this option is set on a netlink socket, this socket will receive
> netlink notifications from all netns that have a nsid assigned into the
> netns where the socket has been opened.
> The nsid is sent to userland via an anscillary data.
>
> Here is an example with a patched iproute2. vxlan10 is created in the
> current netns (netns0, nsid 0) and then moved to another netns (netns1,
> nsid 1):
>
> $ ip netns exec netns0 ip monitor all-nsid label
> [nsid 0][NSID]nsid 1 (iproute2 netns name: netns1)
> [nsid 0][NEIGH]??? lladdr 00:00:00:00:00:00 REACHABLE,PERMANENT
> [nsid 0][LINK]5: vxlan10@NONE: <BROADCAST,MULTICAST> mtu 1450 qdisc noop state DOWN group default 
>     link/ether 92:33:17:e6:e7:1d brd ff:ff:ff:ff:ff:ff
> [nsid 0][LINK]Deleted 5: vxlan10@NONE: <BROADCAST,MULTICAST> mtu 1450 qdisc noop state DOWN group default 
>     link/ether 92:33:17:e6:e7:1d brd ff:ff:ff:ff:ff:ff
> [nsid 1][NSID]nsid 0 (iproute2 netns name: netns0)
> [nsid 1][LINK]5: vxlan10@NONE: <BROADCAST,MULTICAST> mtu 1450 qdisc noop state DOWN group default 
>     link/ether 92:33:17:e6:e7:1d brd ff:ff:ff:ff:ff:ff link-netnsid 0
> [nsid 1][ADDR]5: vxlan10    inet 192.168.0.249/24 brd 192.168.0.255 scope global vxlan10
>        valid_lft forever preferred_lft forever
> [nsid 1][ROUTE]local 192.168.0.249 dev vxlan10  table local  proto kernel  scope host  src 192.168.0.249 
> [nsid 1][ROUTE]ff00::/8 dev vxlan10  table local  metric 256  pref medium
> [nsid 1][ROUTE]2001:123::/64 dev vxlan10  proto kernel  metric 256  pref medium
> [nsid 1][LINK]5: vxlan10@NONE: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue state UNKNOWN group default 
>     link/ether 92:33:17:e6:e7:1d brd ff:ff:ff:ff:ff:ff link-netnsid 0
> [nsid 1][ROUTE]broadcast 192.168.0.255 dev vxlan10  table local  proto kernel  scope link  src 192.168.0.249 
> [nsid 1][ROUTE]192.168.0.0/24 dev vxlan10  proto kernel  scope link  src 192.168.0.249 
> [nsid 1][ROUTE]broadcast 192.168.0.0 dev vxlan10  table local  proto kernel  scope link  src 192.168.0.249 
> [nsid 1][ROUTE]fe80::/64 dev vxlan10  proto kernel  metric 256  pref medium
>
>
>  drivers/net/vxlan.c          |   2 +-
>  include/linux/netlink.h      |   2 +
>  include/net/net_namespace.h  |   2 +
>  include/uapi/linux/netlink.h |   1 +
>  net/core/net_namespace.c     | 132 ++++++++++++++++++++++++++++---------------
>  net/core/rtnetlink.c         |   2 +-
>  net/netlink/af_netlink.c     | 111 +++++++++++++++++++++++++-----------
>  7 files changed, 170 insertions(+), 82 deletions(-)
>
>
> Comments are welcome.
>
> Regards,
> Nicolas
