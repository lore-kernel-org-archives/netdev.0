From: Jacob Keller <jacob.e.keller@intel.com>
Subject: [PATCH v2 0/4] ethtool: correct {GS}CHANNELS and {GS}RXFH conflict
Date: Mon,  8 Feb 2016 16:05:02 -0800
Message-ID: <1454976306-23523-1-git-send-email-jacob.e.keller@intel.com>
Cc: Jakub Kicinski <moorray3@wp.pl>,
	David Miller <davem@davemloft.net>,
	Jacob Keller <jacob.e.keller@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:6948 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932487AbcBIAFK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Feb 2016 19:05:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series fixes up ethtool_set_channels operation which
allowed modifying the RXFH table indirectly by reducing the number of
queues below the current max queue used by the Rx flow table. Most
drivers incorrectly allowed this to destroy the Rx flow table and
would then start by reinitializing it to default settings. However,
drivers are not able to correctly handle the conflict since there was
no way to differentiate between the default settings and the user
requested explicit settings.

To fix this, implement a new netdev private flag which we use to
indicate whether the RXFH has been user configured. If someone has
a better alternative of how to store this information, let me know.
I am not sure that priv_flags is the best solution but I have not had
any better idea.

Secondly, we add a function which just calls the driver's get_rxfh
callback to determine the current indirection table. Loop through this
and we can determine the current highest queue that will be used by
RSS.

Now, modify ethtool_set_channels to add a check ensuring that if (a)
we have had rxfh configured by user, (b) we can get the maximum RSS
queue currently used, then we ensure that the newly requested Rx count
(or combined count) is at least as high as this maximum RSS queue. The
reasoning here is that we can always safely increase the number of
queues. If we decrease the queues we must ensure that the decrease
does not go lower than the highest in-use queue for the Rx flow table.

Drivers may still need to be patched if they currently overwrite the
Rx flow table during channel configuration. If the driver currently
always resets Rx flow table when increasing number of queues it must
be patched to only do this when netif_is_rxfh_configured returns
false.

The second patch simply adds a check to ensure that all provided
channel counts fit within driver defined maximums.

The third patch fixes fm10k to correctly reconfigure the RSS reta
table whenever it is still unconfigured. This means that the default
state will provide RSS to every queue. Once the user has configured
RXFH, then we should maintain it. In addition, since the case where we
must reconfigure the RSS table in this case should now no longer
occur, add a dev_err message to indicate the user that we did so.

I have also supplied an ethtool patch to enable setting the default Rx
flow indirection table. Without this, current ethtool does not support
sending an indir_size of 0, and thus does not correctly support
configuring back to the default.

Changes in v2:
* fixed compile error
* fixed incorrect comparison with max_rx_in_use
* adjusted looping over dev_size
* removed inline on function
* dropped patch about separating combined vs asymmetric channels
* verified behavior using fm10k driver

Jacob Keller (3):
  ethtool: correctly ensure {GS}CHANNELS doesn't conflict with GS{RXFH}
  ethtool: ensure channel counts are within bounds during SCHANNELS
  fm10k: don't reinitialize RSS flow table when RXFH configured

 drivers/net/ethernet/intel/fm10k/fm10k_main.c | 10 +++-
 include/linux/netdevice.h                     |  8 +++
 net/core/ethtool.c                            | 71 ++++++++++++++++++++++++++-
 3 files changed, 85 insertions(+), 4 deletions(-)

-- 
2.7.0.236.gda096a0.dirty
