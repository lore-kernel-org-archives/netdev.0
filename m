From: Chris Wright <chrisw@sous-sol.org>
Subject: [patch 067/100] sfc: Match calls to netif_napi_add() and netif_napi_del()
Date: Thu, 23 Apr 2009 00:21:27 -0700
Message-ID: <20090423072804.211647624@sous-sol.org>
References: <20090423072020.428683652@sous-sol.org>
Cc: Justin Forbes <jmforbes@linuxtx.org>,
	Zwane Mwaikambo <zwane@arm.linux.org.uk>,
	"Theodore Ts'o" <tytso@mit.edu>,
	Randy Dunlap <rdunlap@xenotime.net>,
	Dave Jones <davej@redhat.com>,
	Chuck Wolber <chuckw@quantumlinux.com>,
	Chris Wedgwood <reviews@ml.cw.f00f.org>,
	Michael Krufky <mkrufky@linuxtv.org>,
	Chuck Ebbert <cebbert@redhat.com>,
	Domenico Andreoli <cavokz@gmail.com>, Willy Tarreau <w@1wt.eu>,
	Rodrigo Rubira Branco <rbranco@la.checkpoint.com>,
	Jake Edge <jake@lwn.net>, Eugene Teo <eteo@redhat.com>,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	alan@lxorguk.ukuu.org.uk,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: linux-kernel@vger.kernel.org, stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sous-sol.org ([216.99.217.87]:50839 "EHLO x200.localdomain"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757167AbZDWHdH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Apr 2009 03:33:07 -0400
Content-Disposition: inline; filename=sfc-match-calls-to-netif_napi_add-and-netif_napi_del.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-stable review patch.  If anyone has any objections, please let us know.
---------------------

From: Ben Hutchings <bhutchings@solarflare.com>

upstream commit: 718cff1eec595ce6ab0635b8160a51ee37d9268d

sfc could call netif_napi_add() multiple times for the same
napi_struct, corrupting the list of napi_structs for the associated
device and leading to a busy-loop on device removal.  Move the call to
netif_napi_add() and add a call to netif_napi_del() in the obvious
places.

[bhutchings: backport to 2.6.29]
Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
Signed-off-by: Chris Wright <chrisw@sous-sol.org>
---
We didn't spot this earlier because only netpoll would look at the list,
but this changed with the addition of GRO in 2.6.29.  I have no excuse
for not catching it during the .29 release cycle though.

Ben.

 drivers/net/sfc/efx.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -424,10 +424,6 @@ static void efx_start_channel(struct efx
 
 	EFX_LOG(channel->efx, "starting chan %d\n", channel->channel);
 
-	if (!(channel->efx->net_dev->flags & IFF_UP))
-		netif_napi_add(channel->napi_dev, &channel->napi_str,
-			       efx_poll, napi_weight);
-
 	/* The interrupt handler for this channel may set work_pending
 	 * as soon as we enable it.  Make sure it's cleared before
 	 * then.  Similarly, make sure it sees the enabled flag set. */
@@ -1273,6 +1269,8 @@ static int efx_init_napi(struct efx_nic 
 
 	efx_for_each_channel(channel, efx) {
 		channel->napi_dev = efx->net_dev;
+		netif_napi_add(channel->napi_dev, &channel->napi_str,
+			       efx_poll, napi_weight);
 		rc = efx_lro_init(&channel->lro_mgr, efx);
 		if (rc)
 			goto err;
@@ -1289,6 +1287,8 @@ static void efx_fini_napi(struct efx_nic
 
 	efx_for_each_channel(channel, efx) {
 		efx_lro_fini(&channel->lro_mgr);
+		if (channel->napi_dev)
+			netif_napi_del(&channel->napi_str);
 		channel->napi_dev = NULL;
 	}
 }

