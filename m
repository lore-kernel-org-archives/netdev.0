From: Brandon Craig Rhodes <brandon@rhodesmill.org>
Subject: TKIP encryption should allocate enough tailroom
Date: Tue, 16 Jan 2007 21:31:40 -0500
Message-ID: <87bqky759v.fsf@ten22.rhodesmill.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-23-211-138.clients.speedfactory.net ([66.23.211.138]:52253
	"EHLO ten22.rhodesmill.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751156AbXAQCxQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jan 2007 21:53:16 -0500
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--=-=-=

After frustrating days of hung TCP connections, I have determined that
the encryption routines in net/iee80211/ieee80211_crypt_tkip.c should
be more aggressive in providing themselves with enough packet tailroom
to perform their encryption.

They presently will only perform encryption if the packet handed to
them happens to be stored with enough tailroom already; otherwise,
they drop the packet.  If ieee80211_michael_mic_add() does not find
the eight bytes of tailroom it needs, it produces a message like

 kernel: Invalid packet for Michael MIC add (tailroom=6 hdr_len=24 skb->len=92)

and drops the packet.  The ieee80211_tkip_encrypt() function that
follows is less needy, requiring only four bytes of tailroom - but
fails to log anything at all when it drops a packet!

The attached patch, if applied to kernel 2.6.18, solves both problems.
I am not very familiar with the conventions of kernel networking code,
so there may be better ways of fixing this; but the patch should
illustrate the general idea, and perhaps provides others in my unhappy
situation with stable WPA connections until someone can provide a more
authorized patch.

And thanks for all the great code, guys; this is the first problem I
have had with the networking stack in eleven years of using Linux.


--=-=-=
Content-Type: text/x-diff
Content-Disposition: inline; filename=ieee80211-tkip-tailroom.patch

--- net/ieee80211/ieee80211_crypt_tkip.c.orig	2007-01-10 10:20:40.000000000 -0500
+++ net/ieee80211/ieee80211_crypt_tkip.c	2007-01-16 21:21:51.000000000 -0500
@@ -334,9 +334,19 @@
 		return -1;
 	}
 
-	if (skb_tailroom(skb) < 4 || skb->len < hdr_len)
+	if (skb->len < hdr_len)
 		return -1;
 
+	if (skb_tailroom(skb) < 4) {
+		int err;
+		err = skb_padto(skb, skb->len + 4);
+		if (unlikely(err || skb_tailroom(skb) < 4)) {
+			printk(KERN_DEBUG "Failed to increase tailroom"
+			       " for TKIP encrypt");
+			return err || -1;
+		}
+	}
+
 	len = skb->len - hdr_len;
 	pos = skb->data + hdr_len;
 
@@ -541,13 +551,24 @@
 	struct ieee80211_tkip_data *tkey = priv;
 	u8 *pos;
 
-	if (skb_tailroom(skb) < 8 || skb->len < hdr_len) {
+	if (skb->len < hdr_len) {
 		printk(KERN_DEBUG "Invalid packet for Michael MIC add "
 		       "(tailroom=%d hdr_len=%d skb->len=%d)\n",
 		       skb_tailroom(skb), hdr_len, skb->len);
 		return -1;
 	}
 
+	/* 8 bytes needed here, and 4 for ieee80211_tkip_encrypt() */
+	if (skb_tailroom(skb) < 12) {
+		int err;
+		err = skb_padto(skb, skb->len + 12);
+		if (unlikely(err || skb_tailroom(skb) < 12)) {
+			printk(KERN_DEBUG "Failed to increase tailroom"
+			       " for Michael MIC add");
+			return err || -1;
+		}
+	}
+
 	michael_mic_hdr(skb, tkey->tx_hdr);
 	pos = skb_put(skb, 8);
 	if (michael_mic(tkey, &tkey->key[16], tkey->tx_hdr,

--=-=-=


-- 
Brandon Craig Rhodes   brandon@rhodesmill.org   http://rhodesmill.org/brandon

--=-=-=--
