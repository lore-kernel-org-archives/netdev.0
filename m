From: Arvid Brodin <arvid.brodin@alten.se>
Subject: [PATCH net-next 09/10] net/hsr: Better frame dispatch
Date: Fri, 4 Jul 2014 23:41:03 +0200
Message-ID: <53B71F6F.7050504@alten.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spam1.webland.se ([91.207.112.90]:55924 "EHLO spam1.webland.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757326AbaGDVkk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jul 2014 17:40:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes the separate paths for frames coming from the outsid=
e, and
frames sent from the HSR device, and instead makes all frames go throug=
h
hsr_forward_skb() in hsr_forward.c. This greatly improves code readabil=
ity and
also opens up the possibility for future support of the HSR Interlink d=
evice
that is the basis for HSR RedBoxes and HSR QuadBoxes, as well as VLAN
compatibility.

Other improvements:
* A reduction in the number of times an skb is copied on machines witho=
ut
  HAVE_EFFICIENT_UNALIGNED_ACCESS, which improves throughput somewhat.
* Headers are now created using the standard eth_header(), and using th=
e
  standard hard_header_len.
* Each HSR slave now gets its own private skb, so slave-specific fields=
 can be
  correctly set.

Signed-off-by: Arvid Brodin <arvid.brodin@alten.se>
---
 net/hsr/Makefile       |   4 +-
 net/hsr/hsr_device.c   | 170 ++++-------------------
 net/hsr/hsr_forward.c  | 368 +++++++++++++++++++++++++++++++++++++++++=
++++++++
 net/hsr/hsr_forward.h  |  20 +++
 net/hsr/hsr_framereg.c | 318 +++++++++++++++++++++--------------------=
-
 net/hsr/hsr_framereg.h |  25 ++--
 net/hsr/hsr_main.c     |  20 ---
 net/hsr/hsr_main.h     |  16 ++-
 net/hsr/hsr_netlink.c  |   2 +-
 net/hsr/hsr_slave.c    | 287 +++++++-------------------------------
 net/hsr/hsr_slave.h    |  12 +-
 11 files changed, 656 insertions(+), 586 deletions(-)
 create mode 100644 net/hsr/hsr_forward.c
 create mode 100644 net/hsr/hsr_forward.h

diff --git a/net/hsr/Makefile b/net/hsr/Makefile
index b533b24..9ae972a 100644
--- a/net/hsr/Makefile
+++ b/net/hsr/Makefile
@@ -4,5 +4,5 @@
=20
 obj-$(CONFIG_HSR)	+=3D hsr.o
=20
-hsr-y			:=3D hsr_main.o hsr_framereg.o hsr_device.o hsr_netlink.o \
-			   hsr_slave.o
+hsr-y			:=3D hsr_main.o hsr_framereg.o hsr_device.o \
+			   hsr_netlink.o hsr_slave.o hsr_forward.o
diff --git a/net/hsr/hsr_device.c b/net/hsr/hsr_device.c
index c2ae549..a138d75 100644
--- a/net/hsr/hsr_device.c
+++ b/net/hsr/hsr_device.c
@@ -21,6 +21,7 @@
 #include "hsr_slave.h"
 #include "hsr_framereg.h"
 #include "hsr_main.h"
+#include "hsr_forward.h"
=20
=20
 static bool is_admin_up(struct net_device *dev)
@@ -231,141 +232,21 @@ static netdev_features_t hsr_fix_features(struct=
 net_device *dev,
 }
=20
=20
-static void hsr_fill_tag(struct hsr_ethhdr *hsr_ethhdr, struct hsr_pri=
v *hsr)
-{
-	unsigned long irqflags;
-
-	/* IEC 62439-1:2010, p 48, says the 4-bit "path" field can take value=
s
-	 * between 0001-1001 ("ring identifier", for regular HSR frames),
-	 * or 1111 ("HSR management", supervision frames). Unfortunately, the
-	 * spec writers forgot to explain what a "ring identifier" is, or
-	 * how it is used. So we just set this to 0001 for regular frames,
-	 * and 1111 for supervision frames.
-	 */
-	set_hsr_tag_path(&hsr_ethhdr->hsr_tag, 0x1);
-
-	/* IEC 62439-1:2010, p 12: "The link service data unit in an Ethernet
-	 * frame is the content of the frame located between the Length/Type
-	 * field and the Frame Check Sequence."
-	 *
-	 * IEC 62439-3, p 48, specifies the "original LPDU" to include the
-	 * original "LT" field (what "LT" means is not explained anywhere as
-	 * far as I can see - perhaps "Length/Type"?). So LSDU_size might
-	 * equal original length + 2.
-	 *   Also, the fact that this field is not used anywhere (might be us=
ed
-	 * by a RedBox connecting HSR and PRP nets?) means I cannot test its
-	 * correctness. Instead of guessing, I set this to 0 here, to make an=
y
-	 * problems immediately apparent. Anyone using this driver with PRP/H=
SR
-	 * RedBoxes might need to fix this...
-	 */
-	set_hsr_tag_LSDU_size(&hsr_ethhdr->hsr_tag, 0);
-
-	spin_lock_irqsave(&hsr->seqnr_lock, irqflags);
-	hsr_ethhdr->hsr_tag.sequence_nr =3D htons(hsr->sequence_nr);
-	hsr->sequence_nr++;
-	spin_unlock_irqrestore(&hsr->seqnr_lock, irqflags);
-
-	hsr_ethhdr->hsr_tag.encap_proto =3D hsr_ethhdr->ethhdr.h_proto;
-
-	hsr_ethhdr->ethhdr.h_proto =3D htons(ETH_P_PRP);
-}
-
-static int slave_xmit(struct hsr_priv *hsr, struct sk_buff *skb,
-		      enum hsr_port_type type)
-{
-	struct hsr_port *port;
-	struct hsr_ethhdr *hsr_ethhdr;
-
-	hsr_ethhdr =3D (struct hsr_ethhdr *) skb->data;
-
-	rcu_read_lock();
-	port =3D hsr_port_get_hsr(hsr, type);
-	if (!port) {
-		rcu_read_unlock();
-		return NET_XMIT_DROP;
-	}
-	skb->dev =3D port->dev;
-
-	hsr_addr_subst_dest(port->hsr, &hsr_ethhdr->ethhdr, port);
-	rcu_read_unlock();
-
-	/* Address substitution (IEC62439-3 pp 26, 50): replace mac
-	 * address of outgoing frame with that of the outgoing slave's.
-	 */
-	ether_addr_copy(hsr_ethhdr->ethhdr.h_source, skb->dev->dev_addr);
-
-	return dev_queue_xmit(skb);
-}
-
 static int hsr_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct hsr_priv *hsr;
+	struct hsr_priv *hsr =3D netdev_priv(dev);
 	struct hsr_port *master;
-	struct hsr_ethhdr *hsr_ethhdr;
-	struct sk_buff *skb2;
-	int res1, res2;
-
-	hsr =3D netdev_priv(dev);
-	hsr_ethhdr =3D (struct hsr_ethhdr *) skb->data;
-
-	if ((skb->protocol !=3D htons(ETH_P_PRP)) ||
-	    (hsr_ethhdr->ethhdr.h_proto !=3D htons(ETH_P_PRP))) {
-		hsr_fill_tag(hsr_ethhdr, hsr);
-		skb->protocol =3D htons(ETH_P_PRP);
-	}
=20
-	skb2 =3D pskb_copy(skb, GFP_ATOMIC);
-
-	res1 =3D slave_xmit(hsr, skb, HSR_PT_SLAVE_A);
-	if (skb2)
-		res2 =3D slave_xmit(hsr, skb2, HSR_PT_SLAVE_B);
-	else
-		res2 =3D NET_XMIT_DROP;
-
-	rcu_read_lock();
 	master =3D hsr_port_get_hsr(hsr, HSR_PT_MASTER);
-	if (likely(res1 =3D=3D NET_XMIT_SUCCESS || res1 =3D=3D NET_XMIT_CN ||
-		   res2 =3D=3D NET_XMIT_SUCCESS || res2 =3D=3D NET_XMIT_CN)) {
-		master->dev->stats.tx_packets++;
-		master->dev->stats.tx_bytes +=3D skb->len;
-	} else {
-		master->dev->stats.tx_dropped++;
-	}
-	rcu_read_unlock();
+	skb->dev =3D master->dev;
+	hsr_forward_skb(skb, master);
=20
 	return NETDEV_TX_OK;
 }
=20
=20
-static int hsr_header_create(struct sk_buff *skb, struct net_device *d=
ev,
-			     unsigned short type, const void *daddr,
-			     const void *saddr, unsigned int len)
-{
-	int res;
-
-	/* Make room for the HSR tag now. We will fill it in later (in
-	 * hsr_dev_xmit)
-	 */
-	if (skb_headroom(skb) < HSR_HLEN + ETH_HLEN)
-		return -ENOBUFS;
-	skb_push(skb, HSR_HLEN);
-
-	/* To allow VLAN/HSR combos we should probably use
-	 * res =3D dev_hard_header(skb, dev, type, daddr, saddr, len + HSR_HL=
EN);
-	 * here instead. It would require other changes too, though - e.g.
-	 * separate headers for each slave etc...
-	 */
-	res =3D eth_header(skb, dev, type, daddr, saddr, len + HSR_HLEN);
-	if (res <=3D 0)
-		return res;
-	skb_reset_mac_header(skb);
-
-	return res + HSR_HLEN;
-}
-
-
 static const struct header_ops hsr_header_ops =3D {
-	.create	 =3D hsr_header_create,
+	.create	 =3D eth_header,
 	.parse	 =3D eth_header_parse,
 };
=20
@@ -382,19 +263,13 @@ static int hsr_pad(int size)
 	return min_size;
 }
=20
-static void send_hsr_supervision_frame(struct net_device *hsr_dev, u8 =
type)
+static void send_hsr_supervision_frame(struct hsr_port *master, u8 typ=
e)
 {
-	struct hsr_priv *hsr;
-	struct hsr_port *master;
 	struct sk_buff *skb;
 	int hlen, tlen;
 	struct hsr_sup_tag *hsr_stag;
 	struct hsr_sup_payload *hsr_sp;
 	unsigned long irqflags;
-	int res;
-
-	hsr =3D netdev_priv(hsr_dev);
-	master =3D hsr_port_get_hsr(hsr, HSR_PT_MASTER);
=20
 	hlen =3D LL_RESERVED_SPACE(master->dev);
 	tlen =3D master->dev->needed_tailroom;
@@ -410,33 +285,30 @@ static void send_hsr_supervision_frame(struct net=
_device *hsr_dev, u8 type)
 	skb->protocol =3D htons(ETH_P_PRP);
 	skb->priority =3D TC_PRIO_CONTROL;
=20
-	res =3D dev_hard_header(skb, skb->dev, ETH_P_PRP,
-			      hsr->sup_multicast_addr,
-			      skb->dev->dev_addr, skb->len);
-	if (res <=3D 0)
+	if (dev_hard_header(skb, skb->dev, ETH_P_PRP,
+			    master->hsr->sup_multicast_addr,
+			    skb->dev->dev_addr, skb->len) <=3D 0)
 		goto out;
+	skb_reset_mac_header(skb);
=20
-	skb_pull(skb, sizeof(struct ethhdr));
-	hsr_stag =3D (typeof(hsr_stag)) skb->data;
+	hsr_stag =3D (typeof(hsr_stag)) skb_put(skb, sizeof(*hsr_stag));
=20
 	set_hsr_stag_path(hsr_stag, 0xf);
 	set_hsr_stag_HSR_Ver(hsr_stag, 0);
=20
-	spin_lock_irqsave(&hsr->seqnr_lock, irqflags);
-	hsr_stag->sequence_nr =3D htons(hsr->sequence_nr);
-	hsr->sequence_nr++;
-	spin_unlock_irqrestore(&hsr->seqnr_lock, irqflags);
+	spin_lock_irqsave(&master->hsr->seqnr_lock, irqflags);
+	hsr_stag->sequence_nr =3D htons(master->hsr->sequence_nr);
+	master->hsr->sequence_nr++;
+	spin_unlock_irqrestore(&master->hsr->seqnr_lock, irqflags);
=20
 	hsr_stag->HSR_TLV_Type =3D type;
 	hsr_stag->HSR_TLV_Length =3D 12;
=20
-	skb_push(skb, sizeof(struct ethhdr));
-
 	/* Payload: MacAddressA */
 	hsr_sp =3D (typeof(hsr_sp)) skb_put(skb, sizeof(*hsr_sp));
 	ether_addr_copy(hsr_sp->MacAddressA, master->dev->dev_addr);
=20
-	dev_queue_xmit(skb);
+	hsr_forward_skb(skb, master);
 	return;
=20
 out:
@@ -453,13 +325,15 @@ static void hsr_announce(unsigned long data)
 	struct hsr_port *master;
=20
 	hsr =3D (struct hsr_priv *) data;
+
+	rcu_read_lock();
 	master =3D hsr_port_get_hsr(hsr, HSR_PT_MASTER);
=20
 	if (hsr->announce_count < 3) {
-		send_hsr_supervision_frame(master->dev, HSR_TLV_ANNOUNCE);
+		send_hsr_supervision_frame(master, HSR_TLV_ANNOUNCE);
 		hsr->announce_count++;
 	} else {
-		send_hsr_supervision_frame(master->dev, HSR_TLV_LIFE_CHECK);
+		send_hsr_supervision_frame(master, HSR_TLV_LIFE_CHECK);
 	}
=20
 	if (hsr->announce_count < 3)
@@ -471,6 +345,8 @@ static void hsr_announce(unsigned long data)
=20
 	if (is_admin_up(master->dev))
 		add_timer(&hsr->announce_timer);
+
+	rcu_read_unlock();
 }
=20
=20
@@ -570,7 +446,7 @@ int hsr_dev_finalize(struct net_device *hsr_dev, st=
ruct net_device *slave[2],
=20
 	spin_lock_init(&hsr->seqnr_lock);
 	/* Overflow soon to find bugs easier: */
-	hsr->sequence_nr =3D USHRT_MAX - 1024;
+	hsr->sequence_nr =3D HSR_SEQNR_START;
=20
 	init_timer(&hsr->announce_timer);
 	hsr->announce_timer.function =3D hsr_announce;
diff --git a/net/hsr/hsr_forward.c b/net/hsr/hsr_forward.c
new file mode 100644
index 0000000..7871ed6
--- /dev/null
+++ b/net/hsr/hsr_forward.c
@@ -0,0 +1,368 @@
+/* Copyright 2011-2014 Autronica Fire and Security AS
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of the GNU General Public License as published by t=
he Free
+ * Software Foundation; either version 2 of the License, or (at your o=
ption)
+ * any later version.
+ *
+ * Author(s):
+ *	2011-2014 Arvid Brodin, arvid.brodin@alten.se
+ */
+
+#include "hsr_forward.h"
+#include <linux/types.h>
+#include <linux/skbuff.h>
+#include <linux/etherdevice.h>
+#include <linux/if_vlan.h>
+#include "hsr_main.h"
+#include "hsr_framereg.h"
+
+
+struct hsr_node;
+
+struct hsr_frame_info {
+	struct sk_buff *skb_std;
+	struct sk_buff *skb_hsr;
+	struct hsr_port *port_rcv;
+	struct hsr_node *node_src;
+	u16 sequence_nr;
+	bool is_supervision;
+	bool is_vlan;
+	bool is_local_dest;
+	bool is_local_exclusive;
+};
+
+
+/* The uses I can see for these HSR supervision frames are:
+ * 1) Use the frames that are sent after node initialization ("HSR_TLV=
=2EType =3D
+ *    22") to reset any sequence_nr counters belonging to that node. U=
seful if
+ *    the other node's counter has been reset for some reason.
+ *    --
+ *    Or not - resetting the counter and bridging the frame would crea=
te a
+ *    loop, unfortunately.
+ *
+ * 2) Use the LifeCheck frames to detect ring breaks. I.e. if no LifeC=
heck
+ *    frame is received from a particular node, we know something is w=
rong.
+ *    We just register these (as with normal frames) and throw them aw=
ay.
+ *
+ * 3) Allow different MAC addresses for the two slave interfaces, usin=
g the
+ *    MacAddressA field.
+ */
+static bool is_supervision_frame(struct hsr_priv *hsr, struct sk_buff =
*skb)
+{
+	struct hsr_ethhdr_sp *hdr;
+
+	WARN_ON_ONCE(!skb_mac_header_was_set(skb));
+	hdr =3D (struct hsr_ethhdr_sp *) skb_mac_header(skb);
+
+	if (!ether_addr_equal(hdr->ethhdr.h_dest,
+			      hsr->sup_multicast_addr))
+		return false;
+
+	if (get_hsr_stag_path(&hdr->hsr_sup) !=3D 0x0f)
+		return false;
+	if ((hdr->hsr_sup.HSR_TLV_Type !=3D HSR_TLV_ANNOUNCE) &&
+	    (hdr->hsr_sup.HSR_TLV_Type !=3D HSR_TLV_LIFE_CHECK))
+		return false;
+	if (hdr->hsr_sup.HSR_TLV_Length !=3D 12)
+		return false;
+
+	return true;
+}
+
+
+static struct sk_buff *create_stripped_skb(struct sk_buff *skb_in,
+					   struct hsr_frame_info *frame)
+{
+	struct sk_buff *skb;
+	int copylen;
+	unsigned char *dst, *src;
+
+	skb_pull(skb_in, HSR_HLEN);
+	skb =3D __pskb_copy(skb_in, skb_headroom(skb_in) - HSR_HLEN, GFP_ATOM=
IC);
+	skb_push(skb_in, HSR_HLEN);
+	if (skb =3D=3D NULL)
+		return NULL;
+
+	skb_reset_mac_header(skb);
+
+	if (skb->ip_summed =3D=3D CHECKSUM_PARTIAL)
+		skb->csum_start -=3D HSR_HLEN;
+
+	copylen =3D 2*ETH_ALEN;
+	if (frame->is_vlan)
+		copylen +=3D VLAN_HLEN;
+	src =3D skb_mac_header(skb_in);
+	dst =3D skb_mac_header(skb);
+	memcpy(dst, src, copylen);
+
+	skb->protocol =3D eth_hdr(skb)->h_proto;
+	return skb;
+}
+
+static struct sk_buff *frame_get_stripped_skb(struct hsr_frame_info *f=
rame,
+					      struct hsr_port *port)
+{
+	if (!frame->skb_std)
+		frame->skb_std =3D create_stripped_skb(frame->skb_hsr, frame);
+	return skb_clone(frame->skb_std, GFP_ATOMIC);
+}
+
+
+static void hsr_fill_tag(struct sk_buff *skb, struct hsr_frame_info *f=
rame,
+			 struct hsr_port *port)
+{
+	struct hsr_ethhdr *hsr_ethhdr;
+	int lane_id;
+	int lsdu_size;
+
+	if (port->type =3D=3D HSR_PT_SLAVE_A)
+		lane_id =3D 0;
+	else
+		lane_id =3D 1;
+
+	lsdu_size =3D skb->len - 14;
+	if (frame->is_vlan)
+		lsdu_size -=3D 4;
+
+	hsr_ethhdr =3D (struct hsr_ethhdr *) skb_mac_header(skb);
+
+	set_hsr_tag_path(&hsr_ethhdr->hsr_tag, lane_id);
+	set_hsr_tag_LSDU_size(&hsr_ethhdr->hsr_tag, lsdu_size);
+	hsr_ethhdr->hsr_tag.sequence_nr =3D htons(frame->sequence_nr);
+	hsr_ethhdr->hsr_tag.encap_proto =3D hsr_ethhdr->ethhdr.h_proto;
+	hsr_ethhdr->ethhdr.h_proto =3D htons(ETH_P_PRP);
+}
+
+static struct sk_buff *create_tagged_skb(struct sk_buff *skb_o,
+					 struct hsr_frame_info *frame,
+					 struct hsr_port *port)
+{
+	int movelen;
+	unsigned char *dst, *src;
+	struct sk_buff *skb;
+
+	/* Create the new skb with enough headroom to fit the HSR tag */
+	skb =3D __pskb_copy(skb_o, skb_headroom(skb_o) + HSR_HLEN, GFP_ATOMIC=
);
+	if (skb =3D=3D NULL)
+		return NULL;
+	skb_reset_mac_header(skb);
+
+	if (skb->ip_summed =3D=3D CHECKSUM_PARTIAL)
+		skb->csum_start +=3D HSR_HLEN;
+
+	movelen =3D ETH_HLEN;
+	if (frame->is_vlan)
+		movelen +=3D VLAN_HLEN;
+
+	src =3D skb_mac_header(skb);
+	dst =3D skb_push(skb, HSR_HLEN);
+	memmove(dst, src, movelen);
+	skb_reset_mac_header(skb);
+
+	hsr_fill_tag(skb, frame, port);
+
+	return skb;
+}
+
+/* If the original frame was an HSR tagged frame, just clone it to be =
sent
+ * unchanged. Otherwise, create a private frame especially tagged for =
'port'.
+ */
+static struct sk_buff *frame_get_tagged_skb(struct hsr_frame_info *fra=
me,
+					    struct hsr_port *port)
+{
+	if (frame->skb_hsr)
+		return skb_clone(frame->skb_hsr, GFP_ATOMIC);
+
+	if ((port->type !=3D HSR_PT_SLAVE_A) && (port->type !=3D HSR_PT_SLAVE=
_B)) {
+		WARN_ONCE(1, "HSR: Bug: trying to create a tagged frame for a non-ri=
ng port");
+		return NULL;
+	}
+
+	return create_tagged_skb(frame->skb_std, frame, port);
+}
+
+
+static void hsr_deliver_master(struct sk_buff *skb, struct net_device =
*dev,
+			       struct hsr_node *node_src)
+{
+	bool was_multicast_frame;
+	int res;
+
+	was_multicast_frame =3D (skb->pkt_type =3D=3D PACKET_MULTICAST);
+	hsr_addr_subst_source(node_src, skb);
+	skb_pull(skb, ETH_HLEN);
+	res =3D netif_rx(skb);
+	if (res =3D=3D NET_RX_DROP) {
+		dev->stats.rx_dropped++;
+	} else {
+		dev->stats.rx_packets++;
+		dev->stats.rx_bytes +=3D skb->len;
+		if (was_multicast_frame)
+			dev->stats.multicast++;
+	}
+}
+
+static int hsr_xmit(struct sk_buff *skb, struct hsr_port *port,
+		    struct hsr_frame_info *frame)
+{
+	if (frame->port_rcv->type =3D=3D HSR_PT_MASTER) {
+		hsr_addr_subst_dest(frame->node_src, skb, port);
+
+		/* Address substitution (IEC62439-3 pp 26, 50): replace mac
+		 * address of outgoing frame with that of the outgoing slave's.
+		 */
+		ether_addr_copy(eth_hdr(skb)->h_source, port->dev->dev_addr);
+	}
+	return dev_queue_xmit(skb);
+}
+
+
+/* Forward the frame through all devices except:
+ * - Back through the receiving device
+ * - If it's a HSR frame: through a device where it has passed before
+ * - To the local HSR master only if the frame is directly addressed t=
o it, or
+ *   a non-supervision multicast or broadcast frame.
+ *
+ * HSR slave devices should insert a HSR tag into the frame, or forwar=
d the
+ * frame unchanged if it's already tagged. Interlink devices should st=
rip HSR
+ * tags if they're of the non-HSR type (but only after duplicate disca=
rd). The
+ * master device always strips HSR tags.
+ */
+static void hsr_forward_do(struct hsr_frame_info *frame)
+{
+	struct hsr_port *port;
+	struct sk_buff *skb;
+
+	hsr_for_each_port(frame->port_rcv->hsr, port) {
+		/* Don't send frame back the way it came */
+		if (port =3D=3D frame->port_rcv)
+			continue;
+
+		/* Don't deliver locally unless we should */
+		if ((port->type =3D=3D HSR_PT_MASTER) && !frame->is_local_dest)
+			continue;
+
+		/* Deliver frames directly addressed to us to master only */
+		if ((port->type !=3D HSR_PT_MASTER) && frame->is_local_exclusive)
+			continue;
+
+		/* Don't send frame over port where it has been sent before */
+		if (hsr_register_frame_out(port, frame->node_src,
+					   frame->sequence_nr))
+			continue;
+
+		if (frame->is_supervision && (port->type =3D=3D HSR_PT_MASTER)) {
+			hsr_handle_sup_frame(frame->skb_hsr,
+					     frame->node_src,
+					     frame->port_rcv);
+			continue;
+		}
+
+		if (port->type !=3D HSR_PT_MASTER)
+			skb =3D frame_get_tagged_skb(frame, port);
+		else
+			skb =3D frame_get_stripped_skb(frame, port);
+		if (skb =3D=3D NULL) {
+			/* FIXME: Record the dropped frame? */
+			continue;
+		}
+
+		skb->dev =3D port->dev;
+		if (port->type =3D=3D HSR_PT_MASTER)
+			hsr_deliver_master(skb, port->dev, frame->node_src);
+		else
+			hsr_xmit(skb, port, frame);
+	}
+}
+
+
+static void check_local_dest(struct hsr_priv *hsr, struct sk_buff *skb=
,
+			     struct hsr_frame_info *frame)
+{
+	struct net_device *master_dev;
+
+	master_dev =3D hsr_port_get_hsr(hsr, HSR_PT_MASTER)->dev;
+
+	if (hsr_addr_is_self(hsr, eth_hdr(skb)->h_dest)) {
+		frame->is_local_exclusive =3D true;
+		skb->pkt_type =3D PACKET_HOST;
+	} else {
+		frame->is_local_exclusive =3D false;
+	}
+
+	if ((skb->pkt_type =3D=3D PACKET_HOST) ||
+	    (skb->pkt_type =3D=3D PACKET_MULTICAST) ||
+	    (skb->pkt_type =3D=3D PACKET_BROADCAST)) {
+		frame->is_local_dest =3D true;
+	} else {
+		frame->is_local_dest =3D false;
+	}
+}
+
+
+static int hsr_fill_frame_info(struct hsr_frame_info *frame,
+			       struct sk_buff *skb, struct hsr_port *port)
+{
+	struct ethhdr *ethhdr;
+	unsigned long irqflags;
+
+	frame->is_supervision =3D is_supervision_frame(port->hsr, skb);
+	frame->node_src =3D hsr_get_node(&port->hsr->node_db, skb,
+				       frame->is_supervision);
+	if (frame->node_src =3D=3D NULL)
+		return -1; /* Unknown node and !is_supervision, or no mem */
+
+	ethhdr =3D (struct ethhdr *) skb_mac_header(skb);
+	frame->is_vlan =3D false;
+	if (ethhdr->h_proto =3D=3D htons(ETH_P_8021Q)) {
+		frame->is_vlan =3D true;
+		/* FIXME: */
+		WARN_ONCE(1, "HSR: VLAN not yet supported");
+	}
+	if (ethhdr->h_proto =3D=3D htons(ETH_P_PRP)) {
+		frame->skb_std =3D NULL;
+		frame->skb_hsr =3D skb;
+		frame->sequence_nr =3D hsr_get_skb_sequence_nr(skb);
+	} else {
+		frame->skb_std =3D skb;
+		frame->skb_hsr =3D NULL;
+		/* Sequence nr for the master node */
+		spin_lock_irqsave(&port->hsr->seqnr_lock, irqflags);
+		frame->sequence_nr =3D port->hsr->sequence_nr;
+		port->hsr->sequence_nr++;
+		spin_unlock_irqrestore(&port->hsr->seqnr_lock, irqflags);
+	}
+
+	frame->port_rcv =3D port;
+	check_local_dest(port->hsr, skb, frame);
+
+	return 0;
+}
+
+/* Must be called holding rcu read lock (because of the port parameter=
) */
+void hsr_forward_skb(struct sk_buff *skb, struct hsr_port *port)
+{
+	struct hsr_frame_info frame;
+
+	if (skb_mac_header(skb) !=3D skb->data) {
+		WARN_ONCE(1, "%s:%d: Malformed frame (port_src %s)\n",
+			  __FILE__, __LINE__, port->dev->name);
+		goto out_drop;
+	}
+
+	if (hsr_fill_frame_info(&frame, skb, port) < 0)
+		goto out_drop;
+	hsr_register_frame_in(frame.node_src, port, frame.sequence_nr);
+	hsr_forward_do(&frame);
+
+	if (frame.skb_hsr !=3D NULL)
+		kfree_skb(frame.skb_hsr);
+	if (frame.skb_std !=3D NULL)
+		kfree_skb(frame.skb_std);
+	return;
+
+out_drop:
+	port->dev->stats.tx_dropped++;
+	kfree_skb(skb);
+}
diff --git a/net/hsr/hsr_forward.h b/net/hsr/hsr_forward.h
new file mode 100644
index 0000000..5c5bc4b
--- /dev/null
+++ b/net/hsr/hsr_forward.h
@@ -0,0 +1,20 @@
+/* Copyright 2011-2014 Autronica Fire and Security AS
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of the GNU General Public License as published by t=
he Free
+ * Software Foundation; either version 2 of the License, or (at your o=
ption)
+ * any later version.
+ *
+ * Author(s):
+ *	2011-2014 Arvid Brodin, arvid.brodin@alten.se
+ */
+
+#ifndef __HSR_FORWARD_H
+#define __HSR_FORWARD_H
+
+#include <linux/netdevice.h>
+#include "hsr_main.h"
+
+void hsr_forward_skb(struct sk_buff *skb, struct hsr_port *port);
+
+#endif /* __HSR_FORWARD_H */
diff --git a/net/hsr/hsr_framereg.c b/net/hsr/hsr_framereg.c
index c9b78c5..c709c13 100644
--- a/net/hsr/hsr_framereg.c
+++ b/net/hsr/hsr_framereg.c
@@ -35,58 +35,56 @@ struct hsr_node {
 	struct rcu_head		rcu_head;
 };
=20
-/*	TODO: use hash lists for mac addresses (linux/jhash.h)?    */
=20
+/*	TODO: use hash lists for mac addresses (linux/jhash.h)?    */
=20
=20
-/* Search for mac entry. Caller must hold rcu read lock.
+/* seq_nr_after(a, b) - return true if a is after (higher in sequence =
than) b,
+ * false otherwise.
  */
-static struct hsr_node *find_node_by_AddrA(struct list_head *node_db,
-					   const unsigned char addr[ETH_ALEN])
+static bool seq_nr_after(u16 a, u16 b)
 {
-	struct hsr_node *node;
-
-	list_for_each_entry_rcu(node, node_db, mac_list) {
-		if (ether_addr_equal(node->MacAddressA, addr))
-			return node;
-	}
+	/* Remove inconsistency where
+	 * seq_nr_after(a, b) =3D=3D seq_nr_before(a, b)
+	 */
+	if ((int) b - a =3D=3D 32768)
+		return false;
=20
-	return NULL;
+	return (((s16) (b - a)) < 0);
 }
+#define seq_nr_before(a, b)		seq_nr_after((b), (a))
+#define seq_nr_after_or_eq(a, b)	(!seq_nr_before((a), (b)))
+#define seq_nr_before_or_eq(a, b)	(!seq_nr_after((a), (b)))
=20
=20
-/* Search for mac entry. Caller must hold rcu read lock.
- */
-static struct hsr_node *find_node_by_AddrB(struct list_head *node_db,
-					   const unsigned char addr[ETH_ALEN])
+bool hsr_addr_is_self(struct hsr_priv *hsr, unsigned char *addr)
 {
 	struct hsr_node *node;
=20
-	list_for_each_entry_rcu(node, node_db, mac_list) {
-		if (ether_addr_equal(node->MacAddressB, addr))
-			return node;
+	node =3D list_first_or_null_rcu(&hsr->self_node_db, struct hsr_node,
+				      mac_list);
+	if (!node) {
+		WARN_ONCE(1, "HSR: No self node\n");
+		return false;
 	}
=20
-	return NULL;
-}
+	if (ether_addr_equal(addr, node->MacAddressA))
+		return true;
+	if (ether_addr_equal(addr, node->MacAddressB))
+		return true;
=20
+	return false;
+}
=20
 /* Search for mac entry. Caller must hold rcu read lock.
  */
-struct hsr_node *hsr_find_node(struct list_head *node_db, struct sk_bu=
ff *skb)
+static struct hsr_node *find_node_by_AddrA(struct list_head *node_db,
+					   const unsigned char addr[ETH_ALEN])
 {
 	struct hsr_node *node;
-	struct ethhdr *ethhdr;
-
-	if (!skb_mac_header_was_set(skb))
-		return NULL;
-
-	ethhdr =3D (struct ethhdr *) skb_mac_header(skb);
=20
 	list_for_each_entry_rcu(node, node_db, mac_list) {
-		if (ether_addr_equal(node->MacAddressA, ethhdr->h_source))
-			return node;
-		if (ether_addr_equal(node->MacAddressB, ethhdr->h_source))
+		if (ether_addr_equal(node->MacAddressA, addr))
 			return node;
 	}
=20
@@ -127,90 +125,22 @@ int hsr_create_self_node(struct list_head *self_n=
ode_db,
 }
=20
=20
-/* Add/merge node to the database of nodes. 'skb' must contain an HSR
- * supervision frame.
- * - If the supervision header's MacAddressA field is not yet in the d=
atabase,
- * this frame is from an hitherto unknown node - add it to the databas=
e.
- * - If the sender's MAC address is not the same as its MacAddressA ad=
dress,
- * the node is using PICS_SUBS (address substitution). Record the send=
er's
- * address as the node's MacAddressB.
- *
- * This function needs to work even if the sender node has changed one=
 of its
- * slaves' MAC addresses. In this case, there are four different cases=
 described
- * by (Addr-changed, received-from) pairs as follows. Note that changi=
ng the
- * SlaveA address is equal to changing the node's own address:
- *
- * - (AddrB, SlaveB): The new AddrB will be recorded by PICS_SUBS code=
 since
- *		      node =3D=3D NULL.
- * - (AddrB, SlaveA): Will work as usual (the AddrB change won't be de=
tected
- *		      from this frame).
- *
- * - (AddrA, SlaveB): The old node will be found. We need to detect th=
is and
- *		      remove the node.
- * - (AddrA, SlaveA): A new node will be registered (non-PICS_SUBS at =
first).
- *		      The old one will be pruned after HSR_NODE_FORGET_TIME.
- *
- * We also need to detect if the sender's SlaveA and SlaveB cables hav=
e been
- * swapped.
+/* Allocate an hsr_node and add it to node_db. 'addr' is the node's Ad=
dressA;
+ * seq_out is used to initialize filtering of outgoing duplicate frame=
s
+ * originating from the newly added node.
  */
-struct hsr_node *hsr_merge_node(struct hsr_node *node, struct sk_buff =
*skb,
-				struct hsr_port *port)
+struct hsr_node *hsr_add_node(struct list_head *node_db, unsigned char=
 addr[],
+			      u16 seq_out)
 {
-	struct hsr_priv *hsr;
-	struct hsr_sup_payload *hsr_sp;
-	struct hsr_ethhdr_sp *hsr_ethsup;
-	int i;
+	struct hsr_node *node;
 	unsigned long now;
-
-	hsr_ethsup =3D (struct hsr_ethhdr_sp *) skb_mac_header(skb);
-	hsr_sp =3D (struct hsr_sup_payload *) skb->data;
-	hsr =3D port->hsr;
-
-	if (node && !ether_addr_equal(node->MacAddressA, hsr_sp->MacAddressA)=
) {
-		/* Node has changed its AddrA, frame was received from SlaveB */
-		list_del_rcu(&node->mac_list);
-		kfree_rcu(node, rcu_head);
-		node =3D NULL;
-	}
-
-	if (node && (port->type =3D=3D node->AddrB_port) &&
-	    !ether_addr_equal(node->MacAddressB, hsr_ethsup->ethhdr.h_source)=
) {
-		/* Cables have been swapped */
-		list_del_rcu(&node->mac_list);
-		kfree_rcu(node, rcu_head);
-		node =3D NULL;
-	}
-
-	if (node && (port->type !=3D node->AddrB_port) &&
-	    (node->AddrB_port !=3D HSR_PT_NONE) &&
-	    !ether_addr_equal(node->MacAddressA, hsr_ethsup->ethhdr.h_source)=
) {
-		/* Cables have been swapped */
-		list_del_rcu(&node->mac_list);
-		kfree_rcu(node, rcu_head);
-		node =3D NULL;
-	}
-
-	if (node)
-		return node;
-
-	node =3D find_node_by_AddrA(&hsr->node_db, hsr_sp->MacAddressA);
-	if (node) {
-		/* Node is known, but frame was received from an unknown
-		 * address. Node is PICS_SUBS capable; merge its AddrB.
-		 */
-		ether_addr_copy(node->MacAddressB, hsr_ethsup->ethhdr.h_source);
-		node->AddrB_port =3D port->type;
-		return node;
-	}
+	int i;
=20
 	node =3D kzalloc(sizeof(*node), GFP_ATOMIC);
 	if (!node)
 		return NULL;
=20
-	ether_addr_copy(node->MacAddressA, hsr_sp->MacAddressA);
-	ether_addr_copy(node->MacAddressB, hsr_ethsup->ethhdr.h_source);
-	if (!ether_addr_equal(hsr_sp->MacAddressA, hsr_ethsup->ethhdr.h_sourc=
e))
-		node->AddrB_port =3D port->type;
+	ether_addr_copy(node->MacAddressA, addr);
=20
 	/* We are only interested in time diffs here, so use current jiffies
 	 * as initialization. (0 could trigger an spurious ring error warning=
).
@@ -219,41 +149,120 @@ struct hsr_node *hsr_merge_node(struct hsr_node =
*node, struct sk_buff *skb,
 	for (i =3D 0; i < HSR_PT_PORTS; i++)
 		node->time_in[i] =3D now;
 	for (i =3D 0; i < HSR_PT_PORTS; i++)
-		node->seq_out[i] =3D ntohs(hsr_ethsup->hsr_sup.sequence_nr) - 1;
+		node->seq_out[i] =3D seq_out;
=20
-	list_add_tail_rcu(&node->mac_list, &hsr->node_db);
+	list_add_tail_rcu(&node->mac_list, node_db);
=20
 	return node;
 }
=20
+/* Get the hsr_node from which 'skb' was sent.
+ */
+struct hsr_node *hsr_get_node(struct list_head *node_db, struct sk_buf=
f *skb,
+			      bool is_sup)
+{
+	struct hsr_node *node;
+	struct ethhdr *ethhdr;
+	u16 seq_out;
+
+	if (!skb_mac_header_was_set(skb))
+		return NULL;
+
+	ethhdr =3D (struct ethhdr *) skb_mac_header(skb);
+
+	list_for_each_entry_rcu(node, node_db, mac_list) {
+		if (ether_addr_equal(node->MacAddressA, ethhdr->h_source))
+			return node;
+		if (ether_addr_equal(node->MacAddressB, ethhdr->h_source))
+			return node;
+	}
+
+	if (!is_sup)
+		return NULL; /* Only supervision frame may create node entry */
+
+	if (ethhdr->h_proto =3D=3D htons(ETH_P_PRP)) {
+		/* Use the existing sequence_nr from the tag as starting point
+		 * for filtering duplicate frames.
+		 */
+		seq_out =3D hsr_get_skb_sequence_nr(skb) - 1;
+	} else {
+		WARN_ONCE(1, "%s: Non-HSR frame\n", __func__);
+		seq_out =3D 0;
+	}
+
+	return hsr_add_node(node_db, ethhdr->h_source, seq_out);
+}
+
+/* Use the Supervision frame's info about an eventual MacAddressB for =
merging
+ * nodes that has previously had their MacAddressB registered as a sep=
arate
+ * node.
+ */
+void hsr_handle_sup_frame(struct sk_buff *skb, struct hsr_node *node_c=
urr,
+			  struct hsr_port *port_rcv)
+{
+	struct hsr_node *node_real;
+	struct hsr_sup_payload *hsr_sp;
+	struct list_head *node_db;
+	int i;
+
+	skb_pull(skb, sizeof(struct hsr_ethhdr_sp));
+	hsr_sp =3D (struct hsr_sup_payload *) skb->data;
+
+	if (ether_addr_equal(eth_hdr(skb)->h_source, hsr_sp->MacAddressA))
+		/* Not sent from MacAddressB of a PICS_SUBS capable node */
+		goto done;
+
+	/* Merge node_curr (registered on MacAddressB) into node_real */
+	node_db =3D &port_rcv->hsr->node_db;
+	node_real =3D find_node_by_AddrA(node_db, hsr_sp->MacAddressA);
+	if (!node_real)
+		/* No frame received from AddrA of this node yet */
+		node_real =3D hsr_add_node(node_db, hsr_sp->MacAddressA,
+					 HSR_SEQNR_START - 1);
+	if (!node_real)
+		goto done; /* No mem */
+	if (node_real =3D=3D node_curr)
+		/* Node has already been merged */
+		goto done;
+
+	ether_addr_copy(node_real->MacAddressB, eth_hdr(skb)->h_source);
+	for (i =3D 0; i < HSR_PT_PORTS; i++) {
+		if (!node_curr->time_in_stale[i] &&
+		    time_after(node_curr->time_in[i], node_real->time_in[i])) {
+			node_real->time_in[i] =3D node_curr->time_in[i];
+			node_real->time_in_stale[i] =3D node_curr->time_in_stale[i];
+		}
+		if (seq_nr_after(node_curr->seq_out[i], node_real->seq_out[i]))
+			node_real->seq_out[i] =3D node_curr->seq_out[i];
+	}
+	node_real->AddrB_port =3D port_rcv->type;
+
+	list_del_rcu(&node_curr->mac_list);
+	kfree_rcu(node_curr, rcu_head);
+
+done:
+	skb_push(skb, sizeof(struct hsr_ethhdr_sp));
+}
+
=20
 /* 'skb' is a frame meant for this host, that is to be passed to upper=
 layers.
  *
- * If the frame was sent by a node's B interface, replace the sender
+ * If the frame was sent by a node's B interface, replace the source
  * address with that node's "official" address (MacAddressA) so that u=
pper
  * layers recognize where it came from.
  */
-void hsr_addr_subst_source(struct hsr_priv *hsr, struct sk_buff *skb)
+void hsr_addr_subst_source(struct hsr_node *node, struct sk_buff *skb)
 {
-	struct ethhdr *ethhdr;
-	struct hsr_node *node;
-
 	if (!skb_mac_header_was_set(skb)) {
 		WARN_ONCE(1, "%s: Mac header not set\n", __func__);
 		return;
 	}
-	ethhdr =3D (struct ethhdr *) skb_mac_header(skb);
=20
-	rcu_read_lock();
-	node =3D find_node_by_AddrB(&hsr->node_db, ethhdr->h_source);
-	if (node)
-		ether_addr_copy(ethhdr->h_source, node->MacAddressA);
-	rcu_read_unlock();
+	memcpy(&eth_hdr(skb)->h_source, node->MacAddressA, ETH_ALEN);
 }
=20
-
 /* 'skb' is a frame meant for another host.
- * 'hsr_dev_idx' is the HSR index of the outgoing device
+ * 'port' is the outgoing interface
  *
  * Substitute the target (dest) MAC address if necessary, so the it ma=
tches the
  * recipient interface MAC address, regardless of whether that is the
@@ -261,44 +270,49 @@ void hsr_addr_subst_source(struct hsr_priv *hsr, =
struct sk_buff *skb)
  * This is needed to keep the packets flowing through switches that le=
arn on
  * which "side" the different interfaces are.
  */
-void hsr_addr_subst_dest(struct hsr_priv *hsr, struct ethhdr *ethhdr,
+void hsr_addr_subst_dest(struct hsr_node *node_src, struct sk_buff *sk=
b,
 			 struct hsr_port *port)
 {
-	struct hsr_node *node;
+	struct hsr_node *node_dst;
=20
-	rcu_read_lock();
-	node =3D find_node_by_AddrA(&hsr->node_db, ethhdr->h_dest);
-	if (node && (node->AddrB_port =3D=3D port->type))
-		ether_addr_copy(ethhdr->h_dest, node->MacAddressB);
-	rcu_read_unlock();
-}
+	if (!skb_mac_header_was_set(skb)) {
+		WARN_ONCE(1, "%s: Mac header not set\n", __func__);
+		return;
+	}
=20
+	if (!is_unicast_ether_addr(eth_hdr(skb)->h_dest))
+		return;
=20
-/* seq_nr_after(a, b) - return true if a is after (higher in sequence =
than) b,
- * false otherwise.
- */
-static bool seq_nr_after(u16 a, u16 b)
-{
-	/* Remove inconsistency where
-	 * seq_nr_after(a, b) =3D=3D seq_nr_before(a, b)
-	 */
-	if ((int) b - a =3D=3D 32768)
-		return false;
+	node_dst =3D find_node_by_AddrA(&port->hsr->node_db, eth_hdr(skb)->h_=
dest);
+	if (!node_dst) {
+		WARN_ONCE(1, "%s: Unknown node\n", __func__);
+		return;
+	}
+	if (port->type !=3D node_dst->AddrB_port)
+		return;
+	if (!node_dst->MacAddressB) {
+		WARN_ONCE(1, "%s: No MacAddressB\n", __func__);
+		return;
+	}
=20
-	return (((s16) (b - a)) < 0);
+	ether_addr_copy(eth_hdr(skb)->h_dest, node_dst->MacAddressB);
 }
-#define seq_nr_before(a, b)		seq_nr_after((b), (a))
-#define seq_nr_after_or_eq(a, b)	(!seq_nr_before((a), (b)))
-#define seq_nr_before_or_eq(a, b)	(!seq_nr_after((a), (b)))
=20
=20
-void hsr_register_frame_in(struct hsr_node *node, struct hsr_port *por=
t)
+void hsr_register_frame_in(struct hsr_node *node, struct hsr_port *por=
t,
+			   u16 sequence_nr)
 {
+	/* Don't register incoming frames without a valid sequence number. Th=
is
+	 * ensures entries of restarted nodes gets pruned so that they can
+	 * re-register and resume communications.
+	 */
+	if (seq_nr_before(sequence_nr, node->seq_out[port->type]))
+		return;
+
 	node->time_in[port->type] =3D jiffies;
 	node->time_in_stale[port->type] =3D false;
 }
=20
-
 /* 'skb' is a HSR Ethernet frame (with a HSR tag inserted), with a val=
id
  * ethhdr->h_source address and skb->mac_header set.
  *
@@ -307,19 +321,9 @@ void hsr_register_frame_in(struct hsr_node *node, =
struct hsr_port *port)
  *	 0 otherwise, or
  *	 negative error code on error
  */
-int hsr_register_frame_out(struct hsr_node *node, struct hsr_port *por=
t,
-			   struct sk_buff *skb)
+int hsr_register_frame_out(struct hsr_port *port, struct hsr_node *nod=
e,
+			   u16 sequence_nr)
 {
-	struct hsr_ethhdr *hsr_ethhdr;
-	u16 sequence_nr;
-
-	if (!skb_mac_header_was_set(skb)) {
-		WARN_ONCE(1, "%s: Mac header not set\n", __func__);
-		return -EINVAL;
-	}
-	hsr_ethhdr =3D (struct hsr_ethhdr *) skb_mac_header(skb);
-
-	sequence_nr =3D ntohs(hsr_ethhdr->hsr_tag.sequence_nr);
 	if (seq_nr_before_or_eq(sequence_nr, node->seq_out[port->type]))
 		return 1;
=20
diff --git a/net/hsr/hsr_framereg.h b/net/hsr/hsr_framereg.h
index c87f36f..438b40f 100644
--- a/net/hsr/hsr_framereg.h
+++ b/net/hsr/hsr_framereg.h
@@ -16,19 +16,22 @@
=20
 struct hsr_node;
=20
-struct hsr_node *hsr_find_node(struct list_head *node_db, struct sk_bu=
ff *skb);
-
-struct hsr_node *hsr_merge_node(struct hsr_node *node, struct sk_buff =
*skb,
-				struct hsr_port *port);
-
-void hsr_addr_subst_source(struct hsr_priv *hsr, struct sk_buff *skb);
-void hsr_addr_subst_dest(struct hsr_priv *hsr, struct ethhdr *ethhdr,
+struct hsr_node *hsr_add_node(struct list_head *node_db, unsigned char=
 addr[],
+			      u16 seq_out);
+struct hsr_node *hsr_get_node(struct list_head *node_db, struct sk_buf=
f *skb,
+			      bool is_sup);
+void hsr_handle_sup_frame(struct sk_buff *skb, struct hsr_node *node_c=
urr,
+			  struct hsr_port *port);
+bool hsr_addr_is_self(struct hsr_priv *hsr, unsigned char *addr);
+
+void hsr_addr_subst_source(struct hsr_node *node, struct sk_buff *skb)=
;
+void hsr_addr_subst_dest(struct hsr_node *node_src, struct sk_buff *sk=
b,
 			 struct hsr_port *port);
=20
-void hsr_register_frame_in(struct hsr_node *node, struct hsr_port *por=
t);
-
-int hsr_register_frame_out(struct hsr_node *node, struct hsr_port *por=
t,
-			   struct sk_buff *skb);
+void hsr_register_frame_in(struct hsr_node *node, struct hsr_port *por=
t,
+			   u16 sequence_nr);
+int hsr_register_frame_out(struct hsr_port *port, struct hsr_node *nod=
e,
+			   u16 sequence_nr);
=20
 void hsr_prune_nodes(unsigned long data);
=20
diff --git a/net/hsr/hsr_main.c b/net/hsr/hsr_main.c
index a06cab5..779d28b 100644
--- a/net/hsr/hsr_main.c
+++ b/net/hsr/hsr_main.c
@@ -20,26 +20,6 @@
 #include "hsr_slave.h"
=20
=20
-/* List of all registered virtual HSR devices */
-static LIST_HEAD(hsr_list);
-
-void register_hsr_master(struct hsr_priv *hsr)
-{
-	list_add_tail_rcu(&hsr->hsr_list, &hsr_list);
-}
-
-void unregister_hsr_master(struct hsr_priv *hsr)
-{
-	struct hsr_priv *hsr_it;
-
-	list_for_each_entry(hsr_it, &hsr_list, hsr_list)
-		if (hsr_it =3D=3D hsr) {
-			list_del_rcu(&hsr_it->hsr_list);
-			return;
-		}
-}
-
-
 static int hsr_netdev_notify(struct notifier_block *nb, unsigned long =
event,
 			     void *ptr)
 {
diff --git a/net/hsr/hsr_main.h b/net/hsr/hsr_main.h
index e31c306..5a9c699 100644
--- a/net/hsr/hsr_main.h
+++ b/net/hsr/hsr_main.h
@@ -29,6 +29,7 @@
  * each node differ before we notify of communication problem?
  */
 #define MAX_SLAVE_DIFF			 3000 /* ms */
+#define HSR_SEQNR_START			(USHRT_MAX - 1024)
=20
=20
 /* How often shall we check for broken ring and remove node entries ol=
der than
@@ -153,10 +154,9 @@ struct hsr_port {
 };
=20
 struct hsr_priv {
-	struct list_head	hsr_list;	/* List of hsr devices */
 	struct rcu_head		rcu_head;
 	struct list_head	ports;
-	struct list_head	node_db;	/* Other HSR nodes */
+	struct list_head	node_db;	/* Known HSR nodes */
 	struct list_head	self_node_db;	/* MACs of slaves */
 	struct timer_list	announce_timer;	/* Supervision frame dispatch */
 	struct timer_list	prune_timer;
@@ -166,6 +166,18 @@ struct hsr_priv {
 	unsigned char		sup_multicast_addr[ETH_ALEN];
 };
=20
+#define hsr_for_each_port(hsr, port) \
+	list_for_each_entry_rcu((port), &(hsr)->ports, port_list)
+
 struct hsr_port *hsr_port_get_hsr(struct hsr_priv *hsr, enum hsr_port_=
type pt);
=20
+/* Caller must ensure skb is a valid HSR frame */
+static inline u16 hsr_get_skb_sequence_nr(struct sk_buff *skb)
+{
+	struct hsr_ethhdr *hsr_ethhdr;
+
+	hsr_ethhdr =3D (struct hsr_ethhdr *) skb_mac_header(skb);
+	return ntohs(hsr_ethhdr->hsr_tag.sequence_nr);
+}
+
 #endif /*  __HSR_PRIVATE_H */
diff --git a/net/hsr/hsr_netlink.c b/net/hsr/hsr_netlink.c
index 6708245..fbdf53f 100644
--- a/net/hsr/hsr_netlink.c
+++ b/net/hsr/hsr_netlink.c
@@ -358,7 +358,7 @@ fail:
 	return res;
 }
=20
-/* Get a list of MacAddressA of all nodes known to this node (other th=
an self).
+/* Get a list of MacAddressA of all nodes known to this node (includin=
g self).
  */
 static int hsr_get_node_list(struct sk_buff *skb_in, struct genl_info =
*info)
 {
diff --git a/net/hsr/hsr_slave.c b/net/hsr/hsr_slave.c
index 23817d0..a348dcb 100644
--- a/net/hsr/hsr_slave.c
+++ b/net/hsr/hsr_slave.c
@@ -14,9 +14,51 @@
 #include <linux/if_arp.h>
 #include "hsr_main.h"
 #include "hsr_device.h"
+#include "hsr_forward.h"
 #include "hsr_framereg.h"
=20
=20
+static rx_handler_result_t hsr_handle_frame(struct sk_buff **pskb)
+{
+	struct sk_buff *skb =3D *pskb;
+	struct hsr_port *port;
+
+	if (!skb_mac_header_was_set(skb)) {
+		WARN_ONCE(1, "%s: skb invalid", __func__);
+		return RX_HANDLER_PASS;
+	}
+
+	rcu_read_lock(); /* hsr->node_db, hsr->ports */
+	port =3D hsr_port_get_rcu(skb->dev);
+
+	if (hsr_addr_is_self(port->hsr, eth_hdr(skb)->h_source)) {
+		/* Directly kill frames sent by ourselves */
+		kfree_skb(skb);
+		goto finish_consume;
+	}
+
+	if (eth_hdr(skb)->h_proto !=3D htons(ETH_P_PRP))
+		goto finish_pass;
+
+	skb_push(skb, ETH_HLEN);
+
+	hsr_forward_skb(skb, port);
+
+finish_consume:
+	rcu_read_unlock(); /* hsr->node_db, hsr->ports */
+	return RX_HANDLER_CONSUMED;
+
+finish_pass:
+	rcu_read_unlock(); /* hsr->node_db, hsr->ports */
+	return RX_HANDLER_PASS;
+}
+
+bool hsr_port_exists(const struct net_device *dev)
+{
+	return rcu_access_pointer(dev->rx_handler) =3D=3D hsr_handle_frame;
+}
+
+
 static int hsr_check_dev_ok(struct net_device *dev)
 {
 	/* Don't allow HSR on non-ethernet like devices */
@@ -42,6 +84,11 @@ static int hsr_check_dev_ok(struct net_device *dev)
 		return -EINVAL;
 	}
=20
+	if (dev->priv_flags & IFF_DONT_BRIDGE) {
+		netdev_info(dev, "This device does not support bridging.\n");
+		return -EOPNOTSUPP;
+	}
+
 	/* HSR over bonded devices has not been tested, but I'm not sure it
 	 * won't work...
 	 */
@@ -50,232 +97,6 @@ static int hsr_check_dev_ok(struct net_device *dev)
 }
=20
=20
-static struct sk_buff *hsr_pull_tag(struct sk_buff *skb)
-{
-	struct hsr_tag *hsr_tag;
-	struct sk_buff *skb2;
-
-	skb2 =3D skb_share_check(skb, GFP_ATOMIC);
-	if (unlikely(!skb2))
-		goto err_free;
-	skb =3D skb2;
-
-	if (unlikely(!pskb_may_pull(skb, HSR_HLEN)))
-		goto err_free;
-
-	hsr_tag =3D (struct hsr_tag *) skb->data;
-	skb->protocol =3D hsr_tag->encap_proto;
-	skb_pull(skb, HSR_HLEN);
-
-	return skb;
-
-err_free:
-	kfree_skb(skb);
-	return NULL;
-}
-
-
-/* The uses I can see for these HSR supervision frames are:
- * 1) Use the frames that are sent after node initialization ("HSR_TLV=
=2EType =3D
- *    22") to reset any sequence_nr counters belonging to that node. U=
seful if
- *    the other node's counter has been reset for some reason.
- *    --
- *    Or not - resetting the counter and bridging the frame would crea=
te a
- *    loop, unfortunately.
- *
- * 2) Use the LifeCheck frames to detect ring breaks. I.e. if no LifeC=
heck
- *    frame is received from a particular node, we know something is w=
rong.
- *    We just register these (as with normal frames) and throw them aw=
ay.
- *
- * 3) Allow different MAC addresses for the two slave interfaces, usin=
g the
- *    MacAddressA field.
- */
-static bool is_supervision_frame(struct hsr_priv *hsr, struct sk_buff =
*skb)
-{
-	struct hsr_sup_tag *hsr_stag;
-
-	if (!ether_addr_equal(eth_hdr(skb)->h_dest,
-			      hsr->sup_multicast_addr))
-		return false;
-
-	hsr_stag =3D (struct hsr_sup_tag *) skb->data;
-	if (get_hsr_stag_path(hsr_stag) !=3D 0x0f)
-		return false;
-	if ((hsr_stag->HSR_TLV_Type !=3D HSR_TLV_ANNOUNCE) &&
-	    (hsr_stag->HSR_TLV_Type !=3D HSR_TLV_LIFE_CHECK))
-		return false;
-	if (hsr_stag->HSR_TLV_Length !=3D 12)
-		return false;
-
-	return true;
-}
-
-
-/* Implementation somewhat according to IEC-62439-3, p. 43
- */
-rx_handler_result_t hsr_handle_frame(struct sk_buff **pskb)
-{
-	struct sk_buff *skb =3D *pskb;
-	struct hsr_port *port, *other_port, *master;
-	struct hsr_priv *hsr;
-	struct hsr_node *node;
-	bool deliver_to_self;
-	struct sk_buff *skb_deliver;
-	bool dup_out;
-	int ret;
-
-	if (eth_hdr(skb)->h_proto !=3D htons(ETH_P_PRP))
-		return RX_HANDLER_PASS;
-
-	rcu_read_lock(); /* ports & node */
-
-	port =3D hsr_port_get_rcu(skb->dev);
-	hsr =3D port->hsr;
-	master =3D hsr_port_get_hsr(hsr, HSR_PT_MASTER);
-
-	node =3D hsr_find_node(&hsr->self_node_db, skb);
-	if (node) {
-		/* Always kill frames sent by ourselves */
-		kfree_skb(skb);
-		ret =3D RX_HANDLER_CONSUMED;
-		goto finish;
-	}
-
-	/* Is this frame a candidate for local reception? */
-	deliver_to_self =3D false;
-	if ((skb->pkt_type =3D=3D PACKET_HOST) ||
-	    (skb->pkt_type =3D=3D PACKET_MULTICAST) ||
-	    (skb->pkt_type =3D=3D PACKET_BROADCAST))
-		deliver_to_self =3D true;
-	else if (ether_addr_equal(eth_hdr(skb)->h_dest,
-				  master->dev->dev_addr)) {
-		skb->pkt_type =3D PACKET_HOST;
-		deliver_to_self =3D true;
-	}
-
-	node =3D hsr_find_node(&hsr->node_db, skb);
-
-	if (is_supervision_frame(hsr, skb)) {
-		skb_pull(skb, sizeof(struct hsr_sup_tag));
-		node =3D hsr_merge_node(node, skb, port);
-		if (!node) {
-			kfree_skb(skb);
-			master->dev->stats.rx_dropped++;
-			ret =3D RX_HANDLER_CONSUMED;
-			goto finish;
-		}
-		skb_push(skb, sizeof(struct hsr_sup_tag));
-		deliver_to_self =3D false;
-	}
-
-	if (!node) {
-		/* Source node unknown; this might be a HSR frame from
-		 * another net (different multicast address). Ignore it.
-		 */
-		kfree_skb(skb);
-		ret =3D RX_HANDLER_CONSUMED;
-		goto finish;
-	}
-
-	if (port->type =3D=3D HSR_PT_SLAVE_A)
-		other_port =3D hsr_port_get_hsr(hsr, HSR_PT_SLAVE_B);
-	else
-		other_port =3D hsr_port_get_hsr(hsr, HSR_PT_SLAVE_A);
-
-	/* Register ALL incoming frames as outgoing through the other interfa=
ce.
-	 * This allows us to register frames as incoming only if they are val=
id
-	 * for the receiving interface, without using a specific counter for
-	 * incoming frames.
-	 */
-	if (other_port)
-		dup_out =3D hsr_register_frame_out(node, other_port, skb);
-	else
-		dup_out =3D 0;
-	if (!dup_out)
-		hsr_register_frame_in(node, port);
-
-	/* Forward this frame? */
-	if (dup_out || (skb->pkt_type =3D=3D PACKET_HOST))
-		other_port =3D NULL;
-
-	if (hsr_register_frame_out(node, master, skb))
-		deliver_to_self =3D false;
-
-	if (!deliver_to_self && !other_port) {
-		kfree_skb(skb);
-		/* Circulated frame; silently remove it. */
-		ret =3D RX_HANDLER_CONSUMED;
-		goto finish;
-	}
-
-	skb_deliver =3D skb;
-	if (deliver_to_self && other_port) {
-		/* skb_clone() is not enough since we will strip the hsr tag
-		 * and do address substitution below
-		 */
-		skb_deliver =3D pskb_copy(skb, GFP_ATOMIC);
-		if (!skb_deliver) {
-			deliver_to_self =3D false;
-			master->dev->stats.rx_dropped++;
-		}
-	}
-
-	if (deliver_to_self) {
-		bool multicast_frame;
-
-		skb_deliver =3D hsr_pull_tag(skb_deliver);
-		if (!skb_deliver) {
-			master->dev->stats.rx_dropped++;
-			goto forward;
-		}
-#if !defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS)
-		/* Move everything in the header that is after the HSR tag,
-		 * to work around alignment problems caused by the 6-byte HSR
-		 * tag. In practice, this removes/overwrites the HSR tag in
-		 * the header and restores a "standard" packet.
-		 */
-		memmove(skb_deliver->data - HSR_HLEN, skb_deliver->data,
-			skb_headlen(skb_deliver));
-
-		/* Adjust skb members so they correspond with the move above.
-		 * This cannot possibly underflow skb->data since hsr_pull_tag()
-		 * above succeeded.
-		 * At this point in the protocol stack, the transport and
-		 * network headers have not been set yet, and we haven't touched
-		 * the mac header nor the head. So we only need to adjust data
-		 * and tail:
-		 */
-		skb_deliver->data -=3D HSR_HLEN;
-		skb_deliver->tail -=3D HSR_HLEN;
-#endif
-		skb_deliver->dev =3D master->dev;
-		hsr_addr_subst_source(hsr, skb_deliver);
-		multicast_frame =3D (skb_deliver->pkt_type =3D=3D PACKET_MULTICAST);
-		ret =3D netif_rx(skb_deliver);
-		if (ret =3D=3D NET_RX_DROP) {
-			master->dev->stats.rx_dropped++;
-		} else {
-			master->dev->stats.rx_packets++;
-			master->dev->stats.rx_bytes +=3D skb->len;
-			if (multicast_frame)
-				master->dev->stats.multicast++;
-		}
-	}
-
-forward:
-	if (other_port) {
-		skb_push(skb, ETH_HLEN);
-		skb->dev =3D other_port->dev;
-		dev_queue_xmit(skb);
-	}
-
-	ret =3D RX_HANDLER_CONSUMED;
-
-finish:
-	rcu_read_unlock();
-	return ret;
-}
-
 /* Setup device to be added to the HSR bridge. */
 static int hsr_portdev_setup(struct net_device *dev, struct hsr_port *=
port)
 {
@@ -285,16 +106,17 @@ static int hsr_portdev_setup(struct net_device *d=
ev, struct hsr_port *port)
 	res =3D dev_set_promiscuity(dev, 1);
 	if (res)
 		goto fail_promiscuity;
-	res =3D netdev_rx_handler_register(dev, hsr_handle_frame, port);
-	if (res)
-		goto fail_rx_handler;
-	dev_disable_lro(dev);
=20
 	/* FIXME:
 	 * What does net device "adjacency" mean? Should we do
 	 * res =3D netdev_master_upper_dev_link(port->dev, port->hsr->dev); ?
 	 */
=20
+	res =3D netdev_rx_handler_register(dev, hsr_handle_frame, port);
+	if (res)
+		goto fail_rx_handler;
+	dev_disable_lro(dev);
+
 	return 0;
=20
 fail_rx_handler:
@@ -339,11 +161,6 @@ int hsr_add_port(struct hsr_priv *hsr, struct net_=
device *dev,
 	synchronize_rcu();
=20
 	master =3D hsr_port_get_hsr(hsr, HSR_PT_MASTER);
-
-	/* Set required header length */
-	if (dev->hard_header_len + HSR_HLEN > master->dev->hard_header_len)
-		master->dev->hard_header_len =3D dev->hard_header_len + HSR_HLEN;
-
 	netdev_update_features(master->dev);
 	dev_set_mtu(master->dev, hsr_get_max_mtu(hsr));
=20
diff --git a/net/hsr/hsr_slave.h b/net/hsr/hsr_slave.h
index 3055022..3ccfbf7 100644
--- a/net/hsr/hsr_slave.h
+++ b/net/hsr/hsr_slave.h
@@ -20,17 +20,7 @@
 int hsr_add_port(struct hsr_priv *hsr, struct net_device *dev,
 		 enum hsr_port_type pt);
 void hsr_del_port(struct hsr_port *port);
-rx_handler_result_t hsr_handle_frame(struct sk_buff **pskb);
-
-
-#define hsr_for_each_port(hsr, port) \
-	list_for_each_entry_rcu((port), &(hsr)->ports, port_list)
-
-
-static inline bool hsr_port_exists(const struct net_device *dev)
-{
-	return dev->rx_handler =3D=3D hsr_handle_frame;
-}
+bool hsr_port_exists(const struct net_device *dev);
=20
 static inline struct hsr_port *hsr_port_get_rtnl(const struct net_devi=
ce *dev)
 {
--=20
1.8.3.2

--=20
Arvid Brodin | Consultant (Linux)
ALTEN | Knarrarn=C3=A4sgatan 7 | SE-164 40 Kista | Sweden
arvid.brodin@alten.se | www.alten.se/en/
