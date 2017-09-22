From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH v4 0/9] bring back stack frame warning with KASAN
Date: Fri, 22 Sep 2017 23:29:11 +0200
Message-ID: <20170922212930.620249-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Arnd Bergmann <arnd@arndb.de>,
        Mauro Carvalho Chehab <mchehab@kernel.org>,
        Jiri Pirko <jiri@resnulli.us>,
        Arend van Spriel <arend.vanspriel@broadcom.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        "David S. Miller" <davem@davemloft.net>,
        Andrey Ryabinin <aryabinin@virtuozzo.com>,
        Alexander Potapenko <glider@google.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Masahiro Yamada <yamada.masahiro@socionext.com>,
        Michal Marek <mmarek@suse.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Kees Cook <keescook@chromium.org>,
        Geert Uytterhoeven <geert@linux-m68k.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        linux-media@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
        brcm80211-dev-list.pdl@broadcom.com,
To: unlisted-recipients:; (no To-header on input)
Return-path: <linux-media-owner@vger.kernel.org>
Sender: linux-media-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a new version of patches I originally submitted back in March
[1], and last time in June [2]. This time I have basically rewritten
the entire patch series based on a new approach that came out of GCC
PR81715 that I opened[3]. The upcoming gcc-8 release is now much better
at consolidating stack slots for inline function arguments and would
obsolete most of my workaround patches here, but we still need the
workarounds for gcc-5, gcc-6 and gcc-7. Many thanks to Jakub Jelinek
for the analysis and the gcc-8 patch!

This minimal set of patches only makes sure that we do get frame size
warnings in allmodconfig for x86_64 and arm64 again with a 2048 byte
limit, even with KASAN enabled, but without the new KASAN_EXTRA option.

I set the warning limit with KASAN_EXTRA to 3072, limiting the
allmodconfig+KASAN_EXTRA build output to around 50 legitimate warnings.
These are for stack frames up to 31KB that will cause an immediate stack
overflow, and fixing them would require bringing back my older patches
and more. We can debate whether we want to apply those as a follow-up,
or instead remove the option entirely.

Another follow-up series I have reduces the warning limit with
KASAN to 1536, and without KASAN to 1280 for 64-bit architectures.

I hope we can get all patches merged for v4.14 and most of them
backported into stable kernels. Since we no longer have a dependency
on a preparation patch, my preference would be for the respective
subsystem maintainers to pick up the individual patches.
The last patch introduces a couple of "allmodconfig" build warnings
on x86 and arm64 unless the other patches get merged first, I'll
send that again separately once everything else has been taken
care of.

The remaining contents are:
- -fsanitize-address-use-after-scope is moved to a separate
  CONFIG_KASAN_EXTRA option that increases the warning limit
- CONFIG_KASAN_EXTRA is disabled with CONFIG_COMPILE_TEST,
  improving compile speed and disabling code that leads to
  valid warnings on gcc-7.0.1
- KMEMCHECK conflicts with CONFIG_KASAN
- my inline function workaround is applied to netlink, one
  ethernet driver and a few media drivers.
- The rework for the brcmsmac driver from previous versions is
  still there.

Changes since v3:
- I dropped all "noinline_if_stackbloat" annotations and used
  a workaround that introduces additional local variables in the inline
  functions to copy the function arguments, resulting in much better
  object code at the expense of having rather odd-looking functions.
- The v4 patches now don't help with KASAN_EXTRA any more at all,
  CONFIG_KASAN_EXTRA now depends on CONFIG_DEBUG_KERNEL, as it
  is more dangerous in production systems than it was before
- Rewrote the "em28xx" patch to be small enough for a stable backport.
- The rewritten vt-keyboard patches got merged and are now in
  stable kernels as well.

Changes since v2:
- rewrote the vt-keyboard patch based on feedback
- and made KMEMCHECK mutually exclusive with KASAN
  (rather than KASAN_EXTRA)

Changes since v1:
- dropped patches to fix all the CONFIG_KASAN_EXTRA warnings:
 - READ_ONCE/WRITE_ONCE cause problems in lots of code
 - typecheck() causes huge problems in a few places
 - many more uses of noinline_if_stackbloat

     Arnd

[1] https://www.spinics.net/lists/linux-wireless/msg159819.html
[2] https://www.spinics.net/lists/netdev/msg441918.html
[3] https://gcc.gnu.org/bugzilla/show_bug.cgi?id=81715

Arnd Bergmann (9):
  brcmsmac: make some local variables 'static const' to reduce stack
    size
  brcmsmac: split up wlc_phy_workarounds_nphy
  brcmsmac: reindent split functions
  em28xx: fix em28xx_dvb_init for KASAN
  r820t: fix r820t_write_reg for KASAN
  dvb-frontends: fix i2c access helpers for KASAN
  rocker: fix rocker_tlv_put_* functions for KASAN
  netlink: fix nla_put_{u8,u16,u32} for KASAN
  kasan: rework Kconfig settings

 drivers/media/dvb-frontends/ascot2e.c              |    4 +-
 drivers/media/dvb-frontends/cxd2841er.c            |    4 +-
 drivers/media/dvb-frontends/helene.c               |    4 +-
 drivers/media/dvb-frontends/horus3a.c              |    4 +-
 drivers/media/dvb-frontends/itd1000.c              |    5 +-
 drivers/media/dvb-frontends/mt312.c                |    4 +-
 drivers/media/dvb-frontends/stb0899_drv.c          |    3 +-
 drivers/media/dvb-frontends/stb6100.c              |    6 +-
 drivers/media/dvb-frontends/stv0367.c              |    4 +-
 drivers/media/dvb-frontends/stv090x.c              |    4 +-
 drivers/media/dvb-frontends/stv6110x.c             |    4 +-
 drivers/media/dvb-frontends/zl10039.c              |    4 +-
 drivers/media/tuners/r820t.c                       |   13 +-
 drivers/media/usb/em28xx/em28xx-dvb.c              |   30 +-
 drivers/net/ethernet/rocker/rocker_tlv.h           |   48 +-
 .../broadcom/brcm80211/brcmsmac/phy/phy_n.c        | 1856 ++++++++++----------
 include/net/netlink.h                              |   73 +-
 lib/Kconfig.debug                                  |    4 +-
 lib/Kconfig.kasan                                  |   13 +-
 lib/Kconfig.kmemcheck                              |    1 +
 scripts/Makefile.kasan                             |    3 +
 21 files changed, 1047 insertions(+), 1044 deletions(-)

-- 
2.9.0

Cc: Mauro Carvalho Chehab <mchehab@kernel.org>
Cc: Jiri Pirko <jiri@resnulli.us>
Cc: Arend van Spriel <arend.vanspriel@broadcom.com>
Cc: Kalle Valo <kvalo@codeaurora.org>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Alexander Potapenko <glider@google.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: Masahiro Yamada <yamada.masahiro@socionext.com>
Cc: Michal Marek <mmarek@suse.com>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Kees Cook <keescook@chromium.org>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-media@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: netdev@vger.kernel.org
Cc: linux-wireless@vger.kernel.org
Cc: brcm80211-dev-list.pdl@broadcom.com
Cc: brcm80211-dev-list@cypress.com
Cc: kasan-dev@googlegroups.com
Cc: linux-kbuild@vger.kernel.org
Cc: Jakub Jelinek <jakub@gcc.gnu.org>
Cc: Martin Liška <marxin@gcc.gnu.org>
