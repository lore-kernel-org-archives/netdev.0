From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH bluetooth-next 4/4] mac802154: add comments for llsec issues
Date: Mon, 28 Sep 2015 09:00:26 +0200
Message-ID: <1443423626-3609-5-git-send-email-alex.aring@gmail.com>
References: <1443423626-3609-1-git-send-email-alex.aring@gmail.com>
Cc: kernel@pengutronix.de, netdev@vger.kernel.org,
	phoebe.buckheister@itwm.fraunhofer.de,
	Alexander Aring <alex.aring@gmail.com>
To: linux-wpan@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:33342 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756394AbbI1HCV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2015 03:02:21 -0400
In-Reply-To: <1443423626-3609-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While doing a little test with the llsec implementation I saw these
issues. We should move decryption and encruption somewhere else,
otherwise while capturing with wireshark the mac header shows secuirty
fields but the payload is plaintext.

A complete other issue is what doing with HardMAC drivers where the
payload is always plaintext. I think we need a special handling then in
userspace. We currently doesn't support any HardMAC transceivers, so we
should fix the first issue for SoftMAC transceivers.

Signed-off-by: Alexander Aring <alex.aring@gmail.com>
---
 net/mac802154/rx.c | 4 ++++
 net/mac802154/tx.c | 4 ++++
 2 files changed, 8 insertions(+)

diff --git a/net/mac802154/rx.c b/net/mac802154/rx.c
index d1c33c1..42e9672 100644
--- a/net/mac802154/rx.c
+++ b/net/mac802154/rx.c
@@ -87,6 +87,10 @@ ieee802154_subif_frame(struct ieee802154_sub_if_data *sdata,
 
 	skb->dev = sdata->dev;
 
+	/* TODO this should be moved after netif_receive_skb call, otherwise
+	 * wireshark will show a mac header with security fields and the
+	 * payload is already decrypted.
+	 */
 	rc = mac802154_llsec_decrypt(&sdata->sec, skb);
 	if (rc) {
 		pr_debug("decryption failed: %i\n", rc);
diff --git a/net/mac802154/tx.c b/net/mac802154/tx.c
index 5ee596e..b205bbe 100644
--- a/net/mac802154/tx.c
+++ b/net/mac802154/tx.c
@@ -129,6 +129,10 @@ ieee802154_subif_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct ieee802154_sub_if_data *sdata = IEEE802154_DEV_TO_SUB_IF(dev);
 	int rc;
 
+	/* TODO we should move it to wpan_dev_hard_header and dev_hard_header
+	 * functions. The reason is wireshark will show a mac header which is
+	 * with security fields but the payload is not encrypted.
+	 */
 	rc = mac802154_llsec_encrypt(&sdata->sec, skb);
 	if (rc) {
 		netdev_warn(dev, "encryption failed: %i\n", rc);
-- 
2.5.3
