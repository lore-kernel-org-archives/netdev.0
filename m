From: Jim Cromie <jim.cromie@gmail.com>
Subject: [PATCH 01/23] add register_chrdev_ids() to char_dev.c, API
Date: Thu, 19 May 2011 15:33:04 -0600
Message-ID: <1305840792-25877-2-git-send-email-jim.cromie@gmail.com>
References: <1305840792-25877-1-git-send-email-jim.cromie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Anil Ravindranath <anil_ravindranath@pmc-sierra.com>,
	linux-sh@vger.kernel.org, Heiko Carstens <heiko.carstens@de.ibm.com>,
	"Hans J. Koch" <hjk@hansjkoch.de>, linux-mtd@lists.infradead.org,
	Sean Hefty <sean.hefty@intel.com>, devel@driverdev.osuosl.org,
	linux-s390@vger.kernel.org,
	David Brownell <dbrownell@users.sourceforge.net>,
	linux-scsi@vger.kernel.org, linux-rdma@vger.kernel.org,
	Paul Mundt <lethal@linux-sh.org>, linux-input@vger.kernel.org,
	osst-users@lists.sourceforge.net,
	Hal Rosenstock <hal.rosenstock@gmail.com>, linux-media@vger.kernel.org,
	Doug Gilbert <dgilbert@interlog.com>,
	Roland Dreier <roland@kernel.org>, rtc-linux@googlegroups.com,
	Matthew Wilcox <matthew@wil.cx>, Boaz Harrosh <bharrosh@panasas.com>,
	Chris Metcalf <cmetcalf@tilera.com>,
	Mauro Carvalho Chehab <mchehab@infradead.org>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	subscribers-only <linuxp
To: linux-kernel@vger.kernel.org
Return-path: <devel-bounces@linuxdriverproject.org>
In-Reply-To: <1305840792-25877-1-git-send-email-jim.cromie@gmail.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/devel>,
	<mailto:devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/devel>
List-Post: <mailto:devel@linuxdriverproject.org>
List-Help: <mailto:devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/devel>,
	<mailto:devel-request@linuxdriverproject.org?subject=subscribe>
Sender: devel-bounces@linuxdriverproject.org
Errors-To: devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

register_chrdev_ids() replaces and deprecates register_chrdev_region()
and alloc_chrdev_region() with a single function that works for both
dynamic and static major numbers.

Like alloc_chrdev_region(), 1st arg is a dev_t*, but its an in/out
parameter, and expects both major and minor to be preset, and thus the
separate minor arg is dropped.  If major == 0, a dynamic major is
reserved, saved into 1st arg, and thus available to caller afterwards.

Signed-off-by: Jim Cromie <jim.cromie@gmail.com>

cc: Alessandro Zummo <a.zummo@towertech.it>
cc: Alexander Viro <viro@zeniv.linux.org.uk>
cc: Anil Ravindranath <anil_ravindranath@pmc-sierra.com>
cc: Benny Halevy <bhalevy@panasas.com>
cc: Boaz Harrosh <bharrosh@panasas.com>
cc: Chris Metcalf <cmetcalf@tilera.com>
cc: David Brownell <dbrownell@users.sourceforge.net>
cc: "David S. Miller" <davem@davemloft.net>
cc: David Woodhouse <dwmw2@infradead.org>
cc: devel@driverdev.osuosl.org
cc: Doug Gilbert <dgilbert@interlog.com>
cc: Greg Kroah-Hartman <gregkh@suse.de>
cc: Hal Rosenstock <hal.rosenstock@gmail.com>
cc: "Hans J. Koch" <hjk@hansjkoch.de>
cc: Heiko Carstens <heiko.carstens@de.ibm.com>
cc: Jens Axboe <axboe@kernel.dk>
cc: Jim Cromie <jim.cromie@gmail.com>
cc: Jiri Kosina <jkosina@suse.cz>
cc: Jiri Slaby <jirislaby@gmail.com>
cc: linux390@de.ibm.com
cc: linux-fsdevel@vger.kernel.org
cc: linux-input@vger.kernel.org
cc: linux-kernel@vger.kernel.org
cc: linux-media@vger.kernel.org
cc: linux-mtd@lists.infradead.org
cc: linuxpps@ml.enneenne.com (subscribers-only)
cc: linux-rdma@vger.kernel.org
cc: linux-s390@vger.kernel.org
cc: linux-scsi@vger.kernel.org
cc: linux-sh@vger.kernel.org
cc: linux-usb@vger.kernel.org
cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
cc: Matthew Wilcox <matthew@wil.cx>
cc: Mauro Carvalho Chehab <mchehab@infradead.org>
cc: netdev@vger.kernel.org
cc: osd-dev@open-osd.org
cc: osst-users@lists.sourceforge.net
cc: Paul Mundt <lethal@linux-sh.org>
cc: Rodolfo Giometti <giometti@enneenne.com>
cc: Roland Dreier <roland@kernel.org>
cc: rtc-linux@googlegroups.com
cc: Sean Hefty <sean.hefty@intel.com>
cc: Willem Riede <osst@riede.org>
---
 fs/char_dev.c      |   33 +++++++++++++++++++++++++++++----
 include/linux/fs.h |    6 ++++--
 2 files changed, 33 insertions(+), 6 deletions(-)

diff --git a/fs/char_dev.c b/fs/char_dev.c
index dca9e5e..9149b7c 100644
--- a/fs/char_dev.c
+++ b/fs/char_dev.c
@@ -93,7 +93,7 @@ void chrdev_show(struct seq_file *f, off_t offset)
  */
 static struct char_device_struct *
 __register_chrdev_region(unsigned int major, unsigned int baseminor,
-			   int minorct, const char *name)
+			 int minorct, const char *name)
 {
 	struct char_device_struct *cd, **cp;
 	int ret = 0;
@@ -193,7 +193,8 @@ __unregister_chrdev_region(unsigned major, unsigned baseminor, int minorct)
  *
  * Return value is zero on success, a negative error code on failure.
  */
-int register_chrdev_region(dev_t from, unsigned count, const char *name)
+int __deprecated
+register_chrdev_region(dev_t from, unsigned count, const char *name)
 {
 	struct char_device_struct *cd;
 	dev_t to = from + count;
@@ -229,8 +230,9 @@ fail:
  * chosen dynamically, and returned (along with the first minor number)
  * in @dev.  Returns zero or a negative error code.
  */
-int alloc_chrdev_region(dev_t *dev, unsigned baseminor, unsigned count,
-			const char *name)
+int __deprecated
+alloc_chrdev_region(dev_t *dev, unsigned baseminor, unsigned count,
+		    const char *name)
 {
 	struct char_device_struct *cd;
 	cd = __register_chrdev_region(0, baseminor, count, name);
@@ -241,6 +243,28 @@ int alloc_chrdev_region(dev_t *dev, unsigned baseminor, unsigned count,
 }
 
 /**
+ * register_chrdev_ids() - register a range of char device numbers
+ * @dev: in/output parameter for requested/claimed device major, minor
+ * @count: the number of minor numbers required
+ * @name: the name of the associated device or driver
+ *
+ * Allocates a range of char device numbers.  The major number will be
+ * chosen dynamically if passed as 0, or reserved specifically otherwize,
+ * with reserved numbers written into @dev.
+ * Returns zero, or a negative error code.
+ */
+int register_chrdev_ids(dev_t *dev, unsigned count, const char *name)
+{
+	struct char_device_struct *cd;
+
+	cd = __register_chrdev_region(MAJOR(*dev), MINOR(*dev), count, name);
+	if (IS_ERR(cd))
+		return PTR_ERR(cd);
+	*dev = MKDEV(cd->major, cd->baseminor);
+	return 0;
+}
+
+/**
  * __register_chrdev() - create and register a cdev occupying a range of minors
  * @major: major device number or 0 for dynamic allocation
  * @baseminor: first of the requested range of minor numbers
@@ -566,6 +590,7 @@ void __init chrdev_init(void)
 EXPORT_SYMBOL(register_chrdev_region);
 EXPORT_SYMBOL(unregister_chrdev_region);
 EXPORT_SYMBOL(alloc_chrdev_region);
+EXPORT_SYMBOL(register_chrdev_ids);
 EXPORT_SYMBOL(cdev_init);
 EXPORT_SYMBOL(cdev_alloc);
 EXPORT_SYMBOL(cdev_del);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index cdf9495..e72de48 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2075,8 +2075,10 @@ static inline void bd_unlink_disk_holder(struct block_device *bdev,
 
 /* fs/char_dev.c */
 #define CHRDEV_MAJOR_HASH_SIZE	255
-extern int alloc_chrdev_region(dev_t *, unsigned, unsigned, const char *);
-extern int register_chrdev_region(dev_t, unsigned, const char *);
+extern int register_chrdev_ids(dev_t *, unsigned, const char *);
+extern int __deprecated alloc_chrdev_region(dev_t *, unsigned, unsigned,
+					    const char *);
+extern int __deprecated register_chrdev_region(dev_t, unsigned, const char *);
 extern int __register_chrdev(unsigned int major, unsigned int baseminor,
 			     unsigned int count, const char *name,
 			     const struct file_operations *fops);
-- 
1.7.4.4
