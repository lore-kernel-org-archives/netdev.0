From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 2/3] ixgbe: In SR-IOV mode insert delay before bring
	the adapter up
Date: Wed, 24 Mar 2010 12:36:08 -0700
Message-ID: <20100324193608.6078.61157.stgit@localhost.localdomain>
References: <20100324193515.6078.27035.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Greg Rose <gregory.v.rose@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta10.emeryville.ca.mail.comcast.net ([76.96.30.17]:36612 "EHLO
	qmta10.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751203Ab0CXTmS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Mar 2010 15:42:18 -0400
In-Reply-To: <20100324193515.6078.27035.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

VFs running in guest VMs do not respond in as timely a manner to
PF indication it is going down as they do when running in the host
domain.  If the adapter is in SR-IOV mode insert a two second delay
to guarantee that all VFs have had time to respond to the PF reset.
In any case resetting the PF while VFs are active should be
discouraged but if it must be done then there will be a two
second delay to help synchronize resets among the PF and all the
VFs.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 90565d8..2f8c348 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3036,6 +3036,14 @@ void ixgbe_reinit_locked(struct ixgbe_adapter *adapter)
 	while (test_and_set_bit(__IXGBE_RESETTING, &adapter->state))
 		msleep(1);
 	ixgbe_down(adapter);
+	/*
+	 * If SR-IOV enabled then wait a bit before bringing the adapter
+	 * back up to give the VFs time to respond to the reset.  The
+	 * two second wait is based upon the watchdog timer cycle in
+	 * the VF driver.
+	 */
+	if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED)
+		msleep(2000);
 	ixgbe_up(adapter);
 	clear_bit(__IXGBE_RESETTING, &adapter->state);
 }

