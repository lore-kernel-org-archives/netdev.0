From: Kalle Valo <kvalo@codeaurora.org>
Subject: pull-request: wireless-drivers-next 2016-07-13
Date: Wed, 13 Jul 2016 21:29:13 +0300
Message-ID: <87a8hlz91i.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

here's a pull request for net-next. This time there are few conflicts
due to the cfg80211 scan API changes, and one of them is easy to miss,
so please pay extra attention to them. Otherwise there's not nothing
really out of ordinary. Please note that I also pulled wireless-drivers
to wireless-drivers-next to reduce the amount of conflicts.

So about the conflicts, the obvious are notified by git:

CONFLICT (content): Merge conflict in drivers/net/wireless/marvell/mwif=
iex/cmdevt.c
CONFLICT (content): Merge conflict in drivers/net/wireless/intel/iwlwif=
i/mvm/scan.c

Basically the major change is that in iwlwifi del_timer() is changed to
cancel_delayed_work() and in mwifiex the code was refactored to use
mwifiex_cancel_scan(). But the tricky part comes here which is easy to
miss:

Auto-merging drivers/net/wireless/marvell/mwifiex/scan.c

You need to convert the scan code in mwifiex_cancel_scan():

        cfg80211_scan_done(priv->scan_request, 1);

to use the new API:

	struct cfg80211_scan_info info =3D {
		.aborted =3D true,
	};

        [...]

	cfg80211_scan_done(priv->scan_request, &info);

I have attached the output from git diff as an example how to resolve
this, hopefully that helps. Please let me know if there are any problem=
s
or if you want to handle these differently.

Kalle


The following changes since commit 742fb20fd4c75bd08733b0ea232c7e0fa67a=
6f87:

  net: ethernet: ti: cpdma: switch to use genalloc (2016-06-29 04:16:11=
 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-=
next.git tags/wireless-drivers-next-for-davem-2016-07-13

for you to fetch changes up to 25f700ef0653d7644ed273f8770230e734cae726=
:

  iwlwifi: add missing type declaration (2016-07-12 14:51:57 +0300)

----------------------------------------------------------------
wireless-drivers-next patches for 4.8

Major changes:

iwlwifi

* more work on the RX path for the 9000 device series
* some more dynamic queue allocation work
* SAR BIOS implementation
* some work on debugging capabilities
* added support for GCMP encryption
* data path rework in preparation for new HW
* some cleanup to remove transport dependency on mac80211
* support for MSIx in preparation for new HW
* lots of work in preparation for HW support (9000 and a000 series)

mwifiex

* implement get_tx_power and get_antenna cfg80211 operation callbacks

wl18xx

* add support for 64bit clock

rtl8xxxu

* aggregation support (optional for now)

Also wireless-drivers is merged to fix some conflicts.

----------------------------------------------------------------
Amitkumar Karwar (8):
      mwifiex: fix system hang problem after resume
      mwifiex: fix AP unable to start in VHT40 problem
      mwifiex: fix AP start problem for newly added interface
      mwifiex: code rearrangement in suspend handler
      mwifiex: clear scan_aborting flag
      mwifiex: fix NULL pointer dereference during suspend
      mwifiex: fix scan_block flag handling
      mwifiex: Change default firmware for PCIe8997 chipset

Andrei Otcheretianski (1):
      iwlwifi: mvm: Support CSA countdown offloading

Andy Shevchenko (1):
      rtl8xxxu: tuse %*ph to dump buffers

Arnd Bergmann (6):
      rtlwifi: use s8 instead of char
      wireless: airo: rename 'register' variable
      wireless: brcmsmac: fix old-style declaration
      wireless: ipw2200: fix old-style declaration
      iwlwifi: mvm: avoid harmless -Wmaybe-uninialized warning
      iwlwifi: add missing type declaration

Avraham Stern (1):
      iwlwifi: rename CAPA_P2P_STANDALONE_UAPSD to CAPA_P2P_SCM_UAPSD

Ayala Beker (2):
      iwlwifi: mvm: fix RX mpdu status enum
      iwlwifi: mvm: add support for GCMP encryption

Bhaktipriya Shridhar (1):
      libertas_tf: Remove create_workqueue

Brian Norris (1):
      mwifiex: mask PCIe interrupts before removal

Bruno Herrera (1):
      wlcore: sdio: Fix crash on wlcore_probe_of when failing to parse/=
map irq

Dan Carpenter (2):
      iwlwifi: mvm: remove an unused variable
      iwlwifi: mvm: silence uninitialized variable warning

Emmanuel Grumbach (7):
      iwlwifi: advertise maximal MPDU length when Rx MQ is supported
      iwlwifi: pcie: enable interrupts before releasing the NIC's CPU
      iwlwifi: mvm: cleanup the coex code
      iwlwifi: mvm: fix coex related comments
      iwlwifi: mvm: fix the channel inhibition table for Channel 14
      iwlwifi: mvm: unmap the paging memory before freeing it
      iwlwifi: pcie: fix a race in firmware loading flow

Ganapathi Bhat (1):
      mwifiex: Fix an issue spotted by KASAN

Golan Ben-Ami (2):
      iwlwifi: Reserve iwl_fw_error_dump_type enum
      iwlwifi: mvm: write the correct internal TXF index

Gregory Greenman (1):
      iwlwifi: mvm: rs: add rate scaling support for 160MHz channels

Guenter Roeck (1):
      iwlwifi: dvm: Remove unused array 'iwlagn_loose_lookup'

Guy Mishol (1):
      wlcore: reconfigure sta rates on authorization

Haim Dreyfuss (1):
      iwlwifi: Add a000 HW family support

Ido Yariv (1):
      iwlwifi: pcie: Enable MSI mode when using MSI interrupts

Javier Martinez Canillas (2):
      mwifiex: fix unconditional error return in .add_virtual_intf call=
back
      mwifiex: add a cfg80211 .get_tx_power operation callback

Jes Sorensen (15):
      rtl8xxxu: Add bit definitions for REG_USB_SPECIAL_OPTION
      rtl8xxxu: Add additional documentation for RX DMA registers
      rtl8xxxu: Reduce console noise when removing the kernel module
      rtl8xxxu: Set all ieee80211_rx_status values in parse_rx_desc()
      rtl8xxxu: Move skb delivery into parse_tx_desc() handler
      rtl8xxxu: Obtain ieee80211_rx_status within parse_rx_desc()
      rtl8xxxu: Correct rxdesc16 definition
      rtl8xxxu: Add support for aggregated RX packets on gen1 parts
      rtl8xxxu: Allocate larger RX skbs when aggregation is enabled
      rtl8xxxu: Adjust RX skb size to include space for phystats
      rtl8xxxu: Enable aggregation for rtl8723au
      rtl8xxxu: Enable aggregation for rtl8192cu/rtl8188cu/rtl8188ru
      rtl8xxxu: Make DMA aggregation optional by setting a module param=
eter
      rtl8xxxu: gen1: Set aggregation timeout (REG_RXDMA_AGG_PG_TH + 1)=
 as well
      rtl8xxxu: gen1: Add module parameters to adjust DMA aggregation p=
arameters

Joe Perches (2):
      rtlwifi: Create _rtl_dbg_trace function to reduce RT_TRACE code s=
ize
      rtlwifi: Add missing newlines to RT_TRACE calls

Johannes Berg (8):
      iwlwifi: mvm: fix comment indentation
      iwlwifi: mvm: handle FRAME_RELEASE in MQ code
      iwlwifi: remove useless enum values
      iwlwifi: change fw.mvm_fw to fw.type
      iwlwifi: remove iwl_ht_params.smps_mode
      iwlwifi: store cipher scheme independent of mac80211
      iwlwifi: tracing: decouple from mac80211
      iwlwifi: decouple PCIe transport from mac80211

Kalle Valo (3):
      Merge tag 'iwlwifi-next-for-kalle-2016-07-01' of git://git.kernel=
=2Eorg/.../iwlwifi/iwlwifi-next
      Merge tag 'iwlwifi-next-for-kalle-2016-07-06' of git://git.kernel=
=2Eorg/.../iwlwifi/iwlwifi-next
      Merge git://git.kernel.org/.../kvalo/wireless-drivers.git

Larry Finger (16):
      rtlwifi: Remove unused parameter from rtl_ps_set_rf_state()
      rtlwifi: rtl8188ee: Fix potential race condition
      rtlwifi: rtl8192ee: Fix potential race condition
      rtlwifi: rtl8723be: Fix potential race condition
      rtlwifi: rtl8723ae: Fix potential race condition
      rtlwifi: rtl8821ae: Fix potential race condition
      rtlwifi: Create common routine to get hardware info
      rtlwifi: rtl8192ce: Convert driver to use common hardware info ro=
utine
      rtlwifi: rtl8192cu: Convert driver to use common hardware info ro=
utine
      rtlwifi: rtl8188ee: Convert driver to use common hardware info ro=
utine
      rtlwifi: rtl8192ee: Convert driver to use common hardware info ro=
utine
      rtlwifi: rtl8723ae: Convert driver to use common hardware info ro=
utine
      rtlwifi: rtl8723be: Convert driver to use common hardware info ro=
utine
      rtlwifi: rtl8821ae: Convert driver to use common hardware info ro=
utine
      rtlwifi: rtl8192de: Convert driver to use common hardware info ro=
utine
      rtlwifi: rtl8723ae: Clean up the hardware info routine

Liad Kaufman (8):
      iwlwifi: mvm: free dqa queues on STA removal also in non-bss
      iwlwifi: mvm: support dqa queue inactivation upon timeout
      iwlwifi: mvm: support dqa queue sharing
      iwlwifi: mvm: set sta_id in SCD_QUEUE_CONFIG cmd
      iwlwifi: mvm: update aux queue in dqa mode
      iwlwifi: mvm: support dqa-enable hcmd
      iwlwifi: mvm: support tdls in dqa mode
      iwlwifi: mvm: support dqa-mode scd queue redirection

Luca Coelho (4):
      iwlwifi: mvm: change scan timeout to a delayed work
      iwlwifi: mvm: remove unnecessary device conversion when reading t=
he MCC
      iwlwifi: mvm: read SAR BIOS table from ACPI
      iwlwifi: mvm: support v4 of the TX power command

Luis de Bethencourt (1):
      rtl8xxxu: remove unneeded assignments

Machani, Yaniv (1):
      wlcore: time sync : add support for 64 bit clock

Masanari Iida (1):
      rtlwifi: Fix typo in printk

Matti Gottlieb (1):
      iwlwifi: mvm: Do not open aggregations for null data packets

Oren Givon (3):
      iwlwifi: add new 8260 PCI IDs
      iwlwifi: add new 8265
      iwlwifi: mvm: fix txq aggregation bug

Pavel Andrianov (1):
      libertas: Add spinlock to avoid race condition

Prasun Maiti (1):
      mwifiex: Fix endianness for event TLV type TLV_BTCOEX_WL_SCANTIME

Rafa=C5=82 Mi=C5=82ecki (7):
      brcmfmac: slightly simplify building interface combinations
      brcmfmac: fix lockup when removing P2P interface after event time=
out
      brcmfmac: use const char * for interface name in brcmf_add_if
      brcmfmac: include also core.h header in cfg80211.h
      brcmfmac: add missing break when deleting P2P_DEVICE
      brcmfmac: delete interface directly in code that sent fw request
      brcmfmac: support removing AP interfaces with "interface_remove"

Sara Sharon (24):
      iwlwifi: mvm: do not trust NSSN for amsdu sub-frames
      iwlwifi: mvm: remove RX_PHY support for 9000 device
      iwlwifi: mvm: update mpdu metadata API
      iwlwifi: pcie: workaround HW shadow registers bug
      iwlwifi: pcie: set RB chunk size per bus
      iwlwifi: pcie: allow more than one frame in RB for 9000 devices
      iwlwifi: pcie: make sure packet arrived to destined queue
      iwlwifi: pcie: unify restock calls on init
      iwlwifi: mvm: fix possible division by zero
      iwlwifi: pcie: poll RFH for RX DMA stop
      iwlwifi: add dump of RFH
      iwlwifi: mvm: support new statistics notification
      iwlwifi: mvm: checksum IPv6 fragmented packet
      iwlwifi: pcie: fix access to scratch buffer
      iwlwifi: pcie: don't use vid 0
      iwlwifi: mvm: add RX aggregation prints
      iwlwifi: mvm: free RX reorder buffer on restart
      iwlwifi: pcie: track rxb status
      iwlwifi: pcie: generalize and increase the size of scratchbuf
      iwlwifi: centralize 64 bit HW registers write
      iwlwifi: pcie: initialize a000 device's TFD table
      iwlwifi: pcie: load FW chunk for a000 devices
      iwlwifi: pcie: centralize SCD status logging
      iwlwifi: move iwl_drv to be shared across transports

Shengzhen Li (3):
      mwifiex: add get_antenna support for cfg80211
      mwifiex: disable MSIx interrupt for 8997 chipset
      mwifiex: fix interrupt processing corner case in MSI mode

Xinming Hu (2):
      mwifiex: factor out mwifiex_cancel_scan
      mwifiex: cancel pending scan during disconnect

striebit (1):
      iwlmvm: mvm: set correct state in smart-fifo configuration

 drivers/net/wireless/ath/ath10k/core.c             |    2 +-
 drivers/net/wireless/ath/ath10k/htt_rx.c           |    1 -
 drivers/net/wireless/ath/ath10k/mac.c              |    2 +-
 drivers/net/wireless/ath/ath9k/reg.h               |    8 +-
 .../broadcom/brcm80211/brcmfmac/cfg80211.c         |   76 ++-
 .../broadcom/brcm80211/brcmfmac/cfg80211.h         |    1 +
 .../wireless/broadcom/brcm80211/brcmfmac/core.c    |   31 +-
 .../wireless/broadcom/brcm80211/brcmfmac/core.h    |    4 +-
 .../wireless/broadcom/brcm80211/brcmfmac/fweh.c    |   10 +-
 .../net/wireless/broadcom/brcm80211/brcmfmac/p2p.c |    7 +-
 .../wireless/broadcom/brcm80211/brcmsmac/main.c    |    4 +-
 drivers/net/wireless/cisco/airo.c                  |    4 +-
 drivers/net/wireless/intel/ipw2x00/ipw2200.c       |    2 +-
 drivers/net/wireless/intel/iwlwifi/Makefile        |    2 +-
 drivers/net/wireless/intel/iwlwifi/dvm/lib.c       |   17 -
 drivers/net/wireless/intel/iwlwifi/dvm/main.c      |    3 +
 drivers/net/wireless/intel/iwlwifi/dvm/rxon.c      |    5 -
 drivers/net/wireless/intel/iwlwifi/iwl-9000.c      |    1 +
 drivers/net/wireless/intel/iwlwifi/iwl-a000.c      |  131 +++++
 drivers/net/wireless/intel/iwlwifi/iwl-config.h    |   13 +-
 drivers/net/wireless/intel/iwlwifi/iwl-csr.h       |    6 +-
 drivers/net/wireless/intel/iwlwifi/iwl-debug.h     |    1 +
 .../net/wireless/intel/iwlwifi/iwl-devtrace-io.h   |   35 ++
 drivers/net/wireless/intel/iwlwifi/iwl-devtrace.h  |   25 +-
 drivers/net/wireless/intel/iwlwifi/iwl-drv.c       |   49 +-
 .../net/wireless/intel/iwlwifi/iwl-eeprom-parse.c  |    4 +-
 .../net/wireless/intel/iwlwifi/iwl-eeprom-parse.h  |    1 +
 drivers/net/wireless/intel/iwlwifi/iwl-fh.h        |   99 +++-
 .../net/wireless/intel/iwlwifi/iwl-fw-error-dump.h |    4 +
 drivers/net/wireless/intel/iwlwifi/iwl-fw-file.h   |   13 +-
 drivers/net/wireless/intel/iwlwifi/iwl-fw.h        |   17 +-
 drivers/net/wireless/intel/iwlwifi/iwl-io.c        |  142 ++++-
 drivers/net/wireless/intel/iwlwifi/iwl-io.h        |    3 +
 drivers/net/wireless/intel/iwlwifi/iwl-modparams.h |   10 +-
 drivers/net/wireless/intel/iwlwifi/iwl-nvm-parse.c |    7 +
 drivers/net/wireless/intel/iwlwifi/iwl-prph.h      |    1 +
 drivers/net/wireless/intel/iwlwifi/iwl-trans.h     |   33 +-
 drivers/net/wireless/intel/iwlwifi/mvm/coex.c      |    6 +-
 drivers/net/wireless/intel/iwlwifi/mvm/debugfs.c   |    2 +
 .../net/wireless/intel/iwlwifi/mvm/fw-api-coex.h   |  222 --------
 .../net/wireless/intel/iwlwifi/mvm/fw-api-mac.h    |    3 +
 .../net/wireless/intel/iwlwifi/mvm/fw-api-power.h  |   22 +-
 drivers/net/wireless/intel/iwlwifi/mvm/fw-api-rx.h |   56 +-
 .../net/wireless/intel/iwlwifi/mvm/fw-api-sta.h    |    8 +-
 .../net/wireless/intel/iwlwifi/mvm/fw-api-stats.h  |   24 +-
 drivers/net/wireless/intel/iwlwifi/mvm/fw-api-tx.h |   58 +-
 drivers/net/wireless/intel/iwlwifi/mvm/fw-api.h    |   26 +-
 drivers/net/wireless/intel/iwlwifi/mvm/fw-dbg.c    |    3 +-
 drivers/net/wireless/intel/iwlwifi/mvm/fw.c        |  217 +++++++-
 drivers/net/wireless/intel/iwlwifi/mvm/mac-ctxt.c  |  108 +++-
 drivers/net/wireless/intel/iwlwifi/mvm/mac80211.c  |   80 ++-
 drivers/net/wireless/intel/iwlwifi/mvm/mvm.h       |   47 +-
 drivers/net/wireless/intel/iwlwifi/mvm/nvm.c       |   45 +-
 drivers/net/wireless/intel/iwlwifi/mvm/ops.c       |   61 ++-
 drivers/net/wireless/intel/iwlwifi/mvm/power.c     |    2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/rs.c        |   94 +++-
 drivers/net/wireless/intel/iwlwifi/mvm/rs.h        |    3 +-
 drivers/net/wireless/intel/iwlwifi/mvm/rx.c        |   44 +-
 drivers/net/wireless/intel/iwlwifi/mvm/rxmq.c      |  107 ++--
 drivers/net/wireless/intel/iwlwifi/mvm/scan.c      |   18 +-
 drivers/net/wireless/intel/iwlwifi/mvm/sf.c        |    2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/sta.c       |  555 ++++++++++++=
++++++--
 drivers/net/wireless/intel/iwlwifi/mvm/sta.h       |    8 +
 drivers/net/wireless/intel/iwlwifi/mvm/tx.c        |  106 ++--
 drivers/net/wireless/intel/iwlwifi/mvm/utils.c     |  186 ++++++-
 drivers/net/wireless/intel/iwlwifi/pcie/drv.c      |   26 +-
 drivers/net/wireless/intel/iwlwifi/pcie/internal.h |   70 ++-
 drivers/net/wireless/intel/iwlwifi/pcie/rx.c       |  145 +++--
 drivers/net/wireless/intel/iwlwifi/pcie/trans.c    |  167 +++---
 drivers/net/wireless/intel/iwlwifi/pcie/tx.c       |  188 ++++---
 drivers/net/wireless/marvell/libertas/cmdresp.c    |    4 +
 drivers/net/wireless/marvell/libertas_tf/main.c    |    2 +-
 drivers/net/wireless/marvell/mwifiex/cfg80211.c    |   91 +++-
 drivers/net/wireless/marvell/mwifiex/cmdevt.c      |   40 +-
 drivers/net/wireless/marvell/mwifiex/fw.h          |    7 +-
 drivers/net/wireless/marvell/mwifiex/init.c        |    4 +-
 drivers/net/wireless/marvell/mwifiex/ioctl.h       |    2 +
 drivers/net/wireless/marvell/mwifiex/join.c        |   12 +
 drivers/net/wireless/marvell/mwifiex/main.h        |    3 +
 drivers/net/wireless/marvell/mwifiex/pcie.c        |   68 ++-
 drivers/net/wireless/marvell/mwifiex/pcie.h        |    6 +-
 drivers/net/wireless/marvell/mwifiex/scan.c        |   32 +-
 drivers/net/wireless/marvell/mwifiex/sta_cmd.c     |   50 +-
 drivers/net/wireless/marvell/mwifiex/sta_cmdresp.c |   10 +-
 drivers/net/wireless/marvell/mwifiex/sta_event.c   |    6 +-
 drivers/net/wireless/marvell/mwifiex/sta_ioctl.c   |    4 +
 drivers/net/wireless/marvell/mwifiex/uap_cmd.c     |   30 +-
 drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu.h   |   18 +-
 .../net/wireless/realtek/rtl8xxxu/rtl8xxxu_8192c.c |   11 +-
 .../net/wireless/realtek/rtl8xxxu/rtl8xxxu_8192e.c |   13 +-
 .../net/wireless/realtek/rtl8xxxu/rtl8xxxu_8723a.c |    2 +
 .../net/wireless/realtek/rtl8xxxu/rtl8xxxu_8723b.c |    9 +-
 .../net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c  |  315 +++++++----
 .../net/wireless/realtek/rtl8xxxu/rtl8xxxu_regs.h  |   14 +-
 .../realtek/rtlwifi/btcoexist/halbtcoutsrc.c       |    2 +-
 .../realtek/rtlwifi/btcoexist/halbtcoutsrc.h       |    4 +-
 drivers/net/wireless/realtek/rtlwifi/core.c        |    2 +-
 drivers/net/wireless/realtek/rtlwifi/debug.c       |   25 +
 drivers/net/wireless/realtek/rtlwifi/debug.h       |   17 +-
 drivers/net/wireless/realtek/rtlwifi/efuse.c       |   78 +++
 drivers/net/wireless/realtek/rtlwifi/efuse.h       |    2 +
 drivers/net/wireless/realtek/rtlwifi/ps.c          |   25 +-
 drivers/net/wireless/realtek/rtlwifi/ps.h          |    3 -
 drivers/net/wireless/realtek/rtlwifi/rc.c          |    2 +-
 .../net/wireless/realtek/rtlwifi/rtl8188ee/dm.c    |    6 +-
 .../net/wireless/realtek/rtlwifi/rtl8188ee/hw.c    |   76 +--
 .../net/wireless/realtek/rtlwifi/rtl8188ee/phy.c   |    6 +-
 .../net/wireless/realtek/rtlwifi/rtl8188ee/rf.c    |    2 +-
 .../net/wireless/realtek/rtlwifi/rtl8188ee/trx.c   |    6 +-
 .../net/wireless/realtek/rtlwifi/rtl8188ee/trx.h   |    4 +-
 .../wireless/realtek/rtlwifi/rtl8192c/dm_common.h  |    2 +-
 .../wireless/realtek/rtlwifi/rtl8192c/phy_common.c |   10 +-
 .../wireless/realtek/rtlwifi/rtl8192c/phy_common.h |    2 +-
 .../net/wireless/realtek/rtlwifi/rtl8192ce/hw.c    |   83 +--
 .../net/wireless/realtek/rtlwifi/rtl8192ce/phy.h   |    2 +-
 .../net/wireless/realtek/rtlwifi/rtl8192ce/trx.c   |   10 +-
 .../net/wireless/realtek/rtlwifi/rtl8192ce/trx.h   |    4 +-
 .../net/wireless/realtek/rtlwifi/rtl8192cu/hw.c    |   61 +--
 .../net/wireless/realtek/rtlwifi/rtl8192cu/mac.c   |    6 +-
 .../net/wireless/realtek/rtlwifi/rtl8192cu/mac.h   |    4 +-
 .../net/wireless/realtek/rtlwifi/rtl8192cu/rf.c    |    2 +-
 .../net/wireless/realtek/rtlwifi/rtl8192de/hw.c    |   77 +--
 .../net/wireless/realtek/rtlwifi/rtl8192de/phy.c   |    2 +-
 .../net/wireless/realtek/rtlwifi/rtl8192de/phy.h   |    2 +-
 .../net/wireless/realtek/rtlwifi/rtl8192de/rf.c    |    2 +-
 .../net/wireless/realtek/rtlwifi/rtl8192de/trx.c   |   10 +-
 .../net/wireless/realtek/rtlwifi/rtl8192de/trx.h   |    4 +-
 .../net/wireless/realtek/rtlwifi/rtl8192ee/dm.c    |    6 +-
 .../net/wireless/realtek/rtlwifi/rtl8192ee/hw.c    |   73 +--
 .../net/wireless/realtek/rtlwifi/rtl8192ee/phy.c   |   16 +-
 .../net/wireless/realtek/rtlwifi/rtl8192ee/phy.h   |    2 +-
 .../net/wireless/realtek/rtlwifi/rtl8192ee/rf.c    |    2 +-
 .../net/wireless/realtek/rtlwifi/rtl8192ee/trx.c   |    6 +-
 .../net/wireless/realtek/rtlwifi/rtl8192ee/trx.h   |    4 +-
 .../net/wireless/realtek/rtlwifi/rtl8192se/hw.c    |    2 +-
 .../net/wireless/realtek/rtlwifi/rtl8192se/rf.c    |    2 +-
 .../net/wireless/realtek/rtlwifi/rtl8192se/trx.c   |    4 +-
 .../net/wireless/realtek/rtlwifi/rtl8723ae/dm.c    |    6 +-
 .../wireless/realtek/rtlwifi/rtl8723ae/hal_btc.c   |    4 +-
 .../net/wireless/realtek/rtlwifi/rtl8723ae/hw.c    |  307 +++++------
 .../net/wireless/realtek/rtlwifi/rtl8723ae/phy.c   |    6 +-
 .../net/wireless/realtek/rtlwifi/rtl8723ae/rf.c    |    2 +-
 .../net/wireless/realtek/rtlwifi/rtl8723ae/trx.c   |    4 +-
 .../net/wireless/realtek/rtlwifi/rtl8723ae/trx.h   |    4 +-
 .../net/wireless/realtek/rtlwifi/rtl8723be/dm.c    |    6 +-
 .../net/wireless/realtek/rtlwifi/rtl8723be/hw.c    |   76 +--
 .../net/wireless/realtek/rtlwifi/rtl8723be/phy.c   |   10 +-
 .../net/wireless/realtek/rtlwifi/rtl8723be/rf.c    |    2 +-
 .../net/wireless/realtek/rtlwifi/rtl8723be/trx.c   |    6 +-
 .../net/wireless/realtek/rtlwifi/rtl8723be/trx.h   |    8 +-
 .../net/wireless/realtek/rtlwifi/rtl8821ae/dm.c    |   12 +-
 .../net/wireless/realtek/rtlwifi/rtl8821ae/hw.c    |   86 +--
 .../net/wireless/realtek/rtlwifi/rtl8821ae/phy.c   |   62 +--
 .../net/wireless/realtek/rtlwifi/rtl8821ae/phy.h   |    2 +-
 .../net/wireless/realtek/rtlwifi/rtl8821ae/rf.c    |    2 +-
 .../net/wireless/realtek/rtlwifi/rtl8821ae/trx.c   |   16 +-
 .../net/wireless/realtek/rtlwifi/rtl8821ae/trx.h   |   10 +-
 drivers/net/wireless/realtek/rtlwifi/stats.c       |    6 +-
 drivers/net/wireless/realtek/rtlwifi/stats.h       |    4 +-
 drivers/net/wireless/realtek/rtlwifi/wifi.h        |   68 +--
 drivers/net/wireless/ti/wl18xx/event.c             |   26 +-
 drivers/net/wireless/ti/wl18xx/event.h             |   19 +-
 drivers/net/wireless/ti/wlcore/cmd.c               |    7 +
 drivers/net/wireless/ti/wlcore/main.c              |    5 +
 drivers/net/wireless/ti/wlcore/sdio.c              |    1 -
 165 files changed, 3695 insertions(+), 1968 deletions(-)
 create mode 100644 drivers/net/wireless/intel/iwlwifi/iwl-a000.c

The example resolution from 'git diff':

diff --cc drivers/net/wireless/intel/iwlwifi/mvm/scan.c
index 1cac10c5d818,fb25d9e41912..000000000000
--- a/drivers/net/wireless/intel/iwlwifi/mvm/scan.c
+++ b/drivers/net/wireless/intel/iwlwifi/mvm/scan.c
@@@ -400,9 -396,10 +400,9 @@@ void iwl_mvm_rx_lmac_scan_complete_noti
  			       iwl_mvm_ebs_status_str(scan_notif->ebs_status));
 =20
  		mvm->scan_status &=3D ~IWL_MVM_SCAN_REGULAR;
 -		ieee80211_scan_completed(mvm->hw,
 -				scan_notif->status =3D=3D IWL_SCAN_OFFLOAD_ABORTED);
 +		ieee80211_scan_completed(mvm->hw, &info);
  		iwl_mvm_unref(mvm, IWL_MVM_REF_SCAN);
- 		del_timer(&mvm->scan_timer);
+ 		cancel_delayed_work(&mvm->scan_timeout_dwork);
  	} else {
  		IWL_ERR(mvm,
  			"got scan complete notification but no scan is running\n");
@@@ -1433,13 -1432,9 +1435,13 @@@ void iwl_mvm_rx_umac_scan_complete_no=
ti
 =20
  	/* if the scan is already stopping, we don't need to notify mac80211=
 */
  	if (mvm->scan_uid_status[uid] =3D=3D IWL_MVM_SCAN_REGULAR) {
 -		ieee80211_scan_completed(mvm->hw, aborted);
 +		struct cfg80211_scan_info info =3D {
 +			.aborted =3D aborted,
 +		};
 +
 +		ieee80211_scan_completed(mvm->hw, &info);
  		iwl_mvm_unref(mvm, IWL_MVM_REF_SCAN);
- 		del_timer(&mvm->scan_timer);
+ 		cancel_delayed_work(&mvm->scan_timeout_dwork);
  	} else if (mvm->scan_uid_status[uid] =3D=3D IWL_MVM_SCAN_SCHED) {
  		ieee80211_sched_scan_stopped(mvm->hw);
  		mvm->sched_scan_pass_all =3D SCHED_SCAN_PASS_ALL_DISABLED;
@@@ -1644,14 -1630,9 +1646,14 @@@ out
  		 * to release the scan reference here.
  		 */
  		iwl_mvm_unref(mvm, IWL_MVM_REF_SCAN);
- 		del_timer(&mvm->scan_timer);
+ 		cancel_delayed_work(&mvm->scan_timeout_dwork);
 -		if (notify)
 -			ieee80211_scan_completed(mvm->hw, true);
 +		if (notify) {
 +			struct cfg80211_scan_info info =3D {
 +				.aborted =3D true,
 +			};
 +
 +			ieee80211_scan_completed(mvm->hw, &info);
 +		}
  	} else if (notify) {
  		ieee80211_sched_scan_stopped(mvm->hw);
  		mvm->sched_scan_pass_all =3D SCHED_SCAN_PASS_ALL_DISABLED;
diff --cc drivers/net/wireless/marvell/mwifiex/cmdevt.c
index e7a21443647e,c29f26d8baf2..000000000000
--- a/drivers/net/wireless/marvell/mwifiex/cmdevt.c
+++ b/drivers/net/wireless/marvell/mwifiex/cmdevt.c
diff --git a/drivers/net/wireless/marvell/mwifiex/scan.c b/drivers/net/=
wireless/marvell/mwifiex/scan.c
index a2c84171fbc3..21ec84794d0c 100644
--- a/drivers/net/wireless/marvell/mwifiex/scan.c
+++ b/drivers/net/wireless/marvell/mwifiex/scan.c
@@ -2029,9 +2029,13 @@ void mwifiex_cancel_scan(struct mwifiex_adapter =
*adapter)
 			if (!priv)
 				continue;
 			if (priv->scan_request) {
+				struct cfg80211_scan_info info =3D {
+					.aborted =3D true,
+				};
+
 				mwifiex_dbg(adapter, INFO,
 					    "info: aborting scan\n");
-				cfg80211_scan_done(priv->scan_request, 1);
+				cfg80211_scan_done(priv->scan_request, &info);
 				priv->scan_request =3D NULL;
 				priv->scan_aborting =3D false;
 			}
