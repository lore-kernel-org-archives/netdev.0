From: "Allan, Bruce W" <bruce.w.allan@intel.com>
Subject: RE: e1000e - BUG: sleeping function called from invalid context
Date: Thu, 1 Sep 2011 08:57:26 -0700
Message-ID: <E0862362F1FF584BBCF7C4EA592A20C40830D1FF@orsmsx509.amr.corp.intel.com>
References: <20110901122000.GA24946@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
To: Francois Romieu <romieu@fr.zoreil.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:48979 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932561Ab1IAP52 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2011 11:57:28 -0400
In-Reply-To: <20110901122000.GA24946@electric-eye.fr.zoreil.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Francois Romieu [mailto:romieu@fr.zoreil.com]
>Sent: Thursday, September 01, 2011 5:20 AM
>To: netdev@vger.kernel.org
>Cc: Kirsher, Jeffrey T; Brandeburg, Jesse; Allan, Bruce W; Wyborny, Carolyn;
>Skidmore, Donald C; Rose, Gregory V; Waskiewicz Jr, Peter P; Duyck, Alexander H;
>Ronciak, John
>Subject: e1000e - BUG: sleeping function called from invalid context
>
>I got this one while running plain 'ip link show' with linus's post
>3.1.0-rc3 (CONFIG_DEBUG_ATOMIC_SLEEP=y, 82544 LOM with Intel DP55KG
>motherboard):
>
>[18628.524980] BUG: sleeping function called from invalid context at
>/home/romieu/git/linux-2.6-ref/kernel/mutex.c:85
>[18628.524987] in_atomic(): 1, irqs_disabled(): 0, pid: 1204, name: irqbalance
>[18628.524993] Pid: 1204, comm: irqbalance Not tainted 3.1.0-rc3+ #4
>[18628.524996] Call Trace:
>[18628.525007]  [<ffffffff810421a1>] __might_sleep+0xeb/0xf0
>[18628.525032]  [<ffffffff814a9dd8>] mutex_lock+0x24/0x4a
>[18628.525040]  [<ffffffff8124dc82>] ? vsnprintf+0x83/0x44c
>[18628.525057]  [<ffffffffa01e1697>] e1000_acquire_swflag_ich8lan+0x27/0x138
>[e1000e]
>[18628.525078]  [<ffffffffa01f0bae>] e1000e_update_stats+0x158/0x750 [e1000e]
>[18628.525098]  [<ffffffffa01f11e8>] e1000e_get_stats64+0x42/0x143 [e1000e]
>[18628.525105]  [<ffffffff813f4986>] dev_get_stats+0x38/0x7a
>[18628.525110]  [<ffffffff813f49f0>] dev_seq_printf_stats+0x28/0xf8
>[18628.525118]  [<ffffffff813f33e2>] ? dev_seq_start+0x1f/0x70
>[18628.525123]  [<ffffffff813f4ae2>] dev_seq_show+0x22/0x26
>
>The path looks the same in linus's (9e79e3e9dd9672b37ac9412e9a926714306551fe)
>and in davem's net-next (3857e3ee2209b7289c434103e366f765ec82a22d) branches:
>
>e1000e_get_stats64
>-> spin_lock(&adapter->stats64_lock);
>   e1000e_update_stats
>   -> e1000e_update_phy_stats
>      -> e1000_acquire_swflag_ich8lan (through hw->phy.ops.acquire)
>         -> mutex_lock(&swflag_mutex);
>
>Can you fix it ?
>
>(either turn stats64_lock into a mutex or remove it - and swflag_mutex as
>well ? - and use the rtnl sem in your work tasks from a quick glance at
>the code)
>
>Thanks.
>
>--
>Ueimor

Thanks for reporting this.  I'll look into it.

Bruce.
