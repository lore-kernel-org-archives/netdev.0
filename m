From: Robert Dolca <robert.dolca@intel.com>
Subject: [PATCH v4 00/10] Add Intel FieldsPeak NFC solution driver
Date: Thu, 22 Oct 2015 12:11:32 +0300
Message-ID: <1445505102-16639-1-git-send-email-robert.dolca@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org,
	Christophe Ricard <christophe.ricard@gmail.com>,
	Robert Dolca <robert.dolca@intel.com>
To: linux-nfc@lists.01.org,
	Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	Samuel Ortiz <sameo@linux.intel.com>,
	Robert Dolca <robert.dolca@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patches add support for Intel's FieldsPeak NFC solution.

=46ields Peak complies with the ISO/IEC 14443A/B, 15693, 18092,
and JIS X 6319-4. It is an NCI based controller.

RF Protocols supported:
 - NFC Forum Type 1 Tags (Jewel, Topaz)
 - NFC Forum Type 2 Tags (Mifare UL)
 - NFC Forum Type 3 Tags (FeliCa)
 - NFC Forum Type 4A (ISO/IEC 14443 A-4 106kbps to 848kbps)
 - NFC Forum Type 4B (ISO/IEC 14443 B-4 106kbps to 848kbps)
 - NFCIP in passive and active modes (ISO/IEC 18092 106kbps to 424kbps)
 - B=E2=80=99 (based on ISO/IEC 14443 B-2)
 - iCLASS (based on ISO/IEC 15693-2)
 - Vicinity cards (ISO/IEC 15693-3)
 - Kovio tags (NFC Forum Type 2)

The device can be enumerated using ACPI using the id INT339A.
The 1st GPIO is the IRQ and the 2nd is the RESET pin.


Changes since v3:
 - replace u32 with le32 where appropriate
 - make nci_prop_ops struct instances static
 - simplify return for fdp_nci_setup and fdp_nci_post_setup
 - change return type from u8 to int for nci_conn_max_data_pkt_payload_=
size
 - set FDP_NCI_I2C_MAX_PAYLOAD to 261 (255 + NCI header (3) + lrc(2) + =
size byte)
 - add sleep during patching to make sure that the NFCC processed the l=
ast data packet
 - patch droped "nfc: nci: Use a separate mutex for nci open and close"
 - patch droped "nfc: nci: Add a parameter to get the new connection id=
"
 - add patch "nfc: nci: fix possible crash in nci_core_conn_create"
 - add patch "nfc: nci: add nci_get_conn_info_by_id function"
 - add patch "nfc: nci: rename nci_prop_ops to nci_driver_ops"
 - edit "ecee665 nfc: nci: Allow the driver to set handler for core nci=
 ops" to
   add wrappers for core ops and prop ops in order to simplify the code
 - removed "atomic_t intercept;" from fdp_nci_info struct
 - make functions inline: fdp_nci_get_versions, fdp_nci_patch_cmd, fdp_=
nci_set_production_data
 - moved otp and ram patching to separate functions that are called fro=
m fdp_nci_post_setup

Changes since v2:
 - rename reset gpio to power gpio because it really is a power switch
 - use named gpio for power with fallback to the indexed gpio 0
 - use device managed gpio for power
 - rely on the i2c subsystem to fill in the irq field of the i2c_client=
 struct
 - remove the internal driver state (the nfc subsystem takes care of wh=
at
   we need)
 - removed the power status field (not needed any more)
 - change i2c / device tree id name s/INT339A/int339a
 - make clock type and clock frequency configurable with device propert=
ies
   (use defauls if not set)
 - firmware vendor specific commands configurable with device propertie=
s
   (default none)
 - other small fixes

Changes since v1:
 - removed .owner
 - made local functions static
 - droped "NFC: NCI: Adds NCI init and reset API for drivers"
 - replaced nfc_info with dev_dbg
 - make controller setup possible without OTP patch
 - retoved the commint that was adding nci_init/reset and using
   the newly added functions nci_core_init/reset
 - fixed typo and use full controller name instead of abreviation in Kc=
onfig
 - added more info about the controller in the commit message
 - moved NCI_OP_CORE_RESET_NTF, NCI_OP_CORE_GET_CONFIG_RSP and
   NCI_OP_CORE_GET_CONFIG_CMD into the core header files
 - added MODULE_DEVICE_TABLE for ACPI
 - defined FDP_FW_UPDATE_DEST 0xC2
 - release the firmware buffers
 - settings the vendor configuration and clock on post setup
 - platform data enumerations removed (ACPI enumeration left)
 - packet reception intercept logic remove
 - nci: removed nci_send_cmd symbol export
 - nci: removed nci_request_driver and nci_req_complete_driver
 - removed mutex from driver (no need for it)
 - nci: check the setup return code before callig post_setup
 - nci: add function to allow sending core commands from driver
 - nci: Use a separate mutex for nci open and close
 - nci: mutex for: Adds a way to get the new connection ID
 - nci: Allow the driver to set handler for core nci ops


Robert Dolca (10):
  nfc: nci: Export nci data send API
  nfc: nci: Add function to get max packet size for conn
  nfc: nci: Introduce new core opcodes
  nfc: nci: Do not call post_setup when setup fails
  nfc: nci: Introduce nci_core_cmd
  nfc: nci: Allow the driver to set handler for core nci ops
  nfc: nci: rename nci_prop_ops to nci_driver_ops
  nfc: nci: fix possible crash in nci_core_conn_create
  nfc: nci: add nci_get_conn_info_by_id function
  nfc: Add Intel Fields Peak NFC solution driver

 drivers/nfc/Kconfig        |   1 +
 drivers/nfc/Makefile       |   1 +
 drivers/nfc/fdp/Kconfig    |  23 ++
 drivers/nfc/fdp/Makefile   |   9 +
 drivers/nfc/fdp/fdp.c      | 817 +++++++++++++++++++++++++++++++++++++=
++++++++
 drivers/nfc/fdp/fdp.h      |  38 +++
 drivers/nfc/fdp/i2c.c      | 388 +++++++++++++++++++++
 drivers/nfc/s3fwrn5/nci.c  |   4 +-
 drivers/nfc/st-nci/core.c  |   2 +-
 include/net/nfc/nci.h      |   7 +
 include/net/nfc/nci_core.h |  18 +-
 net/nfc/nci/core.c         | 120 +++++--
 net/nfc/nci/data.c         |  13 +
 net/nfc/nci/ntf.c          |   3 +-
 net/nfc/nci/rsp.c          |   1 +
 15 files changed, 1409 insertions(+), 36 deletions(-)
 create mode 100644 drivers/nfc/fdp/Kconfig
 create mode 100644 drivers/nfc/fdp/Makefile
 create mode 100644 drivers/nfc/fdp/fdp.c
 create mode 100644 drivers/nfc/fdp/fdp.h
 create mode 100644 drivers/nfc/fdp/i2c.c

--

1.9.1
