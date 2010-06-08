From: David VomLehn <dvomlehn@cisco.com>
Subject: [PATCH][RFC] Infrastructure for compact call location
	representation
Date: Mon, 7 Jun 2010 17:30:52 -0700
Message-ID: <20100608003052.GA29377@dvomlehn-lnx2.corp.sa.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: to@dvomlehn-lnx2.corp.sa.net, "netdev@vger.kernel.org"@cisco.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-2.cisco.com ([171.71.176.71]:42356 "EHLO
	sj-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752377Ab0FHAax (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jun 2010 20:30:53 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows the location of a call to be recorded as a small integer,
with each call location ("callsite") assigned a new value the first time
the code in that location is executed. Locations can be recorded as a
an address or as a __FILE__/__LINE__ pair. The later is easier to read, but
requires significantly more space.

The goal here was to record the location in very few bits but, at the same
time, to have minimal overhead.  The key observation towards achieving this
goals is to note that there are are far fewer locations where calls of
interest are made than there are addresses. If the site of each call of
interest is assigned a unique ID, and there are fewer than n of them,
only log2(n) bits are required to identify the call site. If the IDs
are assigned dynamically and most call sites aren't reached, you can get
by with even fewer bits.

This is debugging code and callsite IDs are generally only used when failures
are detected, so though the mapping from a callsite location to a callsite ID
must be fast, speed is not as critical for the reverse mapping. Also, an ID
is assigned to a callsite just once, so it is acceptable to take a while to
assign an ID, but things should run with minimal delay if an ID is already
assigned.

The major implementation pieces are:
1.	Two macros are provided for use in wrapping functions that are to
	be instrumented. CALLSITE_CALL is for functions that return values,
	CALLSITE_CALL_VOID is used for functions that do not.
2.	The call site infrastructure consists of three data structures:
	a.	A statically allocated struct callsite_id holds the ID for
		the call site.
	b.	A statically allocated struct callsite_static holds
		information which is constant for each callsite. The call site
		ID could be combined with this, but by separating them I hope
		to avoid polluting the cache with this very cold information.
	c.	A struct callsite_frame builds on the oobparam infrastructure
		and holds the call site ID. This is assigned at this time
		if this had not previously been done. This will be pushed on
		the OOB parameter stack before calling the skb_* function
		and popped after it returns.
3.	A callsite_top structure is added to task_struct. When a call site
	is entered, its callsite_frame is pushed on the call site stack.
4.	When a function needs to know the call site ID so it can be stored,
	it gets it from the callsite_frame at the top of the call site
	stack.

Notes
o	Under simple test conditions, the number of call site IDs allocated
	can be quite small, small enough to fit in 6 bits. That would reduce
	the sk_buff growth to one byte. This is *not* a recommended
	configuration.
o	This is placed in net/core and linux/net since those are the only
	current users, but there is nothing about this that is networking-
	specific.

Restrictions
o	Call site IDs are never reused, so it is possible to exceed the
	maximum number of IDs by having a large number of call locations.
	In addition, it does not recognize that the same module has been
	unloaded and reloaded, so calls from the reloaded module will be
	assigned new IDs. Detection of incorrect operations on an sk_buff
	is not affected by exhaustion of call site IDs, but it may not be
	possible to determine the location of the last operation.
	CONFIG_DEBUG_SKB_ID_SIZE is set to reduce the sk_buff growth to 16
	bits and should handle most cases. It could be made larger to allow
	more call site IDs, if necessary.
o	The callsite structures for a module will be freed when that module
	is unloaded, even though sk_buffs may be using IDs corresponding to
	those call sites. To allow useful error reporting, the call site
	information in a module being unloaded is copied. If
	CONFIG_CALLSITE_TERSE is not enabled and the module that last changed
	the sk_buff is no longer loaded, the address of the call site
	is no longer valid, so only the function name and offset are printed
	if the module is unloaded. If it is loaded, the address is also
	reported.

History
v2	Support small callsite IDs and split out out-of-band parameter
	parsing.
V1	Initial release

Signed-off-by: David VomLehn <dvomlehn@cisco.com>
---
 include/net/callsite-types.h |  160 +++++++++++++++++++
 include/net/callsite.h       |  208 +++++++++++++++++++++++++
 net/core/callsite.c          |  354 ++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 722 insertions(+), 0 deletions(-)

diff --git a/include/net/callsite-types.h b/include/net/callsite-types.h
new file mode 100644
index 0000000..796cfb1
--- /dev/null
+++ b/include/net/callsite-types.h
@@ -0,0 +1,160 @@
+/*
+ *				callsite-types.h
+ *
+ * Definitions for tracking sites at which functions are called with low
+ * overhead.
+ *
+ * Copyright (C) 2009  Scientific-Atlanta, Inc.
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
+ */
+
+#ifndef	_LINUX_NET_CALLSITE_TYPES_H_
+#define _LINUX_NET_CALLSITE_TYPES_H_
+#include <linux/oobparam.h>
+
+/* Pre-defined call site IDs */
+#define	CALLSITE_UNSET		0	/* Never set (default) */
+#define	CALLSITE_UNKNOWN	1	/* Tried to set, but couldn't */
+#define CALLSITE_START		2	/* First valid call site ID */
+
+#define	CALLSITE_MAX_ID_SIZE	16	/* Max # bits in a call site ID */
+
+/**
+ * struct callsite_id - callsite identifier
+ * @id:		Unique value assigned to callsite
+ *
+ * This includes the unique ID assigned to the call site and the information
+ * that defines the location of the call site.
+ */
+struct callsite_id {
+	unsigned		id:CALLSITE_MAX_ID_SIZE;
+};
+
+/* The id value must be set to CALLSITE_UNSET. This is conveniently defined
+ * to have the value zero, so we don't need to explicitly set it */
+#define CALLSITE_ID_INIT() {						\
+	}
+
+/**
+ * struct callsite_where - Location information for loaded callsites
+ * @here:	Address of code doing the calling (if terse reporting)
+ * @file:	Pointer to file name (if not using terse reporting)
+ * @lineno:	Line number in file (if not using terse reporting)
+ */
+struct callsite_where {
+#ifdef CONFIG_CALLSITE_TERSE
+	void			*here;	/* Address */
+#else
+	const char		*file;	/* Call location */
+	unsigned short		lineno;
+#endif
+};
+
+#ifdef CONFIG_CALLSITE_TERSE
+#define CALLSITE_WHERE_INIT()			{		\
+			.here =		NULL,			\
+		}
+#else
+#define CALLSITE_WHERE_INIT()			{		\
+			.file =		__FILE__,		\
+			.lineno =	__LINE__,		\
+		}
+#endif
+
+/**
+ * struct callsite_const - constant per-callsite information
+ * @id:		Pointer to the location of the callsite ID
+ * @where:	Location information
+ * @module:	Pointer to the module om which the callsite exists
+ * @set:	Pointer to information that allies to all callsites of this
+ *		particular set.
+ */
+struct callsite_static {
+	struct callsite_id	*id;
+	struct callsite_where	where;
+	struct module		*module;
+	struct callsite_set	*set;
+};
+
+#define	CALLSITE_STATIC_INIT(_id, _set)	{			\
+			.id =		_id,			\
+			.where =	CALLSITE_WHERE_INIT(),	\
+			.module =	THIS_MODULE,		\
+			.set =		_set,			\
+		}
+
+/*
+ * callsite_set - information about a set of callsite IDs
+ * @name:		Callsite_set name
+ * @width:		Number of bits available for callsite ID
+ * Private members:
+ * @warned:		Has a warning been printed that no call site ID could
+ *			be assigned for this callsite set?
+ * @max_id:		The maximim value of a callsite ID. This must fit in
+ *			the number of bits allocated to the callsite_id and
+ *			must be at least CALLSITE_START.
+ * @next_id:		Value of the next callsite ID to give out. Will never
+ *			be more than @max_id.
+ * @info:		Pointer to callsite_info array.
+ * @lock:		Lock that protects the @callsites structure member
+ * @callsite_id_sets:	Link to the next callsite_id_set
+ */
+struct callsite_set {
+	const char		*name;
+	unsigned int		width;
+	/* private */
+	bool			warned:1;
+	unsigned int		max_id;
+	unsigned int		next_id;
+	struct callsite_info	*info;
+	spinlock_t		lock;
+	struct list_head	callsite_id_sets;
+};
+
+#define CALLSITE_SET_INIT(str_name, _varname, _width)	{		\
+	.name =			str_name,				\
+	.width =		_width,					\
+	.lock =			__SPIN_LOCK_UNLOCKED((_varname).lock),	\
+	.callsite_id_sets =	LIST_HEAD_INIT((_varname).callsite_id_sets), \
+}
+
+/**
+ * struct callsite_frame - data in each "frame" of the callsite stack
+ * @id:			Callsite ID
+ * @callsite_oobparam:	Data for passing out of band parameters
+ *
+ * Data that is stored on the stack each time a call is made. A linked list
+ * of these is constructed on the stack for each task. In effect, these
+ * are "frames" for the stack of call sites
+ */
+struct callsite_frame {
+	struct callsite_id	id;
+	OOBPARAM_FRAME(frame);
+};
+#define CALLSITE_FRAME(name)	struct callsite_frame name;
+
+/**
+ * struct callsite_top - pointer to the top of the callsite stack
+ * @callsite_top	Pointer to the top of the callsite stack
+ */
+struct callsite_top {
+	OOBPARAM_TOP(top);
+};
+#define CALLSITE_TOP(name)	struct callsite_top name;
+#endif
diff --git a/include/net/callsite.h b/include/net/callsite.h
new file mode 100644
index 0000000..a355a23
--- /dev/null
+++ b/include/net/callsite.h
@@ -0,0 +1,208 @@
+/*
+ *			callsite.h
+ *
+ * Definitions for tracking callers to functions with very low storage
+ * overhead.
+ *
+ * Copyright (C) 2009  Scientific-Atlanta, Inc.
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
+ */
+
+#ifndef	_LINUX_NET_CALLSITE_H_
+#define _LINUX_NET_CALLSITE_H_
+#include <linux/stringify.h>
+#include <linux/sched.h>
+#include <net/callsite-types.h>
+
+#ifdef CONFIG_CALLSITE
+/* CALLSITE_VARS - macro to define all variables local to a call site
+ * @cs_top:	Name of a variable in which to store the value of the top
+ *		of the stack
+ * @cs_id:	Name of the statically allocated variable in which the call
+ *		site ID is stored
+ * @cs_static:	Name of the statically allocated structure in which constant
+ *		data about the call site is stored
+ * @cs_sf:	Name of the &struct callsite_frame variable (allocated
+ *		on the stack)
+ * @set:	Pointer to the &struct callsite_set for this set of call sites
+ * @top:	Pointer to the &struct callsite_top for this thread
+ */
+#define CALLSITE_VARS(cs_top, cs_id, cs_static, cs_sf, set, top)	\
+		struct callsite_top *cs_top = (top);			\
+		static struct callsite_id cs_id;			\
+		static struct callsite_static cs_static =		\
+			CALLSITE_STATIC_INIT(&cs_id, (set));		\
+		struct callsite_frame cs_sf
+
+/* Define a macro for declaring the variables */
+#define CALLSITE_DECL(cs_top, cs_id, cs_static, cs_sf, set, top) \
+	CALLSITE_VARS(cs_top, cs_id, cs_static, cs_sf, (set), (top))
+
+/**
+ * CALLSITE_CALL - Push a callsite stack "frame" and call a function
+ * @top:	Pointer to a pointer to the first in the list of
+ *		&callsite_top "frames
+ * @set:	Pointer to a &struct callsite_set
+ * @fn:		Function returning a non-void value
+ * @...:	Arguments to fn()
+ *
+ * Push a callsite stack "frame" on the stack, call the given function,
+ * and pop the callsite stack frame. Evaluates to the value returned by
+ * the function.
+ */
+#define CALLSITE_CALL(top, set, fn, arg1, ...)	({			\
+		CALLSITE_DECL(_cs_top, _cs_id, _cs_static,		\
+			_cs_stackframe, (set), (top));			\
+		typeof((fn)(arg1, ##__VA_ARGS__)) _cs_result;		\
+		callsite_push(_cs_top, &_cs_stackframe, &_cs_id,	\
+			&_cs_static);					\
+		_cs_result = (fn)(arg1, ##__VA_ARGS__);			\
+		callsite_pop(_cs_top);					\
+		_cs_result;						\
+	})
+
+/**
+ * CALLSITE_CALL_VOID - Push a callsite stack "frame" and call a void function
+ * @top:	Pointer to a pointer to the first in the list of
+ *		callsite_top "frames
+ * @fn:		Function of type void
+ * @...:	Arguments to fn()
+ *
+ * Push a callsite stack "frame" on the stack, call the given function,
+ * and pop the callsite stack frame.
+ */
+#define CALLSITE_CALL_VOID(top, set, fn, arg1, ...)	do {		\
+		CALLSITE_DECL(_cs_top, _cs_id, _cs_static,		\
+			_cs_stackframe, (set), (top));			\
+		callsite_push(_cs_top, &_cs_stackframe, &_cs_id,	\
+			&_cs_static);					\
+		(fn)(arg1, ##__VA_ARGS__);				\
+		callsite_pop(_cs_top);					\
+	} while (0)
+
+#define CALLSITE_CUR(top) \
+	OOBPARAM_CUR(&top->top, struct callsite_frame, frame)
+
+extern void callsite_print_where_by_id(struct callsite_set *cs_set,
+	unsigned int id);
+extern void callsite_assign_id(struct callsite_static *cs_static);
+extern void callsite_remove_module(struct module *module);
+extern int callsite_set_register(struct callsite_set *cs_set);
+
+/**
+ * callsite_set_id - Set the callsite ID if it isn't already set
+ * @id:		Pointer to &callsite_id to check and set
+ * @cs_static:	Pointer to &struct callsite_static data for this callsite
+ */
+static inline void callsite_set_id(struct callsite_id *id,
+	struct callsite_static *cs_static)
+{
+	if (unlikely(id->id == CALLSITE_UNSET))
+		callsite_assign_id(cs_static);
+}
+
+/*
+ * callsite_push - Push the current callsite on the callsite stack
+ * @top:	Pointer to the stack information
+ * @s:		Pointer to stack "frame" on stack.
+ * @cs_where:	Pointer to statically allocated per-callsite location
+ *		information
+ */
+static inline void callsite_push(struct callsite_top *top,
+	struct callsite_frame *s, struct callsite_id *id,
+	struct callsite_static *cs_static)
+{
+	callsite_set_id(id, cs_static);
+	s->id = *id;
+	oobparam_push(&top->top, &s->frame);
+}
+
+/*
+ * callsite_pop - Pop the current callsite from the callsite stack
+ * @top:	Pointer to a pointer to the top of the callsite stack
+ *
+ * It is possible that the memory pointed to by top will be reused once it
+ * goes out of scope, and the storage now used by the next element of
+ * the top callsite_top structure modified. If top has not been changed
+ * by then, the linked list will be thoroughly confused. We use barrier() to
+ * ensure that top is changed before the callsite_top structure goes out
+ * of scope.
+ */
+static inline void callsite_pop(struct callsite_top *top)
+{
+	oobparam_pop(&top->top);
+}
+
+/**
+ * callsite_top_id - Get the &callsite_id for the topmost &callsite_frame
+ * @top:	Pointer to the &struct callsite_top
+ */
+static inline int callsite_get_id(struct callsite_top *top)
+{
+	return CALLSITE_CUR(top)->id.id;
+}
+
+/**
+ * callsite_task_init - initialize a callsite member of the task structure
+ * @p	Pointer to the member to initialize
+ */
+static inline void callsite_top_init(struct callsite_top *p)
+{
+}
+#else
+#define CALLSITE_CALL(top, set, fn, arg1, ...)	({			\
+		(fn)(arg1, ##__VA_ARGS__);				\
+	})
+
+/* Macro to use to call functions that do not return values */
+#define CALLSITE_CALL_VOID(top, set, fn, arg1, ...)	do {		\
+		(fn)(arg1, ##__VA_ARGS__);				\
+	} while (0)
+
+static inline void callsite_remove_module(struct module *module)
+{
+}
+
+static inline void callsite_push(struct callsite_top *top,
+	struct callsite_frame *s, struct callsite_id *id,
+	const struct callsite_static *cs_static)
+{
+}
+
+static inline void callsite_pop(struct callsite_top **top)
+{
+}
+
+static inline void callsite_top_init(struct callsite_top *p)
+{
+}
+
+static inline int callsite_set_register(struct callsite_set *cs_set)
+{
+	return 0;
+}
+
+static inline int callsite_top_id(const struct callsite_frame *top)
+{
+	return 0;
+}
+#endif
+
+extern void *here(void);
+#endif
diff --git a/net/core/callsite.c b/net/core/callsite.c
new file mode 100644
index 0000000..e77d44b
--- /dev/null
+++ b/net/core/callsite.c
@@ -0,0 +1,354 @@
+/*
+ *			callsite.c
+ *
+ * Support for assigning IDs to addresses.
+ *
+ * For debugging, it may be desirable to store information about where a
+ * structure was, for example used or modified. This location would generically
+ * be an address, but since there are generally only a small number of
+ * addresses that would actually be used, a much smaller tag value can be
+ * stored instead. This code takes care of dynamically generating IDs and
+ * converting them to addresses, when necessary. It is written with the
+ * assumption that generating IDs must be very fast, but converting them
+ * to addresses does not need to be particularly quick.
+ *
+ * Copyright (C) 2009  Scientific-Atlanta, Inc.
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
+ */
+
+#include <linux/kernel.h>
+#include <linux/list.h>
+#include <linux/spinlock.h>
+#include <linux/slab.h>
+#include <linux/kallsyms.h>
+#include <linux/module.h>
+#include <net/callsite.h>
+
+/**
+ * struct callsite_info - Per-call site information
+ * @unloaded:	Is this in a module that has been unloaded?
+ * @where:	Union of location information
+ *   @loaded	Location information if callsite is loaded
+ *   @unloaded	Location information if callsite is in an unloaded module
+ * @lock:	Lock for updating information for this call site
+ */
+struct callsite_info {
+	bool					unloaded:1;
+	union {
+		const struct callsite_static	*loaded;
+		const char			*unloaded;
+	} where;
+};
+
+/* List of callsite_id_sets and the synchronization primitive that protects
+ * the list */
+static DEFINE_MUTEX(callsite_id_sets_lock);
+static LIST_HEAD(callsite_id_sets);
+
+static const char unknown_location[] = "<unknown>";
+
+/**
+ * callsite_print_location - Print location from &struct callsite_where
+ * @where:	Pointer to &struct callsite_where to print
+ *
+ * The caller of this function should have already printed the printk()
+ * priority so that these pr_cont()s will use the same priority.
+ */
+#ifdef CONFIG_CALLSITE_TERSE
+void callsite_print_where(const struct callsite_where *where)
+{
+	print_ip_sym((unsigned long) where->here);
+}
+#else
+void callsite_print_where(const struct callsite_where *where)
+{
+	pr_cont("%s:%u\n", where->file, where->lineno);
+}
+#endif
+
+/**
+ * callsite_location_alloc - Store location in allocated string
+ * @cs:	Pointer to the &struct callsite
+ *
+ * Returns a pointer to an allocated string, or %NULL.
+ */
+#ifdef CONFIG_CALLSITE_TERSE
+static char *callsite_location_alloc(const struct callsite_where *where)
+{
+	char	*location;
+
+	location = kmalloc(KSYM_SYMBOL_LEN, GFP_KERNEL);
+
+	/* The only interesting information is really the function and offset
+	 * information. The actual location is irrelevant because the module
+	 * is going away. */
+	if (location != NULL) {
+		size_t	size;
+		snprintf(location, KSYM_SYMBOL_LEN, "%pS", where->here);
+		size = strlen(location) + 1;
+		location = krealloc(location, size, GFP_KERNEL);
+	}
+
+	return location;
+}
+#else
+static char *callsite_location_alloc(const struct callsite_where *where)
+{
+	char	*location;
+	size_t	size;
+	static const char colon[] = ":";
+	static const char lineno[] = "99999";
+
+	size = strlen(where->file) + sizeof(colon) + sizeof(lineno) + 1;
+	location = kmalloc(size, GFP_KERNEL);
+
+	if (location != NULL)
+		snprintf(location, size, "%s:%u", where->file, where->lineno);
+
+	return location;
+}
+#endif
+
+/**
+ * callsite_location - Get a string for the location
+ * @cs:	Pointer to call site information
+ */
+static const char *callsite_location(const struct callsite_where *where)
+{
+	const char	*p;
+
+	p = callsite_location_alloc(where);
+	if (p == NULL)
+		p = unknown_location;
+	return p;
+}
+
+/**
+ * callsite_print_location_by_id - Symbolically print the caller location
+ * @cs_set:	Pointer to information about this set of caller IDs
+ * @id:		Call site ID to search for
+ *
+ * The caller of this function should have already printed the printk()
+ * priority so that these pr_cont()s will use the same priority.
+ */
+void callsite_print_where_by_id(struct callsite_set *cs_set,
+	unsigned int id)
+{
+	struct callsite_info	*p;
+	unsigned long		flags;
+
+	switch (id) {
+	case CALLSITE_UNSET:
+		pr_cont("<unset>\n");
+		break;
+	case CALLSITE_UNKNOWN:
+		pr_cont("%s\n", unknown_location);
+		break;
+	default:
+		spin_lock_irqsave(&cs_set->lock, flags);
+
+		/* If the ID is not valid, we can't say where what the callsite
+		 * might be. */
+		if (id >= cs_set->next_id || cs_set->info == NULL)
+			pr_cont("<unknown ID %u>\n", id); /* Couldn't find ID */
+
+		else {
+			p = &cs_set->info[id - CALLSITE_START];
+
+			if (p->unloaded)
+				pr_cont("%s (module unloaded)\n",
+					p->where.unloaded);
+			else
+				callsite_print_where(&p->where.loaded->where);
+		}
+
+		spin_unlock_irqrestore(&cs_set->lock, flags);
+		break;
+	}
+}
+
+/**
+ * callsite_assign_id - Assign a call site ID
+ * @cs_static:	Pointer to static information about the callsite
+ *
+ * If the ID is @CALLSITE_UNSET in a given &struct callsite, this
+ * function is called to assign a call site ID. The value assigned will
+ * normally * be @CALLSITE_START or above, but if we exceed the maximum
+ * size of an ID, * we assign @CALLSITE_UNKNOWN.
+ */
+extern void callsite_assign_id(struct callsite_static *cs_static)
+{
+	unsigned int		id;
+	unsigned long		flags;
+	struct callsite_set	*set;
+
+	/* Record the caller's location. */
+	cs_static->where.here = here();
+
+	/* Lock the call site set. The first time we check, we do so on
+	 * the optimistic assumption that it has already been set. It may
+	 * have been since checking, though, which is why we need to lock
+	 * the callsite_set and check again. */
+	set = cs_static->set;
+	spin_lock_irqsave(&set->lock, flags);
+
+	/* If the callsite_info array wasn't allocated, we can't assign an
+	 * ID and the callsite is unknown. Since the value returned is not
+	 * @CALLSITE_UNKNOWN, we won't try again to assign a callsite ID for
+	 * this site, */
+	if (set->info == NULL)
+		cs_static->id->id = CALLSITE_UNKNOWN;
+
+	else if (cs_static->id->id == CALLSITE_UNSET) {
+
+		/* If we are out of tags, just indicate that it's unknown */
+		if (set->next_id > set->max_id) {
+			id = CALLSITE_UNKNOWN;
+			if (!set->warned) {
+				pr_warning("Exhausted IDs for callsite_set "
+					"%s\n", set->name);
+				set->warned = true;
+			}
+		}
+
+		else {
+			struct callsite_info *p;
+			id = set->next_id;
+			set->next_id++;
+
+			p = &set->info[id - CALLSITE_START];
+			p->unloaded = false;
+			p->where.loaded = cs_static;
+		}
+
+		cs_static->id->id = id;
+	}
+
+	spin_unlock_irqrestore(&set->lock, flags);
+#ifdef DEBUG
+	if (cs_static->id->id != CALLSITE_UNKNOWN) {
+		pr_debug("%s: assigned ID %u to call at ",
+			__func__, cs_static->id->id);
+		callsite_print_where_by_id(set, cs_static->id->id);
+	}
+#endif
+}
+EXPORT_SYMBOL(callsite_assign_id);
+
+/*
+ * callsite_unload_id - Preserve call site ID info on module unload
+ * @p:	Pointer to &struct callsite_info to preserve
+ *
+ * We assume that we are not in atomic mode, so we can sleep waiting for
+ * memory. Must be called with the list lock held.
+ */
+static void callsite_unload_id(struct callsite_info *p)
+{
+	p->unloaded = true;
+	p->where.unloaded = callsite_location(&p->where.loaded->where);
+}
+
+/*
+ * callsite_unload_module - Preserve callsite ID info when unloading a module
+ * @module:	Pointer to &struct module for module being unloaded
+ *
+ * Call site IDs are assigned dynamically as the need arises, which works well
+ * much of the time. There is an issue, though, with call site ID information
+ * stored in modules, because the callsite associated with an ID
+ * goes away when that module is removed. To handle that, we copy all of the
+ * callsite information for a module when it is removed, including
+ * generating the location string.
+ */
+void callsite_remove_module(struct module *module)
+{
+	unsigned long		flags;
+	struct callsite_set *cs;
+
+	mutex_lock(&callsite_id_sets_lock);
+	list_for_each_entry(cs, &callsite_id_sets, callsite_id_sets) {
+		int	i;
+
+		if (cs->info == NULL)
+			continue;
+
+		spin_lock_irqsave(&cs->lock, flags);
+
+		for (i = CALLSITE_START; i < cs->next_id; i++) {
+			struct callsite_info *p;
+
+			p = &cs->info[i - CALLSITE_START];
+
+			if (!p->unloaded && p->where.loaded->module == module)
+				callsite_unload_id(p);
+		}
+
+		spin_unlock_irqrestore(&cs->lock, flags);
+	}
+	mutex_unlock(&callsite_id_sets_lock);
+}
+
+/**
+ * callsite_id_set_register - add information for a set of callsite IDs
+ * @cs_set:	Pointer to the &struct callsite_id_set to add
+ *
+ * Returns zero on success, or a negative errno value.
+ */
+int callsite_set_register(struct callsite_set *cs_set)
+{
+	size_t	n;
+	size_t	size;
+	struct callsite_info *info;
+
+	BUG_ON(cs_set->max_id > (1 << CALLSITE_MAX_ID_SIZE));
+	cs_set->max_id = (1 << (cs_set->width)) - 1;
+
+	if (cs_set->max_id < CALLSITE_START)
+		return -EINVAL;
+
+	n = cs_set->max_id - CALLSITE_START;
+
+	/* Allocate memory for the maximum number of callsites. We take
+	 * advantage of the fact that the value of CALLSITE_UNSET is zero */
+	size = n * sizeof(struct callsite_info);
+	BUG_ON(CALLSITE_UNSET != 0);
+	info = kzalloc(size, GFP_KERNEL);
+
+	if (info == NULL)
+		return -ENOMEM;
+
+	cs_set->info = info;
+	cs_set->next_id = CALLSITE_START;
+
+	mutex_lock(&callsite_id_sets_lock);
+	list_add(&cs_set->callsite_id_sets, &callsite_id_sets);
+	mutex_unlock(&callsite_id_sets_lock);
+
+	return 0;
+}
+EXPORT_SYMBOL(callsite_set_register);
+
+/**
+ * here - address in calling function
+ *
+ * This needs the caller to create a stackframe, so it can't be inlined.
+ */
+noinline void *here()
+{
+	return __builtin_return_address(0);
+}
+EXPORT_SYMBOL(here);
