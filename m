From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 08/12] ptp: Added a brand new class driver for ptp clocks.
Date: Tue, 15 Jun 2010 13:11:30 -0600
Message-ID: <AANLkTinYjzfChsN0AB5W6kOh6xJYPJtoEq941pG8WbmS@mail.gmail.com>
References: <cover.1276615626.git.richard.cochran@omicron.at>
	<4a030d2bace90f089f2f3f61496b918c6f1dfb52.1276615626.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-arm-kernel@lists.infradead.org,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Thomas Gleixner <tglx@linutronix.de>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:47120 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932189Ab0FOTLx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 15:11:53 -0400
Received: by gye5 with SMTP id 5so3473522gye.19
        for <netdev@vger.kernel.org>; Tue, 15 Jun 2010 12:11:52 -0700 (PDT)
In-Reply-To: <4a030d2bace90f089f2f3f61496b918c6f1dfb52.1276615626.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 15, 2010 at 10:09 AM, Richard Cochran
<richardcochran@gmail.com> wrote:
> This patch adds an infrastructure for hardware clocks that implement
> IEEE 1588, the Precision Time Protocol (PTP). A class driver offers a
> registration method to particular hardware clock drivers. Each clock =
is
> exposed to user space as a character device with ioctls that allow tu=
ning
> of the PTP clock.
>
> Signed-off-by: Richard Cochran <richard.cochran@omicron.at>

Hi Richard,

Some more comments on this patch...

> ---
> =A0Documentation/ptp/ptp.txt =A0 =A0 =A0 =A0| =A0 95 +++++++
> =A0Documentation/ptp/testptp.c =A0 =A0 =A0| =A0269 ++++++++++++++++++=
++
> =A0Documentation/ptp/testptp.mk =A0 =A0 | =A0 33 +++
> =A0drivers/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A02 +
> =A0drivers/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A01 +
> =A0drivers/ptp/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 26 ++
> =A0drivers/ptp/Makefile =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A05 +
> =A0drivers/ptp/ptp_clock.c =A0 =A0 =A0 =A0 =A0| =A0514 ++++++++++++++=
++++++++++++++++++++++++
> =A0include/linux/Kbuild =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A01 +
> =A0include/linux/ptp_clock.h =A0 =A0 =A0 =A0| =A0 79 ++++++
> =A0include/linux/ptp_clock_kernel.h | =A0137 ++++++++++
> =A011 files changed, 1162 insertions(+), 0 deletions(-)
> =A0create mode 100644 Documentation/ptp/ptp.txt
> =A0create mode 100644 Documentation/ptp/testptp.c
> =A0create mode 100644 Documentation/ptp/testptp.mk
> =A0create mode 100644 drivers/ptp/Kconfig
> =A0create mode 100644 drivers/ptp/Makefile
> =A0create mode 100644 drivers/ptp/ptp_clock.c
> =A0create mode 100644 include/linux/ptp_clock.h
> =A0create mode 100644 include/linux/ptp_clock_kernel.h
>
> diff --git a/drivers/ptp/Makefile b/drivers/ptp/Makefile
> new file mode 100644
> index 0000000..b86695c
> --- /dev/null
> +++ b/drivers/ptp/Makefile
> @@ -0,0 +1,5 @@
> +#
> +# Makefile for PTP 1588 clock support.
> +#
> +
> +obj-$(CONFIG_PTP_1588_CLOCK) =A0 =A0 =A0 =A0 =A0 +=3D ptp_clock.o
> diff --git a/drivers/ptp/ptp_clock.c b/drivers/ptp/ptp_clock.c
> new file mode 100644
> index 0000000..4753bf3
> --- /dev/null
> +++ b/drivers/ptp/ptp_clock.c
> @@ -0,0 +1,514 @@
> +/*
> + * PTP 1588 clock support
> + *
> + * Partially adapted from the Linux PPS driver.
> + *
> + * Copyright (C) 2010 OMICRON electronics GmbH
> + *
> + * =A0This program is free software; you can redistribute it and/or =
modify
> + * =A0it under the terms of the GNU General Public License as publis=
hed by
> + * =A0the Free Software Foundation; either version 2 of the License,=
 or
> + * =A0(at your option) any later version.
> + *
> + * =A0This program is distributed in the hope that it will be useful=
,
> + * =A0but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * =A0MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. =A0See th=
e
> + * =A0GNU General Public License for more details.
> + *
> + * =A0You should have received a copy of the GNU General Public Lice=
nse
> + * =A0along with this program; if not, write to the Free Software
> + * =A0Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
> + */
> +#include <linux/bitops.h>
> +#include <linux/cdev.h>
> +#include <linux/device.h>
> +#include <linux/init.h>
> +#include <linux/kernel.h>
> +#include <linux/list.h>
> +#include <linux/module.h>
> +#include <linux/poll.h>
> +#include <linux/sched.h>
> +#include <linux/slab.h>
> +#include <linux/uaccess.h>
> +
> +#include <linux/ptp_clock_kernel.h>
> +#include <linux/ptp_clock.h>
> +
> +#define PTP_MAX_ALARMS 4
> +#define PTP_MAX_CLOCKS BITS_PER_LONG
> +#define PTP_MAX_TIMESTAMPS 128
> +
> +struct alarm {
> + =A0 =A0 =A0 struct pid *pid;
> + =A0 =A0 =A0 int sig;
> +};
> +
> +struct timestamp_event_queue {
> + =A0 =A0 =A0 struct ptp_extts_event buf[PTP_MAX_TIMESTAMPS];
> + =A0 =A0 =A0 int head;
> + =A0 =A0 =A0 int tail;
> + =A0 =A0 =A0 int overflow;
> +};
> +
> +struct ptp_clock {
> + =A0 =A0 =A0 struct list_head list;
> + =A0 =A0 =A0 struct cdev cdev;
> + =A0 =A0 =A0 struct device *dev;
> + =A0 =A0 =A0 struct ptp_clock_info *info;
> + =A0 =A0 =A0 dev_t devid;
> + =A0 =A0 =A0 int index; /* index into clocks.map, also the minor num=
ber */
> +
> + =A0 =A0 =A0 struct alarm alarm[PTP_MAX_ALARMS];
> + =A0 =A0 =A0 struct mutex alarm_mux; /* one process at a time settin=
g an alarm */
> +
> + =A0 =A0 =A0 struct timestamp_event_queue tsevq; /* simple fifo for =
time stamps */
> + =A0 =A0 =A0 struct mutex tsevq_mux; /* one process at a time readin=
g the fifo */
> + =A0 =A0 =A0 wait_queue_head_t tsev_wq;
> +};
> +
> +/* private globals */
> +
> +static const struct file_operations ptp_fops;
> +static dev_t ptp_devt;
> +static struct class *ptp_class;
> +
> +static struct {
> + =A0 =A0 =A0 struct list_head list;
> + =A0 =A0 =A0 DECLARE_BITMAP(map, PTP_MAX_CLOCKS);
> +} clocks;
> +static DEFINE_SPINLOCK(clocks_lock); /* protects 'clocks' */

Doesn't appear that clocks is manipulated at atomic context.  Mutex ins=
tead?

> +
> +/* time stamp event queue operations */
> +
> +static inline int queue_cnt(struct timestamp_event_queue *q)
> +{
> + =A0 =A0 =A0 int cnt =3D q->tail - q->head;
> + =A0 =A0 =A0 return cnt < 0 ? PTP_MAX_TIMESTAMPS + cnt : cnt;
> +}
> +
> +static inline int queue_free(struct timestamp_event_queue *q)
> +{
> + =A0 =A0 =A0 return PTP_MAX_TIMESTAMPS - queue_cnt(q) - 1;
> +}
> +
> +static void enqueue_external_timestamp(struct timestamp_event_queue =
*queue,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0struct ptp_clock_event *src)
> +{
> + =A0 =A0 =A0 struct ptp_extts_event *dst;
> + =A0 =A0 =A0 u32 remainder;
> +
> + =A0 =A0 =A0 dst =3D &queue->buf[queue->tail];
> +
> + =A0 =A0 =A0 dst->index =3D src->index;
> + =A0 =A0 =A0 dst->ts.tv_sec =3D div_u64_rem(src->timestamp, 10000000=
00, &remainder);
> + =A0 =A0 =A0 dst->ts.tv_nsec =3D remainder;
> +
> + =A0 =A0 =A0 if (!queue_free(queue))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 queue->overflow++;
> +
> + =A0 =A0 =A0 queue->tail =3D (queue->tail + 1) % PTP_MAX_TIMESTAMPS;
> +}
> +
> +/* public interface */
> +
> +struct ptp_clock *ptp_clock_register(struct ptp_clock_info *info)
> +{
> + =A0 =A0 =A0 struct ptp_clock *ptp;
> + =A0 =A0 =A0 int err =3D 0, index, major =3D MAJOR(ptp_devt);
> + =A0 =A0 =A0 unsigned long flags;
> +
> + =A0 =A0 =A0 if (info->n_alarm > PTP_MAX_ALARMS)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ERR_PTR(-EINVAL);

Okay, this is my opinion here, and other maintainers may disagree with
me, but the ERR_PTR() pattern is a horrible idea.  It is non-obvious
when reading code when the pattern is used, and the compiler will not
catch misinterpretation of the return value for you.  Please don't add
new instances of using it.  Just return NULL on error and log it with
printk() or pr_error().  Very seldom do I find the actual error code
to be actually useful anyway.  Generally callers only care about
whether or not the operation succeeded.

> +
> + =A0 =A0 =A0 /* Find a free clock slot and reserve it. */
> + =A0 =A0 =A0 err =3D -EBUSY;
> + =A0 =A0 =A0 spin_lock_irqsave(&clocks_lock, flags);
> + =A0 =A0 =A0 index =3D find_first_zero_bit(clocks.map, PTP_MAX_CLOCK=
S);
> + =A0 =A0 =A0 if (index < PTP_MAX_CLOCKS) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_bit(index, clocks.map);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock_irqrestore(&clocks_lock, fl=
ags);
> + =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock_irqrestore(&clocks_lock, fl=
ags);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto no_clock;
> + =A0 =A0 =A0 }

If the spinlock is changed to a mutex that is held for the entire
function call, then the logic here can be simpler.

> +
> + =A0 =A0 =A0 /* Initialize a clock structure. */
> + =A0 =A0 =A0 err =3D -ENOMEM;
> + =A0 =A0 =A0 ptp =3D kzalloc(sizeof(struct ptp_clock), GFP_KERNEL);
> + =A0 =A0 =A0 if (ptp =3D=3D NULL)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto no_memory;
> +
> + =A0 =A0 =A0 ptp->info =3D info;
> + =A0 =A0 =A0 ptp->devid =3D MKDEV(major, index);
> + =A0 =A0 =A0 ptp->index =3D index;
> + =A0 =A0 =A0 mutex_init(&ptp->alarm_mux);
> + =A0 =A0 =A0 mutex_init(&ptp->tsevq_mux);
> + =A0 =A0 =A0 init_waitqueue_head(&ptp->tsev_wq);
> +
> + =A0 =A0 =A0 /* Create a new device in our class. */
> + =A0 =A0 =A0 ptp->dev =3D device_create(ptp_class, NULL, ptp->devid,=
 ptp,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"ptp=
_clock_%d", ptp->index);
> + =A0 =A0 =A0 if (IS_ERR(ptp->dev))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto no_device;
> +
> + =A0 =A0 =A0 dev_set_drvdata(ptp->dev, ptp);
> +
> + =A0 =A0 =A0 /* Register a character device. */
> + =A0 =A0 =A0 cdev_init(&ptp->cdev, &ptp_fops);
> + =A0 =A0 =A0 ptp->cdev.owner =3D info->owner;
> + =A0 =A0 =A0 err =3D cdev_add(&ptp->cdev, ptp->devid, 1);
> + =A0 =A0 =A0 if (err)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto no_cdev;
> +
> + =A0 =A0 =A0 /* Clock is ready, add it into the list. */
> + =A0 =A0 =A0 spin_lock_irqsave(&clocks_lock, flags);
> + =A0 =A0 =A0 list_add(&ptp->list, &clocks.list);
> + =A0 =A0 =A0 spin_unlock_irqrestore(&clocks_lock, flags);
> +
> + =A0 =A0 =A0 return ptp;
> +
> +no_cdev:
> + =A0 =A0 =A0 device_destroy(ptp_class, ptp->devid);
> +no_device:
> + =A0 =A0 =A0 mutex_destroy(&ptp->alarm_mux);
> + =A0 =A0 =A0 mutex_destroy(&ptp->tsevq_mux);
> + =A0 =A0 =A0 kfree(ptp);
> +no_memory:
> + =A0 =A0 =A0 spin_lock_irqsave(&clocks_lock, flags);
> + =A0 =A0 =A0 clear_bit(index, clocks.map);
> + =A0 =A0 =A0 spin_unlock_irqrestore(&clocks_lock, flags);
> +no_clock:
> + =A0 =A0 =A0 return ERR_PTR(err);
> +}
> +EXPORT_SYMBOL(ptp_clock_register);
> +
> +int ptp_clock_unregister(struct ptp_clock *ptp)
> +{
> + =A0 =A0 =A0 unsigned long flags;
> +
> + =A0 =A0 =A0 /* Release the clock's resources. */
> + =A0 =A0 =A0 cdev_del(&ptp->cdev);
> + =A0 =A0 =A0 device_destroy(ptp_class, ptp->devid);
> + =A0 =A0 =A0 mutex_destroy(&ptp->alarm_mux);
> + =A0 =A0 =A0 mutex_destroy(&ptp->tsevq_mux);
> +
> + =A0 =A0 =A0 /* Remove the clock from the list. */
> + =A0 =A0 =A0 spin_lock_irqsave(&clocks_lock, flags);
> + =A0 =A0 =A0 list_del(&ptp->list);
> + =A0 =A0 =A0 clear_bit(ptp->index, clocks.map);
> + =A0 =A0 =A0 spin_unlock_irqrestore(&clocks_lock, flags);
> +
> + =A0 =A0 =A0 kfree(ptp);
> +
> + =A0 =A0 =A0 return 0;
> +}
> +EXPORT_SYMBOL(ptp_clock_unregister);
> +
> +void ptp_clock_event(struct ptp_clock *ptp, struct ptp_clock_event *=
event)
> +{
> + =A0 =A0 =A0 switch (event->type) {
> +
> + =A0 =A0 =A0 case PTP_CLOCK_ALARM:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kill_pid(ptp->alarm[event->index].pid,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ptp->alarm[event->in=
dex].sig, 1);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> +
> + =A0 =A0 =A0 case PTP_CLOCK_EXTTS:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 enqueue_external_timestamp(&ptp->tsevq,=
 event);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 wake_up_interruptible(&ptp->tsev_wq);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> +
> + =A0 =A0 =A0 case PTP_CLOCK_PPS:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 }
> +}
> +EXPORT_SYMBOL(ptp_clock_event);
> +
> +/* character device operations */
> +
> +static int ptp_ioctl(struct inode *node, struct file *fp,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned int cmd, unsigned =
long arg)
> +{
> + =A0 =A0 =A0 struct ptp_clock_caps caps;
> + =A0 =A0 =A0 struct ptp_clock_request req;
> + =A0 =A0 =A0 struct ptp_clock_timer timer;
> + =A0 =A0 =A0 struct ptp_clock *ptp =3D fp->private_data;
> + =A0 =A0 =A0 struct ptp_clock_info *ops =3D ptp->info;
> + =A0 =A0 =A0 void *priv =3D ops->priv;
> + =A0 =A0 =A0 struct timespec ts;
> + =A0 =A0 =A0 int flags, index;
> + =A0 =A0 =A0 int err =3D 0;
> +
> + =A0 =A0 =A0 switch (cmd) {
> +
> + =A0 =A0 =A0 case PTP_CLOCK_APIVERS:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D put_user(PTP_CLOCK_VERSION, (u3=
2 __user *)arg);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> +
> + =A0 =A0 =A0 case PTP_CLOCK_ADJFREQ:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!capable(CAP_SYS_TIME))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EPERM;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D ops->adjfreq(priv, arg);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> +
> + =A0 =A0 =A0 case PTP_CLOCK_ADJTIME:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!capable(CAP_SYS_TIME))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EPERM;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (copy_from_user(&ts, (void __user *)=
arg, sizeof(ts)))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D -EFAULT;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D ops->adjtime(pr=
iv, &ts);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> +
> + =A0 =A0 =A0 case PTP_CLOCK_GETTIME:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D ops->gettime(priv, &ts);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (err)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D copy_to_user((void __user *)arg=
, &ts, sizeof(ts));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> +
> + =A0 =A0 =A0 case PTP_CLOCK_SETTIME:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!capable(CAP_SYS_TIME))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EPERM;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (copy_from_user(&ts, (void __user *)=
arg, sizeof(ts)))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D -EFAULT;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D ops->settime(pr=
iv, &ts);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> +
> + =A0 =A0 =A0 case PTP_CLOCK_GETCAPS:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 memset(&caps, 0, sizeof(caps));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 caps.max_adj =3D ptp->info->max_adj;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 caps.n_alarm =3D ptp->info->n_alarm;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 caps.n_ext_ts =3D ptp->info->n_ext_ts;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 caps.n_per_out =3D ptp->info->n_per_out=
;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 caps.pps =3D ptp->info->pps;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D copy_to_user((void __user *)arg=
, &caps, sizeof(caps));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> +
> + =A0 =A0 =A0 case PTP_CLOCK_GETTIMER:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (copy_from_user(&timer, (void __user=
 *)arg, sizeof(timer))) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D -EFAULT;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 index =3D timer.alarm_index;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (index < 0 || index >=3D ptp->info->=
n_alarm) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D -EINVAL;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D ops->gettimer(priv, index, &tim=
er.tsp);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (err)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D copy_to_user((void __user *)arg=
, &timer, sizeof(timer));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> +
> + =A0 =A0 =A0 case PTP_CLOCK_SETTIMER:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (copy_from_user(&timer, (void __user=
 *)arg, sizeof(timer))) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D -EFAULT;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 index =3D timer.alarm_index;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (index < 0 || index >=3D ptp->info->=
n_alarm) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D -EINVAL;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!valid_signal(timer.signum))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 flags =3D timer.flags;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (flags & (flags !=3D TIMER_ABSTIME))=
 {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D -EINVAL;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (mutex_lock_interruptible(&ptp->alar=
m_mux))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ERESTARTSYS;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ptp->alarm[index].pid)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 put_pid(ptp->alarm[inde=
x].pid);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ptp->alarm[index].pid =3D get_pid(task_=
pid(current));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ptp->alarm[index].sig =3D timer.signum;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D ops->settimer(priv, index, flag=
s, &timer.tsp);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mutex_unlock(&ptp->alarm_mux);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> +
> + =A0 =A0 =A0 case PTP_FEATURE_REQUEST:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (copy_from_user(&req, (void __user *=
)arg, sizeof(req))) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D -EFAULT;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 switch (req.type) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case PTP_REQUEST_EXTTS:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case PTP_REQUEST_PEROUT:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case PTP_REQUEST_PPS:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!capable(CAP_SYS_TI=
ME))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return =
-EPERM;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 default:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D -EINVAL;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (err)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D ops->enable(priv, &req,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 req=
=2Eflags & PTP_ENABLE_FEATURE ? 1 : 0);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> +
> + =A0 =A0 =A0 default:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D -ENOTTY;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 return err;
> +}
> +
> +static int ptp_open(struct inode *inode, struct file *fp)
> +{
> + =A0 =A0 =A0 struct ptp_clock *ptp;
> + =A0 =A0 =A0 ptp =3D container_of(inode->i_cdev, struct ptp_clock, c=
dev);
> +
> + =A0 =A0 =A0 fp->private_data =3D ptp;
> +
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static unsigned int ptp_poll(struct file *fp, poll_table *wait)
> +{
> + =A0 =A0 =A0 struct ptp_clock *ptp =3D fp->private_data;
> +
> + =A0 =A0 =A0 poll_wait(fp, &ptp->tsev_wq, wait);
> +
> + =A0 =A0 =A0 return queue_cnt(&ptp->tsevq) ? POLLIN : 0;
> +}
> +
> +static ssize_t ptp_read(struct file *fp, char __user *buf,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 size_t cnt, loff_t *off=
)
> +{
> + =A0 =A0 =A0 struct ptp_clock *ptp =3D fp->private_data;
> + =A0 =A0 =A0 struct timestamp_event_queue *queue =3D &ptp->tsevq;
> + =A0 =A0 =A0 struct ptp_extts_event *event;
> + =A0 =A0 =A0 size_t qcnt;
> +
> + =A0 =A0 =A0 if (mutex_lock_interruptible(&ptp->tsevq_mux))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ERESTARTSYS;
> +
> + =A0 =A0 =A0 cnt =3D cnt / sizeof(struct ptp_extts_event);
> +
> + =A0 =A0 =A0 if (wait_event_interruptible(ptp->tsev_wq,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0(qcnt =3D queue_cnt(&ptp->tsevq)))) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mutex_unlock(&ptp->tsevq_mux);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ERESTARTSYS;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 if (cnt > qcnt)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cnt =3D qcnt;
> +
> + =A0 =A0 =A0 event =3D &queue->buf[queue->head];
> +
> + =A0 =A0 =A0 if (copy_to_user(buf, event, cnt * sizeof(struct ptp_ex=
tts_event))) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mutex_unlock(&ptp->tsevq_mux);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EFAULT;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 queue->head =3D (queue->head + cnt) % PTP_MAX_TIMESTAMP=
S;
> +
> + =A0 =A0 =A0 mutex_unlock(&ptp->tsevq_mux);
> +
> + =A0 =A0 =A0 return cnt * sizeof(struct ptp_extts_event);
> +}
> +
> +static int ptp_release(struct inode *inode, struct file *fp)
> +{
> + =A0 =A0 =A0 struct ptp_clock *ptp;
> + =A0 =A0 =A0 struct itimerspec ts =3D {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 {0, 0}, {0, 0}
> + =A0 =A0 =A0 };
> + =A0 =A0 =A0 int i;
> +
> + =A0 =A0 =A0 ptp =3D container_of(inode->i_cdev, struct ptp_clock, c=
dev);
> +
> + =A0 =A0 =A0 for (i =3D 0; i < ptp->info->n_alarm; i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ptp->alarm[i].pid) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ptp->info->settimer(ptp=
->info->priv, i, 0, &ts);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 put_pid(ptp->alarm[i].p=
id);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ptp->alarm[i].pid =3D N=
ULL;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static const struct file_operations ptp_fops =3D {
> + =A0 =A0 =A0 .owner =A0 =A0 =A0 =A0 =A0=3D THIS_MODULE,
> + =A0 =A0 =A0 .ioctl =A0 =A0 =A0 =A0 =A0=3D ptp_ioctl,
> + =A0 =A0 =A0 .open =A0 =A0 =A0 =A0 =A0 =3D ptp_open,
> + =A0 =A0 =A0 .poll =A0 =A0 =A0 =A0 =A0 =3D ptp_poll,
> + =A0 =A0 =A0 .read =A0 =A0 =A0 =A0 =A0 =3D ptp_read,
> + =A0 =A0 =A0 .release =A0 =A0 =A0 =A0=3D ptp_release,
> +};
> +
> +/* sysfs */
> +
> +static ssize_t ptp_show_status(struct device *dev,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct d=
evice_attribute *attr, char *buf)
> +{
> + =A0 =A0 =A0 struct ptp_clock *ptp =3D dev_get_drvdata(dev);
> + =A0 =A0 =A0 return sprintf(buf,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"maximum adjustment: =A0=
%d\n"
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"programmable alarms: %d=
\n"
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"external timestamps: %d=
\n"
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"periodic outputs: =A0 =A0=
%d\n"
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"has pps: =A0 =A0 =A0 =A0=
 =A0 =A0 %d\n"
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"device index: =A0 =A0 =A0=
 =A0%d\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ptp->info->max_adj,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ptp->info->n_alarm,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ptp->info->n_ext_ts,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ptp->info->n_per_out,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ptp->info->pps,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ptp->index);
> +}

Don't do this in a sysfs file.  Use a debugfs file if you want to
export freeform data like this.  sysfs files should contain either
only one value, or a simple list-of-same-type values.  Formatted data
is completely out.

> +
> +struct device_attribute ptp_attrs[] =3D {
> + =A0 =A0 =A0 __ATTR(capabilities, S_IRUGO, ptp_show_status, NULL),
> + =A0 =A0 =A0 __ATTR_NULL,
> +};
> +
> +/* module operations */
> +
> +static void __exit ptp_exit(void)
> +{
> + =A0 =A0 =A0 class_destroy(ptp_class);
> + =A0 =A0 =A0 unregister_chrdev_region(ptp_devt, PTP_MAX_CLOCKS);
> +}
> +
> +static int __init ptp_init(void)
> +{
> + =A0 =A0 =A0 int err;
> +
> + =A0 =A0 =A0 INIT_LIST_HEAD(&clocks.list);
> +
> + =A0 =A0 =A0 ptp_class =3D class_create(THIS_MODULE, "ptp");
> + =A0 =A0 =A0 if (!ptp_class) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "ptp: failed to allocat=
e class\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 ptp_class->dev_attrs =3D ptp_attrs;
> +
> + =A0 =A0 =A0 err =3D alloc_chrdev_region(&ptp_devt, 0, PTP_MAX_CLOCK=
S, "ptp");
> + =A0 =A0 =A0 if (err < 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "ptp: failed to allocat=
e char device region\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto no_region;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 pr_info("PTP clock support registered\n");
> + =A0 =A0 =A0 return 0;
> +
> +no_region:
> + =A0 =A0 =A0 class_destroy(ptp_class);
> + =A0 =A0 =A0 return err;
> +}
> +
> +subsys_initcall(ptp_init);
> +module_exit(ptp_exit);
> +
> +MODULE_AUTHOR("Richard Cochran <richard.cochran@omicron.at>");
> +MODULE_DESCRIPTION("PTP clocks support");
> +MODULE_LICENSE("GPL");
> diff --git a/include/linux/Kbuild b/include/linux/Kbuild
> index 2fc8e14..9959fe4 100644
> --- a/include/linux/Kbuild
> +++ b/include/linux/Kbuild
> @@ -140,6 +140,7 @@ header-y +=3D pkt_sched.h
> =A0header-y +=3D posix_types.h
> =A0header-y +=3D ppdev.h
> =A0header-y +=3D prctl.h
> +header-y +=3D ptp_clock.h
> =A0header-y +=3D qnxtypes.h
> =A0header-y +=3D qnx4_fs.h
> =A0header-y +=3D radeonfb.h
> diff --git a/include/linux/ptp_clock.h b/include/linux/ptp_clock.h
> new file mode 100644
> index 0000000..5a509c5
> --- /dev/null
> +++ b/include/linux/ptp_clock.h
> @@ -0,0 +1,79 @@
> +/*
> + * PTP 1588 clock support - user space interface
> + *
> + * Copyright (C) 2010 OMICRON electronics GmbH
> + *
> + * =A0This program is free software; you can redistribute it and/or =
modify
> + * =A0it under the terms of the GNU General Public License as publis=
hed by
> + * =A0the Free Software Foundation; either version 2 of the License,=
 or
> + * =A0(at your option) any later version.
> + *
> + * =A0This program is distributed in the hope that it will be useful=
,
> + * =A0but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * =A0MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. =A0See th=
e
> + * =A0GNU General Public License for more details.
> + *
> + * =A0You should have received a copy of the GNU General Public Lice=
nse
> + * =A0along with this program; if not, write to the Free Software
> + * =A0Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
> + */
> +
> +#ifndef _PTP_CLOCK_H_
> +#define _PTP_CLOCK_H_
> +
> +#include <linux/ioctl.h>
> +#include <linux/types.h>
> +
> +#define PTP_ENABLE_FEATURE (1<<0)
> +#define PTP_RISING_EDGE =A0 =A0(1<<1)
> +#define PTP_FALLING_EDGE =A0 (1<<2)
> +
> +enum ptp_request_types {
> + =A0 =A0 =A0 PTP_REQUEST_EXTTS,
> + =A0 =A0 =A0 PTP_REQUEST_PEROUT,
> + =A0 =A0 =A0 PTP_REQUEST_PPS,
> +};
> +
> +struct ptp_clock_caps {
> + =A0 =A0 =A0 __s32 max_adj; /* Maximum frequency adjustment, parts p=
er billon. */
> + =A0 =A0 =A0 int n_alarm; =A0 /* Number of programmable alarms. */
> + =A0 =A0 =A0 int n_ext_ts; =A0/* Number of external time stamp chann=
els. */
> + =A0 =A0 =A0 int n_per_out; /* Number of programmable periodic signa=
ls. */
> + =A0 =A0 =A0 int pps; =A0 =A0 =A0 /* Whether the clock supports a PP=
S callback. */
> +};
> +
> +struct ptp_clock_timer {
> + =A0 =A0 =A0 int alarm_index; =A0 =A0 =A0 /* Which alarm to query or=
 configure. */
> + =A0 =A0 =A0 int signum; =A0 =A0 =A0 =A0 =A0 =A0/* Requested signal.=
 */
> + =A0 =A0 =A0 int flags; =A0 =A0 =A0 =A0 =A0 =A0 /* Zero or TIMER_ABS=
TIME, see TIMER_SETTIME(2) */
> + =A0 =A0 =A0 struct itimerspec tsp; /* See TIMER_SETTIME(2) */
> +};
> +
> +struct ptp_clock_request {
> + =A0 =A0 =A0 int type; =A0/* One of the ptp_request_types enumeratio=
n values. */
> + =A0 =A0 =A0 int index; /* Which channel to configure. */
> + =A0 =A0 =A0 struct timespec ts; /* For period signals, the desired =
period. */
> + =A0 =A0 =A0 int flags; /* Bit field for PTP_ENABLE_FEATURE or other=
 flags. */
> +};
> +
> +struct ptp_extts_event {
> + =A0 =A0 =A0 int index;
> + =A0 =A0 =A0 struct timespec ts;
> +};
> +
> +#define PTP_CLOCK_VERSION 0x00000001
> +
> +#define PTP_CLK_MAGIC '=3D'
> +
> +#define PTP_CLOCK_APIVERS _IOR (PTP_CLK_MAGIC, 1, __u32)
> +#define PTP_CLOCK_ADJFREQ _IO =A0(PTP_CLK_MAGIC, 2)
> +#define PTP_CLOCK_ADJTIME _IOW (PTP_CLK_MAGIC, 3, struct timespec)
> +#define PTP_CLOCK_GETTIME _IOR (PTP_CLK_MAGIC, 4, struct timespec)
> +#define PTP_CLOCK_SETTIME _IOW (PTP_CLK_MAGIC, 5, struct timespec)
> +
> +#define PTP_CLOCK_GETCAPS =A0 _IOR =A0(PTP_CLK_MAGIC, 6, struct ptp_=
clock_caps)
> +#define PTP_CLOCK_GETTIMER =A0_IOWR (PTP_CLK_MAGIC, 7, struct ptp_cl=
ock_timer)
> +#define PTP_CLOCK_SETTIMER =A0_IOW =A0(PTP_CLK_MAGIC, 8, struct ptp_=
clock_timer)
> +#define PTP_FEATURE_REQUEST _IOW =A0(PTP_CLK_MAGIC, 9, struct ptp_cl=
ock_request)
> +
> +#endif
> diff --git a/include/linux/ptp_clock_kernel.h b/include/linux/ptp_clo=
ck_kernel.h
> new file mode 100644
> index 0000000..d6cc158
> --- /dev/null
> +++ b/include/linux/ptp_clock_kernel.h
> @@ -0,0 +1,137 @@
> +/*
> + * PTP 1588 clock support
> + *
> + * Copyright (C) 2010 OMICRON electronics GmbH
> + *
> + * =A0This program is free software; you can redistribute it and/or =
modify
> + * =A0it under the terms of the GNU General Public License as publis=
hed by
> + * =A0the Free Software Foundation; either version 2 of the License,=
 or
> + * =A0(at your option) any later version.
> + *
> + * =A0This program is distributed in the hope that it will be useful=
,
> + * =A0but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * =A0MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. =A0See th=
e
> + * =A0GNU General Public License for more details.
> + *
> + * =A0You should have received a copy of the GNU General Public Lice=
nse
> + * =A0along with this program; if not, write to the Free Software
> + * =A0Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
> + */
> +
> +#ifndef _PTP_CLOCK_KERNEL_H_
> +#define _PTP_CLOCK_KERNEL_H_
> +
> +#include <linux/ptp_clock.h>
> +
> +/**
> + * struct ptp_clock_info - decribes a PTP hardware clock
> + *
> + * @owner: =A0 =A0 The clock driver should set to THIS_MODULE.
> + * @name: =A0 =A0 =A0A short name to identify the clock.
> + * @max_adj: =A0 The maximum possible frequency adjustment, in parts=
 per billon.
> + * @n_alarm: =A0 The number of programmable alarms.
> + * @n_ext_ts: =A0The number of external time stamp channels.
> + * @n_per_out: The number of programmable periodic signals.
> + * @pps: =A0 =A0 =A0 Indicates whether the clock supports a PPS call=
back.
> + * @priv: =A0 =A0 =A0Passed to the clock operations, for the driver'=
s private use.
> + *
> + * clock operations
> + *
> + * @adjfreq: =A0Adjusts the frequency of the hardware clock.
> + * =A0 =A0 =A0 =A0 =A0 =A0parameter delta: Desired period change in =
parts per billion.
> + *
> + * @adjtime: =A0Shifts the time of the hardware clock.
> + * =A0 =A0 =A0 =A0 =A0 =A0parameter ts: Desired change in seconds an=
d nanoseconds.
> + *
> + * @gettime: =A0Reads the current time from the hardware clock.
> + * =A0 =A0 =A0 =A0 =A0 =A0parameter ts: Holds the result.
> + *
> + * @settime: =A0Set the current time on the hardware clock.
> + * =A0 =A0 =A0 =A0 =A0 =A0parameter ts: Time value to set.
> + *
> + * @gettimer: Reads the time remaining from the given timer.
> + * =A0 =A0 =A0 =A0 =A0 =A0parameter index: Which alarm to query.
> + * =A0 =A0 =A0 =A0 =A0 =A0parameter ts: Holds the result.
> + *
> + * @settimer: Arms the given timer for periodic or one shot operatio=
n.
> + * =A0 =A0 =A0 =A0 =A0 =A0parameter index: Which alarm to set.
> + * =A0 =A0 =A0 =A0 =A0 =A0parameter abs: TIMER_ABSTIME, or zero for =
relative timer.
> + * =A0 =A0 =A0 =A0 =A0 =A0parameter ts: Alarm time and period to set=
=2E
> + *
> + * @enable: =A0 Request driver to enable or disable an ancillary fea=
ture.
> + * =A0 =A0 =A0 =A0 =A0 =A0parameter request: Desired resource to ena=
ble or disable.
> + * =A0 =A0 =A0 =A0 =A0 =A0parameter on: Caller passes one to enable =
or zero to disable.
> + *
> + * The callbacks must all return zero on success, non-zero otherwise=
=2E
> + */
> +
> +struct ptp_clock_info {
> + =A0 =A0 =A0 struct module *owner;
> + =A0 =A0 =A0 char name[16];
> + =A0 =A0 =A0 s32 max_adj;
> + =A0 =A0 =A0 int n_alarm;
> + =A0 =A0 =A0 int n_ext_ts;
> + =A0 =A0 =A0 int n_per_out;
> + =A0 =A0 =A0 int pps;
> + =A0 =A0 =A0 void *priv;
> + =A0 =A0 =A0 int (*adjfreq)(void *priv, s32 delta);
> + =A0 =A0 =A0 int (*adjtime)(void *priv, struct timespec *ts);
> + =A0 =A0 =A0 int (*gettime)(void *priv, struct timespec *ts);
> + =A0 =A0 =A0 int (*settime)(void *priv, struct timespec *ts);
> + =A0 =A0 =A0 int (*gettimer)(void *priv, int index, struct itimerspe=
c *ts);
> + =A0 =A0 =A0 int (*settimer)(void *priv, int index, int abs, struct =
itimerspec *ts);
> + =A0 =A0 =A0 int (*enable)(void *priv, struct ptp_clock_request *req=
uest, int on);
> +};
> +
> +struct ptp_clock;
> +
> +/**
> + * ptp_clock_register() - register a PTP hardware clock driver
> + *
> + * @info: =A0Structure describing the new clock.
> + */
> +
> +extern struct ptp_clock *ptp_clock_register(struct ptp_clock_info *i=
nfo);
> +
> +/**
> + * ptp_clock_unregister() - unregister a PTP hardware clock driver
> + *
> + * @ptp: =A0The clock to remove from service.
> + */
> +
> +extern int ptp_clock_unregister(struct ptp_clock *ptp);
> +
> +
> +enum ptp_clock_events {
> + =A0 =A0 =A0 PTP_CLOCK_ALARM,
> + =A0 =A0 =A0 PTP_CLOCK_EXTTS,
> + =A0 =A0 =A0 PTP_CLOCK_PPS,
> +};
> +
> +/**
> + * struct ptp_clock_event - decribes a PTP hardware clock event
> + *
> + * @type: =A0One of the ptp_clock_events enumeration values.
> + * @index: Identifies the source of the event.
> + * @timestamp: When the event occured.
> + */
> +
> +struct ptp_clock_event {
> + =A0 =A0 =A0 int type;
> + =A0 =A0 =A0 int index;
> + =A0 =A0 =A0 u64 timestamp;
> +};
> +
> +/**
> + * ptp_clock_event() - notify the PTP layer about an event
> + *
> + * This function should only be called from interrupt context.
> + *
> + * @ptp: =A0 =A0The clock obtained from ptp_clock_register().
> + * @event: =A0Message structure describing the event.
> + */
> +
> +extern void ptp_clock_event(struct ptp_clock *ptp,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct ptp_cloc=
k_event *event);
> +
> +#endif
> --
> 1.6.3.3
>
>
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
>



--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
