From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [PATCH next v2 0/7] Introduce l3_dev pointer for L3 processing
Date: Wed,  9 Mar 2016 13:49:49 -0800
Message-ID: <1457560189-12870-1-git-send-email-mahesh@bandewar.net>
Cc: Mahesh Bandewar <maheshb@google.com>,
	Eric Dumazet <edumazet@google.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:33485 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750872AbcCIVt4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 16:49:56 -0500
Received: by mail-pa0-f66.google.com with SMTP id q6so4210390pav.0
        for <netdev@vger.kernel.org>; Wed, 09 Mar 2016 13:49:55 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>

One of the major request (for enhancement) that I have received
from various users of IPvlan in L3 mode is its inability to handle
IPtables.

While looking at the code and how we handle ingress, the problem
can be attributed to the asymmetry in the way packets get processed
for IPvlan devices configured in L3 mode. L3 mode is supposed to
be restrictive and all the L3 decisions need to be taken for the
traffic in master's ns. This does happen as expected for egress
traffic however on ingress traffic, the IPvlan packet-handler
changes the skb->dev and this forces packet to be processed with
the IPvlan slave and it's associated ns. This causes above mentioned
problem and few other which are not yet reported / attempted. e.g.
IPsec with L3 mode or even ingress routing.

This could have been solved if we had a way to handover packet to
slave and associated ns after completing the L3 phase. This is a
non-trivial issue to fix especially looking at IPsec code.

This patch series attempts to solve this problem by introducing the
device pointer l3_dev which resides in net_device structure in the
RX cache line. We initialize the l3_dev to self. This would mean
there is no complex logic to when-and-how-to initialize it. Now
the stack will use this dev pointer during the L3 phase. This should
not alter any existing properties / behavior and also there should
not be any additional penalties since it resides in the same RX
cache line. 

Now coming back to IPvlan setup. The typical IPvlan L3 setup where
master is in default-ns while the slaves are put inside different
(slave) net-ns. During the initialization phase, the driver can
make l3_dev for each slave to point to its master-device. This will
solve the current IPT problem as well as make the packet processing
symmetric from stack perspective. For all other packet processing
since dev->l3_dev is same as dev, there should not be any behavioral
or functional change. 

Mahesh Bandewar (7):
  dev: Add netif_get_l3_dev() helper
  dev: Update packet dispatcher to pass l3_dev as an input device
  ipv4: Use l3_dev for L3 ingress processing
  ipv6: Use l3_dev for L3 ingress processing
  raw: Use l3_dev for L3 ingress raw packet delivery
  xfrm: Use l3_dev for xfrm policy checks.
  ipvlan: Implement L3-symmetric mode.

 drivers/net/ipvlan/ipvlan_main.c | 16 +++++++++-------
 include/linux/netdevice.h        |  6 ++++++
 include/net/xfrm.h               |  2 +-
 net/core/dev.c                   | 10 +++++++---
 net/ipv4/ip_input.c              | 12 +++++++-----
 net/ipv4/ip_options.c            |  3 ++-
 net/ipv4/raw.c                   | 11 +++++------
 net/ipv6/ip6_input.c             | 14 ++++++++------
 net/ipv6/raw.c                   |  2 +-
 net/ipv6/route.c                 |  7 ++++---
 net/xfrm/xfrm_policy.c           |  4 ++--
 11 files changed, 52 insertions(+), 35 deletions(-)

-- 
2.7.0.rc3.207.g0ac5344
