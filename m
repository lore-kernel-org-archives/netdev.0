From: Yegor Yefremov <yegorslists@googlemail.com>
Subject: Re: 2.6.33.2: Turn tx power off/on for Atheros card
Date: Thu, 6 May 2010 16:52:18 +0200
Message-ID: <g2wf69abfc31005060752w6876439cm45f5be68001c8382@mail.gmail.com>
References: <r2xf69abfc31005050326oe123cb60s131ab4969341ef57@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:40279 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753031Ab0EFOwV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 10:52:21 -0400
In-Reply-To: <r2xf69abfc31005050326oe123cb60s131ab4969341ef57@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 5, 2010 at 12:26 PM, Yegor Yefremov
<yegorslists@googlemail.com> wrote:
> I'm using kernel 2.6.33.2 with AR2413 WLAN card. Issuing
>
> iwconfig wlan0 txpower off
>
> turns txpower off. I can see this status by iwconfig wlan0 and the
> communication with AP terminates. But when I turn the txpower on
>
> iwconfig wlan0 txpower on
>
> nothing happens. Though iwconfig shows the previous tx power value.
> Only ifconfig wlan0 down and then up recovers the transmission.
>
> Is it a known bug or I'm doing something wrong?

I made some debugging and found out that after iwconfig wlan0 txpower
off dev_close() will be invoked, so that local->open_count will be 0.
The next time txpower on will be called, it will be checked if
local->open_count > 0 and this conditions fails, so no  hardware
configuration will be made.

I've made a quick and dirty hack, that opens the wireless device by
enabling the txpower, if it was closed before. Is there any proper
solution? Is it really necessary to close device to tunr txpower off?

Best regards,
Yegor

Index: b/net/wireless/wext-compat.c
===================================================================
--- a/net/wireless/wext-compat.c	2010-04-30 05:02:05.000000000 +0200
+++ b/net/wireless/wext-compat.c	2010-05-06 16:31:20.000000000 +0200
@@ -15,6 +15,7 @@
 #include <linux/slab.h>
 #include <net/iw_handler.h>
 #include <net/cfg80211.h>
+#include "../mac80211/ieee80211_i.h"
 #include "wext-compat.h"
 #include "core.h"

@@ -824,6 +825,7 @@
 {
 	struct wireless_dev *wdev = dev->ieee80211_ptr;
 	struct cfg80211_registered_device *rdev = wiphy_to_dev(wdev->wiphy);
+	struct ieee80211_local *local = wiphy_priv(wdev->wiphy);
 	enum tx_power_setting type;
 	int dbm = 0;

@@ -861,6 +863,8 @@
 				type = TX_POWER_LIMITED;
 			}
 		}
+		if(!local->open_count)
+			dev_open(wdev->netdev);
 	} else {
 		rfkill_set_sw_state(rdev->rfkill, true);
 		schedule_work(&rdev->rfkill_sync);
