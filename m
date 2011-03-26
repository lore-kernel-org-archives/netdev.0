From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH V12 1/4] ptp: Added a brand new class driver for ptp
 clocks.
Date: Sat, 26 Mar 2011 14:12:29 +0100
Message-ID: <20110326131229.GA23260@riccoc20.at.omicron.at>
References: <cover.1298878618.git.richard.cochran@omicron.at>
 <bf964489f4c6ee51bd8a2ab818cd6a5e2f544627.1298878618.git.richard.cochran@omicron.at>
 <1300915160.848.33.camel@work-vm>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Rodolfo Giometti <giometti-k2GhghHVRtY@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
	Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>,
	Mike Frysinger <vapier-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>,
	Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>,
	Russell King <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
To: John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1300915160.848.33.camel@work-vm>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 23, 2011 at 02:19:20PM -0700, John Stultz wrote:
> On Mon, 2011-02-28 at 08:57 +0100, Richard Cochran wrote:
> > +++ b/drivers/ptp/ptp_clock.c
> > @@ -0,0 +1,320 @@
> [snip]
> > +static void enqueue_external_timestamp(struct timestamp_event_queue *queue,
> > +				       struct ptp_clock_event *src)
> > +{
> > +	struct ptp_extts_event *dst;
> > +	unsigned long flags;
> > +	u32 remainder;
> > +
> > +	dst = &queue->buf[queue->tail];
> 
> Doesn't the lock need to happen before you access the
> queue->buf[queue->tail] ? 
> 
> For example: What happens if two cpus enter the function at the same
> time, both get the same tail index, one overwrite the other's data, then
> both take turns bumping up the tail pointer?

Yes, thanks for that catch.

> > +struct timestamp_event_queue {
> > +	struct ptp_extts_event buf[PTP_MAX_TIMESTAMPS];
> > +	int head;
> > +	int tail;
> > +	spinlock_t lock;
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
> q->tail and head access probably need to happen only when locked. 
> 
> So probably need a comment that queue_cnt must be called only when
> holding the proper lock.

In this case, calling without a lock is allowed. However, I'll add
comment like the following.

 * The function queue_cnt() is safe for readers to call without
 * holding q->lock. Readers use this function to verify that the queue
 * is nonempty before proceeding with a dequeue operation. The fact
 * that a writer might concurrently increment the tail does not
 * matter, since the queue remains nonempty nonetheless.

Thanks for your feedback,

Richard
