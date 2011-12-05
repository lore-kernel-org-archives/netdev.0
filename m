From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: WARNING: at mm/slub.c:3357, kernel BUG at mm/slub.c:3413
Date: Mon, 5 Dec 2011 12:10:46 -0500
Message-ID: <20111205171046.GA4342@homer.localdomain>
References: <20111121153621.GA1678@x4.trippels.de>
 <20111123160353.GA1673@x4.trippels.de>
 <alpine.DEB.2.00.1111231004490.17317@router.home>
 <20111124085040.GA1677@x4.trippels.de>
 <20111202230412.GB12057@homer.localdomain>
 <20111203092845.GA1520@x4.trippels.de>
 <CAPM=9tyjZc9waC_ZBygW9zh+Zq-Wb1X5Y6yfsCCMPYwpFVWOOg@mail.gmail.com>
 <20111203122900.GA1617@x4.trippels.de>
 <CAH3drwZDOpPuQ_G=LwTiNsR5BNyJTNr+VJU74E6nS5AbKyQH0A@mail.gmail.com>
 <20111204010200.GA1530@x4.trippels.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="G4iJoqBmSsgzjUCe"
Cc: Dave Airlie <airlied@gmail.com>, Christoph Lameter <cl@linux.com>,
	"Alex, Shi" <alex.shi@intel.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	dri-devel@lists.freedesktop.org, Pekka Enberg <penberg@kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	Matt Mackall <mpm@selenic.com>, tj@kernel.org,
	Alex Deucher <alexander.deucher@amd.com>
To: Markus Trippelsdorf <markus@trippelsdorf.de>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <20111204010200.GA1530@x4.trippels.de>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org


--G4iJoqBmSsgzjUCe
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sun, Dec 04, 2011 at 02:02:00AM +0100, Markus Trippelsdorf wrote:
> On 2011.12.03 at 14:31 -0500, Jerome Glisse wrote:
> > On Sat, Dec 3, 2011 at 7:29 AM, Markus Trippelsdorf
> > <markus@trippelsdorf.de> wrote:
> > > On 2011.12.03 at 12:20 +0000, Dave Airlie wrote:
> > >> >> > > > > FIX idr_layer_cache: Marking all objects used
> > >> >> > > >
> > >> >> > > > Yesterday I couldn't reproduce the issue at all. But today I've hit
> > >> >> > > > exactly the same spot again. (CCing the drm list)
> > >>
> > >> If I had to guess it looks like 0 is getting written back to some
> > >> random page by the GPU maybe, it could be that the GPU is in some half
> > >> setup state at boot or on a reboot does it happen from a cold boot or
> > >> just warm boot or kexec?
> > >
> > > Only happened with kexec thus far. Cold boot seems to be fine.
> > >
> > > --
> > > Markus
> > 
> > Can you add radeon.no_wb=1 to your kexec kernel paramater an see if
> > you can reproduce.
> 
> No, I cannot reproduce the issue with radeon.no_wb=1. (I write this
> after 700 successful kexec iterations...)
> 
> -- 
> Markus

Can you try if attached patch fix the issue when you don't pass the
radeon.no_wb=1 option ?

Cheers,
Jerome

--G4iJoqBmSsgzjUCe
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="0001-drm-radeon-disable-possible-GPU-writeback-early.patch"

>From 5e3e9d9b3069837a07bea7b4997c6fca26405bce Mon Sep 17 00:00:00 2001
From: Jerome Glisse <jglisse@redhat.com>
Date: Mon, 5 Dec 2011 12:02:17 -0500
Subject: [PATCH] drm/radeon: disable possible GPU writeback early

Given how kexec works we need to disable any kind of GPU writeback
early in GPU initialization just in case some are still active from
previous setup.

Signed-off-by: Jerome Glisse <jglisse@redhat.com>
---
 drivers/gpu/drm/radeon/evergreen.c |    7 ++++++
 drivers/gpu/drm/radeon/ni.c        |    9 +++++++
 drivers/gpu/drm/radeon/nid.h       |   19 ++++++++++++++++
 drivers/gpu/drm/radeon/r100.c      |    7 ++++++
 drivers/gpu/drm/radeon/r300.c      |    7 ++++++
 drivers/gpu/drm/radeon/r300d.h     |   21 ++++++++++++++++++
 drivers/gpu/drm/radeon/r420.c      |    7 ++++++
 drivers/gpu/drm/radeon/r420d.h     |   42 ++++++++++++++++++++++++++++++++++++
 drivers/gpu/drm/radeon/r520.c      |   10 ++++++++
 drivers/gpu/drm/radeon/r520d.h     |   24 ++++++++++++++++++++
 drivers/gpu/drm/radeon/r600.c      |    7 ++++++
 drivers/gpu/drm/radeon/rs400.c     |    7 ++++++
 drivers/gpu/drm/radeon/rs400d.h    |   21 ++++++++++++++++++
 drivers/gpu/drm/radeon/rs600.c     |   10 ++++++++
 drivers/gpu/drm/radeon/rs600d.h    |   21 ++++++++++++++++++
 drivers/gpu/drm/radeon/rs690.c     |   10 ++++++++
 drivers/gpu/drm/radeon/rs690d.h    |   24 ++++++++++++++++++++
 drivers/gpu/drm/radeon/rv515.c     |   10 ++++++++
 drivers/gpu/drm/radeon/rv515d.h    |   24 ++++++++++++++++++++
 drivers/gpu/drm/radeon/rv770.c     |    7 ++++++
 drivers/gpu/drm/radeon/rv770d.h    |   20 +++++++++++++++++
 21 files changed, 314 insertions(+), 0 deletions(-)

diff --git a/drivers/gpu/drm/radeon/evergreen.c b/drivers/gpu/drm/radeon/evergreen.c
index 1934728..d49596b 100644
--- a/drivers/gpu/drm/radeon/evergreen.c
+++ b/drivers/gpu/drm/radeon/evergreen.c
@@ -3249,6 +3249,13 @@ int evergreen_init(struct radeon_device *rdev)
 {
 	int r;
 
+	/* stop possible GPU activities */
+	WREG32(IH_RB_CNTL, 0);
+	WREG32(IH_CNTL, 0);
+	WREG32(CP_ME_CNTL, CP_ME_HALT | CP_PFP_HALT);
+	WREG32(SCRATCH_UMSK, 0);
+	WREG32(CP_RB_CNTL, RB_NO_UPDATE);
+
 	/* This don't do much */
 	r = radeon_gem_init(rdev);
 	if (r)
diff --git a/drivers/gpu/drm/radeon/ni.c b/drivers/gpu/drm/radeon/ni.c
index c15fc8b..2a00ad1 100644
--- a/drivers/gpu/drm/radeon/ni.c
+++ b/drivers/gpu/drm/radeon/ni.c
@@ -1577,6 +1577,15 @@ int cayman_init(struct radeon_device *rdev)
 	struct radeon_ring *ring = &rdev->ring[RADEON_RING_TYPE_GFX_INDEX];
 	int r;
 
+	/* stop possible GPU activities */
+	WREG32(IH_RB_CNTL, 0);
+	WREG32(IH_CNTL, 0);
+	WREG32(CP_ME_CNTL, CP_ME_HALT | CP_PFP_HALT);
+	WREG32(SCRATCH_UMSK, 0);
+	WREG32(CP_RB0_CNTL, RB_NO_UPDATE);
+	WREG32(CP_RB1_CNTL, RB_NO_UPDATE);
+	WREG32(CP_RB2_CNTL, RB_NO_UPDATE);
+
 	/* This don't do much */
 	r = radeon_gem_init(rdev);
 	if (r)
diff --git a/drivers/gpu/drm/radeon/nid.h b/drivers/gpu/drm/radeon/nid.h
index 4640334..3aa33c6 100644
--- a/drivers/gpu/drm/radeon/nid.h
+++ b/drivers/gpu/drm/radeon/nid.h
@@ -162,6 +162,25 @@
 #define HDP_MISC_CNTL					0x2F4C
 #define 	HDP_FLUSH_INVALIDATE_CACHE			(1 << 0)
 
+#define IH_RB_CNTL                                        0x3e00
+#       define IH_RB_ENABLE                               (1 << 0)
+#       define IH_IB_SIZE(x)                              ((x) << 1) /* log2 */
+#       define IH_RB_FULL_DRAIN_ENABLE                    (1 << 6)
+#       define IH_WPTR_WRITEBACK_ENABLE                   (1 << 8)
+#       define IH_WPTR_WRITEBACK_TIMER(x)                 ((x) << 9) /* log2 */
+#       define IH_WPTR_OVERFLOW_ENABLE                    (1 << 16)
+#       define IH_WPTR_OVERFLOW_CLEAR                     (1 << 31)
+#define IH_CNTL                                           0x3e18
+#       define ENABLE_INTR                                (1 << 0)
+#       define IH_MC_SWAP(x)                              ((x) << 1)
+#       define IH_MC_SWAP_NONE                            0
+#       define IH_MC_SWAP_16BIT                           1
+#       define IH_MC_SWAP_32BIT                           2
+#       define IH_MC_SWAP_64BIT                           3
+#       define RPTR_REARM                                 (1 << 4)
+#       define MC_WRREQ_CREDIT(x)                         ((x) << 15)
+#       define MC_WR_CLEAN_CNT(x)                         ((x) << 20)
+
 #define	CC_SYS_RB_BACKEND_DISABLE			0x3F88
 #define	GC_USER_SYS_RB_BACKEND_DISABLE			0x3F8C
 #define	CGTS_SYS_TCC_DISABLE				0x3F90
diff --git a/drivers/gpu/drm/radeon/r100.c b/drivers/gpu/drm/radeon/r100.c
index 657040b..8a71502 100644
--- a/drivers/gpu/drm/radeon/r100.c
+++ b/drivers/gpu/drm/radeon/r100.c
@@ -4010,6 +4010,13 @@ int r100_init(struct radeon_device *rdev)
 {
 	int r;
 
+	/* stop possible GPU activities */
+	WREG32(RADEON_CP_CSQ_MODE, 0);
+	WREG32(RADEON_CP_CSQ_CNTL, 0);
+	WREG32(R_000770_SCRATCH_UMSK, 0);
+	WREG32(RADEON_CP_RB_CNTL, RADEON_RB_NO_UPDATE);
+	WREG32(RADEON_GEN_INT_CNTL, 0);
+
 	/* Register debugfs file specific to this group of asics */
 	r100_debugfs(rdev);
 	/* Disable VGA */
diff --git a/drivers/gpu/drm/radeon/r300.c b/drivers/gpu/drm/radeon/r300.c
index 3fc0d29..63ca887 100644
--- a/drivers/gpu/drm/radeon/r300.c
+++ b/drivers/gpu/drm/radeon/r300.c
@@ -1491,6 +1491,13 @@ int r300_init(struct radeon_device *rdev)
 {
 	int r;
 
+	/* stop possible GPU activities */
+	WREG32(R_000740_CP_CSQ_CNTL, 0);
+	WREG32(R_000744_CP_CSQ_MODE, 0);
+	WREG32(R_000770_SCRATCH_UMSK, 0);
+	WREG32(R_000704_CP_RB_CNTL, S_000704_RB_NO_UPDATE(1));
+	WREG32(R_000040_GEN_INT_CNTL, 0);
+
 	/* Disable VGA */
 	r100_vga_render_disable(rdev);
 	/* Initialize scratch registers */
diff --git a/drivers/gpu/drm/radeon/r300d.h b/drivers/gpu/drm/radeon/r300d.h
index 1f519a5..b9f5e3e 100644
--- a/drivers/gpu/drm/radeon/r300d.h
+++ b/drivers/gpu/drm/radeon/r300d.h
@@ -350,5 +350,26 @@
 #define   S_00000D_FORCE_OV0(x)                        (((x) & 0x1) << 31)
 #define   G_00000D_FORCE_OV0(x)                        (((x) >> 31) & 0x1)
 #define   C_00000D_FORCE_OV0                           0x7FFFFFFF
+#define R_000040_GEN_INT_CNTL                        0x000040
+#define R_000704_CP_RB_CNTL                          0x000704
+#define   S_000704_RB_NO_UPDATE(x)                     (((x) & 0x1) << 27)
+#define R_000740_CP_CSQ_CNTL                         0x000740
+#define   S_000740_CSQ_CNT_PRIMARY(x)                  (((x) & 0xFF) << 0)
+#define   G_000740_CSQ_CNT_PRIMARY(x)                  (((x) >> 0) & 0xFF)
+#define   C_000740_CSQ_CNT_PRIMARY                     0xFFFFFF00
+#define   S_000740_CSQ_CNT_INDIRECT(x)                 (((x) & 0xFF) << 8)
+#define   G_000740_CSQ_CNT_INDIRECT(x)                 (((x) >> 8) & 0xFF)
+#define   C_000740_CSQ_CNT_INDIRECT                    0xFFFF00FF
+#define   S_000740_CSQ_MODE(x)                         (((x) & 0xF) << 28)
+#define   G_000740_CSQ_MODE(x)                         (((x) >> 28) & 0xF)
+#define   C_000740_CSQ_MODE                            0x0FFFFFFF
+#define R_000744_CP_CSQ_MODE                         0x000744
+#define R_000770_SCRATCH_UMSK                        0x000770
+#define   S_000770_SCRATCH_UMSK(x)                     (((x) & 0x3F) << 0)
+#define   G_000770_SCRATCH_UMSK(x)                     (((x) >> 0) & 0x3F)
+#define   C_000770_SCRATCH_UMSK                        0xFFFFFFC0
+#define   S_000770_SCRATCH_SWAP(x)                     (((x) & 0x3) << 16)
+#define   G_000770_SCRATCH_SWAP(x)                     (((x) >> 16) & 0x3)
+#define   C_000770_SCRATCH_SWAP                        0xFFFCFFFF
 
 #endif
diff --git a/drivers/gpu/drm/radeon/r420.c b/drivers/gpu/drm/radeon/r420.c
index 666e28f..9b9b293 100644
--- a/drivers/gpu/drm/radeon/r420.c
+++ b/drivers/gpu/drm/radeon/r420.c
@@ -360,6 +360,13 @@ int r420_init(struct radeon_device *rdev)
 {
 	int r;
 
+	/* stop possible GPU activities */
+	WREG32(R_000740_CP_CSQ_CNTL, 0);
+	WREG32(R_000744_CP_CSQ_MODE, 0);
+	WREG32(R_000770_SCRATCH_UMSK, 0);
+	WREG32(R_000704_CP_RB_CNTL, S_000704_RB_NO_UPDATE(1));
+	WREG32(R_000040_GEN_INT_CNTL, 0);
+
 	/* Initialize scratch registers */
 	radeon_scratch_init(rdev);
 	/* Initialize surface registers */
diff --git a/drivers/gpu/drm/radeon/r420d.h b/drivers/gpu/drm/radeon/r420d.h
index fc78d31..d5ee6e8 100644
--- a/drivers/gpu/drm/radeon/r420d.h
+++ b/drivers/gpu/drm/radeon/r420d.h
@@ -245,5 +245,47 @@
 #define   S_00000D_FORCE_OV0(x)                        (((x) & 0x1) << 31)
 #define   G_00000D_FORCE_OV0(x)                        (((x) >> 31) & 0x1)
 #define   C_00000D_FORCE_OV0                           0x7FFFFFFF
+#define R_000040_GEN_INT_CNTL                        0x000040
+#define R_000704_CP_RB_CNTL                          0x000704
+#define   S_000704_RB_NO_UPDATE(x)                     (((x) & 0x1) << 27)
+#define R_000740_CP_CSQ_CNTL                         0x000740
+#define   S_000740_CSQ_CNT_PRIMARY(x)                  (((x) & 0xFF) << 0)
+#define   G_000740_CSQ_CNT_PRIMARY(x)                  (((x) >> 0) & 0xFF)
+#define   C_000740_CSQ_CNT_PRIMARY                     0xFFFFFF00
+#define   S_000740_CSQ_CNT_INDIRECT(x)                 (((x) & 0xFF) << 8)
+#define   G_000740_CSQ_CNT_INDIRECT(x)                 (((x) >> 8) & 0xFF)
+#define   C_000740_CSQ_CNT_INDIRECT                    0xFFFF00FF
+#define   S_000740_CSQ_MODE(x)                         (((x) & 0xF) << 28)
+#define   G_000740_CSQ_MODE(x)                         (((x) >> 28) & 0xF)
+#define   C_000740_CSQ_MODE                            0x0FFFFFFF
+#define R_000744_CP_CSQ_MODE                         0x000744
+#define R_000770_SCRATCH_UMSK                        0x000770
+#define   S_000770_SCRATCH_UMSK(x)                     (((x) & 0x3F) << 0)
+#define   G_000770_SCRATCH_UMSK(x)                     (((x) >> 0) & 0x3F)
+#define   C_000770_SCRATCH_UMSK                        0xFFFFFFC0
+#define   S_000770_SCRATCH_SWAP(x)                     (((x) & 0x3) << 16)
+#define   G_000770_SCRATCH_SWAP(x)                     (((x) >> 16) & 0x3)
+#define   C_000770_SCRATCH_SWAP                        0xFFFCFFFF
+#define R_000040_GEN_INT_CNTL                        0x000040
+#define R_000704_CP_RB_CNTL                          0x000704
+#define   S_000704_RB_NO_UPDATE(x)                     (((x) & 0x1) << 27)
+#define R_000740_CP_CSQ_CNTL                         0x000740
+#define   S_000740_CSQ_CNT_PRIMARY(x)                  (((x) & 0xFF) << 0)
+#define   G_000740_CSQ_CNT_PRIMARY(x)                  (((x) >> 0) & 0xFF)
+#define   C_000740_CSQ_CNT_PRIMARY                     0xFFFFFF00
+#define   S_000740_CSQ_CNT_INDIRECT(x)                 (((x) & 0xFF) << 8)
+#define   G_000740_CSQ_CNT_INDIRECT(x)                 (((x) >> 8) & 0xFF)
+#define   C_000740_CSQ_CNT_INDIRECT                    0xFFFF00FF
+#define   S_000740_CSQ_MODE(x)                         (((x) & 0xF) << 28)
+#define   G_000740_CSQ_MODE(x)                         (((x) >> 28) & 0xF)
+#define   C_000740_CSQ_MODE                            0x0FFFFFFF
+#define R_000744_CP_CSQ_MODE                         0x000744
+#define R_000770_SCRATCH_UMSK                        0x000770
+#define   S_000770_SCRATCH_UMSK(x)                     (((x) & 0x3F) << 0)
+#define   G_000770_SCRATCH_UMSK(x)                     (((x) >> 0) & 0x3F)
+#define   C_000770_SCRATCH_UMSK                        0xFFFFFFC0
+#define   S_000770_SCRATCH_SWAP(x)                     (((x) & 0x3) << 16)
+#define   G_000770_SCRATCH_SWAP(x)                     (((x) >> 16) & 0x3)
+#define   C_000770_SCRATCH_SWAP                        0xFFFCFFFF
 
 #endif
diff --git a/drivers/gpu/drm/radeon/r520.c b/drivers/gpu/drm/radeon/r520.c
index 4ae1615..403b1d0 100644
--- a/drivers/gpu/drm/radeon/r520.c
+++ b/drivers/gpu/drm/radeon/r520.c
@@ -244,6 +244,16 @@ int r520_init(struct radeon_device *rdev)
 {
 	int r;
 
+	/* stop possible GPU activities */
+	WREG32(R_000740_CP_CSQ_CNTL, 0);
+	WREG32(R_000744_CP_CSQ_MODE, 0);
+	WREG32(R_000770_SCRATCH_UMSK, 0);
+	WREG32(R_000704_CP_RB_CNTL, S_000704_RB_NO_UPDATE(1));
+	WREG32(R_000040_GEN_INT_CNTL, 0);
+	WREG32(R_006540_DxMODE_INT_MASK, 0);
+	WREG32(R_007D08_DC_HOT_PLUG_DETECT1_INT_CONTROL, 0);
+	WREG32(R_007D18_DC_HOT_PLUG_DETECT2_INT_CONTROL, 0);
+
 	/* Initialize scratch registers */
 	radeon_scratch_init(rdev);
 	/* Initialize surface registers */
diff --git a/drivers/gpu/drm/radeon/r520d.h b/drivers/gpu/drm/radeon/r520d.h
index 61af61f..6d34664 100644
--- a/drivers/gpu/drm/radeon/r520d.h
+++ b/drivers/gpu/drm/radeon/r520d.h
@@ -183,5 +183,29 @@
 #define   S_000007_AGP_BASE_ADDR_2(x)                  (((x) & 0xF) << 0)
 #define   G_000007_AGP_BASE_ADDR_2(x)                  (((x) >> 0) & 0xF)
 #define   C_000007_AGP_BASE_ADDR_2                     0xFFFFFFF0
+#define R_006540_DxMODE_INT_MASK                     0x006540
+#define R_007D08_DC_HOT_PLUG_DETECT1_INT_CONTROL       0x007D08
+#define R_007D18_DC_HOT_PLUG_DETECT2_INT_CONTROL       0x007D18
+#define R_000040_GEN_INT_CNTL                        0x000040
+#define R_000704_CP_RB_CNTL                          0x000704
+#define   S_000704_RB_NO_UPDATE(x)                     (((x) & 0x1) << 27)
+#define R_000740_CP_CSQ_CNTL                         0x000740
+#define   S_000740_CSQ_CNT_PRIMARY(x)                  (((x) & 0xFF) << 0)
+#define   G_000740_CSQ_CNT_PRIMARY(x)                  (((x) >> 0) & 0xFF)
+#define   C_000740_CSQ_CNT_PRIMARY                     0xFFFFFF00
+#define   S_000740_CSQ_CNT_INDIRECT(x)                 (((x) & 0xFF) << 8)
+#define   G_000740_CSQ_CNT_INDIRECT(x)                 (((x) >> 8) & 0xFF)
+#define   C_000740_CSQ_CNT_INDIRECT                    0xFFFF00FF
+#define   S_000740_CSQ_MODE(x)                         (((x) & 0xF) << 28)
+#define   G_000740_CSQ_MODE(x)                         (((x) >> 28) & 0xF)
+#define   C_000740_CSQ_MODE                            0x0FFFFFFF
+#define R_000744_CP_CSQ_MODE                         0x000744
+#define R_000770_SCRATCH_UMSK                        0x000770
+#define   S_000770_SCRATCH_UMSK(x)                     (((x) & 0x3F) << 0)
+#define   G_000770_SCRATCH_UMSK(x)                     (((x) >> 0) & 0x3F)
+#define   C_000770_SCRATCH_UMSK                        0xFFFFFFC0
+#define   S_000770_SCRATCH_SWAP(x)                     (((x) & 0x3) << 16)
+#define   G_000770_SCRATCH_SWAP(x)                     (((x) >> 16) & 0x3)
+#define   C_000770_SCRATCH_SWAP                        0xFFFCFFFF
 
 #endif
diff --git a/drivers/gpu/drm/radeon/r600.c b/drivers/gpu/drm/radeon/r600.c
index 951566f..d333909 100644
--- a/drivers/gpu/drm/radeon/r600.c
+++ b/drivers/gpu/drm/radeon/r600.c
@@ -2566,6 +2566,13 @@ int r600_init(struct radeon_device *rdev)
 {
 	int r;
 
+	/* stop possible GPU activities */
+	WREG32(IH_RB_CNTL, 0);
+	WREG32(IH_CNTL, 0);
+	WREG32(R_0086D8_CP_ME_CNTL, S_0086D8_CP_ME_HALT(1));
+	WREG32(SCRATCH_UMSK, 0);
+	WREG32(CP_RB_CNTL, RB_NO_UPDATE);
+
 	if (r600_debugfs_mc_info_init(rdev)) {
 		DRM_ERROR("Failed to register debugfs file for mc !\n");
 	}
diff --git a/drivers/gpu/drm/radeon/rs400.c b/drivers/gpu/drm/radeon/rs400.c
index b0ce84a..4f708a5 100644
--- a/drivers/gpu/drm/radeon/rs400.c
+++ b/drivers/gpu/drm/radeon/rs400.c
@@ -494,6 +494,13 @@ int rs400_init(struct radeon_device *rdev)
 {
 	int r;
 
+	/* stop possible GPU activities */
+	WREG32(R_000740_CP_CSQ_CNTL, 0);
+	WREG32(R_000744_CP_CSQ_MODE, 0);
+	WREG32(R_000770_SCRATCH_UMSK, 0);
+	WREG32(R_000704_CP_RB_CNTL, S_000704_RB_NO_UPDATE(1));
+	WREG32(R_000040_GEN_INT_CNTL, 0);
+
 	/* Disable VGA */
 	r100_vga_render_disable(rdev);
 	/* Initialize scratch registers */
diff --git a/drivers/gpu/drm/radeon/rs400d.h b/drivers/gpu/drm/radeon/rs400d.h
index 6d8bac5..fc6a9e5 100644
--- a/drivers/gpu/drm/radeon/rs400d.h
+++ b/drivers/gpu/drm/radeon/rs400d.h
@@ -156,5 +156,26 @@
 #define   S_000E40_GUI_ACTIVE(x)                       (((x) & 0x1) << 31)
 #define   G_000E40_GUI_ACTIVE(x)                       (((x) >> 31) & 0x1)
 #define   C_000E40_GUI_ACTIVE                          0x7FFFFFFF
+#define R_000040_GEN_INT_CNTL                        0x000040
+#define R_000704_CP_RB_CNTL                          0x000704
+#define   S_000704_RB_NO_UPDATE(x)                     (((x) & 0x1) << 27)
+#define R_000740_CP_CSQ_CNTL                         0x000740
+#define   S_000740_CSQ_CNT_PRIMARY(x)                  (((x) & 0xFF) << 0)
+#define   G_000740_CSQ_CNT_PRIMARY(x)                  (((x) >> 0) & 0xFF)
+#define   C_000740_CSQ_CNT_PRIMARY                     0xFFFFFF00
+#define   S_000740_CSQ_CNT_INDIRECT(x)                 (((x) & 0xFF) << 8)
+#define   G_000740_CSQ_CNT_INDIRECT(x)                 (((x) >> 8) & 0xFF)
+#define   C_000740_CSQ_CNT_INDIRECT                    0xFFFF00FF
+#define   S_000740_CSQ_MODE(x)                         (((x) & 0xF) << 28)
+#define   G_000740_CSQ_MODE(x)                         (((x) >> 28) & 0xF)
+#define   C_000740_CSQ_MODE                            0x0FFFFFFF
+#define R_000744_CP_CSQ_MODE                         0x000744
+#define R_000770_SCRATCH_UMSK                        0x000770
+#define   S_000770_SCRATCH_UMSK(x)                     (((x) & 0x3F) << 0)
+#define   G_000770_SCRATCH_UMSK(x)                     (((x) >> 0) & 0x3F)
+#define   C_000770_SCRATCH_UMSK                        0xFFFFFFC0
+#define   S_000770_SCRATCH_SWAP(x)                     (((x) & 0x3) << 16)
+#define   G_000770_SCRATCH_SWAP(x)                     (((x) >> 16) & 0x3)
+#define   C_000770_SCRATCH_SWAP                        0xFFFCFFFF
 
 #endif
diff --git a/drivers/gpu/drm/radeon/rs600.c b/drivers/gpu/drm/radeon/rs600.c
index ca6d5b6..76f56bb 100644
--- a/drivers/gpu/drm/radeon/rs600.c
+++ b/drivers/gpu/drm/radeon/rs600.c
@@ -939,6 +939,16 @@ int rs600_init(struct radeon_device *rdev)
 {
 	int r;
 
+	/* stop possible GPU activities */
+	WREG32(R_000740_CP_CSQ_CNTL, 0);
+	WREG32(R_000744_CP_CSQ_MODE, 0);
+	WREG32(R_000770_SCRATCH_UMSK, 0);
+	WREG32(R_000704_CP_RB_CNTL, S_000704_RB_NO_UPDATE(1));
+	WREG32(R_000040_GEN_INT_CNTL, 0);
+	WREG32(R_006540_DxMODE_INT_MASK, 0);
+	WREG32(R_007D08_DC_HOT_PLUG_DETECT1_INT_CONTROL, 0);
+	WREG32(R_007D18_DC_HOT_PLUG_DETECT2_INT_CONTROL, 0);
+
 	/* Disable VGA */
 	rv515_vga_render_disable(rdev);
 	/* Initialize scratch registers */
diff --git a/drivers/gpu/drm/radeon/rs600d.h b/drivers/gpu/drm/radeon/rs600d.h
index a27c13a..54d96e6 100644
--- a/drivers/gpu/drm/radeon/rs600d.h
+++ b/drivers/gpu/drm/radeon/rs600d.h
@@ -668,4 +668,25 @@
 #define   PM_ASSERT_RESET                              (1 << 20)
 #define   PM_PWRDN_PPLL                                (1 << 24)
 
+#define R_000704_CP_RB_CNTL                          0x000704
+#define   S_000704_RB_NO_UPDATE(x)                     (((x) & 0x1) << 27)
+#define R_000740_CP_CSQ_CNTL                         0x000740
+#define   S_000740_CSQ_CNT_PRIMARY(x)                  (((x) & 0xFF) << 0)
+#define   G_000740_CSQ_CNT_PRIMARY(x)                  (((x) >> 0) & 0xFF)
+#define   C_000740_CSQ_CNT_PRIMARY                     0xFFFFFF00
+#define   S_000740_CSQ_CNT_INDIRECT(x)                 (((x) & 0xFF) << 8)
+#define   G_000740_CSQ_CNT_INDIRECT(x)                 (((x) >> 8) & 0xFF)
+#define   C_000740_CSQ_CNT_INDIRECT                    0xFFFF00FF
+#define   S_000740_CSQ_MODE(x)                         (((x) & 0xF) << 28)
+#define   G_000740_CSQ_MODE(x)                         (((x) >> 28) & 0xF)
+#define   C_000740_CSQ_MODE                            0x0FFFFFFF
+#define R_000744_CP_CSQ_MODE                         0x000744
+#define R_000770_SCRATCH_UMSK                        0x000770
+#define   S_000770_SCRATCH_UMSK(x)                     (((x) & 0x3F) << 0)
+#define   G_000770_SCRATCH_UMSK(x)                     (((x) >> 0) & 0x3F)
+#define   C_000770_SCRATCH_UMSK                        0xFFFFFFC0
+#define   S_000770_SCRATCH_SWAP(x)                     (((x) & 0x3) << 16)
+#define   G_000770_SCRATCH_SWAP(x)                     (((x) >> 16) & 0x3)
+#define   C_000770_SCRATCH_SWAP                        0xFFFCFFFF
+
 #endif
diff --git a/drivers/gpu/drm/radeon/rs690.c b/drivers/gpu/drm/radeon/rs690.c
index 4f24a0f..e84913e 100644
--- a/drivers/gpu/drm/radeon/rs690.c
+++ b/drivers/gpu/drm/radeon/rs690.c
@@ -711,6 +711,16 @@ int rs690_init(struct radeon_device *rdev)
 {
 	int r;
 
+	/* stop possible GPU activities */
+	WREG32(RADEON_CP_CSQ_MODE, 0);
+	WREG32(RADEON_CP_CSQ_CNTL, 0);
+	WREG32(R_000770_SCRATCH_UMSK, 0);
+	WREG32(RADEON_CP_RB_CNTL, RADEON_RB_NO_UPDATE);
+	WREG32(R_000040_GEN_INT_CNTL, 0);
+	WREG32(R_006540_DxMODE_INT_MASK, 0);
+	WREG32(R_007D08_DC_HOT_PLUG_DETECT1_INT_CONTROL, 0);
+	WREG32(R_007D18_DC_HOT_PLUG_DETECT2_INT_CONTROL, 0);
+
 	/* Disable VGA */
 	rv515_vga_render_disable(rdev);
 	/* Initialize scratch registers */
diff --git a/drivers/gpu/drm/radeon/rs690d.h b/drivers/gpu/drm/radeon/rs690d.h
index 36e6398..fa41027 100644
--- a/drivers/gpu/drm/radeon/rs690d.h
+++ b/drivers/gpu/drm/radeon/rs690d.h
@@ -306,5 +306,29 @@
 #define   S_000104_MC_GLOBW_INIT_LAT(x)                (((x) & 0xF) << 28)
 #define   G_000104_MC_GLOBW_INIT_LAT(x)                (((x) >> 28) & 0xF)
 #define   C_000104_MC_GLOBW_INIT_LAT                   0x0FFFFFFF
+#define R_006540_DxMODE_INT_MASK                     0x006540
+#define R_007D08_DC_HOT_PLUG_DETECT1_INT_CONTROL       0x007D08
+#define R_007D18_DC_HOT_PLUG_DETECT2_INT_CONTROL       0x007D18
+#define R_000040_GEN_INT_CNTL                        0x000040
+#define R_000704_CP_RB_CNTL                          0x000704
+#define   S_000704_RB_NO_UPDATE(x)                     (((x) & 0x1) << 27)
+#define R_000740_CP_CSQ_CNTL                         0x000740
+#define   S_000740_CSQ_CNT_PRIMARY(x)                  (((x) & 0xFF) << 0)
+#define   G_000740_CSQ_CNT_PRIMARY(x)                  (((x) >> 0) & 0xFF)
+#define   C_000740_CSQ_CNT_PRIMARY                     0xFFFFFF00
+#define   S_000740_CSQ_CNT_INDIRECT(x)                 (((x) & 0xFF) << 8)
+#define   G_000740_CSQ_CNT_INDIRECT(x)                 (((x) >> 8) & 0xFF)
+#define   C_000740_CSQ_CNT_INDIRECT                    0xFFFF00FF
+#define   S_000740_CSQ_MODE(x)                         (((x) & 0xF) << 28)
+#define   G_000740_CSQ_MODE(x)                         (((x) >> 28) & 0xF)
+#define   C_000740_CSQ_MODE                            0x0FFFFFFF
+#define R_000744_CP_CSQ_MODE                         0x000744
+#define R_000770_SCRATCH_UMSK                        0x000770
+#define   S_000770_SCRATCH_UMSK(x)                     (((x) & 0x3F) << 0)
+#define   G_000770_SCRATCH_UMSK(x)                     (((x) >> 0) & 0x3F)
+#define   C_000770_SCRATCH_UMSK                        0xFFFFFFC0
+#define   S_000770_SCRATCH_SWAP(x)                     (((x) & 0x3) << 16)
+#define   G_000770_SCRATCH_SWAP(x)                     (((x) >> 16) & 0x3)
+#define   C_000770_SCRATCH_SWAP                        0xFFFCFFFF
 
 #endif
diff --git a/drivers/gpu/drm/radeon/rv515.c b/drivers/gpu/drm/radeon/rv515.c
index 880637f..5133d96 100644
--- a/drivers/gpu/drm/radeon/rv515.c
+++ b/drivers/gpu/drm/radeon/rv515.c
@@ -482,6 +482,16 @@ int rv515_init(struct radeon_device *rdev)
 {
 	int r;
 
+	/* stop possible GPU activities */
+	WREG32(R_000740_CP_CSQ_CNTL, 0);
+	WREG32(R_000744_CP_CSQ_MODE, 0);
+	WREG32(R_000770_SCRATCH_UMSK, 0);
+	WREG32(R_000704_CP_RB_CNTL, S_000704_RB_NO_UPDATE(1));
+	WREG32(R_000040_GEN_INT_CNTL, 0);
+	WREG32(R_006540_DxMODE_INT_MASK, 0);
+	WREG32(R_007D08_DC_HOT_PLUG_DETECT1_INT_CONTROL, 0);
+	WREG32(R_007D18_DC_HOT_PLUG_DETECT2_INT_CONTROL, 0);
+
 	/* Initialize scratch registers */
 	radeon_scratch_init(rdev);
 	/* Initialize surface registers */
diff --git a/drivers/gpu/drm/radeon/rv515d.h b/drivers/gpu/drm/radeon/rv515d.h
index 590309a..03cddd2 100644
--- a/drivers/gpu/drm/radeon/rv515d.h
+++ b/drivers/gpu/drm/radeon/rv515d.h
@@ -645,5 +645,29 @@
 #define   S_000013_IDCT_NORMAL_POWER_BUSY(x)           (((x) & 0xFF) << 24)
 #define   G_000013_IDCT_NORMAL_POWER_BUSY(x)           (((x) >> 24) & 0xFF)
 #define   C_000013_IDCT_NORMAL_POWER_BUSY              0x00FFFFFF
+#define R_006540_DxMODE_INT_MASK                     0x006540
+#define R_007D08_DC_HOT_PLUG_DETECT1_INT_CONTROL       0x007D08
+#define R_007D18_DC_HOT_PLUG_DETECT2_INT_CONTROL       0x007D18
+#define R_000040_GEN_INT_CNTL                        0x000040
+#define R_000704_CP_RB_CNTL                          0x000704
+#define   S_000704_RB_NO_UPDATE(x)                     (((x) & 0x1) << 27)
+#define R_000740_CP_CSQ_CNTL                         0x000740
+#define   S_000740_CSQ_CNT_PRIMARY(x)                  (((x) & 0xFF) << 0)
+#define   G_000740_CSQ_CNT_PRIMARY(x)                  (((x) >> 0) & 0xFF)
+#define   C_000740_CSQ_CNT_PRIMARY                     0xFFFFFF00
+#define   S_000740_CSQ_CNT_INDIRECT(x)                 (((x) & 0xFF) << 8)
+#define   G_000740_CSQ_CNT_INDIRECT(x)                 (((x) >> 8) & 0xFF)
+#define   C_000740_CSQ_CNT_INDIRECT                    0xFFFF00FF
+#define   S_000740_CSQ_MODE(x)                         (((x) & 0xF) << 28)
+#define   G_000740_CSQ_MODE(x)                         (((x) >> 28) & 0xF)
+#define   C_000740_CSQ_MODE                            0x0FFFFFFF
+#define R_000744_CP_CSQ_MODE                         0x000744
+#define R_000770_SCRATCH_UMSK                        0x000770
+#define   S_000770_SCRATCH_UMSK(x)                     (((x) & 0x3F) << 0)
+#define   G_000770_SCRATCH_UMSK(x)                     (((x) >> 0) & 0x3F)
+#define   C_000770_SCRATCH_UMSK                        0xFFFFFFC0
+#define   S_000770_SCRATCH_SWAP(x)                     (((x) & 0x3) << 16)
+#define   G_000770_SCRATCH_SWAP(x)                     (((x) >> 16) & 0x3)
+#define   C_000770_SCRATCH_SWAP                        0xFFFCFFFF
 
 #endif
diff --git a/drivers/gpu/drm/radeon/rv770.c b/drivers/gpu/drm/radeon/rv770.c
index a1668b6..7f8500b 100644
--- a/drivers/gpu/drm/radeon/rv770.c
+++ b/drivers/gpu/drm/radeon/rv770.c
@@ -1177,6 +1177,13 @@ int rv770_init(struct radeon_device *rdev)
 {
 	int r;
 
+	/* stop possible GPU activities */
+	WREG32(IH_RB_CNTL, 0);
+	WREG32(IH_CNTL, 0);
+	WREG32(CP_ME_CNTL, CP_ME_HALT | CP_PFP_HALT);
+	WREG32(SCRATCH_UMSK, 0);
+	WREG32(CP_RB_CNTL, RB_NO_UPDATE);
+
 	/* This don't do much */
 	r = radeon_gem_init(rdev);
 	if (r)
diff --git a/drivers/gpu/drm/radeon/rv770d.h b/drivers/gpu/drm/radeon/rv770d.h
index 79fa588..03bed2d 100644
--- a/drivers/gpu/drm/radeon/rv770d.h
+++ b/drivers/gpu/drm/radeon/rv770d.h
@@ -38,6 +38,26 @@
 #define R7XX_MAX_PIPES             8
 #define R7XX_MAX_PIPES_MASK        0xff
 
+
+#define IH_RB_CNTL                                        0x3e00
+#       define IH_RB_ENABLE                               (1 << 0)
+#       define IH_IB_SIZE(x)                              ((x) << 1) /* log2 */
+#       define IH_RB_FULL_DRAIN_ENABLE                    (1 << 6)
+#       define IH_WPTR_WRITEBACK_ENABLE                   (1 << 8)
+#       define IH_WPTR_WRITEBACK_TIMER(x)                 ((x) << 9) /* log2 */
+#       define IH_WPTR_OVERFLOW_ENABLE                    (1 << 16)
+#       define IH_WPTR_OVERFLOW_CLEAR                     (1 << 31)
+#define IH_CNTL                                           0x3e18
+#       define ENABLE_INTR                                (1 << 0)
+#       define IH_MC_SWAP(x)                              ((x) << 1)
+#       define IH_MC_SWAP_NONE                            0
+#       define IH_MC_SWAP_16BIT                           1
+#       define IH_MC_SWAP_32BIT                           2
+#       define IH_MC_SWAP_64BIT                           3
+#       define RPTR_REARM                                 (1 << 4)
+#       define MC_WRREQ_CREDIT(x)                         ((x) << 15)
+#       define MC_WR_CLEAN_CNT(x)                         ((x) << 20)
+
 /* Registers */
 #define	CB_COLOR0_BASE					0x28040
 #define	CB_COLOR1_BASE					0x28044
-- 
1.7.7.1


--G4iJoqBmSsgzjUCe--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
