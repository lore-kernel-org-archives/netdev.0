From: Tommi Rantala <tt.rantala@gmail.com>
Subject: trinity locking troubles with ax25_recvmsg()
Date: Fri, 19 Apr 2013 14:30:35 +0300
Message-ID: <CA+ydwtriLJK9PSUfKObcNSMT1Z8PgLZOC9zJjux-xHmxQr4wXg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: LKML <linux-kernel@vger.kernel.org>, Dave Jones <davej@redhat.com>
To: netdev@vger.kernel.org, Joerg Reuter <jreuter@yaina.de>,
	Ralf Baechle <ralf@linux-mips.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

Noticed a huge load in one of my trinity test machines:
   14:07:10 up  6:11,  1 user,  load average: 39,00, 39,01, 38,95

But it is just 39x trinity child processes sitting there for couple of
hours in D state, plus "trinity-child38" in S state:

USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
...
root      3716  0.0  0.0 186620  3284 ?        Sl   07:57   0:00 polkitd
ttrantal  5576  0.0  0.1  22728  9124 ?        DNL  12:00   0:00 trinity-child33
ttrantal  5592  0.0  0.1  24636  8968 ?        DNL  12:00   0:00 trinity-child14
ttrantal  5593  0.0  0.1  26164 10684 ?        DNL  12:00   0:00 trinity-child25
ttrantal  5597  0.0  0.1  26620 10804 ?        DNL  12:00   0:00 trinity-child4
ttrantal  5599  0.0  0.1  31044  9268 ?        DNL  12:00   0:00 trinity-child17
ttrantal  5613  0.0  0.1  38804  8716 ?        DNL  12:00   0:00 trinity-child24
ttrantal  5621  0.0  0.2  38536 20528 ?        DNL  12:00   0:00 trinity-child27
ttrantal  5632  0.0  0.1  37508 11596 ?        SNL  12:00   0:00 trinity-child38
ttrantal  5663  0.0  0.2  31304 17656 ?        DNL  12:01   0:00 trinity-child35
ttrantal  5666  0.0  0.1  43656 13880 ?        DNL  12:01   0:01 trinity-child2
ttrantal  5689  0.0  0.3  54872 28748 ?        DNL  12:01   0:00 trinity-child9
ttrantal  5700  0.0  0.1  36600 10528 ?        DN   12:01   0:00 trinity-child23
...

[20091.121189] trinity-child38 S 0000000000000000     0  5632      1 0x00000000
[20091.121189]  ffff8802036adab8 0000000000000046 ffff8802036adfd8
ffff88020354a3e0
[20091.121189]  ffff8802036adfd8 ffff8802036adfd8 ffff88022afe47c0
ffff88020354a3e0
[20091.121189]  ffff88020354aab8 ffff8802036adc64 ffff88021b154b80
ffff88021b154a40
[20091.121189] Call Trace:
[20091.121189]  [<ffffffff822ce975>] schedule+0x55/0x60
[20091.121189]  [<ffffffff822cc1c6>] schedule_timeout+0x36/0x310
[20091.121189]  [<ffffffff811507d5>] ? trace_hardirqs_on_caller+0x155/0x1f0
[20091.121189]  [<ffffffff8115087d>] ? trace_hardirqs_on+0xd/0x10
[20091.121189]  [<ffffffff8111bc27>] ? prepare_to_wait_exclusive+0x77/0x90
[20091.121189]  [<ffffffff81ebd823>] __skb_recv_datagram+0x2e3/0x3d0
[20091.121189]  [<ffffffff81eb4fad>] ? lock_sock_nested+0x8d/0xa0
[20091.121189]  [<ffffffff81ebd1b0>] ?
csum_partial_copy_fromiovecend+0x220/0x220
[20091.121189]  [<ffffffff81ebd93d>] skb_recv_datagram+0x2d/0x30
[20091.121189]  [<ffffffff8205ef68>] ax25_recvmsg+0x78/0x260
[20091.121189]  [<ffffffff81ead2f2>] sock_aio_read+0x132/0x170
[20091.121189]  [<ffffffff8120f308>] do_sync_read+0x98/0xf0
[20091.121189]  [<ffffffff8120f9ad>] vfs_read+0xbd/0x180
[20091.121189]  [<ffffffff8120fe80>] sys_read+0x50/0xa0
[20091.121189]  [<ffffffff822d1da9>] system_call_fastpath+0x16/0x1b
[20091.121189] trinity-child35 D 0000000000000000     0  5663      1 0x00000004
[20091.121189]  ffff880210a2fe68 0000000000000046 ffff880210a2ffd8
ffff88022afe0000
[20091.121189]  ffff880210a2ffd8 ffff880210a2ffd8 ffff88022aa823e0
ffff88022afe0000
[20091.121189]  ffff880210a2fe58 ffff88021b154a90 ffff88021b154a40
ffff88021b154ae0
[20091.121189] Call Trace:
[20091.121189]  [<ffffffff81001000>] ? _stext+0xe48/0xe48
[20091.121189]  [<ffffffff822ce975>] schedule+0x55/0x60
[20091.121189]  [<ffffffff81eb162e>] __lock_sock+0x6e/0xa0
[20091.121189]  [<ffffffff8111bd70>] ? abort_exclusive_wait+0xb0/0xb0
[20091.121189]  [<ffffffff81eb4f5e>] ? lock_sock_nested+0x3e/0xa0
[20091.121189]  [<ffffffff81eb4f72>] lock_sock_nested+0x52/0xa0
[20091.121189]  [<ffffffff81001000>] ? _stext+0xe48/0xe48
[20091.121189]  [<ffffffff8205f17b>] ax25_listen+0x2b/0x70
[20091.121189]  [<ffffffff81eafca7>] sys_listen+0x57/0x80
[20091.121189]  [<ffffffff822d1da9>] system_call_fastpath+0x16/0x1b
[20091.121189]  [<ffffffff81001000>] ? _stext+0xe48/0xe48
[20091.121189] trinity-child15 D 0000000000000000     0  5781      1 0x00000004
[20091.121189]  ffff8801f992fd58 0000000000000046 ffff8801f992ffd8
ffff8801f9c723e0
[20091.121189]  ffff8801f992ffd8 ffff8801f992ffd8 ffff88020354c7c0
ffff8801f9c723e0
[20091.121189]  ffff8801f992fd48 ffff88021b154a90 ffff88021b154a40
ffff88021b154ae0
[20091.121189] Call Trace:
[20091.121189]  [<ffffffff822ce975>] schedule+0x55/0x60
[20091.121189]  [<ffffffff81eb162e>] __lock_sock+0x6e/0xa0
[20091.121189]  [<ffffffff8111bd70>] ? abort_exclusive_wait+0xb0/0xb0
[20091.121189]  [<ffffffff81eb4f5e>] ? lock_sock_nested+0x3e/0xa0
[20091.121189]  [<ffffffff81eb4f72>] lock_sock_nested+0x52/0xa0
[20091.121189]  [<ffffffff812112db>] ? get_empty_filp+0x13b/0x1e0
[20091.121189]  [<ffffffff8205fb28>] ax25_accept+0x78/0x280
[20091.121189]  [<ffffffff8111bd70>] ? abort_exclusive_wait+0xb0/0xb0
[20091.121189]  [<ffffffff81eafdf8>] sys_accept4+0x128/0x200
[20091.121189]  [<ffffffff8115087d>] ? trace_hardirqs_on+0xd/0x10
[20091.121189]  [<ffffffff822d06fb>] ? _raw_spin_unlock_irq+0x2b/0x50
[20091.121189]  [<ffffffff822d1dd5>] ? sysret_check+0x22/0x5d
[20091.121189]  [<ffffffff811507d5>] ? trace_hardirqs_on_caller+0x155/0x1f0
[20091.121189]  [<ffffffff814c222e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[20091.121189]  [<ffffffff81eafedb>] sys_accept+0xb/0x10
[20091.121189]  [<ffffffff822d1da9>] system_call_fastpath+0x16/0x1b
[20091.121189] trinity-child37 D 0000000000000000     0  5788      1 0x00000004
[20091.121189]  ffff8801fccabb78 0000000000000046 ffff8801fccabfd8
ffff88022aa70000
[20091.121189]  ffff8801fccabfd8 ffff8801fccabfd8 ffff8801f9840000
ffff88022aa70000
[20091.121189]  ffff8801fccabb68 ffff88021b154a90 ffff88021b154a40
ffff88021b154ae0
[20091.121189] Call Trace:
[20091.121189]  [<ffffffff822ce975>] schedule+0x55/0x60
[20091.121189]  [<ffffffff81eb162e>] __lock_sock+0x6e/0xa0
[20091.121189]  [<ffffffff8111bd70>] ? abort_exclusive_wait+0xb0/0xb0
[20091.121189]  [<ffffffff81eb4f5e>] ? lock_sock_nested+0x3e/0xa0
[20091.121189]  [<ffffffff81eb4f72>] lock_sock_nested+0x52/0xa0
[20091.121189]  [<ffffffff8143d450>] ? sock_has_perm+0x180/0x1e0
[20091.121189]  [<ffffffff8143d2d0>] ? selinux_setprocattr+0x790/0x790
[20091.121189]  [<ffffffff8205ef2d>] ax25_recvmsg+0x3d/0x260
[20091.121189]  [<ffffffff81ead97c>] sock_recvmsg+0xbc/0xf0
[20091.121189]  [<ffffffff8106b555>] ? native_sched_clock+0x35/0x80
[20091.121189]  [<ffffffff8106b5a9>] ? sched_clock+0x9/0x10
[20091.121189]  [<ffffffff81eb039e>] sys_recvfrom+0xde/0x150
[20091.121189]  [<ffffffff8115087d>] ? trace_hardirqs_on+0xd/0x10
[20091.121189]  [<ffffffff822d06fb>] ? _raw_spin_unlock_irq+0x2b/0x50
[20091.121189]  [<ffffffff822d1dd5>] ? sysret_check+0x22/0x5d
[20091.121189]  [<ffffffff811507d5>] ? trace_hardirqs_on_caller+0x155/0x1f0
[20091.121189]  [<ffffffff814c222e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[20091.121189]  [<ffffffff822d1da9>] system_call_fastpath+0x16/0x1b
[...]


[20091.121189] Showing all locks held in the system:
[20091.121189] 1 lock held by getty/3568:
[20091.121189]  #0:  (&ldata->atomic_read_lock){+.+...}, at:
[<ffffffff81582808>] n_tty_read+0x2b8/0x980
[20091.121189] 1 lock held by getty/3574:
[20091.121189]  #0:  (&ldata->atomic_read_lock){+.+...}, at:
[<ffffffff81582808>] n_tty_read+0x2b8/0x980
[20091.121189] 1 lock held by getty/3581:
[20091.121189]  #0:  (&ldata->atomic_read_lock){+.+...}, at:
[<ffffffff81582808>] n_tty_read+0x2b8/0x980
[20091.121189] 1 lock held by getty/3585:
[20091.121189]  #0:  (&ldata->atomic_read_lock){+.+...}, at:
[<ffffffff81582808>] n_tty_read+0x2b8/0x980
[20091.121189] 1 lock held by getty/3588:
[20091.121189]  #0:  (&ldata->atomic_read_lock){+.+...}, at:
[<ffffffff81582808>] n_tty_read+0x2b8/0x980
[20091.121189] 1 lock held by getty/3637:
[20091.121189]  #0:  (&ldata->atomic_read_lock){+.+...}, at:
[<ffffffff81582808>] n_tty_read+0x2b8/0x980
[20091.121189] 1 lock held by trinity-child38/5632:
[20091.121189]  #0:  (sk_lock-AF_AX25){+.+.+.}, at:
[<ffffffff8205ef2d>] ax25_recvmsg+0x3d/0x260
[20091.121189] 2 locks held by bash/6823:
[20091.121189]  #0:  (sysrq_key_table_lock){......}, at:
[<ffffffff8158a52e>] __handle_sysrq+0x2e/0x1b0
[20091.121189]  #1:  (tasklist_lock){.+.+..}, at: [<ffffffff81151b7c>]
debug_show_all_locks+0x5c/0x260
[20091.121189]


Looking at e.g. net/ax25/af_ax25.c and net/x25/af_x25.c side-by-side,
one glaring difference is that in x25 we release_sock() just before
skb_recv_datagram(), but not in ax25.

Tommi
