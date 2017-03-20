From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 0/2] net: vrf: performance improvements
Date: Mon, 20 Mar 2017 11:19:43 -0700
Message-ID: <1490033985-14874-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:34965 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756115AbdCTST6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Mar 2017 14:19:58 -0400
Received: by mail-pg0-f42.google.com with SMTP id t143so15399531pgb.2
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 11:19:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Device based features for VRF such as qdisc, netfilter and packet
captures are implemented by switching the dst on skbuffs to its per-VRF
dst. This has the effect of controlling the output function which points
a function in the VRF driver. [1] The skb proceeds down the stack with
dst->dev pointing to the VRF device. Netfilter, qdisc and tc rules and
network taps are evaluated based on this device. Finally, the skb makes
it to the vrf_xmit function which resets the dst based on a FIB lookup.

The feature comes at cost - between 5 and 10% depending on test (TCP vs
UDP, stream vs RR and IPv4 vs IPv6). The main cost is requiring a FIB
lookup in the VRF driver for each packet sent through it. The FIB lookup
is required because the real dst gets dropped so that the skb can
traverse the stack with dst->dev set to the VRF device.

All of that is really driven by the qdisc and not replicating the
processing of __dev_queue_xmit if a qdisc is set up on the device. But,
VRF devices by default do not have a qdisc and really have no need for
multiple Tx queues. This means the performance overhead is inflicted upon
all users for the potential use case of a qdisc being configured.

The overhead can be avoided by checking if the default configuration
applies to a specific VRF device before switching the dst. If a device
does not have a qdisc, the pass through netfilter hooks and packet taps
can be done inline without dropping the dst and thus avoiding the
performance penalty. With this change performance overhead of VRF drops
to neglible (difference with run-over-run variance) to 3% depending on
test type.

netperf performance comparison for 3 cases:
1. L3_MASTER_DEVICE compiled out
2. VRF with this patch set
3. current VRF code

IPv4
----
           no-l3mdev     new-vrf     old-vrf
TCP_RR       28778        28938*       27169
TCP_CRR      10706        10490         9770
UDP_RR       30750        29813        29256

* Although higher in the final run used for submitting this patch set, I
  think what this really represents is a neglible performance overhead for
  VRF with this change (i.e, within the +-1% variance of runs). Most
  notably the FIB lookups in the Tx path are avoided for TCP_RR.

IPv6
----
           no-l3mdev     new-vrf     old-vrf
TCP_RR       29495        29432       27794
TCP_CRR      10520        10338        9870
UDP_RR       26137        27019*      26511

* UDP is consistently better with VRF for two reasons:
  1. Source address selection with L3 domains is considering fewer
     addresses since only addresses on interfaces in the domain are
     considered for the selection. Specifically, perf-top shows
     shows ipv6_get_saddr_eval, ipv6_dev_get_saddr and __ipv6_dev_get_saddr
     running much lower with vrf than without.

  2. The VRF table contains all routes (i.e, there are no separate local
     and main tables per VRF). That means ip6_pol_route_output only has 1
     lookup for VRF where it does 2 without it (1 in the local table and 1
     in the main table).

[1] http://netdevconf.org/1.2/papers/ahern-what-is-l3mdev-paper.pdf

David Ahern (2):
  net: vrf: performance improvements for IPv4
  net: vrf: performance improvements for IPv6

 drivers/net/vrf.c | 172 +++++++++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 152 insertions(+), 20 deletions(-)

-- 
2.1.4
