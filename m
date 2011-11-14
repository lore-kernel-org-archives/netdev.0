From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] Don't allow sharing of tx skbs on xen-netfront
Date: Mon, 14 Nov 2011 14:22:24 -0500
Message-ID: <1321298544-16434-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	xen-devel@lists.xensource.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:55707 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753733Ab1KNTWi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 14:22:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It was pointed out to me recently that the xen-netfront driver can't safely
support shared skbs on transmit, since, while it doesn't maintain skb state
directly, it does pass a pointer to the skb to the hypervisor via a list, and
the hypervisor may expect the contents of the skb to remain stable.  Clearing
the IFF_TX_SKB_SHARING flag after the call to alloc_etherdev to make it safe.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: "David S. Miller" <davem@davemloft.net>
CC: Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>
CC: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
CC: xen-devel@lists.xensource.com
---
 drivers/net/xen-netfront.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 226faab..fb1077b 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -1252,6 +1252,12 @@ static struct net_device * __devinit xennet_create_dev(struct xenbus_device *dev
 		return ERR_PTR(-ENOMEM);
 	}
 
+	/*
+	 * Since frames remain on a queue after a return from xennet_start_xmit,
+	 * we can't support tx shared skbs
+	 */
+	netdev->priv_flags &= ~IFF_TX_SKB_SHARING;
+
 	np                   = netdev_priv(netdev);
 	np->xbdev            = dev;
 
-- 
1.7.6.4
