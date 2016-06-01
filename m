From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [RFC 01/12] add basic register-field manipulation macros
Date: Wed,  1 Jun 2016 17:50:03 +0100
Message-ID: <1464799814-4453-2-git-send-email-jakub.kicinski@netronome.com>
References: <1464799814-4453-1-git-send-email-jakub.kicinski@netronome.com>
Cc: ast@kernel.org, daniel@iogearbox.net,
	dinan.gunawardena@netronome.com,
	Jakub Kicinski <jakub.kicinski@netronome.com>,
	Ivo van Doorn <IvDoorn@gmail.com>,
	Felix Fietkau <nbd@openwrt.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:37699 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753052AbcFAQvo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 12:51:44 -0400
Received: by mail-wm0-f49.google.com with SMTP id z87so37551007wmh.0
        for <netdev@vger.kernel.org>; Wed, 01 Jun 2016 09:51:43 -0700 (PDT)
In-Reply-To: <1464799814-4453-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

C bitfields are problematic and best avoided.  Developers
interacting with hardware registers find themselves searching
for easy-to-use alternatives.  Common approach is to define
structures or sets of macros containing mask and shift pair.
Operation on the register are then performed as follows:

 field = (reg >> shift) & mask;

 reg &= ~(mask << shift);
 reg |= (field & mask) << shift;

Defining shift and mask separately is tedious.  Ivo van Doorn
came up with an idea of computing them at compilation time
based on a single shifted mask (later refined by Felix) which
can be used like this:

 field = FIELD_GET(REG_FIELD, reg);

 reg &= ~REG_FIELD;
 reg |= FIELD_PUT(REG_FIELD, field);

FIELD_{GET,PUT} macros take care of finding out what the
appropriate shift is based on compilation time ffs operation.

GENMASK can be used to define registers (which is usually
less error-prone and easier to match with datasheets).

This approach is the most convenient I've seen so to limit code
multiplication let's move the macros to a global header file.

Compared to Felix Fietkau's version I:
 - edited the comments a bit;
 - gave auxiliary macros _bf_ prefix;
 - dropped the UL specifier from 1 in _bf_low_bits,
 - renamed the FIELD_SET to FIELD_PUT;
 - added 64bit versions.

CC: Ivo van Doorn <IvDoorn@gmail.com>
CC: Felix Fietkau <nbd@openwrt.org>
Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Dinan Gunawardena <dgunawardena@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 include/linux/bitfield.h | 89 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 89 insertions(+)
 create mode 100644 include/linux/bitfield.h

diff --git a/include/linux/bitfield.h b/include/linux/bitfield.h
new file mode 100644
index 000000000000..3815c81f5b10
--- /dev/null
+++ b/include/linux/bitfield.h
@@ -0,0 +1,89 @@
+/*
+ * Copyright (C) 2014 Felix Fietkau <nbd@openwrt.org>
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
+#include <asm/types.h>
+
+/*
+ * Macros to find first set bit in a variable.
+ * These macros behave the same as the __ffs() functions but the most important
+ * difference that this is done during compile-time rather than run-time.
+ */
+#define compile_ffs2(__x) \
+	__builtin_choose_expr(((__x) & 0x1), 0, 1)
+
+#define compile_ffs4(__x) \
+	__builtin_choose_expr(((__x) & 0x3), \
+			      (compile_ffs2((__x))), \
+			      (compile_ffs2((__x) >> 2) + 2))
+
+#define compile_ffs8(__x) \
+	__builtin_choose_expr(((__x) & 0xf), \
+			      (compile_ffs4((__x))), \
+			      (compile_ffs4((__x) >> 4) + 4))
+
+#define compile_ffs16(__x) \
+	__builtin_choose_expr(((__x) & 0xff), \
+			      (compile_ffs8((__x))), \
+			      (compile_ffs8((__x) >> 8) + 8))
+
+#define compile_ffs32(__x) \
+	__builtin_choose_expr(((__x) & 0xffff), \
+			      (compile_ffs16((__x))), \
+			      (compile_ffs16((__x) >> 16) + 16))
+
+#define compile_ffs64(__x) \
+	__builtin_choose_expr(((__x) & 0xffffffff), \
+			      (compile_ffs32((__x))), \
+			      (compile_ffs32(((__x) >> 16) >> 16) + 32))
+
+/*
+ * Macros to validate that the mask given contains a contiguous set of bits.
+ * Note that we cannot use the is_power_of_2() function since this check
+ * must be done at compile-time.
+ */
+#define _bf_is_power_of_two(x)	( !((x) & ((x) - 1)) )
+#define _bf_low_bits(x)		( ((x) - 1) & ~(x) )
+#define _bf_is_valid_mask(x)	_bf_is_power_of_two(1U + (x) + _bf_low_bits(x))
+
+#define _BF_FIELD_CHECK(_mask)						\
+	BUILD_BUG_ON(!(_mask) || !_bf_is_valid_mask(_mask))
+
+#define FIELD_PUT(_mask, _val)						\
+	({								\
+		_BF_FIELD_CHECK(_mask);					\
+		(((u32)(_val)) << compile_ffs32(_mask)) & _mask;	\
+	})
+
+#define FIELD_GET(_mask, _val)						\
+	({								\
+		_BF_FIELD_CHECK(_mask);					\
+		(u32)(((_val) & _mask) >> compile_ffs32(_mask));	\
+	})
+
+#define FIELD_PUT64(_mask, _val)					\
+	({								\
+		_BF_FIELD_CHECK(_mask);					\
+		(((u64)(_val)) << compile_ffs64(_mask)) & _mask;	\
+	})
+
+#define FIELD_GET64(_mask, _val)					\
+	({								\
+		_BF_FIELD_CHECK(_mask);					\
+		(u64)(((_val) & _mask) >> compile_ffs64(_mask));	\
+	})
+
+#endif
-- 
1.9.1
