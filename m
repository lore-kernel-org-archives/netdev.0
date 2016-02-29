From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [PATCH next 0/3] IPvlan L3 symetric mode
Date: Mon, 29 Feb 2016 14:08:04 -0800
Message-ID: <1456783684-18374-1-git-send-email-mahesh@bandewar.net>
Cc: Mahesh Bandewar <maheshb@google.com>,
	Eric Dumazet <edumazet@google.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:33204 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753109AbcB2WIQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Feb 2016 17:08:16 -0500
Received: by mail-pa0-f68.google.com with SMTP id y7so9295616paa.0
        for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 14:08:15 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>

One of the major request (for enhancement) that I have received
from various users of IPvlan in L3 mode is its inability to handle
IPtables.

In a typical IPvlan L3 setup where master is in default-ns and 
each slave is into different (slave) ns. In this setup egress
packet processing for traffic originating from slave-ns will
hit all NF_HOOKs in slave-ns as well as default-ns. However same
is not true for ingress processing. All these NF_HOOKs are
hit only in the slave-ns skipping them in the default-ns.
IPvlan in L3 mode is restrictive and it's preferred to hit these
hooks in master's ns than in slave's ns (L2 mode is where these
hooks will be hit only in slave's ns).

This can be achieved by adding a device pointer in net_device
struct. Stack will use this device reference and associated ns
for all egress L3 processing. By default this is initialized to
self so skb->dev would be same as skb->dev->l3_dev and hence the
normal path will stay unchanged. Also since l3_dev is in the
same RX cache line, there should not be any additional cost.

IPvlan slaves OTOH can assign (nominate) its master to its l3_dev
so that L3 processing happens in master's ns

Please check individual patches for the details.

Mahesh Bandewar (3):
  dev: Add netif_get_l3_dev() helper
  ipvlan: Use netif_get_l3_dev() to implement L3-symmetric mode.
  net: update L3 path with device selection logic

 drivers/net/ipvlan/ipvlan_main.c | 16 +++++++++-------
 include/linux/netdevice.h        |  6 ++++++
 net/core/dev.c                   | 10 +++++++---
 net/ipv4/ip_input.c              |  5 +++--
 net/ipv6/ip6_input.c             |  5 +++--
 5 files changed, 28 insertions(+), 14 deletions(-)

-- 
2.7.0.rc3.207.g0ac5344
