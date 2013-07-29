From: Andy Isaacson <adi@hexapodia.org>
Subject: 3.10, iwlwifi 6200AGN: AP changed bandwidth in a way we can't
 support - disconnect
Date: Mon, 29 Jul 2013 09:34:52 -0700
Message-ID: <20130729163452.GA454@hexapodia.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Johannes Berg <johannes.berg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from straum.hexapodia.org ([66.109.99.53]:42671 "EHLO
	straum.hexapodia.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756118Ab3G2QlY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jul 2013 12:41:24 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After upgrading to 3.10.4 and traveling to Europe I'm often suffering
from failures to associate with the following in dmesg:

[   37.351621] wlan0: authenticate with 64:70:02:e6:a6:ba
[   37.364701] wlan0: send auth to 64:70:02:e6:a6:ba (try 1/3)
[   37.366358] wlan0: authenticated
[   37.368543] wlan0: associate with 64:70:02:e6:a6:ba (try 1/3)
[   37.372765] wlan0: RX AssocResp from 64:70:02:e6:a6:ba (capab=0x431 status=0 aid=8)
[   37.380190] wlan0: associated
[   37.438935] wlan0: AP 64:70:02:e6:a6:ba changed bandwidth, new config is 2447 MHz, width 1 (2447/0 MHz)
[   37.438941] wlan0: AP 64:70:02:e6:a6:ba changed bandwidth in a way we can't support - disconnect

I hacked the driver to do

-                  "AP %pM changed bandwidth, new config is %d MHz, width %d (%d/%d MHz)\n",
+                  "AP %pM changed bandwidth, new config is %d MHz, width %d (%d/%d MHz) flags %x/%x\n",
                   ifmgd->bssid, chandef.chan->center_freq, chandef.width,
-                  chandef.center_freq1, chandef.center_freq2);
+                  chandef.center_freq1, chandef.center_freq2, flags, ifmgd->flags);

and

-       if (flags != (ifmgd->flags & (IEEE80211_STA_DISABLE_HT |
+       if ((flags != 0x810 && ifmgd->flags != 0x804) && (
+            flags != (ifmgd->flags & (IEEE80211_STA_DISABLE_HT |

and the result is a working link with

[ 1277.069287] wlan0: authenticate with 64:70:02:e6:a6:ba
[ 1277.118344] wlan0: send auth to 64:70:02:e6:a6:ba (try 1/3)
[ 1277.222126] wlan0: send auth to 64:70:02:e6:a6:ba (try 2/3)
[ 1277.226656] wlan0: authenticated
[ 1277.226806] wlan0: waiting for beacon from 64:70:02:e6:a6:ba
[ 1277.258119] wlan0: associate with 64:70:02:e6:a6:ba (try 1/3)
[ 1277.262717] wlan0: RX AssocResp from 64:70:02:e6:a6:ba (capab=0x431 status=0 aid=9)
[ 1277.269678] wlan0: associated
[ 1277.269727] IPv6: ADDRCONF(NETDEV_CHANGE): wlan0: link becomes ready
[ 1277.366049] wlan0: AP 64:70:02:e6:a6:ba changed bandwidth, new config is 2447 MHz, width 1 (2447/0 MHz) flags 810/804
[ 2219.627077] wlan0: AP 64:70:02:e6:a6:ba changed bandwidth, new config is 2447 MHz, width 2 (2437/0 MHz) flags 800/804
[ 2220.668210] wlan0: AP 64:70:02:e6:a6:ba changed bandwidth, new config is 2447 MHz, width 1 (2447/0 MHz) flags 810/804

My userland is Debian unstable with 

ii  wpasupplicant    1.0-3+b2      amd64 client support for WPA and WPA2 (IEEE 802.11i)
ii  firmware-iwlwifi 0.36+wheezy.1 all   Binary firmware for Intel PRO/Wireless 3945 and 802.11

using ifup with the WPA configuration in /etc/network/interfaces.
Hardware is a Thinkpad x201s.  Bootup iwlwifi messages are

[    7.985050] iwlwifi 0000:02:00.0: irq 42 for MSI/MSI-X
[    8.061896] iwlwifi 0000:02:00.0: loaded firmware version 9.221.4.1 build 25532 op_mode iwldvm
[    8.087255] iwlwifi 0000:02:00.0: CONFIG_IWLWIFI_DEBUG enabled
[    8.087257] iwlwifi 0000:02:00.0: CONFIG_IWLWIFI_DEBUGFS enabled
[    8.087258] iwlwifi 0000:02:00.0: CONFIG_IWLWIFI_DEVICE_TRACING enabled
[    8.087260] iwlwifi 0000:02:00.0: CONFIG_IWLWIFI_DEVICE_TESTMODE disabled
[    8.087261] iwlwifi 0000:02:00.0: CONFIG_IWLWIFI_P2P enabled
[    8.087264] iwlwifi 0000:02:00.0: Detected Intel(R) Centrino(R) Advanced-N 6200 AGN, REV=0x74
[    8.087379] iwlwifi 0000:02:00.0: L1 Enabled; Disabling L0S
[   26.676655] iwlwifi 0000:02:00.0: L1 Enabled; Disabling L0S
[   26.683499] iwlwifi 0000:02:00.0: Radio type=0x1-0x3-0x1
[   27.023090] iwlwifi 0000:02:00.0: L1 Enabled; Disabling L0S
[   27.029927] iwlwifi 0000:02:00.0: Radio type=0x1-0x3-0x1

-andy
