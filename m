From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: ravb/sh_eth/b44: BUG: sleeping function called from invalid context
Date: Wed, 14 Dec 2016 17:12:45 +0100
Message-ID: <CAMuHMdXfPtOKkfNakAgXRQxLTt2fh7Cr26inkp7KAxP6vD-oTg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux-Renesas <linux-renesas-soc@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Michael Chan <michael.chan@broadcom.com>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

When CONFIG_DEBUG_ATOMIC_SLEEP=y, running "ethtool -s eth0 speed 100"
on Salvator-X gives:

BUG: sleeping function called from invalid context at kernel/locking/mutex.c:97
in_atomic(): 1, irqs_disabled(): 128, pid: 1683, name: ethtool
CPU: 0 PID: 1683 Comm: ethtool Tainted: G        W
4.9.0-salvator-x-00426-g326519df42c65007-dirty #976
Hardware name: Renesas Salvator-X board based on r8a7796 (DT)
Call trace:
[<ffffff8008089400>] dump_backtrace+0x0/0x208
[<ffffff800808961c>] show_stack+0x14/0x1c
[<ffffff8008233424>] dump_stack+0x94/0xb4
[<ffffff80080c377c>] ___might_sleep+0x108/0x11c
[<ffffff80080c3814>] __might_sleep+0x84/0x94
[<ffffff800855db0c>] mutex_lock+0x24/0x40
[<ffffff800837610c>] phy_start_aneg+0x20/0x130
[<ffffff80083763b8>] phy_ethtool_ksettings_set+0xd0/0xe8
[<ffffff8008386724>] ravb_set_link_ksettings+0x4c/0xa4
[<ffffff80084a7b94>] ethtool_set_settings+0xec/0xfc
[<ffffff80084aa918>] dev_ethtool+0x188/0x17c4
[<ffffff80084bce3c>] dev_ioctl+0x53c/0x6b8
[<ffffff8008488acc>] sock_do_ioctl.constprop.45+0x3c/0x4c
[<ffffff80084897b4>] sock_ioctl+0x33c/0x370
[<ffffff8008171878>] vfs_ioctl+0x20/0x38
[<ffffff8008172198>] do_vfs_ioctl+0x844/0x954
[<ffffff80081722ec>] SyS_ioctl+0x44/0x68
[<ffffff80080830f0>] el0_svc_naked+0x24/0x28

ravb_set_link_ksettings() calls phy_ethtool_ksettings_set() with a spinlock
held and interrupts disabled, while phy_start_aneg() tries to obtain a mutex.

The same issue is present in sh_eth_set_link_ksettings() (verified) and
b44_set_link_ksettings() (code inspection).

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
