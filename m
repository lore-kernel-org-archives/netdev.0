From: Alexander Potapenko <glider@google.com>
Subject: Re: [PATCH 00/26] bring back stack frame warning with KASAN
Date: Fri, 3 Mar 2017 13:25:29 +0100
Message-ID: <CAG_fn=UVcLhP8mH6tvzqZUn4u9T4pnQw8bMf=qccNro59VcABw@mail.gmail.com>
References: <20170302163834.2273519-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: kasan-dev <kasan-dev@googlegroups.com>,
        Andrey Ryabinin <aryabinin@virtuozzo.com>,
        Dmitry Vyukov <dvyukov@google.com>, netdev@vger.kernel.org,
        LKML <linux-kernel@vger.kernel.org>, linux-media@vger.kernel.org,
        linux-wireless@vger.kernel.org,
        kernel-build-reports@lists.linaro.org,
        "David S . Miller" <davem@davemloft.net>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170302163834.2273519-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 2, 2017 at 5:38 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> It took a long while to get this done, but I'm finally ready
> to send the first half of the KASAN stack size patches that
> I did in response to the kernelci.org warnings.
>
> As before, it's worth mentioning that things are generally worse
> with gcc-7.0.1 because of the addition of -fsanitize-address-use-after-sc=
ope
> that are not present on kernelci, so my randconfig testing found
> a lot more than kernelci did.
>
> The main areas are:
>
> - READ_ONCE/WRITE_ONCE cause problems in lots of code
> - typecheck() causes huge problems in a few places
> - I'm introducing "noinline_for_kasan" and use it in a lot
>   of places that suffer from inline functions with local variables
>   - netlink, as used in various parts of the kernel
>   - a number of drivers/media drivers
>   - a handful of wireless network drivers
> - kmemcheck conflicts with -fsanitize-address-use-after-scope
>
> This series lets us add back a stack frame warning for 3072 bytes
> with -fsanitize-address-use-after-scope, or 2048 bytes without it.
>
> I have a follow-up series that further reduces the stack frame
> warning limit to 1280 bytes for all 64-bit architectures, and
> 1536 bytes with basic KASAN support (no -fsanitize-address-use-after-scop=
e).
> For now, I'm only posting the first half, in order to keep
> it (barely) reviewable.
Can you please elaborate on why do you need this? Are you trying to
squeeze KASAN into some embedded device?
Noinlines sprayed over the codebase are hard to maintain, and certain
compiler changes may cause bloated stack frames in other places.
Maybe it should be enough to just increase the stack frame limit in
KASAN builds, as Dmitry suggested previously?
> Both series are tested with many hundred randconfig builds on both
> x86 and arm64, which are the only architectures supporting KASAN.
>
>         Arnd
>
>  [PATCH 01/26] compiler: introduce noinline_for_kasan annotation
>  [PATCH 02/26] rewrite READ_ONCE/WRITE_ONCE
>  [PATCH 03/26] typecheck.h: avoid local variables in typecheck() macro
>  [PATCH 04/26] tty: kbd: reduce stack size with KASAN
>  [PATCH 05/26] netlink: mark nla_put_{u8,u16,u32} noinline_for_kasan
>  [PATCH 06/26] rocker: mark rocker_tlv_put_* functions as
>  [PATCH 07/26] brcmsmac: reduce stack size with KASAN
>  [PATCH 08/26] brcmsmac: make some local variables 'static const' to
>  [PATCH 09/26] brcmsmac: split up wlc_phy_workarounds_nphy
>  [PATCH 10/26] brcmsmac: reindent split functions
>  [PATCH 11/26] rtlwifi: reduce stack usage for KASAN
>  [PATCH 12/26] wl3501_cs: reduce stack size for KASAN
>  [PATCH 13/26] rtl8180: reduce stack size for KASAN
>  [PATCH 14/26] [media] dvb-frontends: reduce stack size in i2c access
>  [PATCH 15/26] [media] tuners: i2c: reduce stack usage for
>  [PATCH 16/26] [media] i2c: adv7604: mark register access as
>  [PATCH 17/26] [media] i2c: ks0127: reduce stack frame size for KASAN
>  [PATCH 18/26] [media] i2c: cx25840: avoid stack overflow with KASAN
>  [PATCH 19/26] [media] r820t: mark register functions as
>  [PATCH 20/26] [media] em28xx: split up em28xx_dvb_init to reduce
>  [PATCH 21/26] drm/bridge: ps8622: reduce stack size for KASAN
>  [PATCH 22/26] drm/i915/gvt: don't overflow the kernel stack with
>  [PATCH 23/26] mtd: cfi: reduce stack size with KASAN
>  [PATCH 24/26] ocfs2: reduce stack size with KASAN
>  [PATCH 25/26] isdn: eicon: mark divascapi incompatible with kasan
>  [PATCH 26/26] kasan: rework Kconfig settings
>
>  arch/x86/include/asm/switch_to.h                                 |    2 =
+-
>  drivers/gpu/drm/bridge/parade-ps8622.c                           |    2 =
+-
>  drivers/gpu/drm/i915/gvt/mmio.h                                  |   17 =
+-
>  drivers/isdn/hardware/eicon/Kconfig                              |    1 =
+
>  drivers/media/dvb-frontends/ascot2e.c                            |    3 =
+-
>  drivers/media/dvb-frontends/cxd2841er.c                          |    4 =
+-
>  drivers/media/dvb-frontends/drx39xyj/drxj.c                      |   14 =
+-
>  drivers/media/dvb-frontends/helene.c                             |    4 =
+-
>  drivers/media/dvb-frontends/horus3a.c                            |    2 =
+-
>  drivers/media/dvb-frontends/itd1000.c                            |    2 =
+-
>  drivers/media/dvb-frontends/mt312.c                              |    2 =
+-
>  drivers/media/dvb-frontends/si2165.c                             |   14 =
+-
>  drivers/media/dvb-frontends/stb0899_drv.c                        |    2 =
+-
>  drivers/media/dvb-frontends/stb6100.c                            |    2 =
+-
>  drivers/media/dvb-frontends/stv0367.c                            |    2 =
+-
>  drivers/media/dvb-frontends/stv090x.c                            |    2 =
+-
>  drivers/media/dvb-frontends/stv6110.c                            |    2 =
+-
>  drivers/media/dvb-frontends/stv6110x.c                           |    2 =
+-
>  drivers/media/dvb-frontends/tda8083.c                            |    2 =
+-
>  drivers/media/dvb-frontends/zl10039.c                            |    2 =
+-
>  drivers/media/i2c/adv7604.c                                      |    4 =
+-
>  drivers/media/i2c/cx25840/cx25840-core.c                         |    4 =
+-
>  drivers/media/i2c/ks0127.c                                       |    2 =
+-
>  drivers/media/tuners/r820t.c                                     |    4 =
+-
>  drivers/media/tuners/tuner-i2c.h                                 |   15 =
+-
>  drivers/media/usb/em28xx/em28xx-dvb.c                            |  947 =
+++++++++++++++++++++------------------
>  drivers/mtd/chips/cfi_cmdset_0020.c                              |    8 =
+-
>  drivers/net/ethernet/rocker/rocker_tlv.h                         |   24 =
+-
>  drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phy_n.c     | 1860 =
+++++++++++++++++++++++++++++++++++++--------------------------------------=
--
>  drivers/net/wireless/realtek/rtl818x/rtl8180/rtl8225se.c         |    4 =
+-
>  drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtc8192e2ant.c |   41 =
+-
>  drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtc8723b1ant.c |   26 =
+-
>  drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtc8723b2ant.c |   34 =
+-
>  drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtc8821a1ant.c |   36 =
+-
>  drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtc8821a2ant.c |   38 =
+-
>  drivers/net/wireless/wl3501_cs.c                                 |   10 =
+-
>  drivers/tty/vt/keyboard.c                                        |    6 =
+-
>  fs/ocfs2/cluster/masklog.c                                       |   10 =
+-
>  fs/ocfs2/cluster/masklog.h                                       |    4 =
+-
>  fs/overlayfs/util.c                                              |    6 =
+-
>  include/linux/compiler.h                                         |   58 =
++-
>  include/linux/mtd/map.h                                          |    8 =
+-
>  include/linux/typecheck.h                                        |    7 =
+-
>  include/net/netlink.h                                            |   36 =
+-
>  lib/Kconfig.debug                                                |    9 =
+-
>  lib/Kconfig.kasan                                                |   11 =
+-
>  lib/Kconfig.kmemcheck                                            |    1 =
+
>  scripts/Makefile.kasan                                           |    3 =
+
>  48 files changed, 1670 insertions(+), 1629 deletions(-)
>



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Matthew Scott Sucherman, Paul Terence Manicle
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg
