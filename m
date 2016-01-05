From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCHv2 net-next 1/4] nfp: return error if MTU change fails
Date: Tue,  5 Jan 2016 11:57:28 +0000
Message-ID: <1451995051-21920-2-git-send-email-jakub.kicinski@netronome.com>
References: <1451995051-21920-1-git-send-email-jakub.kicinski@netronome.com>
Cc: simon.horman@netronome.com, rolf.neugebauer@netronome.com,
	Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:36726 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751616AbcAEL5i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2016 06:57:38 -0500
Received: by mail-wm0-f52.google.com with SMTP id l65so19892018wmf.1
        for <netdev@vger.kernel.org>; Tue, 05 Jan 2016 03:57:37 -0800 (PST)
In-Reply-To: <1451995051-21920-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When reopening device fails after MTU change, let the userspace
know.  MTU remains changed even though error is returned, this
is what all ethernet devices are doing.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Rolf Neugebauer <rolf.neugebauer@netronome.com>
---
Dave,

I know this is not what you asked for but, since we are using FW
commands to disable/enable RX, even if we allocate all required
resources before freeing old ones we still cannot guarantee that
the reenabling operation will not fail.  Should we refuse to do
MTU changes while the interface is running altogether?

---
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 43c618bafdb6..006d9600240f 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -1911,6 +1911,7 @@ static void nfp_net_set_rx_mode(struct net_device *netdev)
 static int nfp_net_change_mtu(struct net_device *netdev, int new_mtu)
 {
 	struct nfp_net *nn = netdev_priv(netdev);
+	int ret = 0;
 	u32 tmp;
 
 	nn_dbg(nn, "New MTU = %d\n", new_mtu);
@@ -1929,10 +1930,10 @@ static int nfp_net_change_mtu(struct net_device *netdev, int new_mtu)
 	/* restart if running */
 	if (netif_running(netdev)) {
 		nfp_net_netdev_close(netdev);
-		nfp_net_netdev_open(netdev);
+		ret = nfp_net_netdev_open(netdev);
 	}
 
-	return 0;
+	return ret;
 }
 
 static struct rtnl_link_stats64 *nfp_net_stat64(struct net_device *netdev,
-- 
1.9.1
