From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: pull request (net-next): ipsec-next 2017-04-20
Date: Thu, 20 Apr 2017 10:54:59 +0200
Message-ID: <1492678515-14347-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:51542 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S939519AbdDTIzy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Apr 2017 04:55:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds the basic infrastructure for IPsec hardware
offloading, it creates a configuration API and adjusts
the packet path.

1) Add the needed netdev features to configure IPsec offloads.

2) Add the IPsec hardware offloading API.

3) Prepare the ESP packet path for hardware offloading.

4) Add gso handlers for esp4 and esp6, this implements
   the software fallback for GSO packets.

5) Add xfrm replay handler functions for offloading.

6) Change ESP to use a synchronous crypto algorithm on
   offloading, we don't have the option for asynchronous
   returns when we handle IPsec at layer2.

7) Add a xfrm validate function to validate_xmit_skb. This
   implements the software fallback for non GSO packets.

8) Set the inner_network and inner_transport members of
   the SKB, as well as encapsulation, to reflect the actual
   positions of these headers, and removes them only once
   encryption is done on the payload.
   From Ilan Tayari.

9) Prepare the ESP GRO codepath for hardware offloading.

10) Fix incorrect null pointer check in esp6.
    From Colin Ian King.

11) Fix for the GSO software fallback path to detect the
    fallback correctly.
    From Ilan Tayari.

Please pull or let me know if there are problems.

Thanks!

The following changes since commit f221dcd91d20cdcb893cf6e9c8894b7d6c97d649:

  Merge branch 'net-smc-next' (2017-04-11 23:01:15 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec-next.git master

for you to fetch changes up to 8f92e03ecca390beed3d5ccc81023d050f0369fd:

  esp4/6: Fix GSO path for non-GSO SW-crypto packets (2017-04-19 07:48:57 +0200)

----------------------------------------------------------------
Colin Ian King (1):
      esp6: fix incorrect null pointer check on xo

Ilan Tayari (2):
      xfrm: Add encapsulation header offsets while SKB is not encrypted
      esp4/6: Fix GSO path for non-GSO SW-crypto packets

Steffen Klassert (13):
      net: Add ESP offload features
      xfrm: Add a xfrm type offload.
      xfrm: Move device notifications to a sepatate file
      xfrm: Add mode handlers for IPsec on layer 2
      xfrm: Add an IPsec hardware offloading API
      esp6: Remame esp_input_done2
      esp4: Reorganize esp_output
      esp6: Reorganize esp_output
      esp: Add gso handlers for esp4 and esp6
      xfrm: Add xfrm_replay_overflow functions for offloading
      esp: Use a synchronous crypto algorithm on offloading.
      net: Add a xfrm validate function to validate_xmit_skb
      xfrm: Prepare the GRO codepath for hardware offloading.

 include/linux/netdev_features.h |   8 +-
 include/linux/netdevice.h       |  15 ++
 include/linux/skbuff.h          |   2 +
 include/net/esp.h               |  19 +++
 include/net/xfrm.h              | 108 +++++++++++-
 include/uapi/linux/xfrm.h       |   8 +
 net/core/dev.c                  |   3 +
 net/core/ethtool.c              |   3 +
 net/ipv4/esp4.c                 | 370 ++++++++++++++++++++++------------------
 net/ipv4/esp4_offload.c         | 231 +++++++++++++++++++++++--
 net/ipv4/xfrm4_mode_transport.c |  34 ++++
 net/ipv4/xfrm4_mode_tunnel.c    |  28 +++
 net/ipv4/xfrm4_output.c         |   3 +-
 net/ipv6/esp6.c                 | 292 +++++++++++++++++--------------
 net/ipv6/esp6_offload.c         | 233 +++++++++++++++++++++++--
 net/ipv6/xfrm6_mode_transport.c |  34 ++++
 net/ipv6/xfrm6_mode_tunnel.c    |  27 +++
 net/ipv6/xfrm6_output.c         |   9 +-
 net/xfrm/Makefile               |   1 +
 net/xfrm/xfrm_device.c          | 208 ++++++++++++++++++++++
 net/xfrm/xfrm_input.c           |  41 ++++-
 net/xfrm/xfrm_output.c          |  46 ++++-
 net/xfrm/xfrm_policy.c          |  27 +--
 net/xfrm/xfrm_replay.c          | 162 +++++++++++++++++-
 net/xfrm/xfrm_state.c           | 147 ++++++++++++++++
 net/xfrm/xfrm_user.c            |  28 +++
 26 files changed, 1717 insertions(+), 370 deletions(-)
 create mode 100644 net/xfrm/xfrm_device.c
