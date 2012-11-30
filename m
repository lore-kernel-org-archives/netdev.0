From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH 15/17] solos-pci: clean up pclose() function
Date: Fri, 30 Nov 2012 00:35:34 +0000
Message-ID: <1354235736-26833-16-git-send-email-dwmw2@infradead.org>
References: <1354235736-26833-1-git-send-email-dwmw2@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: chas@cmf.nrl.navy.mil, krzysiek@podlesie.net,
	David Woodhouse <David.Woodhouse@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:37529 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755028Ab2K3Agn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2012 19:36:43 -0500
In-Reply-To: <1354235736-26833-1-git-send-email-dwmw2@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: David Woodhouse <David.Woodhouse@intel.com>

 - Flush pending TX skbs from the queue rather than waiting for them al=
l to
   complete (suggested by Krzysztof Mazur <krzysiek@podlesie.net>).
 - Clear ATM_VF_ADDR only when the PKT_PCLOSE packet has been submitted=
=2E
 - Don't clear ATM_VF_READY at all =E2=80=94 vcc_destroy_socket() does =
that for us.

Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
---
 drivers/atm/solos-pci.c | 26 ++++++++++++++++++--------
 1 file changed, 18 insertions(+), 8 deletions(-)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index 6258961..7c56286 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -868,9 +868,20 @@ static int popen(struct atm_vcc *vcc)
 static void pclose(struct atm_vcc *vcc)
 {
 	struct solos_card *card =3D vcc->dev->dev_data;
-	struct sk_buff *skb;
+	unsigned char port =3D SOLOS_CHAN(vcc->dev);
+	struct sk_buff *skb, *tmpskb;
 	struct pkt_hdr *header;
=20
+	/* Remove any yet-to-be-transmitted packets from the pending queue */
+	spin_lock(&card->tx_queue_lock);
+	skb_queue_walk_safe(&card->tx_queue[port], skb, tmpskb) {
+		if (SKB_CB(skb)->vcc =3D=3D vcc) {
+			skb_unlink(skb, &card->tx_queue[port]);
+			solos_pop(vcc, skb);
+		}
+	}
+	spin_unlock(&card->tx_queue_lock);
+
 	skb =3D alloc_skb(sizeof(*header), GFP_ATOMIC);
 	if (!skb) {
 		dev_warn(&card->dev->dev, "Failed to allocate sk_buff in pclose()\n"=
);
@@ -885,20 +896,19 @@ static void pclose(struct atm_vcc *vcc)
=20
 	init_completion(&SKB_CB(skb)->c);
=20
-	fpga_queue(card, SOLOS_CHAN(vcc->dev), skb, NULL);
-
-	clear_bit(ATM_VF_ADDR, &vcc->flags);
-	clear_bit(ATM_VF_READY, &vcc->flags);
+	fpga_queue(card, port, skb, NULL);
=20
-	if (!wait_for_completion_timeout(&SKB_CB(skb)->c,
-					 msecs_to_jiffies(5000)))
+	if (!wait_for_completion_timeout(&SKB_CB(skb)->c, 5 * HZ))
 		dev_warn(&card->dev->dev, "Timeout waiting for VCC close on port %d\=
n",
-			 SOLOS_CHAN(vcc->dev));
+			 port);
=20
 	/* Hold up vcc_destroy_socket() (our caller) until solos_bh() in the
 	   tasklet has finished processing any incoming packets (and, more to
 	   the point, using the vcc pointer). */
 	tasklet_unlock_wait(&card->tlet);
+
+	clear_bit(ATM_VF_ADDR, &vcc->flags);
+
 	return;
 }
=20
--=20
1.8.0
