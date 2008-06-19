From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 4/12] benet: beclib (h/w access lib) header files
Date: Thu, 19 Jun 2008 06:24:32 -0400
Message-ID: <20080619102432.GD17697@infradead.org>
References: <20080612104042.89fa1f08@mailhost.serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: Subbu Seetharaman <subbus@serverengines.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:33052 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752892AbYFSKYe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 06:24:34 -0400
Content-Disposition: inline
In-Reply-To: <20080612104042.89fa1f08@mailhost.serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +#define TRUE	(1)
> +#define FALSE	(0)

Please use the standard true/false as provided by the kernel headers.

> +#if !defined(SG_PACK)
> +#define SG_PACK __attribute__ ((packed))
> +#endif

Please use __packed

> +/*
> + *---------   Assert related --------
> + * a way to force  compilation error
> + */
> +
> +#define SA_C_ASSERT(_expression_)       {				\
> +	struct __COMPILE_TIME_ASSERT__ {				\
> +		u8 __COMPILE_TIME_ASSERT__[(_expression_)?1: -1];	\
> +	};								\
> +}

Please use BUG_ON.

> +#define SA_COMPILETIME_NAMED_TYPEDEF_ASSERT(_name_, _expression_)	\
> +	struct _name_##_COMPILE_TIME_ASSERT_ {				\
> +		u8 _name##_COMPILE_TIME_ASSERT_[(_expression_)?1: -1];	\
> +	};

Please use BUILD_BUG_ON.

> +static inline u32 sa_required_bits(u32 x)


> + * Returns the log base 2 for a number, always rounding down.
> + * sa_log2 example input->output
> + * 0->4294967295, 1->0, 2->1, 3->1, 4->2, 5->2, 6->2, 7->2, 8->3, 9->3
> + */
> +static inline u32 sa_log2(u32 x)
> +{
> +	return sa_required_bits(x) - 1;

Please take a look at include/linux/log2.h

> + * Status code datatype
> + */
> +typedef int SA_STATUS, *PSA_STATUS;

Please kill this and just use normal errno values.

> +#define SA_PTR_TO_INT(_p_) ((size_t)(_p_))
> +#define SA_PTR_TO_U32(_p_) ((u32)SA_PTR_TO_INT(_p_))
> +#define SA_PTR_TO_U64(_p_) ((u64)SA_PTR_TO_INT(_p_))
> +
> +#define SA_PTR_TO_INT(_p_) ((size_t)(_p_))
> +#define SA_U64_TO_PTR(_u_) ((void *)(size_t)(_u_))
> +#define SA_U32_TO_PTR(_u_) ((void *)(size_t)(_u_))

These warnings are there for a reason, and having the casts spelled
out where they are required is a good warnings sign.

> +#define SA_PAGE_OFFSET(_addr_) (SA_PTR_TO_INT(_addr_) & (PAGE_SIZE-1))

Should be lower case and without that sa prefix.

> +/* Returns byte offset of field within given struct type. */
> +#define SA_FIELD_OFFSET(_type_, _field_)              \
> +	(SA_PTR_TO_U32((u8 *)&(((struct _type_ *)0)->_field_)))
> +
> +/* Returns byte size of given field with a structure. */
> +#define SA_SIZEOF_FIELD(_type_, _field_)  \
> +	sizeof(((struct _type_ *)0)->_field_)
> +
> +/* Returns the number of items in the field array. */
> +#define SA_NUMBER_OF_FIELD(_type_, _field_)				\
> +	(SA_SIZEOF_FIELD(_type_, _field_) / 				\
> +			sizeof((((struct _type_ *)0)->_field_[0])))
> +

Please use the kernel.h helpers.

> +/* descriptor for a physically contiguous  memory region */
> +struct sa_sgl {
> +	u32 length;
> +	void *va;
> +	u64 pa;
> +} ;

What do you actually needs this an the helpers for?  It seems a rather
odd data structure because linux scatter/gather lists are page-based.

> +/*-----------  amap bit filed get / set macros and functions -----*/
> +/*
> + * Structures defined in the map header files (under fw/amap/) with names
> + * in the format BE_<name>_AMAP are pseudo structures with members
> + * of type BE_BIT. These structures are templates that are used in
> + * conjuntion with the structures with names in the format
> + * <name>_AMAP to calculate the bit masks and bit offsets to get or set
> + * bit fields in structures. The structures <name>_AMAP are arrays
> + * of 32 bits words and have the correct size.  The following macros
> + * provide convenient ways to get and set the various members
> + * in the structures without using strucctures with bit fields.
> + * Always use the macros AMAP_GET_BITS_PTR and AMAP_SET_BITS_PTR
> + * macros to extract and set various members.
> + */
> +/* Each bit is 1 byte in array maps. */
> +typedef u8 AMAP_BIT, BE_BIT;

Please just u8 instead of these ugly typedefs.

> +static inline u32
> +amap_get(void *ptr, u32 dw_offset, u32 mask, u32 offset)
> +{
> +	u32 *dw = (u32 *)ptr;
> +	return mask & (*(dw + dw_offset) >> offset);
> +}
> +#define AMAP_GET_BITS_PTR(_struct_, _register_, _structPtr_)		\
> +	amap_get(_structPtr_, AMAP_WORD_OFFSET(_struct_, _register_),	\
> +		AMAP_BIT_MASK(_struct_, _register_),			\
> +			AMAP_BIT_OFFSET(_struct_, _register_))		\

Why do you need all this infrastructure?  Any reason the regular
bitmasks in Linux are not enough?


> +#if !defined(BE_CONFIG)
> +#define BE_CONFIG 0
> +#define CONFIG0
> +#endif

What's the reasons for this?

> +/* Callback types.  Deprecate most of these. */
> +typedef void (*MCC_WRB_CQE_CALLBACK) (void *context,
> +				BESTATUS status,
> +				struct MCC_WRB_AMAP *optional_wrb);
> +typedef void (*MCC_ASYNC_EVENT_CALLBACK) (void *context,
> +				u32 event_code,
> +				void *event);
> +
> +typedef BESTATUS(*EQ_CALLBACK) (struct be_function_object *,
> +				struct be_eq_object *, void *context);
> +typedef BESTATUS(*CQ_CALLBACK) (struct be_function_object *,
> +				struct be_cq_object *, void *context);

Lowercase, please.

> +/* --- BE_FUNCTION_ENUM --- */
> +#define BE_FUNCTION_TYPE_ISCSI          (0)
> +#define BE_FUNCTION_TYPE_NETWORK        (1)
> +#define BE_FUNCTION_TYPE_ARM            (2)
> +
> +enum BE_FUNCTION_ENUM {
> +	ENUM_BE_FUNCTION_TYPE_ISCSI = 0x0UL,
> +	ENUM_BE_FUNCTION_TYPE_NETWORK = 0x1UL,
> +	ENUM_BE_FUNCTION_TYPE_ARM = 0x2UL
> +} ;

Why is this done twice?  Also the enum as every type name should be
lower cased.

