From: Francois Romieu <romieu@fr.zoreil.com>
Subject: e1000e - BUG: sleeping function called from invalid context
Date: Thu, 1 Sep 2011 14:20:00 +0200
Message-ID: <20110901122000.GA24946@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	John Ronciak <john.ronciak@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:42323 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757191Ab1IAMie (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2011 08:38:34 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I got this one while running plain 'ip link show' with linus's post
3.1.0-rc3 (CONFIG_DEBUG_ATOMIC_SLEEP=y, 82544 LOM with Intel DP55KG
motherboard):

[18628.524980] BUG: sleeping function called from invalid context at /home/romieu/git/linux-2.6-ref/kernel/mutex.c:85
[18628.524987] in_atomic(): 1, irqs_disabled(): 0, pid: 1204, name: irqbalance
[18628.524993] Pid: 1204, comm: irqbalance Not tainted 3.1.0-rc3+ #4
[18628.524996] Call Trace:
[18628.525007]  [<ffffffff810421a1>] __might_sleep+0xeb/0xf0
[18628.525032]  [<ffffffff814a9dd8>] mutex_lock+0x24/0x4a
[18628.525040]  [<ffffffff8124dc82>] ? vsnprintf+0x83/0x44c
[18628.525057]  [<ffffffffa01e1697>] e1000_acquire_swflag_ich8lan+0x27/0x138 [e1000e]
[18628.525078]  [<ffffffffa01f0bae>] e1000e_update_stats+0x158/0x750 [e1000e]
[18628.525098]  [<ffffffffa01f11e8>] e1000e_get_stats64+0x42/0x143 [e1000e]
[18628.525105]  [<ffffffff813f4986>] dev_get_stats+0x38/0x7a
[18628.525110]  [<ffffffff813f49f0>] dev_seq_printf_stats+0x28/0xf8
[18628.525118]  [<ffffffff813f33e2>] ? dev_seq_start+0x1f/0x70
[18628.525123]  [<ffffffff813f4ae2>] dev_seq_show+0x22/0x26

The path looks the same in linus's (9e79e3e9dd9672b37ac9412e9a926714306551fe)
and in davem's net-next (3857e3ee2209b7289c434103e366f765ec82a22d) branches:

e1000e_get_stats64
-> spin_lock(&adapter->stats64_lock);
   e1000e_update_stats
   -> e1000e_update_phy_stats
      -> e1000_acquire_swflag_ich8lan (through hw->phy.ops.acquire)
         -> mutex_lock(&swflag_mutex);

Can you fix it ?

(either turn stats64_lock into a mutex or remove it - and swflag_mutex as
well ? - and use the rtnl sem in your work tasks from a quick glance at
the code)

Thanks.

-- 
Ueimor
