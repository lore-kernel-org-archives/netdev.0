From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: net: Enable TSO if supported by at least one device
Date: Mon, 8 Sep 2008 18:42:03 +1000
Message-ID: <20080908084203.GA14168@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:57462 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750971AbYIHImG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2008 04:42:06 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

net: Enable TSO if supported by at least one device

As it stands users of netdev_compute_features (e.g., bridges/bonding)
will only enable TSO if all consituent devices support it.  This
is unnecessarily pessimistic since even on devices that do not
support hardware TSO and SG, emulated TSO still performs to a par
with TSO off.

This patch enables TSO if at least on constituent device supports
it in hardware.

The direct beneficiaries will be virtualisation that uses bridging
since this means that TSO will always be enabled for communication
from the host to the guests.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/core/dev.c b/net/core/dev.c
index 60c51f7..abef86e 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4663,6 +4663,12 @@ int netdev_compute_features(unsigned long all, unsigned long one)
 		one |= NETIF_F_GSO_SOFTWARE;
 	one |= NETIF_F_GSO;
 
+	/*
+	 * If even one device supports a GSO protocol with software fallback,
+	 * enable it for all.
+	 */
+	all |= one & NETIF_F_GSO_SOFTWARE;
+
 	/* If even one device supports robust GSO, enable it for all. */
 	if (one & NETIF_F_GSO_ROBUST)
 		all |= NETIF_F_GSO_ROBUST;

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
