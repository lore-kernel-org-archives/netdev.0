From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: Top 10 kernel oopses for the week ending January 5th, 2008
Date: Thu, 10 Jan 2008 05:53:59 +0000
Message-ID: <20080110055359.GA27894@ZenIV.linux.org.uk>
References: <477FF149.4070609@linux.intel.com> <20080105213935.GN27894@ZenIV.linux.org.uk> <20080107174431.GC27741@fieldses.org> <4782CF9C.6000508@gmail.com> <alpine.LFD.1.00.0801071851120.3148@woody.linux-foundation.org> <20080108055917.GZ27894@ZenIV.linux.org.uk> <18309.39804.31974.851666@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Kevin Winchester <kjwinchester@gmail.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Arjan van de Ven <arjan@linux.intel.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	NetDev <netdev@vger.kernel.org>, gregkh@suse.de
To: Neil Brown <neilb@suse.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754317AbYAJFyZ@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <18309.39804.31974.851666@notabene.brown>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 10, 2008 at 03:13:48PM +1100, Neil Brown wrote:
> > What guarantees that it doesn't happen before we get to callback?  AFAICS,
> > nothing whatsoever...
> 
> Yes, that's bad isn't it :-)
> 
> I think I should be using sysfs_schedule_callback here.  That makes the 
> required 'get' and 'put' calls.... but it can fail with -ENOMEM.  I
> wonder what I do if -ENOMEM???  Maybe I'll just continue to roll my
> one :-( 

How about this instead (completely untested)

	* split failure exits
	* switch to kick_rdev_from_array()
	* fold unbind_rdev_from_array() into it (no other callers anymore)
	* take export_rdev() into failure case in bind_rdev_to_array()
	* in kick_rdev_from_array() do what export_rdev() does sans
kobject_put() and do that before schedule_work().  Take kobject_put() into
delayed_delete().

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
diff --git a/drivers/md/md.c b/drivers/md/md.c
index cef9ebd..116cc5a 100644
--- a/drivers/md/md.c
+++ b/drivers/md/md.c
@@ -1344,6 +1344,39 @@ static int match_mddev_units(mddev_t *mddev1, mddev_t *mddev2)
 
 static LIST_HEAD(pending_raid_disks);
 
+static void unlock_rdev(mdk_rdev_t *rdev)
+{
+	struct block_device *bdev = rdev->bdev;
+	rdev->bdev = NULL;
+	if (!bdev)
+		MD_BUG();
+	bd_release(bdev);
+	blkdev_put(bdev);
+}
+
+void md_autodetect_dev(dev_t dev);
+
+static void __export_rdev(mdk_rdev_t * rdev)
+{
+	char b[BDEVNAME_SIZE];
+	printk(KERN_INFO "md: export_rdev(%s)\n",
+		bdevname(rdev->bdev,b));
+	if (rdev->mddev)
+		MD_BUG();
+	free_disk_sb(rdev);
+	list_del_init(&rdev->same_set);
+#ifndef MODULE
+	md_autodetect_dev(rdev->bdev->bd_dev);
+#endif
+	unlock_rdev(rdev);
+}
+
+static void export_rdev(mdk_rdev_t * rdev)
+{
+	__export_rdev(rdev);
+	kobject_put(&rdev->kobj);
+}
+
 static int bind_rdev_to_array(mdk_rdev_t * rdev, mddev_t * mddev)
 {
 	char b[BDEVNAME_SIZE];
@@ -1353,7 +1386,8 @@ static int bind_rdev_to_array(mdk_rdev_t * rdev, mddev_t * mddev)
 
 	if (rdev->mddev) {
 		MD_BUG();
-		return -EINVAL;
+		err = -EINVAL;
+		goto out;
 	}
 	/* make sure rdev->size exceeds mddev->size */
 	if (rdev->size && (mddev->size == 0 || rdev->size < mddev->size)) {
@@ -1362,8 +1396,10 @@ static int bind_rdev_to_array(mdk_rdev_t * rdev, mddev_t * mddev)
 			 * If mddev->level <= 0, then we don't care
 			 * about aligning sizes (e.g. linear)
 			 */
-			if (mddev->level > 0)
-				return -ENOSPC;
+			if (mddev->level > 0) {
+				err = -ENOSPC;
+				goto out;
+			}
 		} else
 			mddev->size = rdev->size;
 	}
@@ -1379,12 +1415,16 @@ static int bind_rdev_to_array(mdk_rdev_t * rdev, mddev_t * mddev)
 			choice++;
 		rdev->desc_nr = choice;
 	} else {
-		if (find_rdev_nr(mddev, rdev->desc_nr))
-			return -EBUSY;
+		if (find_rdev_nr(mddev, rdev->desc_nr)) {
+			err = -EBUSY;
+			goto out;
+		}
 	}
 	bdevname(rdev->bdev,b);
-	if (kobject_set_name(&rdev->kobj, "dev-%s", b) < 0)
-		return -ENOMEM;
+	if (kobject_set_name(&rdev->kobj, "dev-%s", b) < 0) {
+		err = -ENOMEM;
+		goto out;
+	}
 	while ( (s=strchr(rdev->kobj.k_name, '/')) != NULL)
 		*s = '!';
 			
@@ -1407,9 +1447,11 @@ static int bind_rdev_to_array(mdk_rdev_t * rdev, mddev_t * mddev)
 	bd_claim_by_disk(rdev->bdev, rdev, mddev->gendisk);
 	return 0;
 
- fail:
+fail:
 	printk(KERN_WARNING "md: failed to register dev-%s for %s\n",
 	       b, mdname(mddev));
+out:
+	export_rdev(rdev);
 	return err;
 }
 
@@ -1417,19 +1459,22 @@ static void delayed_delete(struct work_struct *ws)
 {
 	mdk_rdev_t *rdev = container_of(ws, mdk_rdev_t, del_work);
 	kobject_del(&rdev->kobj);
+	kobject_put(&rdev->kobj);
 }
 
-static void unbind_rdev_from_array(mdk_rdev_t * rdev)
+static void kick_rdev_from_array(mdk_rdev_t * rdev)
 {
 	char b[BDEVNAME_SIZE];
 	if (!rdev->mddev) {
 		MD_BUG();
+		export_rdev(rdev);
 		return;
 	}
 	bd_release_from_disk(rdev->bdev, rdev->mddev->gendisk);
 	list_del_init(&rdev->same_set);
 	printk(KERN_INFO "md: unbind<%s>\n", bdevname(rdev->bdev,b));
 	rdev->mddev = NULL;
+	__export_rdev(rdev);
 	sysfs_remove_link(&rdev->kobj, "block");
 
 	/* We need to delay this, otherwise we can deadlock when
@@ -1467,40 +1512,6 @@ static int lock_rdev(mdk_rdev_t *rdev, dev_t dev)
 	return err;
 }
 
-static void unlock_rdev(mdk_rdev_t *rdev)
-{
-	struct block_device *bdev = rdev->bdev;
-	rdev->bdev = NULL;
-	if (!bdev)
-		MD_BUG();
-	bd_release(bdev);
-	blkdev_put(bdev);
-}
-
-void md_autodetect_dev(dev_t dev);
-
-static void export_rdev(mdk_rdev_t * rdev)
-{
-	char b[BDEVNAME_SIZE];
-	printk(KERN_INFO "md: export_rdev(%s)\n",
-		bdevname(rdev->bdev,b));
-	if (rdev->mddev)
-		MD_BUG();
-	free_disk_sb(rdev);
-	list_del_init(&rdev->same_set);
-#ifndef MODULE
-	md_autodetect_dev(rdev->bdev->bd_dev);
-#endif
-	unlock_rdev(rdev);
-	kobject_put(&rdev->kobj);
-}
-
-static void kick_rdev_from_array(mdk_rdev_t * rdev)
-{
-	unbind_rdev_from_array(rdev);
-	export_rdev(rdev);
-}
-
 static void export_array(mddev_t *mddev)
 {
 	struct list_head *tmp;
@@ -2576,8 +2587,10 @@ new_dev_store(mddev_t *mddev, const char *buf, size_t len)
 						       mdk_rdev_t, same_set);
 			err = super_types[mddev->major_version]
 				.load_super(rdev, rdev0, mddev->minor_version);
-			if (err < 0)
-				goto out;
+			if (err < 0) {
+				export_rdev(rdev);
+				return err;
+			}
 		}
 	} else
 		rdev = md_import_device(dev, -1, -1);
@@ -2585,9 +2598,6 @@ new_dev_store(mddev_t *mddev, const char *buf, size_t len)
 	if (IS_ERR(rdev))
 		return PTR_ERR(rdev);
 	err = bind_rdev_to_array(rdev, mddev);
- out:
-	if (err)
-		export_rdev(rdev);
 	return err ? err : len;
 }
 
@@ -3637,8 +3647,7 @@ static void autorun_devices(int part)
 			printk(KERN_INFO "md: created %s\n", mdname(mddev));
 			ITERATE_RDEV_GENERIC(candidates,rdev,tmp) {
 				list_del_init(&rdev->same_set);
-				if (bind_rdev_to_array(rdev, mddev))
-					export_rdev(rdev);
+				bind_rdev_to_array(rdev, mddev);
 			}
 			autorun_array(mddev);
 			mddev_unlock(mddev);
@@ -3807,7 +3816,6 @@ static int add_new_disk(mddev_t * mddev, mdu_disk_info_t *info)
 		return -EOVERFLOW;
 
 	if (!mddev->raid_disks) {
-		int err;
 		/* expecting a device which has a superblock */
 		rdev = md_import_device(dev, mddev->major_version, mddev->minor_version);
 		if (IS_ERR(rdev)) {
@@ -3830,10 +3838,7 @@ static int add_new_disk(mddev_t * mddev, mdu_disk_info_t *info)
 				return -EINVAL;
 			}
 		}
-		err = bind_rdev_to_array(rdev, mddev);
-		if (err)
-			export_rdev(rdev);
-		return err;
+		return bind_rdev_to_array(rdev, mddev);
 	}
 
 	/*
@@ -3887,10 +3892,8 @@ static int add_new_disk(mddev_t * mddev, mdu_disk_info_t *info)
 				validate_super(mddev, rdev);
 			err = mddev->pers->hot_add_disk(mddev, rdev);
 			if (err)
-				unbind_rdev_from_array(rdev);
+				kick_rdev_from_array(rdev);
 		}
-		if (err)
-			export_rdev(rdev);
 
 		md_update_sb(mddev, 1);
 		set_bit(MD_RECOVERY_NEEDED, &mddev->recovery);
@@ -3908,7 +3911,6 @@ static int add_new_disk(mddev_t * mddev, mdu_disk_info_t *info)
 	}
 
 	if (!(info->state & (1<<MD_DISK_FAULTY))) {
-		int err;
 		rdev = md_import_device (dev, -1, 0);
 		if (IS_ERR(rdev)) {
 			printk(KERN_WARNING 
@@ -3938,11 +3940,7 @@ static int add_new_disk(mddev_t * mddev, mdu_disk_info_t *info)
 			rdev->sb_offset = calc_dev_sboffset(rdev->bdev);
 		rdev->size = calc_dev_size(rdev, mddev->chunk_size);
 
-		err = bind_rdev_to_array(rdev, mddev);
-		if (err) {
-			export_rdev(rdev);
-			return err;
-		}
+		return bind_rdev_to_array(rdev, mddev);
 	}
 
 	return 0;
@@ -4018,15 +4016,15 @@ static int hot_add_disk(mddev_t * mddev, dev_t dev)
 		printk(KERN_WARNING 
 			"md: can not hot-add faulty %s disk to %s!\n",
 			bdevname(rdev->bdev,b), mdname(mddev));
-		err = -EINVAL;
-		goto abort_export;
+		export_rdev(rdev);
+		return -EINVAL;
 	}
 	clear_bit(In_sync, &rdev->flags);
 	rdev->desc_nr = -1;
 	rdev->saved_raid_disk = -1;
 	err = bind_rdev_to_array(rdev, mddev);
 	if (err)
-		goto abort_export;
+		return err;
 
 	/*
 	 * The rest should better be atomic, we can have disk failures
@@ -4036,8 +4034,8 @@ static int hot_add_disk(mddev_t * mddev, dev_t dev)
 	if (rdev->desc_nr == mddev->max_disks) {
 		printk(KERN_WARNING "%s: can not hot-add to full array!\n",
 			mdname(mddev));
-		err = -EBUSY;
-		goto abort_unbind_export;
+		kick_rdev_from_array(rdev);
+		return -EBUSY;
 	}
 
 	rdev->raid_disk = -1;
@@ -4052,13 +4050,6 @@ static int hot_add_disk(mddev_t * mddev, dev_t dev)
 	md_wakeup_thread(mddev->thread);
 	md_new_event(mddev);
 	return 0;
-
-abort_unbind_export:
-	unbind_rdev_from_array(rdev);
