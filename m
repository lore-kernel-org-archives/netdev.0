From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH 0/2] GENEVE/VXLAN: Enable outer Tx checksum by
 default
Date: Fri, 19 Feb 2016 11:26:17 -0800
Message-ID: <20160219191806.15687.37621.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net,
	alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:33449 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1948232AbcBST0U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2016 14:26:20 -0500
Received: by mail-pa0-f47.google.com with SMTP id fl4so55090252pad.0
        for <netdev@vger.kernel.org>; Fri, 19 Feb 2016 11:26:19 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series makes it so that we enable the outer Tx checksum for IPv4
tunnels by default.  This makes the behavior consistent with how we were
handling this for IPv6.  In addition I have updated the internal flags for
these tunnels so that we use a ZERO_CSUM_TX flag for IPv4 which should
match up will with the ZERO_CSUM6_TX flag which was already in use for
IPv6.

For most network devices this should be a net gain in terms of performance
as having the outer header checksum present allows for devices to report
CHECKSUM_UNNECESSARY which we can then convert to CHECKSUM_COMPLETE in order
to determine if the inner header checksum is valid.

Below is some data I collected with ixgbe with an X540 that demonstrates
this.  I located two PFs connected back to back in two different name
spaces and then setup a pair of tunnels on each, one with checksum enabled
and one without.

Recv   Send    Send                          Utilization
Socket Socket  Message  Elapsed              Send
Size   Size    Size     Time     Throughput  local
bytes  bytes   bytes    secs.    10^6bits/s  % S

noudpcsum:
 87380  16384  16384    30.00      8898.67   12.80
udpcsum:
 87380  16384  16384    30.00      9088.47   5.69

The one spot where this may cause a performance regression is if the
environment contains devices that can parse the inner headers and a device
supports NETIF_F_GSO_UDP_TUNNEL but not NETIF_F_GSO_UDP_TUNNEL_CSUM.  In
the case of such a device we have to fall back to using GSO to segment the
tunnel instead of TSO and as a result we may take a performance hit as seen
below with i40e.

Recv   Send    Send                          Utilization
Socket Socket  Message  Elapsed              Send
Size   Size    Size     Time     Throughput  local
bytes  bytes   bytes    secs.    10^6bits/s  % S

noudpcsum:
 87380  16384  16384    30.00      9085.21   3.32
udpcsum:
 87380  16384  16384    30.00      9089.23   5.54

In addition it will be necessary to update iproute2 so that we don't
provide the checksum attribute unless specified.  This way on older kernels
which don't have local checksum offload we will default to disabling the
outer checksum, and on newer kernels that have LCO we can default to
enabling it.

I also haven't investigated the effect this will have on OVS.  However I
suspect the impact should be minimal as the worst case scenario should be
that Tx checksumming will become enabled by default which should be
consistent with the existing behavior for IPv6.

---

Alexander Duyck (2):
      GENEVE: Support outer IPv4 Tx checksums by default
      VXLAN: Support outer IPv4 Tx checksums by default


 drivers/net/geneve.c |   16 ++++++++--------
 drivers/net/vxlan.c  |   19 +++++++++----------
 include/net/vxlan.h  |    2 +-
 3 files changed, 18 insertions(+), 19 deletions(-)
