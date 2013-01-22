From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH RFC net-next 00/15] drivers/net: obsolete ISA driver round-up
Date: Mon, 21 Jan 2013 20:46:07 -0500
Message-ID: <1358819182-28032-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Donald Becker <becker@scyld.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Alan Cox <alan@linux.intel.com>, Andreas Mohr <andi@lisas.de>,
	Jan-Pascal van Best <janpascal@vanbest.org>,
	Mika Kuoppala <miku@iki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:45417 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753459Ab3AVBqw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 20:46:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Ethernet-HowTo was maintained for roughly 10 years, from 1993 to 2003.
Fortunately sane hardware probing and auto detection (via PCI and ISA/PnP)
largely made the document a relic of the past, hence it being abandoned
a decade ago.

However, there is one last useful thing that we can extract from the
effort made in maintaining that document.  We can use it to guide us
with respect to what rare, experimental and/or super ancient 10Mbit
ISA drivers don't make sense to maintain in-tree anymore.

Nobody will argue that ISA is obsolete.  Availability went away at about
the time Pentium3 motherboards moved from 500MHz Slot1/SECC processors
to the green 500MHz Socket 370 Pentium3 chips, at the turn of the century.

In theory, it is possible that someone could still be running one of these
12+ year old P3 machines and want 3.9+ bleeding edge kernels (but unlikely).
In light of the above (remote) possibility, we can defer the removal of some
ISA network drivers that were highly popular and well tested.  Typically
that means the stuff more from the mid to late '90s, some with ISA PnP
support, like the 3c509, the wd/SMC 8390 based stuff, PCnet/lance etc.

But a lot of other drivers, typically from the early 1990s were for rare
hardware, and experimental (to the point of requiring a cron job that would
do a test ping, and then ifconfig down/up and/or a rmmod/insmod!).  And
some of these drivers (znet, and lp486e to name two) are physically tied
to platforms with on motherboard ethernet -- of 486 machines that date
from the early 1990s and can only have single digit amounts of memory.

What I'd like to achieve here with this series, is to get rid of those old
drivers that are no longer being used.  In an earlier discussion where
I'd proposed deleting a single driver, Alan suggested we instead dump
all the historical stuff in one go, to make it "...immediately obvious
where the break point is..."[1] and that it was "perfectly reasonable it
(and a pile of other ISA cards) ought to be shown the door"[2].  So that
is the goal here - make a clear line in the sand where the really ancient
stuff finally gets kicked to the curb.

Two old parallel port drivers are considered for removal here as well,
since in early 386/486 ISA machines, the parallel port was typically found
with the UARTS on the multi-I/O ISA controller card.  These drivers also date
from the early 1990's; parallel ports are no longer found on modern boards,
and their performance was not even capable of 10% of 10Mbit bandwidth.

Allow me a preemptive justification against the inevitable comments from
well meaning bystanders who suggest "why not just leave all this alone?".
Dead drivers cost us all if they are left in tree.  If you think that
is false, then please first consider:

-every time you type "git status", you are checking to see if modifications
 have been made by you to all that dead code.

-every time you type "git grep <regex>" you are searching through files
 which contain that dead code that simply does not interest you.

-every time you build a "allyesconfig" and an "allmodconfig" (don't tell
 me you skip this step before submitting your changes to a maintainer),
 you waste CPU cycles building this dead code.

-every time there is a tree wide API change, or cleanup, or file relocation,
 we pay the cost of updating dead code, or moving dead code.

-daily regression tests (take linux-next as the most transparent
 example) spend time building (and possibly running) this dead code.

-hard working people who regularly run auditing tools looking for lurking
 bugs (sparse/coverity/smatch/coccinelle) are wasting time checking for,
 and fixing bugs in this dead code.

This last one is key.  Please take a look at the git history for the
files that are proposed for removal here.  Look at the git history for
any one of them ("git whatchanged --follow drivers/net/.../driver.c")
Mentally sort the changes into two bins -- (1) the robotic tree-wide
changes, and (2) the "look I found a real run-time bug while using this"
category.  You will see that category #2 is essentially empty.

Further to that, realize that drivers don't simply disappear.  We are
not operating in the binary-only distribution space like other OS.  All
these drivers remain in the git history forever.  If a person is an
enthusiast for extreme legacy hardware, they are probably already
customizing their kernel source and building it themselves to support
such systems.  Also keep in mind that they could still build the 3.8
kernel exactly as-is, and run it (or a 3.8.x stable variant of it) for
several more years if they were really determined to cling to these old
experimental ISA drivers for some reason.

In summary, I hope that folks can be pragmatic about this, and not
get swept up in nostalgia.  Ask yourself whether it is realistic to
expect a person would have a genuine use case where they would
need to build a 3.9+ modern kernel and install it on some legacy hardware
that has no option but to absolutely _require_ one of the drivers
that are deleted here.

The following series was created with --irreversible-delete for
ease of review (it skips showing the content of files that are
deleted); however the complete patches can be pulled as per below.

Thanks,
Paul.

[1] http://www.spinics.net/lists/netdev/msg199142.html
[2] http://lists.openwall.net/netdev/2012/05/19/41

Cc: Donald Becker <becker@scyld.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Cc: Alan Cox <alan@linux.intel.com>
Cc: Andreas Mohr <andi@lisas.de>
Cc: Jan-Pascal van Best <janpascal@vanbest.org>
Cc: Mika Kuoppala <miku@iki.fi>

---

The following changes since commit 63b203b43baeb1ba5fab0b7f3611e0f0a2a4a7ab:

  isdn/gigaset: beautify ev-layer.c (2013-01-21 17:36:26 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/paulg/linux.git legacy-isa-delete

for you to fetch changes up to 6e5a2c3cc742fb3b9fb2cb3f0454918a5d5463f6:

  drivers/net: delete old x86 variant of the seeq8005 driver (2013-01-21 20:02:23 -0500)

----------------------------------------------------------------
Paul Gortmaker (15):
      drivers/net: delete 486 Apricot support
      drivers/net: delete intel 486 panther onboard ethernet support
      drivers/net: delete old 8bit ISA 3c501 driver.
      drivers/net: delete old parallel port de600/de620 drivers
      drivers/net: delete the 3Com 3c505/3c507 intel i825xx support
      drivers/net: delete ISA intel eexpress and eepro i825xx drivers
      drivers/net: delete intel i825xx based znet notebook driver
      drivers/net: delete Racal Interlan ISA ni52 (i825xx) driver
      drivers/net: delete old 8 bit ISA Racal ni5010 support.
      drivers/net: delete at1700 ISA 10Mbit driver
      drivers/net: delete old fujitsu based eth16i driver
      drivers/net: delete the really obsolete 8390 based 10Mbit ISA drivers
      drivers/net: delete old DEC depca ISA drivers support.
      drivers/net: delete Digital EtherWorks-3 support.
      drivers/net: delete old x86 variant of the seeq8005 driver

 Documentation/networking/00-INDEX      |    4 -
 Documentation/networking/DLINK.txt     |  203 ----
 Documentation/networking/depca.txt     |   92 --
 Documentation/networking/ewrk3.txt     |   46 -
 MAINTAINERS                            |   12 -
 drivers/net/Space.c                    |   75 +-
 drivers/net/ethernet/3com/3c501.c      |  897 ---------------
 drivers/net/ethernet/3com/3c501.h      |   91 --
 drivers/net/ethernet/3com/Kconfig      |   14 -
 drivers/net/ethernet/3com/Makefile     |    1 -
 drivers/net/ethernet/8390/3c503.c      |  778 -------------
 drivers/net/ethernet/8390/3c503.h      |   91 --
 drivers/net/ethernet/8390/Kconfig      |   48 -
 drivers/net/ethernet/8390/Makefile     |    4 -
 drivers/net/ethernet/8390/e2100.c      |  489 --------
 drivers/net/ethernet/8390/hp-plus.c    |  505 --------
 drivers/net/ethernet/8390/hp.c         |  438 -------
 drivers/net/ethernet/Kconfig           |    1 -
 drivers/net/ethernet/Makefile          |    1 -
 drivers/net/ethernet/amd/Kconfig       |   13 -
 drivers/net/ethernet/amd/Makefile      |    1 -
 drivers/net/ethernet/amd/depca.c       | 1910 -------------------------------
 drivers/net/ethernet/amd/depca.h       |  183 ---
 drivers/net/ethernet/dec/Kconfig       |   16 -
 drivers/net/ethernet/dec/Makefile      |    1 -
 drivers/net/ethernet/dec/ewrk3.c       | 1961 --------------------------------
 drivers/net/ethernet/dec/ewrk3.h       |  322 ------
 drivers/net/ethernet/dlink/Kconfig     |   32 +-
 drivers/net/ethernet/dlink/Makefile    |    2 -
 drivers/net/ethernet/dlink/de600.c     |  529 ---------
 drivers/net/ethernet/dlink/de600.h     |  168 ---
 drivers/net/ethernet/dlink/de620.c     |  987 ----------------
 drivers/net/ethernet/dlink/de620.h     |  117 --
 drivers/net/ethernet/fujitsu/Kconfig   |   23 -
 drivers/net/ethernet/fujitsu/Makefile  |    2 -
 drivers/net/ethernet/fujitsu/at1700.c  |  791 -------------
 drivers/net/ethernet/fujitsu/eth16i.c  | 1483 ------------------------
 drivers/net/ethernet/i825xx/3c505.c    | 1672 ---------------------------
 drivers/net/ethernet/i825xx/3c505.h    |  292 -----
 drivers/net/ethernet/i825xx/3c507.c    |  939 ---------------
 drivers/net/ethernet/i825xx/82596.c    |   96 +-
 drivers/net/ethernet/i825xx/Kconfig    |   90 --
 drivers/net/ethernet/i825xx/Makefile   |    8 -
 drivers/net/ethernet/i825xx/eepro.c    | 1822 -----------------------------
 drivers/net/ethernet/i825xx/eexpress.c | 1661 ---------------------------
 drivers/net/ethernet/i825xx/eexpress.h |  179 ---
 drivers/net/ethernet/i825xx/lp486e.c   | 1337 ----------------------
 drivers/net/ethernet/i825xx/ni52.c     | 1346 ----------------------
 drivers/net/ethernet/i825xx/ni52.h     |  310 -----
 drivers/net/ethernet/i825xx/znet.c     |  928 ---------------
 drivers/net/ethernet/racal/Kconfig     |   33 -
 drivers/net/ethernet/racal/Makefile    |    5 -
 drivers/net/ethernet/racal/ni5010.c    |  771 -------------
 drivers/net/ethernet/racal/ni5010.h    |  144 ---
 drivers/net/ethernet/seeq/Kconfig      |   11 -
 drivers/net/ethernet/seeq/Makefile     |    1 -
 drivers/net/ethernet/seeq/seeq8005.c   |  749 ------------
 drivers/net/ethernet/seeq/seeq8005.h   |  156 ---
 58 files changed, 11 insertions(+), 24870 deletions(-)
 delete mode 100644 Documentation/networking/DLINK.txt
 delete mode 100644 Documentation/networking/depca.txt
 delete mode 100644 Documentation/networking/ewrk3.txt
 delete mode 100644 drivers/net/ethernet/3com/3c501.c
 delete mode 100644 drivers/net/ethernet/3com/3c501.h
 delete mode 100644 drivers/net/ethernet/8390/3c503.c
 delete mode 100644 drivers/net/ethernet/8390/3c503.h
 delete mode 100644 drivers/net/ethernet/8390/e2100.c
 delete mode 100644 drivers/net/ethernet/8390/hp-plus.c
 delete mode 100644 drivers/net/ethernet/8390/hp.c
 delete mode 100644 drivers/net/ethernet/amd/depca.c
 delete mode 100644 drivers/net/ethernet/amd/depca.h
 delete mode 100644 drivers/net/ethernet/dec/ewrk3.c
 delete mode 100644 drivers/net/ethernet/dec/ewrk3.h
 delete mode 100644 drivers/net/ethernet/dlink/de600.c
 delete mode 100644 drivers/net/ethernet/dlink/de600.h
 delete mode 100644 drivers/net/ethernet/dlink/de620.c
 delete mode 100644 drivers/net/ethernet/dlink/de620.h
 delete mode 100644 drivers/net/ethernet/fujitsu/at1700.c
 delete mode 100644 drivers/net/ethernet/fujitsu/eth16i.c
 delete mode 100644 drivers/net/ethernet/i825xx/3c505.c
 delete mode 100644 drivers/net/ethernet/i825xx/3c505.h
 delete mode 100644 drivers/net/ethernet/i825xx/3c507.c
 delete mode 100644 drivers/net/ethernet/i825xx/eepro.c
 delete mode 100644 drivers/net/ethernet/i825xx/eexpress.c
 delete mode 100644 drivers/net/ethernet/i825xx/eexpress.h
 delete mode 100644 drivers/net/ethernet/i825xx/lp486e.c
 delete mode 100644 drivers/net/ethernet/i825xx/ni52.c
 delete mode 100644 drivers/net/ethernet/i825xx/ni52.h
 delete mode 100644 drivers/net/ethernet/i825xx/znet.c
 delete mode 100644 drivers/net/ethernet/racal/Kconfig
 delete mode 100644 drivers/net/ethernet/racal/Makefile
 delete mode 100644 drivers/net/ethernet/racal/ni5010.c
 delete mode 100644 drivers/net/ethernet/racal/ni5010.h
 delete mode 100644 drivers/net/ethernet/seeq/seeq8005.c
 delete mode 100644 drivers/net/ethernet/seeq/seeq8005.h
