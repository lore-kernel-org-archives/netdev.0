From: "Ivo Van Doorn" <ivdoorn@gmail.com>
Subject: Re: [PATCH] d80211: Fix inconsistent sta_lock usage
Date: Sat, 6 Jan 2007 20:09:36 +0100
Message-ID: <a32f33a40701061109o39a55f4fmdd1d252b1f2f2784@mail.gmail.com>
References: <45996CBA.8020307@web.de>
	 <a32f33a40701020730n773d7ed8pe99d98ecc7b96a0e@mail.gmail.com>
	 <20070102162201.GA28457@infradead.org>
	 <200701052108.40185.IvDoorn@gmail.com>
	 <1168102377.5207.59.camel@johannes.berg> <459FD5B5.2050706@web.de>
	 <1168102881.5207.63.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Jan Kiszka" <jan.kiszka@web.de>, "Jiri Benc" <jbenc@suse.cz>,
	"Christoph Hellwig" <hch@infradead.org>, netdev@vger.kernel.org,
	rt2400-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:57273 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932089AbXAFTJi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Jan 2007 14:09:38 -0500
Received: by ug-out-1314.google.com with SMTP id 44so5945516uga
        for <netdev@vger.kernel.org>; Sat, 06 Jan 2007 11:09:37 -0800 (PST)
To: "Johannes Berg" <johannes@sipsolutions.net>
In-Reply-To: <1168102881.5207.63.camel@johannes.berg>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > Bit ordering, I see. Then go for my original patch + comments why this
> > is open-coded in __bss_tim_set/clear + removed unused arguments from
> > those functions, OK?
>
> Sounds good to me, care to send a new patch?

This patch returns to the original format for setting and clearing the tim bit,
as the IEEE specs mandate. (Comment has been added to prevent future
attempts to use the __set_bit and __clear_bit)
And the local argument has been removed.

Signed-off-by Jan Kiszka <jan.kiszka@web.de>
Signed-off-by Ivo van Doorn <IvDoorn@gmail.com>

---

diff --git a/net/d80211/ieee80211_i.h b/net/d80211/ieee80211_i.h
index ef303da..64d881c 100644
--- a/net/d80211/ieee80211_i.h
+++ b/net/d80211/ieee80211_i.h
@@ -558,20 +558,38 @@ struct sta_attribute {
 	ssize_t (*store)(struct sta_info *, const char *buf, size_t count);
 };

+static inline void __bss_tim_set(struct ieee80211_if_ap *bss, int aid)
+{
+	/*
+	 * This format has ben mandated by the IEEE specifications,
+	 * so this line may not be changed to use the __set_bit() format.
+	 */
+	bss->tim[(aid)/8] |= 1<<((aid) % 8);
+}
+
 static inline void bss_tim_set(struct ieee80211_local *local,
 			       struct ieee80211_if_ap *bss, int aid)
 {
-	spin_lock(&local->sta_lock);
-	bss->tim[(aid)/8] |= 1<<((aid) % 8);
-	spin_unlock(&local->sta_lock);
+	spin_lock_bh(&local->sta_lock);
+	__bss_tim_set(bss, aid);
+	spin_unlock_bh(&local->sta_lock);
+}
+
+static inline void __bss_tim_clear(struct ieee80211_if_ap *bss, int aid)
+{
+	/*
+	 * This format has ben mandated by the IEEE specifications,
+	 * so this line may not be changed to use the __clear_bit() format.
+	 */
+	bss->tim[(aid)/8] &= !(1<<((aid) % 8));
 }

 static inline void bss_tim_clear(struct ieee80211_local *local,
 				 struct ieee80211_if_ap *bss, int aid)
 {
-	spin_lock(&local->sta_lock);
-	bss->tim[(aid)/8] &= !(1<<((aid) % 8));
-	spin_unlock(&local->sta_lock);
+	spin_lock_bh(&local->sta_lock);
+	__bss_tim_clear(bss, aid);
+	spin_unlock_bh(&local->sta_lock);
 }

 /* ieee80211.c */
diff --git a/net/d80211/ieee80211_ioctl.c b/net/d80211/ieee80211_ioctl.c
index c74b431..1363a01 100644
--- a/net/d80211/ieee80211_ioctl.c
+++ b/net/d80211/ieee80211_ioctl.c
@@ -285,7 +285,9 @@ static int ieee80211_ioctl_add_sta(struct net_device *dev,
 	if (sta->dev != dev) {
 		/* Binding STA to a new interface, so remove all references to
 		 * the old BSS. */
+		spin_lock_bh(&local->sta_lock);
 		sta_info_remove_aid_ptr(sta);
+		spin_unlock_bh(&local->sta_lock);
 	}

         /* TODO
@@ -359,7 +361,7 @@ static int ieee80211_ioctl_remove_sta(struct
net_device *dev,
 	sta = sta_info_get(local, param->sta_addr);
 	if (sta) {
 		sta_info_put(sta);
-		sta_info_free(sta, 1);
+		sta_info_free(sta, 0);
 	}

 	return sta ? 0 : -ENOENT;
diff --git a/net/d80211/sta_info.c b/net/d80211/sta_info.c
index 0c42ae8..f27bd0e 100644
--- a/net/d80211/sta_info.c
+++ b/net/d80211/sta_info.c
@@ -439,7 +439,7 @@ void sta_info_remove_aid_ptr(struct sta_info *sta)
 		sdata->local->ops->set_tim(local_to_hw(sdata->local),
 					  sta->aid, 0);
 	if (sdata->bss)
-		bss_tim_clear(sdata->local, sdata->bss, sta->aid);
+		__bss_tim_clear(sdata->bss, sta->aid);
 }
