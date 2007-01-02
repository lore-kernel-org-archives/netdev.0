From: "Ivo Van Doorn" <ivdoorn@gmail.com>
Subject: Re: [PATCH] d80211: Fix inconsistent sta_lock usage
Date: Tue, 2 Jan 2007 16:30:41 +0100
Message-ID: <a32f33a40701020730n773d7ed8pe99d98ecc7b96a0e@mail.gmail.com>
References: <45996CBA.8020307@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Jiri Benc" <jbenc@suse.cz>, netdev@vger.kernel.org,
	rt2400-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.225]:51396 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752789AbXABPam (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jan 2007 10:30:42 -0500
Received: by wr-out-0506.google.com with SMTP id 68so463940wri
        for <netdev@vger.kernel.org>; Tue, 02 Jan 2007 07:30:41 -0800 (PST)
To: "Jan Kiszka" <jan.kiszka@web.de>
In-Reply-To: <45996CBA.8020307@web.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/1/07, Jan Kiszka <jan.kiszka@web.de> wrote:
> Hacking a bit on rt2x00 to make it work in master and ad-hoc mode, lockdep
> popped up on some hostapd ioctls, pointing out remaining inconsistencies
> related to sta_lock:
>
> 1. sta_lock holders must always be protected against softirq
> 2. bss_tim_set/clear must not be called with sta_lock held, rather an
>    unprotected variant
> 3. ieee80211_ioctl_remove_sta is not already holding the lock when calling
>    sta_info_free
>
> As I was not sure if sta_info_remove_aid_ptr needs lock protection or
> not, I played safe and moved it always under the lock. Please correct me
> if this is overkill.
>
> Signed-off-by: Jan Kiszka <jan.kiszka@web.de>
>
> [Sorry, patch is against rt2x00 CVS. I'm lacking time and bandwidth to pull
> the d80211 git repos and rebase.]

To make it easier for everybody, here is the same patch
only this time applied to the dscape git tree. ;)

Signed-off-by: Jan Kiszka <jan.kiszka@web.de>
Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

---

diff --git a/net/d80211/ieee80211_i.h b/net/d80211/ieee80211_i.h
index ef303da..b132ae0 100644
--- a/net/d80211/ieee80211_i.h
+++ b/net/d80211/ieee80211_i.h
@@ -558,20 +558,32 @@ struct sta_attribute {
 	ssize_t (*store)(struct sta_info *, const char *buf, size_t count);
 };

+static inline void __bss_tim_set(struct ieee80211_local *local,
+				 struct ieee80211_if_ap *bss, int aid)
+{
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
+	__bss_tim_set(local, bss, aid);
+	spin_unlock_bh(&local->sta_lock);
+}
+
+static inline void __bss_tim_clear(struct ieee80211_local *local,
+				   struct ieee80211_if_ap *bss, int aid)
+{
+	bss->tim[(aid)/8] &= !(1<<((aid) % 8));
 }

 static inline void bss_tim_clear(struct ieee80211_local *local,
 				 struct ieee80211_if_ap *bss, int aid)
 {
-	spin_lock(&local->sta_lock);
-	bss->tim[(aid)/8] &= !(1<<((aid) % 8));
-	spin_unlock(&local->sta_lock);
+	spin_lock_bh(&local->sta_lock);
+	__bss_tim_clear(local, bss, aid);
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
index 0c42ae8..e120a4f 100644
--- a/net/d80211/sta_info.c
+++ b/net/d80211/sta_info.c
@@ -439,7 +439,7 @@ void sta_info_remove_aid_ptr(struct sta_info *sta)
 		sdata->local->ops->set_tim(local_to_hw(sdata->local),
 					  sta->aid, 0);
 	if (sdata->bss)
-		bss_tim_clear(sdata->local, sdata->bss, sta->aid);
+		__bss_tim_clear(sdata->local, sdata->bss, sta->aid);
 }
