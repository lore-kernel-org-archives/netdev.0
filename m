From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH V10 12/15] ptp: Added a brand new class driver for ptp
 clocks.
Date: Fri, 11 Feb 2011 09:15:24 +0100
Message-ID: <20110211081524.GA12270@riccoc20.at.omicron.at>
References: <cover.1296124770.git.richard.cochran@omicron.at>
 <ada07b1d09b1e8eb717c5203e64856d2eaad7456.1296124770.git.richard.cochran@omicron.at>
 <1296612031.3336.201.camel@work-vm>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
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
To: John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1296612031.3336.201.camel@work-vm>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 01, 2011 at 06:00:31PM -0800, John Stultz wrote:
> On Thu, 2011-01-27 at 11:59 +0100, Richard Cochran wrote:

> You may want to tweak the kconfig a bit here. If I don't have pps
> enabled, if I go into the "PTP clock support" page, I get an empty
> screen.
> 
> Similarly, its not very discoverable to figure out what you need to
> enable to get the driver options to show up, as they depend the drivers
> enabled in the networking device section.

Okay, I'll see what I can come up with.

> > +#define PTP_MAX_ALARMS 4
> > +#define PTP_MAX_CLOCKS (MAX_CLOCKS/2)
> 
> Why MAX_CLOCKS/2 ? Should this scale as MAX_CLOCKS is increased?
> Or do you really just mean 8?

This is just left over from when I thought the PHCs would use the
static clock IDs. I'll fix that.

> > +static void enqueue_external_timestamp(struct timestamp_event_queue *queue,
> > +				       struct ptp_clock_event *src)
> > +{
> > +	struct ptp_extts_event *dst;
> > +	u32 remainder;
> > +
> > +	dst = &queue->buf[queue->tail];
> > +
> > +	dst->index = src->index;
> > +	dst->t.sec = div_u64_rem(src->timestamp, 1000000000, &remainder);
> > +	dst->t.nsec = remainder;
> > +
> > +	if (!queue_free(queue))
> > +		queue->overflow++;
> > +
> > +	queue->tail = (queue->tail + 1) % PTP_MAX_TIMESTAMPS;
> > +}
> 
> So what is serializing access to the timestamp_event_queue here? I don't
> see any usage of tsevq_mux by the callers. Am I missing it? It looks
> like its called from interrupt context, so do you really need a spinlock
> and not a mutex here?

The external timestamp FIFO is written only from interrupt context.
The readers are from user space via read() or sysfs. The readers must
hold a mutex. As you know, FIFOs with exactly one reader and one
writer don't need locking.

However, looking again at my own code (after spending a long time in
the posicx clock stuff), I notice that, although FIFO overflow is
detected, I do not offer a way for user space to find this out or to
clear the error. I'll fix that.

> > +#define PTP_MAX_TIMESTAMPS 128
> > +
> > +struct timestamp_event_queue {
> > +	struct ptp_extts_event buf[PTP_MAX_TIMESTAMPS];
> > +	int head;
> > +	int tail;
> > +	int overflow;
> > +};
> > +
> > +struct ptp_clock {
> > +	struct posix_clock clock;
> > +	struct device *dev;
> > +	struct ptp_clock_info *info;
> > +	dev_t devid;
> > +	int index; /* index into clocks.map */
> > +	struct pps_device *pps_source;
> > +	struct timestamp_event_queue tsevq; /* simple fifo for time stamps */
> > +	struct mutex tsevq_mux; /* one process at a time reading the fifo */
> > +	wait_queue_head_t tsev_wq;
> > +};
> > +
> > +static inline int queue_cnt(struct timestamp_event_queue *q)
> > +{
> > +	int cnt = q->tail - q->head;
> > +	return cnt < 0 ? PTP_MAX_TIMESTAMPS + cnt : cnt;
> > +}
> 
> This probably needs a comment as to its locking rules. Something like
> "Callers must hold tsevq_mux."

I'll add a comment explaining the readers mutex and why no
reader/writer locking is needed.

> > +struct ptp_clock_time {
> > +	__s64 sec;  /* seconds */
> > +	__u32 nsec; /* nanoseconds */
> > +	__u32 reserved;
> > +};
> > +
> > +struct ptp_clock_caps {
> > +	int max_adj;   /* Maximum frequency adjustment in parts per billon. */
> > +	int n_alarm;   /* Number of programmable alarms. */
> > +	int n_ext_ts;  /* Number of external time stamp channels. */
> > +	int n_per_out; /* Number of programmable periodic signals. */
> > +	int pps;       /* Whether the clock supports a PPS callback. */
> > +};
> > +
> > +struct ptp_extts_request {
> > +	unsigned int index; /* Which channel to configure. */
> > +	unsigned int flags; /* Bit field for PTP_xxx flags. */
> > +};
> > +
> > +struct ptp_perout_request {
> > +	struct ptp_clock_time start;  /* Absolute start time. */
> > +	struct ptp_clock_time period; /* Desired period, zero means disable. */
> > +	unsigned int index;           /* Which channel to configure. */
> > +	unsigned int flags;           /* Reserved for future use. */
> > +};
> 
> Since these are all new API/ABI structures, would it be wise to pad
> these out a bit more? You've got a couple of reserved fields, which is
> good, but if you think we're going to expand this at all, we may want to
> have a bit more wiggle room. The timex structure had something like 12
> unused ints (which came in handy when the tai field was added).
> 
> Not sure what the wider opinion is on this though.

Okay, I'll pad them a bit more.

However, I don't intend to ever offer more than simple functionality
here. A general purpose DAQ API is not so easy to define (look at
comedi, for example). Also, the capabilities of the current crop of
clocks varies quite a bit.

So, I think the PHC should offer a PPS, simple period outputs, and
simple external timestamping. If someone want more complex DAQ like
functions, then they can offer that through comedi or whatever.

> > +struct ptp_extts_event {
> > +	struct ptp_clock_time t; /* Time event occured. */
> > +	unsigned int index;      /* Which channel produced the event. */
> > +};
> 
> Same padding suggestion for this as well.

Okay, and thanks for the review,

Richard
