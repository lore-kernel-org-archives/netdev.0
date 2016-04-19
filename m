From: Edward Cree <ecree@solarflare.com>
Subject: [RFC PATCH net-next 0/8] Handle multiple received packets at each
 stage
Date: Tue, 19 Apr 2016 14:33:02 +0100
Message-ID: <5716338E.4050003@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	<linux-net-drivers@solarflare.com>
To: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:23490 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752739AbcDSNdP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 09:33:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Earlier discussions on this list[1] suggested that having multiple packets
traverse the network stack together (rather than calling the stack for each
packet singly) could improve performance through better cache locality.
This patch series is an attempt to implement this by having drivers pass an
SKB list to the stack at the end of the NAPI poll.  The stack then attempts
to keep the list together, only splitting it when either packets need to be
treated differently, or the next layer of the stack is not list-aware.

The first two patches simply place received packets on a list during the
event processing loop on the sfc EF10 architecture, then call the normal
stack for each packet singly at the end of the NAPI poll.
The remaining patches extend the 'listified' processing as far as the IP
receive handler.

Packet rate was tested with NetPerf UDP_STREAM, with 10 streams of 1-byte
packets, and the process and interrupt pinned to a single core on the RX
side.
The NIC was a 40G Solarflare 7x42Q; the CPU was a Xeon E3-1220V2 @ 3.10GHz.
Baseline:      5.07Mpps
after patch 2: 5.59Mpps (10.2% above baseline)
after patch 8: 6.44Mpps (25.6% above baseline)

I also attempted to measure the latency, but couldn't get reliable numbers;
my best estimate is that the series cost about 160ns if interrupt moderation
is disabled and busy-poll is enabled; about 60ns vice-versa.
I tried adding a check in the driver to only perform bundling if interrupt
moderation was active on the channel, but was unable to demonstrate any
latency gain from this, so I have omitted it from this series.

[1] http://thread.gmane.org/gmane.linux.network/395502

Edward Cree (8):
  net: core: trivial netif_receive_skb_list() entry point
  sfc: batch up RX delivery on EF10
  net: core: unwrap skb list receive slightly further
  net: core: Another step of skb receive list processing
  net: core: another layer of lists, around PF_MEMALLOC skb handling
  net: core: propagate SKB lists through packet_type lookup
  net: ipv4: listified version of ip_rcv
  net: ipv4: listify ip_rcv_finish

 drivers/net/ethernet/sfc/ef10.c       |   9 ++
 drivers/net/ethernet/sfc/efx.c        |   2 +
 drivers/net/ethernet/sfc/net_driver.h |   3 +
 drivers/net/ethernet/sfc/rx.c         |   7 +-
 include/linux/netdevice.h             |   4 +
 include/linux/netfilter.h             |  27 ++++
 include/linux/skbuff.h                |  16 +++
 include/net/ip.h                      |   2 +
 include/trace/events/net.h            |  14 ++
 net/core/dev.c                        | 245 ++++++++++++++++++++++++++++------
 net/ipv4/af_inet.c                    |   1 +
 net/ipv4/ip_input.c                   | 127 ++++++++++++++++--
 12 files changed, 409 insertions(+), 48 deletions(-)
