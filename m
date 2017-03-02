From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 22/26] drm/i915/gvt: don't overflow the kernel stack with KASAN
Date: Thu,  2 Mar 2017 17:38:30 +0100
Message-ID: <20170302163834.2273519-23-arnd@arndb.de>
References: <20170302163834.2273519-1-arnd@arndb.de>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>,
        Alexander Potapenko <glider@google.com>,
        Dmitry Vyukov <dvyukov@google.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-media@vger.kernel.org,
        linux-wireless@vger.kernel.org,
        kernel-build-reports@lists.linaro.org,
        "David S . Miller" <davem@davemloft.net>,
        Arnd Bergmann <arnd@arndb.de>
To: kasan-dev@googlegroups.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170302163834.2273519-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Enabling CONFIG_KASAN can lead to an instant stack overflow:

drivers/gpu/drm/i915/gvt/handlers.c: In function 'init_generic_mmio_info':
drivers/gpu/drm/i915/gvt/handlers.c:2200:1: error: the frame size of 30464 bytes is larger than 3072 bytes [-Werror=frame-larger-than=]
drivers/gpu/drm/i915/gvt/handlers.c: In function 'init_broadwell_mmio_info':
drivers/gpu/drm/i915/gvt/handlers.c:2402:1: error: the frame size of 5376 bytes is larger than 3072 bytes [-Werror=frame-larger-than=]
drivers/gpu/drm/i915/gvt/handlers.c: In function 'init_skl_mmio_info':
drivers/gpu/drm/i915/gvt/handlers.c:2628:1: error: the frame size of 5296 bytes is larger than 3072 bytes [-Werror=frame-larger-than=]

The reason is the INTEL_GVT_MMIO_OFFSET() hack that attempts to convert any type
(including i915_reg_t) into a u32 by reading the first four bytes, in combination
with the stack sanitizer that adds a redzone around each instance.

Originally, i915_reg_t was introduced to add a little extra type safety by
disallowing simple type casts, and INTEL_GVT_MMIO_OFFSET() goes the opposite
way by allowing any type as input, including those that are not safe in this
context.

I'm replacing it with an implementation that specifically allows the three
types that are actually used as input: 'i915_reg_t' (from _MMIO constants),
'int' (from other constants), and 'unsigned int' (from function arguments),
and any other type should now provoke a build error. This also solves the
stack overflow as we no longer use a local variable for each instance.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/gpu/drm/i915/gvt/mmio.h | 17 ++++++++++++-----
 1 file changed, 12 insertions(+), 5 deletions(-)

diff --git a/drivers/gpu/drm/i915/gvt/mmio.h b/drivers/gpu/drm/i915/gvt/mmio.h
index 3bc620f56f35..bf40100fc626 100644
--- a/drivers/gpu/drm/i915/gvt/mmio.h
+++ b/drivers/gpu/drm/i915/gvt/mmio.h
@@ -78,13 +78,20 @@ bool intel_gvt_match_device(struct intel_gvt *gvt, unsigned long device);
 int intel_gvt_setup_mmio_info(struct intel_gvt *gvt);
 void intel_gvt_clean_mmio_info(struct intel_gvt *gvt);
 
+static inline u32 intel_gvt_mmio_offset(unsigned int offset)
+{
+	return offset;
+}
+
 struct intel_gvt_mmio_info *intel_gvt_find_mmio_info(struct intel_gvt *gvt,
 						     unsigned int offset);
-#define INTEL_GVT_MMIO_OFFSET(reg) ({ \
-	typeof(reg) __reg = reg; \
-	u32 *offset = (u32 *)&__reg; \
-	*offset; \
-})
+#define INTEL_GVT_MMIO_OFFSET(reg) \
+__builtin_choose_expr(__builtin_types_compatible_p(typeof(reg), int), intel_gvt_mmio_offset, \
+__builtin_choose_expr(__builtin_types_compatible_p(typeof(reg), unsigned int), intel_gvt_mmio_offset, \
+__builtin_choose_expr(__builtin_types_compatible_p(typeof(reg), i915_reg_t), i915_mmio_reg_offset, \
+	(void)(0) \
+)))(reg)
+
 
 int intel_vgpu_init_mmio(struct intel_vgpu *vgpu);
 void intel_vgpu_reset_mmio(struct intel_vgpu *vgpu);
-- 
2.9.0
