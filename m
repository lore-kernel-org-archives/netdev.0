From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/16][pull request] 40GbE Intel Wired LAN Driver Updates 2016-02-18
Date: Thu, 18 Feb 2016 16:31:05 -0800
Message-ID: <1455841881-128892-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:49646 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1948825AbcBSAbY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Feb 2016 19:31:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf only.

Alex Duyck provides all the patches in the series to update and fix the
drivers.  Fixed the driver to drop the outer checksum offload on UDP
tunnels, since the issue is that the upper levels of the stack never
requested such an offload and it results in possible errors.  Updates the
TSO function to just use u64 values, so we do not have to end up casting
u32 values.  In the TSO path, factored out the L4 header offsets allowing
us to ignore the L4 header offsets when dealing with the L3 checksum and
length update.  Consolidates all of the spots where we were updating
either the TCP or IP checksums in the TSO and checksum path into the TSO
function.  Fixed two issues by adding support for IPv4 encapsulated in
IPv6, first issue was the fact that iphdr(skb)->protocol was being used to
test for the outer transport protocol which breaks IPv6 support.  The second
was that we cleared the flag for v4 going to v6, but we did not take care
of txflags going the other way.  Added support for IPv6 extension headers
in setting up the Tx checksum.  Added exception handling to the Tx
checksum path so that we can handle cases of TSO where the frame is bad,
or Tx checksum where we did not recognize a protocol.  Fixed a number of
issues to make certain that we are using the correct protocols when
parsing both the inner and outer headers of a frame that is mixed between
IPv4 and IPv6 for inner and outer.  Updated the feature flags to reflect
the newly enabled/added features.

Sorry, no witty patch descriptions this time around, probably should
let Mitch help in writing patch descriptions for Alex. :-)

The following are changes since commit 7e6e18fbc033e00a4d4af3d4ea7bad0db6b7ad1b:
  net_sched: Improve readability of filter processing
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 40GbE

Alexander Duyck (16):
  i40e/i40evf: Drop outer checksum offload that was not requested
  i40e/i40evf: Use u64 values instead of casting them in TSO function
  i40e/i40evf: Factor out L4 header and checksum from L3 bits in TSO
    path
  i40e/i40evf: Consolidate all header changes into TSO function
  i40e/i40evf: Replace header pointers with unions of pointers in Tx
    checksum path
  i40e/i40evf: Add support for IPv4 encapsulated in IPv6
  i40e/i40evf: Handle IPv6 extension headers in checksum offload
  i40e/i40evf: Do not write to descriptor unless we complete
  i40e/i40evf: Add exception handling for Tx checksum
  i40e/i40evf: Clean-up Rx packet checksum handling
  i40e/i40evf: Enable support for SKB_GSO_UDP_TUNNEL_CSUM
  i40e: Fix ATR in relation to tunnels
  i40e: Do not drop support for IPv6 VXLAN or GENEVE tunnels
  i40e: Update feature flags to reflect newly enabled features
  i40evf: Update feature flags to reflect newly enabled features
  i40e: Add support for ATR w/ IPv6 extension headers

 drivers/net/ethernet/intel/i40e/i40e_main.c     |  28 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c     | 404 ++++++++++++------------
 drivers/net/ethernet/intel/i40e/i40e_txrx.h     |   2 -
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c   | 360 +++++++++++----------
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h   |   2 -
 drivers/net/ethernet/intel/i40evf/i40evf_main.c |  23 +-
 6 files changed, 433 insertions(+), 386 deletions(-)

-- 
2.5.0
