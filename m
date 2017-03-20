From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/13][pull request] 40GbE Intel Wired LAN Driver Updates 2017-03-20
Date: Mon, 20 Mar 2017 16:46:59 -0700
Message-ID: <20170320234712.84157-1-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:49349 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754163AbdCTXrS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 20 Mar 2017 19:47:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf only.

Philippe Reynes updates i40e and i40evf to use the new ethtool API for
{get|set}_link_ksettings.

Jake provides the remaining patches in the series, starting with a fix
for i40e where the firmware expected the port numbers for the offloaded
UDP tunnels in Little Endian format and we were sending them in Big Endian
format which put the wrong port number to be put in the UDP tunnel list.
Changed the driver to use __be32 values instead of arrays for
(src|dst)_ip.  Refactored the exit flow of i40e_add_fdir_ethtool() which
removes the dependency on having a non-zero return value.  Fixed a memory
leak by running kfree() and returning immediately when we fail to add
flow director filter.  Fixed a potential issue where could update the
filter count without actually succeeding in adding a filter, by moving
the ATR exit check to after we have sent the TCP/IPv4 filter to the ring
successfully.  Ensures that the fd_tcp_rule count is reset to 0, before
we reprogram the filters so that we do not end up with a stale count
which does not correctly reflect the number of programmed filters.  Added
a check whether we have TCP/IPv4 filters before re-enabling ATR after
flushing and replaying FDIR filters.  Added counters for each filter
type in preparation for adding code to properly check the mask value.
Fixed potential issues by explicitly checking the flow type at the
start of i40e_add_fdir_ethtool().  To avoid possible memory leaks,
we now unconditionally delete the old filter, even if it is identical to
the new filter and ensures will always update the filters as expected.

The following are changes since commit fe723dff0fa4181ddb8116e72bc67d00d4239cb6:
  liquidio: fix wrong information about link modes reported to ethtool
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 40GbE

Jacob Keller (11):
  i40e: send correct port number to AdminQ when enabling UDP tunnels
  i40e: don't use arrays for (src|dst)_ip
  i40e: rework exit flow of i40e_add_fdir_ethtool
  i40e: return immediately when failing to add fdir filter
  i40e: exit ATR mode only when adding TCP/IPv4 filter succeeds
  i40e: remove redundant check for fd_tcp_rule when restoring filters
  i40e: reset fd_tcp_rule count when restoring filters
  i40e: don't re-enable ATR when flushing filters if SB has TCP4/IPv4
    rules
  i40e: add counters for UDP/IPv4 and IPv4 filters
  i40e: explicitly fail on extended MAC field for ethtool_rx_flow_spec
  i40e: always remove old filter when adding new FDir filter

Philippe Reynes (2):
  i40e: use new api ethtool_{get|set}_link_ksettings
  i40evf: use new api ethtool_{get|set}_link_ksettings

 drivers/net/ethernet/intel/i40e/i40e.h             |  16 +-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     | 323 ++++++++++++---------
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  43 +--
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        |  84 +++---
 drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c |  31 +-
 5 files changed, 273 insertions(+), 224 deletions(-)

-- 
2.12.0
