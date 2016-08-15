From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [BUGFIX PATCH 1/2] brcmfmac: Check rtnl_lock is locked when
 removing interface
Date: Mon, 15 Aug 2016 12:41:34 +0200
Message-ID: <5bb6e373-e110-b1ac-6f65-fdf2f9f059fc@gmail.com>
References: <147125403645.9434.8008546579326856373.stgit@devbox>
 <147125405701.9434.12911635695339175773.stgit@devbox>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: linux-wireless@vger.kernel.org,
	brcm80211-dev-list.pdl@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Masami Hiramatsu <mhiramat@kernel.org>,
	Arend van Spriel <arend.vanspriel@broadcom.com>,
	Franky Lin <franky.lin@broadcom.com>,
	Hante Meuleman <hante.meuleman@broadcom.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	Pieter-Paul Giesberts <pieterpg@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147125405701.9434.12911635695339175773.stgit@devbox>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/15/2016 11:40 AM, Masami Hiramatsu wrote:
> Check rtnl_lock is locked in brcmf_p2p_ifp_removed() by passing
> rtnl_locked flag. Actually the caller brcmf_del_if() checks whether
> the rtnl_lock is locked, but doesn't pass it to brcmf_p2p_ifp_removed().
>
> Without this fix, wpa_supplicant goes softlockup with rtnl_lock
> holding (this means all other process using netlink are locked up too)
>
> e.g.
> [ 4495.876627] INFO: task wpa_supplicant:7307 blocked for more than 10 seconds.
> [ 4495.876632]       Tainted: G        W       4.8.0-rc1+ #8
> [ 4495.876635] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> [ 4495.876638] wpa_supplicant  D ffff974c647b39a0     0  7307      1 0x00000000
> [ 4495.876644]  ffff974c647b39a0 0000000000000000 ffff974c00000000 ffff974c7dc59c58
> [ 4495.876651]  ffff974c6b7417c0 ffff974c645017c0 ffff974c647b4000 ffffffff86f16c08
> [ 4495.876657]  ffff974c645017c0 0000000000000246 00000000ffffffff ffff974c647b39b8
> [ 4495.876664] Call Trace:
> [ 4495.876671]  [<ffffffff868aeccc>] schedule+0x3c/0x90
> [ 4495.876676]  [<ffffffff868af065>] schedule_preempt_disabled+0x15/0x20
> [ 4495.876682]  [<ffffffff868b0996>] mutex_lock_nested+0x176/0x3b0
> [ 4495.876686]  [<ffffffff867a2067>] ? rtnl_lock+0x17/0x20
> [ 4495.876690]  [<ffffffff867a2067>] rtnl_lock+0x17/0x20
> [ 4495.876720]  [<ffffffffc0ae9a5d>] brcmf_p2p_ifp_removed+0x4d/0x70 [brcmfmac]
> [ 4495.876741]  [<ffffffffc0aebde6>] brcmf_remove_interface+0x196/0x1b0 [brcmfmac]
> [ 4495.876760]  [<ffffffffc0ae9901>] brcmf_p2p_del_vif+0x111/0x220 [brcmfmac]
> [ 4495.876777]  [<ffffffffc0adefab>] brcmf_cfg80211_del_iface+0x21b/0x270 [brcmfmac]
> [ 4495.876820]  [<ffffffffc097b39e>] nl80211_del_interface+0xfe/0x3a0 [cfg80211]
> [ 4495.876825]  [<ffffffff867ca335>] genl_family_rcv_msg+0x1b5/0x370
> [ 4495.876832]  [<ffffffff860e5d8d>] ? trace_hardirqs_on+0xd/0x10
> [ 4495.876836]  [<ffffffff867ca56d>] genl_rcv_msg+0x7d/0xb0
> [ 4495.876839]  [<ffffffff867ca4f0>] ? genl_family_rcv_msg+0x370/0x370
> [ 4495.876846]  [<ffffffff867c9a47>] netlink_rcv_skb+0x97/0xb0
> [ 4495.876849]  [<ffffffff867ca168>] genl_rcv+0x28/0x40
> [ 4495.876854]  [<ffffffff867c93c3>] netlink_unicast+0x1d3/0x2f0
> [ 4495.876860]  [<ffffffff867c933b>] ? netlink_unicast+0x14b/0x2f0
> [ 4495.876866]  [<ffffffff867c97cb>] netlink_sendmsg+0x2eb/0x3a0
> [ 4495.876870]  [<ffffffff8676dad8>] sock_sendmsg+0x38/0x50
> [ 4495.876874]  [<ffffffff8676e4df>] ___sys_sendmsg+0x27f/0x290
> [ 4495.876882]  [<ffffffff8628b935>] ? mntput_no_expire+0x5/0x3f0
> [ 4495.876888]  [<ffffffff8628b9be>] ? mntput_no_expire+0x8e/0x3f0
> [ 4495.876894]  [<ffffffff8628b935>] ? mntput_no_expire+0x5/0x3f0
> [ 4495.876899]  [<ffffffff8628bd44>] ? mntput+0x24/0x40
> [ 4495.876904]  [<ffffffff86267830>] ? __fput+0x190/0x200
> [ 4495.876909]  [<ffffffff8676f125>] __sys_sendmsg+0x45/0x80
> [ 4495.876914]  [<ffffffff8676f172>] SyS_sendmsg+0x12/0x20
> [ 4495.876918]  [<ffffffff868b5680>] entry_SYSCALL_64_fastpath+0x23/0xc1
> [ 4495.876924]  [<ffffffff860e2b8f>] ? trace_hardirqs_off_caller+0x1f/0xc0

This is probably caused by my commit:
a63b09872c1d ("brcmfmac: delete interface directly in code that sent fw request")
https://git.kernel.org/cgit/linux/kernel/git/kvalo/wireless-drivers-next.git/commit/?id=a63b09872c1dc0ce0da3628647da67a112b484bf

I changed condition for calling brcmf_remove_interface and it seems it broke P2P. Unfortunately I couldn't fully test my change due to firmware not supporting P2P.

I did similar fix for error path for P2P with commit
b50ddfa8530e ("brcmfmac: fix lockup when removing P2P interface after event timeout")
https://git.kernel.org/cgit/linux/kernel/git/kvalo/wireless-drivers-next.git/commit/?id=b50ddfa8530e9b5f52e873fdd6ff04f327a88799
so your change looks like a proper follow-up.


> Signed-off-by: Masami Hiramatsu <mhiramat@kernel.org>

Fixes: a63b09872c1d ("brcmfmac: delete interface directly in code that sent fw request")
Acked-by: Rafał Miłecki <rafal@milecki.pl>

Kalle: I'm acking this as bugfix for 4.8 release.
