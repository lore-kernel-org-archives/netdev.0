From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 03/13] nfp: rename ring allocation helpers
Date: Thu,  3 Nov 2016 13:58:48 +0000
Message-ID: <1478181538-20778-4-git-send-email-jakub.kicinski@netronome.com>
References: <1478181538-20778-1-git-send-email-jakub.kicinski@netronome.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:35080 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757745AbcKCN7X (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 09:59:23 -0400
Received: by mail-wm0-f41.google.com with SMTP id a197so207204647wmd.0
        for <netdev@vger.kernel.org>; Thu, 03 Nov 2016 06:59:22 -0700 (PDT)
In-Reply-To: <1478181538-20778-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Shadow" in ring helpers used to mean that the helper will allocate
rings without touching existing configuration, this was used for
reconfiguration while the device was running.  We will soon use
the same helpers for .ndo_open() path, so replace "shadow" with
"ring_set".

No functional changes.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 26 +++++++++++-----------
 1 file changed, 13 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index e58532d27c5b..b7b2851ebb6b 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -1573,7 +1573,7 @@ static int nfp_net_tx_ring_alloc(struct nfp_net_tx_ring *tx_ring, u32 cnt)
 }
 
 static struct nfp_net_tx_ring *
-nfp_net_shadow_tx_rings_prepare(struct nfp_net *nn, struct nfp_net_ring_set *s)
+nfp_net_tx_ring_set_prepare(struct nfp_net *nn, struct nfp_net_ring_set *s)
 {
 	struct nfp_net_tx_ring *rings;
 	unsigned int r;
@@ -1599,7 +1599,7 @@ static int nfp_net_tx_ring_alloc(struct nfp_net_tx_ring *tx_ring, u32 cnt)
 }
 
 static void
-nfp_net_shadow_tx_rings_swap(struct nfp_net *nn, struct nfp_net_ring_set *s)
+nfp_net_tx_ring_set_swap(struct nfp_net *nn, struct nfp_net_ring_set *s)
 {
 	struct nfp_net_tx_ring *rings = s->rings;
 	struct nfp_net_ring_set new = *s;
@@ -1616,7 +1616,7 @@ static int nfp_net_tx_ring_alloc(struct nfp_net_tx_ring *tx_ring, u32 cnt)
 }
 
 static void
-nfp_net_shadow_tx_rings_free(struct nfp_net *nn, struct nfp_net_ring_set *s)
+nfp_net_tx_ring_set_free(struct nfp_net *nn, struct nfp_net_ring_set *s)
 {
 	struct nfp_net_tx_ring *rings = s->rings;
 	unsigned int r;
@@ -1693,7 +1693,7 @@ static void nfp_net_rx_ring_free(struct nfp_net_rx_ring *rx_ring)
 }
 
 static struct nfp_net_rx_ring *
-nfp_net_shadow_rx_rings_prepare(struct nfp_net *nn, struct nfp_net_ring_set *s)
+nfp_net_rx_ring_set_prepare(struct nfp_net *nn, struct nfp_net_ring_set *s)
 {
 	unsigned int fl_bufsz =	nfp_net_calc_fl_bufsz(nn, s->mtu);
 	struct nfp_net_rx_ring *rings;
@@ -1726,7 +1726,7 @@ static void nfp_net_rx_ring_free(struct nfp_net_rx_ring *rx_ring)
 }
 
 static void
-nfp_net_shadow_rx_rings_swap(struct nfp_net *nn, struct nfp_net_ring_set *s)
+nfp_net_rx_ring_set_swap(struct nfp_net *nn, struct nfp_net_ring_set *s)
 {
 	struct nfp_net_rx_ring *rings = s->rings;
 	struct nfp_net_ring_set new = *s;
@@ -1746,7 +1746,7 @@ static void nfp_net_rx_ring_free(struct nfp_net_rx_ring *rx_ring)
 }
 
 static void
-nfp_net_shadow_rx_rings_free(struct nfp_net *nn, struct nfp_net_ring_set *s)
+nfp_net_rx_ring_set_free(struct nfp_net *nn, struct nfp_net_ring_set *s)
 {
 	struct nfp_net_rx_ring *rings = s->rings;
 	unsigned int r;
@@ -2268,9 +2268,9 @@ static void nfp_net_set_rx_mode(struct net_device *netdev)
 			 struct nfp_net_ring_set *tx)
 {
 	if (rx)
-		nfp_net_shadow_rx_rings_swap(nn, rx);
+		nfp_net_rx_ring_set_swap(nn, rx);
 	if (tx)
-		nfp_net_shadow_tx_rings_swap(nn, tx);
+		nfp_net_tx_ring_set_swap(nn, tx);
 
 	return __nfp_net_set_config_and_enable(nn);
 }
@@ -2299,11 +2299,11 @@ static void nfp_net_set_rx_mode(struct net_device *netdev)
 
 	/* Prepare new rings */
 	if (rx) {
-		if (!nfp_net_shadow_rx_rings_prepare(nn, rx))
+		if (!nfp_net_rx_ring_set_prepare(nn, rx))
 			return -ENOMEM;
 	}
 	if (tx) {
-		if (!nfp_net_shadow_tx_rings_prepare(nn, tx)) {
+		if (!nfp_net_tx_ring_set_prepare(nn, tx)) {
 			err = -ENOMEM;
 			goto err_free_rx;
 		}
@@ -2327,9 +2327,9 @@ static void nfp_net_set_rx_mode(struct net_device *netdev)
 	}
 
 	if (rx)
-		nfp_net_shadow_rx_rings_free(nn, rx);
+		nfp_net_rx_ring_set_free(nn, rx);
 	if (tx)
-		nfp_net_shadow_tx_rings_free(nn, tx);
+		nfp_net_tx_ring_set_free(nn, tx);
 
 	nfp_net_open_stack(nn);
 
@@ -2337,7 +2337,7 @@ static void nfp_net_set_rx_mode(struct net_device *netdev)
 
 err_free_rx:
 	if (rx)
-		nfp_net_shadow_rx_rings_free(nn, rx);
+		nfp_net_rx_ring_set_free(nn, rx);
 	return err;
 }
 
-- 
1.9.1
