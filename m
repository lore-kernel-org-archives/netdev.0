From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [GIT PULL] tree-wide: clean up no longer required #include <linux/init.h>
Date: Tue, 4 Feb 2014 15:51:58 -0500
Message-ID: <1391547118-21967-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
        <linux-alpha@vger.kernel.org>, <linux-arch@vger.kernel.org>,
        <linux-arm-kernel@lists.infradead.org>,
        <linux-ia64@vger.kernel.org>, <linux-m68k@vger.kernel.org>,
        <linux-mips@linux-mips.org>, <linuxppc-dev@lists.ozlabs.org>,
        <linux-s390@vger.kernel.org>, <sparclinux@vger.kernel.org>,
        <x86@kernel.org>, <netdev@vger.kernel.org>, <kvm@vger.kernel.org>,
        <sfr@canb.auug.org.au>, <rusty@rustcorp.com.au>,
        <gregkh@linuxfoundation.org>, <akpm@linux-foundation.org>
To: <torvalds@linux-foundation.org>
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

We've had this in linux-next for 2+ weeks (thanks Stephen!) as a
linux-stable like queue of patches, and as can be seen here:

  https://git.kernel.org/pub/scm/linux/kernel/git/paulg/init.git

most of the changes in the last week have been trivial adding acks
or dropping patches that maintainers decided to take themselves.

With -rc1 now containing what was in linux-next, the queue applies
to that baseline w/o issue, and I've redone comprehensive multi
arch build testing on the -rc1 baseline as a final sanity check.

Original RFC discussion and patch posting is here, if needed:

  https://lkml.org/lkml/2014/1/21/434

Suggested merge text follows:

   ----------------------------8<-----------------------------
Summary - We removed cpuinit and devinit, which left ~2000 instances
of include <linux/init.h> that were no longer needed.  To fully enable
this removal/cleanup, we relocate module_init() from init.h into
module.h.  Multi arch/multi config build testing on linux-next has
been used to find and fix any implicit header dependencies prior to
deploying the actual init.h --> module.h move, to preserve bisection.

Additional details:

module_init/module_exit and friends moved to module.h
-----------------------------------------------------
Aside from enabling this init.h cleanup to extend into modular files,
it actually does make sense.  For all modules will use some form of
our initfunc processing/categorization, but not all initfunc users
will be necessarily using modular functionality.  So we move these
module related macros to module.h and ensure module.h sources init.h


module_init in non modular code:
--------------------------------
This series uncovered that we are enabling people to use module_init
in non-modular code.  While that works fine, there are at least three
reasons why it probably should not be encouraged:

 1) it makes a casual reader of the code assume the code is modular
    even though it is obj-y (builtin) or controlled by a bool Kconfig.

 2) it makes it too easy to add dead code in a function that is handed
    to module_exit() -- [more on that below]

 3) it breaks our ability to use priority sorted initcalls properly
    [more on that below.]

 4) on some files, the use of module.h vs. init.h can cost a ~10%
    increase in the number of lines output from CPP.

After this change, a new coder who tries to make use of module_init in
non modular code would find themselves also needing to include the
module.h header.  At which point the odds are greater that they would
ask themselves "Am I doing this right?  I shouldn't need this."

Note that existing non-modular code that already includes module.h and
uses module_init doesn't get fixed here, since they already build w/o
errors triggered by this change; we'll have to hunt them down later.


module_init and initcall ordering:
----------------------------------
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
-------------------------
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
-------
To finalize the removal of cpuinit, which was done several releases
ago, we remove the remaining stub functions from init.h in this
series.  We've seen one or two "users" try to creep back in, so this
will close the door on that chapter and prevent creep.

   ----------------------------8<-----------------------------

Thanks,
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


The following changes since commit 38dbfb59d1175ef458d006556061adeaa8751b72:

  Linus 3.14-rc1 (2014-02-02 16:42:13 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/paulg/linux.git tags/init-cleanup

for you to fetch changes up to a830e2e2777c893e5bfdaa370d6375023e8cd2a5:

  include: remove needless instances of <linux/init.h> (2014-02-03 16:39:14 -0500)

----------------------------------------------------------------
Cleanup of <linux/init.h> for 3.14-rc1

----------------------------------------------------------------
Paul Gortmaker (77):
      init: delete the __cpuinit related stubs
      kernel: audit/fix non-modular users of module_init in core code
      mm: replace module_init usages with subsys_initcall in nommu.c
      fs/notify: don't use module_init for non-modular inotify_user code
      netfilter: don't use module_init/exit in core IPV4 code
      x86: don't use module_init in non-modular intel_mid_vrtc.c
      x86: don't use module_init for non-modular core bootflag code
      x86: replace __init_or_module with __init in non-modular vsmp_64.c
      x86: don't use module_init in non-modular devicetree.c code
      drivers/tty/hvc: don't use module_init in non-modular hyp. console code
      staging: don't use module_init in non-modular ion_dummy_driver.c
      powerpc: use device_initcall for registering rtc devices
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
      m68k: don't use module_init in non-modular mvme16x/rtc.c code
      ia64: don't use module_init for non-modular core kernel/mca.c code
      ia64: don't use module_init in non-modular sim/simscsi.c code
      mips: make loongsoon serial driver explicitly modular
      mips: don't use module_init in non-modular sead3-mtd.c code
      cris: don't use module_init for non-modular core intmem.c code
      parisc: don't use module_init for non-modular core pdc_cons code
      parisc64: don't use module_init for non-modular core perf code
      mn10300: don't use module_init in non-modular flash.c code
      sh: don't use module_init in non-modular psw.c code
      sh: mach-highlander/psw.c is tristate and should use module.h
      xtensa: don't use module_init for non-modular core network.c code
      drivers/clk: don't use module_init in clk-nomadik.c which is non-modular
      cpuidle: don't use modular platform register in non-modular ARM drivers
      drivers/platform: don't use modular register in non-modular pdev_bus.c
      module: relocate module_init from init.h to module.h
      logo: emit "#include <linux/init.h> in autogenerated C file
      arm: delete non-required instances of include <linux/init.h>
      mips: restore init.h usage to arch/mips/ar7/time.c
      s390: delete non-required instances of include <linux/init.h>
      alpha: delete non-required instances of <linux/init.h>
      powerpc: delete another unrequired instance of <linux/init.h>
      arm64: delete non-required instances of <linux/init.h>
      watchdog: delete non-required instances of include <linux/init.h>
      video: delete non-required instances of include <linux/init.h>
      rtc: delete non-required instances of include <linux/init.h>
      scsi: delete non-required instances of include <linux/init.h>
      spi: delete non-required instances of include <linux/init.h>
      acpi: delete non-required instances of include <linux/init.h>
      drivers/power: delete non-required instances of include <linux/init.h>
      drivers/media: delete non-required instances of include <linux/init.h>
      drivers/ata: delete non-required instances of include <linux/init.h>
      drivers/hwmon: delete non-required instances of include <linux/init.h>
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
 arch/arm/mach-iop33x/uart.c                        |  1 -
 arch/arm/mach-msm/headsmp.S                        |  1 -
 arch/arm/mach-msm/proc_comm.h                      |  1 -
 arch/arm/mach-mvebu/headsmp.S                      |  1 -
 arch/arm/mach-netx/fb.c                            |  1 -
 arch/arm/mach-netx/pfifo.c                         |  1 -
 arch/arm/mach-netx/xc.c                            |  1 -
 arch/arm/mach-nspire/clcd.c                        |  1 -
 arch/arm/mach-omap1/fpga.c                         |  1 -
 arch/arm/mach-omap1/include/mach/serial.h          |  1 -
 arch/arm/mach-omap2/omap-headsmp.S                 |  1 -
 arch/arm/mach-omap2/omap3-restart.c                |  1 -
 arch/arm/mach-omap2/vc3xxx_data.c                  |  1 -
 arch/arm/mach-omap2/vc44xx_data.c                  |  1 -
 arch/arm/mach-omap2/vp3xxx_data.c                  |  1 -
 arch/arm/mach-omap2/vp44xx_data.c                  |  1 -
 arch/arm/mach-prima2/headsmp.S                     |  1 -
 arch/arm/mach-pxa/clock-pxa2xx.c                   |  1 -
 arch/arm/mach-pxa/clock-pxa3xx.c                   |  1 -
 arch/arm/mach-pxa/corgi_pm.c                       |  1 -
 arch/arm/mach-pxa/mfp-pxa3xx.c                     |  1 -
 arch/arm/mach-pxa/spitz_pm.c                       |  1 -
 arch/arm/mach-s3c24xx/clock-s3c244x.c              |  1 -
 arch/arm/mach-s3c24xx/iotiming-s3c2410.c           |  1 -
 arch/arm/mach-s3c24xx/iotiming-s3c2412.c           |  1 -
 arch/arm/mach-s3c24xx/irq-pm.c                     |  1 -
 arch/arm/mach-s3c24xx/pm.c                         |  1 -
 arch/arm/mach-s3c64xx/mach-crag6410-module.c       |  2 +-
 arch/arm/mach-s5p64x0/clock.c                      |  1 -
 arch/arm/mach-sa1100/ssp.c                         |  1 -
 arch/arm/mach-shmobile/headsmp-scu.S               |  1 -
 arch/arm/mach-shmobile/headsmp.S                   |  1 -
 arch/arm/mach-shmobile/platsmp.c                   |  1 -
 arch/arm/mach-shmobile/sleep-sh7372.S              |  1 -
 arch/arm/mach-socfpga/headsmp.S                    |  1 -
 arch/arm/mach-sti/headsmp.S                        |  1 -
 arch/arm/mach-sunxi/headsmp.S                      |  1 -
 arch/arm/mach-tegra/flowctrl.c                     |  1 -
 arch/arm/mach-tegra/headsmp.S                      |  1 -
 arch/arm/mach-tegra/reset-handler.S                |  1 -
 arch/arm/mach-u300/dummyspichip.c                  |  1 -
 arch/arm/mach-ux500/board-mop500-audio.c           |  1 -
 arch/arm/mach-ux500/headsmp.S                      |  1 -
 arch/arm/mach-versatile/versatile_ab.c             |  1 -
 arch/arm/mach-vexpress/spc.c                       |  2 +-
 arch/arm/mach-zynq/headsmp.S                       |  1 -
 arch/arm/mm/hugetlbpage.c                          |  1 -
 arch/arm/plat-iop/i2c.c                            |  1 -
 arch/arm/plat-samsung/pm-check.c                   |  1 -
 arch/arm/plat-samsung/pm-gpio.c                    |  1 -
 arch/arm/plat-samsung/s5p-irq-pm.c                 |  1 -
 arch/arm/plat-versatile/headsmp.S                  |  1 -
 arch/arm/plat-versatile/platsmp.c                  |  1 -
 arch/arm/vfp/entry.S                               |  2 +
 arch/arm64/include/asm/arch_timer.h                |  1 -
 arch/arm64/kernel/cputable.c                       |  2 -
 arch/arm64/kernel/entry.S                          |  1 -
 arch/arm64/kernel/hyp-stub.S                       |  1 -
 arch/arm64/kernel/process.c                        |  1 -
 arch/arm64/kernel/ptrace.c                         |  1 -
 arch/arm64/kernel/smp_spin_table.c                 |  1 -
 arch/arm64/kernel/vdso/vdso.S                      |  1 -
 arch/arm64/lib/delay.c                             |  1 -
 arch/arm64/mm/cache.S                              |  1 -
 arch/arm64/mm/proc.S                               |  1 -
 arch/cris/arch-v32/mm/intmem.c                     |  3 +-
 arch/ia64/hp/sim/simscsi.c                         | 11 +---
 arch/ia64/sn/kernel/mca.c                          |  3 +-
 arch/m68k/mvme16x/rtc.c                            |  2 +-
 arch/mips/ar7/time.c                               |  1 +
 arch/mips/loongson/common/serial.c                 |  9 ++-
 arch/mips/mti-sead3/sead3-mtd.c                    |  3 +-
 arch/mn10300/unit-asb2303/flash.c                  |  3 +-
 arch/parisc/kernel/pdc_cons.c                      |  3 +-
 arch/parisc/kernel/perf.c                          |  3 +-
 arch/powerpc/kernel/time.c                         |  2 +-
 arch/powerpc/mm/hugetlbpage.c                      |  2 +-
 arch/powerpc/platforms/83xx/suspend.c              |  3 +-
 arch/powerpc/platforms/ps3/time.c                  |  3 +-
 arch/powerpc/sysdev/fsl_lbc.c                      |  2 +-
 arch/powerpc/sysdev/indirect_pci.c                 |  1 -
 arch/sh/boards/mach-highlander/psw.c               |  2 +-
 arch/sh/boards/mach-landisk/psw.c                  |  2 +-
 arch/x86/kernel/bootflag.c                         |  2 +-
 arch/x86/kernel/devicetree.c                       |  2 +-
 arch/x86/kernel/vsmp_64.c                          |  2 +-
 arch/x86/platform/intel-mid/intel_mid_vrtc.c       |  3 +-
 arch/xtensa/platforms/iss/network.c                |  4 +-
 drivers/acpi/apei/apei-base.c                      |  1 -
 drivers/acpi/button.c                              |  1 -

 [ ... snip ~1000 lines of trivial driver diffstat ... ]

 drivers/watchdog/wdt_pci.c                         |  1 -
 drivers/xen/xen-stub.c                             |  1 -
 fs/notify/inotify/inotify_user.c                   |  4 +-
 include/drm/drmP.h                                 |  1 -
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
 include/xen/xenbus.h                               |  1 -
 kernel/hung_task.c                                 |  3 +-
 kernel/kexec.c                                     |  4 +-
 kernel/profile.c                                   |  2 +-
 kernel/sched/stats.c                               |  2 +-
 kernel/user.c                                      |  3 +-
 kernel/user_namespace.c                            |  2 +-
 mm/nommu.c                                         |  4 +-
 net/ipv4/netfilter.c                               |  9 +--
 scripts/pnmtologo.c                                |  1 +
 scripts/tags.sh                                    |  2 +-
 1115 files changed, 148 insertions(+), 1273 deletions(-)
