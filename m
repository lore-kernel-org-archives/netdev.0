From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Bug 6936] BUG: warning at net/core/dev.c:1171/skb_checksum_help()
Date: Wed, 16 Aug 2006 11:29:00 +1000
Message-ID: <20060816012900.GA23430@gondor.apana.org.au>
References: <200608151829.k7FITxKM006438@fire-2.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:38418 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1750786AbWHPBaR
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 21:30:17 -0400
To: bugme-daemon@bugzilla.kernel.org
Content-Disposition: inline
In-Reply-To: <200608151829.k7FITxKM006438@fire-2.osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 15, 2006 at 11:29:59AM -0700, bugme-daemon@bugzilla.kernel.org wrote:
> http://bugzilla.kernel.org/show_bug.cgi?id=6936

It's actually a bug in the bridging code :)

[BRIDGE]: Disable SG/GSO if TX checksum is off

When the bridge recomputes features, it does not maintain the
constraint that SG/GSO must be off if TX checksum is off.
This patch adds that constraint.

On a completely unrelated note, I've also added TSO6 and TSO_ECN
feature bits if GSO is enabled on the underlying device through
the new NETIF_F_GSO_SOFTWARE macro.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 75f02d8..5d95da5 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -320,6 +320,9 @@ #define NETIF_F_GSO_ROBUST	(SKB_GSO_DODG
 #define NETIF_F_TSO_ECN		(SKB_GSO_TCP_ECN << NETIF_F_GSO_SHIFT)
 #define NETIF_F_TSO6		(SKB_GSO_TCPV6 << NETIF_F_GSO_SHIFT)
 
+	/* List of features with software fallbacks. */
+#define NETIF_F_GSO_SOFTWARE	(NETIF_F_TSO | NETIF_F_TSO_ECN | NETIF_F_TSO6)
+
 #define NETIF_F_GEN_CSUM	(NETIF_F_NO_CSUM | NETIF_F_HW_CSUM)
 #define NETIF_F_ALL_CSUM	(NETIF_F_IP_CSUM | NETIF_F_GEN_CSUM)
 
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index f55ef68..b1211d5 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -386,12 +386,17 @@ void br_features_recompute(struct net_br
 			checksum = 0;
 
 		if (feature & NETIF_F_GSO)
-			feature |= NETIF_F_TSO;
+			feature |= NETIF_F_GSO_SOFTWARE;
 		feature |= NETIF_F_GSO;
 
 		features &= feature;
 	}
 
+	if (!(checksum & NETIF_F_ALL_CSUM))
+		features &= ~NETIF_F_SG;
+	if (!(features & NETIF_F_SG))
+		features &= ~NETIF_F_GSO_MASK;
+
 	br->dev->features = features | checksum | NETIF_F_LLTX |
 			    NETIF_F_GSO_ROBUST;
 }
