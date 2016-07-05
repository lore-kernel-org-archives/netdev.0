From: Jakub Kicinski <jakub.kicinski-wFxRvT7yatFl57MIdRCFDg@public.gmane.org>
Subject: [PATCHv4 wl-drv-next 1/2] add basic register-field manipulation macros
Date: Tue,  5 Jul 2016 12:42:58 +0100
Message-ID: <1467718979-20029-2-git-send-email-jakub.kicinski@netronome.com>
References: <1467718979-20029-1-git-send-email-jakub.kicinski@netronome.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org, nbd-Vt+b4OUoWG0@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Jakub Kicinski <jakub.kicinski-wFxRvT7yatFl57MIdRCFDg@public.gmane.org>
To: kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1467718979-20029-1-git-send-email-jakub.kicinski-wFxRvT7yatFl57MIdRCFDg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

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
 reg |= FIELD_PUT(REG_FIELD, field);

FIELD_{GET,PUT} macros take care of finding out what the
appropriate shift is based on compilation time ffs operation.

GENMASK can be used to define registers (which is usually
less error-prone and easier to match with datasheets).

This approach is the most convenient I've seen so to limit code
multiplication let's move the macros to a global header file.

Signed-off-by: Jakub Kicinski <jakub.kicinski-wFxRvT7yatFl57MIdRCFDg@public.gmane.org>
---
 include/linux/bitfield.h | 109 +++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/bug.h      |   3 ++
 2 files changed, 112 insertions(+)
 create mode 100644 include/linux/bitfield.h

diff --git a/include/linux/bitfield.h b/include/linux/bitfield.h
new file mode 100644
index 000000000000..ff9fd0af2ac7
--- /dev/null
+++ b/include/linux/bitfield.h
@@ -0,0 +1,109 @@
+/*
+ * Copyright (C) 2014 Felix Fietkau <nbd-Vt+b4OUoWG0@public.gmane.org>
+ * Copyright (C) 2004 - 2009 Ivo van Doorn <IvDoorn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
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
+#include <asm/types.h>
+#include <linux/bug.h>
+
+#define _bf_shf(x) (__builtin_ffsll(x) - 1)
+
+#define _BF_FIELD_CHECK(_mask, _val)					\
+	({								\
+		BUILD_BUG_ON(!(_mask));					\
+		BUILD_BUG_ON(__builtin_constant_p(_val) ?		\
+			     ~((_mask) >> _bf_shf(_mask)) & (_val) :	\
+			     0);					\
+		__BUILD_BUG_ON_NOT_POWER_OF_2((_mask) +			\
+					      (1ULL << _bf_shf(_mask))); \
+	})
+
+/*
+ * Bitfield access macros
+ *
+ * This file contains macros which take as input shifted mask
+ * from which they extract the base mask and shift amount at
+ * compilation time.  There are two separate sets of the macros
+ * one for 32bit registers and one for 64bit ones.
+ *
+ * Fields can be defined using GENMASK (which is usually
+ * less error-prone and easier to match with datasheets).
+ *
+ * FIELD_{GET,PUT} macros are designed to be used with masks which
+ * are compilation time constants.
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
+ *  reg = FIELD_PUT(REG_FIELD_A, 1) |
+ *	  FIELD_PUT(REG_FIELD_B, 0) |
+ *	  FIELD_PUT(REG_FIELD_C, c) |
+ *	  FIELD_PUT(REG_FIELD_D, 0x40);
+ *
+ * Modify:
+ *  reg &= ~REG_FIELD_C;
+ *  reg |= FIELD_PUT(REG_FIELD_C, c);
+ */
+
+/**
+ * FIELD_PUT() - construct a bitfield element
+ * @_mask: shifted mask defining the field's length and position
+ * @_val:  value to put in the field
+ *
+ * FIELD_PUT() masks and shifts up the value.  The result should
+ * be combined with other fields of the bitfield using logical OR.
+ */
+#define FIELD_PUT(_mask, _val)					\
+	({							\
+		_BF_FIELD_CHECK(_mask, _val);			\
+		((u32)(_val) << _bf_shf(_mask)) & (_mask);	\
+	})
+
+/**
+ * FIELD_GET() - extract a bitfield element
+ * @_mask: shifted mask defining the field's length and position
+ * @_val:  32bit value of entire bitfield
+ *
+ * FIELD_GET() extracts the field specified by @_mask from the
+ * bitfield passed in as @_val.
+ */
+#define FIELD_GET(_mask, _val)					\
+	({							\
+		_BF_FIELD_CHECK(_mask, 0);			\
+		(u32)(((_val) & (_mask)) >> _bf_shf(_mask));	\
+	})
+
+#define FIELD_PUT64(_mask, _val)				\
+	({							\
+		_BF_FIELD_CHECK(_mask, _val);			\
+		((u64)(_val) << _bf_shf(_mask)) & (_mask);	\
+	})
+
+#define FIELD_GET64(_mask, _val)				\
+	({							\
+		_BF_FIELD_CHECK(_mask, 0);			\
+		(u64)(((_val) & (_mask)) >> _bf_shf(_mask));	\
+	})
+
+#endif
diff --git a/include/linux/bug.h b/include/linux/bug.h
index e51b0709e78d..bba5bdae1681 100644
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
+#define __BUILD_BUG_ON_NOT_POWER_OF_2(n) 			\
+	BUILD_BUG_ON(((n) & ((n) - 1)) != 0)
 #define BUILD_BUG_ON_NOT_POWER_OF_2(n)			\
 	BUILD_BUG_ON((n) == 0 || (((n) & ((n) - 1)) != 0))
 
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
