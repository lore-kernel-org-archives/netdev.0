From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH RFC 00/73] tree-wide: clean up some no longer required #include <linux/init.h>
Date: Tue, 21 Jan 2014 16:22:03 -0500
Message-ID: <1390339396-3479-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: <linux-arch@vger.kernel.org>,
        Paul Gortmaker <paul.gortmaker@windriver.com>,
        <linux-alpha@vger.kernel.org>,
        <linux-arm-kernel@lists.infradead.org>,
        <linux-ia64@vger.kernel.org>, <linux-m68k@vger.kernel.org>,
        <linux-mips@linux-mips.org>, <linuxppc-dev@lists.ozlabs.org>,
        <linux-s390@vger.kernel.org>, <sparclinux@vger.kernel.org>,
        <x86@kernel.org>, <netdev@vger.kernel.org>, <kvm@vger.kernel.org>,
        <sfr@canb.auug.org.au>, <rusty@rustcorp.com.au>,
        <gregkh@linuxfoundation.org>, <akpm@linux-foundation.org>,
        <torvalds@linux-foundation.org>
To: <linux-kernel@vger.kernel.org>
Return-path: <linux-mips-bounce@linux-mips.org>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

TL;DR - We removed cpuinit and devinit, which left ~2000 instances of
include <linux/init.h> that were no longer needed.  To fully enable
this removal/cleanup, we relocate module_init() from init.h into
module.h.  Multi arch/multi config build testing on linux-next has
been used to find and fix any implicit header dependencies prior to
deploying the actual init.h --> module.h move, to preserve bisection.

Additional details beyond TL;DR:

module_init/module_exit and friends moved to module.h
=====================================================
Aside from enabling this init.h cleanup to extend into modular files,
it actually does make sense.  For all modules will use some form of
our initfunc processing/categorization, but not all initfunc users
will be necessarily using modular functionality.  So we move these
module related macros to module.h and ensure module.h sources init.h


module_init in non modular code:
================================
This series uncovered that we are enabling people to use module_init
in non-modular code.  While that works fine, there are at least three
reasons why it probably should not be encouraged:

 1) it makes a casual reader of the code assume the code is modular
    even though it is obj-y (builtin) or controlled by a bool Kconfig.

 2) it makes it too easy to add dead code in a function that is handed
    to module_exit() -- [more on that below]

 3) it breaks our ability to use priority sorted initcalls properly
    [more on that below.]

After this change, a new coder who tries to make use of module_init in
non modular code would find themselves also needing to include the
module.h header.  At which point the odds are greater that they would
ask themselves "Am I doing this right?  I shouldn't need this."

Note that existing non-modular code that already includes module.h and
uses module_init doesn't get fixed here, since they already build w/o
errors triggered by this change; we'll have to hunt them down later.


module_init and initcall ordering:
==================================
We have a group of about ten priority sorted initcalls, that are
called in init/main.c after most of the hard coded/direct calls
have been processed.  These serve the purpose of avoiding everyone
poking at init/main.c to hook in their init sequence.  The bins are:

        pure_initcall               0
        core_initcall               1
        postcore_initcall           2
        arch_initcall               3
        subsys_initcall             4
        fs_initcall                 5
        device_initcall             6
        late_initcall               7

These are meant to eventually replace users of the non specific
priority "__initcall" which currently maps onto device_initcall.
This is of interest, because in non-modular code, cpp does this:

    module_init -->  __initcall --> device_initcall

So all module_init() land in the device_initcall bucket, rather late
in the sequence.  That makes sense, since if it was a module, the init
could be real late (days, weeks after boot).  But now imagine you add
support for some non-modular bus/arch/infrastructure (say for e.g. PCI)
and you use module_init for it.  That means anybody else who wants
to use your subsystem can't do so if they use an initcall of 0 --> 5
priority.  For a real world example of this, see patch #1 in this series:

	https://lkml.org/lkml/2014/1/14/809

We don't want to force code that is clearly arch or subsys or fs
specific to have to use the device_initcall just because something
else has been mistakenly put (or left) in that bucket.  So a couple of
changes do actually change the initcall level where it is inevitably
appropriate to do so.  Those are called out explicitly in their
respective commit logs.


module_exit and dead code
=========================
Built in code will never have an opportunity to call functions that
are registered with module_exit(), so any cases of that uncovered in
this series delete that dead code.  Note that any built-in code that
was already including module.h and using module_exit won't have shown
up as breakage on the build coverage of this series, so we'll have to
find those independently later.  It looks like there may be quite a
few that are invisibly created via module_platform_driver -- a macro
that creates module_init and module_exit automatically.  We may want
to consider relocating module_platform_driver into module.h later...


cpuinit
=======
To finalize the removal of cpuinit, which was done several releases
ago, we remove the remaining stub functions from init.h in this
series.  We've seen one or two "users" try to creep back in, so this
will close the door on that chapter and prevent creep.


When, what and where?
=====================
When: Ideally, barring any objections or massive oversights on my
part, this will go in at or around rc1, i.e. in about 2wks.  In the
meantime I will continue daily re-test on linux-next across ~10 different
arch, using allyesconfig, allmodconfig and arch specific defconfigs
for things like mips/arm/powerpc; as I have been doing for a while.

Where: This work exists as a queue of patches that I apply to
linux-next; since the changes are fixing some things that currently
can only be found there.  The patch series can be found at:

   http://git.kernel.org/cgit/linux/kernel/git/paulg/init.git
   git://git.kernel.org/pub/scm/linux/kernel/git/paulg/init.git

The patches are not in strict chronological order, since when I've
found a header change causes a build regression that is due to an
implicit dependency/inclusion, I place the dependency fix before the
header change that caused it, so that bisection is preserved.

I've avoided annoying Stephen with another queue of patches for
linux-next while the development content was in flux, but now that
the merge window has opened, and new additions are fewer, perhaps he
wouldn't mind tacking it on the end...  Stephen?

In order to reduce the size of the overall queue here, I have already
put some dependency-free changes through maintainer trees after
re-testing them on whatever their development baseline was.  That made
sense for the larger ones (drivers/[net,usb,input] some arch trees...)
and for the kernel/ mm/ and fs/ ones where the changes were less
trivial and an earlier review was desired. But that independent treatment
doesn't scale for handling all the commits -- hence ~1400 of the
full ~2k of init.h removals remain here in this series.

What: The audit for removal of extra init.h lines has covered
drivers/, all of the main architectures (and some of the more fringe
ones), and core dirs like mm/ fs/ and kernel/ too.  The removals from
include/ itself are probably the most valuable, in terms of reducing
the amount of stuff we needlessly feed CPP.  There is probably more
fringe ones to be found, but this covers the majority of them.
Additional ones can be fed in later (through the trivial tree perhaps)
as desired.

Build coverage (from memory) has included, but is not limited to:

  allyesconfig, allmodconfig:
	x86, x86_64, ia64, s390, arm, mips, sparc, powerpc
  arch specifc arch/<name>/config/*config files:
	arm, mips, powerpc
  defconfig:
	(all of the above), c6x, parisc, uml, tile, c6x, blackfin, ...

and it will continue to take place for the next ~2wks, until I can
reliably apply the queue to master and submit a pull request.

Thanks for reading this far, and thanks to those who have merged init.h
cleanup commits already!  Additional comments, reviews and acks welcomed.

Paul.
---

Cc: linux-alpha@vger.kernel.org
Cc: linux-arch@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org
Cc: linux-ia64@vger.kernel.org
Cc: linux-m68k@lists.linux-m68k.org
Cc: linux-mips@linux-mips.org
Cc: linuxppc-dev@lists.ozlabs.org
Cc: linux-s390@vger.kernel.org
Cc: sparclinux@vger.kernel.org
Cc: x86@kernel.org
Cc: netdev@vger.kernel.org
Cc: kvm@vger.kernel.org
Cc: sfr@canb.auug.org.au
Cc: rusty@rustcorp.com.au
Cc: gregkh@linuxfoundation.org
Cc: akpm@linux-foundation.org
Cc: torvalds@linux-foundation.org

Paul Gortmaker (73):
  init: delete the __cpuinit related stubs
  mm: replace module_init usages with subsys_initcall in nommu.c
  fs/notify: don't use module_init for non-modular inotify_user code
  netfilter: don't use module_init/exit in core IPV4 code
  x86: don't use module_init in non-modular intel_mid_vrtc.c
  x86: don't use module_init for non-modular core bootflag code
  x86: replace __init_or_module with __init in non-modular vsmp_64.c
  drivers/tty/hvc: don't use module_init in non-modular hyp. console code
  staging: don't use module_init in non-modular ion_dummy_driver.c
  powerpc: use device_initcall for registering rtc devices
  powerpc: book3s KVM can be modular so it should use module.h
  powerpc: kvm e500/44x is not modular, so don't use module_init
  powerpc: use subsys_initcall for Freescale Local Bus
  powerpc: don't use module_init for non-modular core hugetlb code
  powerpc: don't use module_init in non-modular 83xx suspend code
  arm: include module.h in drivers/bus/omap_l3_smx.c
  arm: fix implicit module.h use in mach-at91 gpio.h
  arm: fix implicit #include <linux/init.h> in entry asm.
  arm: mach-s3c64xx mach-crag6410-module.c is not modular
  arm: use subsys_initcall in non-modular pl320 IPC code
  arm: don't use module_init in non-modular mach-vexpress/spc.c code
  alpha: don't use module_init for non-modular core code
  sparc: don't use module_init in non-modular pci.c code
  m68k: don't use module_init in non-modular mvme16x/rtc.c code
  ia64: don't use module_init for non-modular core kernel/mca.c code
  ia64: don't use module_init in non-modular sim/simscsi.c code
  drivers/clk: don't use module_init in clk-nomadik.c which is non-modular
  cpuidle: don't use modular platform register in non-modular ARM drivers
  drivers/platform: don't use modular register in non-modular pdev_bus.c
  drivers/i2c: busses/i2c-acorn.c is tristate and should use module.h
  module: relocate module_init from init.h to module.h
  logo: emit "#include <linux/init.h> in autogenerated C file
  arm: delete non-required instances of include <linux/init.h>
  mips: delete non-required instances of include <linux/init.h>
  sparc: delete non-required instances of include <linux/init.h>
  s390: delete non-required instances of include <linux/init.h>
  alpha: delete non-required instances of <linux/init.h>
  blackfin: delete non-required instances of <linux/init.h>
  powerpc: delete another unrequired instance of <linux/init.h>
  watchdog: delete non-required instances of include <linux/init.h>
  video: delete non-required instances of include <linux/init.h>
  rtc: delete non-required instances of include <linux/init.h>
  scsi: delete non-required instances of include <linux/init.h>
  spi: delete non-required instances of include <linux/init.h>
  acpi: delete non-required instances of include <linux/init.h>
  drivers/power: delete non-required instances of include <linux/init.h>
  drivers/media: delete non-required instances of include <linux/init.h>
  drivers/ata: delete non-required instances of include <linux/init.h>
  drivers/mtd: delete non-required instances of include <linux/init.h>
  drivers/hwmon: delete non-required instances of include <linux/init.h>
  drivers/i2c: delete non-required instances of include <linux/init.h>
  drivers/pinctrl: delete non-required instances of include <linux/init.h>
  drivers/isdn: delete non-required instances of include <linux/init.h>
  drivers/leds: delete non-required instances of include <linux/init.h>
  drivers/pcmcia: delete non-required instances of include <linux/init.h>
  drivers/char: delete non-required instances of include <linux/init.h>
  drivers/infiniband: delete non-required instances of include <linux/init.h>
  drivers/mfd: delete non-required instances of include <linux/init.h>
  drivers/gpio: delete non-required instances of include <linux/init.h>
  drivers/bluetooth: delete non-required instances of include <linux/init.h>
  drivers/mmc: delete non-required instances of include <linux/init.h>
  drivers/crypto: delete non-required instances of include <linux/init.h>
  drivers/platform: delete non-required instances of include <linux/init.h>
  drivers/misc: delete non-required instances of include <linux/init.h>
  drivers/edac: delete non-required instances of include <linux/init.h>
  drivers/macintosh: delete non-required instances of include <linux/init.h>
  drivers/base: delete non-required instances of include <linux/init.h>
  drivers/cpufreq: delete non-required instances of <linux/init.h>
  drivers/pci: delete non-required instances of <linux/init.h>
  drivers/dma: delete non-required instances of <linux/init.h>
  drivers/gpu: delete non-required instances of <linux/init.h>
  drivers: delete remaining non-required instances of <linux/init.h>
  include: remove needless instances of <linux/init.h>

 arch/alpha/kernel/err_ev6.c                        |  1 -
 arch/alpha/kernel/irq.c                            |  1 -
 arch/alpha/kernel/srmcons.c                        |  3 +-
 arch/alpha/kernel/traps.c                          |  1 -
 arch/alpha/oprofile/op_model_ev4.c                 |  1 -
 arch/alpha/oprofile/op_model_ev5.c                 |  1 -
 arch/alpha/oprofile/op_model_ev6.c                 |  1 -
 arch/alpha/oprofile/op_model_ev67.c                |  1 -
 arch/arm/common/dmabounce.c                        |  1 -
 arch/arm/firmware/trusted_foundations.c            |  1 -
 arch/arm/include/asm/arch_timer.h                  |  1 -
 arch/arm/kernel/entry-armv.S                       |  2 +
 arch/arm/kernel/entry-header.S                     |  1 -
 arch/arm/kernel/hyp-stub.S                         |  1 -
 arch/arm/kernel/suspend.c                          |  1 -
 arch/arm/kernel/unwind.c                           |  1 -
 arch/arm/mach-at91/include/mach/gpio.h             |  1 +
 arch/arm/mach-cns3xxx/pm.c                         |  1 -
 arch/arm/mach-exynos/headsmp.S                     |  1 -
 arch/arm/mach-footbridge/personal.c                |  1 -
 arch/arm/mach-imx/headsmp.S                        |  1 -
 arch/arm/mach-imx/iomux-v3.c                       |  1 -

 [.... snip ~1300 lines ...]

 drivers/watchdog/stmp3xxx_rtc_wdt.c                |  1 -
 drivers/watchdog/wdt_pci.c                         |  1 -
 drivers/xen/xen-stub.c                             |  1 -
 fs/notify/inotify/inotify_user.c                   |  4 +-
 include/drm/drmP.h                                 |  2 +-
 include/linux/fb.h                                 |  1 -
 include/linux/ide.h                                |  1 -
 include/linux/init.h                               | 77 ----------------------
 include/linux/kdb.h                                |  1 -
 include/linux/linux_logo.h                         |  3 -
 include/linux/lsm_audit.h                          |  1 -
 include/linux/module.h                             | 72 ++++++++++++++++++++
 include/linux/moduleparam.h                        |  1 -
 include/linux/netfilter.h                          |  1 -
 include/linux/nls.h                                |  2 +-
 include/linux/percpu_ida.h                         |  1 -
 include/linux/profile.h                            |  1 -
 include/linux/pstore_ram.h                         |  1 -
 include/linux/usb/gadget.h                         |  1 -
 include/linux/zorro.h                              |  1 -
 include/xen/xenbus.h                               |  1 -
 mm/nommu.c                                         |  4 +-
 net/ipv4/netfilter.c                               |  9 +--
 scripts/pnmtologo.c                                |  1 +
 scripts/tags.sh                                    |  2 +-
 1254 files changed, 131 insertions(+), 1431 deletions(-)
 mode change 100755 => 100644 scripts/tags.sh

-- 
1.8.4.1
