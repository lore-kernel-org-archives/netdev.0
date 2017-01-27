From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH v2 net-next 0/4] sfc: encapsulated filters
Date: Fri, 27 Jan 2017 15:00:45 +0000
Message-ID: <9baa375c-b3b1-f640-04fb-e234c85a4e93@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: <linux-net-drivers@solarflare.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:11793 "EHLO
        nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754861AbdA0PHk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 10:07:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds support for setting up filters for encapsulated traffic on
SFC 8000-series adapters, which recognise VXLAN, GENEVE and NVGRE packets by
parsing packet headers.  (VXLAN and GENEVE will only be recognised if the
driver on the primary PF has notified the firmware of relevant UDP ports,
which this driver does not yet do.)
While the driver currently has no way of using these filters for flow
steering, it is nonetheless necessary to insert catch-all (aka 'default')
filters to direct this traffic, similar to the existing unencapsulated uni-
and multi-cast catch-all filters, as otherwise the traffic will be dropped
by the NIC - implementation details of the hardware filtering mean that the
traffic will not get matched on outer MAC address to unencapsulated catch-
all filters.  (Yes, this is a mess.)
Although this is, therefore, fixing a bug in the existing driver, it's a bug
which has existed since 8000 series support was added, and the fix involves
quite a big patch with an 'adding features' flavour to it, hence why this is
for net-next rather than net and stable.

v2: move netif_cond_dbg into netdevice.h and its own patch

---
Edward Cree (2):
  net: implement netif_cond_dbg macro
  sfc: insert catch-all filters for encapsulated traffic

Jon Cooper (2):
  sfc: fixes to filter restore handling
  sfc: refactor debug-or-warnings printks

 drivers/net/ethernet/sfc/ef10.c   | 582 ++++++++++++++++++++++++++++----------
 drivers/net/ethernet/sfc/filter.h |  41 ++-
 drivers/net/ethernet/sfc/mcdi.c   |  19 +-
 include/linux/netdevice.h         |   9 +
 4 files changed, 497 insertions(+), 154 deletions(-)
