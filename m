From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] don't allow / in class device names
Date: Fri, 13 Feb 2004 10:27:55 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040213102755.27cf4fcd.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Leann Ogasawara <ogasawara@osdl.org>, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Tommi Virtanen <tv@tv.debian.net>, Greg KH <greg@kroah.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> [0 tv@tao /sys/class/misc]$ uname -a
> Linux tao 2.6.2-rc2 #6 Mon Jan 26 10:54:50 EET 2004 i686 GNU/Linux
> [0 tv@tao /sys/class/misc]$ echo *
> intermezzo net/tun psaux rtc uinput
> [0 tv@tao /sys/class/misc]$
>
> Seems like that's all because of this:
>
> static struct miscdevice tun_miscdev = {
>         .minor = TUN_MINOR,
>         .name = "net/tun",
>         .fops = &tun_fops
> };
>
> Name is apparently meant to be a filename, not a path.
> Don't know what should be done to it; maybe
>
> static struct miscdevice tun_miscdev = {
>         .minor = TUN_MINOR,
>         .name = "tun",
>         .fops = &tun_fops,
>         .devfs_name = "misc/net/tun",
> };
>
> But I havent tried that out.
>
> I'd suggest this, to flush out all the problems. Later,
> it can be changed to return -EINVAL or BUG_ON.
>
> --- 1.26/drivers/char/misc.c    Thu Jan 15 13:05:56 2004
> +++ edited/misc.c       Fri Feb 13 19:35:45 2004
> @@ -212,6 +212,9 @@
>  int misc_register(struct miscdevice * misc)
>  {
>         struct miscdevice *c;
> +
> +       if (misc->name && strchr(misc->name, '/'))
> +         printk("%s: name contains slash when registering %s.\n", __func__, misc->name);
>
>         down(&misc_sem);
>         list_for_each_entry(c, &misc_list, list) {
>
Don't fix it just for misc_register, the fix needs to go into class_device.

diff -Nru a/drivers/base/class.c b/drivers/base/class.c
--- a/drivers/base/class.c	Fri Feb 13 10:23:36 2004
+++ b/drivers/base/class.c	Fri Feb 13 10:23:36 2004
@@ -281,7 +281,8 @@
 	int error;
 
 	class_dev = class_device_get(class_dev);
-	if (!class_dev || !strlen(class_dev->class_id))
+	if (!class_dev || !strlen(class_dev->class_id) 
+	    || strchr(class_dev->class_id, '/'))
 		return -EINVAL;
 
 	parent = class_get(class_dev->class);
