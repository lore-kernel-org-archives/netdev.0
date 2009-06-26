From: Frans Pop <elendil@planet.nl>
Subject: [2.6.31-rc1] iwlagn (4965): no wireless due to RFKILL problem
Date: Fri, 26 Jun 2009 13:36:28 +0200
Message-ID: <200906261336.29318.elendil@planet.nl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Cpsmtpm-eml106.kpnxchange.com ([195.121.3.10]:62317 "EHLO
	CPSMTPM-EML106.kpnxchange.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753561AbZFZLg2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2009 07:36:28 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've tried .31-rc1 on my HP 2510p notebook and the only problem I found 
was that wireless no longer works. The cause looks to be related to 
RFKILL.

Initially when I booted all I got in dmesg was:
cfg80211: Using static regulatory domain info
cfg80211: Regulatory domain: EU
        (start_freq - end_freq @ bandwidth), (max_antenna_gain, max_eirp)
        (2402000 KHz - 2482000 KHz @ 40000 KHz), (600 mBi, 2000 mBm)
        (5170000 KHz - 5190000 KHz @ 40000 KHz), (600 mBi, 2300 mBm)
        (5190000 KHz - 5210000 KHz @ 40000 KHz), (600 mBi, 2300 mBm)
        (5210000 KHz - 5230000 KHz @ 40000 KHz), (600 mBi, 2300 mBm)
        (5230000 KHz - 5330000 KHz @ 40000 KHz), (600 mBi, 2000 mBm)
        (5490000 KHz - 5710000 KHz @ 40000 KHz), (600 mBi, 3000 mBm)
cfg80211: Calling CRDA for country: EU
iwlagn: Intel(R) Wireless WiFi Link AGN driver for Linux, 1.3.27kd
iwlagn: Copyright(c) 2003-2009 Intel Corporation
iwlagn 0000:10:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
iwlagn 0000:10:00.0: setting latency timer to 64
iwlagn 0000:10:00.0: Detected Intel Wireless WiFi Link 4965AGN REV=0x4
iwlagn 0000:10:00.0: Tunable channels: 11 802.11bg, 13 802.11a channels
iwlagn 0000:10:00.0: irq 27 for MSI/MSI-X
phy0: Selected rate control algorithm 'iwl-agn-rs'

Normally I'd expect to see the following after that (from .30):
iwlagn 0000:10:00.0: firmware: requesting iwlwifi-4965-2.ucode
iwlagn 0000:10:00.0: loaded firmware version 228.57.2.23
Registered led device: iwl-phy0::radio
Registered led device: iwl-phy0::assoc
Registered led device: iwl-phy0::RX
Registered led device: iwl-phy0::TX
wlan0: authenticate with AP 00:14:c1:38:e5:15
wlan0: authenticated
wlan0: associate with AP 00:14:c1:38:e5:15
wlan0: RX AssocResp from 00:14:c1:38:e5:15 (capab=0x411 status=0 aid=1)
wlan0: associated

So it did not even try to load the firmware...


After the boot completed I tried unloading and reloading iwlagn, and then 
I suddenly got:
iwlagn 0000:10:00.0: PCI INT A disabled
cfg80211: Using static regulatory domain info
cfg80211: Regulatory domain: EU
        (start_freq - end_freq @ bandwidth), (max_antenna_gain, max_eirp)
        (2402000 KHz - 2482000 KHz @ 40000 KHz), (600 mBi, 2000 mBm)
        (5170000 KHz - 5190000 KHz @ 40000 KHz), (600 mBi, 2300 mBm)
        (5190000 KHz - 5210000 KHz @ 40000 KHz), (600 mBi, 2300 mBm)
        (5210000 KHz - 5230000 KHz @ 40000 KHz), (600 mBi, 2300 mBm)
        (5230000 KHz - 5330000 KHz @ 40000 KHz), (600 mBi, 2000 mBm)
        (5490000 KHz - 5710000 KHz @ 40000 KHz), (600 mBi, 3000 mBm)
cfg80211: Calling CRDA for country: EU
iwlagn: Intel(R) Wireless WiFi Link AGN driver for Linux, 1.3.27kd
iwlagn: Copyright(c) 2003-2009 Intel Corporation
iwlagn 0000:10:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
iwlagn 0000:10:00.0: setting latency timer to 64
iwlagn 0000:10:00.0: Detected Intel Wireless WiFi Link 4965AGN REV=0x4
iwlagn 0000:10:00.0: Tunable channels: 11 802.11bg, 13 802.11a channels
iwlagn 0000:10:00.0: irq 27 for MSI/MSI-X
phy0: Selected rate control algorithm 'iwl-agn-rs'
iwlagn 0000:10:00.0: firmware: requesting iwlwifi-4965-2.ucode
iwlagn 0000:10:00.0: loaded firmware version 228.57.2.23
iwlagn 0000:10:00.0: Radio disabled by HW RF Kill switch

I then noticed that the wireless led on the notbook was indeed off, but it 
was totally unresponsive to any attempts to turn it on.

I also compared loaded modules; for .30:
   cfg80211               65944  3 iwlagn,iwlcore,mac80211
   iwlagn                113236  0 
   iwlcore               159172  1 iwlagn
   led_class               5080  3 iwlcore,hp_accel,sdhci
   lib80211                7520  1 iwlcore
   mac80211              164744  2 iwlagn,iwlcore
   rfkill                 12276  5 hp_wmi,iwlcore
and for .31-rc1:
   cfg80211               90808  3 iwlagn,iwlcore,mac80211
   iwlagn                107856  0 
   iwlcore               167908  1 iwlagn
   led_class               5064  3 iwlcore,hp_accel,sdhci
   mac80211              167024  2 iwlagn,iwlcore
   rfkill                 20640  2 hp_wmi,cfg80211

Note that lib80211 no longer gets loaded.

After rebooting into .30 wireless worked again.

Cheers,
FJP

Relevant part of config (diff between .30 and .31-rc1):
 CONFIG_WIRELESS=y
 CONFIG_CFG80211=m
 # CONFIG_CFG80211_REG_DEBUG is not set
+# CONFIG_CFG80211_DEBUGFS is not set
 CONFIG_WIRELESS_OLD_REGULATORY=y
 CONFIG_WIRELESS_EXT=y
 CONFIG_WIRELESS_EXT_SYSFS=y
 CONFIG_LIB80211=m
 # CONFIG_LIB80211_DEBUG is not set
 CONFIG_MAC80211=m
+# CONFIG_MAC80211_DEFAULT_PS is not set
+CONFIG_MAC80211_DEFAULT_PS_VALUE=1

 #
 # Rate control algorithm selection
 #
 CONFIG_MAC80211_RC_MINSTREL=y
 # CONFIG_MAC80211_RC_DEFAULT_PID is not set
 CONFIG_MAC80211_RC_DEFAULT_MINSTREL=y
 CONFIG_MAC80211_RC_DEFAULT="minstrel"
 CONFIG_MAC80211_MESH=y
 CONFIG_MAC80211_LEDS=y
 # CONFIG_MAC80211_DEBUGFS is not set
 # CONFIG_MAC80211_DEBUG_MENU is not set
 # CONFIG_WIMAX is not set
 CONFIG_RFKILL=m
-CONFIG_RFKILL_INPUT=m
 CONFIG_RFKILL_LEDS=y
+CONFIG_RFKILL_INPUT=y
 # CONFIG_NET_9P is not set
[...]
 CONFIG_IWLWIFI=m
 CONFIG_IWLWIFI_LEDS=y
-CONFIG_IWLWIFI_RFKILL=y
 # CONFIG_IWLWIFI_SPECTRUM_MEASUREMENT is not set
 CONFIG_IWLWIFI_DEBUG=y
 CONFIG_IWLAGN=m
 CONFIG_IWL4965=y
 # CONFIG_IWL5000 is not set
 # CONFIG_IWL3945 is not set
 # CONFIG_HOSTAP is not set
 # CONFIG_B43 is not set
 # CONFIG_B43LEGACY is not set
 # CONFIG_ZD1211RW is not set
 # CONFIG_RT2X00 is not set
 # CONFIG_HERMES is not set
+# CONFIG_IWM is not set
