From: <gregkh@suse.de>
Subject: patch kobject-cleanup-kobject_rename-and-config_sysfs.patch added to gregkh-2.6 tree
Date: Tue, 19 Aug 2008 18:48:08 -0700
Message-ID: <12191968881412@kroah.org>
References: <m1tzf6ihlz.fsf_-_@frodo.ebiederm.org>
To: gregkh@suse.de, akpm@linux-foundation.org, benjamin.thery@bull.net,
	containers@lists.osdl.org, dlezcano@fr.ibm.com,
	ebiederm@xmission.com, htejun@gmail.com, netdev@vger.kernel.org,
	tj
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:53827 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751355AbYHTBwS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Aug 2008 21:52:18 -0400
In-Reply-To: <m1tzf6ihlz.fsf_-_@frodo.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is a note to let you know that I've just added the patch titled

    Subject: kobject: Cleanup kobject_rename and !CONFIG_SYSFS

to my gregkh-2.6 tree.  Its filename is

    kobject-cleanup-kobject_rename-and-config_sysfs.patch

This tree can be found at 
    http://www.kernel.org/pub/linux/kernel/people/gregkh/gregkh-2.6/patches/


>From ebiederm@xmission.com Thu Jul  3 18:11:54 2008
From: ebiederm@xmission.com (Eric W. Biederman)
Date: Thu, 03 Jul 2008 18:05:28 -0700
Subject: kobject: Cleanup kobject_rename and !CONFIG_SYSFS
To: ebiederm@xmission.com (Eric W. Biederman)
Cc: Greg Kroah-Hartman <gregkh@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <htejun@gmail.com>, Daniel Lezcano <dlezcano@fr.ibm.com>, linux-kernel@vger.kernel.org, Al Viro <viro@ftp.linux.org.uk>, Linux Containers <containers@lists.osdl.org>, Benjamin Thery <benjamin.thery@bull.net>, <netdev@vger.kernel.org>
Message-ID: <m1tzf6ihlz.fsf_-_@frodo.ebiederm.org>



It finally dawned on me what the clean fix to sysfs_rename_dir
calling kobject_set_name is.  Move the work into kobject_rename
where it belongs.  The callers serialize us anyway so this is
safe.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
Acked-by: Tejun Heo <tj@kernel.org>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 fs/sysfs/dir.c        |    6 +-----
 include/linux/sysfs.h |    4 +---
 lib/kobject.c         |   17 +++++++++++++++--
 3 files changed, 17 insertions(+), 10 deletions(-)

--- a/fs/sysfs/dir.c
+++ b/fs/sysfs/dir.c
@@ -830,16 +830,12 @@ int sysfs_rename_dir(struct kobject * ko
 	if (!new_dentry)
 		goto out_unlock;
 
-	/* rename kobject and sysfs_dirent */
+	/* rename sysfs_dirent */
 	error = -ENOMEM;
 	new_name = dup_name = kstrdup(new_name, GFP_KERNEL);
 	if (!new_name)
 		goto out_unlock;
 
-	error = kobject_set_name(kobj, "%s", new_name);
-	if (error)
-		goto out_unlock;
-
 	dup_name = sd->s_name;
 	sd->s_name = new_name;
 
--- a/include/linux/sysfs.h
+++ b/include/linux/sysfs.h
@@ -20,8 +20,6 @@
 struct kobject;
 struct module;
 
-extern int kobject_set_name(struct kobject *kobj, const char *name, ...)
-			    __attribute__((format(printf, 2, 3)));
 /* FIXME
  * The *owner field is no longer used, but leave around
  * until the tree gets cleaned up fully.
@@ -149,7 +147,7 @@ static inline void sysfs_remove_dir(stru
 
 static inline int sysfs_rename_dir(struct kobject *kobj, const char *new_name)
 {
-	return kobject_set_name(kobj, "%s", new_name);
+	return 0;
 }
 
 static inline int sysfs_move_dir(struct kobject *kobj,
--- a/lib/kobject.c
+++ b/lib/kobject.c
@@ -447,6 +447,7 @@ int kobject_rename(struct kobject *kobj,
 {
 	int error = 0;
 	const char *devpath = NULL;
+	const char *dup_name = NULL, *name;
 	char *devpath_string = NULL;
 	char *envp[2];
 
@@ -470,15 +471,27 @@ int kobject_rename(struct kobject *kobj,
 	envp[0] = devpath_string;
 	envp[1] = NULL;
 
+	name = dup_name = kstrdup(new_name, GFP_KERNEL);
+	if (!name) {
+		error = -ENOMEM;
+		goto out;
+	}
+
 	error = sysfs_rename_dir(kobj, new_name);
+	if (error)
+		goto out;
+
+	/* Install the new kobject name */
+	dup_name = kobj->name;
+	kobj->name = name;
 
 	/* This function is mostly/only used for network interface.
 	 * Some hotplug package track interfaces by their name and
 	 * therefore want to know when the name is changed by the user. */
-	if (!error)
-		kobject_uevent_env(kobj, KOBJ_MOVE, envp);
+	kobject_uevent_env(kobj, KOBJ_MOVE, envp);
 
 out:
+	kfree(dup_name);
 	kfree(devpath_string);
 	kfree(devpath);
 	kobject_put(kobj);


Patches currently in gregkh-2.6 which might be from gregkh@suse.de are

.git/logs/refs/heads/master
.git/logs/refs/heads/origin
.git/logs/refs/remotes/aria/master
.git/logs/refs/remotes/aria/origin
.git/logs/HEAD
bad/pci-domain/pci-device-ensure-sysdata-initialised.patch
bad/pci-domain/pci-fix-the-x86-pci-domain-support-fix.patch
bad/pci-domain/x86-pci-domain-support-struct-pci_sysdata.patch
bad/pci-domain/x86-pci-domain-support-a-humble-fix.patch
bad/pci-domain/x86-pci-domain-support-the-meat.patch
bad/relayfs/relay-consolidate-relayfs-core-into-kernel-relay.c.patch
bad/relayfs/relay-relay-header-cleanup.patch
bad/relayfs/sysfs-add-__attr_relay-helper-for-relay-attributes.patch
bad/relayfs/sysfs-relay-channel-buffers-as-sysfs-attributes.patch
bad/usbip/usb-usbip-more-dead-code-fix.patch
bad/usbip/usb-usbip-build-fix.patch
bad/usbip/usb-usbip-warning-fixes.patch
bad/ndevfs.patch
bad/driver-sample.sh.patch
bad/driver-model-convert-driver-model-to-mutexes.patch
bad/gpl_future-test.patch
bad/gregkh-debugfs_example.patch
bad/i2c-device-id-lm75.patch
bad/speakup-kconfig-fix.patch
bad/speakup-build-fix.patch
bad/pci-test-that-drivers-properly-call-pci_set_master.patch
bad/pci-use-new-multi-phase-suspend-infrastructure.patch
bad/speakup-core.patch
bad/uio.patch
bad/usbfs2.patch
bad/no-more-non-gpl-modules.patch
bad/usb-serial-serqt_usb.patch
bad/spi-device.patch
bad/ata_piix-multithread.patch
bad/uio-irq.patch
bad/sysfs-crash-debugging.patch
bad/pci-dynamic-id-cleanup.patch
bad/pci-piggy-bus.patch
bad/input-device_type.patch
bad/usb-iphone-charge.patch
bad/sysfs-test.patch
bad/ohci-fix-toggle-bit-desynchronization-when-canceling-urbs.patch
bad/ldp/dvb-add-firesat-driver.patch
bad/ldp/video-add-the-go7007-driver.patch
bad/ldp/framebuffer-add-the-via-framebuffer-driver.patch
bad/ldp/net-add-alacritech-slicoss-driver.patch
bad/ldp/aectc-add-the-aectc-driver.patch
bad/ldp/me4000-firmware-file.patch
bad/ldp/novfs-add-the-novell-filesystem-client-kernel-module.patch
bad/ldp/net-add-et131x-driver.patch
bad/ldp/oms-add-oms-maxp-driver.patch
bad/ldp/me4000-add-pci-data-collection-driver.patch
bad/ldp/usb-add-usb-test-and-measurement-class-driver.patch
bad/ldp/kolter_1616-add-kolter_1616-pci-i-o-driver.patch
bad/ldp.next/usb-add-option-hso-driver.patch
bad/ldp.next/usb-add-sensoray-2255-v4l-driver.patch
bad/ldp.next/input-add-appleir-driver.patch
gregkh/gkh-version.patch
gregkh/sysrq-u-laptop.patch
usb/usb-gotemp.patch
usb/hso-fix-oops-in-read-write-callbacks.patch
usb/hso-fix-refcounting-on-the-ttyhsx-devices.patch
usb/usb-hso-make-tty_operations-const.patch
usb/usb-hso-minor-fixes-due-to-code-review.patch
usb/usb-add-config_usb_debug_messages-and-usb_dbg.patch
usb/usb-convert-the-usb-core-code-to-use-usb_dbg.patch
usb/usb-remove-config_usb_debug.patch
usb/usb-convert-the-usb-host-controller-code-to-use-usb_dbg.patch
usb/usb-remove-warn-macro-from-usb.h.patch
usb/usb-remove-info-macro-from-usb.h.patch
usb/hso-icon-322-detection-fix.patch
usb/hso-dev_kfree_skb-crash-fix.patch
usb/usb-add-new-pm-callback-methods-for-usb.patch
usb/drivers-usb-class-usblp.c-adjust-error-handling-code.patch
usb/usb-kill-urbs-permanently.patch
usb/usb-extend-poisoning-to-anchors.patch
usb/ub-remove-sg_stat.patch
usb/usb-added-driver-for-a-delcom-usb-7-segment-led-display.patch
usb/usb-add-udev-argument-to-interface-suspend-resume-functions.patch
usb/usb-defer-set-interface-for-suspended-devices.patch
usb/usb-don-t-rebind-before-complete-callback.patch
usb/usb-gadget-dummy_hcd-implement-set_wedge.patch
usb/usb-gadget-kconfig-cleanup.patch
usb/usb-gadget-net2280-implement-set_wedge.patch
usb/usb-let-some-usb-host-controllers-get-irq-flags-from-resource.patch
usb/usb-removed-unused-include-version.h.patch
usb.current/usb-cdc-acm-quirk-for-conexant-cx93010-usb-modem.patch
usb.current/usb-fix-bug-in-usb_unlink_anchored_urbs.patch
usb.current/usb-fix-pxa27x_udc-usb-speed-handling.patch
usb.current/usb-isp1760-fixed-trivial-math-in-comment.patch
usb.current/usb-serial-option-support-hsdpa-modem-a2502.patch
HOWTO
driver-core/put_device-might_sleep.patch
driver-core/sysfs-crash-debugging.patch
driver-core/warn-when-statically-allocated-kobjects-are-used.patch
driver-core/usb-gadget-make-gadget_core.ko.patch
driver-core/net-convert-the-phy_device-file-to-use-bus_find_device_by_name.patch
driver-core/s390-bus_id-dev_set_name-for-css-and-ccw-busses.patch
driver-core/driver-core-make-struct-platform_pm_ops-static.patch
driver-core/sysfs-support-sysfs_notify-from-atomic-context-with-new-sysfs_notify_dirent.patch
driver-core/driver-core-basic-infrastructure-for-per-module-dynamic-debug-messages.patch
driver-core/usb-gadget-move-f_acm.c-and-u_serial.c-gadget_acm_core.ko.patch
driver-core/usb-gadget-move-f_ecm.c-to-gadget_ecm_core.ko.patch
driver-core/usb-gadget-move-u_ether.c-to-gadget_ether_core.ko.patch
driver-core/usb-gadget-move-library-files-into-g_cdc.ko.patch
driver-core/usb-gadget-move-library-files-into-g_ether.ko.patch
driver-core/usb-gadget-move-library-files-into-g_file_storage.ko.patch
driver-core/usb-gadget-move-library-files-into-g_midi.ko.patch
driver-core/usb-gadget-move-library-files-into-g_printer.ko.patch
driver-core/usb-gadget-move-library-files-into-g_serial-ko.patch
driver-core/usb-gadget-move-library-files-into-g_zero.ko.patch
driver-core/device-create-block-convert-device_create_drvdata-to-device_create.patch
driver-core/device-create-char-convert-device_create_drvdata-to-device_create.patch
driver-core/device-create-ide-convert-device_create_drvdata-to-device_create.patch
driver-core/device-create-ieee1394-convert-device_create_drvdata-to-device_create.patch
driver-core/device-create-infiniband-convert-device_create_drvdata-to-device_create.patch
driver-core/device-create-misc-convert-device_create_drvdata-to-device_create.patch
driver-core/device-create-net-convert-device_create_drvdata-to-device_create.patch
driver-core/device-create-remove-device_create_drvdata.patch
driver-core/device-create-s390-convert-device_create_drvdata-to-device_create.patch
driver-core/device-create-scsi-convert-device_create_drvdata-to-device_create.patch
driver-core/device-create-sound-convert-device_create_drvdata-to-device_create.patch
driver-core/device-create-usb-convert-device_create_drvdata-to-device_create.patch
driver-core/device-create-video-convert-device_create_drvdata-to-device_create.patch
driver-core/kobject-fix-kobject_rename-and-config_sysfs.patch
driver-core/kobject-cleanup-kobject_rename-and-config_sysfs.patch
driver-core/driver-core-convert-to-new-device-api-to-allow-names-longer-than-20-chars.patch
driver-core/driver-core-lguest-convert-to-new-device-api-to-allow-names-longer-than-20-chars.patch
driver-core/driver-core-prepare-for-removal-of-20-char-limit-from-struct-device.patch
driver-core/s390-bus_id-dev_set_name-changes.patch
driver-core/s390-more-bus_id-dev_name-conversions.patch
driver-core/s390-use-s390_root_dev_-in-kvm_virtio.patch
driver-core/s390-bus_id-dev_name-conversions.patch
driver-core/driver-core-provide-a-dev_set_name-that-handles-names-longer-than-20-chars.patch
pending/perfmon-fix-up-some-static-kobject-usages.patch
pending/kobject-change-sys-kernel-uids-to-not-use-a-kset.patch
pending/kobjects-hook-them-up-to-the-debugobjects-infrastructure.patch
pending/firmware-add-kconfig-and-makefile-to-build-the-firmware-samples.patch
driver-core.current/dev_printk-constify-the-dev-argument.patch
driver-core.current/drivers-base-driver.c-remove-unused-to_dev-macro.patch
driver-core.current/japanese-translation-of-documentation-submitchecklist.patch
driver-core.current/kobject-replace-all-occurrences-of-with-instead-of-only-the-first-one.patch
driver-core.current/driver-model-anti-oopsing-medicine.patch
driver-core.current/pm-don-t-skip-device-pm-init-when-config_pm_sleep-isn-t-set-and-config_pm-is-set.patch
driver-core.current/driver-core-add-init_name-to-struct-device.patch
driver-core.current/pm-remove-warn_on-from-device_pm_add.patch
driver-core.current/block-drop-references-taken-by-class_find_device.patch
driver-core.current/block-fix-partial-read-of-proc-partitions-diskstats.patch
