From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [2/2] [BRIDGE]: Add support for NETIF_F_HW_CSUM devices
Date: Tue, 13 Jun 2006 21:25:43 +1000
Message-ID: <20060613112543.GA13253@gondor.apana.org.au>
References: <20060613112511.GA13204@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="AhhlLboLdkugWU4S"
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:28679 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1750964AbWFMLZz
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jun 2006 07:25:55 -0400
To: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20060613112511.GA13204@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--AhhlLboLdkugWU4S
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

[BRIDGE]: Add support for NETIF_F_HW_CSUM devices

As it is the bridge will only ever declare NETIF_F_IP_CSUM even if all
its constituent devices support NETIF_F_HW_CSUM.  This patch fixes this
by supporting the first one out of NETIF_F_NO_CSUM, NETIF_F_HW_CSUM,
and NETIF_F_IP_CSUM that is supported by all constituent devices.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--AhhlLboLdkugWU4S
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="p2.patch"

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -145,9 +145,9 @@ static int br_set_tx_csum(struct net_dev
 	struct net_bridge *br = netdev_priv(dev);
 
 	if (data)
-		br->feature_mask |= NETIF_F_IP_CSUM;
+		br->feature_mask |= NETIF_F_NO_CSUM;
 	else
-		br->feature_mask &= ~NETIF_F_IP_CSUM;
+		br->feature_mask &= ~NETIF_F_ALL_CSUM;
 
 	br_features_recompute(br);
 	return 0;
@@ -185,5 +185,5 @@ void br_dev_setup(struct net_device *dev
 	dev->priv_flags = IFF_EBRIDGE;
 
  	dev->features = NETIF_F_SG | NETIF_F_FRAGLIST
- 		| NETIF_F_HIGHDMA | NETIF_F_TSO | NETIF_F_IP_CSUM;
+ 		| NETIF_F_HIGHDMA | NETIF_F_TSO | NETIF_F_NO_CSUM;
 }
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -377,11 +377,17 @@ void br_features_recompute(struct net_br
 	struct net_bridge_port *p;
 	unsigned long features, checksum;
 
-	features = br->feature_mask &~ NETIF_F_IP_CSUM;
-	checksum = br->feature_mask & NETIF_F_IP_CSUM;
+	checksum = br->feature_mask & NETIF_F_ALL_CSUM ? NETIF_F_NO_CSUM : 0;
+	features = br->feature_mask & ~NETIF_F_ALL_CSUM;
 
 	list_for_each_entry(p, &br->port_list, list) {
-		if (!(p->dev->features & NETIF_F_ALL_CSUM))
+		if (checksum & NETIF_F_NO_CSUM &&
+		    !(p->dev->features & NETIF_F_NO_CSUM))
+			checksum ^= NETIF_F_NO_CSUM | NETIF_F_HW_CSUM;
+		if (checksum & NETIF_F_HW_CSUM &&
+		    !(p->dev->features & NETIF_F_HW_CSUM))
+			checksum ^= NETIF_F_HW_CSUM | NETIF_F_IP_CSUM;
+		if (!(p->dev->features & NETIF_F_IP_CSUM))
 			checksum = 0;
 		features &= p->dev->features;
 	}

--AhhlLboLdkugWU4S--
