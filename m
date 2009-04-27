From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: skb_warn_if_lro(skb) in ip_forward()
Date: Mon, 27 Apr 2009 08:53:23 +0200
Message-ID: <49F55663.1050705@cosmosbay.com>
References: <dac45060904262343v481d2665s4074e901852406b5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Mark Ryden <markryde@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:34918 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754101AbZD0GxZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2009 02:53:25 -0400
In-Reply-To: <dac45060904262343v481d2665s4074e901852406b5@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mark Ryden a =E9crit :
> Hello,
>=20
> I would appreciate if somebody will explain in a few sentences, why,
> when forwarding
> a packet in IPV4 , in ip_forward() method, (net/ipv4/ip_forward.c) we
> drop the packet
> if it is lro.
>=20
> To be more specific, why do we have, in ip_forward() :
> ...
> ...
> if (skb_warn_if_lro(skb))
> 	goto drop;

git blame is your friend :)

-> commit 4497b0763cb1afae463f5e144c28b5d806e28b60 added this call

net: Discard and warn about LRO'd skbs received for forwarding

Then google search gave :

http://kerneltrap.org/index.php?q=3Dmailarchive/linux-netdev/2008/6/19/=
2173204

Large Receive Offload (LRO) destroys packet headers that should be
preserved when forwarding.  Currently it also triggers a BUG() or WARN(=
)
in skb_gso_segment().  We should disable it wherever forwarding is
enabled, and discard LRO skbs with a warning if it is turned back on.

Since the previous version of these patches, I have:
- Tightened the test for LRO'd skbs, so it should not catch skbs from
  VM guests that want GSO
- Made the test an inline function, with the warning a separate extern
  function
- Rebased against net-next-2.6

Ben.

Ben Hutchings (2):
  net: Disable LRO on devices that are forwarding
  net: Discard and warn about LRO'd skbs received for forwarding

 include/linux/netdevice.h |    1 +
 include/linux/skbuff.h    |   14 ++++++++++++++
 net/bridge/br_forward.c   |    2 +-
 net/bridge/br_if.c        |    1 +
 net/core/dev.c            |   24 ++++++++++++++++++++++++
 net/core/skbuff.c         |    8 ++++++++
 net/ipv4/devinet.c        |   21 ++++++++++++++++-----
 net/ipv4/ip_forward.c     |    3 +++
 net/ipv6/addrconf.c       |    6 ++++++
 net/ipv6/ip6_output.c     |    3 +++
 10 files changed, 77 insertions(+), 6 deletions(-)


