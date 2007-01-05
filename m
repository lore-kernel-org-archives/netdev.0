From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [PATCH] d80211: Fix inconsistent sta_lock usage
Date: Fri, 5 Jan 2007 21:08:39 +0100
Message-ID: <200701052108.40185.IvDoorn@gmail.com>
References: <45996CBA.8020307@web.de> <a32f33a40701020730n773d7ed8pe99d98ecc7b96a0e@mail.gmail.com> <20070102162201.GA28457@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jan Kiszka <jan.kiszka@web.de>,
	Christoph Hellwig <hch@infradead.org>, netdev@vger.kernel.org,
	rt2400-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:26764 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750708AbXAEUJO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jan 2007 15:09:14 -0500
Received: by ug-out-1314.google.com with SMTP id 44so5794826uga
        for <netdev@vger.kernel.org>; Fri, 05 Jan 2007 12:09:13 -0800 (PST)
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20070102162201.GA28457@infradead.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 02 January 2007 17:22, Christoph Hellwig wrote:
> On Tue, Jan 02, 2007 at 04:30:41PM +0100, Ivo Van Doorn wrote:
> > +static inline void __bss_tim_set(struct ieee80211_local *local,
> > +				 struct ieee80211_if_ap *bss, int aid)
> > +{
> > +	bss->tim[(aid)/8] |= 1<<((aid) % 8);
> > +}
> 
> This really screams to be converted to __set_bit.  Also the local
> argument is entirely unused.  I'd probaby not even add a helper for
> this but just opencode it as:
> 
> 	__set_bit(&bss->time, aid);
> 
> > +static inline void __bss_tim_clear(struct ieee80211_local *local,
> > +				   struct ieee80211_if_ap *bss, int aid)
> > +{
> > +	bss->tim[(aid)/8] &= !(1<<((aid) % 8));
> 
> Similarly this should just be __clear_bit

This patch uses the __set_bit and __clear_but as suggested by Christoph.
It also removes the local argument since it was unused.

Signed-off-by: Jan Kiszka <jan.kiszka@web.de>
Signed-off-by Ivo van Doorn <IvDoorn@gmail.com>

---

diff --git a/net/d80211/ieee80211_i.h b/net/d80211/ieee80211_i.h
index 6ba6a61..c5c04d2 100644
--- a/net/d80211/ieee80211_i.h
+++ b/net/d80211/ieee80211_i.h
@@ -560,19 +560,23 @@ struct sta_attribute {
 	ssize_t (*store)(struct sta_info *, const char *buf, size_t count);
 };
 
+#define __bss_tim_set(__bss, __aid)	__set_bit((__aid), &(__bss)->tim)
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
 }
 
+#define __bss_tim_clear(__bss, __aid)	__clear_bit((__aid), &(__bss)->tim)
+
 static inline void bss_tim_clear(struct ieee80211_local *local,
 				 struct ieee80211_if_ap *bss, int aid)
 {
 	spin_lock(&local->sta_lock);
-	bss->tim[(aid)/8] &= !(1<<((aid) % 8));
+	__bss_tim_clear(bss, aid);
 	spin_unlock(&local->sta_lock);
 }
 
diff --git a/net/d80211/ieee80211_ioctl.c b/net/d80211/ieee80211_ioctl.c
index 81a6e82..5a21b2d 100644
--- a/net/d80211/ieee80211_ioctl.c
+++ b/net/d80211/ieee80211_ioctl.c
@@ -286,7 +286,9 @@ static int ieee80211_ioctl_add_sta(struct net_device *dev,
 	if (sta->dev != dev) {
 		/* Binding STA to a new interface, so remove all references to
 		 * the old BSS. */
+		spin_lock_bh(&local->sta_lock);
 		sta_info_remove_aid_ptr(sta);
+		spin_unlock_bh(&local->sta_lock);
 	}
 
         /* TODO
@@ -360,7 +362,7 @@ static int ieee80211_ioctl_remove_sta(struct net_device *dev,
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
 
 
