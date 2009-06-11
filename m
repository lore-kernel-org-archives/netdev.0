From: Minoru Usui <usui@mxm.nes.nec.co.jp>
Subject: [PATCH 1/1] cls_cgroup: unify classid syntax to tc
Date: Thu, 11 Jun 2009 18:05:55 +0900
Message-ID: <20090611180555.f2c76568.usui@mxm.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, hadi@cyberus.ca, jarkao2@gmail.com
To: containers@lists.linux-foundation.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO201.gate.nec.co.jp ([202.32.8.193]:53668 "EHLO
	tyo201.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752650AbZFKJJ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 05:09:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

cls_cgroup: unify classid syntax to tc

This patch unifies classid syntax of cls_cgroup to tc.
In present implementation of cls_cgroup, classid read/write syntax is different from tc's one.

  tc     1:10
  write  0x10010 (hexadecimal)
  read   65552   (decimal)

-------------------------------------------------
  # echo 0x10010 > /cgroup/net/net_cls.classid
  # cat /cgroup/net/net_cls.classid
  65552
-------------------------------------------------

This is very inconvenient, so I made a patch which enables only tc syntax.
If we don't classify with net_cls.classid, we write 0 to net_cls.classid.
(This behavior is the same as present implementation.)

-------------------------------------------------
  # echo 1:10 > /cgroup/net/net_cls.classid
  # cat /cgroup/net/net_cls.classid
  1:10
  # echo 0 > /cgroup/net/net_cls.classid
  # cat /cgroup/net/net_cls.classid
  0
-------------------------------------------------


Signed-off-by: Minoru Usui <usui@mxm.nes.nec.co.jp>

diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index e5becb9..6d87d00 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -12,6 +12,7 @@
 #include <linux/module.h>
 #include <linux/types.h>
 #include <linux/string.h>
+#include <linux/ctype.h>
 #include <linux/errno.h>
 #include <linux/skbuff.h>
 #include <linux/cgroup.h>
@@ -55,17 +56,76 @@ static void cgrp_destroy(struct cgroup_subsys *ss, struct cgroup *cgrp)
 	kfree(cgrp_cls_state(cgrp));
 }
 
-static u64 read_classid(struct cgroup *cgrp, struct cftype *cft)
+#define CLS_CGROUP_CLASSID_LEN 16
+
+static ssize_t read_classid(struct cgroup *cgrp, struct cftype *cft,
+				struct file *file, char __user *buf,
+				size_t nbytes, loff_t *ppos)
+{
+	u32 value;
+	char classid[CLS_CGROUP_CLASSID_LEN];
+
+	value = cgrp_cls_state(cgrp)->classid;
+	if (value)
+		sprintf(classid, "%x:%x\n",
+			TC_H_MAJ(value)>>16, TC_H_MIN(value));
+	else
+		strcpy(classid, "0\n");
+
+	return simple_read_from_buffer(buf, nbytes, ppos,
+					classid, strlen(classid));
+}
+
+static int get_tc_classid(u32 *classid, const char *str)
 {
-	return cgrp_cls_state(cgrp)->classid;
+	u32 maj, min;
+	char *p;
+
+	/* check "0" for reset request */
+	if (!strcmp(str, "0")) {
+		*classid = 0;
+		return 0;
+	}
+
+	/* parse major number */
+	maj = simple_strtoul(str, &p, 16);
+	if (p == str) {
+		maj = 0;
+		if (*p != ':')
+			return -EINVAL;
+	}
+
+	/* parse minor number */
+	if (*p == ':') {
+		if (maj >= (1<<16))
+			return -EINVAL;
+
+		str = p + 1;
+		min = simple_strtoul(str, &p, 16);
+		if (*p != 0)
+			return -EINVAL;
+		if (min >= (1<<16))
+			return -EINVAL;
+	} else if (*p != 0)
+		return -EINVAL;
+
+	*classid = TC_H_MAKE(maj<<16, min);
+
+	return 0;
 }
 
-static int write_classid(struct cgroup *cgrp, struct cftype *cft, u64 value)
+static int write_classid(struct cgroup *cgrp, struct cftype *cft,
+				const char *buf)
 {
+	u32 classid;
+
 	if (!cgroup_lock_live_group(cgrp))
 		return -ENODEV;
 
-	cgrp_cls_state(cgrp)->classid = (u32) value;
+	if (get_tc_classid(&classid, buf) < 0)
+		return -EINVAL;
+
+	cgrp_cls_state(cgrp)->classid = classid;
 
 	cgroup_unlock();
 
@@ -75,8 +135,8 @@ static int write_classid(struct cgroup *cgrp, struct cftype *cft, u64 value)
 static struct cftype ss_files[] = {
 	{
 		.name = "classid",
-		.read_u64 = read_classid,
-		.write_u64 = write_classid,
+		.read = read_classid,
+		.write_string = write_classid,
 	},
 };
 

-- 
Minoru Usui <usui@mxm.nes.nec.co.jp>
