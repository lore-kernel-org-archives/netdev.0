From: Roman Kagan <rkagan@mail.ru>
Subject: Re: [Linux-ATM-General] [RFC][PATCH] Very basic sysfs support for ATM devices (updated)
Date: Fri, 4 Feb 2005 23:13:27 +0300
Message-ID: <20050204201327.GA2439@katya>
References: <20050121085123.GA2471@katya> <200502041811.j14IBOna020338@ginger.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-atm-general@lists.sourceforge.net,
        usbatm@lists.infradead.org
To: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Content-Disposition: inline
In-Reply-To: <200502041811.j14IBOna020338@ginger.cmf.nrl.navy.mil>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  Hi Chas,

On Fri, Feb 04, 2005 at 01:11:25PM -0500, chas williams - CONTRACTOR wrote:
> In message <20050121085123.GA2471@katya>,Roman Kagan writes:
> >The patch is against 2.6.10.  Please comment.
> 
> i guess i would prefer that entries be named typeN, like he0
> instead of just a number.

I'm fine with it.

> if !CONFIG_SYSFS, then __free_atm_dev() is going to need to do the
> kfree.

Right, I forgot that sysfs was still optional.  Below is the patch on
top of yours to add this conditional to a few other places.

> i added some other fields that i think are interesting.

As a matter of fact that's what I hoped for :)

> +static CLASS_DEVICE_ATTR(address, S_IRUGO, show_address, NULL);

Maybe it should better be "esi", to match the name in struct atm_dev?

Besides, I've encountered a problem with hotplug being called from
atm_dev_register: the device actually becomes usable only when the
driver sets .dev_data, which may happen after hotplug has been called.
E.g. if I call br2684ctl in my hotplug script, and it happens to attempt
to open a socket on the device before .dev_data is set, br2684ctl fails
(rather disgracefully BTW, forgetting to cleanup nasX).  I had to work
around it by adding a sleep for a couple of seconds to the hotplug
script, and hoping that was enough for the driver to complete
initializing atm_dev.  I suspect the only way to fix it is to split the
atm_dev initialization into two stages, allocation and registration, as
it is done for net_device.

Cheers,
  Roman.

diff -ruNp linux-2.6.10.atm/net/atm/common.h linux-2.6.10.atm.new/net/atm/common.h
--- linux-2.6.10.atm/net/atm/common.h	2005-02-04 21:46:52.084591328 +0300
+++ linux-2.6.10.atm.new/net/atm/common.h	2005-02-04 22:19:41.962124424 +0300
@@ -28,8 +28,21 @@ int atmpvc_init(void);
 void atmpvc_exit(void);
 int atmsvc_init(void);
 void atmsvc_exit(void);
+
+#ifdef CONFIG_SYSFS
 int atm_sysfs_init(void);
 void atm_sysfs_exit(void);
+#else
+static inline int atm_sysfs_init(void)
+{
+	return 0;
+}
+
+static inline void atm_sysfs_exit(void)
+{
+	/* nothing */
+}
+#endif /* CONFIG_SYSFS */
 
 #ifdef CONFIG_PROC_FS
 int atm_proc_init(void);
diff -ruNp linux-2.6.10.atm/net/atm/Makefile linux-2.6.10.atm.new/net/atm/Makefile
--- linux-2.6.10.atm/net/atm/Makefile	2005-02-04 21:46:51.966609264 +0300
+++ linux-2.6.10.atm.new/net/atm/Makefile	2005-02-04 22:19:07.025435608 +0300
@@ -2,7 +2,7 @@
 # Makefile for the ATM Protocol Families.
 #
 
-atm-y		:= addr.o pvc.o signaling.o svc.o ioctl.o common.o atm_misc.o raw.o resources.o atm_sysfs.o
+atm-y		:= addr.o pvc.o signaling.o svc.o ioctl.o common.o atm_misc.o raw.o resources.o
 mpoa-objs	:= mpc.o mpoa_caches.o mpoa_proc.o
 
 obj-$(CONFIG_ATM) += atm.o
@@ -12,6 +12,7 @@ obj-$(CONFIG_ATM_BR2684) += br2684.o
 atm-$(subst m,y,$(CONFIG_ATM_BR2684)) += ipcommon.o
 atm-$(subst m,y,$(CONFIG_NET_SCH_ATM)) += ipcommon.o
 atm-$(CONFIG_PROC_FS) += proc.o
+atm-$(CONFIG_SYSFS) += atm_sysfs.o
 
 obj-$(CONFIG_ATM_LANE) += lec.o
 obj-$(CONFIG_ATM_MPOA) += mpoa.o
diff -ruNp linux-2.6.10.atm/net/atm/resources.h linux-2.6.10.atm.new/net/atm/resources.h
--- linux-2.6.10.atm/net/atm/resources.h	2005-02-04 21:46:52.263564120 +0300
+++ linux-2.6.10.atm.new/net/atm/resources.h	2005-02-04 22:19:19.766498672 +0300
@@ -43,7 +43,21 @@ static inline void atm_proc_dev_deregist
 
 #endif /* CONFIG_PROC_FS */
 
+#ifdef CONFIG_SYSFS
 int atm_register_sysfs(struct atm_dev *adev);
 void atm_unregister_sysfs(struct atm_dev *adev);
+#else
+
+static inline int atm_register_sysfs(struct atm_dev *dev)
+{
+	return 0;
+}
+
+static inline void atm_deregister_sysfs(struct atm_dev *dev)
+{
+	/* nothing */
+}
+
+#endif /* CONFIG_SYSFS */
 
 #endif
