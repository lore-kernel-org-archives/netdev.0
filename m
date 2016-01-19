From: "=?UTF-8?q?Jo=C3=A3o=20Paulo=20Rechi=20Vita?=" <jprvita@gmail.com>
Subject: [PATCH 5/8] rfkill: Remove obsolete "state" sysfs interface
Date: Tue, 19 Jan 2016 10:42:40 -0500
Message-ID: <1453218163-31998-6-git-send-email-jprvita@endlessm.com>
References: <1453218163-31998-1-git-send-email-jprvita@endlessm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: marcel@holtmann.org, linux-wireless@vger.kernel.org,
	davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jprvita@endlessm.com,
	linux@endlessm.com
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:35672 "EHLO
	mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756317AbcASPoI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2016 10:44:08 -0500
In-Reply-To: <1453218163-31998-1-git-send-email-jprvita@endlessm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This was schedule to be removed in 2014 by:

 commit 69c86373c6ea1149aa559e6088362d58d8ec8835
 Author: florian@mickler.org <florian@mickler.org>
 Date:   Wed Feb 24 12:05:16 2010 +0100

     Document the rfkill sysfs ABI

     This moves sysfs ABI info from Documentation/rfkill.txt to the
     ABI subfolder and reformats it.

     This also schedules the deprecated sysfs parts to be removed in
     2012 (claim file) and 2014 (state file).

     Signed-off-by: Florian Mickler <florian@mickler.org>
     Signed-off-by: John W. Linville <linville@tuxdriver.com>

Signed-off-by: Jo=C3=A3o Paulo Rechi Vita <jprvita@endlessm.com>
---
 Documentation/ABI/obsolete/sysfs-class-rfkill | 20 ---------------
 Documentation/ABI/removed/sysfs-class-rfkill  | 17 +++++++++++++
 net/rfkill/core.c                             | 35 -------------------=
--------
 3 files changed, 17 insertions(+), 55 deletions(-)
 delete mode 100644 Documentation/ABI/obsolete/sysfs-class-rfkill

diff --git a/Documentation/ABI/obsolete/sysfs-class-rfkill b/Documentat=
ion/ABI/obsolete/sysfs-class-rfkill
deleted file mode 100644
index e736d14..0000000
--- a/Documentation/ABI/obsolete/sysfs-class-rfkill
+++ /dev/null
@@ -1,20 +0,0 @@
-rfkill - radio frequency (RF) connector kill switch support
-
-For details to this subsystem look at Documentation/rfkill.txt.
-
-What:		/sys/class/rfkill/rfkill[0-9]+/state
-Date:		09-Jul-2007
-KernelVersion	v2.6.22
-Contact:	linux-wireless@vger.kernel.org
-Description: 	Current state of the transmitter.
-		This file is deprecated and scheduled to be removed in 2014,
-		because its not possible to express the 'soft and hard block'
-		state of the rfkill driver.
-Values: 	A numeric value.
-		0: RFKILL_STATE_SOFT_BLOCKED
-			transmitter is turned off by software
-		1: RFKILL_STATE_UNBLOCKED
-			transmitter is (potentially) active
-		2: RFKILL_STATE_HARD_BLOCKED
-			transmitter is forced off by something outside of
-			the driver's control.
diff --git a/Documentation/ABI/removed/sysfs-class-rfkill b/Documentati=
on/ABI/removed/sysfs-class-rfkill
index 3ce6231..1b93139 100644
--- a/Documentation/ABI/removed/sysfs-class-rfkill
+++ b/Documentation/ABI/removed/sysfs-class-rfkill
@@ -11,3 +11,20 @@ Description:	This file was deprecated because there =
no longer was a way to
 		This file was scheduled to be removed in 2012, and was removed
 		in 2016.
 Values: 	0: Kernel handles events
+
+What:		/sys/class/rfkill/rfkill[0-9]+/state
+Date:		09-Jul-2007
+KernelVersion	v2.6.22
+Contact:	linux-wireless@vger.kernel.org
+Description: 	Current state of the transmitter.
+		This file was deprecated and scheduled to be removed in 2014,
+		because it was not possible to express the 'soft and hard block'
+		state of the rfkill driver. It was removed in 2016.
+Values: 	A numeric value.
+		0: RFKILL_STATE_SOFT_BLOCKED
+			transmitter is turned off by software
+		1: RFKILL_STATE_UNBLOCKED
+			transmitter is (potentially) active
+		2: RFKILL_STATE_HARD_BLOCKED
+			transmitter is forced off by something outside of
+			the driver's control.
diff --git a/net/rfkill/core.c b/net/rfkill/core.c
index a05d1f1..26da4f0 100644
--- a/net/rfkill/core.c
+++ b/net/rfkill/core.c
@@ -683,46 +683,11 @@ static u8 user_state_from_blocked(unsigned long s=
tate)
 	return RFKILL_USER_STATE_UNBLOCKED;
 }
=20
-static ssize_t state_show(struct device *dev, struct device_attribute =
*attr,
-			  char *buf)
-{
-	struct rfkill *rfkill =3D to_rfkill(dev);
-
-	return sprintf(buf, "%d\n", user_state_from_blocked(rfkill->state));
-}
-
-static ssize_t state_store(struct device *dev, struct device_attribute=
 *attr,
-			   const char *buf, size_t count)
-{
-	struct rfkill *rfkill =3D to_rfkill(dev);
-	unsigned long state;
-	int err;
-
-	if (!capable(CAP_NET_ADMIN))
-		return -EPERM;
-
-	err =3D kstrtoul(buf, 0, &state);
-	if (err)
-		return err;
-
-	if (state !=3D RFKILL_USER_STATE_SOFT_BLOCKED &&
-	    state !=3D RFKILL_USER_STATE_UNBLOCKED)
-		return -EINVAL;
-
-	mutex_lock(&rfkill_global_mutex);
-	rfkill_set_block(rfkill, state =3D=3D RFKILL_USER_STATE_SOFT_BLOCKED)=
;
-	mutex_unlock(&rfkill_global_mutex);
-
-	return count;
-}
-static DEVICE_ATTR_RW(state);
-
 static struct attribute *rfkill_dev_attrs[] =3D {
 	&dev_attr_name.attr,
 	&dev_attr_type.attr,
 	&dev_attr_index.attr,
 	&dev_attr_persistent.attr,
-	&dev_attr_state.attr,
 	&dev_attr_soft.attr,
 	&dev_attr_hard.attr,
 	NULL,
--=20
2.5.0
