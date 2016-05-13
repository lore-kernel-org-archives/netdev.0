From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] Bluetooth: Fix l2cap_sock_teardown_cb race condition with bt_accept_dequeue
Date: Fri, 13 May 2016 07:54:35 -0700
Message-ID: <45EE47FA-D319-4091-941A-C4005E32B572@holtmann.org>
References: <1462842935-136364-1-git-send-email-zhaoyichen@google.com>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "Gustavo F. Padovan" <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Yichen Zhao <zhaoyichen@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462842935-136364-1-git-send-email-zhaoyichen@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Yichen,

> Fix a race condition between l2cap_sock_teardown_cb on an L2CAP socket
> and bt_accept_dequeue on its parent socket. When the race condition is
> encountered bt_accept_dequeue may call bt_accept_unlink on an already
> unlinked socket and result in a NULL pointer dereference.
> 
> Even if bt_accept_unlink is not called by bt_accept_dequeue,
> bt_accept_unlink called by l2cap_sock_teardown_cb can race with
> list_for_each_entry_safe in bt_accept_dequeue, causing the latter to
> loop indefinitely on the unlinked socket, until release_sock crashes
> with a NULL pointer dereference when the sock pointer is freed.
> 
> The race condition is fixed by locking the parent socket in
> l2cap_sock_teardown_cb.
> 
> [50510.241632] BUG: unable to handle kernel NULL pointer dereference at 00000000000001a8
> [50510.241694] IP: [<ffffffffc01243f7>] bt_accept_unlink+0x47/0xa0 [bluetooth]
> [50510.241759] PGD 0
> [50510.241776] Oops: 0002 [#1] SMP
> [50510.241802] Modules linked in: rtl8192cu rtl_usb rtlwifi rtl8192c_common 8021q garp stp mrp llc rfcomm bnep nls_iso8859_1 intel_rapl x86_pkg_temp_thermal intel_powerclamp coretemp arc4 ath9k ath9k_common ath9k_hw ath kvm eeepc_wmi asus_wmi mac80211 snd_hda_codec_hdmi snd_hda_codec_realtek sparse_keymap crct10dif_pclmul snd_hda_codec_generic crc32_pclmul snd_hda_intel snd_hda_controller cfg80211 snd_hda_codec i915 snd_hwdep snd_pcm ghash_clmulni_intel snd_timer snd soundcore serio_raw cryptd drm_kms_helper drm i2c_algo_bit shpchp ath3k mei_me lpc_ich btusb bluetooth 6lowpan_iphc mei lp parport wmi video mac_hid psmouse ahci libahci r8169 mii
> [50510.242279] CPU: 0 PID: 934 Comm: krfcommd Not tainted 3.16.0-49-generic #65~14.04.1-Ubuntu
> [50510.242327] Hardware name: ASUSTeK Computer INC. VM40B/VM40B, BIOS 1501 12/09/2014
> [50510.242370] task: ffff8800d9068a30 ti: ffff8800d7a54000 task.ti: ffff8800d7a54000
> [50510.242413] RIP: 0010:[<ffffffffc01243f7>]  [<ffffffffc01243f7>] bt_accept_unlink+0x47/0xa0 [bluetooth]
> [50510.242480] RSP: 0018:ffff8800d7a57d58  EFLAGS: 00010246
> [50510.242511] RAX: 0000000000000000 RBX: ffff880119bb8c00 RCX: ffff880119bb8eb0
> [50510.242552] RDX: ffff880119bb8eb0 RSI: 00000000fffffe01 RDI: ffff880119bb8c00
> [50510.242592] RBP: ffff8800d7a57d60 R08: 0000000000000283 R09: 0000000000000001
> [50510.242633] R10: 0000000000000000 R11: 0000000000000000 R12: ffff8800d8da9eb0
> [50510.242673] R13: ffff8800d74fdb80 R14: ffff880119bb8c00 R15: ffff8800d8da9c00
> [50510.242715] FS:  0000000000000000(0000) GS:ffff88011fa00000(0000) knlGS:0000000000000000
> [50510.242761] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [50510.242794] CR2: 00000000000001a8 CR3: 0000000001c13000 CR4: 00000000001407f0
> [50510.242835] Stack:
> [50510.242849]  ffff880119bb8eb0 ffff8800d7a57da0 ffffffffc0124506 ffff8800d8da9eb0
> [50510.242899]  ffff8800d8da9c00 ffff8800d9068a30 0000000000000000 ffff8800d74fdb80
> [50510.242949]  ffff8800d6f85208 ffff8800d7a57e08 ffffffffc0159985 000000000000001f
> [50510.242999] Call Trace:
> [50510.243027]  [<ffffffffc0124506>] bt_accept_dequeue+0xb6/0x180 [bluetooth]
> [50510.243085]  [<ffffffffc0159985>] l2cap_sock_accept+0x125/0x220 [bluetooth]
> [50510.243128]  [<ffffffff810a1b30>] ? wake_up_state+0x20/0x20
> [50510.243163]  [<ffffffff8164946e>] kernel_accept+0x4e/0xa0
> [50510.243200]  [<ffffffffc05b97cd>] rfcomm_run+0x1ad/0x890 [rfcomm]
> [50510.243238]  [<ffffffffc05b9620>] ? rfcomm_process_rx+0x8a0/0x8a0 [rfcomm]
> [50510.243281]  [<ffffffff81091572>] kthread+0xd2/0xf0
> [50510.243312]  [<ffffffff810914a0>] ? kthread_create_on_node+0x1c0/0x1c0
> [50510.243353]  [<ffffffff8176e9d8>] ret_from_fork+0x58/0x90
> [50510.243387]  [<ffffffff810914a0>] ? kthread_create_on_node+0x1c0/0x1c0
> [50510.243424] Code: 00 48 8b 93 b8 02 00 00 48 8d 83 b0 02 00 00 48 89 51 08 48 89 0a 48 89 83 b0 02 00 00 48 89 83 b8 02 00 00 48 8b 83 c0 02 00 00 <66> 83 a8 a8 01 00 00 01 48 c7 83 c0 02 00 00 00 00 00 00 f0 ff
> [50510.243685] RIP  [<ffffffffc01243f7>] bt_accept_unlink+0x47/0xa0 [bluetooth]
> [50510.243737]  RSP <ffff8800d7a57d58>
> [50510.243758] CR2: 00000000000001a8
> [50510.249457] ---[ end trace bb984f932c4e3ab3 ]---
> 
> Signed-off-by: Yichen Zhao <zhaoyichen@google.com>
> ---
> net/bluetooth/l2cap_sock.c | 18 +++++++++++++++++-
> 1 file changed, 17 insertions(+), 1 deletion(-)
> 
> diff --git a/net/bluetooth/l2cap_sock.c b/net/bluetooth/l2cap_sock.c
> index e4cae72..ff1c821 100644
> --- a/net/bluetooth/l2cap_sock.c
> +++ b/net/bluetooth/l2cap_sock.c
> @@ -1307,6 +1307,15 @@ static void l2cap_sock_teardown_cb(struct l2cap_chan *chan, int err)
> 
> 	BT_DBG("chan %p state %s", chan, state_to_string(chan->state));
> 
> +	parent = bt_sk(sk)->parent;
> +
> +	/* The parent sock must be locked if its state is mutated by
> +	 * bt_accept_unlink. It must be locked before sk to maintain the same
> +	 * locking order as bt_accept_dequeue.
> +	 */
> +	if (parent)
> +		lock_sock_nested(parent, L2CAP_NESTING_PARENT);
> +
> 	/* This callback can be called both for server (BT_LISTEN)
> 	 * sockets as well as "normal" ones. To avoid lockdep warnings
> 	 * with child socket locking (through l2cap_sock_cleanup_listen)
> @@ -1316,7 +1325,11 @@ static void l2cap_sock_teardown_cb(struct l2cap_chan *chan, int err)
> 	 */
> 	lock_sock_nested(sk, atomic_read(&chan->nesting));
> 
> -	parent = bt_sk(sk)->parent;
> +	/* bt_accept_unlink could have been called before locking parent. */
> +	if (parent && !bt_sk(sk)->parent) {
> +		release_sock(parent);
> +		parent = NULL;
> +	}
> 
> 	sock_set_flag(sk, SOCK_ZAPPED);
> 
> @@ -1348,6 +1361,9 @@ static void l2cap_sock_teardown_cb(struct l2cap_chan *chan, int err)
> 	}
> 
> 	release_sock(sk);
> +
> +	if (parent)
> +		release_sock(parent);

so I am not big fan of the conditional locking in case of parent is set or not. Do you have a test case that reproduces the mentioned race. It would love to have that in tools/l2cap-tester or similar. Maybe the code needs some restructuring to avoid the conditional locking.

Regards

Marcel
