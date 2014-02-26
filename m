From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net 0/3] yet another new mtu discovery mode
Date: Wed, 26 Feb 2014 01:20:40 +0100
Message-ID: <1393374043-796-1-git-send-email-hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:52920 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751785AbaBZAUt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Feb 2014 19:20:49 -0500
Received: from stressinduktion.org (localhost.localdomain [127.0.0.1])
	by order.stressinduktion.org (Postfix) with ESMTP id ABD481A0C213
	for <netdev@vger.kernel.org>; Wed, 26 Feb 2014 01:20:48 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

After my proposal for weakening the IP_PMTUDISC_INTERFACE mode to
produce fragments if the packet size exceeds the outgoing interface mtu
was rightfully rejected, I am now in the really bad position to have to
propose yet another IP_MTU_DISCOVER mode (I don't like to do that at all,
especially because I argued so favorably for the IP_PMTUDISC_INTERFACE
mode :( ).

Currently unbound and bind kind of use a fire-and-forget logic in
the UDP output path and are not propagating errors back. To use
IP_PMTUDISC_INTERFACE correctly, I would need to have access to the
unserialized dns data while trying the first send, checking for EMSGSIZE
and in case the syscall failed with EMSGSIZE, altering the dns data by
removing everything but question section and setting TC=1 and remembering
the new minimal outgoing udp packet size globally. The unserialized dns
data is mostly not available at that point the sending takes place.

That said, I propose this slightly weaker version of
IP_PMTUDISC_INTERFACE, which allows to send fragments if the packet
size exceeds the outgoing interface mtu. As such, I can now just change
IP_PMTUDISC_DONT, which is currently in use by dns software, to this new
option and we finally have fragmentation avoidance in dns. This option
seems much easier to support and will find users fast.

I propose this for the net branch, because I currently classify the logic
of IP_PMTUDISC_INTERFACE as flawed and want to fix this with this new
option. Hopefully IP_PMTUDISC_INTERFACE does still serve a purpose for
someone out there. Because of the preparations for IP_PMTUDISC_INTERFACE
the changes are not too big and it luckily doesn't need additional space
in the sock structs.

The first patch ensures we cut the packet into pieces of the size of
the interface mtu and not of the pmtu in case of IP_PMTUDISC_INTERFACE.

Thanks and very sorry for bloating kernel api,

  Hannes

Included patches:
 ipv4: use ip_skb_dst_mtu instead of
 ipv4: yet another new IP_MTU_DISCOVER option
 ipv6: yet another new IPV6_MTU_DISCOVER option

Diffstat:
 include/net/ip.h         |  9 ++++++++-
 include/net/ip6_route.h  |  9 ++++++++-
 include/uapi/linux/in.h  |  4 ++++
 include/uapi/linux/in6.h |  4 ++++
 net/ipv4/ip_output.c     | 12 ++++--------
 net/ipv4/ip_sockglue.c   |  2 +-
 net/ipv6/ip6_output.c    |  9 +++++----
 net/ipv6/ipv6_sockglue.c |  2 +-
 8 files changed, 35 insertions(+), 16 deletions(-)
