From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH v5 net-next 13/15] nfp: convert .ndo_change_mtu() to prepare/commit paradigm
Date: Thu,  7 Apr 2016 19:39:46 +0100
Message-ID: <1460054388-471-14-git-send-email-jakub.kicinski@netronome.com>
References: <1460054388-471-1-git-send-email-jakub.kicinski@netronome.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f41.google.com ([209.85.192.41]:35166 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757388AbcDGSke (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 14:40:34 -0400
Received: by mail-qg0-f41.google.com with SMTP id f105so47335400qge.2
        for <netdev@vger.kernel.org>; Thu, 07 Apr 2016 11:40:34 -0700 (PDT)
In-Reply-To: <1460054388-471-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When changing MTU on running device first allocate new rings
and buffers and once it succeeds proceed with changing MTU.

Allocation of new rings is not really necessary for this
operation - it's done to keep the code simple and because
size of the extra ring memory is quite small compared to
the size of buffers.

Operation can still fail midway through if FW communication
times out.  In that case we retry with old MTU (rings).

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 108 +++++++++++++++++++--
 1 file changed, 102 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 03c60f755de0..e7c420fdcb0d 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -1506,6 +1506,64 @@ err_alloc:
 	return -ENOMEM;
 }
 
+static struct nfp_net_rx_ring *
+nfp_net_shadow_rx_rings_prepare(struct nfp_net *nn, unsigned int fl_bufsz)
+{
+	struct nfp_net_rx_ring *rings;
+	unsigned int r;
+
+	rings = kcalloc(nn->num_rx_rings, sizeof(*rings), GFP_KERNEL);
+	if (!rings)
+		return NULL;
+
+	for (r = 0; r < nn->num_rx_rings; r++) {
+		nfp_net_rx_ring_init(&rings[r], nn->rx_rings[r].r_vec, r);
+
+		if (nfp_net_rx_ring_alloc(&rings[r], fl_bufsz))
+			goto err_free_prev;
+
+		if (nfp_net_rx_ring_bufs_alloc(nn, &rings[r]))
+			goto err_free_ring;
+	}
+
+	return rings;
+
+err_free_prev:
+	while (r--) {
+		nfp_net_rx_ring_bufs_free(nn, &rings[r]);
+err_free_ring:
+		nfp_net_rx_ring_free(&rings[r]);
+	}
+	kfree(rings);
+	return NULL;
+}
+
+static struct nfp_net_rx_ring *
+nfp_net_shadow_rx_rings_swap(struct nfp_net *nn, struct nfp_net_rx_ring *rings)
+{
+	struct nfp_net_rx_ring *old = nn->rx_rings;
+	unsigned int r;
+
+	for (r = 0; r < nn->num_rx_rings; r++)
+		old[r].r_vec->rx_ring = &rings[r];
+
+	nn->rx_rings = rings;
+	return old;
+}
+
+static void
+nfp_net_shadow_rx_rings_free(struct nfp_net *nn, struct nfp_net_rx_ring *rings)
+{
+	unsigned int r;
+
+	for (r = 0; r < nn->num_r_vecs; r++) {
+		nfp_net_rx_ring_bufs_free(nn, &rings[r]);
+		nfp_net_rx_ring_free(&rings[r]);
+	}
+
+	kfree(rings);
+}
+
 static int
 nfp_net_prepare_vector(struct nfp_net *nn, struct nfp_net_r_vector *r_vec,
 		       int idx)
@@ -1984,23 +2042,61 @@ static void nfp_net_set_rx_mode(struct net_device *netdev)
 
 static int nfp_net_change_mtu(struct net_device *netdev, int new_mtu)
 {
+	unsigned int old_mtu, old_fl_bufsz, new_fl_bufsz;
 	struct nfp_net *nn = netdev_priv(netdev);
+	struct nfp_net_rx_ring *tmp_rings;
+	int err;
 
 	if (new_mtu < 68 || new_mtu > nn->max_mtu) {
 		nn_err(nn, "New MTU (%d) is not valid\n", new_mtu);
 		return -EINVAL;
 	}
 
+	old_mtu = netdev->mtu;
+	old_fl_bufsz = nn->fl_bufsz;
+	new_fl_bufsz = NFP_NET_MAX_PREPEND + ETH_HLEN + VLAN_HLEN * 2 + new_mtu;
+
+	if (!netif_running(netdev)) {
+		netdev->mtu = new_mtu;
+		nn->fl_bufsz = new_fl_bufsz;
+		return 0;
+	}
+
+	/* Prepare new rings */
+	tmp_rings = nfp_net_shadow_rx_rings_prepare(nn, new_fl_bufsz);
+	if (!tmp_rings)
+		return -ENOMEM;
+
+	/* Stop device, swap in new rings, try to start the firmware */
+	nfp_net_close_stack(nn);
+	nfp_net_clear_config_and_disable(nn);
+
+	tmp_rings = nfp_net_shadow_rx_rings_swap(nn, tmp_rings);
+
 	netdev->mtu = new_mtu;
-	nn->fl_bufsz = NFP_NET_MAX_PREPEND + ETH_HLEN + VLAN_HLEN * 2 + new_mtu;
+	nn->fl_bufsz = new_fl_bufsz;
+
+	err = nfp_net_set_config_and_enable(nn);
+	if (err) {
+		const int err_new = err;
+
+		/* Try with old configuration and old rings */
+		tmp_rings = nfp_net_shadow_rx_rings_swap(nn, tmp_rings);
+
+		netdev->mtu = old_mtu;
+		nn->fl_bufsz = old_fl_bufsz;
 
-	/* restart if running */
-	if (netif_running(netdev)) {
-		nfp_net_netdev_close(netdev);
-		nfp_net_netdev_open(netdev);
+		err = __nfp_net_set_config_and_enable(nn);
+		if (err)
+			nn_err(nn, "Can't restore MTU - FW communication failed (%d,%d)\n",
+			       err_new, err);
 	}
 
-	return 0;
+	nfp_net_shadow_rx_rings_free(nn, tmp_rings);
+
+	nfp_net_open_stack(nn);
+
+	return err;
 }
 
 static struct rtnl_link_stats64 *nfp_net_stat64(struct net_device *netdev,
-- 
1.9.1
