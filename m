From: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 08/10] tty_io: export tty_class
Date: Tue, 2 Jun 2009 18:22:41 +0400
Message-ID: <20090602142241.GA18656@doriath.ww600.siemens.net>
References: <1243868091-5315-3-git-send-email-dbaryshkov@gmail.com> <1243868091-5315-4-git-send-email-dbaryshkov@gmail.com> <1243868091-5315-5-git-send-email-dbaryshkov@gmail.com> <1243868091-5315-6-git-send-email-dbaryshkov@gmail.com> <1243868091-5315-7-git-send-email-dbaryshkov@gmail.com> <1243868091-5315-8-git-send-email-dbaryshkov@gmail.com> <1243868091-5315-9-git-send-email-dbaryshkov@gmail.com> <20090601160721.7b262469@lxorguk.ukuu.org.uk> <bc64b4640906010810l8ace77byfbd650b549f9b5c3@mail.gmail.com> <20090601163418.465be751@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, slapin-9cOl001CZnBAfugRpC6u6w@public.gmane.org,
	maxim.osipov-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org, dmitry.baryshkov-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org,
	oliver.fendt-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org
To: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090601163418.465be751-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 01, 2009 at 04:34:18PM +0100, Alan Cox wrote:
> > I used class_find_device finding the device with matching minor. Will it be
> > acceptable, if I just move this code into tty_* file and export it as
> > to modules?
> 
> Yes - create a proper tty helper function for doing the job and document
> what it does. That way if the tty layer is changed it is obvious that
> this code also needs considering.

Is this suitable:

>From bea1f7dd279119a1aa60556ff0441e31c92876aa Mon Sep 17 00:00:00 2001
From: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Tue, 2 Jun 2009 06:31:35 +0400
Subject: [PATCH] tty_io: add an API to get device corresponding to tty_struct

Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/char/tty_io.c |   13 +++++++++++++
 include/linux/tty.h   |    1 +
 2 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/drivers/char/tty_io.c b/drivers/char/tty_io.c
index 66b99a2..04d6c9a 100644
--- a/drivers/char/tty_io.c
+++ b/drivers/char/tty_io.c
@@ -3026,6 +3026,19 @@ dev_t tty_devnum(struct tty_struct *tty)
 }
 EXPORT_SYMBOL(tty_devnum);
 
+static int dev_match_devt(struct device *dev, void *data)
+{
+	dev_t *devt = data;
+	return dev->devt == *devt;
+}
+
+struct device *tty_get_device(struct tty_struct *tty)
+{
+	dev_t devt = tty_devnum(tty);
+	return class_find_device(tty_class, NULL, &devt, dev_match_devt);
+}
+EXPORT_SYMBOL(tty_get_device);
+
 void proc_clear_tty(struct task_struct *p)
 {
 	unsigned long flags;
diff --git a/include/linux/tty.h b/include/linux/tty.h
index fc39db9..d17ba1e 100644
--- a/include/linux/tty.h
+++ b/include/linux/tty.h
@@ -413,6 +413,7 @@ extern int tty_mode_ioctl(struct tty_struct *tty, struct file *file,
 			unsigned int cmd, unsigned long arg);
 extern int tty_perform_flush(struct tty_struct *tty, unsigned long arg);
 extern dev_t tty_devnum(struct tty_struct *tty);
+struct device *tty_get_device(struct tty_struct *tty);
 extern void proc_clear_tty(struct task_struct *p);
 extern struct tty_struct *get_current_tty(void);
 extern void tty_default_fops(struct file_operations *fops);
-- 
1.6.3.1

-- 
With best wishes
Dmitry

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
