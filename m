From: David VomLehn <dvomlehn@cisco.com>
Subject: [PATCH][RFC] Infrastructure for out-of-band parameter passing
Date: Mon, 7 Jun 2010 17:30:49 -0700
Message-ID: <20100608003049.GA29350@dvomlehn-lnx2.corp.sa.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: to@dvomlehn-lnx2.corp.sa.net, "netdev@vger.kernel.org"@cisco.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-3.cisco.com ([171.71.176.72]:56263 "EHLO
	sj-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752131Ab0FHAat (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jun 2010 20:30:49 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Infrastructure to support out of band/indirect passing of data to functions.

It is useful at times to be able to pass data from one function to another
nested many stack frames more deeply than the passing function. Doing so
allows the interfaces in the intervening functions to be simpler, though
this "hidden" information passing risks increased complexity. In cases
where this is justified, this simple infrastructure provides the
functionality.

Out of band data passing is implemented by adding, for each instance,
an element to the task_struct that serves as the pointer to the top
of a OOB parameter stack. Data is made available by being pushed
on the OOB parameter stack by a function, and accessed via the top
element of the OOB parameter stack.

Signed-off-by: David VomLehn (dvomlehn@cisco.com)
---
 include/linux/oobparam.h |   89 ++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 89 insertions(+), 0 deletions(-)

diff --git a/include/linux/oobparam.h b/include/linux/oobparam.h
new file mode 100644
index 0000000..6eaa04c
--- /dev/null
+++ b/include/linux/oobparam.h
@@ -0,0 +1,89 @@
+/*
+ * Definitions used to pass information across multiple stack frames
+ * within a single task.
+ *
+ * Copyright (C) 2010  Cisco Systems, Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
+ *
+ * Author: David VomLehn
+ *
+ * These definitions allow one function to establish a context for another
+ * function without adding parameters to the intervening functions. It can,
+ * for example, supply state information from one function to be used in the
+ * case that some function nested several levels more deeply wants to report
+ * the context from the original function. Since it works in a way invisible
+ * to the intervening functions, passing information this way is less
+ * obvious than simply supplying parameters and it should be used sparingly.
+ *
+ * To use this:
+ * 1.	Define a structure containing a struct oobparam:
+ *		struct ctx {
+ *			const char *name;
+ *			OOBPARAM_FRAME(frame);
+ *			...
+ *		};
+ * 2.	Create an element in the task_struct to serve as the top of the
+ *	oobparam stack:
+ *		OOBPARAM_TOP(my_top);
+ * 3.	Populate the structure in the function that has context to be passed.
+ *		struct ctx ctx;
+ *		ctx.name = __func__;
+ * 4.	Surround the call to the next function with oobparam_push() and
+ *	oobparam_pop():
+ *		oobparam_push(&ctx.frame);
+ *		myfunc();
+ *		oobparam_pop(&ctx.frame);
+ * 5.	In function that wants to use the parameter value, use OOBPARAM_CUR
+ *	to retrieve the value:
+ *		struct ctx *ctx;
+ *		ctx = OOBPARAM_CUR(&my_top, struct ctx, frame);
+ *		pr_info("Indirectly called by %s\n", ctx->name);
+ */
+
+#ifndef	_LINUX_OOBPARAM_H_
+#define _LINUX_OOBPARAM_H_
+
+struct oobparam {
+	struct oobparam *next;
+};
+
+#define OOBPARAM_TOP(name)	struct oobparam name;
+#define OOBPARAM_FRAME(name)	struct oobparam name;
+
+/**
+ * oobparam_push - push an out of band parameter frame on the OOB param stack
+ * @head	Pointer to the OOB parameter stack top, which must be in the
+ *		task structure.
+ * @frame	Pointer to the OOB parameter frame, generally embedded in
+ *		another structure
+ */
+static inline void oobparam_push(struct oobparam *top, struct oobparam *frame)
+{
+	frame->next = top;
+	/* We need to ensure that the pointer in the frame is set prior to
+	 * the pointer to the top in case we handle an interrupt in between
+	 * the two stores. */
+	wmb();
+	top->next = frame;
+}
+
+static inline void oobparam_pop(struct oobparam *top)
+{
+	top->next = top->next->next;
+}
+
+#define OOBPARAM_CUR(top, type, frame) container_of((top)->next, type, frame)
+#endif
