From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH v3 00/11] bring back stack frame warning with KASAN
Date: Thu, 22 Jun 2017 19:13:44 +0200
Message-ID: <20170622171355.267192-1-arnd@arndb.de>
Cc: kasan-dev@googlegroups.com, Dmitry Vyukov <dvyukov@google.com>,
        Alexander Potapenko <glider@google.com>,
        Andrey Ryabinin <aryabinin@virtuozzo.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Arend van Spriel <arend.vanspriel@broadcom.com>,
        Arnd Bergmann <arnd@arndb.de>,
        Masahiro Yamada <yamada.masahiro@socionext.com>,
        Michal Marek <mmarek@suse.com>,
        Kees Cook <keescook@chromium.org>,
        Ingo Molnar <mingo@kernel.org>,
        "David S . Miller" <davem@davemloft.net>,
        linux-kbuild@vger.kernel.org,
        Samuel Thibault <samuel.thibault@ens-lyon.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Jiri Slaby <jslaby@suse.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([217.72.192.75]:61751 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753719AbdFVRPK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2017 13:15:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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

Compared to the version 1, I no longer have patches
to fix all the CONFIG_KASAN_EXTRA warnings:

- READ_ONCE/WRITE_ONCE cause problems in lots of code
- typecheck() causes huge problems in a few places
- many more uses of noinline_if_stackbloat

And compared to version 2, I have rewritten the vt-keyboard
patch based on feedback, and made KMEMCHECK mutually exclusive
with KASAN (rather than KASAN_EXTRA), everything else remains
unchanged.

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

Arnd Bergmann (11):
  compiler: introduce noinline_if_stackbloat annotation
  netlink: mark nla_put_{u8,u16,u32} noinline_if_stackbloat
  rocker: mark rocker_tlv_put_* functions as noinline_if_stackbloat
  mtd: cfi: reduce stack size with KASAN
  dvb-frontends: reduce stack size in i2c access
  r820t: mark register functions as noinline_if_stackbloat
  tty: improve tty_insert_flip_char() fast path
  brcmsmac: make some local variables 'static const' to reduce stack
    size
  brcmsmac: split up wlc_phy_workarounds_nphy
  brcmsmac: reindent split functions
  kasan: rework Kconfig settings

 drivers/media/dvb-frontends/ascot2e.c              |    3 +-
 drivers/media/dvb-frontends/cxd2841er.c            |    4 +-
 drivers/media/dvb-frontends/drx39xyj/drxj.c        |   14 +-
 drivers/media/dvb-frontends/helene.c               |    4 +-
 drivers/media/dvb-frontends/horus3a.c              |    2 +-
 drivers/media/dvb-frontends/itd1000.c              |    2 +-
 drivers/media/dvb-frontends/mt312.c                |    2 +-
 drivers/media/dvb-frontends/si2165.c               |   14 +-
 drivers/media/dvb-frontends/stb0899_drv.c          |    2 +-
 drivers/media/dvb-frontends/stb6100.c              |    2 +-
 drivers/media/dvb-frontends/stv0367.c              |    2 +-
 drivers/media/dvb-frontends/stv090x.c              |    2 +-
 drivers/media/dvb-frontends/stv6110.c              |    2 +-
 drivers/media/dvb-frontends/stv6110x.c             |    2 +-
 drivers/media/dvb-frontends/tda8083.c              |    2 +-
 drivers/media/dvb-frontends/zl10039.c              |    2 +-
 drivers/media/tuners/r820t.c                       |    4 +-
 drivers/mtd/chips/cfi_cmdset_0020.c                |    8 +-
 drivers/net/ethernet/rocker/rocker_tlv.h           |   24 +-
 .../broadcom/brcm80211/brcmsmac/phy/phy_n.c        | 1856 ++++++++++----------
 drivers/tty/tty_buffer.c                           |   24 +
 include/linux/compiler.h                           |   11 +
 include/linux/mtd/map.h                            |    8 +-
 include/linux/tty_flip.h                           |    3 +-
 include/net/netlink.h                              |   36 +-
 lib/Kconfig.debug                                  |    4 +-
 lib/Kconfig.kasan                                  |   11 +-
 lib/Kconfig.kmemcheck                              |    1 +
 scripts/Makefile.kasan                             |    3 +
 29 files changed, 1009 insertions(+), 1045 deletions(-)

-- 
2.9.0
