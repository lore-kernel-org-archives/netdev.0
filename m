From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH 3/3] ixgbe: Allow FDB entries access to more RAR
 filters
Date: Thu, 22 Oct 2015 16:26:42 -0700
Message-ID: <20151022232642.24612.46212.stgit@ahduyck-vm-fedora22>
References: <20151022232228.24612.81341.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
	jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:35372 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965705AbbJVX0o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 19:26:44 -0400
Received: by pasz6 with SMTP id z6so99263165pas.2
        for <netdev@vger.kernel.org>; Thu, 22 Oct 2015 16:26:43 -0700 (PDT)
In-Reply-To: <20151022232228.24612.81341.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change makes it so that we allow the PF to make use of all free RAR
entries for FDB use if needed.

Previously the code limited us to 16 unicast entries, however this was
shared between MACVLAN which wasn't limited and the FDB code which was.  So
instead of treating the FDB code as a second class citizen I have updated
it so that it has access to just as many entries as the MACVLAN filters.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index ba5c0d5b95b9..4befe637b9be 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -8206,7 +8206,10 @@ static int ixgbe_ndo_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 {
 	/* guarantee we can provide a unique filter for the unicast address */
 	if (is_unicast_ether_addr(addr) || is_link_local_ether_addr(addr)) {
-		if (IXGBE_MAX_PF_MACVLANS <= netdev_uc_count(dev))
+		struct ixgbe_adapter *adapter = netdev_priv(dev);
+		u16 pool = VMDQ_P(0);
+
+		if (netdev_uc_count(dev) >= ixgbe_available_rars(adapter, pool))
 			return -ENOMEM;
 	}
 
