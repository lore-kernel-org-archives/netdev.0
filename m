From: Alexander Popov <alex.popov@linux.com>
Subject: BUG at net/sctp/socket.c:7425
Date: Sun, 29 Jan 2017 03:35:31 +0300
Message-ID: <48766e1c-99c9-3a88-0fec-998bf4db9a3a@linux.com>
Reply-To: alex.popov@linux.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        syzkaller <syzkaller@googlegroups.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I'm running the syzkaller fuzzer for v4.10-rc4 (0aa0313f9d576affd7747cc3f179feb097d28990)
and have such a crash in sctp code:

[   38.423932] ------------[ cut here ]------------
[   38.424298] kernel BUG at net/sctp/socket.c:7425!
[   38.424583] invalid opcode: 0000 [#1] SMP KASAN
[   38.424839] Dumping ftrace buffer:
[   38.425031]    (ftrace buffer empty)
[   38.425232] Modules linked in: sctp libcrc32c snd_hda_codec_generic snd_hda_intel
snd_hda_codec snd_hda_core snd_intel8x0 snd_ens1370 snd_ac97_codec gameport snd_rawmidi
snd_hwdep snd_seq_device ac97_bus snd_pcm hid_generic joydev usbmouse snd_timer psmouse
usbhid e1000 snd hid parport_pc i2c_piix4 soundcore serio_raw parport input_leds pcspkr
floppy evbug mac_hid
[   38.427058] CPU: 0 PID: 1930 Comm: syz-executor12 Not tainted 4.10.0-rc4+ #2
[   38.427457] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS
Ubuntu-1.8.2-1ubuntu1 04/01/2014
[   38.427999] task: ffff88006945ca00 task.stack: ffff880053e40000
[   38.428364] RIP: 0010:sctp_sendmsg+0x29b3/0x3030 [sctp]
[   38.428719] RSP: 0018:ffff880053e478f8 EFLAGS: 00010297
[   38.429062] RAX: ffff88006945ca00 RBX: ffff880048d148c0 RCX: 0000000000000000
[   38.429636] RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffff88006d022c88
[   38.430051] RBP: ffff880053e47b70 R08: 0000000000000560 R09: ffff88007ffda680
[   38.430473] R10: 000000000000000a R11: 1ffffd400032be05 R12: dffffc0000000000
[   38.430915] R13: ffff880048d148c0 R14: 0000000000000000 R15: ffff880059ad9160
[   38.431390] FS:  00007f984a645700(0000) GS:ffff88006d000000(0000) knlGS:0000000000000000
[   38.431979] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   38.432405] CR2: 0000000020005fe0 CR3: 000000006400a000 CR4: 00000000000006f0
[   38.432827] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   38.433253] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[   38.433765] Call Trace:
[   38.433938]  ? sctp_id2assoc+0x330/0x330 [sctp]
[   38.434245]  ? wake_atomic_t_function+0x2b0/0x2b0
[   38.434545]  inet_sendmsg+0x128/0x3a0
[   38.434758]  ? inet_recvmsg+0x420/0x420
[   38.434983]  sock_sendmsg+0xcf/0x110
[   38.435192]  sock_write_iter+0x222/0x3c0
[   38.435421]  ? sock_sendmsg+0x110/0x110
[   38.435644]  ? iov_iter_init+0xaf/0x1d0
[   38.435867]  __vfs_write+0x3cb/0x640
[   38.436075]  ? do_iter_readv_writev+0x4c0/0x4c0
[   38.436338]  ? apparmor_file_permission+0x27/0x30
[   38.436618]  ? rw_verify_area+0xea/0x2b0
[   38.436853]  vfs_write+0x175/0x4e0
[   38.437053]  SyS_write+0xd8/0x1b0
[   38.437283]  ? SyS_read+0x1b0/0x1b0
[   38.437522]  entry_SYSCALL_64_fastpath+0x1e/0xad
[   38.437820] RIP: 0033:0x44f869
[   38.438013] RSP: 002b:00007f984a644b58 EFLAGS: 00000212 ORIG_RAX: 0000000000000001
[   38.438464] RAX: ffffffffffffffda RBX: 00007f984a645700 RCX: 000000000044f869
[   38.438886] RDX: 0000000000000018 RSI: 0000000020ac4fe8 RDI: 0000000000000004
[   38.439305] RBP: 00007ffe1d7be490 R08: 0000000000000000 R09: 0000000000000000
[   38.439712] R10: 0000000000000000 R11: 0000000000000212 R12: 0000000000000000
[   38.440145] R13: 00007ffe1d7be40f R14: 00007f984a6459c0 R15: 0000000000000000
[   38.440563] Code: c7 c7 10 1a 5c a0 e8 4d fb 76 e1 c6 44 24 68 01 e9 a2 f2 ff ff e8 be
34 e1 e0 8b 9c 24 98 00 00 00 e9 06 fd ff ff e8 ad 34 e1 e0 <0f> 0b e8 a6 34 e1 e0 4c 8b
4c 24 78 4c 8b 44 24 68 4c 89 f9 48
[   38.441881] RIP: sctp_sendmsg+0x29b3/0x3030 [sctp] RSP: ffff880053e478f8
[   38.442341] ---[ end trace c704b04c884389c0 ]---
[   38.442634] Kernel panic - not syncing: Fatal exception
[   38.443084] Dumping ftrace buffer:
[   38.443335]    (ftrace buffer empty)
[   38.443590] Kernel Offset: disabled


Unfortunately, I didn't manage to get a C program reproducing the crash (looks like race).
However, I stably hit it on my setup - so I can help fixing the issue.

The crash happens here:
	/* Let another process have a go.  Since we are going
	 * to sleep anyway.
	 */
	release_sock(sk);
	current_timeo = schedule_timeout(current_timeo);
>	BUG_ON(sk != asoc->base.sk);
	lock_sock(sk);

I've added some debugging output and see, that the original value of asoc->base.sk is
changed to the address of another struct sock, which appeared in sctp_endpoint_init()
shortly before the crash.

Hope for some assistance.
Best regards,
Alexander
