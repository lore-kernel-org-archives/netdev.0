From: =?utf-8?Q?Rog=C3=A9rio?= Brito <rbrito@ime.usp.br>
Subject: [PATCH] powerpc: convert mace to netdev_ops
Date: Sun, 3 May 2009 08:48:20 -0300
Message-ID: <20090503114820.GA14926@ime.usp.br>
References: <20090426155708.GA23159@ime.usp.br> <20090426.230648.254087966.davem@davemloft.net> <20090427121633.GA29608@ime.usp.br> <20090427.054258.16622932.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, paulus@samba.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.flash.net.br ([201.46.240.48]:34624 "EHLO
	smtp.gru.flash.tv.br" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755886AbZECLtL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 May 2009 07:49:11 -0400
Received: from localhost (localhost [127.0.0.1])
	by smtp.gru.flash.tv.br (Postfix) with ESMTP id 4E4BC1E66DE
	for <netdev@vger.kernel.org>; Sun,  3 May 2009 08:48:55 -0300 (BRT)
Received: from smtp.gru.flash.tv.br ([127.0.0.1])
	by localhost (smtp.gru.flash.tv.br [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 2rj-IxzKVQ-S for <netdev@vger.kernel.org>;
	Sun,  3 May 2009 08:48:41 -0300 (BRT)
Received: from chagas.nectar.ath.cx (unknown [187.22.248.170])
	by smtp.gru.flash.tv.br (Postfix) with ESMTPA id 7D6111E6802
	for <netdev@vger.kernel.org>; Sun,  3 May 2009 08:48:36 -0300 (BRT)
Content-Disposition: inline
In-Reply-To: <20090427.054258.16622932.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Dave.

On Apr 27 2009, David Miller wrote:
> You can fix the mace_set_timeout() function arguments by having
> a helper function that simply wraps around it and provides the
> second expection of argument types.

I hope that this version is a slightly better fix to convert mace to
netdev_ops.

This is against this morning's net-2.6 tree.


Signed-off-by: Rog=C3=A9rio Brito <rbrito@ime.usp.br>
---
diff --git a/drivers/net/mace.c b/drivers/net/mace.c
index feebbd9..03a179d 100644
--- a/drivers/net/mace.c
+++ b/drivers/net/mace.c
@@ -89,6 +89,19 @@ static inline void dbdma_reset(volatile struct dbdma=
_regs __iomem *dma);
 static inline void mace_clean_rings(struct mace_data *mp);
 static void __mace_set_address(struct net_device *dev, void *addr);
=20
+/* Conversion to netdev_ops. */
+static const struct net_device_ops mace_netdev_ops =3D {
+	.ndo_open		=3D mace_open,
+	.ndo_stop		=3D mace_close,
+	.ndo_start_xmit		=3D mace_xmit_start,
+	.ndo_tx_timeout		=3D mace_tx_timeout,
+	.ndo_set_multicast_list	=3D mace_set_multicast,
+	.ndo_set_mac_address	=3D mace_set_address,
+	.ndo_change_mtu		=3D eth_change_mtu,
+	.ndo_set_mac_address	=3D eth_mac_addr,
+	.ndo_validate_addr	=3D eth_validate_addr,
+};
+
 /*
  * If we can't get a skbuff when we need it, we use this area for DMA.
  */
@@ -207,11 +220,7 @@ static int __devinit mace_probe(struct macio_dev *=
mdev, const struct of_device_i
 		}
 	}
=20
-	dev->open =3D mace_open;
-	dev->stop =3D mace_close;
-	dev->hard_start_xmit =3D mace_xmit_start;
-	dev->set_multicast_list =3D mace_set_multicast;
-	dev->set_mac_address =3D mace_set_address;
+	dev->netdev_ops =3D &mace_netdev_ops;
=20
 	/*
 	 * Most of what is below could be moved to mace_open()
@@ -798,6 +807,13 @@ static irqreturn_t mace_interrupt(int irq, void *d=
ev_id)
     return IRQ_HANDLED;
 }
=20
+/*
+ * In the following, the parameter "data" is treated like a pointer,
+ * which is probably OK for 32 bit arches, but not for 64.
+ *
+ * (Are mace's found on any newer machines??) -- rbrito
+ *
+ */
 static void mace_tx_timeout(unsigned long data)
 {
     struct net_device *dev =3D (struct net_device *) data;


--=20
Rog=C3=A9rio Brito : rbrito@{mackenzie,ime.usp}.br : GPG key 1024D/7C2C=
AEB8
http://www.ime.usp.br/~rbrito : http://meusite.mackenzie.com.br/rbrito
Projects: algorithms.berlios.de : lame.sf.net : vrms.alioth.debian.org
