From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [patch net-next RFC 0/6] switchdev: introduce tranction enfra and
 for pre-commit split
Date: Mon, 21 Sep 2015 00:23:24 -0700
Message-ID: <CAE4R7bArD_uYEnsQtvYg94qsydtEJAjYwC9Q3ZfaZH8Wqs0SEQ@mail.gmail.com>
References: <1442665751-10949-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>, eladr@mellanox.com,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:36532 "EHLO
	mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752192AbbIUHXo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 03:23:44 -0400
Received: by oibi136 with SMTP id i136so53892344oib.3
        for <netdev@vger.kernel.org>; Mon, 21 Sep 2015 00:23:43 -0700 (PDT)
In-Reply-To: <1442665751-10949-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 19, 2015 at 5:29 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> Jiri Pirko (6):
>   switchdev: rename "trans" to "trans_ph".
>   switchdev: introduce transaction infrastructure for attr_set and
>     obj_add
>   rocker: switch to local transaction phase enum
>   switchdev: move transaction phase enum under transaction structure
>   rocker: use switchdev transaction queue for allocated memory
>   switchdev: split commit and prepare phase into two callbacks

Patches compile, but first test bombs.  Cut-and-paste of dump at end
of this email.

I'm not sure I'm liking this patchset because it looks like a way for
switchdev drivers to easily opt-out of the prepare-commit transaction
model by simply not implementing the *_pre op.  I would rather drivers
explicitly handle the PREPARE phase in code, even if that means
skipping it gracefully (in code) with a comment (in code) explaining
why it does not matter for this device/operation.  That's what DSA had
done, mostly because it was a retro-fit.

Also, the patchset removes the ABORT callback in case of a rollback
due to a failed PREPARE.  We can't make the assumption that it's just
a memory list to destroy on ABORT.  The driver, on PREPARE, may have
reserved device space or staged an operation on the device which we'll
need to undo on ABORT.

So we need ABORT back, and we need PREPARE to not be optional, so
what's left list enqueue/dequeue helpers, which I'm not seeing much
value in up-leveling as the driver can do list_add/del itself.

Am I missing something?  I didn't see a motivation statement for the
RFC so I'm not sure where you wanted to take this.

-scott



[    1.998791] BUG: unable to handle kernel NULL pointer dereference
at 0000000000000008
[    2.000005] IP: [<ffffffffa005a2c5>]
rocker_port_kzalloc.isra.50+0x5/0x10 [rocker]
[    2.000005] PGD 0
[    2.000005] Oops: 0000 [#1] SMP
[    2.000005] Modules linked in: floppy(+) ata_piix(+) libata
rocker(+) virtio_pci(+) virtio_ring virtio scsi_mod
[    2.000005] CPU: 0 PID: 91 Comm: modprobe Not tainted 4.2.0+ #3
[    2.000005] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
BIOS rel-1.8.2-0-g33fbe13 by qemu-project.org 04/01/2014
[    2.000005] task: ffff88000f5e0800 ti: ffff88000f5f8000 task.ti:
ffff88000f5f8000
[    2.000005] RIP: 0010:[<ffffffffa005a2c5>]  [<ffffffffa005a2c5>]
rocker_port_kzalloc.isra.50+0x5/0x10 [rocker]
[    2.000005] RSP: 0018:ffff88000f5fba20  EFLAGS: 00010246
[    2.000005] RAX: ffff88000f17c050 RBX: ffff88000b400000 RCX: 0000000000000020
[    2.000005] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000000000
[    2.000005] RBP: 0000000000000000 R08: 0000000000000000 R09: ffffffffa0058680
[    2.000005] R10: 0000000000000001 R11: 0000000000009319 R12: 0000000000000000
[    2.000005] R13: ffff88000f5b7000 R14: ffff88000f5b7840 R15: 0000000000000000
[    2.000005] FS:  00007fd132237700(0000) GS:ffff88000fc00000(0000)
knlGS:0000000000000000
[    2.000005] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[    2.000005] CR2: 0000000000000008 CR3: 000000000f5d5000 CR4: 00000000000006f0
[    2.000005] Stack:
[    2.000005]  ffffffffa005a32a 0000000000000001 00ff88000f5b7000
ffffffff8175725a
[    2.000005]  ffffffffa0057750 0000000000000000 ffffffffa0058680
000000200000001a
[    2.000005]  ffff88000b400000 0000000000000000 ffff88000ea06000
ffff88000f5b7000
[    2.000005] Call Trace:
[    2.000005]  [<ffffffffa005a32a>] ? rocker_cmd_exec+0x5a/0x1f0 [rocker]
[    2.000005]  [<ffffffffa0057750>] ?
rocker_cmd_get_port_stats_prep+0x90/0x90 [rocker]
[    2.000005]  [<ffffffffa0058680>] ?
rocker_cmd_get_port_settings_phys_name_proc+0xb0/0xb0 [rocker]
[    2.000005]  [<ffffffffa005e37a>] ? rocker_probe+0xb6a/0xe59 [rocker]
[    2.000005]  [<ffffffff812b6608>] ? local_pci_probe+0x48/0xa0
[    2.000005]  [<ffffffff812b7142>] ? pci_device_probe+0x112/0x130
[    2.000005]  [<ffffffff81384b46>] ? driver_probe_device+0x196/0x2a0
[    2.000005]  [<ffffffff81384c50>] ? driver_probe_device+0x2a0/0x2a0
[    2.000005]  [<ffffffff81384cdd>] ? __driver_attach+0x8d/0x90
[    2.000005]  [<ffffffff81384c50>] ? driver_probe_device+0x2a0/0x2a0
[    2.000005]  [<ffffffff81382f3c>] ? bus_for_each_dev+0x4c/0x80
[    2.000005]  [<ffffffff81384219>] ? bus_add_driver+0x119/0x220
[    2.000005]  [<ffffffffa0065000>] ? 0xffffffffa0065000
[    2.000005]  [<ffffffff813854ba>] ? driver_register+0x5a/0xe0
[    2.000005]  [<ffffffffa0065000>] ? 0xffffffffa0065000
[    2.000005]  [<ffffffffa0065033>] ? rocker_module_init+0x33/0x1000 [rocker]
[    2.000005]  [<ffffffff81002110>] ? do_one_initcall+0x90/0x1e0
[    2.000005]  [<ffffffff81110bd0>] ? do_init_module+0x50/0x1d8
[    2.000005]  [<ffffffff810d632c>] ? load_module+0x1c1c/0x2240
[    2.000005]  [<ffffffff810d33e0>] ? show_initstate+0x50/0x50
[    2.000005]  [<ffffffff810d6a54>] ? SyS_init_module+0x104/0x130
[    2.000005]  [<ffffffff81508ef6>] ? entry_SYSCALL_64_fastpath+0x16/0x75
[    2.000005] Code: 48 89 c1 48 c7 c2 10 dc 15 81 48 89 c6 e8 e4 0d
4a e1 48 8b 3b e8 1c 1b 4a e1 eb b6 66 2e 0f 1f 84 00 00 00 00 00 48
89 d1 89 f2 <8b> 77 08 e9 73 ff ff ff 0f 1f 00 48 83 ec 68 4c 89 7c 24
60 41
[    2.000005] RIP  [<ffffffffa005a2c5>]
rocker_port_kzalloc.isra.50+0x5/0x10 [rocker]
