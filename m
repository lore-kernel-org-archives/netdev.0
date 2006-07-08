From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [patch] work around/fix deadlock in the bcm43xx driver by making netlink irq safe
Date: Sat, 8 Jul 2006 20:32:12 +0200
Message-ID: <200607082032.13127.mb@bu3sch.de>
References: <1151677494.11434.47.camel@laptopd505.fenrus.org> <44A53918.2020700@linux.intel.com> <44AFF272.8000109@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Arjan van de Ven <arjan@linux.intel.com>,
	Joseph Jezak <josejx@gentoo.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:15290
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S964951AbWGHSbg
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Jul 2006 14:31:36 -0400
To: Larry Finger <Larry.Finger@lwfinger.net>, Jiri Benc <jbenc@suse.cz>
In-Reply-To: <44AFF272.8000109@lwfinger.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 08 July 2006 19:59, you wrote:
> kernel: stack backtrace:
> kernel:  [<c0103d1d>] show_trace_log_lvl+0x13d/0x160
> kernel:  [<c010525b>] show_trace+0x1b/0x20
> kernel:  [<c0105286>] dump_stack+0x26/0x30
> kernel:  [<c0133f7d>] check_usage+0x26d/0x280
> kernel:  [<c013536f>] __lock_acquire+0x77f/0xdd0
> kernel:  [<c0135d48>] lock_acquire+0x68/0x90
> kernel:  [<c030c195>] _read_lock+0x45/0x60
> kernel:  [<c02a786f>] sock_def_readable+0x1f/0x90
> kernel:  [<c02bf072>] netlink_broadcast+0x282/0x320
> kernel:  [<c02bb6e4>] wireless_send_event+0x244/0x3b0

This is another fscking deadlock. But it should be fixed by
the suggested workaround as well.
So I see this problem solved for now, too.

> kernel:  [<e4a2c586>] ieee80211softmac_call_events_locked+0x86/0x140 [ieee80211softmac]
> kernel:  [<e4a2c674>] ieee80211softmac_call_events+0x34/0x6f [ieee80211softmac]
> kernel:  [<e4a28faf>] ieee80211softmac_auth_resp+0x19f/0x620 [ieee80211softmac]
> kernel:  [<e4a1e413>] ieee80211_rx_mgt+0x543/0x810 [ieee80211]
> kernel:  [<e4a7ea2b>] bcm43xx_rx+0x34b/0x980 [bcm43xx]
> kernel:  [<e4a820bc>] bcm43xx_dma_rx+0x23c/0x550 [bcm43xx]
> kernel:  [<e4a6751e>] bcm43xx_interrupt_tasklet+0x38e/0x970 [bcm43xx]
> kernel:  [<c011e4de>] tasklet_action+0x4e/0x90
> kernel:  [<c011ecc2>] __do_softirq+0x62/0xe0
> kernel:  [<c01055cb>] do_softirq+0x9b/0xf0
> kernel:  [<c01056d1>] do_IRQ+0xb1/0x110
> kernel:  [<c0103439>] common_interrupt+0x25/0x2c
> kernel:  [<c015e01e>] kmem_cache_free+0x6e/0xa0
> kernel:  [<c019631d>] proc_destroy_inode+0x1d/0x20
> kernel:  [<c017d7eb>] destroy_inode+0x2b/0x60
> kernel:  [<c017e753>] generic_delete_inode+0xb3/0x100
> kernel:  [<c017d8fd>] iput+0x6d/0x80
> kernel:  [<c017b79b>] dentry_iput+0x7b/0xd0
> kernel:  [<c017bee4>] dput+0x84/0x190
> kernel:  [<c0172194>] path_release+0x14/0x30
> kernel:  [<c017295a>] __link_path_walk+0x3ea/0xef0
> kernel:  [<c01734b4>] link_path_walk+0x54/0xf0
> kernel:  [<c017394e>] do_path_lookup+0xae/0x260
> kernel:  [<c017403a>] __path_lookup_intent_open+0x4a/0x90
> kernel:  [<c017410a>] path_lookup_open+0x2a/0x30
> kernel:  [<c01743a7>] open_namei+0x77/0x6d0
> kernel:  [<c0161898>] do_filp_open+0x38/0x60
> kernel:  [<c016190b>] do_sys_open+0x4b/0x100
> kernel:  [<c0161a17>] sys_open+0x27/0x30
> kernel:  [<c01031cd>] sysenter_past_esp+0x56/0x8d
> kernel:  [<b7fb9410>] 0xb7fb9410
> kernel: SoftMAC: sent association request!
> kernel: SoftMAC: associated!
> kernel: SoftMAC: Scanning finished
> 
> So far, this situation has only occurred during the initial association/authorization steps during 
> bootup.


BTW:

Jiri, As you can see, various deadlocks are possible when calling
directly from a driver tasklet into the 802.11 stack, because by
the nature of the 802.11 we must call back into the driver
at some places.
So, I would like to get rid of the not _irqsafe functions
in devicescape. The _irqsafe functions could be stripped by the
postfix and the unsafe functions should be strictly internal to
the stack. I don't see valid usages for them outside of the stack.

-- 
Greetings Michael.
