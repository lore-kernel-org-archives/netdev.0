From: Jiri Benc <jbenc@suse.cz>
Subject: [5/5] ieee80211: add sequence numbers
Date: Tue, 24 May 2005 15:13:41 +0200
Message-ID: <20050524151341.612245e8@griffin.suse.cz>
References: <20050524150711.01632672@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>, jgarzik@pobox.com, pavel@suse.cz
Return-path: <netdev-bounce@oss.sgi.com>
To: NetDev <netdev@oss.sgi.com>
In-Reply-To: <20050524150711.01632672@griffin.suse.cz>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Adds sequence numbers to IEEE 802.11 headers.


Signed-off-by: Jiri Benc <jbenc@suse.cz>
Signed-off-by: Jirka Bohac <jbohac@suse.cz>

--- a/include/net/ieee80211.h
+++ b/include/net/ieee80211.h
@@ -711,6 +711,8 @@
 	unsigned int frag_next_idx;
 	u16 fts; /* Fragmentation Threshold */
 
+	u16 seq_number;	/* sequence number in transmitted frames */
+
 	/* Association info */
 	u8 bssid[IEEE80211_ALEN];
 
--- a/net/ieee80211/ieee80211_module.c
+++ b/net/ieee80211/ieee80211_module.c
@@ -333,6 +333,7 @@
 
 	/* Default fragmentation threshold is maximum payload size */
 	ieee->fts = DEFAULT_FTS;
+	ieee->seq_number = 0;
 	ieee->scan_age = DEFAULT_MAX_SCAN_AGE;
 	ieee->open_wep = 1;
 
--- a/net/ieee80211/ieee80211_tx.c
+++ b/net/ieee80211/ieee80211_tx.c
@@ -277,6 +277,13 @@
 	else
 		bytes_last_frag = bytes_per_frag;
 
+	if (nr_frags > 16) {
+		/* Should never happen */
+		printk(KERN_WARNING "%s: Fragmentation threshold too low\n",
+			dev->name);
+		goto failed;
+	}
+
 	/* When we allocate the TXB we allocate enough space for the reserve
 	 * and full fragment bytes (bytes_per_frag doesn't include prefix,
 	 * postfix, header, FCS, etc.) */
@@ -300,6 +307,8 @@
 		frag_hdr = (struct ieee80211_hdr *)skb_put(skb_frag, hdr_len);
 		memcpy(frag_hdr, header, hdr_len);
 
+		frag_hdr->seq_ctl = cpu_to_le16(ieee->seq_number | i);
+
 		/* If this is not the last fragment, then add the MOREFRAGS
 		 * bit to the frame control */
 		if (i != nr_frags - 1) {
@@ -324,7 +333,7 @@
 		    (CFG_IEEE80211_COMPUTE_FCS | CFG_IEEE80211_RESERVE_FCS))
 			skb_put(skb_frag, 4);
 	}
-
+	ieee->seq_number += 0x10;
 
  success:
 	spin_unlock_irqrestore(&ieee->lock, flags);


--
Jiri Benc
SUSE Labs
