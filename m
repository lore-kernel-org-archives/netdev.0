From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH 32/37] sound/aoa: use .dev.of_node instead of .node in struct
	of_device
Date: Thu, 11 Mar 2010 11:06:44 -0700
Message-ID: <20100311180644.4824.41302.stgit__35331.2998232015$1268330915$gmane$org@angua>
References: <20100311174830.4824.19820.stgit@angua>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: monstr@monstr.eu, gregkh@suse.de, benh@kernel.crashing.org,
	akpm@linux-foundation.org, davem@davemloft.net,
	sfr@canb.auug.org.au, jgarzik@pobox.com, ben-linux@fluff.org,
	dwmw2@infrade
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:63703 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933816Ab0CKSG6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 13:06:58 -0500
In-Reply-To: <20100311174830.4824.19820.stgit@angua>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

.node is being removed

Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
---

 sound/aoa/fabrics/layout.c          |    2 +-
 sound/aoa/soundbus/core.c           |    8 ++++----
 sound/aoa/soundbus/i2sbus/control.c |    2 +-
 sound/aoa/soundbus/i2sbus/core.c    |    4 ++--
 sound/aoa/soundbus/sysfs.c          |    4 ++--
 5 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/sound/aoa/fabrics/layout.c b/sound/aoa/fabrics/layout.c
index 7a437da..da38f2b 100644
--- a/sound/aoa/fabrics/layout.c
+++ b/sound/aoa/fabrics/layout.c
@@ -991,7 +991,7 @@ static int aoa_fabric_layout_probe(struct soundbus_dev *sdev)
 		return -ENODEV;
 
 	/* by breaking out we keep a reference */
-	while ((sound = of_get_next_child(sdev->ofdev.node, sound))) {
+	while ((sound = of_get_next_child(sdev->ofdev.dev.of_node, sound))) {
 		if (sound->type && strcasecmp(sound->type, "soundchip") == 0)
 			break;
 	}
diff --git a/sound/aoa/soundbus/core.c b/sound/aoa/soundbus/core.c
index fa8ab28..99ca712 100644
--- a/sound/aoa/soundbus/core.c
+++ b/sound/aoa/soundbus/core.c
@@ -74,11 +74,11 @@ static int soundbus_uevent(struct device *dev, struct kobj_uevent_env *env)
 	of = &soundbus_dev->ofdev;
 
 	/* stuff we want to pass to /sbin/hotplug */
-	retval = add_uevent_var(env, "OF_NAME=%s", of->node->name);
+	retval = add_uevent_var(env, "OF_NAME=%s", of->dev.of_node->name);
 	if (retval)
 		return retval;
 
-	retval = add_uevent_var(env, "OF_TYPE=%s", of->node->type);
+	retval = add_uevent_var(env, "OF_TYPE=%s", of->dev.of_node->type);
 	if (retval)
 		return retval;
 
@@ -86,7 +86,7 @@ static int soundbus_uevent(struct device *dev, struct kobj_uevent_env *env)
 	 * it's not really legal to split it out with commas. We split it
 	 * up using a number of environment variables instead. */
 
-	compat = of_get_property(of->node, "compatible", &cplen);
+	compat = of_get_property(of->dev.of_node, "compatible", &cplen);
 	while (compat && cplen > 0) {
 		int tmp = env->buflen;
 		retval = add_uevent_var(env, "OF_COMPATIBLE_%d=%s", seen, compat);
@@ -169,7 +169,7 @@ int soundbus_add_one(struct soundbus_dev *dev)
 
 	/* sanity checks */
 	if (!dev->attach_codec ||
-	    !dev->ofdev.node ||
+	    !dev->ofdev.dev.of_node ||
 	    dev->pcmname ||
 	    dev->pcmid != -1) {
 		printk(KERN_ERR "soundbus: adding device failed sanity check!\n");
diff --git a/sound/aoa/soundbus/i2sbus/control.c b/sound/aoa/soundbus/i2sbus/control.c
index 87beb4a..799804d 100644
--- a/sound/aoa/soundbus/i2sbus/control.c
+++ b/sound/aoa/soundbus/i2sbus/control.c
@@ -41,7 +41,7 @@ int i2sbus_control_add_dev(struct i2sbus_control *c,
 {
 	struct device_node *np;
 
-	np = i2sdev->sound.ofdev.node;
+	np = i2sdev->sound.ofdev.dev.of_node;
 	i2sdev->enable = pmf_find_function(np, "enable");
 	i2sdev->cell_enable = pmf_find_function(np, "cell-enable");
 	i2sdev->clock_enable = pmf_find_function(np, "clock-enable");
diff --git a/sound/aoa/soundbus/i2sbus/core.c b/sound/aoa/soundbus/i2sbus/core.c
index 4e3b819..ddb1577 100644
--- a/sound/aoa/soundbus/i2sbus/core.c
+++ b/sound/aoa/soundbus/i2sbus/core.c
@@ -220,8 +220,8 @@ static int i2sbus_add_dev(struct macio_dev *macio,
 
 	mutex_init(&dev->lock);
 	spin_lock_init(&dev->low_lock);
-	dev->sound.ofdev.node = np;
 	dev->sound.ofdev.dma_mask = macio->ofdev.dma_mask;
+	dev->sound.ofdev.dev.of_node = np;
 	dev->sound.ofdev.dev.dma_mask = &dev->sound.ofdev.dma_mask;
 	dev->sound.ofdev.dev.parent = &macio->ofdev.dev;
 	dev->sound.ofdev.dev.release = i2sbus_release_dev;
@@ -345,7 +345,7 @@ static int i2sbus_probe(struct macio_dev* dev, const struct of_device_id *match)
 		return -ENODEV;
 	}
 
-	while ((np = of_get_next_child(dev->ofdev.node, np))) {
+	while ((np = of_get_next_child(dev->ofdev.dev.of_node, np))) {
 		if (of_device_is_compatible(np, "i2sbus") ||
 		    of_device_is_compatible(np, "i2s-modem")) {
 			got += i2sbus_add_dev(dev, control, np);
diff --git a/sound/aoa/soundbus/sysfs.c b/sound/aoa/soundbus/sysfs.c
index f580942..6496e75 100644
--- a/sound/aoa/soundbus/sysfs.c
+++ b/sound/aoa/soundbus/sysfs.c
@@ -9,7 +9,7 @@ field##_show (struct device *dev, struct device_attribute *attr,	\
               char *buf)						\
 {									\
 	struct soundbus_dev *mdev = to_soundbus_device (dev);		\
-	return sprintf (buf, format_string, mdev->ofdev.node->field);	\
+	return sprintf (buf, format_string, mdev->ofdev.dev.of_node->field); \
 }
 
 static ssize_t modalias_show(struct device *dev, struct device_attribute *attr,
@@ -25,7 +25,7 @@ static ssize_t modalias_show(struct device *dev, struct device_attribute *attr,
 		length = strlen(buf);
 	} else {
 		length = sprintf(buf, "of:N%sT%s\n",
-				 of->node->name, of->node->type);
+				 of->dev.of_node->name, of->dev.of_node->type);
 	}
 
 	return length;

