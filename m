From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH v2 00/11] bring back stack frame warning with KASAN
Date: Wed, 14 Jun 2017 23:15:35 +0200
Message-ID: <20170614211556.2062728-1-arnd@arndb.de>
Cc: kasan-dev@googlegroups.com, Dmitry Vyukov <dvyukov@google.com>,
        Alexander Potapenko <glider@google.com>,
        Andrey Ryabinin <aryabinin@virtuozzo.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Arend van Spriel <arend.vanspriel@broadcom.com>,
        Arnd Bergmann <arnd@arndb.de>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a new version of patches I originally submitted back in
March [1], this time reducing the size of the series even further.

This minimal set of patches only makes sure that we do get
frame size warnings in allmodconfig for x86_64 and arm64 again,
even with KASAN enabled.

The changes this time are reduced to:

- I'm introducing "noinline_if_stackbloat" and use it in a number
  of places that suffer from inline functions with local variables
  - netlink, as used in various parts of the kernel
  - a number of drivers/media drivers
  - a handful of wireless network drivers
- a rework for the brcmsmac driver
- -fsanitize-address-use-after-scope is moved to a separate
  CONFIG_KASAN_EXTRA option that increases the warning limit
- CONFIG_KASAN_EXTRA is disabled with CONFIG_COMPILE_TEST,
  improving compile speed and disabling code that leads to
  valid warnings on gcc-7.0.1
- kmemcheck conflicts with CONFIG_KASAN_EXTRA

Compared to the previous version, I no longer have patches
to fix all the CONFIG_KASAN_EXTRA warnings:

- READ_ONCE/WRITE_ONCE cause problems in lots of code
- typecheck() causes huge problems in a few places
- many more uses of noinline_if_stackbloat

This series lets us add back a stack frame warning for the regular
2048 bytes without CONFIG_KASAN_EXTRA. I set the warning limit with
KASAN_EXTRA to 3072, since I have an additional set of patches
to address all files that surpass that limit. We can debate whether
we want to apply those as a follow-up, or instead remove the option
entirely.

Another follow-up series I have reduces the warning limit with
KASAN to 1536, and without KASAN to 1280 for 64-bit architectures.

I hope that Andrew can pick up the entire series for mmotm, and
we can eventually backport most of it to stable kernels and
address the warnings that kernelci still reports for this problem [2].

     Arnd

[1] https://lkml.org/lkml/2017/3/2/508
[2] https://kernelci.org/build/id/593f89a659b51463306b958d/logs/

 kasan: rework Kconfig settings
 brcmsmac: reindent split functions
 brcmsmac: split up wlc_phy_workarounds_nphy
 brcmsmac: make some local variables 'static const' to reduce stack size
 r820t: mark register functions as noinline_if_stackbloat
 dvb-frontends: reduce stack size in i2c access
 mtd: cfi: reduce stack size with KASAN
 rocker: mark rocker_tlv_put_* functions as noinline_if_stackbloat
 tty: kbd: reduce stack size with KASAN
 netlink: mark nla_put_{u8,u16,u32} noinline_if_stackbloat
 compiler: introduce noinline_if_stackbloat annotation

Arnd Bergmann (11):
 drivers/media/dvb-frontends/ascot2e.c                        |    3 +-
 drivers/media/dvb-frontends/cxd2841er.c                      |    4 +-
 drivers/media/dvb-frontends/drx39xyj/drxj.c                  |   14 +-
 drivers/media/dvb-frontends/helene.c                         |    4 +-
 drivers/media/dvb-frontends/horus3a.c                        |    2 +-
 drivers/media/dvb-frontends/itd1000.c                        |    2 +-
 drivers/media/dvb-frontends/mt312.c                          |    2 +-
 drivers/media/dvb-frontends/si2165.c                         |   14 +-
 drivers/media/dvb-frontends/stb0899_drv.c                    |    2 +-
 drivers/media/dvb-frontends/stb6100.c                        |    2 +-
 drivers/media/dvb-frontends/stv0367.c                        |    2 +-
 drivers/media/dvb-frontends/stv090x.c                        |    2 +-
 drivers/media/dvb-frontends/stv6110.c                        |    2 +-
 drivers/media/dvb-frontends/stv6110x.c                       |    2 +-
 drivers/media/dvb-frontends/tda8083.c                        |    2 +-
 drivers/media/dvb-frontends/zl10039.c                        |    2 +-
 drivers/media/tuners/r820t.c                                 |    4 +-
 drivers/mtd/chips/cfi_cmdset_0020.c                          |    8 +-
 drivers/net/ethernet/rocker/rocker_tlv.h                     |   24 +-
 drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phy_n.c | 1856 +++++++++++++++++++++++-------------------------
 drivers/tty/vt/keyboard.c                                    |    6 +-
 include/linux/compiler.h                                     |   11 +
 include/linux/mtd/map.h                                      |    8 +-
 include/net/netlink.h                                        |   36 +-
 lib/Kconfig.debug                                            |    4 +-
 lib/Kconfig.kasan                                            |   11 +-
 lib/Kconfig.kmemcheck                                        |    1 +
 scripts/Makefile.kasan                                       |    3 +
 28 files changed, 986 insertions(+), 1047 deletions(-)

-- 
2.9.0
