From: Hong Liu <hong.liu@intel.com>
Subject: Re: [PATCH]d80211: fix "iwconfig key [x]" behavior
Date: Fri, 22 Sep 2006 15:56:26 +0800
Message-ID: <1158911742.15563.1.camel@devlinux-hong>
References: <1156754199.6061.3.camel@devlinux-hong>
	 <20060830192452.6ae099d5@griffin.suse.cz>
	 <1157081877.11040.44.camel@devlinux-hong>
	 <20060921175104.31429d65@logostar.upir.cz>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:1167 "EHLO mga02.intel.com")
	by vger.kernel.org with ESMTP id S1750937AbWIVIDg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2006 04:03:36 -0400
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20060921175104.31429d65@logostar.upir.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-09-21 at 23:51, Jiri Benc wrote:
> Hi,
> 
> sorry for the delay.
> 
> On Fri, 01 Sep 2006 11:37:57 +0800, Hong Liu wrote:
> > @@ -2925,7 +2932,8 @@ static int ieee80211_ioctl_giwencode(str
> >  		return 0;
> >  	}
> >  
> > -	erq->length = 0;
> > +	erq->length = min((int)erq->length, sdata->keys[idx]->keylen);
> > +	memcpy(key, sdata->keys[idx]->key, erq->length);
> >  	erq->flags |= IW_ENCODE_ENABLED;
> >  
> >  	return 0;
> 
> This is still not correct, erq->length should be set to the actual key
> length to allow WE to return -E2BIG in case of too small buffer.
> 
> 	memcpy(key, sdata->keys[idx]->key,
> 	       min((int)erq->length, sdata->keys[idx]->keylen));
> 	erq->length = sdata->keys[idx]->keylen;
> 
>  Jiri

Resend.

Thanks,
Hong


Signed-off-by: Hong Liu <hong.liu@intel.com>

diff --git a/net/d80211/ieee80211_ioctl.c b/net/d80211/ieee80211_ioctl.c
index 89a58e3..bde0c43 100644
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
@@ -2925,7 +2932,9 @@ static int ieee80211_ioctl_giwencode(str
 		return 0;
 	}
 
-	erq->length = 0;
+	memcpy(key, sdata->keys[idx]->key,
+	       min((int)erq->length, sdata->keys[idx]->keylen));
+	erq->length = sdata->keys[idx]->keylen;
 	erq->flags |= IW_ENCODE_ENABLED;
 
 	return 0;
@@ -3054,9 +3063,10 @@ static int ieee80211_ioctl_siwencodeext(
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
