From: John Stultz <john.stultz@linaro.org>
Subject: Re: [PATCH V12 1/4] ptp: Added a brand new class driver for ptp
 clocks.
Date: Wed, 23 Mar 2011 14:19:20 -0700
Message-ID: <1300915160.848.33.camel@work-vm>
References: <cover.1298878618.git.richard.cochran@omicron.at>
	 <bf964489f4c6ee51bd8a2ab818cd6a5e2f544627.1298878618.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Arnd Bergmann <arnd@arndb.de>,
	Christoph Lameter <cl@linux.com>,
	David Miller <davem@davemloft.net>,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Peter Zijlstra <peterz@infradead.org>,
	Rodolfo Giometti <giometti@linux.it>,
	Thomas Gleixner <tglx@linutronix.de>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Mike Frysinger <vapier@gentoo.org>,
	Paul Mackerras <paulus@samba.org>,
	Russell King <linux@arm.linux.org.uk>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:58507 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932133Ab1CWVTe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2011 17:19:34 -0400
In-Reply-To: <bf964489f4c6ee51bd8a2ab818cd6a5e2f544627.1298878618.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-02-28 at 08:57 +0100, Richard Cochran wrote:
> This patch adds an infrastructure for hardware clocks that implement
> IEEE 1588, the Precision Time Protocol (PTP). A class driver offers a
> registration method to particular hardware clock drivers. Each clock is
> presented as a standard POSIX clock.
> 
> The ancillary clock features are exposed in two different ways, via
> the sysfs and by a character device.
> 
> Signed-off-by: Richard Cochran <richard.cochran@omicron.at>

I think this looks mostly ok. I've got one concern on the locking and
there are a few minor nits that might need extra commenting below. 

thanks
-john

> --- /dev/null
> +++ b/Documentation/ptp/testptp.c
[snip]
> +	if (0x7fffffff != adjfreq) {
> +		memset(&tx, 0, sizeof(tx));
> +		tx.modes = ADJ_FREQUENCY;
> +		tx.freq = (long) (adjfreq * 65.536);

So, 65.536... I understand you're converting ppb to ppm << 16 (which is
what adjtime takes), but I'm not sure if anyone else will. I'd either
wrap that in a commented conversion function/macro or just do the
conversion explicitly (freq = (adjfreq << 16)/1000;  although this has
potential overflow risks with large ppb values) with a comment about
what is going on.

> --- /dev/null
> +++ b/drivers/ptp/ptp_clock.c
> @@ -0,0 +1,320 @@
[snip]
> +static void enqueue_external_timestamp(struct timestamp_event_queue *queue,
> +				       struct ptp_clock_event *src)
> +{
> +	struct ptp_extts_event *dst;
> +	unsigned long flags;
> +	u32 remainder;
> +
> +	dst = &queue->buf[queue->tail];

Doesn't the lock need to happen before you access the
queue->buf[queue->tail] ? 

For example: What happens if two cpus enter the function at the same
time, both get the same tail index, one overwrite the other's data, then
both take turns bumping up the tail pointer?


> +	dst->index = src->index;
> +	dst->t.sec = div_u64_rem(src->timestamp, 1000000000, &remainder);
> +	dst->t.nsec = remainder;
> +
> +	spin_lock_irqsave(&queue->lock, flags);
> +
> +	if (!queue_free(queue))
> +		queue->head = (queue->head + 1) % PTP_MAX_TIMESTAMPS;
> +
> +	queue->tail = (queue->tail + 1) % PTP_MAX_TIMESTAMPS;
> +
> +	spin_unlock_irqrestore(&queue->lock, flags);
> +}
[snip]
> +static int ptp_clock_adjtime(struct posix_clock *pc, struct timex *tx)
> +{
> +	struct ptp_clock *ptp = container_of(pc, struct ptp_clock, clock);
> +	struct ptp_clock_info *ops;
> +	int err = -EOPNOTSUPP;
> +
> +	ops = ptp->info;
> +
> +	if (tx->modes & ADJ_SETOFFSET) {
> +		struct timespec ts;
> +		ktime_t kt;
> +		s64 delta;
> +
> +		ts.tv_sec  = tx->time.tv_sec;
> +		ts.tv_nsec = tx->time.tv_usec;
> +
> +		if (!(tx->modes & ADJ_NANO))
> +			ts.tv_nsec *= 1000;
> +
> +		if ((unsigned long) ts.tv_nsec >= NSEC_PER_SEC)
> +			return -EINVAL;
> +
> +		kt = timespec_to_ktime(ts);
> +		delta = ktime_to_ns(kt);
> +		err = ops->adjtime(ops, delta);
> +
> +	} else if (tx->modes & ADJ_FREQUENCY) {
> +		s64 ppb = 1 + tx->freq;
> +		ppb *= 125;
> +		ppb >>= 13;

((1 + freq) *125)>>13 == magic :)
Needs a clear comment.

> +		err = ops->adjfreq(ops, (s32)ppb);
> +	}
> +
> +	return err;
> +}

[snip]

> diff --git a/drivers/ptp/ptp_private.h b/drivers/ptp/ptp_private.h
> new file mode 100644
> index 0000000..2f76266
> --- /dev/null
> +++ b/drivers/ptp/ptp_private.h
> @@ -0,0 +1,86 @@
> +/*
> + * PTP 1588 clock support - private declarations for the core module.
> + *
> + * Copyright (C) 2010 OMICRON electronics GmbH
> + *
> + *  This program is free software; you can redistribute it and/or modify
> + *  it under the terms of the GNU General Public License as published by
> + *  the Free Software Foundation; either version 2 of the License, or
> + *  (at your option) any later version.
> + *
> + *  This program is distributed in the hope that it will be useful,
> + *  but WITHOUT ANY WARRANTY; without even the implied warranty of
> + *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + *  GNU General Public License for more details.
> + *
> + *  You should have received a copy of the GNU General Public License
> + *  along with this program; if not, write to the Free Software
> + *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
> + */
> +#ifndef _PTP_PRIVATE_H_
> +#define _PTP_PRIVATE_H_
> +
> +#include <linux/cdev.h>
> +#include <linux/device.h>
> +#include <linux/mutex.h>
> +#include <linux/posix-clock.h>
> +#include <linux/ptp_clock.h>
> +#include <linux/ptp_clock_kernel.h>
> +#include <linux/time.h>
> +
> +#define PTP_MAX_TIMESTAMPS 128
> +#define PTP_BUF_TIMESTAMPS 30
> +
> +struct timestamp_event_queue {
> +	struct ptp_extts_event buf[PTP_MAX_TIMESTAMPS];
> +	int head;
> +	int tail;
> +	spinlock_t lock;
> +};
> +
> +struct ptp_clock {
> +	struct posix_clock clock;
> +	struct device *dev;
> +	struct ptp_clock_info *info;
> +	dev_t devid;
> +	int index; /* index into clocks.map */
> +	struct pps_device *pps_source;
> +	struct timestamp_event_queue tsevq; /* simple fifo for time stamps */
> +	struct mutex tsevq_mux; /* one process at a time reading the fifo */
> +	wait_queue_head_t tsev_wq;
> +};
> +
> +static inline int queue_cnt(struct timestamp_event_queue *q)
> +{
> +	int cnt = q->tail - q->head;
> +	return cnt < 0 ? PTP_MAX_TIMESTAMPS + cnt : cnt;
> +}

q->tail and head access probably need to happen only when locked. 

So probably need a comment that queue_cnt must be called only when
holding the proper lock.


thanks
-john


