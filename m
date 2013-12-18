From: Joe Perches <joe@perches.com>
Subject: ieee80211_i.h: shouldn't struct ps_data.tim be aligned unsigned
 long?
Date: Wed, 18 Dec 2013 00:16:04 -0800
Message-ID: <1387354564.13593.26.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Jiri Benc <jbenc@redhat.com>,
	Johannes Berg <johannes.berg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0212.hostedemail.com ([216.40.44.212]:60691 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751196Ab3LRIQH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 03:16:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

about
net/mac80211/tx.c:              have_bits = !bitmap_empty((unsigned long*)ps->tim,
and
net/mac80211/ieee80211_i.h
d012a6051 (Marco Porsch        2012-10-10 12:39:50 -0700 244) struct ps_data {
f0706e828 (Jiri Benc           2007-05-05 11:45:53 -0700 245)   /* yes, this looks ugly, but guarantees that we can later use
f0706e828 (Jiri Benc           2007-05-05 11:45:53 -0700 246)    * bitmap_empty :)
004c872e7 (Johannes Berg       2008-02-20 11:21:35 +0100 247)    * NB: don't touch this bitmap, use sta_info_{set,clear}_tim_bit */
f0706e828 (Jiri Benc           2007-05-05 11:45:53 -0700 248)   u8 tim[sizeof(unsigned long) * BITS_TO_LONGS(IEEE80211_MAX_AID + 1)];
d012a6051 (Marco Porsch        2012-10-10 12:39:50 -0700 249)   struct sk_buff_head bc_buf;
056cdd599 (Johannes Berg       2008-03-26 23:21:47 +0100 250)   atomic_t num_sta_ps; /* number of stations in PS mode */
5dfdaf58d (Johannes Berg       2007-12-19 02:03:33 +0100 251)   int dtim_count;
512119b36 (Christian Lamparter 2011-01-31 20:48:44 +0200 252)   bool dtim_bc_mc;
f0706e828 (Jiri Benc           2007-05-05 11:45:53 -0700 253) };

Perhaps the
	u8 tim[sizeof...]
member should be marked
	__aligned(sizeof(unsigned long))
so that the cast to ulong when bitmap_empty
is actually forced to be ulong aligned?

Perhaps the "guarantee" isn't valid without it.

---

 net/mac80211/ieee80211_i.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index ed5bf8b..e5a9c51 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -245,7 +245,8 @@ struct ps_data {
 	/* yes, this looks ugly, but guarantees that we can later use
 	 * bitmap_empty :)
 	 * NB: don't touch this bitmap, use sta_info_{set,clear}_tim_bit */
-	u8 tim[sizeof(unsigned long) * BITS_TO_LONGS(IEEE80211_MAX_AID + 1)];
+	u8 tim[sizeof(unsigned long) * BITS_TO_LONGS(IEEE80211_MAX_AID + 1)]
+			__aligned(sizeof(unsigned long));
 	struct sk_buff_head bc_buf;
 	atomic_t num_sta_ps; /* number of stations in PS mode */
 	int dtim_count;
