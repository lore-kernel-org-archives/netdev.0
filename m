From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [RFC net-next 4/4] net: phy: Correctly process PHY_HALTED in phy_stop_machine()
Date: Mon, 30 Oct 2017 14:56:25 +0100
Message-ID: <CAMuHMdUHdEuhMRzGGpg4ev_3pJy6ahGh4YMJjvrgBJAKgJLa7A@mail.gmail.com>
References: <20171025232124.14120-1-f.fainelli@gmail.com> <20171025232124.14120-5-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Marc Gonzalez <marc_gonzalez@sigmadesigns.com>,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>, opendmb@gmail.com,
        Mason <slash.tmp@free.fr>, David Daney <david.daney@cavium.com>,
        Geert Uytterhoeven <geert+renesas@glider.be>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:48267 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752466AbdJ3N41 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 09:56:27 -0400
Received: by mail-qk0-f193.google.com with SMTP id d67so16189827qkg.5
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 06:56:27 -0700 (PDT)
In-Reply-To: <20171025232124.14120-5-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

On Thu, Oct 26, 2017 at 1:21 AM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> Marc reported that he was not getting the PHY library adjust_link()
> callback function to run when calling phy_stop() + phy_disconnect()
> which does not indeed happen because we set the state machine to
> PHY_HALTED but we don't get to run it to process this state past that
> point.
>
> Fix this with a synchronous call to phy_state_machine() in order to have
> the state machine actually act on PHY_HALTED, set the PHY device's link
> down, turn the network device's carrier off and finally call the
> adjust_link() function.
>
> At the end of phy_state_machine() though, if we are going to be moving
> from PHY_HALTED to PHY_HALTED, do not reschedule the state machine, this
> is pointless.
>
> Reported-by: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
> Fixes: a390d1f379cf ("phylib: convert state_queue work to delayed_work")
> Signed-off-by: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Thanks for your patch!

Unfortunately, after applying this one, the last in your series, both
sh73a0/kzm9g and r8a73a4/ape6evm start crashing again in the system
suspend/resume path, due to register accesses while the device is already
suspended:

PM: suspend entry (deep)
PM: Syncing filesystems ... done.
Freezing user space processes ... (elapsed 0.000 seconds) done.
OOM killer disabled.
Freezing remaining freezable tasks ... (elapsed 0.000 seconds) done.
PM: suspend devices took 0.100 seconds
Unhandled fault: imprecise external abort (0x1406) at 0x0005b950
Disabling non-boot CPUs ...
pgd = c0004000
[0005b950] *pgd=00000000
Internal error: : 1406 [#1] SMP ARM
Modules linked in:
CPU: 1 PID: 17 Comm: kworker/1:0 Not tainted
4.14.0-rc5-kzm9g-00454-g13bf0e7c8794d746 #1002
Hardware name: Generic SH73A0 (Flattened Device Tree)
Workqueue: events linkwatch_event
task: df490480 task.stack: df492000
PC is at __smsc911x_reg_read+0x1c/0x60
LR is at smsc911x_tx_get_txstatus+0x64/0x7c
pc : [<c03cc77c>]    lr : [<c03cd000>]    psr: 20030093
sp : df493d98  ip : 00000000  fp : c09313a0
r10: c0931330  r9 : c0909a40  r8 : 00000000
r7 : 00030013  r6 : df705e08  r5 : df705dc0  r4 : 001c0000
r3 : e0903000  r2 : 00000001  r1 : e0903048  r0 : 00000000
Flags: nzCv  IRQs off  FIQs on  Mode SVC_32  ISA ARM  Segment none
Control: 10c5387d  Table: 5ed1804a  DAC: 00000051
Process kworker/1:0 (pid: 17, stack limit = 0xdf492210)
Stack: (0xdf493d98 to 0xdf494000)
3d80:                                                       c03cd2dc df705800
3da0: df705dc0 c063b2b0 df493e18 c03cd248 c03cd2dc df705800 df705800 c03cd2e8
3dc0: c03cd2dc def4b0e4 df705800 c063b2b0 df493e18 c048a13c def4b0e0 dedbb300
3de0: df705800 c04ab388 dedbb300 df705800 def4b000 c04a5e10 0000002a 00000000
3e00: c04a5a8c c01ffcfc c04aabd0 dedbb300 014000c0 df493e47 00000000 00000000
3e20: 00000000 00000000 00000000 00000000 00000050 00000000 df493e47 014000c0
3e40: 00000000 dedbb300 df705800 00000010 00000000 00000000 00000000 c0931330
3e60: c09313a0 c04aac00 00000000 00000000 00000000 00000000 00000000 00000000
3e80: 014000c0 df705800 df705800 c09313a0 df493ee0 c04aac9c 014000c0 00000000
3ea0: 00000000 df705800 c0931330 c04aace0 014000c0 00000000 00000000 c048ef18
3ec0: df705800 df705800 00000000 00000000 df705800 c04abee0 df705ab0 c04ac150
3ee0: df493ee0 df493ee0 c109a9f8 df436d00 c0931330 dfbd7bc0 df493f30 dfbdae00
3f00: 00000000 00000000 00000001 c04ac1bc c04ac198 c013a6f8 00000001 00000000
3f20: c013a680 00000000 00000000 00000000 c0931330 00000000 00000000 c0758db6
3f40: c0905900 df436d00 dfbd7bc0 dfbd7bc0 df492000 dfbd7bf4 c0905900 df436d18
3f60: 00000008 c013aecc df490480 df436400 df42c900 00000000 df443e6c df436d00
3f80: c013ac14 df436438 00000000 c0140200 df42c900 c01400dc 00000000 00000000
3fa0: 00000000 00000000 00000000 c01071c8 00000000 00000000 00000000 00000000
3fc0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
3fe0: 00000000 00000000 00000000 00000000 00000013 00000000 7fdfffff fff7fdff
[<c03cc77c>] (__smsc911x_reg_read) from [<c03cd000>]
(smsc911x_tx_get_txstatus+0x64/0x7c)
[<c03cd000>] (smsc911x_tx_get_txstatus) from [<c03cd248>]
(smsc911x_tx_update_txcounters+0x14/0xa8)
[<c03cd248>] (smsc911x_tx_update_txcounters) from [<c03cd2e8>]
(smsc911x_get_stats+0xc/0x58)
[<c03cd2e8>] (smsc911x_get_stats) from [<c048a13c>] (dev_get_stats+0x54/0xa4)
[<c048a13c>] (dev_get_stats) from [<c04ab388>] (rtnl_fill_stats+0x38/0x118)
[<c04ab388>] (rtnl_fill_stats) from [<c04a5e10>] (rtnl_fill_ifinfo+0x5f0/0xf74)
[<c04a5e10>] (rtnl_fill_ifinfo) from [<c04aac00>]
(rtmsg_ifinfo_build_skb+0x6c/0xc0)
[<c04aac00>] (rtmsg_ifinfo_build_skb) from [<c04aac9c>]
(rtmsg_ifinfo_event.part.5+0x1c/0x40)
[<c04aac9c>] (rtmsg_ifinfo_event.part.5) from [<c04aace0>]
(rtmsg_ifinfo+0x20/0x28)
[<c04aace0>] (rtmsg_ifinfo) from [<c048ef18>] (netdev_state_change+0x48/0x54)
[<c048ef18>] (netdev_state_change) from [<c04abee0>]
(linkwatch_do_dev+0x50/0x74)
[<c04abee0>] (linkwatch_do_dev) from [<c04ac150>]
(__linkwatch_run_queue+0x124/0x16c)
[<c04ac150>] (__linkwatch_run_queue) from [<c04ac1bc>]
(linkwatch_event+0x24/0x34)
[<c04ac1bc>] (linkwatch_event) from [<c013a6f8>] (process_one_work+0x240/0x3fc)
[<c013a6f8>] (process_one_work) from [<c013aecc>] (worker_thread+0x2b8/0x3f4)
[<c013aecc>] (worker_thread) from [<c0140200>] (kthread+0x124/0x144)
[<c0140200>] (kthread) from [<c01071c8>] (ret_from_fork+0x14/0x2c)
Code: e5903000 e0831001 e5910000 f57ff04f (e12fff1e)
---[ end trace e71c0b5246c61082 ]---

Gr{oetje,eeting}s,

                        Geert
