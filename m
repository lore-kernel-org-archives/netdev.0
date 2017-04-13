From: Logan Gunthorpe <logang-OTvnGxWRz7hWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 00/22] Introduce common scatterlist map function
Date: Thu, 13 Apr 2017 16:05:13 -0600
Message-ID: <1492121135-4437-1-git-send-email-logang@deltatee.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
To: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>,
 "Martin K. Petersen" <martin.petersen-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
 Sagi Grimberg <sagi-NQWnxTmZq1alnMjI0IkVqw@public.gmane.org>, Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>,
 Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
 Dan Williams <dan.j.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
 Ross Zwisler <ross.zwisler-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
 Matthew Wilcox <mawilcox-0li6OtcxBFHby3iVrkZq2A@public.gmane.org>,
 Sumit Semwal <sumit.semwal-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, Ming Lin <ming.l-Vzezgt5dB6uUEJcrhfAQsw@public.gmane.org>,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-crypto-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org,
 linaro-mm-sig-cunTk1MwBs8s++Sfvej+rw@public.gmane.org, intel-gfx-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org,
 linux-raid-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-nvme-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-nvdimm-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org,
 linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, fcoe-devel-s9riP+hp16TNLxjTenLetw@public.gmane.org,
 open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org, megaraidlinux.pdl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
 sparmaintainer-GLv8BlqOqDDQT0dZR+AlfA@public.gmane.org, devel@driverd
Return-path: <linux-nvdimm-bounces-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org>
List-Unsubscribe: <https://lists.01.org/mailman/options/linux-nvdimm>,
 <mailto:linux-nvdimm-request-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.01.org/pipermail/linux-nvdimm/>
List-Post: <mailto:linux-nvdimm-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org>
List-Help: <mailto:linux-nvdimm-request-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org?subject=help>
List-Subscribe: <https://lists.01.org/mailman/listinfo/linux-nvdimm>,
 <mailto:linux-nvdimm-request-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org?subject=subscribe>
Errors-To: linux-nvdimm-bounces-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org
Sender: "Linux-nvdimm" <linux-nvdimm-bounces-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org>
List-Id: netdev.vger.kernel.org

Hi Everyone,

As part of my effort to enable P2P DMA transactions with PCI cards,
we've identified the need to be able to safely put IO memory into
scatterlists (and eventually other spots). This probably involves a
conversion from struct page to pfn_t but that migration is a ways off
and those decisions are yet to be made.

As an initial step in that direction, I've started cleaning up some of the
scatterlist code by trying to carve out a better defined layer between it
and it's users. The longer term goal would be to remove sg_page or replace
it with something that can potentially fail.

This patchset is the first step in that effort. I've introduced
a common function to map scatterlist memory and converted all the common
kmap(sg_page()) cases. This removes about 66 sg_page calls (of ~331).

Seeing this is a fairly large cleanup set that touches a wide swath of
the kernel I have limited the people I've sent this to. I'd suggest we look
toward merging the first patch and then I can send the individual subsystem
patches on to their respective maintainers and get them merged
independantly. (This is to avoid the conflicts I created with my last
cleanup set... Sorry) Though, I'm certainly open to other suggestions to get
it merged.

The patchset is based on v4.11-rc6 and can be found in the sg_map
branch from this git tree:

https://github.com/sbates130272/linux-p2pmem.git

Thanks,

Logan


Logan Gunthorpe (22):
  scatterlist: Introduce sg_map helper functions
  nvmet: Make use of the new sg_map helper function
  libiscsi: Make use of new the sg_map helper function
  target: Make use of the new sg_map function at 16 call sites
  drm/i915: Make use of the new sg_map helper function
  crypto: hifn_795x: Make use of the new sg_map helper function
  crypto: shash, caam: Make use of the new sg_map helper function
  crypto: chcr: Make use of the new sg_map helper function
  dm-crypt: Make use of the new sg_map helper in 4 call sites
  staging: unisys: visorbus: Make use of the new sg_map helper function
  RDS: Make use of the new sg_map helper function
  scsi: ipr, pmcraid, isci: Make use of the new sg_map helper in 4 call
    sites
  scsi: hisi_sas, mvsas, gdth: Make use of the new sg_map helper
    function
  scsi: arcmsr, ips, megaraid: Make use of the new sg_map helper
    function
  scsi: libfc, csiostor: Change to sg_copy_buffer in two drivers
  xen-blkfront: Make use of the new sg_map helper function
  mmc: sdhci: Make use of the new sg_map helper function
  mmc: spi: Make use of the new sg_map helper function
  mmc: tmio: Make use of the new sg_map helper function
  mmc: sdricoh_cs: Make use of the new sg_map helper function
  mmc: tifm_sd: Make use of the new sg_map helper function
  memstick: Make use of the new sg_map helper function

 crypto/shash.c                                  |   9 +-
 drivers/block/xen-blkfront.c                    |  33 +++++--
 drivers/crypto/caam/caamalg.c                   |   8 +-
 drivers/crypto/chelsio/chcr_algo.c              |  28 +++---
 drivers/crypto/hifn_795x.c                      |  32 ++++---
 drivers/dma-buf/dma-buf.c                       |   3 +
 drivers/gpu/drm/i915/i915_gem.c                 |  27 +++---
 drivers/md/dm-crypt.c                           |  38 +++++---
 drivers/memstick/host/jmb38x_ms.c               |  23 ++++-
 drivers/memstick/host/tifm_ms.c                 |  22 ++++-
 drivers/mmc/host/mmc_spi.c                      |  26 +++--
 drivers/mmc/host/sdhci.c                        |  35 ++++++-
 drivers/mmc/host/sdricoh_cs.c                   |  14 ++-
 drivers/mmc/host/tifm_sd.c                      |  88 +++++++++++++----
 drivers/mmc/host/tmio_mmc.h                     |  12 ++-
 drivers/mmc/host/tmio_mmc_dma.c                 |   5 +
 drivers/mmc/host/tmio_mmc_pio.c                 |  24 +++++
 drivers/nvme/target/fabrics-cmd.c               |  16 +++-
 drivers/scsi/arcmsr/arcmsr_hba.c                |  16 +++-
 drivers/scsi/csiostor/csio_scsi.c               |  54 +----------
 drivers/scsi/cxgbi/libcxgbi.c                   |   5 +
 drivers/scsi/gdth.c                             |   9 +-
 drivers/scsi/hisi_sas/hisi_sas_v1_hw.c          |  14 ++-
 drivers/scsi/hisi_sas/hisi_sas_v2_hw.c          |  13 ++-
 drivers/scsi/ipr.c                              |  27 +++---
 drivers/scsi/ips.c                              |   8 +-
 drivers/scsi/isci/request.c                     |  42 ++++----
 drivers/scsi/libfc/fc_libfc.c                   |  49 ++--------
 drivers/scsi/libiscsi_tcp.c                     |  32 ++++---
 drivers/scsi/megaraid.c                         |   9 +-
 drivers/scsi/mvsas/mv_sas.c                     |  10 +-
 drivers/scsi/pmcraid.c                          |  19 ++--
 drivers/staging/unisys/visorhba/visorhba_main.c |  12 ++-
 drivers/target/iscsi/iscsi_target.c             |  27 ++++--
 drivers/target/target_core_rd.c                 |   3 +-
 drivers/target/target_core_sbc.c                | 122 +++++++++++++++++-------
 drivers/target/target_core_transport.c          |  18 ++--
 drivers/target/target_core_user.c               |  43 ++++++---
 include/linux/scatterlist.h                     |  97 +++++++++++++++++++
 include/scsi/libiscsi_tcp.h                     |   3 +-
 include/target/target_core_backend.h            |   4 +-
 net/rds/ib_recv.c                               |  17 +++-
 42 files changed, 739 insertions(+), 357 deletions(-)

--
2.1.4
