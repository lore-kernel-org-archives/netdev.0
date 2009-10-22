From: dann frazier <dannf@hp.com>
Subject: [PATCH] udev: create empty regular files to represent net
 interfaces
Date: Thu, 22 Oct 2009 00:36:20 -0600
Message-ID: <20091022063619.GB6321@ldl.fc.hp.com>
References: <20091016214024.GA10091@ldl.fc.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Narendra_K@Dell.com, netdev@vger.kernel.org, Matt_Domsch@Dell.com,
	Jordan_Hargrave@Dell.com, Charles_Rose@Dell.com,
	Ben Hutchings <bhutchings@solarflare.com>
To: linux-hotplug@vger.kernel.org
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20091016214024.GA10091@ldl.fc.hp.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Here's a proof of concept to further the discussion..

The default filename uses the format:
  /dev/netdev/by-ifindex/$ifindex

This provides the infrastructure to permit udev rules to create aliases for
network devices using symlinks, for example:

  /dev/netdev/by-name/eth0 -> ../by-ifindex/1
  /dev/netdev/by-biosname/LOM0 -> ../by-ifindex/3

A library (such as the proposed libnetdevname) could use this information
to provide an alias->realname mapping for network utilities.

Tested with the following rule:

SUBSYSTEM=="net", PROGRAM=="/usr/local/bin/ifindex2name $attr{ifindex}", SYMLINK+="netdev/by-name/%c"

$ cat /usr/local/bin/ifindex2name
#!/bin/sh

set -e

ifindex="$1"

for d in /sys/class/net/*; do
    testindex="$(cat $d/ifindex)"
    if [ "$ifindex" = "$testindex" ]; then
	echo "$(basename $d)"
	exit 0
    fi
done

exit 1

---
 libudev/exported_symbols |    1 +
 libudev/libudev.c        |   29 ++++++++++++++++
 libudev/libudev.h        |    1 +
 udev/udev-event.c        |   82 ++++++++++++++++++++--------------------------
 udev/udev-node.c         |   41 ++++++++++++++++++++---
 udev/udev-rules.c        |    3 +-
 6 files changed, 105 insertions(+), 52 deletions(-)

diff --git a/libudev/exported_symbols b/libudev/exported_symbols
index 018463d..31c616a 100644
--- a/libudev/exported_symbols
+++ b/libudev/exported_symbols
@@ -8,6 +8,7 @@ udev_get_userdata
 udev_set_userdata
 udev_get_sys_path
 udev_get_dev_path
+udev_get_netdev_path
 udev_list_entry_get_next
 udev_list_entry_get_by_name
 udev_list_entry_get_name
diff --git a/libudev/libudev.c b/libudev/libudev.c
index 1909138..2a83417 100644
--- a/libudev/libudev.c
+++ b/libudev/libudev.c
@@ -42,6 +42,7 @@ struct udev {
 	void *userdata;
 	char *sys_path;
 	char *dev_path;
+	char *netdev_path;
 	char *rules_path;
 	struct udev_list_node properties_list;
 	int log_priority;
@@ -125,8 +126,10 @@ struct udev *udev_new(void)
 	udev->run = 1;
 	udev->dev_path = strdup("/dev");
 	udev->sys_path = strdup("/sys");
+	udev->netdev_path = strdup("/dev/netdev/by-ifindex");
 	config_file = strdup(SYSCONFDIR "/udev/udev.conf");
 	if (udev->dev_path == NULL ||
+	    udev->netdev_path == NULL ||
 	    udev->sys_path == NULL ||
 	    config_file == NULL)
 		goto err;
@@ -243,6 +246,14 @@ struct udev *udev_new(void)
 		udev_add_property(udev, "UDEV_ROOT", udev->dev_path);
 	}
 
+	env = getenv("NETDEV_ROOT");
+	if (env != NULL) {
+		free(udev->netdev_path);
+		udev->netdev_path = strdup(env);
+		util_remove_trailing_chars(udev->netdev_path, '/');
+		udev_add_property(udev, "NETDEV_ROOT", udev->netdev_path);
+	}
+
 	env = getenv("UDEV_LOG");
 	if (env != NULL)
 		udev_set_log_priority(udev, util_log_priority(env));
@@ -253,6 +264,7 @@ struct udev *udev_new(void)
 	dbg(udev, "log_priority=%d\n", udev->log_priority);
 	dbg(udev, "config_file='%s'\n", config_file);
 	dbg(udev, "dev_path='%s'\n", udev->dev_path);
+	dbg(udev, "netdev_path='%s'\n", udev->netdev_path);
 	dbg(udev, "sys_path='%s'\n", udev->sys_path);
 	if (udev->rules_path != NULL)
 		dbg(udev, "rules_path='%s'\n", udev->rules_path);
@@ -398,6 +410,23 @@ const char *udev_get_dev_path(struct udev *udev)
 	return udev->dev_path;
 }
 
+/**
+ * udev_get_netdev_path:
+ * @udev: udev library context
+ *
+ * Retrieve the device directory path. The default value is "/etc/udev/net",
+ * the actual value may be overridden in the udev configuration
+ * file.
+ *
+ * Returns: the device directory path
+ **/
+const char *udev_get_netdev_path(struct udev *udev)
+{
+	if (udev == NULL)
+		return NULL;
+	return udev->netdev_path;
+}
+
 struct udev_list_entry *udev_add_property(struct udev *udev, const char *key, const char *value)
 {
 	if (value == NULL) {
diff --git a/libudev/libudev.h b/libudev/libudev.h
index 4bcf442..5834781 100644
--- a/libudev/libudev.h
+++ b/libudev/libudev.h
@@ -77,6 +77,7 @@ struct udev_device *udev_device_get_parent_with_subsystem_devtype(struct udev_de
 								  const char *subsystem, const char *devtype);
 /* retrieve device properties */
 const char *udev_device_get_devpath(struct udev_device *udev_device);
+const char *udev_device_get_netdevpath(struct udev_device *udev_device);
 const char *udev_device_get_subsystem(struct udev_device *udev_device);
 const char *udev_device_get_devtype(struct udev_device *udev_device);
 const char *udev_device_get_syspath(struct udev_device *udev_device);
diff --git a/udev/udev-event.c b/udev/udev-event.c
index d5b4d09..953f87a 100644
--- a/udev/udev-event.c
+++ b/udev/udev-event.c
@@ -542,7 +542,7 @@ int udev_event_execute_rules(struct udev_event *event, struct udev_rules *rules)
 	}
 
 	/* add device node */
-	if (major(udev_device_get_devnum(dev)) != 0 &&
+	if ((major(udev_device_get_devnum(dev)) != 0 || strcmp(udev_device_get_subsystem(dev), "net") == 0) &&
 	    (strcmp(udev_device_get_action(dev), "add") == 0 || strcmp(udev_device_get_action(dev), "change") == 0)) {
 		char filename[UTIL_PATH_SIZE];
 		struct udev_device *dev_old;
@@ -603,10 +603,38 @@ int udev_event_execute_rules(struct udev_event *event, struct udev_rules *rules)
 			goto exit_add;
 		}
 
-		/* set device node name */
-		util_strscpyl(filename, sizeof(filename), udev_get_dev_path(event->udev), "/", event->name, NULL);
-		udev_device_set_devnode(dev, filename);
-
+		/* add netif */
+		if (strcmp(udev_device_get_subsystem(dev), "net") == 0 &&
+		    strcmp(udev_device_get_action(dev), "add") == 0) {
+			char syspath[UTIL_PATH_SIZE];
+			info(event->udev, "netif add '%s'\n", udev_device_get_devpath(dev));
+			/* look if we want to change the name of the netif */
+			if (strcmp(event->name, udev_device_get_sysname(dev)) != 0) {
+				char *pos;
+				err = rename_netif(event);
+				if (err != 0)
+					goto exit;
+				info(event->udev, "renamed netif to '%s'\n", event->name);
+				
+				/* remember old name */
+				udev_device_add_property(dev, "INTERFACE_OLD", udev_device_get_sysname(dev));
+				
+				/* now change the devpath, because the kernel device name has changed */
+				util_strscpy(syspath, sizeof(syspath), udev_device_get_syspath(dev));
+				pos = strrchr(syspath, '/');
+				if (pos != NULL) {
+					pos++;
+					util_strscpy(pos, sizeof(syspath) - (pos - syspath), event->name);
+					udev_device_set_syspath(event->dev, syspath);
+					udev_device_add_property(dev, "INTERFACE", udev_device_get_sysname(dev));
+					info(event->udev, "changed devpath to '%s'\n", udev_device_get_devpath(dev));
+				}
+			}
+			snprintf(syspath, sizeof(syspath), "%s/%s", udev_get_netdev_path(event->udev),
+				 udev_device_get_property_value(event->dev, "IFINDEX"));
+			udev_device_set_devnode(dev, syspath);
+		}
+		    
 		/* write current database entry */
 		udev_device_update_db(dev);
 
@@ -632,49 +660,11 @@ exit_add:
 		goto exit;
 	}
 
-	/* add netif */
-	if (strcmp(udev_device_get_subsystem(dev), "net") == 0 && strcmp(udev_device_get_action(dev), "add") == 0) {
-		dbg(event->udev, "netif add '%s'\n", udev_device_get_devpath(dev));
-		udev_device_delete_db(dev);
-
-		udev_rules_apply_to_event(rules, event);
-		if (event->ignore_device) {
-			info(event->udev, "device event will be ignored\n");
-			goto exit;
-		}
-		if (event->name == NULL)
-			goto exit;
-
-		/* look if we want to change the name of the netif */
-		if (strcmp(event->name, udev_device_get_sysname(dev)) != 0) {
-			char syspath[UTIL_PATH_SIZE];
-			char *pos;
-
-			err = rename_netif(event);
-			if (err != 0)
-				goto exit;
-			info(event->udev, "renamed netif to '%s'\n", event->name);
-
-			/* remember old name */
-			udev_device_add_property(dev, "INTERFACE_OLD", udev_device_get_sysname(dev));
-
-			/* now change the devpath, because the kernel device name has changed */
-			util_strscpy(syspath, sizeof(syspath), udev_device_get_syspath(dev));
-			pos = strrchr(syspath, '/');
-			if (pos != NULL) {
-				pos++;
-				util_strscpy(pos, sizeof(syspath) - (pos - syspath), event->name);
-				udev_device_set_syspath(event->dev, syspath);
-				udev_device_add_property(dev, "INTERFACE", udev_device_get_sysname(dev));
-				info(event->udev, "changed devpath to '%s'\n", udev_device_get_devpath(dev));
-			}
-		}
-		udev_device_update_db(dev);
-		goto exit;
-	}
 
 	/* remove device node */
-	if (major(udev_device_get_devnum(dev)) != 0 && strcmp(udev_device_get_action(dev), "remove") == 0) {
+	if ((major(udev_device_get_devnum(dev)) != 0 ||
+	     strcmp(udev_device_get_subsystem(dev), "net") == 0) &&
+	    strcmp(udev_device_get_action(dev), "remove") == 0) {
 		/* import database entry and delete it */
 		udev_device_read_db(dev);
 		udev_device_set_info_loaded(dev);
diff --git a/udev/udev-node.c b/udev/udev-node.c
index 39bec3e..da96a4a 100644
--- a/udev/udev-node.c
+++ b/udev/udev-node.c
@@ -32,6 +32,34 @@
 
 #define TMP_FILE_EXT		".udev-tmp"
 
+static bool udev_node_mode_matches(struct stat *stats, dev_t devnum, mode_t mode)
+{
+	if ((stats->st_mode & S_IFMT) != (mode & S_IFMT))
+		return false;
+
+	if ((S_ISCHR(mode) || S_ISBLK(mode)) && (stats->st_rdev != devnum))
+		return false;
+
+	return true;
+}
+
+static int udev_node_create_file(struct udev *udev, const char *path, dev_t devnum, mode_t mode)
+{
+	int fd, ret = 0;
+
+	if (S_ISCHR(mode) || S_ISBLK(mode))
+		ret = mknod(path, mode, devnum);
+	else {
+		fd = creat(path, mode);
+		if (fd < 0)
+			ret = fd;
+		else
+			close(fd);
+	}
+
+	return ret;
+}
+
 int udev_node_mknod(struct udev_device *dev, const char *file, dev_t devnum, mode_t mode, uid_t uid, gid_t gid)
 {
 	struct udev *udev = udev_device_get_udev(dev);
@@ -47,12 +75,15 @@ int udev_node_mknod(struct udev_device *dev, const char *file, dev_t devnum, mod
 	else
 		mode |= S_IFCHR;
 
+	if (strcmp(udev_device_get_subsystem(dev), "net") == 0)
+		mode = S_IFREG | S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH;
+
 	if (file == NULL)
 		file = udev_device_get_devnode(dev);
 
 	if (lstat(file, &stats) == 0) {
-		if (((stats.st_mode & S_IFMT) == (mode & S_IFMT)) && (stats.st_rdev == devnum)) {
-			info(udev, "preserve file '%s', because it has correct dev_t\n", file);
+		if (udev_node_mode_matches(&stats, devnum, mode)) {
+			info(udev, "preserve file '%s', because it has correct type\n", file);
 			preserve = 1;
 			udev_selinux_lsetfilecon(udev, file, mode);
 		} else {
@@ -62,10 +93,10 @@ int udev_node_mknod(struct udev_device *dev, const char *file, dev_t devnum, mod
 			util_strscpyl(file_tmp, sizeof(file_tmp), file, TMP_FILE_EXT, NULL);
 			unlink(file_tmp);
 			udev_selinux_setfscreatecon(udev, file_tmp, mode);
-			err = mknod(file_tmp, mode, devnum);
+			err = udev_node_create_file(udev, file_tmp, devnum, mode);
 			udev_selinux_resetfscreatecon(udev);
 			if (err != 0) {
-				err(udev, "mknod(%s, %#o, %u, %u) failed: %m\n",
+				err(udev, "udev_node_create_file(%s, %#o, %u, %u) failed: %m\n",
 				    file_tmp, mode, major(devnum), minor(devnum));
 				goto exit;
 			}
@@ -80,7 +111,7 @@ int udev_node_mknod(struct udev_device *dev, const char *file, dev_t devnum, mod
 		do {
 			util_create_path(udev, file);
 			udev_selinux_setfscreatecon(udev, file, mode);
-			err = mknod(file, mode, devnum);
+			err = udev_node_create_file(udev, file, devnum, mode);
 			if (err != 0)
 				err = errno;
 			udev_selinux_resetfscreatecon(udev);
diff --git a/udev/udev-rules.c b/udev/udev-rules.c
index ddb51de..a1fe991 100644
--- a/udev/udev-rules.c
+++ b/udev/udev-rules.c
@@ -2435,7 +2435,8 @@ int udev_rules_apply_to_event(struct udev_rules *rules, struct udev_event *event
 
 				if (event->devlink_final)
 					break;
-				if (major(udev_device_get_devnum(event->dev)) == 0)
+				if ((major(udev_device_get_devnum(event->dev)) == 0) &&
+				    (strcmp(udev_device_get_subsystem(event->dev), "net") != 0))
 					break;
 				if (cur->key.op == OP_ASSIGN_FINAL)
 					event->devlink_final = 1;
-- 
1.6.5



