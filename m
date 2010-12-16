From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH V7 3/8] posix clocks: introduce dynamic clocks
Date: Thu, 16 Dec 2010 17:16:42 +0100
Message-ID: <201012161716.42520.arnd@arndb.de>
References: <cover.1292512461.git.richard.cochran@omicron.at> <8debe4d48d9a6484b7fbd35d8888524155fed977.1292512461.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	John Stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>,
	Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Rodolfo Giometti <giometti-k2GhghHVRtY@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
To: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <8debe4d48d9a6484b7fbd35d8888524155fed977.1292512461.git.richard.cochran-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thursday 16 December 2010, Richard Cochran wrote:
> This patch adds support for adding and removing posix clocks. The
> clock lifetime cycle is patterned after usb devices. Each clock is
> represented by a standard character device. In addition, the driver
> may optionally implemented custom character device operations.
> 
> The dynamic posix clocks do not yet do anything useful. This patch
> merely provides some needed infrastructure.
> 
> Signed-off-by: Richard Cochran <richard.cochran-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>

> +struct posix_clock_fops {
> +	int (*fasync)  (void *priv, int fd, struct file *file, int on);
> +	int (*mmap)    (void *priv, struct vm_area_struct *vma);
> +	int (*open)    (void *priv, fmode_t f_mode);
> +	int (*release) (void *priv);
> +	long (*ioctl)  (void *priv, unsigned int cmd, unsigned long arg);
> +	long (*compat_ioctl) (void *priv, unsigned int cmd, unsigned long arg);
> +	ssize_t (*read) (void *priv, uint flags, char __user *buf, size_t cnt);
> +	unsigned int (*poll) (void *priv, struct file *file, poll_table *wait);
> +};

Thanks for the change to a private ops structure. Three more
suggestions for this:

* I would recommend starting without a compat_ioctl operation if you can.
Just mandate that all ioctls for posix clocks are compatible and call
fops->ioctl from the posix_clock_compat_ioctl() function.
If you ever need compat_ioctl handling, it can still be added later.

* Instead of passing a void pointer, why not pass a struct posix_clock
pointer to the lower device and use container_of? That follows what
we do in other subsystems and allows you save one allocation, by
including the posix_clock into the specific clock struct like
ptp_clock.

> +struct posix_clock_operations {
> +	struct module *owner;
> +	struct posix_clock_fops fops;
> +	int  (*clock_adjtime)(void *priv, struct timex *tx);

You can easily combine the two structures and get rid of the extra
struct posix_clock_fops by moving its operations into
posix_clock_operations.

Looks really good otherwise.

	Arnd
