From: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
Subject: [announce] new rt2800 drivers for Ralink wireless & project tree
Date: Tue, 3 Nov 2009 19:51:05 +0100
Message-ID: <200911031951.05235.bzolnier@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Ivo van Doorn <ivdoorn@gmail.com>,
	Randy Dunlap <rdunlap@xenotime.net>,
	Luis Correia <luis.f.correia@gmail.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Ingo Molnar <mingo@elte.hu>,
	Johannes Berg <johannes@sipsolutions.net>,
	Jarek Poplawski <jarkao2@gmail.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	David Miller <davem@davemloft.net>
To: linux-wireless@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755108AbZKCUBp@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi,

The following patch series (against wireless-next) addresses issues raised
during code review and subsequently rejected by rt2x00/wireless/networking
maintainers.


Namely, it:

- Adds abstraction of chipset register access for chipsets connected to
  different buses by using new structure (struct rt2800_ops) which contains
  all needed register access methods.

  [ It is a prerequisite for fixing code duplication between rt2800usb.c
    and rt2800pci.c drivers. ]

- Fixes code duplication in rt2800usb.h and rt2800pci.h header files by
  using new shared rt2800.h header (almost 1800 LOC gone).

  Updated debugging scripts are located here:

      http://www.kernel.org/pub/linux/kernel/people/bart/rt2800/scripts/

  (they also work fine with older drivers)

- Adds rt2800 library containing common code for PCI and USB versions
  of rt2800 chipsets.  This removes over 1300 LOC and allows us to save
  a lot of maintenance burden in the future. 


It also fixes two real bugs (one in rt2800pci and one in rt2800usb) found
as a direct result of the code de-duplication:

- Fix rt2800usb driver to write the rfcsr read request into RF_CSR_CFG
  register and not BBP_CSR_CFG one in rt2800usb_rfcsr_read().

- Use the correct encryption key index for TX frames in rt2800pci (this is
  based on rt2800usb patch from Benoit PAPILLAULT already in Linus' tree,
  unfortunately the fix was not ported over to rt2800pci).

  [ There are also some minor code rt2x00 infrastructure fixes and improvements
     here and there... ]


All in all over 3100 LOC are gone and rt2800pci specific code is:

 1685 drivers/net/wireless/rt2x00/rt2800pci.c
  180 drivers/net/wireless/rt2x00/rt2800pci.h
 1865 total

instead of:

  3323 drivers/net/wireless/rt2x00/rt2800pci.c
  1960 drivers/net/wireless/rt2x00/rt2800pci.h
  5283 total

  (wireless-next and net-next trees)

which means decrease of the code needed for rt2800pci by 65% (this in turn
translates to 31% decrease for rt2800 specific code and 9% for whole rt2x00
infrastructure).

The rewrite was quite conservative and there is still a room for improvement
but it should serve as a good starting base for all future work on rt2800
drivers, and there is a lot to do there (both drivers are still practically
non-functional).

Comments and patches are welcomed.


The following changes since commit fa867e7355a1bdcd9bf7d55ebe9296f5b9c4028a:
  Juuso Oikarinen (1):
        wl1271: Generalize command response reading

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bart/misc.git rt2800

Bartlomiej Zolnierkiewicz (40):
      rt2800usb: fix rt2800usb_rfcsr_read()
      rt2800pci: fix crypto in TX frame
      rt2800pci: fix comment about register access
      rt2800pci: fix comment about IV/EIV fields
      rt2x00: fix rt2x00usb_register_read() comment
      rt2800usb: use rt2x00usb_register_multiwrite() to set key entries
      rt2800usb: add rt2800_register_[read,write]() wrappers
      rt2800pci: add rt2800_register_[read,write]() wrappers
      rt2800usb: add rt2800_register_multi[read,write]() wrappers
      rt2800pci: add rt2800_register_multi[read,write]() wrappers
      rt2800usb: add rt2800_regbusy_read() wrapper
      rt2800pci: add rt2800_regbusy_read() wrapper
      rt2800usb: add rt2800_bbp_[read,write]() wrappers
      rt2800pci: add rt2800_bbp_[read,write]() wrappers
      rt2800usb: add rt2800_rfcsr_[read,write]() wrappers
      rt2800pci: add rt2800_rfcsr_[read,write]() wrappers
      rt2800usb: add rt2800_rf_[read,write]() wrappers
      rt2800pci: add rt2800_rf_[read,write]() wrappers
      rt2800usb: add rt2800_mcu_request() wrapper
      rt2800pci: add rt2800_mcu_request() wrapper
      rt2x00: add driver private field to struct rt2x00_dev
      rt2800usb: convert to use struct rt2800_ops methods
      rt2800pci: convert to use struct rt2800_ops methods
      rt2x00: fix rt2x00usb_register_multiwrite() arguments
      rt2x00: fix rt2x00usb_regbusy_read() arguments
      rt2x00: fix rt2x00pci_register_multi[read,write]() arguments
      rt2800: add rt2800lib.h
      rt2800usb: fix comments in rt2800usb.h
      rt2800usb: add RXINFO_DESC_SIZE definition
      rt2800: fix duplication in header files
      rt2800: fix comments in rt2800.h
      rt2x00: add support for different chipset interfaces
      rt2800: prepare for rt2800lib addition
      rt2800: add rt2800lib (part one)
      rt2x00: remove needless ifdefs from rt2x00leds.h
      rt2800: add rt2800lib (part two)
      rt2x00: move REGISTER_BUSY_* definitions to rt2x00.h
      rt2800: add rt2800lib (part three)
      rt2800: add rt2800lib (part four)
      MAINTAINERS: add rt2800 entry

 MAINTAINERS                              |    7 +
 drivers/net/wireless/rt2x00/Kconfig      |    5 +
 drivers/net/wireless/rt2x00/Makefile     |    1 +
 drivers/net/wireless/rt2x00/rt2800.h     | 1816 ++++++++++++++++++++++++++++
 drivers/net/wireless/rt2x00/rt2800lib.c  | 1817 ++++++++++++++++++++++++++++
 drivers/net/wireless/rt2x00/rt2800lib.h  |  134 +++
 drivers/net/wireless/rt2x00/rt2800pci.c  | 1908 +++---------------------------
 drivers/net/wireless/rt2x00/rt2800pci.h  | 1780 ----------------------------
 drivers/net/wireless/rt2x00/rt2800usb.c  | 1828 ++---------------------------
 drivers/net/wireless/rt2x00/rt2800usb.h  | 1818 +----------------------------
 drivers/net/wireless/rt2x00/rt2x00.h     |   33 +
 drivers/net/wireless/rt2x00/rt2x00leds.h |    4 -
 drivers/net/wireless/rt2x00/rt2x00pci.h  |   24 +-
 drivers/net/wireless/rt2x00/rt2x00usb.c  |    2 +-
 drivers/net/wireless/rt2x00/rt2x00usb.h  |   17 +-
 15 files changed, 4036 insertions(+), 7158 deletions(-)
 create mode 100644 drivers/net/wireless/rt2x00/rt2800.h
 create mode 100644 drivers/net/wireless/rt2x00/rt2800lib.c
 create mode 100644 drivers/net/wireless/rt2x00/rt2800lib.h
