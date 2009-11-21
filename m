From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 06/23] e1000e: link reporting problems
Date: Sat, 21 Nov 2009 01:23:34 -0800
Message-ID: <20091121092333.5715.81064.stgit@localhost.localdomain>
References: <20091121092126.5715.41618.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta02.emeryville.ca.mail.comcast.net ([76.96.30.24]:37074 "EHLO
	QMTA02.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752349AbZKUJXo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Nov 2009 04:23:44 -0500
In-Reply-To: <20091121092126.5715.41618.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Copper links with WoL or management enabled (any condition which prevents
the phy from being powered down when the interface is taken down) were
always reporting link-up when the interface had been taken down. This
is because when the interface is taken down (ifconfig ethx down),
interrupts are disabled. With no interrupts, there is no LSC interrupt,
which is normally required to set "get_link_status", which instructs the
driver to query the device for link state. The fix is to force
get_link_status to true if the interface is not up.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/ethtool.c |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index 3d73f20..67e06fd 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -190,6 +190,17 @@ static int e1000_get_settings(struct net_device *netdev,
 static u32 e1000_get_link(struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
+	struct e1000_mac_info *mac = &adapter->hw.mac;
+
+	/*
+	 * If the link is not reported up to netdev, interrupts are disabled,
+	 * and so the physical link state may have changed since we last
+	 * looked. Set get_link_status to make sure that the true link
+	 * state is interrogated, rather than pulling a cached and possibly
+	 * stale link state from the driver.
+	 */
+	if (!netif_carrier_ok(netdev))
+		mac->get_link_status = 1;
 
 	return e1000_has_link(adapter);
 }

