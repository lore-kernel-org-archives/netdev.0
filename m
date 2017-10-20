From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH] net: ethtool: remove error check for legacy setting
 transceiver type
Date: Fri, 20 Oct 2017 09:15:50 +0200
Message-ID: <CAMuHMdUFHP-nmft72q7_ZGqqUzuOoj0q+6+fyfQF-XkfnFpLvA@mail.gmail.com>
References: <20171019233208.15444-1-niklas.soderlund+renesas@ragnatech.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Linux-Renesas <linux-renesas-soc@vger.kernel.org>,
        Renjith R V <renjith.rv@quest-global.com>
To: =?UTF-8?Q?Niklas_S=C3=B6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <20171019233208.15444-1-niklas.soderlund+renesas@ragnatech.se>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Niklas,

On Fri, Oct 20, 2017 at 1:32 AM, Niklas S=C3=B6derlund
<niklas.soderlund+renesas@ragnatech.se> wrote:
> Commit 9cab88726929605 ("net: ethtool: Add back transceiver type")
> restores the transceiver type to struct ethtool_link_settings and
> convert_link_ksettings_to_legacy_settings() but forgets to remove the
> error check for the same in convert_legacy_settings_to_link_ksettings().
> This prevents older versions of ethtool to change link settings.
>
>     # ethtool --version
>     ethtool version 3.16
>
>     # ethtool -s eth0 autoneg on speed 100 duplex full
>     Cannot set new settings: Invalid argument
>       not setting speed
>       not setting duplex
>       not setting autoneg
>
> While newer versions of ethtool works.
>
>     # ethtool --version
>     ethtool version 4.10
>
>     # ethtool -s eth0 autoneg on speed 100 duplex full
>     [   57.703268] sh-eth ee700000.ethernet eth0: Link is Down
>     [   59.618227] sh-eth ee700000.ethernet eth0: Link is Up - 100Mbps/Fu=
ll - flow control rx/tx
>
> Fixes: 19cab88726929605 ("net: ethtool: Add back transceiver type")

Thanks for your patch!

Reported-by: Renjith R V <renjith.rv@quest-global.com>

> Signed-off-by: Niklas S=C3=B6derlund <niklas.soderlund+renesas@ragnatech.=
se>

Tested-by: Geert Uytterhoeven <geert+renesas@glider.be>

While this fixed ethtool, unfortunately this revealed another issue: severa=
l
drivers call phy_ethtool_ksettings_set() while holding a driver-specific
spinlock, which leads to phy_start_aneg_priv() calling mutex_lock() with
interrupts disabled.

Backtrace for sh_eth:

BUG: sleeping function called from invalid context at kernel/locking/mutex.=
c:238
[  161.636382] in_atomic(): 1, irqs_disabled(): 128, pid: 1684, name: ethto=
ol
[  161.643260] CPU: 1 PID: 1684 Comm: ethtool Not tainted
4.14.0-rc5-koelsch-00441-g8545ae86337930b0 #3649
[  161.652653] Hardware name: Generic R-Car Gen2 (Flattened Device Tree)
[  161.659109] [<c020efe4>] (unwind_backtrace) from [<c020aa5c>]
(show_stack+0x10/0x14)
[  161.666859] [<c020aa5c>] (show_stack) from [<c0723444>]
(dump_stack+0x7c/0x9c)
[  161.674090] [<c0723444>] (dump_stack) from [<c023f760>]
(___might_sleep+0x128/0x164)
[  161.681841] [<c023f760>] (___might_sleep) from [<c073894c>]
(mutex_lock+0x18/0x60)
[  161.689418] [<c073894c>] (mutex_lock) from [<c0537c60>]
(phy_start_aneg_priv+0x28/0x120)
[  161.697513] [<c0537c60>] (phy_start_aneg_priv) from [<c0537ee4>]
(phy_ethtool_ksettings_set+0xc0/0xcc)
[  161.706824] [<c0537ee4>] (phy_ethtool_ksettings_set) from
[<c053fe58>] (sh_eth_set_link_ksettings+0x3c/0xa8)
[  161.716657] [<c053fe58>] (sh_eth_set_link_ksettings) from
[<c0676f88>] (ethtool_set_settings+0x100/0x114)
[  161.726229] [<c0676f88>] (ethtool_set_settings) from [<c0679ea0>]
(dev_ethtool+0x400/0x2248)
[  161.734672] [<c0679ea0>] (dev_ethtool) from [<c068f850>]
(dev_ioctl+0x424/0x774)
[  161.742074] [<c068f850>] (dev_ioctl) from [<c02f9a24>] (vfs_ioctl+0x20/0=
x34)
[  161.749128] [<c02f9a24>] (vfs_ioctl) from [<c02fa1f0>]
(do_vfs_ioctl+0x6b4/0x7b8)
[  161.756616] [<c02fa1f0>] (do_vfs_ioctl) from [<c02fa328>]
(SyS_ioctl+0x34/0x5c)
[  161.763930] [<c02fa328>] (SyS_ioctl) from [<c0206e60>]
(ret_fast_syscall+0x0/0x40)

There's a similar dump for ravb.

I quick grep shows that at least the Broadcom B44 driver is also affected.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k=
.org

In personal conversations with technical people, I call myself a hacker. Bu=
t
when I'm talking to journalists I just say "programmer" or something like t=
hat.
                                -- Linus Torvalds
