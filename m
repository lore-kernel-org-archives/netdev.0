From: David Miller <davem@davemloft.net>
Subject: [PATCH]: Eliminate fast-path print_mac() pr_debug()'s.
Date: Tue, 08 Apr 2008 16:54:53 -0700 (PDT)
Message-ID: <20080408.165453.215068738.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, joe@perches.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40651
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758113AbYDHXyx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2008 19:54:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Patrick, this is what I checked in to net-2.6, based upon your list.

Thanks!

Joe, the issue isn't whether your suggested fix is better or not.
Rather it is a matter of what is the least risk fix for 2.6.25.  But
for some reason you keep pushing your agenda without understanding the
consequences.  I had a reason for requesting that you fix things
in this way.  Thanks for wasting part of my afternoon when I already
am bombed with an enormous backlog of other work :-/

I made a note of this in the changelog so there is no confusion what
the issue is.

commit 21f644f3eabde637f255f75ad05d0821a7a36b7f
Author: David S. Miller <davem@davemloft.net>
Date:   Tue Apr 8 16:50:44 2008 -0700

    [NET]: Undo code bloat in hot paths due to print_mac().
    
    If print_mac() is used inside of a pr_debug() the compiler
    can't see that the call is redundant so still performs it
    even of pr_debug() ends up being a nop.
    
    So don't use print_mac() in such cases in hot code paths,
    use MAC_FMT et al. instead.
    
    As noted by Joe Perches, pr_debug() could be modified to
    handle this better, but that is a change to an interface
    used by the entire kernel and thus needs to be validated
    carefully.  This here is thus the less risky fix for
    2.6.25
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/drivers/net/starfire.c b/drivers/net/starfire.c
index c49214f..7b7b171 100644
--- a/drivers/net/starfire.c
+++ b/drivers/net/starfire.c
@@ -1472,13 +1472,12 @@ static int __netdev_rx(struct net_device *dev, int *quota)
 #ifndef final_version			/* Remove after testing. */
 		/* You will want this info for the initial debug. */
 		if (debug > 5) {
-			DECLARE_MAC_BUF(mac);
-			DECLARE_MAC_BUF(mac2);
-
-			printk(KERN_DEBUG "  Rx data %s %s"
+			printk(KERN_DEBUG "  Rx data " MAC_FMT " " MAC_FMT
 			       " %2.2x%2.2x.\n",
-			       print_mac(mac, &skb->data[0]),
-			       print_mac(mac2, &skb->data[6]),
+			       skb->data[0], skb->data[1], skb->data[2],
+			       skb->data[3], skb->data[4], skb->data[5],
+			       skb->data[6], skb->data[7], skb->data[8],
+			       skb->data[9], skb->data[10], skb->data[11],
 			       skb->data[12], skb->data[13]);
 		}
 #endif
diff --git a/drivers/net/tokenring/olympic.c b/drivers/net/tokenring/olympic.c
index db4ca4f..0ab51a0 100644
--- a/drivers/net/tokenring/olympic.c
+++ b/drivers/net/tokenring/olympic.c
@@ -1438,13 +1438,18 @@ static void olympic_arb_cmd(struct net_device *dev)
 
 		if (olympic_priv->olympic_network_monitor) { 
 			struct trh_hdr *mac_hdr;
-			DECLARE_MAC_BUF(mac);
 			printk(KERN_WARNING "%s: Received MAC Frame, details: \n",dev->name);
 			mac_hdr = tr_hdr(mac_frame);
-			printk(KERN_WARNING "%s: MAC Frame Dest. Addr: %s\n",
-			       dev->name, print_mac(mac, mac_hdr->daddr));
-			printk(KERN_WARNING "%s: MAC Frame Srce. Addr: %s\n",
-			       dev->name, print_mac(mac, mac_hdr->saddr));
+			printk(KERN_WARNING "%s: MAC Frame Dest. Addr: "
+			       MAC_FMT " \n", dev->name,
+			       mac_hdr->daddr[0], mac_hdr->daddr[1],
+			       mac_hdr->daddr[2], mac_hdr->daddr[3],
+			       mac_hdr->daddr[4], mac_hdr->daddr[5]);
+			printk(KERN_WARNING "%s: MAC Frame Srce. Addr: "
+			       MAC_FMT " \n", dev->name,
+			       mac_hdr->saddr[0], mac_hdr->saddr[1],
+			       mac_hdr->saddr[2], mac_hdr->saddr[3],
+			       mac_hdr->saddr[4], mac_hdr->saddr[5]);
 		}
 		netif_rx(mac_frame);
 		dev->last_rx = jiffies;
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index b58472c..d02d9d7 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -234,11 +234,12 @@ static int start_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct scatterlist sg[1+MAX_SKB_FRAGS];
 	struct virtio_net_hdr *hdr;
 	const unsigned char *dest = ((struct ethhdr *)skb->data)->h_dest;
-	DECLARE_MAC_BUF(mac);
 
 	sg_init_table(sg, 1+MAX_SKB_FRAGS);
 
-	pr_debug("%s: xmit %p %s\n", dev->name, skb, print_mac(mac, dest));
+	pr_debug("%s: xmit %p " MAC_FMT "\n", dev->name, skb,
+		 dest[0], dest[1], dest[2],
+		 dest[3], dest[4], dest[5]);
 
 	/* Encode metadata header at front. */
 	hdr = skb_vnet_hdr(skb);
diff --git a/drivers/net/wireless/hostap/hostap_80211_rx.c b/drivers/net/wireless/hostap/hostap_80211_rx.c
index 49978bd..4fd7380 100644
--- a/drivers/net/wireless/hostap/hostap_80211_rx.c
+++ b/drivers/net/wireless/hostap/hostap_80211_rx.c
@@ -635,7 +635,6 @@ hostap_rx_frame_decrypt(local_info_t *local, struct sk_buff *skb,
 {
 	struct ieee80211_hdr_4addr *hdr;
 	int res, hdrlen;
-	DECLARE_MAC_BUF(mac);
 
 	if (crypt == NULL || crypt->ops->decrypt_mpdu == NULL)
 		return 0;
@@ -647,8 +646,10 @@ hostap_rx_frame_decrypt(local_info_t *local, struct sk_buff *skb,
 	    strcmp(crypt->ops->name, "TKIP") == 0) {
 		if (net_ratelimit()) {
 			printk(KERN_DEBUG "%s: TKIP countermeasures: dropped "
-			       "received packet from %s\n",
-			       local->dev->name, print_mac(mac, hdr->addr2));
+			       "received packet from " MAC_FMT "\n",
+			       local->dev->name,
+			       hdr->addr2[0], hdr->addr2[1], hdr->addr2[2],
+			       hdr->addr2[3], hdr->addr2[4], hdr->addr2[5]);
 		}
 		return -1;
 	}
@@ -657,9 +658,12 @@ hostap_rx_frame_decrypt(local_info_t *local, struct sk_buff *skb,
 	res = crypt->ops->decrypt_mpdu(skb, hdrlen, crypt->priv);
 	atomic_dec(&crypt->refcnt);
 	if (res < 0) {
-		printk(KERN_DEBUG "%s: decryption failed (SA=%s"
+		printk(KERN_DEBUG "%s: decryption failed (SA=" MAC_FMT
 		       ") res=%d\n",
-		       local->dev->name, print_mac(mac, hdr->addr2), res);
+		       local->dev->name,
+		       hdr->addr2[0], hdr->addr2[1], hdr->addr2[2],
+		       hdr->addr2[3], hdr->addr2[4], hdr->addr2[5],
+		       res);
 		local->comm_tallies.rx_discards_wep_undecryptable++;
 		return -1;
 	}
@@ -721,7 +725,6 @@ void hostap_80211_rx(struct net_device *dev, struct sk_buff *skb,
 	struct ieee80211_crypt_data *crypt = NULL;
 	void *sta = NULL;
 	int keyidx = 0;
-	DECLARE_MAC_BUF(mac);
 
 	iface = netdev_priv(dev);
 	local = iface->local;
@@ -798,8 +801,10 @@ void hostap_80211_rx(struct net_device *dev, struct sk_buff *skb,
 			 * frames silently instead of filling system log with
 			 * these reports. */
 			printk(KERN_DEBUG "%s: WEP decryption failed (not set)"
-			       " (SA=%s)\n",
-			       local->dev->name, print_mac(mac, hdr->addr2));
+			       " (SA=" MAC_FMT ")\n",
+			       local->dev->name,
+			       hdr->addr2[0], hdr->addr2[1], hdr->addr2[2],
+			       hdr->addr2[3], hdr->addr2[4], hdr->addr2[5]);
 #endif
 			local->comm_tallies.rx_discards_wep_undecryptable++;
 			goto rx_dropped;
@@ -813,8 +818,9 @@ void hostap_80211_rx(struct net_device *dev, struct sk_buff *skb,
 		    (keyidx = hostap_rx_frame_decrypt(local, skb, crypt)) < 0)
 		{
 			printk(KERN_DEBUG "%s: failed to decrypt mgmt::auth "
-			       "from %s\n", dev->name,
-			       print_mac(mac, hdr->addr2));
+			       "from " MAC_FMT "\n", dev->name,
+			       hdr->addr2[0], hdr->addr2[1], hdr->addr2[2],
+			       hdr->addr2[3], hdr->addr2[4], hdr->addr2[5]);
 			/* TODO: could inform hostapd about this so that it
 			 * could send auth failure report */
 			goto rx_dropped;
@@ -982,8 +988,10 @@ void hostap_80211_rx(struct net_device *dev, struct sk_buff *skb,
 			       "unencrypted EAPOL frame\n", local->dev->name);
 		} else {
 			printk(KERN_DEBUG "%s: encryption configured, but RX "
-			       "frame not encrypted (SA=%s)\n",
-			       local->dev->name, print_mac(mac, hdr->addr2));
+			       "frame not encrypted (SA=" MAC_FMT ")\n",
+			       local->dev->name,
+			       hdr->addr2[0], hdr->addr2[1], hdr->addr2[2],
+			       hdr->addr2[3], hdr->addr2[4], hdr->addr2[5]);
 			goto rx_dropped;
 		}
 	}
@@ -992,9 +1000,10 @@ void hostap_80211_rx(struct net_device *dev, struct sk_buff *skb,
 	    !hostap_is_eapol_frame(local, skb)) {
 		if (net_ratelimit()) {
 			printk(KERN_DEBUG "%s: dropped unencrypted RX data "
-			       "frame from %s"
-			       " (drop_unencrypted=1)\n",
-			       dev->name, print_mac(mac, hdr->addr2));
+			       "frame from " MAC_FMT " (drop_unencrypted=1)\n",
+			       dev->name,
+			       hdr->addr2[0], hdr->addr2[1], hdr->addr2[2],
+			       hdr->addr2[3], hdr->addr2[4], hdr->addr2[5]);
 		}
 		goto rx_dropped;
 	}
diff --git a/drivers/net/wireless/hostap/hostap_80211_tx.c b/drivers/net/wireless/hostap/hostap_80211_tx.c
index e7afc3e..921c984 100644
--- a/drivers/net/wireless/hostap/hostap_80211_tx.c
+++ b/drivers/net/wireless/hostap/hostap_80211_tx.c
@@ -314,7 +314,6 @@ static struct sk_buff * hostap_tx_encrypt(struct sk_buff *skb,
 	struct ieee80211_hdr_4addr *hdr;
 	u16 fc;
 	int prefix_len, postfix_len, hdr_len, res;
-	DECLARE_MAC_BUF(mac);
 
 	iface = netdev_priv(skb->dev);
 	local = iface->local;
@@ -329,8 +328,10 @@ static struct sk_buff * hostap_tx_encrypt(struct sk_buff *skb,
 		hdr = (struct ieee80211_hdr_4addr *) skb->data;
 		if (net_ratelimit()) {
 			printk(KERN_DEBUG "%s: TKIP countermeasures: dropped "
-			       "TX packet to %s\n",
-			       local->dev->name, print_mac(mac, hdr->addr1));
+			       "TX packet to " MAC_FMT "\n",
+			       local->dev->name,
+			       hdr->addr1[0], hdr->addr1[1], hdr->addr1[2],
+			       hdr->addr1[3], hdr->addr1[4], hdr->addr1[5]);
 		}
 		kfree_skb(skb);
 		return NULL;
diff --git a/drivers/net/wireless/hostap/hostap_ap.c b/drivers/net/wireless/hostap/hostap_ap.c
index ad040a3..0acd958 100644
--- a/drivers/net/wireless/hostap/hostap_ap.c
+++ b/drivers/net/wireless/hostap/hostap_ap.c
@@ -632,7 +632,6 @@ static void hostap_ap_tx_cb_auth(struct sk_buff *skb, int ok, void *data)
 	__le16 *pos;
 	struct sta_info *sta = NULL;
 	char *txt = NULL;
-	DECLARE_MAC_BUF(mac);
 
 	if (ap->local->hostapd) {
 		dev_kfree_skb(skb);
@@ -684,10 +683,12 @@ static void hostap_ap_tx_cb_auth(struct sk_buff *skb, int ok, void *data)
 	if (sta)
 		atomic_dec(&sta->users);
 	if (txt) {
-		PDEBUG(DEBUG_AP, "%s: %s auth_cb - alg=%d "
+		PDEBUG(DEBUG_AP, "%s: " MAC_FMT " auth_cb - alg=%d "
 		       "trans#=%d status=%d - %s\n",
-		       dev->name, print_mac(mac, hdr->addr1), auth_alg,
-		       auth_transaction, status, txt);
+		       dev->name,
+		       hdr->addr1[0], hdr->addr1[1], hdr->addr1[2],
+		       hdr->addr1[3], hdr->addr1[4], hdr->addr1[5],
+		       auth_alg, auth_transaction, status, txt);
 	}
 	dev_kfree_skb(skb);
 }
@@ -703,7 +704,6 @@ static void hostap_ap_tx_cb_assoc(struct sk_buff *skb, int ok, void *data)
 	__le16 *pos;
 	struct sta_info *sta = NULL;
 	char *txt = NULL;
-	DECLARE_MAC_BUF(mac);
 
 	if (ap->local->hostapd) {
 		dev_kfree_skb(skb);
@@ -754,8 +754,11 @@ static void hostap_ap_tx_cb_assoc(struct sk_buff *skb, int ok, void *data)
 	if (sta)
 		atomic_dec(&sta->users);
 	if (txt) {
-		PDEBUG(DEBUG_AP, "%s: %s assoc_cb - %s\n",
-		       dev->name, print_mac(mac, hdr->addr1), txt);
+		PDEBUG(DEBUG_AP, "%s: " MAC_FMT " assoc_cb - %s\n",
+		       dev->name,
+		       hdr->addr1[0], hdr->addr1[1], hdr->addr1[2],
+		       hdr->addr1[3], hdr->addr1[4], hdr->addr1[5],
+		       txt);
 	}
 	dev_kfree_skb(skb);
 }
@@ -767,7 +770,6 @@ static void hostap_ap_tx_cb_poll(struct sk_buff *skb, int ok, void *data)
 	struct ap_data *ap = data;
 	struct ieee80211_hdr_4addr *hdr;
 	struct sta_info *sta;
-	DECLARE_MAC_BUF(mac);
 
 	if (skb->len < 24)
 		goto fail;
@@ -779,9 +781,11 @@ static void hostap_ap_tx_cb_poll(struct sk_buff *skb, int ok, void *data)
 			sta->flags &= ~WLAN_STA_PENDING_POLL;
 		spin_unlock(&ap->sta_table_lock);
 	} else {
-		PDEBUG(DEBUG_AP, "%s: STA %s"
+		PDEBUG(DEBUG_AP, "%s: STA " MAC_FMT
 		       " did not ACK activity poll frame\n",
-		       ap->local->dev->name, print_mac(mac, hdr->addr1));
+		       ap->local->dev->name,
+		       hdr->addr1[0], hdr->addr1[1], hdr->addr1[2],
+		       hdr->addr1[3], hdr->addr1[4], hdr->addr1[5]);
 	}
 
  fail:
@@ -1306,7 +1310,6 @@ static void handle_authen(local_info_t *local, struct sk_buff *skb,
 	struct sta_info *sta = NULL;
 	struct ieee80211_crypt_data *crypt;
 	char *txt = "";
-	DECLARE_MAC_BUF(mac);
 
 	len = skb->len - IEEE80211_MGMT_HDR_LEN;
 
@@ -1315,8 +1318,9 @@ static void handle_authen(local_info_t *local, struct sk_buff *skb,
 
 	if (len < 6) {
 		PDEBUG(DEBUG_AP, "%s: handle_authen - too short payload "
-		       "(len=%d) from %s\n", dev->name, len,
-		       print_mac(mac, hdr->addr2));
+		       "(len=%d) from " MAC_FMT "\n", dev->name, len,
+		       hdr->addr2[0], hdr->addr2[1], hdr->addr2[2],
+		       hdr->addr2[3], hdr->addr2[4], hdr->addr2[5]);
 		return;
 	}
 
@@ -1381,8 +1385,10 @@ static void handle_authen(local_info_t *local, struct sk_buff *skb,
 		if (time_after(jiffies, sta->u.ap.last_beacon +
 			       (10 * sta->listen_interval * HZ) / 1024)) {
 			PDEBUG(DEBUG_AP, "%s: no beacons received for a while,"
-			       " assuming AP %s is now STA\n",
-			       dev->name, print_mac(mac, sta->addr));
+			       " assuming AP " MAC_FMT " is now STA\n",
+			       dev->name,
+			       sta->addr[0], sta->addr[1], sta->addr[2],
+			       sta->addr[3], sta->addr[4], sta->addr[5]);
 			sta->ap = 0;
 			sta->flags = 0;
 			sta->u.sta.challenge = NULL;
@@ -1497,10 +1503,13 @@ static void handle_authen(local_info_t *local, struct sk_buff *skb,
 	}
 
 	if (resp) {
-		PDEBUG(DEBUG_AP, "%s: %s auth (alg=%d "
+		PDEBUG(DEBUG_AP, "%s: " MAC_FMT " auth (alg=%d "
 		       "trans#=%d stat=%d len=%d fc=%04x) ==> %d (%s)\n",
-		       dev->name, print_mac(mac, hdr->addr2), auth_alg,
-		       auth_transaction, status_code, len, fc, resp, txt);
+		       dev->name,
+		       hdr->addr2[0], hdr->addr2[1], hdr->addr2[2],
+		       hdr->addr2[3], hdr->addr2[4], hdr->addr2[5],
+		       auth_alg, auth_transaction, status_code, len,
+		       fc, resp, txt);
 	}
 }
 
@@ -1519,14 +1528,15 @@ static void handle_assoc(local_info_t *local, struct sk_buff *skb,
 	int send_deauth = 0;
 	char *txt = "";
 	u8 prev_ap[ETH_ALEN];
-	DECLARE_MAC_BUF(mac);
 
 	left = len = skb->len - IEEE80211_MGMT_HDR_LEN;
 
 	if (len < (reassoc ? 10 : 4)) {
 		PDEBUG(DEBUG_AP, "%s: handle_assoc - too short payload "
-		       "(len=%d, reassoc=%d) from %s\n",
-		       dev->name, len, reassoc, print_mac(mac, hdr->addr2));
+		       "(len=%d, reassoc=%d) from " MAC_FMT "\n",
+		       dev->name, len, reassoc,
+		       hdr->addr2[0], hdr->addr2[1], hdr->addr2[2],
+		       hdr->addr2[3], hdr->addr2[4], hdr->addr2[5]);
 		return;
 	}
 
@@ -1603,9 +1613,12 @@ static void handle_assoc(local_info_t *local, struct sk_buff *skb,
 		}
 
 		if (left > 0) {
-			PDEBUG(DEBUG_AP, "%s: assoc from %s"
+			PDEBUG(DEBUG_AP, "%s: assoc from " MAC_FMT
 			       " with extra data (%d bytes) [",
-			       dev->name, print_mac(mac, hdr->addr2), left);
+			       dev->name,
+			       hdr->addr2[0], hdr->addr2[1], hdr->addr2[2],
+			       hdr->addr2[3], hdr->addr2[4], hdr->addr2[5],
+			       left);
 			while (left > 0) {
 				PDEBUG2(DEBUG_AP, "<%02x>", *u);
 				u++; left--;
@@ -1704,10 +1717,15 @@ static void handle_assoc(local_info_t *local, struct sk_buff *skb,
 	}
 
 #if 0
-	PDEBUG(DEBUG_AP, "%s: %s %sassoc (len=%d "
-	       "prev_ap=%s) => %d(%d) (%s)\n",
-	       dev->name, print_mac(mac, hdr->addr2), reassoc ? "re" : "", len,
-	       print_mac(mac, prev_ap), resp, send_deauth, txt);
+	PDEBUG(DEBUG_AP, "%s: " MAC_FMT" %sassoc (len=%d "
+	       "prev_ap=" MAC_FMT") => %d(%d) (%s)\n",
+	       dev->name,
+	       hdr->addr2[0], hdr->addr2[1], hdr->addr2[2],
+	       hdr->addr2[3], hdr->addr2[4], hdr->addr2[5],
+	       reassoc ? "re" : "", len,
+	       prev_ap[0], prev_ap[1], prev_ap[2],
+	       prev_ap[3], prev_ap[4], prev_ap[5],
+	       resp, send_deauth, txt);
 #endif
 }
 
@@ -1735,9 +1753,11 @@ static void handle_deauth(local_info_t *local, struct sk_buff *skb,
 	pos = (__le16 *) body;
 	reason_code = le16_to_cpu(*pos);
 
-	PDEBUG(DEBUG_AP, "%s: deauthentication: %s len=%d, "
-	       "reason_code=%d\n", dev->name, print_mac(mac, hdr->addr2), len,
-	       reason_code);
+	PDEBUG(DEBUG_AP, "%s: deauthentication: " MAC_FMT " len=%d, "
+	       "reason_code=%d\n", dev->name,
+	       hdr->addr2[0], hdr->addr2[1], hdr->addr2[2],
+	       hdr->addr2[3], hdr->addr2[4], hdr->addr2[5],
+	       len, reason_code);
 
 	spin_lock_bh(&local->ap->sta_table_lock);
 	sta = ap_get_sta(local->ap, hdr->addr2);
@@ -1748,9 +1768,11 @@ static void handle_deauth(local_info_t *local, struct sk_buff *skb,
 	}
 	spin_unlock_bh(&local->ap->sta_table_lock);
 	if (sta == NULL) {
-		printk("%s: deauthentication from %s, "
+		printk("%s: deauthentication from " MAC_FMT ", "
 	       "reason_code=%d, but STA not authenticated\n", dev->name,
-		       print_mac(mac, hdr->addr2), reason_code);
+		       hdr->addr2[0], hdr->addr2[1], hdr->addr2[2],
+		       hdr->addr2[3], hdr->addr2[4], hdr->addr2[5],
+		       reason_code);
 	}
 }
 
@@ -1766,7 +1788,6 @@ static void handle_disassoc(local_info_t *local, struct sk_buff *skb,
 	u16 reason_code;
 	__le16 *pos;
 	struct sta_info *sta = NULL;
-	DECLARE_MAC_BUF(mac);
 
 	len = skb->len - IEEE80211_MGMT_HDR_LEN;
 
@@ -1778,9 +1799,11 @@ static void handle_disassoc(local_info_t *local, struct sk_buff *skb,
 	pos = (__le16 *) body;
 	reason_code = le16_to_cpu(*pos);
 
-	PDEBUG(DEBUG_AP, "%s: disassociation: %s len=%d, "
-	       "reason_code=%d\n", dev->name, print_mac(mac, hdr->addr2), len,
-	       reason_code);
+	PDEBUG(DEBUG_AP, "%s: disassociation: " MAC_FMT " len=%d, "
+	       "reason_code=%d\n", dev->name,
+	       hdr->addr2[0], hdr->addr2[1], hdr->addr2[2],
+	       hdr->addr2[3], hdr->addr2[4], hdr->addr2[5],
+	       len, reason_code);
 
 	spin_lock_bh(&local->ap->sta_table_lock);
 	sta = ap_get_sta(local->ap, hdr->addr2);
@@ -1791,9 +1814,12 @@ static void handle_disassoc(local_info_t *local, struct sk_buff *skb,
 	}
 	spin_unlock_bh(&local->ap->sta_table_lock);
 	if (sta == NULL) {
-		printk("%s: disassociation from %s, "
+		printk("%s: disassociation from " MAC_FMT ", "
 		       "reason_code=%d, but STA not authenticated\n",
-		       dev->name, print_mac(mac, hdr->addr2), reason_code);
+		       dev->name,
+		       hdr->addr2[0], hdr->addr2[1], hdr->addr2[2],
+		       hdr->addr2[3], hdr->addr2[4], hdr->addr2[5],
+		       reason_code);
 	}
 }
 
@@ -1882,16 +1908,20 @@ static void handle_pspoll(local_info_t *local,
 	struct sta_info *sta;
 	u16 aid;
 	struct sk_buff *skb;
-	DECLARE_MAC_BUF(mac);
 
-	PDEBUG(DEBUG_PS2, "handle_pspoll: BSSID=%s"
-	       ", TA=%s PWRMGT=%d\n",
-	       print_mac(mac, hdr->addr1), print_mac(mac, hdr->addr2),
+	PDEBUG(DEBUG_PS2, "handle_pspoll: BSSID=" MAC_FMT
+	       ", TA=" MAC_FMT " PWRMGT=%d\n",
+	       hdr->addr1[0], hdr->addr1[1], hdr->addr1[2],
+	       hdr->addr1[3], hdr->addr1[4], hdr->addr1[5],
+	       hdr->addr2[0], hdr->addr2[1], hdr->addr2[2],
+	       hdr->addr2[3], hdr->addr2[4], hdr->addr2[5],
 	       !!(le16_to_cpu(hdr->frame_ctl) & IEEE80211_FCTL_PM));
 
 	if (memcmp(hdr->addr1, dev->dev_addr, ETH_ALEN)) {
-		PDEBUG(DEBUG_AP, "handle_pspoll - addr1(BSSID)=%s"
-		       " not own MAC\n", print_mac(mac, hdr->addr1));
+		PDEBUG(DEBUG_AP, "handle_pspoll - addr1(BSSID)=" MAC_FMT
+		       " not own MAC\n",
+		       hdr->addr1[0], hdr->addr1[1], hdr->addr1[2],
+		       hdr->addr1[3], hdr->addr1[4], hdr->addr1[5]);
 		return;
 	}
 
@@ -1969,7 +1999,6 @@ static void handle_wds_oper_queue(struct work_struct *work)
 					  wds_oper_queue);
 	local_info_t *local = ap->local;
 	struct wds_oper_data *entry, *prev;
-	DECLARE_MAC_BUF(mac);
 
 	spin_lock_bh(&local->lock);
 	entry = local->ap->wds_oper_entries;
@@ -1978,10 +2007,11 @@ static void handle_wds_oper_queue(struct work_struct *work)
 
 	while (entry) {
 		PDEBUG(DEBUG_AP, "%s: %s automatic WDS connection "
-		       "to AP %s\n",
+		       "to AP " MAC_FMT "\n",
 		       local->dev->name,
 		       entry->type == WDS_ADD ? "adding" : "removing",
-		       print_mac(mac, entry->addr));
+		       entry->addr[0], entry->addr[1], entry->addr[2],
+		       entry->addr[3], entry->addr[4], entry->addr[5]);
 		if (entry->type == WDS_ADD)
 			prism2_wds_add(local, entry->addr, 0);
 		else if (entry->type == WDS_DEL)
@@ -2158,7 +2188,6 @@ static void handle_ap_item(local_info_t *local, struct sk_buff *skb,
 #endif /* PRISM2_NO_KERNEL_IEEE80211_MGMT */
 	u16 fc, type, stype;
 	struct ieee80211_hdr_4addr *hdr;
-	DECLARE_MAC_BUF(mac);
 
 	/* FIX: should give skb->len to handler functions and check that the
 	 * buffer is long enough */
@@ -2187,8 +2216,9 @@ static void handle_ap_item(local_info_t *local, struct sk_buff *skb,
 
 		if (memcmp(hdr->addr1, dev->dev_addr, ETH_ALEN)) {
 			PDEBUG(DEBUG_AP, "handle_ap_item - addr1(BSSID)="
-			       "%s not own MAC\n",
-			       print_mac(mac, hdr->addr1));
+			       MAC_FMT " not own MAC\n",
+			       hdr->addr1[0], hdr->addr1[1], hdr->addr1[2],
+			       hdr->addr1[3], hdr->addr1[4], hdr->addr1[5]);
 			goto done;
 		}
 
@@ -2224,14 +2254,18 @@ static void handle_ap_item(local_info_t *local, struct sk_buff *skb,
 	}
 
 	if (memcmp(hdr->addr1, dev->dev_addr, ETH_ALEN)) {
-		PDEBUG(DEBUG_AP, "handle_ap_item - addr1(DA)=%s"
-		       " not own MAC\n", print_mac(mac, hdr->addr1));
+		PDEBUG(DEBUG_AP, "handle_ap_item - addr1(DA)=" MAC_FMT
+		       " not own MAC\n",
+		       hdr->addr1[0], hdr->addr1[1], hdr->addr1[2],
+		       hdr->addr1[3], hdr->addr1[4], hdr->addr1[5]);
 		goto done;
 	}
 
 	if (memcmp(hdr->addr3, dev->dev_addr, ETH_ALEN)) {
-		PDEBUG(DEBUG_AP, "handle_ap_item - addr3(BSSID)=%s"
-		       " not own MAC\n", print_mac(mac, hdr->addr3));
+		PDEBUG(DEBUG_AP, "handle_ap_item - addr3(BSSID)=" MAC_FMT
+		       " not own MAC\n",
+		       hdr->addr3[0], hdr->addr3[1], hdr->addr3[2],
+		       hdr->addr3[3], hdr->addr3[4], hdr->addr3[5]);
 		goto done;
 	}
 
@@ -2312,7 +2346,6 @@ static void schedule_packet_send(local_info_t *local, struct sta_info *sta)
 	struct sk_buff *skb;
 	struct ieee80211_hdr_4addr *hdr;
 	struct hostap_80211_rx_status rx_stats;
-	DECLARE_MAC_BUF(mac);
 
 	if (skb_queue_empty(&sta->tx_buf))
 		return;
@@ -2334,7 +2367,9 @@ static void schedule_packet_send(local_info_t *local, struct sta_info *sta)
 	hdr->duration_id = cpu_to_le16(sta->aid | BIT(15) | BIT(14));
 
 	PDEBUG(DEBUG_PS2, "%s: Scheduling buffered packet delivery for STA "
-	       "%s\n", local->dev->name, print_mac(mac, sta->addr));
+	       MAC_FMT "\n", local->dev->name,
+	       sta->addr[0], sta->addr[1], sta->addr[2],
+	       sta->addr[3], sta->addr[4], sta->addr[5]);
 
 	skb->dev = local->dev;
 
@@ -2661,7 +2696,6 @@ static int ap_update_sta_tx_rate(struct sta_info *sta, struct net_device *dev)
 	int ret = sta->tx_rate;
 	struct hostap_interface *iface;
 	local_info_t *local;
-	DECLARE_MAC_BUF(mac);
 
 	iface = netdev_priv(dev);
 	local = iface->local;
@@ -2689,9 +2723,12 @@ static int ap_update_sta_tx_rate(struct sta_info *sta, struct net_device *dev)
 			case 3: sta->tx_rate = 110; break;
 			default: sta->tx_rate = 0; break;
 			}
-			PDEBUG(DEBUG_AP, "%s: STA %s"
+			PDEBUG(DEBUG_AP, "%s: STA " MAC_FMT
 			       " TX rate raised to %d\n",
-			       dev->name, print_mac(mac, sta->addr), sta->tx_rate);
+			       dev->name,
+			       sta->addr[0], sta->addr[1], sta->addr[2],
+			       sta->addr[3], sta->addr[4], sta->addr[5],
+			       sta->tx_rate);
 		}
 		sta->tx_since_last_failure = 0;
 	}
@@ -2709,7 +2746,6 @@ ap_tx_ret hostap_handle_sta_tx(local_info_t *local, struct hostap_tx_data *tx)
 	int set_tim, ret;
 	struct ieee80211_hdr_4addr *hdr;
 	struct hostap_skb_tx_data *meta;
-	DECLARE_MAC_BUF(mac);
 
 	meta = (struct hostap_skb_tx_data *) skb->cb;
 	ret = AP_TX_CONTINUE;
@@ -2745,8 +2781,9 @@ ap_tx_ret hostap_handle_sta_tx(local_info_t *local, struct hostap_tx_data *tx)
 		 * print out any errors here. */
 		if (net_ratelimit()) {
 			printk(KERN_DEBUG "AP: drop packet to non-associated "
-			       "STA %s\n",
-			       print_mac(mac, hdr->addr1));
+			       "STA " MAC_FMT "\n",
+			       hdr->addr1[0], hdr->addr1[1], hdr->addr1[2],
+			       hdr->addr1[3], hdr->addr1[4], hdr->addr1[5]);
 		}
 #endif
 		local->ap->tx_drop_nonassoc++;
@@ -2784,9 +2821,11 @@ ap_tx_ret hostap_handle_sta_tx(local_info_t *local, struct hostap_tx_data *tx)
 	}
 
 	if (skb_queue_len(&sta->tx_buf) >= STA_MAX_TX_BUFFER) {
-		PDEBUG(DEBUG_PS, "%s: No more space in STA (%s"
+		PDEBUG(DEBUG_PS, "%s: No more space in STA (" MAC_FMT
 		       ")'s PS mode buffer\n",
-		       local->dev->name, print_mac(mac, sta->addr));
+		       local->dev->name,
+		       sta->addr[0], sta->addr[1], sta->addr[2],
+		       sta->addr[3], sta->addr[4], sta->addr[5]);
 		/* Make sure that TIM is set for the station (it might not be
 		 * after AP wlan hw reset). */
 		/* FIX: should fix hw reset to restore bits based on STA
@@ -2850,7 +2889,6 @@ void hostap_handle_sta_tx_exc(local_info_t *local, struct sk_buff *skb)
 	struct sta_info *sta;
 	struct ieee80211_hdr_4addr *hdr;
 	struct hostap_skb_tx_data *meta;
-	DECLARE_MAC_BUF(mac);
 
 	hdr = (struct ieee80211_hdr_4addr *) skb->data;
 	meta = (struct hostap_skb_tx_data *) skb->cb;
@@ -2859,9 +2897,12 @@ void hostap_handle_sta_tx_exc(local_info_t *local, struct sk_buff *skb)
 	sta = ap_get_sta(local->ap, hdr->addr1);
 	if (!sta) {
 		spin_unlock(&local->ap->sta_table_lock);
-		PDEBUG(DEBUG_AP, "%s: Could not find STA %s"
+		PDEBUG(DEBUG_AP, "%s: Could not find STA " MAC_FMT
 		       " for this TX error (@%lu)\n",
-		       local->dev->name, print_mac(mac, hdr->addr1), jiffies);
+		       local->dev->name,
+		       hdr->addr1[0], hdr->addr1[1], hdr->addr1[2],
+		       hdr->addr1[3], hdr->addr1[4], hdr->addr1[5],
+		       jiffies);
 		return;
 	}
 
@@ -2888,9 +2929,11 @@ void hostap_handle_sta_tx_exc(local_info_t *local, struct sk_buff *skb)
 			case 3: sta->tx_rate = 110; break;
 			default: sta->tx_rate = 0; break;
 			}
-			PDEBUG(DEBUG_AP, "%s: STA %s"
+			PDEBUG(DEBUG_AP, "%s: STA " MAC_FMT
 			       " TX rate lowered to %d\n",
-			       local->dev->name, print_mac(mac, sta->addr),
+			       local->dev->name,
+			       sta->addr[0], sta->addr[1], sta->addr[2],
+			       sta->addr[3], sta->addr[4], sta->addr[5],
 			       sta->tx_rate);
 		}
 		sta->tx_consecutive_exc = 0;
@@ -2956,7 +2999,6 @@ ap_rx_ret hostap_handle_sta_rx(local_info_t *local, struct net_device *dev,
 	struct sta_info *sta;
 	u16 fc, type, stype;
 	struct ieee80211_hdr_4addr *hdr;
-	DECLARE_MAC_BUF(mac);
 
 	if (local->ap == NULL)
 		return AP_RX_CONTINUE;
@@ -2988,9 +3030,12 @@ ap_rx_ret hostap_handle_sta_rx(local_info_t *local, struct net_device *dev,
 			} else {
 				printk(KERN_DEBUG "%s: dropped received packet"
 				       " from non-associated STA "
-				       "%s"
+				       MAC_FMT
 				       " (type=0x%02x, subtype=0x%02x)\n",
-				       dev->name, print_mac(mac, hdr->addr2),
+				       dev->name,
+				       hdr->addr2[0], hdr->addr2[1],
+				       hdr->addr2[2], hdr->addr2[3],
+				       hdr->addr2[4], hdr->addr2[5],
 				       type >> 2, stype >> 4);
 				hostap_rx(dev, skb, rx_stats);
 #endif /* PRISM2_NO_KERNEL_IEEE80211_MGMT */
@@ -3025,8 +3070,11 @@ ap_rx_ret hostap_handle_sta_rx(local_info_t *local, struct net_device *dev,
 			 * being associated. */
 			printk(KERN_DEBUG "%s: rejected received nullfunc "
 			       "frame without ToDS from not associated STA "
-			       "%s\n",
-			       dev->name, print_mac(mac, hdr->addr2));
+			       MAC_FMT "\n",
+			       dev->name,
+			       hdr->addr2[0], hdr->addr2[1],
+			       hdr->addr2[2], hdr->addr2[3],
+			       hdr->addr2[4], hdr->addr2[5]);
 			hostap_rx(dev, skb, rx_stats);
 #endif /* PRISM2_NO_KERNEL_IEEE80211_MGMT */
 		}
@@ -3043,9 +3091,12 @@ ap_rx_ret hostap_handle_sta_rx(local_info_t *local, struct net_device *dev,
 		 * If BSSID is own, report the dropping of this frame. */
 		if (memcmp(hdr->addr3, dev->dev_addr, ETH_ALEN) == 0) {
 			printk(KERN_DEBUG "%s: dropped received packet from "
-			       "%s with no ToDS flag "
+			       MAC_FMT " with no ToDS flag "
 			       "(type=0x%02x, subtype=0x%02x)\n", dev->name,
-			       print_mac(mac, hdr->addr2), type >> 2, stype >> 4);
+			       hdr->addr2[0], hdr->addr2[1],
+			       hdr->addr2[2], hdr->addr2[3],
+			       hdr->addr2[4], hdr->addr2[5],
+			       type >> 2, stype >> 4);
 			hostap_dump_rx_80211(dev->name, skb, rx_stats);
 		}
 		ret = AP_RX_DROP;
diff --git a/drivers/net/wireless/ipw2200.c b/drivers/net/wireless/ipw2200.c
index a56d9fc..0d78e40 100644
--- a/drivers/net/wireless/ipw2200.c
+++ b/drivers/net/wireless/ipw2200.c
@@ -10192,7 +10192,6 @@ static int ipw_tx_skb(struct ipw_priv *priv, struct ieee80211_txb *txb,
 	u8 id, hdr_len, unicast;
 	u16 remaining_bytes;
 	int fc;
-	DECLARE_MAC_BUF(mac);
 
 	hdr_len = ieee80211_get_hdrlen(le16_to_cpu(hdr->frame_ctl));
 	switch (priv->ieee->iw_mode) {
@@ -10203,8 +10202,10 @@ static int ipw_tx_skb(struct ipw_priv *priv, struct ieee80211_txb *txb,
 			id = ipw_add_station(priv, hdr->addr1);
 			if (id == IPW_INVALID_STATION) {
 				IPW_WARNING("Attempt to send data to "
-					    "invalid cell: %s\n",
-					    print_mac(mac, hdr->addr1));
+					    "invalid cell: " MAC_FMT "\n",
+					    hdr->addr1[0], hdr->addr1[1],
+					    hdr->addr1[2], hdr->addr1[3],
+					    hdr->addr1[4], hdr->addr1[5]);
 				goto drop;
 			}
 		}
diff --git a/net/atm/lec.c b/net/atm/lec.c
index a2efa7f..3235c57 100644
--- a/net/atm/lec.c
+++ b/net/atm/lec.c
@@ -266,7 +266,6 @@ static int lec_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	char buf[300];
 	int i = 0;
 #endif /* DUMP_PACKETS >0 */
-	DECLARE_MAC_BUF(mac);
 
 	pr_debug("lec_start_xmit called\n");
 	if (!priv->lecd) {
@@ -374,15 +373,19 @@ static int lec_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		if (entry && (entry->tx_wait.qlen < LEC_UNRES_QUE_LEN)) {
 			pr_debug("%s:lec_start_xmit: queuing packet, ",
 				dev->name);
-			pr_debug("MAC address %s\n",
-				 print_mac(mac, lec_h->h_dest));
+			pr_debug("MAC address " MAC_FMT "\n",
+				 lec_h->h_dest[0], lec_h->h_dest[1],
+				 lec_h->h_dest[2], lec_h->h_dest[3],
+				 lec_h->h_dest[4], lec_h->h_dest[5]);
 			skb_queue_tail(&entry->tx_wait, skb);
 		} else {
 			pr_debug
 			    ("%s:lec_start_xmit: tx queue full or no arp entry, dropping, ",
 			     dev->name);
-			pr_debug("MAC address %s\n",
-				 print_mac(mac, lec_h->h_dest));
+			pr_debug("MAC address " MAC_FMT "\n",
+				 lec_h->h_dest[0], lec_h->h_dest[1],
+				 lec_h->h_dest[2], lec_h->h_dest[3],
+				 lec_h->h_dest[4], lec_h->h_dest[5]);
 			priv->stats.tx_dropped++;
 			dev_kfree_skb(skb);
 		}
@@ -394,8 +397,10 @@ static int lec_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	while (entry && (skb2 = skb_dequeue(&entry->tx_wait))) {
 		pr_debug("lec.c: emptying tx queue, ");
-		pr_debug("MAC address %s\n",
-			 print_mac(mac, lec_h->h_dest));
+		pr_debug("MAC address " MAC_FMT "\n",
+			 lec_h->h_dest[0], lec_h->h_dest[1],
+			 lec_h->h_dest[2], lec_h->h_dest[3],
+			 lec_h->h_dest[4], lec_h->h_dest[5]);
 		lec_send(vcc, skb2, priv);
 	}
 
@@ -449,7 +454,6 @@ static int lec_atm_send(struct atm_vcc *vcc, struct sk_buff *skb)
 	struct lec_arp_table *entry;
 	int i;
 	char *tmp;		/* FIXME */
-	DECLARE_MAC_BUF(mac);
 
 	atomic_sub(skb->truesize, &sk_atm(vcc)->sk_wmem_alloc);
 	mesg = (struct atmlec_msg *)skb->data;
@@ -536,9 +540,14 @@ static int lec_atm_send(struct atm_vcc *vcc, struct sk_buff *skb)
 			struct net_bridge_fdb_entry *f;
 
 			pr_debug
-			    ("%s: bridge zeppelin asks about %s\n",
+			    ("%s: bridge zeppelin asks about " MAC_FMT "\n",
 			     dev->name,
-			     print_mac(mac, mesg->content.proxy.mac_addr));
+			     mesg->content.proxy.mac_addr[0],
+			     mesg->content.proxy.mac_addr[1],
+			     mesg->content.proxy.mac_addr[2],
+			     mesg->content.proxy.mac_addr[3],
+			     mesg->content.proxy.mac_addr[4],
+			     mesg->content.proxy.mac_addr[5]);
 
 			if (br_fdb_get_hook == NULL || dev->br_port == NULL)
 				break;
diff --git a/net/ieee80211/ieee80211_rx.c b/net/ieee80211/ieee80211_rx.c
index 1e3f87c..200ee1e 100644
--- a/net/ieee80211/ieee80211_rx.c
+++ b/net/ieee80211/ieee80211_rx.c
@@ -271,7 +271,6 @@ ieee80211_rx_frame_decrypt(struct ieee80211_device *ieee, struct sk_buff *skb,
 {
 	struct ieee80211_hdr_3addr *hdr;
 	int res, hdrlen;
-	DECLARE_MAC_BUF(mac);
 
 	if (crypt == NULL || crypt->ops->decrypt_mpdu == NULL)
 		return 0;
@@ -283,8 +282,12 @@ ieee80211_rx_frame_decrypt(struct ieee80211_device *ieee, struct sk_buff *skb,
 	res = crypt->ops->decrypt_mpdu(skb, hdrlen, crypt->priv);
 	atomic_dec(&crypt->refcnt);
 	if (res < 0) {
-		IEEE80211_DEBUG_DROP("decryption failed (SA=%s"
-				     ") res=%d\n", print_mac(mac, hdr->addr2), res);
+		IEEE80211_DEBUG_DROP("decryption failed (SA=" MAC_FMT
+				     ") res=%d\n",
+				     hdr->addr2[0], hdr->addr2[1],
+				     hdr->addr2[2], hdr->addr2[3],
+				     hdr->addr2[4], hdr->addr2[5],
+				     res);
 		if (res == -2)
 			IEEE80211_DEBUG_DROP("Decryption failed ICV "
 					     "mismatch (key %d)\n",
@@ -304,7 +307,6 @@ ieee80211_rx_frame_decrypt_msdu(struct ieee80211_device *ieee,
 {
 	struct ieee80211_hdr_3addr *hdr;
 	int res, hdrlen;
-	DECLARE_MAC_BUF(mac);
 
 	if (crypt == NULL || crypt->ops->decrypt_msdu == NULL)
 		return 0;
@@ -317,8 +319,12 @@ ieee80211_rx_frame_decrypt_msdu(struct ieee80211_device *ieee,
 	atomic_dec(&crypt->refcnt);
 	if (res < 0) {
 		printk(KERN_DEBUG "%s: MSDU decryption/MIC verification failed"
-		       " (SA=%s keyidx=%d)\n",
-		       ieee->dev->name, print_mac(mac, hdr->addr2), keyidx);
+		       " (SA=" MAC_FMT " keyidx=%d)\n",
+		       ieee->dev->name,
+		       hdr->addr2[0], hdr->addr2[1],
+		       hdr->addr2[2], hdr->addr2[3],
+		       hdr->addr2[4], hdr->addr2[5],
+		       keyidx);
 		return -1;
 	}
 
@@ -462,8 +468,10 @@ int ieee80211_rx(struct ieee80211_device *ieee, struct sk_buff *skb,
 			 * frames silently instead of filling system log with
 			 * these reports. */
 			IEEE80211_DEBUG_DROP("Decryption failed (not set)"
-					     " (SA=%s)\n",
-					     print_mac(mac, hdr->addr2));
+					     " (SA=" MAC_FMT ")\n",
+					     hdr->addr2[0], hdr->addr2[1],
+					     hdr->addr2[2], hdr->addr2[3],
+					     hdr->addr2[4], hdr->addr2[5]);
 			ieee->ieee_stats.rx_discards_undecryptable++;
 			goto rx_dropped;
 		}
@@ -474,8 +482,10 @@ int ieee80211_rx(struct ieee80211_device *ieee, struct sk_buff *skb,
 		    fc & IEEE80211_FCTL_PROTECTED && ieee->host_decrypt &&
 		    (keyidx = hostap_rx_frame_decrypt(ieee, skb, crypt)) < 0) {
 			printk(KERN_DEBUG "%s: failed to decrypt mgmt::auth "
-			       "from %s\n", dev->name,
-			       print_mac(mac, hdr->addr2));
+			       "from " MAC_FMT "\n", dev->name,
+			       hdr->addr2[0], hdr->addr2[1],
+			       hdr->addr2[2], hdr->addr2[3],
+			       hdr->addr2[4], hdr->addr2[5]);
 			/* TODO: could inform hostapd about this so that it
 			 * could send auth failure report */
 			goto rx_dropped;
@@ -653,8 +663,11 @@ int ieee80211_rx(struct ieee80211_device *ieee, struct sk_buff *skb,
 			 * configured */
 		} else {
 			IEEE80211_DEBUG_DROP("encryption configured, but RX "
-					     "frame not encrypted (SA=%s"
-					     ")\n", print_mac(mac, hdr->addr2));
+					     "frame not encrypted (SA="
+					     MAC_FMT ")\n",
+					     hdr->addr2[0], hdr->addr2[1],
+					     hdr->addr2[2], hdr->addr2[3],
+					     hdr->addr2[4], hdr->addr2[5]);
 			goto rx_dropped;
 		}
 	}
@@ -662,9 +675,11 @@ int ieee80211_rx(struct ieee80211_device *ieee, struct sk_buff *skb,
 	if (crypt && !(fc & IEEE80211_FCTL_PROTECTED) && !ieee->open_wep &&
 	    !ieee80211_is_eapol_frame(ieee, skb)) {
 		IEEE80211_DEBUG_DROP("dropped unencrypted RX data "
-				     "frame from %s"
+				     "frame from " MAC_FMT
 				     " (drop_unencrypted=1)\n",
-				     print_mac(mac, hdr->addr2));
+				     hdr->addr2[0], hdr->addr2[1],
+				     hdr->addr2[2], hdr->addr2[3],
+				     hdr->addr2[4], hdr->addr2[5]);
 		goto rx_dropped;
 	}
 
