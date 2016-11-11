From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: [PATCH v4 0/6] make POSIX timers optional with some Kconfig help
Date: Fri, 11 Nov 2016 00:10:04 -0500
Message-ID: <1478841010-28605-1-git-send-email-nicolas.pitre@linaro.org>
Cc: Richard Cochran <richardcochran@gmail.com>,
        Paul Bolle <pebolle@tiscali.nl>,
        Thomas Gleixner <tglx@linutronix.de>,
        Josh Triplett <josh@joshtriplett.org>,
        Edward Cree <ecree@solarflare.com>, netdev@vger.kernel.org,
        linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org
To: John Stultz <john.stultz@linaro.org>,
        Michal Marek <mmarek@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Many embedded systems don't need the full POSIX timer support.
Configuring them out provides a nice kernel image size reduction.

When POSIX timers are configured out, the PTP clock subsystem should be
left out as well. However a bunch of ethernet drivers currently *select*
the later in their Kconfig entries. Therefore some more work was needed
to break that hard dependency from those drivers without preventing their
usage altogether.

Therefore this series also includes kconfig changes to implement a new
keyword to express some reverse dependencies like "select" does, named
"imply", and still allowing for the target config symbol to be disabled
if the user or a direct dependency says so.

At this point I'd like to gather ACKs especially from people in the "To"
field. Ideally this would need to go upstream as a single series to avoid
cross subsystem dependency issues.  So far it was suggested that this could
go via the kbuild tree. Given the end goal and the included timer cleanup
patches I'd lean towards the timer tree but any tree would suit me just
as well.

This is also available here for those who prefer a git tree:
git://git.linaro.org/people/nicolas.pitre/linux/ configurable_posix_timers

Changes from v3:

- Added a patch to move sys_alarm to itimer.c where the support code lives.
- Added a patch to move entropy collection out of posix-cpu-timers.c.
- Remove itimer as well when POSIX_TIMERS=n as they rely on code already
  removed. This means the getitimer, setitimer and alarm syscalls are also
  stubbed out in that case.
- Reverted the addition of empty timer stubs from posix-timers.h. Since
  there is only a few callers, it's better to conditionalize call sites
  instead, and get a link error if some were missed. Easier to clearly
  ponder the implications that way.
- Collected more ACKs.

Changes from v2:

- Dropped the patch adding the "suggest" keyword as nothing uses it.
  Requested by Paul Bolle.
- Various documentation and commit log clarifications, prompted also
  by Paul Bolle.
- Collected more ACKs.

Changes from v1:

- added "suggest" to kconfig for completeness
- various typo fixes
- small "imply" effect visibility fix

The bulk of the diffstat comes from the kconfig lex parser regeneration.

Diffstat:

 Documentation/kbuild/kconfig-language.txt       |   29 +
 arch/alpha/kernel/osf_sys.c                     |    8 +
 drivers/Makefile                                |    2 +-
 drivers/char/Kconfig                            |    1 +
 drivers/net/ethernet/adi/Kconfig                |    2 +-
 drivers/net/ethernet/amd/Kconfig                |    2 +-
 drivers/net/ethernet/amd/xgbe/xgbe-main.c       |    6 +-
 drivers/net/ethernet/broadcom/Kconfig           |    4 +-
 drivers/net/ethernet/cavium/Kconfig             |    2 +-
 drivers/net/ethernet/freescale/Kconfig          |    2 +-
 drivers/net/ethernet/intel/Kconfig              |   10 +-
 drivers/net/ethernet/mellanox/mlx4/Kconfig      |    2 +-
 drivers/net/ethernet/mellanox/mlx5/core/Kconfig |    2 +-
 drivers/net/ethernet/renesas/Kconfig            |    2 +-
 drivers/net/ethernet/samsung/Kconfig            |    2 +-
 drivers/net/ethernet/sfc/Kconfig                |    2 +-
 drivers/net/ethernet/stmicro/stmmac/Kconfig     |    2 +-
 drivers/net/ethernet/ti/Kconfig                 |    2 +-
 drivers/net/ethernet/tile/Kconfig               |    2 +-
 drivers/ptp/Kconfig                             |   10 +-
 fs/exec.c                                       |    2 +
 include/linux/ptp_clock_kernel.h                |   65 +-
 include/linux/time.h                            |    2 -
 init/Kconfig                                    |   17 +
 kernel/compat.c                                 |    8 +
 kernel/exit.c                                   |   15 +-
 kernel/fork.c                                   |    2 +
 kernel/signal.c                                 |    6 +
 kernel/sys.c                                    |    3 +-
 kernel/time/Makefile                            |   10 +-
 kernel/time/alarmtimer.c                        |    6 +-
 kernel/time/itimer.c                            |   15 +-
 kernel/time/posix-cpu-timers.c                  |    4 -
 kernel/time/posix-stubs.c                       |  123 ++
 kernel/time/timer.c                             |   16 +-
 scripts/kconfig/expr.h                          |    2 +
 scripts/kconfig/menu.c                          |   55 +-
 scripts/kconfig/symbol.c                        |   24 +-
 scripts/kconfig/zconf.gperf                     |    1 +
 scripts/kconfig/zconf.hash.c_shipped            |   30 +-
 scripts/kconfig/zconf.tab.c_shipped             | 1581 +++++++++++------------
 scripts/kconfig/zconf.y                         |   16 +-
 security/selinux/hooks.c                        |   11 +-
 43 files changed, 1148 insertions(+), 960 deletions(-)
