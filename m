From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [RFCv2 01/16] add basic register-field manipulation macros
Date: Fri, 26 Aug 2016 19:06:00 +0100
Message-ID: <1472234775-29453-2-git-send-email-jakub.kicinski@netronome.com>
References: <1472234775-29453-1-git-send-email-jakub.kicinski@netronome.com>
Cc: ast@kernel.org, daniel@iogearbox.net,
        dinan.gunawardena@netronome.com, jiri@resnulli.us,
        john.fastabend@gmail.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:36705 "EHLO
        mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753168AbcHZSPi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2016 14:15:38 -0400
Received: by mail-wm0-f51.google.com with SMTP id q128so2995085wma.1
        for <netdev@vger.kernel.org>; Fri, 26 Aug 2016 11:15:25 -0700 (PDT)
In-Reply-To: <1472234775-29453-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Common approach to accessing register fields is to define
structures or sets of macros containing mask and shift pair.
Operations on the register are then performed as follows:

 field = (reg >> shift) & mask;

 reg &= ~(mask << shift);
 reg |= (field & mask) << shift;

Defining shift and mask separately is tedious.  Ivo van Doorn
came up with an idea of computing them at compilation time
based on a single shifted mask (later refined by Felix) which
can be used like this:

 #define REG_FIELD 0x000ff000

 field = FIELD_GET(REG_FIELD, reg);

 reg &= ~REG_FIELD;
 reg |= FIELD_PREP(REG_FIELD, field);

FIELD_{GET,PREP} macros take care of finding out what the
appropriate shift is based on compilation time ffs operation.

GENMASK can be used to define registers (which is usually
less error-prone and easier to match with datasheets).

This approach is the most convenient I've seen so to limit code
multiplication let's move the macros to a global header file.
Attempts to use static inlines instead of macros failed due
to false positive triggering of BUILD_BUG_ON()s, especially with
GCC < 6.0.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 include/linux/bitfield.h | 93 ++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/bug.h      |  3 ++
 2 files changed, 96 insertions(+)
 create mode 100644 include/linux/bitfield.h

diff --git a/include/linux/bitfield.h b/include/linux/bitfield.h
new file mode 100644
index 000000000000..32ca8863e66d
--- /dev/null
+++ b/include/linux/bitfield.h
@@ -0,0 +1,93 @@
+/*
+ * Copyright (C) 2014 Felix Fietkau <nbd@nbd.name>
+ * Copyright (C) 2004 - 2009 Ivo van Doorn <IvDoorn@gmail.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+
+#ifndef _LINUX_BITFIELD_H
+#define _LINUX_BITFIELD_H
+
+#include <linux/bug.h>
+
+/*
+ * Bitfield access macros
+ *
+ * FIELD_{GET,PREP} macros take as first parameter shifted mask
+ * from which they extract the base mask and shift amount.
+ * Mask must be a compilation time constant.
+ *
+ * Example:
+ *
+ *  #define REG_FIELD_A  GENMASK(6, 0)
+ *  #define REG_FIELD_B  BIT(7)
+ *  #define REG_FIELD_C  GENMASK(15, 8)
+ *  #define REG_FIELD_D  GENMASK(31, 16)
+ *
+ * Get:
+ *  a = FIELD_GET(REG_FIELD_A, reg);
+ *  b = FIELD_GET(REG_FIELD_B, reg);
+ *
+ * Set:
+ *  reg = FIELD_PREP(REG_FIELD_A, 1) |
+ *	  FIELD_PREP(REG_FIELD_B, 0) |
+ *	  FIELD_PREP(REG_FIELD_C, c) |
+ *	  FIELD_PREP(REG_FIELD_D, 0x40);
+ *
+ * Modify:
+ *  reg &= ~REG_FIELD_C;
+ *  reg |= FIELD_PREP(REG_FIELD_C, c);
+ */
+
+#define _bf_shf(x) (__builtin_ffsll(x) - 1)
+
+#define _BF_FIELD_CHECK(_mask, _reg, _val, _pfx)			\
+	({								\
+		BUILD_BUG_ON_MSG(!__builtin_constant_p(_mask),		\
+				 _pfx "mask is not constant");		\
+		BUILD_BUG_ON_MSG(!(_mask), _pfx "mask is zero");	\
+		BUILD_BUG_ON_MSG(__builtin_constant_p(_val) ?		\
+				 ~((_mask) >> _bf_shf(_mask)) & (_val) : 0, \
+				 _pfx "value too large for the field"); \
+		BUILD_BUG_ON_MSG((_mask) > (typeof(_reg))~0ull,		\
+				 _pfx "type of reg too small for mask"); \
+		__BUILD_BUG_ON_NOT_POWER_OF_2((_mask) +			\
+					      (1ULL << _bf_shf(_mask))); \
+	})
+
+/**
+ * FIELD_PREP() - prepare a bitfield element
+ * @_mask: shifted mask defining the field's length and position
+ * @_val:  value to put in the field
+ *
+ * FIELD_PREP() masks and shifts up the value.  The result should
+ * be combined with other fields of the bitfield using logical OR.
+ */
+#define FIELD_PREP(_mask, _val)						\
+	({								\
+		_BF_FIELD_CHECK(_mask, 0ULL, _val, "FIELD_PREP: ");	\
+		((typeof(_mask))(_val) << _bf_shf(_mask)) & (_mask);	\
+	})
+
+/**
+ * FIELD_GET() - extract a bitfield element
+ * @_mask: shifted mask defining the field's length and position
+ * @_reg:  32bit value of entire bitfield
+ *
+ * FIELD_GET() extracts the field specified by @_mask from the
+ * bitfield passed in as @_reg by masking and shifting it down.
+ */
+#define FIELD_GET(_mask, _reg)						\
+	({								\
+		_BF_FIELD_CHECK(_mask, _reg, 0U, "FIELD_GET: ");	\
+		(typeof(_mask))(((_reg) & (_mask)) >> _bf_shf(_mask));	\
+	})
+
+#endif
diff --git a/include/linux/bug.h b/include/linux/bug.h
index e51b0709e78d..292d6a10b0c2 100644
--- a/include/linux/bug.h
+++ b/include/linux/bug.h
@@ -13,6 +13,7 @@ enum bug_trap_type {
 struct pt_regs;
 
 #ifdef __CHECKER__
+#define __BUILD_BUG_ON_NOT_POWER_OF_2(n) (0)
 #define BUILD_BUG_ON_NOT_POWER_OF_2(n) (0)
 #define BUILD_BUG_ON_ZERO(e) (0)
 #define BUILD_BUG_ON_NULL(e) ((void*)0)
@@ -24,6 +25,8 @@ struct pt_regs;
 #else /* __CHECKER__ */
 
 /* Force a compilation error if a constant expression is not a power of 2 */
+#define __BUILD_BUG_ON_NOT_POWER_OF_2(n)	\
+	BUILD_BUG_ON(((n) & ((n) - 1)) != 0)
 #define BUILD_BUG_ON_NOT_POWER_OF_2(n)			\
 	BUILD_BUG_ON((n) == 0 || (((n) & ((n) - 1)) != 0))
 
-- 
1.9.1
