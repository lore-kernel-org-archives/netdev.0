From: Daniel Mack <daniel@caiaq.de>
Subject: [PATCH] drivers/net/arcnet/capmode.c: clean up code
Date: Mon, 31 May 2010 09:31:10 +0200
Message-ID: <1275291070-23062-1-git-send-email-daniel@caiaq.de>
References: <20100531.002429.71095599.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, Daniel Mack <daniel@caiaq.de>,
	Tejun Heo <tj@kernel.org>, Jiri Kosina <jkosina@suse.cz>,
	Christoph Lameter <cl@linux-foundation.org>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100531.002429.71095599.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 - shuffle around functions to get rid of forward declarations
 - fix some CodingStyle and indentation issues
 - last but not least, get rid of the following CONFIG_MODULE=3Dn warni=
ng:

	drivers/net/arcnet/capmode.c:52: warning: =E2=80=98capmode_proto=E2=80=
=99 defined but not used

Signed-off-by: Daniel Mack <daniel@caiaq.de>
Cc: Tejun Heo <tj@kernel.org>
Cc: Jiri Kosina <jkosina@suse.cz>
Cc: Christoph Lameter <cl@linux-foundation.org>
Cc: Joe Perches <joe@perches.com>
Cc: netdev@vger.kernel.org
---
 drivers/net/arcnet/capmode.c |  178 +++++++++++++++++++---------------=
--------
 1 files changed, 79 insertions(+), 99 deletions(-)

diff --git a/drivers/net/arcnet/capmode.c b/drivers/net/arcnet/capmode.=
c
index 355797f..e1810a3 100644
--- a/drivers/net/arcnet/capmode.c
+++ b/drivers/net/arcnet/capmode.c
@@ -37,69 +37,6 @@
=20
 #define VERSION "arcnet: cap mode (`c') encapsulation support loaded.\=
n"
=20
-
-static void rx(struct net_device *dev, int bufnum,
-	       struct archdr *pkthdr, int length);
-static int build_header(struct sk_buff *skb,
-			struct net_device *dev,
-			unsigned short type,
-			uint8_t daddr);
-static int prepare_tx(struct net_device *dev, struct archdr *pkt, int =
length,
-		      int bufnum);
-static int ack_tx(struct net_device *dev, int acked);
-
-
-static struct ArcProto capmode_proto =3D
-{
-	'r',
-	XMTU,
-	0,
-       	rx,
-	build_header,
-	prepare_tx,
-	NULL,
-	ack_tx
-};
-
-
-static void arcnet_cap_init(void)
-{
-	int count;
-
-	for (count =3D 1; count <=3D 8; count++)
-		if (arc_proto_map[count] =3D=3D arc_proto_default)
-			arc_proto_map[count] =3D &capmode_proto;
-
-	/* for cap mode, we only set the bcast proto if there's no better one=
 */
-	if (arc_bcast_proto =3D=3D arc_proto_default)
-		arc_bcast_proto =3D &capmode_proto;
-
-	arc_proto_default =3D &capmode_proto;
-	arc_raw_proto =3D &capmode_proto;
-}
-
-
-#ifdef MODULE
-
-static int __init capmode_module_init(void)
-{
-	printk(VERSION);
-	arcnet_cap_init();
-	return 0;
-}
-
-static void __exit capmode_module_exit(void)
-{
-	arcnet_unregister_proto(&capmode_proto);
-}
-module_init(capmode_module_init);
-module_exit(capmode_module_exit);
-
-MODULE_LICENSE("GPL");
-#endif				/* MODULE */
-
-
-
 /* packet receiver */
 static void rx(struct net_device *dev, int bufnum,
 	       struct archdr *pkthdr, int length)
@@ -231,65 +168,108 @@ static int prepare_tx(struct net_device *dev, st=
ruct archdr *pkt, int length,
 	BUGMSG(D_DURING, "prepare_tx: length=3D%d ofs=3D%d\n",
 	       length,ofs);
=20
-	// Copy the arcnet-header + the protocol byte down:
+	/* Copy the arcnet-header + the protocol byte down: */
 	lp->hw.copy_to_card(dev, bufnum, 0, hard, ARC_HDR_SIZE);
 	lp->hw.copy_to_card(dev, bufnum, ofs, &pkt->soft.cap.proto,
 			    sizeof(pkt->soft.cap.proto));
=20
-	// Skip the extra integer we have written into it as a cookie
-	// but write the rest of the message:
+	/* Skip the extra integer we have written into it as a cookie
+	   but write the rest of the message: */
 	lp->hw.copy_to_card(dev, bufnum, ofs+1,
 			    ((unsigned char*)&pkt->soft.cap.mes),length-1);
=20
 	lp->lastload_dest =3D hard->dest;
=20
-	return 1;		/* done */
+	return 1;	/* done */
 }
=20
-
 static int ack_tx(struct net_device *dev, int acked)
 {
-  struct arcnet_local *lp =3D netdev_priv(dev);
-  struct sk_buff *ackskb;
-  struct archdr *ackpkt;
-  int length=3Dsizeof(struct arc_cap);
+	struct arcnet_local *lp =3D netdev_priv(dev);
+	struct sk_buff *ackskb;
+	struct archdr *ackpkt;
+	int length=3Dsizeof(struct arc_cap);
=20
-  BUGMSG(D_DURING, "capmode: ack_tx: protocol: %x: result: %d\n",
-	 lp->outgoing.skb->protocol, acked);
+	BUGMSG(D_DURING, "capmode: ack_tx: protocol: %x: result: %d\n",
+		lp->outgoing.skb->protocol, acked);
=20
-  BUGLVL(D_SKB) arcnet_dump_skb(dev, lp->outgoing.skb, "ack_tx");
+	BUGLVL(D_SKB) arcnet_dump_skb(dev, lp->outgoing.skb, "ack_tx");
=20
-  /* Now alloc a skb to send back up through the layers: */
-  ackskb =3D alloc_skb(length + ARC_HDR_SIZE , GFP_ATOMIC);
-  if (ackskb =3D=3D NULL) {
-	  BUGMSG(D_NORMAL, "Memory squeeze, can't acknowledge.\n");
-	  goto free_outskb;
-  }
+	/* Now alloc a skb to send back up through the layers: */
+	ackskb =3D alloc_skb(length + ARC_HDR_SIZE , GFP_ATOMIC);
+	if (ackskb =3D=3D NULL) {
+		BUGMSG(D_NORMAL, "Memory squeeze, can't acknowledge.\n");
+		goto free_outskb;
+	}
=20
-  skb_put(ackskb, length + ARC_HDR_SIZE );
-  ackskb->dev =3D dev;
+	skb_put(ackskb, length + ARC_HDR_SIZE );
+	ackskb->dev =3D dev;
=20
-  skb_reset_mac_header(ackskb);
-  ackpkt =3D (struct archdr *)skb_mac_header(ackskb);
-  /* skb_pull(ackskb, ARC_HDR_SIZE); */
+	skb_reset_mac_header(ackskb);
+	ackpkt =3D (struct archdr *)skb_mac_header(ackskb);
+	/* skb_pull(ackskb, ARC_HDR_SIZE); */
=20
+	skb_copy_from_linear_data(lp->outgoing.skb, ackpkt,
+				  ARC_HDR_SIZE + sizeof(struct arc_cap));
+	ackpkt->soft.cap.proto =3D 0; /* using protocol 0 for acknowledge */
+	ackpkt->soft.cap.mes.ack=3Dacked;
=20
-  skb_copy_from_linear_data(lp->outgoing.skb, ackpkt,
-		ARC_HDR_SIZE + sizeof(struct arc_cap));
-  ackpkt->soft.cap.proto=3D0; /* using protocol 0 for acknowledge */
-  ackpkt->soft.cap.mes.ack=3Dacked;
+	BUGMSG(D_PROTO, "Ackknowledge for cap packet %x.\n",
+			*((int*)&ackpkt->soft.cap.cookie[0]));
=20
-  BUGMSG(D_PROTO, "Ackknowledge for cap packet %x.\n",
-	 *((int*)&ackpkt->soft.cap.cookie[0]));
+	ackskb->protocol =3D cpu_to_be16(ETH_P_ARCNET);
=20
-  ackskb->protocol =3D cpu_to_be16(ETH_P_ARCNET);
+	BUGLVL(D_SKB) arcnet_dump_skb(dev, ackskb, "ack_tx_recv");
+	netif_rx(ackskb);
=20
-  BUGLVL(D_SKB) arcnet_dump_skb(dev, ackskb, "ack_tx_recv");
-  netif_rx(ackskb);
+free_outskb:
+	dev_kfree_skb_irq(lp->outgoing.skb);
+	lp->outgoing.proto =3D NULL; /* We are always finished when in this p=
rotocol */
+
+	return 0;
+}
+
+static struct ArcProto capmode_proto =3D
+{
+	'r',
+	XMTU,
+	0,
+	rx,
+	build_header,
+	prepare_tx,
+	NULL,
+	ack_tx
+};
=20
- free_outskb:
-  dev_kfree_skb_irq(lp->outgoing.skb);
-  lp->outgoing.proto =3D NULL; /* We are always finished when in this =
protocol */
+static void arcnet_cap_init(void)
+{
+	int count;
=20
-  return 0;
+	for (count =3D 1; count <=3D 8; count++)
+		if (arc_proto_map[count] =3D=3D arc_proto_default)
+			arc_proto_map[count] =3D &capmode_proto;
+
+	/* for cap mode, we only set the bcast proto if there's no better one=
 */
+	if (arc_bcast_proto =3D=3D arc_proto_default)
+		arc_bcast_proto =3D &capmode_proto;
+
+	arc_proto_default =3D &capmode_proto;
+	arc_raw_proto =3D &capmode_proto;
 }
+
+static int __init capmode_module_init(void)
+{
+	printk(VERSION);
+	arcnet_cap_init();
+	return 0;
+}
+
+static void __exit capmode_module_exit(void)
+{
+	arcnet_unregister_proto(&capmode_proto);
+}
+module_init(capmode_module_init);
+module_exit(capmode_module_exit);
+
+MODULE_LICENSE("GPL");
+
--=20
1.7.1
