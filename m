From: Tobias Brunner <tobias@strongswan.org>
Subject: [PATCH net] macsec: Fix header length if SCI is added if explicitily
 disabled
Date: Fri, 21 Oct 2016 13:11:37 +0200
Message-ID: <bfb9f7ef-39b1-269f-48de-d7caf5c54c2f@strongswan.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
        Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sitav-80046.hsr.ch ([152.96.80.46]:36159 "EHLO
        mail.strongswan.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753745AbcJULVB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 07:21:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Even if sending SCIs is explicitly disabled, the code that creates the
Security Tag might still decide to add it (e.g. if multiple RX SCs are
defined on the MACsec interface).
But because the header length so far only depended on the configuration
option the SCI might not actually have ended up in the packet, while the
SC flag in the TCI field of the Security Tag was still set, resulting
in invalid MACsec frames.

Signed-off-by: Tobias Brunner <tobias@strongswan.org>
---
 drivers/net/macsec.c | 22 ++++++++++++++++------
 1 file changed, 16 insertions(+), 6 deletions(-)

diff --git a/drivers/net/macsec.c b/drivers/net/macsec.c
index 3ea47f28e143..246679f24a44 100644
--- a/drivers/net/macsec.c
+++ b/drivers/net/macsec.c
@@ -397,6 +397,14 @@ static struct macsec_cb *macsec_skb_cb(struct sk_buff *skb)
 #define DEFAULT_ENCRYPT false
 #define DEFAULT_ENCODING_SA 0
 
+static bool send_sci(const struct macsec_secy *secy)
+{
+	const struct macsec_tx_sc *tx_sc = &secy->tx_sc;
+
+	return tx_sc->send_sci ||
+		(secy->n_rx_sc > 1 && !tx_sc->end_station && !tx_sc->scb);
+}
+
 static sci_t make_sci(u8 *addr, __be16 port)
 {
 	sci_t sci;
@@ -440,12 +448,12 @@ static void macsec_fill_sectag(struct macsec_eth_header *h,
 			       const struct macsec_secy *secy, u32 pn)
 {
 	const struct macsec_tx_sc *tx_sc = &secy->tx_sc;
+	bool sci_present = send_sci(secy);
 
-	memset(&h->tci_an, 0, macsec_sectag_len(tx_sc->send_sci));
+	memset(&h->tci_an, 0, macsec_sectag_len(sci_present));
 	h->eth.h_proto = htons(ETH_P_MACSEC);
 
-	if (tx_sc->send_sci ||
-	    (secy->n_rx_sc > 1 && !tx_sc->end_station && !tx_sc->scb)) {
+	if (sci_present) {
 		h->tci_an |= MACSEC_TCI_SC;
 		memcpy(&h->secure_channel_id, &secy->sci,
 		       sizeof(h->secure_channel_id));
@@ -650,6 +658,7 @@ static struct sk_buff *macsec_encrypt(struct sk_buff *skb,
 	struct macsec_tx_sc *tx_sc;
 	struct macsec_tx_sa *tx_sa;
 	struct macsec_dev *macsec = macsec_priv(dev);
+	bool sci_present;
 	u32 pn;
 
 	secy = &macsec->secy;
@@ -687,7 +696,8 @@ static struct sk_buff *macsec_encrypt(struct sk_buff *skb,
 
 	unprotected_len = skb->len;
 	eth = eth_hdr(skb);
-	hh = (struct macsec_eth_header *)skb_push(skb, macsec_extra_len(tx_sc->send_sci));
+	sci_present = send_sci(secy);
+	hh = (struct macsec_eth_header *)skb_push(skb, macsec_extra_len(sci_present));
 	memmove(hh, eth, 2 * ETH_ALEN);
 
 	pn = tx_sa_update_pn(tx_sa, secy);
@@ -726,10 +736,10 @@ static struct sk_buff *macsec_encrypt(struct sk_buff *skb,
 	skb_to_sgvec(skb, sg, 0, skb->len);
 
 	if (tx_sc->encrypt) {
-		int len = skb->len - macsec_hdr_len(tx_sc->send_sci) -
+		int len = skb->len - macsec_hdr_len(sci_present) -
 			  secy->icv_len;
 		aead_request_set_crypt(req, sg, sg, len, iv);
-		aead_request_set_ad(req, macsec_hdr_len(tx_sc->send_sci));
+		aead_request_set_ad(req, macsec_hdr_len(sci_present));
 	} else {
 		aead_request_set_crypt(req, sg, sg, 0, iv);
 		aead_request_set_ad(req, skb->len - secy->icv_len);
-- 
1.9.1
