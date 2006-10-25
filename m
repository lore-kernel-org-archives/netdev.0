From: Michael Buesch <mb@bu3sch.de>
Subject: Re: rmmod bcm43xx-d80211 while keys set etc
Date: Wed, 25 Oct 2006 11:41:01 +0200
Message-ID: <200610251141.02177.mb@bu3sch.de>
References: <1161729564.4044.0.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:2019
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1423105AbWJYJmA
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Oct 2006 05:42:00 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1161729564.4044.0.camel@johannes.berg>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 25 October 2006 00:39, Johannes Berg wrote:
> resulted in this:
> 
> [10261.556773] BUG: sleeping function called from invalid context at kernel/mutex.c:86

Yeah, there are a few bugs of this type left and I know most of them. ;)
The stack should never call atomically into the driver.
That must be made a hard general rule.

> [10261.556777] in_atomic():1, irqs_disabled():0
> [10261.556780] Call Trace:
> [10261.556783] [C13CDC80] [C0008ED4] show_stack+0x3c/0x194 (unreliable)
> [10261.556799] [C13CDCB0] [C0025AE4] __might_sleep+0xd0/0xe4
> [10261.556810] [C13CDCC0] [C02B90F8] mutex_lock+0x24/0x3c
> [10261.556819] [C13CDCE0] [F290647C] bcm43xx_net_set_key+0xd0/0x2d0 [bcm43xx_d80211]
> [10261.556854] [C13CDD10] [F248DEF4] sta_info_free+0x1b4/0x2c8 [80211]
> [10261.556906] [C13CDD50] [F248E078] sta_info_flush+0x70/0xa0 [80211]
> [10261.556918] [C13CDD70] [F2496728] ieee80211_if_reinit+0x10c/0x2cc [80211]
> [10261.556931] [C13CDDA0] [F2496908] __ieee80211_if_del+0x20/0x4c [80211]
> [10261.556943] [C13CDDC0] [F2485428] ieee80211_unregister_hw+0x78/0x248 [80211]
> [10261.556955] [C13CDDF0] [F29079F0] bcm43xx_remove_one+0x38/0x7c [bcm43xx_d80211]
> [10261.556966] [C13CDE10] [C017958C] pci_device_remove+0x38/0x60
> [10261.556976] [C13CDE20] [C01CC59C] __device_release_driver+0x74/0xac
> [10261.556985] [C13CDE40] [C01CCCBC] driver_detach+0x110/0x140
> [10261.556991] [C13CDE60] [C01CC0B8] bus_remove_driver+0x8c/0xc8
> [10261.556996] [C13CDE80] [C01CCD44] driver_unregister+0x18/0x34
> [10261.557001] [C13CDEA0] [C0179608] pci_unregister_driver+0x1c/0x70
> [10261.557006] [C13CDEC0] [F291C9E0] bcm43xx_exit+0x18/0x3a90 [bcm43xx_d80211]
> [10261.557015] [C13CDED0] [C004A31C] sys_delete_module+0x1ac/0x210
> [10261.557026] [C13CDF40] [C0010D20] ret_from_syscall+0x0/0x38
> [10261.557035] --- Exception: c01 at 0xff6c2b8
> [10261.557061]     LR = 0x1000100c
> [10261.557073] Badness in __mutex_lock_common at kernel/mutex.c:132
> [10261.557076] Call Trace:
> [10261.557078] [C13CDB50] [C0008ED4] show_stack+0x3c/0x194 (unreliable)
> [10261.557084] [C13CDB80] [C000FCA4] program_check_exception+0x47c/0x598
> [10261.557090] [C13CDBD0] [C001137C] ret_from_except_full+0x0/0x4c
> [10261.557094] --- Exception: 700 at __mutex_lock_slowpath+0x168/0x170
> [10261.557100]     LR = __mutex_lock_slowpath+0x160/0x170
> [10261.557103] [C13CDC90] [00000003] 0x3 (unreliable)
> [10261.557108] [C13CDCE0] [F290647C] bcm43xx_net_set_key+0xd0/0x2d0 [bcm43xx_d80211]
> [10261.557118] [C13CDD10] [F248DEF4] sta_info_free+0x1b4/0x2c8 [80211]
> [10261.557133] [C13CDD50] [F248E078] sta_info_flush+0x70/0xa0 [80211]
> [10261.557144] [C13CDD70] [F2496728] ieee80211_if_reinit+0x10c/0x2cc [80211]
> [10261.557156] [C13CDDA0] [F2496908] __ieee80211_if_del+0x20/0x4c [80211]
> [10261.557168] [C13CDDC0] [F2485428] ieee80211_unregister_hw+0x78/0x248 [80211]
> [10261.557180] [C13CDDF0] [F29079F0] bcm43xx_remove_one+0x38/0x7c [bcm43xx_d80211]
> [10261.557189] [C13CDE10] [C017958C] pci_device_remove+0x38/0x60
> [10261.557195] [C13CDE20] [C01CC59C] __device_release_driver+0x74/0xac
> [10261.557200] [C13CDE40] [C01CCCBC] driver_detach+0x110/0x140
> [10261.557205] [C13CDE60] [C01CC0B8] bus_remove_driver+0x8c/0xc8
> [10261.557210] [C13CDE80] [C01CCD44] driver_unregister+0x18/0x34
> [10261.557215] [C13CDEA0] [C0179608] pci_unregister_driver+0x1c/0x70
> [10261.557220] [C13CDEC0] [F291C9E0] bcm43xx_exit+0x18/0x3a90 [bcm43xx_d80211]
> [10261.557229] [C13CDED0] [C004A31C] sys_delete_module+0x1ac/0x210
> [10261.557235] [C13CDF40] [C0010D20] ret_from_syscall+0x0/0x38
> [10261.557240] --- Exception: c01 at 0xff6c2b8
> [10261.557245]     LR = 0x1000100c
> [10261.557322] eth1: Removed STA 00:15:f2:3d:63:97
> [10261.623773] bcm43xx_d80211: Virtual interface removed (type: 0x00000002, ID: 24, MAC: 00:11:24:91:07:4d)
> 
> 

-- 
Greetings Michael.
