From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: [PATCH][RFC] Infrastructure for compact call location
 representation
Date: Tue, 8 Jun 2010 08:44:52 -0700
Message-ID: <20100608084452.9a3ebb0a.rdunlap@xenotime.net>
References: <20100608003052.GA29377@dvomlehn-lnx2.corp.sa.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: to@dvomlehn-lnx2.corp.sa.net, netdev@vger.kernel.org
To: David VomLehn <dvomlehn@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([72.52.115.56]:44575 "HELO xenotime.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752800Ab0FHPoy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jun 2010 11:44:54 -0400
Received: from chimera.site ([71.245.98.113]) by xenotime.net for <netdev@vger.kernel.org>; Tue, 8 Jun 2010 08:44:52 -0700
In-Reply-To: <20100608003052.GA29377@dvomlehn-lnx2.corp.sa.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 7 Jun 2010 17:30:52 -0700 David VomLehn wrote:

> Notes
> o	Under simple test conditions, the number of call site IDs allocated
> 	can be quite small, small enough to fit in 6 bits. That would reduce
> 	the sk_buff growth to one byte. This is *not* a recommended
> 	configuration.
> o	This is placed in net/core and linux/net since those are the only
> 	current users, but there is nothing about this that is networking-
> 	specific.

=> this shouldn't end up in net/

>  include/net/callsite-types.h |  160 +++++++++++++++++++
>  include/net/callsite.h       |  208 +++++++++++++++++++++++++
>  net/core/callsite.c          |  354 ++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 722 insertions(+), 0 deletions(-)
> 
> diff --git a/include/net/callsite-types.h b/include/net/callsite-types.h
> new file mode 100644
> index 0000000..796cfb1
> --- /dev/null
> +++ b/include/net/callsite-types.h
> @@ -0,0 +1,160 @@

> +#ifndef	_LINUX_NET_CALLSITE_TYPES_H_
> +#define _LINUX_NET_CALLSITE_TYPES_H_
> +#include <linux/oobparam.h>
> +
> +/* Pre-defined call site IDs */
> +#define	CALLSITE_UNSET		0	/* Never set (default) */
> +#define	CALLSITE_UNKNOWN	1	/* Tried to set, but couldn't */
> +#define CALLSITE_START		2	/* First valid call site ID */
> +
> +#define	CALLSITE_MAX_ID_SIZE	16	/* Max # bits in a call site ID */
> +
> +/**
> + * struct callsite_id - callsite identifier
> + * @id:		Unique value assigned to callsite
> + *
> + * This includes the unique ID assigned to the call site and the information
> + * that defines the location of the call site.
> + */
> +struct callsite_id {
> +	unsigned		id:CALLSITE_MAX_ID_SIZE;
> +};
> +
> +/* The id value must be set to CALLSITE_UNSET. This is conveniently defined
> + * to have the value zero, so we don't need to explicitly set it */
> +#define CALLSITE_ID_INIT() {						\
> +	}
> +
> +/**
> + * struct callsite_where - Location information for loaded callsites
> + * @here:	Address of code doing the calling (if terse reporting)
> + * @file:	Pointer to file name (if not using terse reporting)
> + * @lineno:	Line number in file (if not using terse reporting)
> + */
> +struct callsite_where {
> +#ifdef CONFIG_CALLSITE_TERSE
> +	void			*here;	/* Address */
> +#else
> +	const char		*file;	/* Call location */
> +	unsigned short		lineno;
> +#endif
> +};
> +
> +#ifdef CONFIG_CALLSITE_TERSE
> +#define CALLSITE_WHERE_INIT()			{		\
> +			.here =		NULL,			\
> +		}
> +#else
> +#define CALLSITE_WHERE_INIT()			{		\
> +			.file =		__FILE__,		\
> +			.lineno =	__LINE__,		\
> +		}
> +#endif
> +
> +/**
> + * struct callsite_const - constant per-callsite information
> + * @id:		Pointer to the location of the callsite ID
> + * @where:	Location information
> + * @module:	Pointer to the module om which the callsite exists
> + * @set:	Pointer to information that allies to all callsites of this
> + *		particular set.
> + */
> +struct callsite_static {
> +	struct callsite_id	*id;
> +	struct callsite_where	where;
> +	struct module		*module;
> +	struct callsite_set	*set;
> +};
> +
> +#define	CALLSITE_STATIC_INIT(_id, _set)	{			\
> +			.id =		_id,			\
> +			.where =	CALLSITE_WHERE_INIT(),	\
> +			.module =	THIS_MODULE,		\
> +			.set =		_set,			\
> +		}
> +
> +/*
> + * callsite_set - information about a set of callsite IDs
> + * @name:		Callsite_set name
> + * @width:		Number of bits available for callsite ID
> + * Private members:

You can use
 * private:
above to keep these parameters from being printed in the kernel-doc output
if that's what you prefer to see.

> + * @warned:		Has a warning been printed that no call site ID could
> + *			be assigned for this callsite set?
> + * @max_id:		The maximim value of a callsite ID. This must fit in
> + *			the number of bits allocated to the callsite_id and
> + *			must be at least CALLSITE_START.
> + * @next_id:		Value of the next callsite ID to give out. Will never
> + *			be more than @max_id.
> + * @info:		Pointer to callsite_info array.
> + * @lock:		Lock that protects the @callsites structure member
> + * @callsite_id_sets:	Link to the next callsite_id_set
> + */
> +struct callsite_set {
> +	const char		*name;
> +	unsigned int		width;
> +	/* private */
> +	bool			warned:1;
> +	unsigned int		max_id;
> +	unsigned int		next_id;
> +	struct callsite_info	*info;
> +	spinlock_t		lock;
> +	struct list_head	callsite_id_sets;
> +};
> +
> +#define CALLSITE_SET_INIT(str_name, _varname, _width)	{		\
> +	.name =			str_name,				\
> +	.width =		_width,					\
> +	.lock =			__SPIN_LOCK_UNLOCKED((_varname).lock),	\
> +	.callsite_id_sets =	LIST_HEAD_INIT((_varname).callsite_id_sets), \
> +}
> +
> +/**
> + * struct callsite_frame - data in each "frame" of the callsite stack
> + * @id:			Callsite ID
> + * @callsite_oobparam:	Data for passing out of band parameters
> + *
> + * Data that is stored on the stack each time a call is made. A linked list
> + * of these is constructed on the stack for each task. In effect, these
> + * are "frames" for the stack of call sites
> + */
> +struct callsite_frame {
> +	struct callsite_id	id;
> +	OOBPARAM_FRAME(frame);
> +};
> +#define CALLSITE_FRAME(name)	struct callsite_frame name;
> +
> +/**
> + * struct callsite_top - pointer to the top of the callsite stack
> + * @callsite_top	Pointer to the top of the callsite stack

 * @callsite_top:

Oh, is it just
 * @top:
??

> + */
> +struct callsite_top {
> +	OOBPARAM_TOP(top);
> +};
> +#define CALLSITE_TOP(name)	struct callsite_top name;
> +#endif
> diff --git a/include/net/callsite.h b/include/net/callsite.h
> new file mode 100644
> index 0000000..a355a23
> --- /dev/null
> +++ b/include/net/callsite.h
> @@ -0,0 +1,208 @@

> +#ifndef	_LINUX_NET_CALLSITE_H_
> +#define _LINUX_NET_CALLSITE_H_
> +#include <linux/stringify.h>
> +#include <linux/sched.h>
> +#include <net/callsite-types.h>
> +
> +#ifdef CONFIG_CALLSITE
> +/* CALLSITE_VARS - macro to define all variables local to a call site
> + * @cs_top:	Name of a variable in which to store the value of the top
> + *		of the stack
> + * @cs_id:	Name of the statically allocated variable in which the call
> + *		site ID is stored
> + * @cs_static:	Name of the statically allocated structure in which constant
> + *		data about the call site is stored
> + * @cs_sf:	Name of the &struct callsite_frame variable (allocated
> + *		on the stack)
> + * @set:	Pointer to the &struct callsite_set for this set of call sites
> + * @top:	Pointer to the &struct callsite_top for this thread
> + */
> +#define CALLSITE_VARS(cs_top, cs_id, cs_static, cs_sf, set, top)	\
> +		struct callsite_top *cs_top = (top);			\
> +		static struct callsite_id cs_id;			\
> +		static struct callsite_static cs_static =		\
> +			CALLSITE_STATIC_INIT(&cs_id, (set));		\
> +		struct callsite_frame cs_sf
> +
> +/* Define a macro for declaring the variables */
> +#define CALLSITE_DECL(cs_top, cs_id, cs_static, cs_sf, set, top) \
> +	CALLSITE_VARS(cs_top, cs_id, cs_static, cs_sf, (set), (top))
> +
> +/**
> + * CALLSITE_CALL - Push a callsite stack "frame" and call a function
> + * @top:	Pointer to a pointer to the first in the list of
> + *		&callsite_top "frames
> + * @set:	Pointer to a &struct callsite_set
> + * @fn:		Function returning a non-void value

Is there always an @arg1 ?

> + * @...:	Arguments to fn()
> + *
> + * Push a callsite stack "frame" on the stack, call the given function,
> + * and pop the callsite stack frame. Evaluates to the value returned by
> + * the function.
> + */
> +#define CALLSITE_CALL(top, set, fn, arg1, ...)	({			\
> +		CALLSITE_DECL(_cs_top, _cs_id, _cs_static,		\
> +			_cs_stackframe, (set), (top));			\
> +		typeof((fn)(arg1, ##__VA_ARGS__)) _cs_result;		\
> +		callsite_push(_cs_top, &_cs_stackframe, &_cs_id,	\
> +			&_cs_static);					\
> +		_cs_result = (fn)(arg1, ##__VA_ARGS__);			\
> +		callsite_pop(_cs_top);					\
> +		_cs_result;						\
> +	})
> +
> +/**
> + * CALLSITE_CALL_VOID - Push a callsite stack "frame" and call a void function
> + * @top:	Pointer to a pointer to the first in the list of
> + *		callsite_top "frames
> + * @fn:		Function of type void

 * @arg1:
??

> + * @...:	Arguments to fn()
> + *
> + * Push a callsite stack "frame" on the stack, call the given function,
> + * and pop the callsite stack frame.
> + */
> +#define CALLSITE_CALL_VOID(top, set, fn, arg1, ...)	do {		\
> +		CALLSITE_DECL(_cs_top, _cs_id, _cs_static,		\
> +			_cs_stackframe, (set), (top));			\
> +		callsite_push(_cs_top, &_cs_stackframe, &_cs_id,	\
> +			&_cs_static);					\
> +		(fn)(arg1, ##__VA_ARGS__);				\
> +		callsite_pop(_cs_top);					\
> +	} while (0)
> +
> +#define CALLSITE_CUR(top) \
> +	OOBPARAM_CUR(&top->top, struct callsite_frame, frame)
> +
> +extern void callsite_print_where_by_id(struct callsite_set *cs_set,
> +	unsigned int id);
> +extern void callsite_assign_id(struct callsite_static *cs_static);
> +extern void callsite_remove_module(struct module *module);
> +extern int callsite_set_register(struct callsite_set *cs_set);
> +
> +/**
> + * callsite_set_id - Set the callsite ID if it isn't already set
> + * @id:		Pointer to &callsite_id to check and set
> + * @cs_static:	Pointer to &struct callsite_static data for this callsite
> + */
> +static inline void callsite_set_id(struct callsite_id *id,
> +	struct callsite_static *cs_static)
> +{
> +	if (unlikely(id->id == CALLSITE_UNSET))
> +		callsite_assign_id(cs_static);
> +}
...
> +/**
> + * callsite_task_init - initialize a callsite member of the task structure
> + * @p	Pointer to the member to initialize

 * @p:

> + */
> +static inline void callsite_top_init(struct callsite_top *p)
> +{
> +}
> +#else
> +#define CALLSITE_CALL(top, set, fn, arg1, ...)	({			\
> +		(fn)(arg1, ##__VA_ARGS__);				\
> +	})
...

> diff --git a/net/core/callsite.c b/net/core/callsite.c
> new file mode 100644
> index 0000000..e77d44b
> --- /dev/null
> +++ b/net/core/callsite.c
> @@ -0,0 +1,354 @@

> +/**
> + * struct callsite_info - Per-call site information
> + * @unloaded:	Is this in a module that has been unloaded?
> + * @where:	Union of location information
> + *   @loaded	Location information if callsite is loaded
> + *   @unloaded	Location information if callsite is in an unloaded module
> + * @lock:	Lock for updating information for this call site

<lock> is not a struct member below.

> + */
> +struct callsite_info {
> +	bool					unloaded:1;
> +	union {
> +		const struct callsite_static	*loaded;
> +		const char			*unloaded;
> +	} where;
> +};
...

> +
> +/**
> + * callsite_assign_id - Assign a call site ID
> + * @cs_static:	Pointer to static information about the callsite
> + *
> + * If the ID is @CALLSITE_UNSET in a given &struct callsite, this
> + * function is called to assign a call site ID. The value assigned will
> + * normally * be @CALLSITE_START or above, but if we exceed the maximum
> + * size of an ID, * we assign @CALLSITE_UNKNOWN.

stray asterisk?      ^

> + */
> +extern void callsite_assign_id(struct callsite_static *cs_static)
> +{
...


---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
