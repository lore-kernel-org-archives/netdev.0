From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH V7 3/8] posix clocks: introduce dynamic clocks
Date: Thu, 16 Dec 2010 21:56:38 +0100 (CET)
Message-ID: <alpine.LFD.2.00.1012161939340.12146@localhost6.localdomain6>
References: <cover.1292512461.git.richard.cochran@omicron.at> <8debe4d48d9a6484b7fbd35d8888524155fed977.1292512461.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Arnd Bergmann <arnd@arndb.de>,
	Christoph Lameter <cl@linux.com>,
	David Miller <davem@davemloft.net>,
	John Stultz <johnstul@us.ibm.com>,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Peter Zijlstra <peterz@infradead.org>,
	Rodolfo Giometti <giometti@linux.it>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.tglx.de ([62.245.132.106]:35307 "EHLO www.tglx.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756591Ab0LPU5X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Dec 2010 15:57:23 -0500
In-Reply-To: <8debe4d48d9a6484b7fbd35d8888524155fed977.1292512461.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 16 Dec 2010, Richard Cochran wrote:

> --- /dev/null
> +++ b/include/linux/posix-clock.h
> +/**
> + * struct posix_clock_fops - character device operations
> + *
> + * Every posix clock is represented by a character device. Drivers may
> + * optionally offer extended capabilities by implementing these
> + * functions. The character device file operations are first handled
> + * by the clock device layer, then passed on to the driver by calling
> + * these functions.
> + *
> + * The clock device layer already uses fp->private_data, so drivers
> + * are provided their private data via the 'priv' paramenter.
> + */
> +void *posix_clock_private(struct file *fp);

Leftover ? There is neither a caller nor an implementation

> +struct posix_clock_fops {
> +	int (*fasync)  (void *priv, int fd, struct file *file, int on);
> +	int (*mmap)    (void *priv, struct vm_area_struct *vma);
> +	int (*open)    (void *priv, fmode_t f_mode);
> +	int (*release) (void *priv);
> +	long (*ioctl)  (void *priv, unsigned int cmd, unsigned long arg);
> +	long (*compat_ioctl) (void *priv, unsigned int cmd, unsigned long arg);

Do we really need a compat_ioctl ?

> +	ssize_t (*read) (void *priv, uint flags, char __user *buf, size_t cnt);
> +	unsigned int (*poll) (void *priv, struct file *file, poll_table *wait);

> --- a/kernel/time/Makefile
> +++ b/kernel/time/Makefile
> @@ -1,4 +1,5 @@
> -obj-y += timekeeping.o ntp.o clocksource.o jiffies.o timer_list.o timecompare.o timeconv.o
> +obj-y += timekeeping.o ntp.o clocksource.o jiffies.o timer_list.o \
> +timecompare.o timeconv.o posix-clock.o

Please start a new obj-y += line instead
  
> --- /dev/null
> +++ b/kernel/time/posix-clock.c
> +
> +#define MAX_CLKDEV BITS_PER_LONG

Please put some more space between the MAX_CLKDEV and BITS_PER_LONG. I
had to look three times to not read it as a single word.

> +static DECLARE_BITMAP(clocks_map, MAX_CLKDEV);
> +static DEFINE_MUTEX(clocks_mutex); /* protects 'clocks_map' */

Please avoid tail comments

> +struct posix_clock {
> +	struct posix_clock_operations *ops;
> +	struct cdev cdev;
> +	struct kref kref;
> +	struct mutex mux;
> +	void *priv;

You can get away with that private pointer and all the void *
arguments to the various posix_clock_operations, if you mandate that
the posix_clock_operations are embedded into a clock specific data
structure.

So void *priv would become struct posix_clock_operations *clkops and
you can get your private data in the clock implementation with
container_of().

> +	int index;
> +	bool zombie;

Ths field is only set, but nowhere else used. What's the purpose ?
Leftover ?

> +};
> +

> +static void delete_clock(struct kref *kref);
> +
> +
> +static int posix_clock_open(struct inode *inode, struct file *fp)
> +{
> +	struct posix_clock *clk =
> +		container_of(inode->i_cdev, struct posix_clock, cdev);
> +
> +	kref_get(&clk->kref);
> +	fp->private_data = clk;

fp->private_data should only be set on success. And this will leak a
ref count when the clock open function fails.

What's that kref protecting here ?

> +
> +	if (clk->ops->fops.open)
> +		return clk->ops->fops.open(clk->priv, fp->f_mode);
> +	else
> +		return 0;
> +}
> +
> +static int posix_clock_release(struct inode *inode, struct file *fp)
> +{
> +	struct posix_clock *clk = fp->private_data;
> +	int err = 0;

fp->private_data should be set to NULL in the release function.

> +	if (clk->ops->fops.release)
> +		err = clk->ops->fops.release(clk->priv);
> +
> +	kref_put(&clk->kref, delete_clock);

> +struct posix_clock *posix_clock_create(struct posix_clock_operations *cops,
> +				       dev_t devid, void *priv)
> +{
> +	struct posix_clock *clk;
> +	int err;
> +
> +	mutex_lock(&clocks_mutex);
> +
> +	err = -ENOMEM;
> +	clk = kzalloc(sizeof(*clk), GFP_KERNEL);
> +	if (!clk)
> +		goto no_memory;
> +
> +	err = -EBUSY;
> +	clk->index = find_first_zero_bit(clocks_map, MAX_CLKDEV);
> +	if (clk->index < MAX_CLKDEV)
> +		set_bit(clk->index, clocks_map);
> +	else
> +		goto no_index;

	if (clk->index >= MAX_CLKDEV)
		goto no_index;

	set_bit(clk->index, clocks_map);

Makes it better readable.

> +static void delete_clock(struct kref *kref)
> +{
> +	struct posix_clock *clk =
> +		container_of(kref, struct posix_clock, kref);
> +
> +	mutex_lock(&clocks_mutex);
> +	clear_bit(clk->index, clocks_map);
> +	mutex_unlock(&clocks_mutex);
> +
> +	mutex_destroy(&clk->mux);
> +	kfree(clk);
> +}
> +
> +void posix_clock_destroy(struct posix_clock *clk)
> +{
> +	cdev_del(&clk->cdev);
> +
> +	mutex_lock(&clk->mux);
> +	clk->zombie = true;
> +	mutex_unlock(&clk->mux);
> +
> +	kref_put(&clk->kref, delete_clock);

I still have some headache to understand that kref / delete_clock
magic here.

Thanks,

	tglx
