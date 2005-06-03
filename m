From: Jiri Benc <jbenc@suse.cz>
Subject: [8/9] ieee80211: add sequence numbers
Date: Fri, 3 Jun 2005 18:36:17 +0200
Message-ID: <20050603183617.7903c5a0@griffin.suse.cz>
References: <20050603182625.64d33be3@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, Jirka Bohac <jbohac@suse.cz>
Return-path: <netdev-bounce@oss.sgi.com>
To: NetDev <netdev@oss.sgi.com>
In-Reply-To: <20050603182625.64d33be3@griffin.suse.cz>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Adds sequence numbers to IEEE 802.11 headers.


Signed-off-by: Jiri Benc <jbenc@suse.cz>
Signed-off-by: Jirka Bohac <jbohac@suse.cz>

Index: netdev/include/net/ieee80211.h
===================================================================
--- netdev.orig/include/net/ieee80211.h	2005-06-03 13:21:00.000000000 +0200
+++ netdev/include/net/ieee80211.h	2005-06-03 13:21:06.000000000 +0200
@@ -711,6 +711,8 @@
 	unsigned int frag_next_idx;
 	u16 fts; /* Fragmentation Threshold */
 
+	u16 seq_number;	/* sequence number in transmitted frames */
+
 	/* Association info */
 	u8 bssid[IEEE80211_ALEN];
 
Index: netdev/net/ieee80211/ieee80211_module.c
===================================================================
--- netdev.orig/net/ieee80211/ieee80211_module.c	2005-06-03 13:21:00.000000000 +0200
+++ netdev/net/ieee80211/ieee80211_module.c	2005-06-03 13:21:06.000000000 +0200
@@ -128,6 +128,7 @@
 
 	/* Default fragmentation threshold is maximum payload size */
 	ieee->fts = DEFAULT_FTS;
+	ieee->seq_number = 0;
 	ieee->scan_age = DEFAULT_MAX_SCAN_AGE;
 	ieee->open_wep = 1;
 
Index: netdev/net/ieee80211/ieee80211_tx.c
===================================================================
--- netdev.orig/net/ieee80211/ieee80211_tx.c	2005-06-03 13:21:00.000000000 +0200
+++ netdev/net/ieee80211/ieee80211_tx.c	2005-06-03 13:21:06.000000000 +0200
@@ -276,6 +276,13 @@
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
@@ -299,6 +306,8 @@
 		frag_hdr = (struct ieee80211_hdr *)skb_put(skb_frag, hdr_len);
 		memcpy(frag_hdr, header, hdr_len);
 
+		frag_hdr->seq_ctl = cpu_to_le16(ieee->seq_number | i);
+
 		/* If this is not the last fragment, then add the MOREFRAGS
 		 * bit to the frame control */
 		if (i != nr_frags - 1) {
@@ -323,7 +332,7 @@
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
