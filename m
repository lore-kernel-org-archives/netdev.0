From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: WARNING: at mm/slub.c:3357, kernel BUG at mm/slub.c:3413
Date: Mon, 5 Dec 2011 15:20:57 -0500
Message-ID: <20111205202057.GD4342@homer.localdomain>
References: <20111203092845.GA1520@x4.trippels.de>
 <CAPM=9tyjZc9waC_ZBygW9zh+Zq-Wb1X5Y6yfsCCMPYwpFVWOOg@mail.gmail.com>
 <20111203122900.GA1617@x4.trippels.de>
 <CAH3drwZDOpPuQ_G=LwTiNsR5BNyJTNr+VJU74E6nS5AbKyQH0A@mail.gmail.com>
 <20111204010200.GA1530@x4.trippels.de>
 <20111205171046.GA4342@homer.localdomain>
 <20111205181549.GA1612@x4.trippels.de>
 <20111205191116.GB4342@homer.localdomain>
 <20111205192701.GA1531@x4.trippels.de>
 <CAOJsxLGCrNZnxZ70vpRGZ35GMK4MPDc4r6S=KTngQuL0eED94w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="TYecfFk8j8mZq+dy"
Cc: Markus Trippelsdorf <markus@trippelsdorf.de>,
	Dave Airlie <airlied@gmail.com>, Christoph Lameter <cl@linux.com>,
	"Alex, Shi" <alex.shi@intel.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	dri-devel@lists.freedesktop.org,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	Matt Mackall <mpm@selenic.com>, tj@kernel.org,
	Alex Deucher <alexander.deucher@amd.com>
To: Pekka Enberg <penberg@kernel.org>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <CAOJsxLGCrNZnxZ70vpRGZ35GMK4MPDc4r6S=KTngQuL0eED94w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org


--TYecfFk8j8mZq+dy
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Dec 05, 2011 at 10:10:34PM +0200, Pekka Enberg wrote:
> On Mon, Dec 5, 2011 at 9:27 PM, Markus Trippelsdorf
> <markus@trippelsdorf.de> wrote:
> >> > Yes the patch finally fixes the issue for me (tested with 120 kexec
> >> > iterations).
> >> > Thanks Jerome!
> >>
> >> Can you do a kick run on the modified patch ?
> >
> > This one is also OK after ~60 iterations.
> 
> Jerome, could you please include a reference to this LKML thread for
> context and attribution for Markus for reporting and following up to
> get the issue fixed in the changelog?
> 
>                               Pekka

Attached updated patch, only changelog is different. Thanks Markus for
testing this.

Cheers,
Jerome

--TYecfFk8j8mZq+dy
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="0001-drm-radeon-disable-possible-GPU-writeback-early-v3.patch"

>From cccfa6f93faa6b556fd72e318606a01e333e67d3 Mon Sep 17 00:00:00 2001
From: Jerome Glisse <jglisse@redhat.com>
Date: Mon, 5 Dec 2011 12:02:17 -0500
Subject: [PATCH] drm/radeon: disable possible GPU writeback early v3

Given how kexec works we need to disable any kind of GPU writeback
early in GPU initialization just in case some are still active from
previous setup. This patch is done to fix the issue described in
the lkml thread :

WARNING: at mm/slub.c:3357, kernel BUG at mm/slub.c:3413

https://lkml.org/lkml/2011/12/5/466

Thanks to Markus Trippelsdorf for testing this.

v2 follow previous sanity work done on earlier radeon, also write
reg uncondionaly and disable irq too.
v3 update change log

Signed-off-by: Jerome Glisse <jglisse@redhat.com>
Tested-by: Markus Trippelsdorf <markus@trippelsdorf.de>
---
 drivers/gpu/drm/radeon/evergreen.c   |    2 ++
 drivers/gpu/drm/radeon/ni.c          |   18 ++++++++++++++++++
 drivers/gpu/drm/radeon/nid.h         |   19 +++++++++++++++++++
 drivers/gpu/drm/radeon/r100.c        |   20 ++++++--------------
 drivers/gpu/drm/radeon/r520.c        |    2 +-
 drivers/gpu/drm/radeon/r600.c        |   16 ++++++++++++++++
 drivers/gpu/drm/radeon/radeon_asic.h |    2 ++
 drivers/gpu/drm/radeon/rs600.c       |   20 +++++++++++++++++++-
 drivers/gpu/drm/radeon/rs600d.h      |   21 +++++++++++++++++++++
 drivers/gpu/drm/radeon/rs690.c       |    2 +-
 drivers/gpu/drm/radeon/rv515.c       |    2 +-
 drivers/gpu/drm/radeon/rv770.c       |   16 ++++++++++++++++
 drivers/gpu/drm/radeon/rv770d.h      |   20 ++++++++++++++++++++
 13 files changed, 142 insertions(+), 18 deletions(-)

diff --git a/drivers/gpu/drm/radeon/evergreen.c b/drivers/gpu/drm/radeon/evergreen.c
index 1934728..6109579 100644
--- a/drivers/gpu/drm/radeon/evergreen.c
+++ b/drivers/gpu/drm/radeon/evergreen.c
@@ -3249,6 +3249,8 @@ int evergreen_init(struct radeon_device *rdev)
 {
 	int r;
 
+	/* restore some register to sane defaults */
+	rv770_restore_sanity(rdev);
 	/* This don't do much */
 	r = radeon_gem_init(rdev);
 	if (r)
diff --git a/drivers/gpu/drm/radeon/ni.c b/drivers/gpu/drm/radeon/ni.c
index c15fc8b..f5d7054 100644
--- a/drivers/gpu/drm/radeon/ni.c
+++ b/drivers/gpu/drm/radeon/ni.c
@@ -1566,6 +1566,22 @@ int cayman_suspend(struct radeon_device *rdev)
 	return 0;
 }
 
+/*
+ * Due to how kexec works, it can leave the hw fully initialised when it
+ * boots the new kernel.
+ */
+static void cayman_restore_sanity(struct radeon_device *rdev)
+{
+	/* stop possible GPU activities */
+	WREG32(IH_RB_CNTL, 0);
+	WREG32(IH_CNTL, 0);
+	WREG32(CP_ME_CNTL, CP_ME_HALT | CP_PFP_HALT);
+	WREG32(SCRATCH_UMSK, 0);
+	WREG32(CP_RB0_CNTL, RB_NO_UPDATE);
+	WREG32(CP_RB1_CNTL, RB_NO_UPDATE);
+	WREG32(CP_RB2_CNTL, RB_NO_UPDATE);
+}
+
 /* Plan is to move initialization in that function and use
  * helper function so that radeon_device_init pretty much
  * do nothing more than calling asic specific function. This
@@ -1577,6 +1593,8 @@ int cayman_init(struct radeon_device *rdev)
 	struct radeon_ring *ring = &rdev->ring[RADEON_RING_TYPE_GFX_INDEX];
 	int r;
 
+	/* restore some register to sane defaults */
+	cayman_restore_sanity(rdev);
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
index 657040b..d58531f 100644
--- a/drivers/gpu/drm/radeon/r100.c
+++ b/drivers/gpu/drm/radeon/r100.c
@@ -3990,20 +3990,12 @@ void r100_fini(struct radeon_device *rdev)
  */
 void r100_restore_sanity(struct radeon_device *rdev)
 {
-	u32 tmp;
-
-	tmp = RREG32(RADEON_CP_CSQ_CNTL);
-	if (tmp) {
-		WREG32(RADEON_CP_CSQ_CNTL, 0);
-	}
-	tmp = RREG32(RADEON_CP_RB_CNTL);
-	if (tmp) {
-		WREG32(RADEON_CP_RB_CNTL, 0);
-	}
-	tmp = RREG32(RADEON_SCRATCH_UMSK);
-	if (tmp) {
-		WREG32(RADEON_SCRATCH_UMSK, 0);
-	}
+	/* stop possible GPU activities */
+	WREG32(RADEON_CP_CSQ_MODE, 0);
+	WREG32(RADEON_CP_CSQ_CNTL, 0);
+	WREG32(R_000770_SCRATCH_UMSK, 0);
+	WREG32(RADEON_CP_RB_CNTL, RADEON_RB_NO_UPDATE);
+	WREG32(RADEON_GEN_INT_CNTL, 0);
 }
 
 int r100_init(struct radeon_device *rdev)
diff --git a/drivers/gpu/drm/radeon/r520.c b/drivers/gpu/drm/radeon/r520.c
index 4ae1615..71a984b 100644
--- a/drivers/gpu/drm/radeon/r520.c
+++ b/drivers/gpu/drm/radeon/r520.c
@@ -249,7 +249,7 @@ int r520_init(struct radeon_device *rdev)
 	/* Initialize surface registers */
 	radeon_surface_init(rdev);
 	/* restore some register to sane defaults */
-	r100_restore_sanity(rdev);
+	rs600_restore_sanity(rdev);
 	/* TODO: disable VGA need to use VGA request */
 	/* BIOS*/
 	if (!radeon_get_bios(rdev)) {
diff --git a/drivers/gpu/drm/radeon/r600.c b/drivers/gpu/drm/radeon/r600.c
index 951566f..ec437d5 100644
--- a/drivers/gpu/drm/radeon/r600.c
+++ b/drivers/gpu/drm/radeon/r600.c
@@ -2556,6 +2556,20 @@ int r600_suspend(struct radeon_device *rdev)
 	return 0;
 }
 
+/*
+ * Due to how kexec works, it can leave the hw fully initialised when it
+ * boots the new kernel.
+ */
+static void r600_restore_sanity(struct radeon_device *rdev)
+{
+	/* stop possible GPU activities */
+	WREG32(IH_RB_CNTL, 0);
+	WREG32(IH_CNTL, 0);
+	WREG32(R_0086D8_CP_ME_CNTL, S_0086D8_CP_ME_HALT(1));
+	WREG32(SCRATCH_UMSK, 0);
+	WREG32(CP_RB_CNTL, RB_NO_UPDATE);
+}
+
 /* Plan is to move initialization in that function and use
  * helper function so that radeon_device_init pretty much
  * do nothing more than calling asic specific function. This
@@ -2566,6 +2580,8 @@ int r600_init(struct radeon_device *rdev)
 {
 	int r;
 
+	/* restore some register to sane defaults */
+	r600_restore_sanity(rdev);
 	if (r600_debugfs_mc_info_init(rdev)) {
 		DRM_ERROR("Failed to register debugfs file for mc !\n");
 	}
diff --git a/drivers/gpu/drm/radeon/radeon_asic.h b/drivers/gpu/drm/radeon/radeon_asic.h
index 6304aef..6b664b0 100644
--- a/drivers/gpu/drm/radeon/radeon_asic.h
+++ b/drivers/gpu/drm/radeon/radeon_asic.h
@@ -215,6 +215,7 @@ extern int rs600_init(struct radeon_device *rdev);
 extern void rs600_fini(struct radeon_device *rdev);
 extern int rs600_suspend(struct radeon_device *rdev);
 extern int rs600_resume(struct radeon_device *rdev);
+void rs600_restore_sanity(struct radeon_device *rdev);
 int rs600_irq_set(struct radeon_device *rdev);
 int rs600_irq_process(struct radeon_device *rdev);
 void rs600_irq_disable(struct radeon_device *rdev);
@@ -388,6 +389,7 @@ u32 rv770_page_flip(struct radeon_device *rdev, int crtc, u64 crtc_base);
 void r700_vram_gtt_location(struct radeon_device *rdev, struct radeon_mc *mc);
 void r700_cp_stop(struct radeon_device *rdev);
 void r700_cp_fini(struct radeon_device *rdev);
+void rv770_restore_sanity(struct radeon_device *rdev);
 
 /*
  * evergreen
diff --git a/drivers/gpu/drm/radeon/rs600.c b/drivers/gpu/drm/radeon/rs600.c
index ca6d5b6..fc3c707 100644
--- a/drivers/gpu/drm/radeon/rs600.c
+++ b/drivers/gpu/drm/radeon/rs600.c
@@ -935,6 +935,24 @@ void rs600_fini(struct radeon_device *rdev)
 	rdev->bios = NULL;
 }
 
+
+/*
+ * Due to how kexec works, it can leave the hw fully initialised when it
+ * boots the new kernel.
+ */
+void rs600_restore_sanity(struct radeon_device *rdev)
+{
+	/* stop possible GPU activities */
+	WREG32(R_000740_CP_CSQ_CNTL, 0);
+	WREG32(R_000744_CP_CSQ_MODE, 0);
+	WREG32(R_000770_SCRATCH_UMSK, 0);
+	WREG32(R_000704_CP_RB_CNTL, S_000704_RB_NO_UPDATE(1));
+	WREG32(R_000040_GEN_INT_CNTL, 0);
+	WREG32(R_006540_DxMODE_INT_MASK, 0);
+	WREG32(R_007D08_DC_HOT_PLUG_DETECT1_INT_CONTROL, 0);
+	WREG32(R_007D18_DC_HOT_PLUG_DETECT2_INT_CONTROL, 0);
+}
+
 int rs600_init(struct radeon_device *rdev)
 {
 	int r;
@@ -946,7 +964,7 @@ int rs600_init(struct radeon_device *rdev)
 	/* Initialize surface registers */
 	radeon_surface_init(rdev);
 	/* restore some register to sane defaults */
-	r100_restore_sanity(rdev);
+	rs600_restore_sanity(rdev);
 	/* BIOS */
 	if (!radeon_get_bios(rdev)) {
 		if (ASIC_IS_AVIVO(rdev))
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
index 4f24a0f..8a3b1f4 100644
--- a/drivers/gpu/drm/radeon/rs690.c
+++ b/drivers/gpu/drm/radeon/rs690.c
@@ -718,7 +718,7 @@ int rs690_init(struct radeon_device *rdev)
 	/* Initialize surface registers */
 	radeon_surface_init(rdev);
 	/* restore some register to sane defaults */
-	r100_restore_sanity(rdev);
+	rs600_restore_sanity(rdev);
 	/* TODO: disable VGA need to use VGA request */
 	/* BIOS*/
 	if (!radeon_get_bios(rdev)) {
diff --git a/drivers/gpu/drm/radeon/rv515.c b/drivers/gpu/drm/radeon/rv515.c
index 880637f..c9ced40 100644
--- a/drivers/gpu/drm/radeon/rv515.c
+++ b/drivers/gpu/drm/radeon/rv515.c
@@ -488,7 +488,7 @@ int rv515_init(struct radeon_device *rdev)
 	radeon_surface_init(rdev);
 	/* TODO: disable VGA need to use VGA request */
 	/* restore some register to sane defaults */
-	r100_restore_sanity(rdev);
+	rs600_restore_sanity(rdev);
 	/* BIOS*/
 	if (!radeon_get_bios(rdev)) {
 		if (ASIC_IS_AVIVO(rdev))
diff --git a/drivers/gpu/drm/radeon/rv770.c b/drivers/gpu/drm/radeon/rv770.c
index a1668b6..3d0397d 100644
--- a/drivers/gpu/drm/radeon/rv770.c
+++ b/drivers/gpu/drm/radeon/rv770.c
@@ -1167,6 +1167,20 @@ int rv770_suspend(struct radeon_device *rdev)
 	return 0;
 }
 
+/*
+ * Due to how kexec works, it can leave the hw fully initialised when it
+ * boots the new kernel.
+ */
+void rv770_restore_sanity(struct radeon_device *rdev)
+{
+	/* stop possible GPU activities */
+	WREG32(IH_RB_CNTL, 0);
+	WREG32(IH_CNTL, 0);
+	WREG32(CP_ME_CNTL, CP_ME_HALT | CP_PFP_HALT);
+	WREG32(SCRATCH_UMSK, 0);
+	WREG32(CP_RB_CNTL, RB_NO_UPDATE);
+}
+
 /* Plan is to move initialization in that function and use
  * helper function so that radeon_device_init pretty much
  * do nothing more than calling asic specific function. This
@@ -1177,6 +1191,8 @@ int rv770_init(struct radeon_device *rdev)
 {
 	int r;
 
+	/* restore some register to sane defaults */
+	rv770_restore_sanity(rdev);
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


--TYecfFk8j8mZq+dy--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
