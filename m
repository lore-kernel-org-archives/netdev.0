From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 0/6] net: Checksum offload changes - Part VI
Date: Sun, 31 Aug 2014 15:12:40 -0700
Message-ID: <1409523166-9215-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:47414 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751707AbaHaWNE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Aug 2014 18:13:04 -0400
Received: by mail-pa0-f49.google.com with SMTP id kq14so10539711pab.8
        for <netdev@vger.kernel.org>; Sun, 31 Aug 2014 15:13:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am working on overhauling RX checksum offload. Goals of this effort
are:

- Specify what exactly it means when driver returns CHECKSUM_UNNECESSARY
- Preserve CHECKSUM_COMPLETE through encapsulation layers
- Don't do skb_checksum more than once per packet
- Unify GRO and non-GRO csum verification as much as possible
- Unify the checksum functions (checksum_init)
- Simplify code

What is in this seventh patch set:

- Add skb->csum. This allows a device or GRO to indicate that an
  invalid checksum was detected.
- Checksum unncessary to checksum complete conversions.

With these changes, I believe that the third goal of the overhaul is
now mostly achieved. In the case of no encapsulation or one layer of
encapsulation, there should only be at most one skb_checksum over
each packet (between GRO and normal path). In the case of two layers
of encapsulation, it is still possible with the right combination of
non-zero and zero UDP checksums to have >1 skb_checksum. For instance:
IP>GRE(with csum)>IP>UDP(zero csum)>VXLAN>IP>UDP(non-zero csum),
would likely necessiate an skb_checksum in GRO and normal path.
This doesn't seem like a common scenario at all so I'm inclined to
not address this now, if multiple layers of encapsulation becomes
popular we can reassess.

Note that checksum conversion shows a nice improvement for RX VXLAN when
outer UDP checksum is enabled (12.65% CPU compared to 20.94%). This
is not only from the fact that we don't need checksum calculation on
the host, but also allows GRO for VXLAN in this case. Checksum
conversion does not help send side (which still needs to perform
a checksum on host). For that we will implement remote checksum offload
in a later patch
(http://tools.ietf.org/html/draft-herbert-remotecsumoffload-00).

Please review carefully and test if possible, mucking with basic
checksum functions is always a little precarious :-)

----

Test results with this patch set are below. I did not see any
obvious performace regression.

Tests run:
   TCP_STREAM: super_netperf with 200 streams

Device bnx2x (10Gbps):
   VXLAN UDP RSS port hashing enabled, UDP RX checksum offload supported.

* VXLAN with checksum
  With fix:
    TCP_STREAM
        12.65% CPU utilization
        9093.81 Mbps
  Without fix:
    TCP_STREAM
        20.94% CPU utilization
        9094.21 Mbps

* VXLAN without checksum
  With fix:
    TCP_STREAM
        24.59% CPU utilization
        9080.96 Mbps
  Without fix:
    TCP_STREAM
        24.69% CPU utilization
        9081.39 Mbps

Tom Herbert (6):
  net: Support for csum_bad in skbuff
  net: Infrastructure for checksum unnecessary conversions
  udp: Add support for doing checksum unnecessary conversion
  gre: Add support for checksum unnecessary conversions
  vxlan: Enable checksum unnecessary conversions for vxlan/UDP sockets
  l2tp: Enable checksum unnecessary conversions for l2tp/UDP sockets

 drivers/net/vxlan.c       |  2 ++
 include/linux/netdevice.h | 24 +++++++++++++++++++++++-
 include/linux/skbuff.h    | 41 ++++++++++++++++++++++++++++++++++++++++-
 include/linux/udp.h       | 16 +++++++++++++++-
 net/core/dev.c            |  2 +-
 net/ipv4/gre_demux.c      |  4 ++++
 net/ipv4/gre_offload.c    |  8 ++++++--
 net/ipv4/udp.c            |  4 ++++
 net/ipv4/udp_offload.c    | 25 +++++++++++++++++--------
 net/ipv6/udp.c            |  4 ++++
 net/ipv6/udp_offload.c    | 24 +++++++++++++++++-------
 net/l2tp/l2tp_core.c      |  2 ++
 12 files changed, 135 insertions(+), 21 deletions(-)

-- 
2.1.0.rc2.206.gedb03e5
