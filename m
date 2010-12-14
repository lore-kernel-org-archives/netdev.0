From: Mike Waychison <mikew@google.com>
Subject: [PATCH v3 00/22] netoops support
Date: Tue, 14 Dec 2010 13:28:53 -0800
Message-ID: <20101214212846.17022.64836.stgit@mike.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: adurbin@google.com, linux-kernel@vger.kernel.org,
	chavey@google.com, Greg KH <greg@kroah.com>,
	netdev@vger.kernel.org,
	=?utf-8?q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>,
	akpm@linux-foundation.org, linux-api@vger.kernel.org
To: simon.kagstrom@netinsight.net, davem@davemloft.net,
	nhorman@tuxdriver.com, Matt Mackall <mpm@selenic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset applies to v2.6.37-rc5.  It also applies cleanly to net-next as
of this morning.

The following series implements support for 'netoops', a simple driver that
will deliver kmsg logs together with machine specifics over the network.

This driver is based on code used in Google's production server environment.
We internally call the driver 'netdump', but are planning on changing the name
to 'netoops' to follow the convention set by both the mtdoops and ramoops
drivers.  We use these facilities to gather crash data from our entire fleet of
machines in a light-weight manner.  We do things this way because it
simply isn't feasible to gather full crash data off of every machine in
the wild when they decide it is time to die.

Currently, this driver only supports UDP over ipv4.

In order to handle configuration, the target support in netconsole is
fixed, seperated out, and re-used by netoops.

I'm posting these patches in an effort to eventually get this sort of
functionality mainlined.  Issues that I had personal concerns about have
been addressed, as well have several from others.  These changes are
documented below.

There is some contention as to whether or not the transmission of
structured data is useful in a crash situation.  I have documented why
we prefer to have structured date below in the comparison to netconsole.


Patchset summary
================

Patches 1 through 4 inclusive are fixes to the existing netconsole code,
adding locking consistency, fixing races and deadlocks.  These are probably
ready to be merged as they fix real problems with the netconsole driver.

Patches 5 through 14 inclusive splits the target configuration portion
of netconsole out into a new component in net/core/netpoll_targets.c.  These
are ready to merge as a cleanup series.

Patches 15 through 18 inclusive are core changes to support functionality in
the netoops driver.  These are required for the netoops driver itself, but are
independent of all prior patches.

Patches 19 through 22 represent the netoops driver itself, with different
functional aspects broken out.

 1 - netconsole: Remove unneeded reference counting
 2 - netconsole: Introduce locking over the netpoll fields
 3 - netconsole: Introduce 'enabled' state-machine
 4 - netconsole: Call netpoll_cleanup() in process context

 5 - netconsole: Wrap the list and locking in a structure
 6 - netconsole: Push configfs_subsystem into netpoll_targets
 7 - netconsole: Move netdev_notifier into netpoll_targets
 8 - netconsole: Split out netpoll_targets init/exit
 9 - netconsole: Add pointer to netpoll_targets
10 - netconsole: Rename netconsole_target -> netpoll_target
11 - netconsole: Abstract away the subsystem name
12 - netconsole: Move setting of default ports.
13 - netpoll: Introduce netpoll_target configs
14 - netpoll: Move target code into netpoll_targets.c

15 - Oops: Pass regs to oops_exit()
16 - kmsg_dumper: Pass pt_regs along to dumpers.
17 - kmsg_dumper: Introduce a new 'SOFT' dump reason
18 - sys-rq: Add option to soft dump

19 - netoops: add core functionality
20 - netoops: Add x86 specific bits to packet headers
21 - netoops: Add user-programmable boot_id
22 - netoops: Add a user programmable blob to the netoops packet.

Diffstat
========
 Documentation/sysrq.txt         |    4 
 arch/arm/kernel/traps.c         |    2 
 arch/parisc/kernel/traps.c      |    2 
 arch/powerpc/kernel/traps.c     |    2 
 arch/s390/kernel/traps.c        |    2 
 arch/sh/kernel/traps_32.c       |    2 
 arch/x86/kernel/dumpstack.c     |    2 
 drivers/char/ramoops.c          |    4 
 drivers/mtd/mtdoops.c           |    4 
 drivers/net/Kconfig             |   26 +
 drivers/net/Makefile            |    1 
 drivers/net/netconsole.c        |  735 +--------------------------------------
 drivers/net/netoops.c           |  346 ++++++++++++++++++
 drivers/tty/sysrq.c             |   14 
 include/linux/kernel.h          |    2 
 include/linux/kmsg_dump.h       |    9 
 include/linux/netpoll_targets.h |   76 ++++
 kernel/kexec.c                  |    5 
 kernel/panic.c                  |    6 
 kernel/printk.c                 |    4 
 net/core/Makefile               |    1 
 net/core/netpoll_targets.c      |  749 ++++++++++++++++++++++++++++++++++++++++
 22 files changed, 1260 insertions(+), 738 deletions(-)

Comparison to netconsole
========================

This driver differs from netconsole in a couple different ways.

* Network overheads:
     With the number of machines we have, streaming large amounts of consoles
     within the data center can really add up.  This gets worse when you take
     into account how reliant we are on kernel logging like OOM conditions
     (which are very regular and very verbose).  Events in the data center
     (such as application growth) tend to be temporally correlated, which
     causes large bursts of logging when we are OOM.  We aren't so interested
     in this kernel verbosity from a global collection standpoint though, and
     haven't been keen on the amount of extra un-regulated UDP traffic it would
     generate.  We are however interested in kernel oopses which occur far less
     often.

* Structured data:
     In terms of the data received, we've really benefited by having structured
     data in the payload.  We've been collecting kernel oopses since sometime
     in 2006 and have a _vast_ collection of crashes that we have indexed by
     just about anything you could ever want (registers, full dmesg text,
     backtraces, motherboards, CPU types, kernel versions, bios versions, etc).
     This has allowed us to quickly find 'big bugs' vs 'rare bugs' (similar to
     kerneloops.org) in a data center environment.

     This structured data also allows for automated labeling of oopses/panics
     using a variety of criteria.  Netconsole only provides unstructured
     streaming data, and the bits that we care about are either not present in
     the dmesg logs or they are, but is extremely difficult to parse them out
     (especially across kernel versions).  Other bits of information, like
     firmware version, are also difficult to associate with crashes with
     post-processing due to gaps in global sampling and the churn that occurs
     in the lab where versions can change quickly.

* Network reliability:
     Another area where the two approaches have differed has been in handling
     of network reliability.  Historically (though less and less now), we found
     that we had to transmit data several times.  We also used to explicitly
     space out packets with delays to handle switch chip buffer overruns.  Both
     of these functions I presume could be added to netconsole without too much
     of a problem.

ChangeLog:
==========
- v3
   - Dropped 'net_dump_now' interface as we already have CONFIG_LKDTM to
     trigger crashes.
   - Updated to also cancel any pending workers and clean the target up
     if needed when removing being dropped from configfs.  Issue
     identified by Neil Horman.
   - The user-programmable boot_id was been split out into its own patch.
   - Other userland programmable entries have been removed and replaced
     by a 'netoops_user_blob' field that is programmable to anything
     less than or equal to 128 bytes in length.
   - Support for 'one-shot' has been removed completely.
   - Now that one-shot support and net_dump_now support are removed from
     the patchset, we no longer have any interfaces in procfs.
   - x86 vendor is now specified in the packet headers.
   - 'netpoll_targets' can now be compiled as a module if neither
     netconsole nor netoops require it to be built in. This property
     also extends to CONFIGFS_FS.
   - All fields for packets are now encoded in little-endian.

- v2
   - Now uses the same mechanism that netconsole uses for configuring
     targets, which is also now abstracted out to
     net/core/netpoll_targets.c.
