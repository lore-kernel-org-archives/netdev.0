From: Johannes Berg <johannes@sipsolutions.net>
Subject: bcm43xx for d80211 softirq loop
Date: Mon, 14 Aug 2006 10:10:53 +0200
Message-ID: <44E0300D.1000402@sipsolutions.net>
References: <44E02F41.2060300@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:8642 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751927AbWHNILG
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Aug 2006 04:11:06 -0400
To: netdev@vger.kernel.org, Michael Buesch <mbuesch@freenet.de>,
	bcm43xx-dev@lists.berlios.de
In-Reply-To: <44E02F41.2060300@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[23750.726463] NETDEV WATCHDOG: wmaster0: transmit timed out
[23750.726482] wmaster0: resetting interface.
[23750.726490] bcm43xx_d80211: Controller RESET (IEEE reset) ...
[23750.753458] bcm43xx_d80211: select_wireless_core: cleanup
[23750.753477] bcm43xx_d80211: Radio turned off
[23750.753538] bcm43xx_d80211: DMA 0x0200 (RX) max used slots: 1/64
[23750.755208] bcm43xx_d80211: DMA 0x0260 (TX) max used slots: 0/512
[23750.755601] bcm43xx_d80211: DMA 0x0240 (TX) max used slots: 0/512
[23750.755992] bcm43xx_d80211: DMA 0x0220 (TX) max used slots: 0/512
[23750.756383] bcm43xx_d80211: DMA 0x0200 (TX) max used slots: 0/512
[23750.957250] bcm43xx_d80211: Radio turned on
[23751.129344] bcm43xx_d80211: Chip initialized
[23751.137239] bcm43xx_d80211: DMA initialized
[23751.137503] bcm43xx_d80211: Keys cleared
[23751.153242] bcm43xx_d80211: Selected 802.11 core (phytype 2)
[23751.153263] bcm43xx_d80211: Controller restarted


after this, ksoftirq started running wild...

Since oprofile doesn't show any function ever called for a tasklet, I 
started to investigate but couldn't find what was up. Then I removed the 
bcm43xx_dscape module and the kernel blew up right away.

Then I patched the kernel with a runaway tasklet patch (see mail on 
lkml) and got this (yeah, previous iteration of the patch where I forgot 
a "\n"):

[15214.574151] NETDEV WATCHDOG: wmaster0: transmit timed out
[15214.574166] wmaster0: resetting interface.
[15214.574174] bcm43xx_d80211: Controller RESET (IEEE reset) ...
[15214.591194] bcm43xx_d80211: select_wireless_core: cleanup
[15214.591209] bcm43xx_d80211: Radio turned off
[15214.591270] bcm43xx_d80211: DMA 0x0200 (RX) max used slots: 1/64
[15214.592901] bcm43xx_d80211: DMA 0x0260 (TX) max used slots: 0/512
[15214.593294] bcm43xx_d80211: DMA 0x0240 (TX) max used slots: 0/512
[15214.593685] bcm43xx_d80211: DMA 0x0220 (TX) max used slots: 0/512
[15214.594075] bcm43xx_d80211: DMA 0x0200 (TX) max used slots: 0/512
[15214.773961] bcm43xx_d80211: Radio turned on
[15214.945901] bcm43xx_d80211: Chip initialized
[15214.953815] bcm43xx_d80211: DMA initialized
[15214.954078] bcm43xx_d80211: Keys cleared
[15214.969864] bcm43xx_d80211: Selected 802.11 core (phytype 2)
[15214.969889] bcm43xx_d80211: Controller restarted
[15215.019746] tasklet 
drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c:4376 is scheduled but 
hasn't been enabled for too long!
<6>NETDEV WATCHDOG: wmaster0: transmit timed out
[15769.964164] wmaster0: resetting interface.
[15769.964175] bcm43xx_d80211: Controller RESET (IEEE reset) ...
[15769.995145] bcm43xx_d80211: select_wireless_core: cleanup
[15769.995166] bcm43xx_d80211: Radio turned off
[15769.995249] bcm43xx_d80211: DMA 0x0200 (RX) max used slots: 0/64
[15769.997222] bcm43xx_d80211: DMA 0x0260 (TX) max used slots: 0/512
[15769.997615] bcm43xx_d80211: DMA 0x0240 (TX) max used slots: 0/512
[15769.998006] bcm43xx_d80211: DMA 0x0220 (TX) max used slots: 0/512
[15769.998397] bcm43xx_d80211: DMA 0x0200 (TX) max used slots: 0/512
[15770.162013] bcm43xx_d80211: IRQ_READY timeout
[15770.162059] bcm43xx_d80211: core_up for active 802.11 core failed (-19)
[15770.162076] bcm43xx_d80211: Controller restart failed


Hence, I'm able to point to bcm43xx now ;) Sorry I can't give a better 
indication of what's up, I can try a different patch if you can come up 
with a good way of debugging it. This usually seems to happen here after 
an hour or two of not using the interface at all.

johannes

