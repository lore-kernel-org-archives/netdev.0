From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH 1/5] ptp: Added a brand new class driver for ptp clocks.
Date: Mon, 16 Aug 2010 16:26:23 +0200
Message-ID: <201008161626.24083.arnd@arndb.de>
References: <cover.1281956490.git.richard.cochran@omicron.at>
	<363bd749a38d0b785d8431e591bf54c38db4c2d7.1281956490.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Rodolfo Giometti <giometti-k2GhghHVRtY@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>
To: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <363bd749a38d0b785d8431e591bf54c38db4c2d7.1281956490.git.richard.cochran-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Monday 16 August 2010, Richard Cochran wrote:
> This patch adds an infrastructure for hardware clocks that implement
> IEEE 1588, the Precision Time Protocol (PTP). A class driver offers a
> registration method to particular hardware clock drivers. Each clock is
> exposed to user space as a character device with ioctls that allow tuning
> of the PTP clock.

Have you considered integrating the subsystem into the Posix clock/timer
framework?

I can't really tell from reading the source if this is possible or
not, but my feeling is that if it can be done, that would be a much
nicer interface. We already have clock_gettime/clock_settime/
timer_settime/... system calls, and while you'd need to add another
clockid and some syscalls, my feeling is that it will be more
usable in the end.

> +static const struct file_operations ptp_fops = {
> +       .owner          = THIS_MODULE,
> +       .ioctl          = ptp_ioctl,
> +       .open           = ptp_open,
> +       .poll           = ptp_poll,
> +       .read           = ptp_read,
> +       .release        = ptp_release,
> +};

.ioctl is gone, you have to use .unlocked_ioctl and make sure that
your ptp_ioctl function can handle being called concurrently.

You should also add a .compat_ioctl function, ideally one that
points to ptp_ioctl so you don't have to list every command as
being compatible. Right now, some commands are incompatible,
which means you need more changes to the interface.

> +struct ptp_clock_timer {
> +       int alarm_index;       /* Which alarm to query or configure. */
> +       int signum;            /* Requested signal. */
> +       int flags;             /* Zero or TIMER_ABSTIME, see TIMER_SETTIME(2) */
> +       struct itimerspec tsp; /* See TIMER_SETTIME(2) */
> +};

This data structure is incompatible between 32 and 64 bit user space,
so you would need a compat_ioctl() function to convert between the
two formats. Better define the structure in a compatible way, avoiding
variable-length fields and implicit padding.

> +struct ptp_clock_request {
> +       int type;  /* One of the ptp_request_types enumeration values. */
> +       int index; /* Which channel to configure. */
> +       struct timespec ts; /* For period signals, the desired period. */
> +       int flags; /* Bit field for PTP_ENABLE_FEATURE or other flags. */
> +};

Same problem here, timespec is either 64 or 128 bits long and has different
alignment.

> +struct ptp_extts_event {
> +       int index;
> +       struct timespec ts;
> +};

here too.

> +#define PTP_CLOCK_VERSION 0x00000001
> +
> +#define PTP_CLK_MAGIC '='
> +
> +#define PTP_CLOCK_APIVERS _IOR (PTP_CLK_MAGIC, 1, __u32)

Try avoiding versioned ABIs. It's better to just add new ioctls
or syscalls when you need some extra functionality and leave the
old ones around.

> +#define PTP_CLOCK_ADJTIME _IOW (PTP_CLK_MAGIC, 3, struct timespec)
> +#define PTP_CLOCK_GETTIME _IOR (PTP_CLK_MAGIC, 4, struct timespec)
> +#define PTP_CLOCK_SETTIME _IOW (PTP_CLK_MAGIC, 5, struct timespec)

These are also incompatible.

	Arnd
