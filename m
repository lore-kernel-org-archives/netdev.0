From: Jorge Ramirez <jorge.ramirez-ortiz@linaro.org>
Subject: Re: SIOCSIWFREQ while in NL80211_IFTYPE_STATION
Date: Thu, 5 Jan 2017 15:38:29 +0100
Message-ID: <f8e8b557-3e7b-cc1a-c31a-91f9d754e683@linaro.org>
References: <685811c3-6247-77fd-8c70-617951886451@linaro.org>
 <1483616301.4394.6.camel@sipsolutions.net>
 <92e60cb2-8bb4-df03-3434-4a055f575df0@linaro.org>
 <1483625204.4394.23.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless <linux-wireless@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>, netdev@vger.kernel.org,
        Daniel Lezcano <daniel.lezcano@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f179.google.com ([209.85.210.179]:36667 "EHLO
        mail-wj0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753617AbdAEOid (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2017 09:38:33 -0500
Received: by mail-wj0-f179.google.com with SMTP id ew7so22741589wjc.3
        for <netdev@vger.kernel.org>; Thu, 05 Jan 2017 06:38:32 -0800 (PST)
In-Reply-To: <1483625204.4394.23.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/05/2017 03:06 PM, Johannes Berg wrote:
>> I am not sure it matters - if I understood your reply, there is no
>> valid use case to change the frequency in that mode (and all that
>> code should be removed);
> All of wext *is* being removed - slowly :)
> It's not longer default in the kernel configuration now.

ah thanks for the info. I should have checked!

>
> IIRC, there actually was a valid use case here - to set the frequency
> before you set the SSID - to be able to force a connection on that
> channel with wext.

ok, yes I thought this would make sense.

>
>> it seems to me that it is also your view that userspace (iwconfig)
>> should be fixed accordingly to not call the extensions?
> iwconfig should just be deleted and iw be used :-)

understood.

>
>> I am just trying to understand how the current code is supposed to
>> work  by exercising widely available user-space tools while debugging
>> the kernel.
> Heh, ok.
>
>> Actually the frequency gets programmed without errors when reverting
>> your commit http://tinyurl.com/ho4urp8 (which comes as a surprise as
>> well).
> Well, it's not my commit, but that makes sense. I suppose we should
> treat this as a regression, but reverting that doesn't seem like the
> right fix. Actually, I'm not convinced we should do monitor channel
> change anyway when you set the frequency with wext, so we can probably
> just remove that call there - want to send a patch to that effect?

do you mean this?

[jramirez@igloo ~ (debian-qcom-dragonboard410c-16.09-local $)]$ git diff
diff --git a/net/wireless/wext-sme.c b/net/wireless/wext-sme.c
index a4e8af3..c56bac5 100644
--- a/net/wireless/wext-sme.c
+++ b/net/wireless/wext-sme.c
@@ -106,30 +106,7 @@ int cfg80211_mgd_wext_siwfreq(struct net_device *dev,
                         goto out;
         }

-
         wdev->wext.connect.channel = chan;
-
-   /*
-    * SSID is not set, we just want to switch monitor channel,
-    * this is really just backward compatibility, if the SSID
-    * is set then we use the channel to select the BSS to use
-    * to connect to instead. If we were connected on another
-    * channel we disconnected above and reconnect below.
-    */
-   if (chan && !wdev->wext.connect.ssid_len) {
-           struct cfg80211_chan_def chandef = {
-                   .width = NL80211_CHAN_WIDTH_20_NOHT,
-                   .center_freq1 = freq,
-           };
-
-           chandef.chan = ieee80211_get_channel(&rdev->wiphy, freq);
-           if (chandef.chan)
-                   err = cfg80211_set_monitor_channel(rdev, &chandef);
-           else
-                   err = -EINVAL;
-           goto out;
-   }
-
         err = cfg80211_mgd_wext_connect(rdev, wdev);
   out:
         wdev_unlock(wdev);



I tested the change above: we can now modify the channel/frequency when 
the SSID is not set in managed mode.
When the SSID is set however iwconfig does not report any error but 
channel/frequency doesn't change.

if you think this is acceptable I can submit a patch


> johannes
