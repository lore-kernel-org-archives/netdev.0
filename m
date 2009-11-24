From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Subject: [PATCH 2/6] bna: Brocade 10Gb Ethernet device driver
Date: Mon, 23 Nov 2009 20:21:52 -0800
Message-ID: <20091123202152.777d702a@s6510>
References: <200911240351.nAO3p1AY025627@blc-10-10.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <adapter_linux_open_src_team@brocade.com>
To: Rasesh Mody <rmody@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56941 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757989AbZKXEWJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Nov 2009 23:22:09 -0500
In-Reply-To: <200911240351.nAO3p1AY025627@blc-10-10.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 23 Nov 2009 19:51:01 -0800
Rasesh Mody <rmody@brocade.com> wrote:

> +/*
> + * Linux network driver for Brocade Converged Network Adapter.
> + *
> + * This program is free software; you can redistribute it and/or modify it
> + * under the terms of the GNU General Public License (GPL) Version 2 as
> + * published by the Free Software Foundation
> + *
> + * This program is distributed in the hope that it will be useful, but
> + * WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
> + * General Public License for more details.
> + */
> +/*
> + * Copyright (c) 2006-2009 Brocade Communications Systems, Inc.
> + * All rights reserved
> + * www.brocade.com
> + */
> +
> +#include "bfa_timer.h"
> +#include "cs/bfa_debug.h"
> +
> +void
> +bfa_timer_init(struct bfa_timer_mod *mod)
> +{
> +	INIT_LIST_HEAD(&mod->timer_q);
> +}
> +
> +void
> +bfa_timer_beat(struct bfa_timer_mod *mod)
> +{
> +	struct list_head        *qh = &mod->timer_q;
> +	struct list_head        *qe, *qe_next;
> +	struct bfa_timer *elem;
> +	struct list_head         timedout_q;
> +
> +	INIT_LIST_HEAD(&timedout_q);
> +
> +	qe = bfa_q_next(qh);
> +
> +	while (qe != qh) {
> +		qe_next = bfa_q_next(qe);
> +
> +		elem = (struct bfa_timer *) qe;
> +		if (elem->timeout <= BFA_TIMER_FREQ) {
> +			elem->timeout = 0;
> +			list_del(&elem->qe);
> +			list_add_tail(&elem->qe, &timedout_q);
> +		} else {
> +			elem->timeout -= BFA_TIMER_FREQ;
> +		}
> +
> +		qe = qe_next;	/* go to next elem */
> +	}
> +
> +	/*
> +	 * Pop all the timeout entries
> +	 */
> +	while (!list_empty(&timedout_q)) {
> +		bfa_q_deq(&timedout_q, &elem);
> +		elem->timercb(elem->arg);
> +	}
> +}
> +
> +/**
> + * Should be called with lock protection
> + */
> +void
> +bfa_timer_begin(struct bfa_timer_mod *mod, struct bfa_timer *timer,
> +		    void (*timercb) (void *), void *arg, unsigned int timeout)
> +{
> +
> +	bfa_assert(timercb != NULL);
> +	bfa_assert(!bfa_q_is_on_q(&mod->timer_q, timer));
> +
> +	timer->timeout = timeout;
> +	timer->timercb = timercb;
> +	timer->arg = arg;
> +
> +	list_add_tail(&timer->qe, &mod->timer_q);
> +}
> +

Why did you create a layered timer implementation? The existing Linux timers scale
to 1000's of timers.
