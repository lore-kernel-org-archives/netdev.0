From: "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Subject: Re: [PATCH 6/8] csiostor: Chelsio FCoE offload driver submission
 (headers part 1).
Date: Thu, 23 Aug 2012 12:58:49 -0700
Message-ID: <1345751929.10190.83.camel@haakon2.linux-iscsi.org>
References: <1345760873-12101-1-git-send-email-naresh@chelsio.com>
	 <1345760873-12101-7-git-send-email-naresh@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: JBottomley@parallels.com, linux-scsi@vger.kernel.org,
	dm@chelsio.com, netdev@vger.kernel.org, chethan@chelsio.com
To: Naresh Kumar Inna <naresh@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linux-iscsi.org ([67.23.28.174]:42467 "EHLO
	linux-iscsi.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751269Ab2HWT64 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 15:58:56 -0400
In-Reply-To: <1345760873-12101-7-git-send-email-naresh@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-08-24 at 03:57 +0530, Naresh Kumar Inna wrote:
> This patch contains the first set of the header files for csiostor driver.
> 
> Signed-off-by: Naresh Kumar Inna <naresh@chelsio.com>
> ---
>  drivers/scsi/csiostor/csio_defs.h       |  143 ++++++
>  drivers/scsi/csiostor/csio_fcoe_proto.h |  843 +++++++++++++++++++++++++++++++
>  drivers/scsi/csiostor/csio_hw.h         |  668 ++++++++++++++++++++++++
>  drivers/scsi/csiostor/csio_init.h       |  158 ++++++
>  4 files changed, 1812 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/scsi/csiostor/csio_defs.h
>  create mode 100644 drivers/scsi/csiostor/csio_fcoe_proto.h
>  create mode 100644 drivers/scsi/csiostor/csio_hw.h
>  create mode 100644 drivers/scsi/csiostor/csio_init.h
> 

Hi Naresh,

Just commenting on csio_defs.h bits here...  As Robert mentioned, you'll
need to convert the driver to use (or add to) upstream protocol
definitions and drop the csio_fcoe_proto.h bits..

> diff --git a/drivers/scsi/csiostor/csio_defs.h b/drivers/scsi/csiostor/csio_defs.h
> new file mode 100644
> index 0000000..4f1c713
> --- /dev/null
> +++ b/drivers/scsi/csiostor/csio_defs.h
> @@ -0,0 +1,143 @@
> +/*
> + * This file is part of the Chelsio FCoE driver for Linux.
> + *
> + * Copyright (c) 2008-2012 Chelsio Communications, Inc. All rights reserved.
> + *
> + * This software is available to you under a choice of one of two
> + * licenses.  You may choose to be licensed under the terms of the GNU
> + * General Public License (GPL) Version 2, available from the file
> + * COPYING in the main directory of this source tree, or the
> + * OpenIB.org BSD license below:
> + *
> + *     Redistribution and use in source and binary forms, with or
> + *     without modification, are permitted provided that the following
> + *     conditions are met:
> + *
> + *      - Redistributions of source code must retain the above
> + *        copyright notice, this list of conditions and the following
> + *        disclaimer.
> + *
> + *      - Redistributions in binary form must reproduce the above
> + *        copyright notice, this list of conditions and the following
> + *        disclaimer in the documentation and/or other materials
> + *        provided with the distribution.
> + *
> + * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
> + * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
> + * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
> + * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
> + * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
> + * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
> + * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
> + * SOFTWARE.
> + */
> +
> +#ifndef __CSIO_DEFS_H__
> +#define __CSIO_DEFS_H__
> +
> +#include <linux/kernel.h>
> +#include <linux/timer.h>
> +#include <linux/list.h>
> +#include <linux/bug.h>
> +#include <linux/pci.h>
> +#include <linux/jiffies.h>
> +
> +/* Function returns */
> +enum csio_retval {
> +	CSIO_SUCCESS = 0,
> +	CSIO_INVAL = 1,
> +	CSIO_BUSY = 2,
> +	CSIO_NOSUPP = 3,
> +	CSIO_TIMEOUT = 4,
> +	CSIO_NOMEM = 5,
> +	CSIO_NOPERM = 6,
> +	CSIO_RETRY = 7,
> +	CSIO_EPROTO = 8,
> +	CSIO_EIO = 9,
> +	CSIO_CANCELLED = 10,
> +};
> +

Please don't assign macros for errno's, and give them positive values.

> +#define csio_retval_t enum csio_retval

Please get rid of this csio_retval_t nonsense.

> +
> +enum {
> +	CSIO_FALSE = 0,
> +	CSIO_TRUE = 1,
> +};
> +

Same here, please use normal Boolean macros

> +#define CSIO_ROUNDUP(__v, __r)		(((__v) + (__r) - 1) / (__r))
> +#define CSIO_INVALID_IDX		0xFFFFFFFF
> +#define csio_inc_stats(elem, val)	((elem)->stats.val++)
> +#define csio_dec_stats(elem, val)	((elem)->stats.val--)

No reason for either of this stats inc+dec macros.  Please drop them.

> +#define csio_valid_wwn(__n)		((*__n >> 4) == 0x5 ? CSIO_TRUE : \
> +						CSIO_FALSE)
> +#define CSIO_WORD_TO_BYTE		4
> +
> +static inline int
> +csio_list_deleted(struct list_head *list)
> +{
> +	return ((list->next == list) && (list->prev == list));
> +}
> +
> +#define csio_list_next(elem)	(((struct list_head *)(elem))->next)
> +#define csio_list_prev(elem)	(((struct list_head *)(elem))->prev)
> +
> +#define csio_deq_from_head(head, elem)					  \
> +do {									  \
> +	if (!list_empty(head)) {					  \
> +		*((struct list_head **)(elem)) = csio_list_next((head));  \
> +		csio_list_next((head)) =				  \
> +				csio_list_next(csio_list_next((head)));   \
> +		csio_list_prev(csio_list_next((head))) = (head);	  \
> +		INIT_LIST_HEAD(*((struct list_head **)(elem)));	          \
> +	} else								  \
> +		*((struct list_head **)(elem)) = (struct list_head *)NULL;\
> +} while (0)
> +

This code is confusing as hell..  Why can't you just use normal list.h
macros for this..?  

> +#define csio_deq_from_tail(head, elem)					  \
> +do {									  \
> +	if (!list_empty(head)) {					  \
> +		*((struct list_head **)(elem)) = csio_list_prev((head));  \
> +		csio_list_prev((head)) =				  \
> +				csio_list_prev(csio_list_prev((head)));	  \
> +		csio_list_next(csio_list_prev((head))) = (head);	  \
> +		INIT_LIST_HEAD(*((struct list_head **)(elem)));		  \
> +	} else								  \
> +		*((struct list_head **)(elem)) = (struct list_head *)NULL;\
> +} while (0)
> +

Same here..  Please don't use macros like this.

> +/* State machine */
> +typedef void (*csio_sm_state_t)(void *, uint32_t);
> +
> +struct csio_sm {
> +	struct list_head	sm_list;
> +	csio_sm_state_t		sm_state;
> +};
> +
> +#define csio_init_state(__smp, __state)					\
> +	(((struct csio_sm *)(__smp))->sm_state = (csio_sm_state_t)(__state))
> +
> +#define	csio_set_state(__smp, __state)					\
> +	(((struct csio_sm *)(__smp))->sm_state = (csio_sm_state_t)(__state))
> +
> +
> +#define csio_post_event(__smp, __evt)					\
> +	(((struct csio_sm *)(__smp))->sm_state((__smp), (uint32_t)(__evt)))
> +
> +#define	csio_get_state(__smp)	(((struct csio_sm *)(__smp))->sm_state)
> +
> +#define	csio_match_state(__smp, __state)				\
> +	(csio_get_state((__smp)) == (csio_sm_state_t)(__state))
> +

Why does any of the sm_state stuff need to be in macros..?  Please
inline all of this code.

> +#define	CSIO_ASSERT(cond)						\
> +do {									\
> +	if (unlikely(!((cond))))					\
> +		BUG();                                                  \
> +} while (0)
> +
> +#ifdef __CSIO_DEBUG__
> +#define CSIO_DB_ASSERT(__c)		CSIO_ASSERT((__c))
> +#else
> +#define CSIO_DB_ASSERT(__c)
> +#endif
> +
> +#endif /* ifndef __CSIO_DEFS_H__ */
