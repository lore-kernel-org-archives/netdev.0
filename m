From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next v2 0/2] net: vrf: Fixup PKTINFO to return enslaved device index
Date: Fri,  6 May 2016 18:49:39 -0700
Message-ID: <1462585781-9146-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:36498 "EHLO
	mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758915AbcEGBtu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2016 21:49:50 -0400
Received: by mail-pf0-f169.google.com with SMTP id c189so56973937pfb.3
        for <netdev@vger.kernel.org>; Fri, 06 May 2016 18:49:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Applications such as OSPF and BFD need the original ingress device not
the VRF device; the latter can be derived from the former. To that end
move the packet intercept from an rx handler that is invoked by
__netif_receive_skb_core to the ipv4 and ipv6 receive processing.

IPv6 already saves the skb_iif to the control buffer in ipv6_rcv. Since
the skb->dev has not been switched the cb has the enslaved device. Make
the same happen for IPv4 by adding the skb_iif to inet_skb_parm and set
it in ipv4 code after clearing the skb control buffer similar to IPv6.
>From there the pktinfo can just pull it from cb with the PKTINFO_SKB_CB
cast. 

David Ahern (2):
  net: l3mdev: Add hook in ip and ipv6
  net: original ingress device index in PKTINFO

 drivers/net/vrf.c         | 188 ++++++++++++++++++++++------------------------
 include/linux/ipv6.h      |  17 ++++-
 include/linux/netdevice.h |   2 +
 include/net/ip.h          |   1 +
 include/net/l3mdev.h      |  43 +++++++++++
 include/net/tcp.h         |   4 +-
 net/core/dev.c            |   3 +-
 net/ipv4/ip_input.c       |   8 ++
 net/ipv4/ip_sockglue.c    |   7 +-
 net/ipv6/ip6_input.c      |   7 ++
 10 files changed, 178 insertions(+), 102 deletions(-)

-- 
2.1.4
