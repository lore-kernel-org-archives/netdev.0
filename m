From: Hong Liu <hong.liu@intel.com>
Subject: Re: [PATCH]d80211: fix "iwconfig key [x]" behavior
Date: Fri, 01 Sep 2006 11:37:57 +0800
Message-ID: <1157081877.11040.44.camel@devlinux-hong>
References: <1156754199.6061.3.camel@devlinux-hong>
	 <20060830192452.6ae099d5@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:12399 "EHLO
	orsmga101-1.jf.intel.com") by vger.kernel.org with ESMTP
	id S1751078AbWIADmQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Aug 2006 23:42:16 -0400
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20060830192452.6ae099d5@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-08-31 at 01:24, Jiri Benc wrote:
> On Mon, 28 Aug 2006 16:36:39 +0800, Hong Liu wrote:
> > "iwconfig key [x]" behavior is not correctly handled in the stack, also
> > modify the giwencode method to show the key info.
> 
> Thanks for spotting and fixing these bugs!
> 
> > @@ -2869,7 +2877,8 @@ static int ieee80211_ioctl_giwencode(str
> >               return 0;
> >       }
> > 
> > -     erq->length = 0;
> > +     erq->length = sdata->keys[idx]->keylen;
> > +     memcpy(key, sdata->keys[idx]->key, erq->length);
> 
> Shouldn't there be a check for buffer size here?
> 
> Thanks,
> 
>  Jiri
> 
> --
> Jiri Benc
> SUSE Labs
> 
> 

Signed-off-by: Hong Liu <hong.liu@intel.com>

diff --git a/net/d80211/ieee80211_ioctl.c b/net/d80211/ieee80211_ioctl.c
index 89a58e3..c9a3524 100644
--- a/net/d80211/ieee80211_ioctl.c
+++ b/net/d80211/ieee80211_ioctl.c
@@ -2867,9 +2867,10 @@ static int ieee80211_ioctl_siwencode(str
 		if (!sdata->default_key)
 			idx = 0;
 		else for (i = 0; i < NUM_DEFAULT_KEYS; i++) {
-			if (sdata->default_key == sdata->keys[i])
+			if (sdata->default_key == sdata->keys[i]) {
 				idx = i;
-			break;
+				break;
+			}
 		}
 		if (idx < 0)
 			return -EINVAL;
@@ -2880,16 +2881,21 @@ static int ieee80211_ioctl_siwencode(str
 		alg = ALG_NONE;
 	else if (erq->length == 0) {
 		/* No key data - just set the default TX key index */
-		sdata->default_key = sdata->keys[idx];
+		if (sdata->default_key != sdata->keys[idx]) {
+			if (sdata->default_key)
+				ieee80211_key_sysfs_remove_default(sdata);
+			sdata->default_key = sdata->keys[idx];
+			if (sdata->default_key)
+				ieee80211_key_sysfs_add_default(sdata);
+		}
+		return 0;
 	}
 
 	return ieee80211_set_encryption(
 		dev, bcaddr,
-		idx, erq->length == 0 ? ALG_NONE : ALG_WEP,
+		idx, alg,
 		!sdata->default_key,
 		NULL, keybuf, erq->length);
-
-	return 0;
 }
 
 
@@ -2908,9 +2914,10 @@ static int ieee80211_ioctl_giwencode(str
 		if (!sdata->default_key)
 			idx = 0;
 		else for (i = 0; i < NUM_DEFAULT_KEYS; i++) {
-			if (sdata->default_key == sdata->keys[i])
+			if (sdata->default_key == sdata->keys[i]) {
 				idx = i;
-			break;
+				break;
+			}
 		}
 		if (idx < 0)
 			return -EINVAL;
@@ -2925,7 +2932,8 @@ static int ieee80211_ioctl_giwencode(str
 		return 0;
 	}
 
-	erq->length = 0;
+	erq->length = min((int)erq->length, sdata->keys[idx]->keylen);
+	memcpy(key, sdata->keys[idx]->key, erq->length);
 	erq->flags |= IW_ENCODE_ENABLED;
 
 	return 0;
@@ -3054,9 +3062,10 @@ static int ieee80211_ioctl_siwencodeext(
 		if (!sdata->default_key)
 			idx = 0;
 		else for (i = 0; i < NUM_DEFAULT_KEYS; i++) {
-			if (sdata->default_key == sdata->keys[i])
+			if (sdata->default_key == sdata->keys[i]) {
 				idx = i;
-			break;
+				break;
+			}
 		}
 		if (idx < 0)
 			return -EINVAL;
