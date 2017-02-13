From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] netlink: move nla_put_{u8,u16,u32} out of line
Date: Mon, 13 Feb 2017 16:03:45 +0100
Message-ID: <CAK8P3a2=BNAaZoEyq2Qw70QX_34efCy13_Pm_8Fq5gsgumW0zA@mail.gmail.com>
References: <20170208211843.2822208-1-arnd@arndb.de> <CAK8P3a1FLFG7NvTEPNQB6Gam2y7O3K+5T_cmQg-rOfT4TKNfnA@mail.gmail.com>
 <CACT4Y+bpoud4y2N0xkatG8N5we6+scqYhCZhvaXJSBQiVnznTQ@mail.gmail.com>
 <4145102.8mea7fgqQV@wuerfel> <CAK8P3a2VvyUj6z10GuPCdR9YHMDazfq86TKF260=waKeD83csg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        David Laight <David.Laight@aculab.com>,
        netdev <netdev@vger.kernel.org>,
        Johannes Berg <johannes.berg@intel.com>,
        Andrey Ryabinin <aryabinin@virtuozzo.com>,
        Alexander Potapenko <glider@google.com>,
        kasan-dev <kasan-dev@googlegroups.com>,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>,
        Alexey Dobriyan <adobriyan@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Thomas Graf <tgraf@suug.ch>,
        Eric Dumazet <edumazet@google.com>,
        LKML <linux-kernel@vger.kernel.org>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAK8P3a2VvyUj6z10GuPCdR9YHMDazfq86TKF260=waKeD83csg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 10, 2017 at 2:24 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> On Thu, Feb 9, 2017 at 6:00 PM, Arnd Bergmann <arnd@arndb.de> wrote:
>> To reduce this risk, -fsanitize-address-use-after-scope is now split out
>> into a separate Kconfig option, which cannot be selected at the same time
>> as CONFIG_KASAN_INLINE, leading to stack frames that are smaller than 2
>> kilobytes most of the time on x86_64. Now we can turn on the warning again
>> that was disabled in commit 3f181b4 ("lib/Kconfig.debug: disable
>> -Wframe-larger-than warnings with KASAN=y").
>>
>> The hope is that we can fix all code that still produces warnings, so far
>> I have found four areas that are still affected (netlink, hisi-hns,
>> dvb and tty/keyboard), and I have patches for all of them.
>
> scratch that, my randconfig tests found too many remaining problems
> with asan-stack=1 even when only one of CONFIG_KASAN_INLINE
> and -fsanitize-address-use-after-scope is set.
>
> I actually get results as bad as
> fs/direct-io.c: In function 'do_direct_IO':
> fs/direct-io.c:1057:1: error: the frame size of 7240 bytes is larger
> than 2048 bytes [-Werror=frame-larger-than=]
>
> with KASAN_OUTLINE=y and KASAN_EXTRA=n.
>
> I need to investigate further to see if I can narrow it down to some
> other configuration options.

Another update while randconfig build updates are coming in: I had
inconsistent results earlier because I was using two different x86
compiler versions: 7.0.0 dated 20161201 and 7.0.1 dated 20170124.

The good news is that most of the extreme frame sizes are gone with
gcc-7.0.1 and my earlier five patches (which addressed mostly the problems I
saw on arm64), this is what I currently see beyond that in randconfig builds,
down from around 500 files with >2048 stack frames I had with gcc-7.0.0:

arch/x86/kernel/cpu/mshyperv.c:234:1: error: the frame size of 2128
bytes is larger than 2048 bytes
arch/x86/kernel/traps.c:1019:1: error: the frame size of 2264 bytes is
larger than 2048 bytes
drivers/acpi/nfit/core.c:2686:1: error: the frame size of 4048 bytes
is larger than 2048 bytes
drivers/gpu/drm/nouveau/nvkm/subdev/i2c/anx9805.c:189:1: error: the
frame size of 2400 bytes is larger than 2048 bytes
drivers/iio/common/ssp_sensors/ssp_spi.c:452:1: error: the frame size
of 2720 bytes is larger than 2048 bytes
drivers/input/mouse/cyapa_gen5.c:2434:1: error: the frame size of 2448
bytes is larger than 2048 bytes
drivers/media/i2c/saa6752hs.c:555:1: error: the frame size of 2232
bytes is larger than 2048 bytes
drivers/media/pci/saa7134/saa7134-cards.c:8068:1: error: the frame
size of 2144 bytes is larger than 2048 bytes
drivers/media/tuners/tda8290.c:310:1: error: the frame size of 3168
bytes is larger than 2048 bytes
drivers/mtd/mtdchar.c:1056:1: error: the frame size of 2104 bytes is
larger than 2048 bytes
drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phy_n.c:16065:1:
error: the frame size of 3200 bytes is larger than 2048 bytes
drivers/rapidio/devices/rio_mport_cdev.c:2207:1: error: the frame size
of 2992 bytes is larger than 2048 bytes
drivers/scsi/mpt3sas/mpt3sas_scsih.c:7933:1: error: the frame size of
2056 bytes is larger than 2048 bytes
drivers/scsi/snic/snic_debugfs.c:355:1: error: the frame size of 3200
bytes is larger than 2048 bytes
fs/btrfs/backref.c:1464:1: error: the frame size of 2088 bytes is
larger than 2048 bytes
fs/btrfs/disk-io.c:3316:1: error: the frame size of 2744 bytes is
larger than 2048 bytes
fs/btrfs/extent-tree.c:5232:1: error: the frame size of 2056 bytes is
larger than 2048 bytes
fs/btrfs/relocation.c:1193:1: error: the frame size of 4208 bytes is
larger than 2048 bytes
fs/btrfs/scrub.c:3435:1: error: the frame size of 2144 bytes is larger
than 2048 bytes
fs/btrfs/tree-log.c:3007:1: error: the frame size of 2496 bytes is
larger than 2048 bytes
fs/cachefiles/rdwr.c:669:1: error: the frame size of 2384 bytes is
larger than 2048 bytes
fs/direct-io.c:1057:1: error: the frame size of 2896 bytes is larger
than 2048 bytes
fs/direct-io.c:1348:1: error: the frame size of 2144 bytes is larger
than 2048 bytes
fs/nilfs2/segment.c:1277:1: error: the frame size of 2832 bytes is
larger than 2048 bytes
fs/nilfs2/segment.c:2111:1: error: the frame size of 2240 bytes is
larger than 2048 bytes
fs/xfs/libxfs/xfs_alloc.c:1338:1: error: the frame size of 2504 bytes
is larger than 2048 bytes
fs/xfs/libxfs/xfs_bmap.c:2183:1: error: the frame size of 5104 bytes
is larger than 2048 bytes
fs/xfs/xfs_log_recover.c:1963:1: error: the frame size of 2272 bytes
is larger than 2048 bytes
kernel/rcu/tree.c:2370:1: error: the frame size of 4688 bytes is
larger than 2048 bytes
kernel/rcu/tree_exp.h:618:1: error: the frame size of 3312 bytes is
larger than 2048 bytes
lib/atomic64_test.c:243:1: error: the frame size of 12688 bytes is
larger than 2048 bytes
lib/rbtree.c:447:1: error: the frame size of 2512 bytes is larger than
2048 bytes
mm/khugepaged.c:1559:1: error: the frame size of 2232 bytes is larger
than 2048 bytes
mm/ksm.c:1537:1: error: the frame size of 2232 bytes is larger than 2048 bytes
mm/migrate.c:1357:1: error: the frame size of 2360 bytes is larger
than 2048 bytes
mm/page_alloc.c:3061:1: error: the frame size of 2056 bytes is larger
than 2048 bytes
mm/vmscan.c:1333:1: error: the frame size of 2368 bytes is larger than
2048 bytes

It will take some time to fix all the worst offenders, but it seems
manageable so we can
hopefully turn the warning back on for both x86 and arm64 in the
future.  On arm64,
a warning limit of 2048 (even as low as 1280 when KASAN is disabled) seems
reasonable, on x86-64 we probably want to set it a little higher and rely on the
larger stacks we already use with KASAN.

The suggested "noinline_for_kasan" annotation should be able to fix
the majority of
the affected files (including nla_put_*) with very little risk of
regressions otherwise.

I also still have to go back to gcc-6 and gcc-5, if I get results like
the earlier gcc-7.0.0,
I would probably suggest leaving using asan-stack=0 with any affected
release, to
avoid silliness like the worst case I found so far:
drivers/media/i2c/cx25840/cx25840-core.c:4960:1: error: the frame size
of 94000 bytes is larger than 2048 bytes

    Arnd
