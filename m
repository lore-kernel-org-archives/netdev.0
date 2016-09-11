From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 00/26] constify local structures
Date: Sun, 11 Sep 2016 15:05:42 +0200
Message-ID: <1473599168-30561-1-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: alsa-devel@alsa-project.org, Mustafa Ismail <mustafa.ismail@intel.com>,
 Tatyana Nikolova <tatyana.e.nikolova@intel.com>,
 kernel-janitors@vger.kernel.org, linux-fbdev@vger.kernel.org,
 platform-driver-x86@vger.kernel.org, devel@driverdev.osuosl.org,
 linux-scsi@vger.kernel.org, linux-rdma@vger.kernel.org,
 Jason Gunthorpe <jgunthorpe@obsidianresearch.com>, linux-acpi@vger.kernel.org,
 tpmdd-devel@lists.sourceforge.net, linux-media@vger.kernel.org,
 linux-pm@vger.kernel.org, linux-can@vger.kernel.org,
 Shiraz Saleem <shiraz.saleem@intel.com>,
 Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, netdev@vger.kernel.org,
 Chien Tin Tung <chien.tin.tung@intel.com>, linux-wireless@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-spi@vger.kernel.org,
 linux-usb@vger.kernel.org, joe@perches.com
To: linux-renesas-soc@vger.kernel.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

Constify local structures.

The semantic patch that makes this change is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
// The first rule ignores some cases that posed problems
@r disable optional_qualifier@
identifier s != {peri_clk_data,threshold_attr,tracer_flags,tracer};
identifier i != {s5k5baf_cis_rect,smtcfb_fix};
position p;
@@
static struct s i@p = { ... };

@lstruct@
identifier r.s;
@@
struct s { ... };

@used depends on lstruct@
identifier r.i;
@@
i

@bad1@
expression e;
identifier r.i;
assignment operator a;
@@
 (<+...i...+>) a e

@bad2@
identifier r.i;
@@
 &(<+...i...+>)

@bad3@
identifier r.i;
declarer d;
@@
 d(...,<+...i...+>,...);

@bad4@
identifier r.i;
type T;
T[] e;
identifier f;
position p;
@@

f@p(...,
(
  (<+...i...+>)
&
  e
)
,...)

@bad4a@
identifier r.i;
type T;
T *e;
identifier f;
position p;
@@

f@p(...,
(
  (<+...i...+>)
&
  e
)
,...)

@ok5@
expression *e;
identifier r.i;
position p;
@@
e =@p i

@bad5@
expression *e;
identifier r.i;
position p != ok5.p;
@@
e =@p (<+...i...+>)

@rr depends on used && !bad1 && !bad2 && !bad3 && !bad4 && !bad4a && !bad5@
identifier s,r.i;
position r.p;
@@

static
+const
 struct s i@p = { ... };

@depends on used && !bad1 && !bad2 && !bad3 && !bad4 && !bad4a && !bad5
 disable optional_qualifier@
identifier rr.s,r.i;
@@

static
+const
 struct s i;
// </smpl>

---

 drivers/acpi/acpi_apd.c                              |    8 +++---
 drivers/char/tpm/tpm-interface.c                     |   10 ++++----
 drivers/char/tpm/tpm-sysfs.c                         |    2 -
 drivers/cpufreq/intel_pstate.c                       |    8 +++---
 drivers/infiniband/hw/i40iw/i40iw_uk.c               |    6 ++---
 drivers/media/i2c/tvp514x.c                          |    2 -
 drivers/media/pci/ddbridge/ddbridge-core.c           |   18 +++++++--------
 drivers/media/pci/ngene/ngene-cards.c                |   14 ++++++------
 drivers/media/pci/smipcie/smipcie-main.c             |    8 +++---
 drivers/misc/sgi-xp/xpc_uv.c                         |    2 -
 drivers/net/arcnet/com20020-pci.c                    |   10 ++++----
 drivers/net/can/c_can/c_can_pci.c                    |    4 +--
 drivers/net/can/sja1000/plx_pci.c                    |   20 ++++++++---------
 drivers/net/ethernet/mellanox/mlx4/main.c            |    4 +--
 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c |    2 -
 drivers/net/ethernet/renesas/sh_eth.c                |   14 ++++++------
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c     |    2 -
 drivers/net/wireless/ath/dfs_pattern_detector.c      |    2 -
 drivers/net/wireless/intel/iwlegacy/3945.c           |    4 +--
 drivers/net/wireless/realtek/rtlwifi/rtl8188ee/sw.c  |    2 -
 drivers/net/wireless/realtek/rtlwifi/rtl8192ce/sw.c  |    2 -
 drivers/net/wireless/realtek/rtlwifi/rtl8192de/sw.c  |    2 -
 drivers/net/wireless/realtek/rtlwifi/rtl8192ee/sw.c  |    2 -
 drivers/net/wireless/realtek/rtlwifi/rtl8192se/sw.c  |    2 -
 drivers/net/wireless/realtek/rtlwifi/rtl8723ae/sw.c  |    2 -
 drivers/net/wireless/realtek/rtlwifi/rtl8723be/sw.c  |    2 -
 drivers/net/wireless/realtek/rtlwifi/rtl8821ae/sw.c  |    2 -
 drivers/platform/chrome/chromeos_laptop.c            |   22 +++++++++----------
 drivers/platform/x86/intel_scu_ipc.c                 |    6 ++---
 drivers/platform/x86/intel_telemetry_debugfs.c       |    2 -
 drivers/scsi/esas2r/esas2r_flash.c                   |    2 -
 drivers/scsi/hptiop.c                                |    6 ++---
 drivers/spi/spi-dw-pci.c                             |    4 +--
 drivers/staging/rtl8192e/rtl8192e/rtl_core.c         |    2 -
 drivers/usb/misc/ezusb.c                             |    2 -
 drivers/video/fbdev/matrox/matroxfb_g450.c           |    2 -
 lib/crc64_ecma.c                                     |    2 -
 sound/pci/ctxfi/ctatc.c                              |    2 -
 sound/pci/hda/patch_ca0132.c                         |   10 ++++----
 sound/pci/riptide/riptide.c                          |    2 -
 40 files changed, 110 insertions(+), 110 deletions(-)
