From: John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH V10 12/15] ptp: Added a brand new class driver for ptp
 clocks.
Date: Tue, 01 Feb 2011 18:00:31 -0800
Message-ID: <1296612031.3336.201.camel@work-vm>
References: <cover.1296124770.git.richard.cochran@omicron.at>
	 <ada07b1d09b1e8eb717c5203e64856d2eaad7456.1296124770.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Rodolfo Giometti <giometti-k2GhghHVRtY@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
	Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Mike Frysinger <vapier-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>,
	Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>,
	Russell King <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
To: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <ada07b1d09b1e8eb717c5203e64856d2eaad7456.1296124770.git.richard.cochran-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2011-01-27 at 11:59 +0100, Richard Cochran wrote:
> This patch adds an infrastructure for hardware clocks that implement
> IEEE 1588, the Precision Time Protocol (PTP). A class driver offers a
> registration method to particular hardware clock drivers. Each clock is
> presented as a standard POSIX clock.
> 
> The ancillary clock features are exposed in two different ways, via
> the sysfs and by a character device.
> 
> Signed-off-by: Richard Cochran <richard.cochran-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>

Few issues below.


> diff --git a/drivers/ptp/Kconfig b/drivers/ptp/Kconfig
> new file mode 100644
> index 0000000..17be208
> --- /dev/null
> +++ b/drivers/ptp/Kconfig
> @@ -0,0 +1,27 @@
> +#
> +# PTP clock support configuration
> +#
> +
> +menu "PTP clock support"
> +
> +config PTP_1588_CLOCK
> +	tristate "PTP clock support"
> +	depends on EXPERIMENTAL
> +	depends on PPS
> +	help
> +	  The IEEE 1588 standard defines a method to precisely
> +	  synchronize distributed clocks over Ethernet networks. The
> +	  standard defines a Precision Time Protocol (PTP), which can
> +	  be used to achieve synchronization within a few dozen
> +	  microseconds. In addition, with the help of special hardware
> +	  time stamping units, it can be possible to achieve
> +	  synchronization to within a few hundred nanoseconds.
> +
> +	  This driver adds support for PTP clocks as character
> +	  devices. If you want to use a PTP clock, then you should
> +	  also enable at least one clock driver as well.
> +
> +	  To compile this driver as a module, choose M here: the module
> +	  will be called ptp.
> +
> +endmenu

You may want to tweak the kconfig a bit here. If I don't have pps
enabled, if I go into the "PTP clock support" page, I get an empty
screen.

Similarly, its not very discoverable to figure out what you need to
enable to get the driver options to show up, as they depend the drivers
enabled in the networking device section.




> diff --git a/drivers/ptp/ptp_clock.c b/drivers/ptp/ptp_clock.c
> new file mode 100644
> index 0000000..cd2b5e5
> --- /dev/null
> +++ b/drivers/ptp/ptp_clock.c
> @@ -0,0 +1,315 @@
> +/*
> + * PTP 1588 clock support
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
> +#include <linux/bitops.h>
> +#include <linux/device.h>
> +#include <linux/err.h>
> +#include <linux/init.h>
> +#include <linux/kernel.h>
> +#include <linux/module.h>
> +#include <linux/posix-clock.h>
> +#include <linux/pps_kernel.h>
> +#include <linux/slab.h>
> +#include <linux/syscalls.h>
> +#include <linux/uaccess.h>
> +
> +#include "ptp_private.h"
> +
> +#define PTP_MAX_ALARMS 4
> +#define PTP_MAX_CLOCKS (MAX_CLOCKS/2)

Why MAX_CLOCKS/2 ? Should this scale as MAX_CLOCKS is increased?
Or do you really just mean 8?

> +#define PTP_PPS_DEFAULTS (PPS_CAPTUREASSERT | PPS_OFFSETASSERT)
> +#define PTP_PPS_EVENT PPS_CAPTUREASSERT
> +#define PTP_PPS_MODE (PTP_PPS_DEFAULTS | PPS_CANWAIT | PPS_TSFMT_TSPEC)
> +
> +/* private globals */
> +
> +static dev_t ptp_devt;
> +static struct class *ptp_class;
> +
> +static DECLARE_BITMAP(ptp_clocks_map, PTP_MAX_CLOCKS);
> +static DEFINE_MUTEX(ptp_clocks_mutex); /* protects 'ptp_clocks_map' */
> +
> +/* time stamp event queue operations */
> +
> +static inline int queue_free(struct timestamp_event_queue *q)
> +{
> +	return PTP_MAX_TIMESTAMPS - queue_cnt(q) - 1;
> +}
> +
> +static void enqueue_external_timestamp(struct timestamp_event_queue *queue,
> +				       struct ptp_clock_event *src)
> +{
> +	struct ptp_extts_event *dst;
> +	u32 remainder;
> +
> +	dst = &queue->buf[queue->tail];
> +
> +	dst->index = src->index;
> +	dst->t.sec = div_u64_rem(src->timestamp, 1000000000, &remainder);
> +	dst->t.nsec = remainder;
> +
> +	if (!queue_free(queue))
> +		queue->overflow++;
> +
> +	queue->tail = (queue->tail + 1) % PTP_MAX_TIMESTAMPS;
> +}

So what is serializing access to the timestamp_event_queue here? I don't
see any usage of tsevq_mux by the callers. Am I missing it? It looks
like its called from interrupt context, so do you really need a spinlock
and not a mutex here?


> diff --git a/drivers/ptp/ptp_private.h b/drivers/ptp/ptp_private.h
> new file mode 100644
> index 0000000..941de61
> --- /dev/null
> +++ b/drivers/ptp/ptp_private.h
> @@ -0,0 +1,85 @@
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
> +
> +struct timestamp_event_queue {
> +	struct ptp_extts_event buf[PTP_MAX_TIMESTAMPS];
> +	int head;
> +	int tail;
> +	int overflow;
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

This probably needs a comment as to its locking rules. Something like
"Callers must hold tsevq_mux."



> diff --git a/include/linux/ptp_clock.h b/include/linux/ptp_clock.h
> new file mode 100644
> index 0000000..b4ef2cb
> --- /dev/null
> +++ b/include/linux/ptp_clock.h
> @@ -0,0 +1,79 @@
> +/*
> + * PTP 1588 clock support - user space interface
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
> +
> +#ifndef _PTP_CLOCK_H_
> +#define _PTP_CLOCK_H_
> +
> +#include <linux/ioctl.h>
> +#include <linux/types.h>
> +
> +/* PTP_xxx bits, for the flags field within the request structures. */
> +#define PTP_ENABLE_FEATURE (1<<0)
> +#define PTP_RISING_EDGE    (1<<1)
> +#define PTP_FALLING_EDGE   (1<<2)
> +
> +/*
> + * struct ptp_clock_time - represents a time value
> + *
> + * The sign of the seconds field applies to the whole value. The
> + * nanoseconds field is always unsigned. The reserved field is
> + * included for sub-nanosecond resolution, should the demand for
> + * this ever appear.
> + *
> + */
> +struct ptp_clock_time {
> +	__s64 sec;  /* seconds */
> +	__u32 nsec; /* nanoseconds */
> +	__u32 reserved;
> +};
> +
> +struct ptp_clock_caps {
> +	int max_adj;   /* Maximum frequency adjustment in parts per billon. */
> +	int n_alarm;   /* Number of programmable alarms. */
> +	int n_ext_ts;  /* Number of external time stamp channels. */
> +	int n_per_out; /* Number of programmable periodic signals. */
> +	int pps;       /* Whether the clock supports a PPS callback. */
> +};
> +
> +struct ptp_extts_request {
> +	unsigned int index; /* Which channel to configure. */
> +	unsigned int flags; /* Bit field for PTP_xxx flags. */
> +};
> +
> +struct ptp_perout_request {
> +	struct ptp_clock_time start;  /* Absolute start time. */
> +	struct ptp_clock_time period; /* Desired period, zero means disable. */
> +	unsigned int index;           /* Which channel to configure. */
> +	unsigned int flags;           /* Reserved for future use. */
> +};

Since these are all new API/ABI structures, would it be wise to pad
these out a bit more? You've got a couple of reserved fields, which is
good, but if you think we're going to expand this at all, we may want to
have a bit more wiggle room. The timex structure had something like 12
unused ints (which came in handy when the tai field was added).

Not sure what the wider opinion is on this though.


> +#define PTP_CLK_MAGIC '='
> +
> +#define PTP_CLOCK_GETCAPS  _IOR(PTP_CLK_MAGIC, 1, struct ptp_clock_caps)
> +#define PTP_EXTTS_REQUEST  _IOW(PTP_CLK_MAGIC, 2, struct ptp_extts_request)
> +#define PTP_PEROUT_REQUEST _IOW(PTP_CLK_MAGIC, 3, struct ptp_perout_request)
> +#define PTP_ENABLE_PPS     _IOW(PTP_CLK_MAGIC, 4, int)
> +
> +struct ptp_extts_event {
> +	struct ptp_clock_time t; /* Time event occured. */
> +	unsigned int index;      /* Which channel produced the event. */
> +};

Same padding suggestion for this as well.


thanks
-john
