From: Hugh Dickins <hughd@google.com>
Subject: Re: 3.11-rc6 genetlink locking fix offends lockdep
Date: Tue, 20 Aug 2013 08:49:33 -0700 (PDT)
Message-ID: <alpine.LNX.2.00.1308200846180.971@eggly.anvils>
References: <alpine.LNX.2.00.1308182143370.906@eggly.anvils> <1376899214.14734.6.camel@jlt4.sipsolutions.net> <5211FAB3.7080400@huawei.com> <1376911362.14734.11.camel@jlt4.sipsolutions.net> <alpine.LNX.2.00.1308191147350.1505@eggly.anvils>
 <1376987338.13829.7.camel@jlt4.sipsolutions.net> <20130820090448.GB13078@pd.tnic>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Borislav Petkov <bp@alien8.de>,
	Ding Tianhong <dingtianhong@huawei.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Greg KH <gregkh@linuxfoundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Otcheretianski, Andrei" <andrei.otcheretianski@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	Thomas Graf <tgraf@suug.ch>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20130820090448.GB13078@pd.tnic>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 20 Aug 2013, Borislav Petkov wrote:
> On Tue, Aug 20, 2013 at 10:28:58AM +0200, Johannes Berg wrote:
> > Something like the patch below, perhaps? Completely untested so far.
> 
> Yeah, this one seems to fix it here (I was seeing the same lockdep splat
> as Hugh).

Not so good for me: it fixed the original splat, but a few seconds later:

[    4.073542] e1000e 0000:00:19.0: irq 43 for MSI/MSI-X
[    4.175849] e1000e 0000:00:19.0: irq 43 for MSI/MSI-X
[    4.176223] IPv6: ADDRCONF(NETDEV_UP): eth1: link is not ready
[    4.182322] iwlwifi 0000:03:00.0: L1 Enabled; Disabling L0S
[    4.182537] iwlwifi 0000:03:00.0: Radio type=0x0-0x3-0x1
[    4.405766] iwlwifi 0000:03:00.0: L1 Enabled; Disabling L0S
[    4.405973] iwlwifi 0000:03:00.0: Radio type=0x0-0x3-0x1
[    4.504441] IPv6: ADDRCONF(NETDEV_UP): wlan1: link is not ready
[    6.204569] input: PS/2 Generic Mouse as /devices/platform/i8042/serio1/serio2/input/input8
[    7.662343] 
[    7.662361] ======================================================
[    7.662393] [ INFO: possible circular locking dependency detected ]
[    7.662426] 3.11.0-rc6 #5 Not tainted
[    7.662462] -------------------------------------------------------
[    7.662500] wpa_supplicant/418 is trying to acquire lock:
[    7.662533]  (nlk->cb_mutex){+.+.+.}, at: [<ffffffff81480122>] __netlink_dump_start+0xae/0x14e
[    7.662603] 
[    7.662603] but task is already holding lock:
[    7.662638]  (genl_mutex){+.+.+.}, at: [<ffffffff8148204d>] genl_lock+0x12/0x14
[    7.662695] 
[    7.662695] which lock already depends on the new lock.
[    7.662695] 
[    7.662743] 
[    7.662743] the existing dependency chain (in reverse order) is:
[    7.662788] 
[    7.662788] -> #1 (genl_mutex){+.+.+.}:
[    7.662827]        [<ffffffff810b34d2>] __lock_acquire+0x865/0x956
[    7.662870]        [<ffffffff810b39fc>] lock_acquire+0x57/0x6d
[    7.662909]        [<ffffffff81583e52>] mutex_lock_nested+0x5e/0x345
[    7.662951]        [<ffffffff8148204d>] genl_lock+0x12/0x14
[    7.662989]        [<ffffffff814822cc>] ctrl_dumpfamily+0x2b/0xea
[    7.663029]        [<ffffffff8147f1b4>] netlink_dump+0x88/0x1d7
[    7.663069]        [<ffffffff81480187>] __netlink_dump_start+0x113/0x14e
[    7.663113]        [<ffffffff81482143>] genl_rcv_msg+0xf4/0x252
[    7.663152]        [<ffffffff81481742>] netlink_rcv_skb+0x3e/0x8c
[    7.663192]        [<ffffffff8148199b>] genl_rcv+0x24/0x34
[    7.663228]        [<ffffffff814811ca>] netlink_unicast+0xed/0x17a
[    7.663270]        [<ffffffff814815d4>] netlink_sendmsg+0x2fb/0x345
[    7.663311]        [<ffffffff814503f7>] sock_sendmsg+0x79/0x8e
[    7.663351]        [<ffffffff81450707>] ___sys_sendmsg+0x231/0x2be
[    7.663391]        [<ffffffff81453228>] __sys_sendmsg+0x3d/0x5e
[    7.663431]        [<ffffffff81453256>] SyS_sendmsg+0xd/0x19
[    7.663469]        [<ffffffff81587c12>] system_call_fastpath+0x16/0x1b
[    7.663513] 
[    7.663513] -> #0 (nlk->cb_mutex){+.+.+.}:
[    7.663554]        [<ffffffff810b1fb0>] validate_chain.isra.21+0x836/0xe8e
[    7.663599]        [<ffffffff810b34d2>] __lock_acquire+0x865/0x956
[    7.663640]        [<ffffffff810b39fc>] lock_acquire+0x57/0x6d
[    7.663679]        [<ffffffff81583e52>] mutex_lock_nested+0x5e/0x345
[    7.663722]        [<ffffffff81480122>] __netlink_dump_start+0xae/0x14e
[    7.663765]        [<ffffffff81482143>] genl_rcv_msg+0xf4/0x252
[    7.663804]        [<ffffffff81481742>] netlink_rcv_skb+0x3e/0x8c
[    7.663844]        [<ffffffff8148199b>] genl_rcv+0x24/0x34
[    7.663881]        [<ffffffff814811ca>] netlink_unicast+0xed/0x17a
[    7.663921]        [<ffffffff814815d4>] netlink_sendmsg+0x2fb/0x345
[    7.663961]        [<ffffffff814503f7>] sock_sendmsg+0x79/0x8e
[    7.664000]        [<ffffffff81450707>] ___sys_sendmsg+0x231/0x2be
[    7.664041]        [<ffffffff81453228>] __sys_sendmsg+0x3d/0x5e
[    7.664081]        [<ffffffff81453256>] SyS_sendmsg+0xd/0x19
[    7.664119]        [<ffffffff81587c12>] system_call_fastpath+0x16/0x1b
[    7.664161] 
[    7.664161] other info that might help us debug this:
[    7.664161] 
[    7.666543]  Possible unsafe locking scenario:
[    7.666543] 
[    7.668877]        CPU0                    CPU1
[    7.670032]        ----                    ----
[    7.671165]   lock(genl_mutex);
[    7.672298]                                lock(nlk->cb_mutex);
[    7.673424]                                lock(genl_mutex);
[    7.674532]   lock(nlk->cb_mutex);
[    7.675607] 
[    7.675607]  *** DEADLOCK ***
[    7.675607] 
[    7.678696] 2 locks held by wpa_supplicant/418:
[    7.679704]  #0:  (cb_lock){++++++}, at: [<ffffffff8148198c>] genl_rcv+0x15/0x34
[    7.680772]  #1:  (genl_mutex){+.+.+.}, at: [<ffffffff8148204d>] genl_lock+0x12/0x14
[    7.681840] 
[    7.681840] stack backtrace:
[    7.683933] CPU: 0 PID: 418 Comm: wpa_supplicant Not tainted 3.11.0-rc6 #5
[    7.685022] Hardware name: LENOVO 4174EH1/4174EH1, BIOS 8CET51WW (1.31 ) 11/29/2011
[    7.686118]  ffffffff81cc8750 ffff88022b8117b8 ffffffff8157cf90 0000000000000006
[    7.687230]  ffffffff81d0a450 ffff88022b811808 ffffffff8157a8a8 0000000000000001
[    7.688347]  ffff880230d0a080 ffff880230d0a080 ffff880230d0a778 ffff880230d0a080
[    7.689461] Call Trace:
[    7.690551]  [<ffffffff8157cf90>] dump_stack+0x4f/0x84
[    7.691657]  [<ffffffff8157a8a8>] print_circular_bug+0x2ad/0x2be
[    7.692775]  [<ffffffff810b1fb0>] validate_chain.isra.21+0x836/0xe8e
[    7.693893]  [<ffffffff810b34d2>] __lock_acquire+0x865/0x956
[    7.695012]  [<ffffffff81480122>] ? __netlink_dump_start+0xae/0x14e
[    7.696137]  [<ffffffff810b39fc>] lock_acquire+0x57/0x6d
[    7.697275]  [<ffffffff81480122>] ? __netlink_dump_start+0xae/0x14e
[    7.698404]  [<ffffffff81583e52>] mutex_lock_nested+0x5e/0x345
[    7.699541]  [<ffffffff81480122>] ? __netlink_dump_start+0xae/0x14e
[    7.700696]  [<ffffffff81586c32>] ? _raw_read_unlock+0x2d/0x4a
[    7.701840]  [<ffffffff81480122>] __netlink_dump_start+0xae/0x14e
[    7.702991]  [<ffffffff81482143>] genl_rcv_msg+0xf4/0x252
[    7.704143]  [<ffffffff81536380>] ? nl80211_dump_mpath+0x10d/0x10d
[    7.705317]  [<ffffffff8148204f>] ? genl_lock+0x14/0x14
[    7.706464]  [<ffffffff81481742>] netlink_rcv_skb+0x3e/0x8c
[    7.707614]  [<ffffffff8148199b>] genl_rcv+0x24/0x34
[    7.708756]  [<ffffffff814811ca>] netlink_unicast+0xed/0x17a
[    7.709890]  [<ffffffff814815d4>] netlink_sendmsg+0x2fb/0x345
[    7.711018]  [<ffffffff814503f7>] sock_sendmsg+0x79/0x8e
[    7.712144]  [<ffffffff810f86fa>] ? might_fault+0x52/0xa2
[    7.713280]  [<ffffffff81450707>] ___sys_sendmsg+0x231/0x2be
[    7.714400]  [<ffffffff810fd37b>] ? handle_mm_fault+0x47d/0x49d
[    7.715525]  [<ffffffff81087aa5>] ? up_read+0x1b/0x32
[    7.716663]  [<ffffffff81053c34>] ? __do_page_fault+0x370/0x414
[    7.717789]  [<ffffffff811488e4>] ? fget_light+0x115/0x377
[    7.718922]  [<ffffffff810f86fa>] ? might_fault+0x52/0xa2
[    7.720052]  [<ffffffff81453228>] __sys_sendmsg+0x3d/0x5e
[    7.721192]  [<ffffffff81453256>] SyS_sendmsg+0xd/0x19
[    7.722309]  [<ffffffff81587c12>] system_call_fastpath+0x16/0x1b
[   11.044520] wlan1: authenticate with c0:3f:0e:ad:ff:ee
[   11.096583] wlan1: send auth to c0:3f:0e:ad:ff:ee (try 1/3)
[   11.099448] wlan1: authenticated
[   11.100813] wlan1: associate with c0:3f:0e:ad:ff:ee (try 1/3)
[   11.105771] wlan1: RX AssocResp from c0:3f:0e:ad:ff:ee (capab=0x411 status=0 aid=6)
[   11.114801] IPv6: ADDRCONF(NETDEV_CHANGE): wlan1: link becomes ready
[   11.115884] wlan1: associated
