From: chas williams <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM]: [ioctl][5/8] change vcc clip info handling (from levon@movementarian.org)
Date: Thu, 25 Sep 2003 12:10:42 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309251610.h8PGAekT006965@ginger.cmf.nrl.navy.mil>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.6 -- thanks

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1451  -> 1.1452 
#	      net/atm/proc.c	1.30    -> 1.31   
#	include/linux/atmdev.h	1.30    -> 1.31   
#	      net/atm/clip.c	1.26    -> 1.27   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/09/23	chas@relax.cmf.nrl.navy.mil	1.1452
# [ATM]: [ioctl][5/8] change vcc clip info handling (from levon@movementarian.org)
# --------------------------------------------
#
diff -Nru a/include/linux/atmdev.h b/include/linux/atmdev.h
--- a/include/linux/atmdev.h	Thu Sep 25 09:24:35 2003
+++ b/include/linux/atmdev.h	Thu Sep 25 09:24:35 2003
@@ -253,6 +253,7 @@
 	ATM_VF_HASSAP,		/* SAP has been set */
 	ATM_VF_CLOSE,		/* asynchronous close - treat like VF_RELEASED*/
 	ATM_VF_WAITING,		/* waiting for reply from sigd */
+	ATM_VF_IS_CLIP,		/* in use by CLIP protocol */
 };
 
 
diff -Nru a/net/atm/clip.c b/net/atm/clip.c
--- a/net/atm/clip.c	Thu Sep 25 09:24:35 2003
+++ b/net/atm/clip.c	Thu Sep 25 09:24:35 2003
@@ -488,6 +488,7 @@
 	DPRINTK("mkip clip_vcc %p vcc %p\n",clip_vcc,vcc);
 	clip_vcc->vcc = vcc;
 	vcc->user_back = clip_vcc;
+	set_bit(ATM_VF_IS_CLIP, &vcc->flags);
 	clip_vcc->entry = NULL;
 	clip_vcc->xoff = 0;
 	clip_vcc->encap = 1;
diff -Nru a/net/atm/proc.c b/net/atm/proc.c
--- a/net/atm/proc.c	Thu Sep 25 09:24:35 2003
+++ b/net/atm/proc.c	Thu Sep 25 09:24:35 2003
@@ -25,6 +25,7 @@
 #include <linux/atmarp.h>
 #include <linux/if_arp.h>
 #include <linux/init.h> /* for __init */
+#include <net/atmclip.h>
 #include <asm/uaccess.h>
 #include <asm/atomic.h>
 #include <asm/param.h> /* for HZ */
@@ -32,9 +33,6 @@
 #include "common.h" /* atm_proc_init prototype */
 #include "signaling.h" /* to get sigd - ugly too */
 
-#include <net/atmclip.h>
-#include "ipcommon.h"
-
 #if defined(CONFIG_ATM_LANE) || defined(CONFIG_ATM_LANE_MODULE)
 #include "lec.h"
 #include "lec_arpc.h"
@@ -139,7 +137,6 @@
 struct vcc_state {
 	struct sock *sk;
 	int family;
-	int clip_info;
 };
 
 static inline int compare_family(struct sock *sk, int family)
@@ -190,7 +187,6 @@
 		goto out_kfree;
 
 	state->family = family;
-	state->clip_info = try_atm_clip_ops();
 
 	seq = file->private_data;
 	seq->private = state;
@@ -203,13 +199,6 @@
 
 static int vcc_seq_release(struct inode *inode, struct file *file)
 {
-#if defined(CONFIG_ATM_CLIP) || defined(CONFIG_ATM_CLIP_MODULE)
-	struct seq_file *seq = file->private_data;
-	struct vcc_state *state = seq->private;
-
-	if (state->clip_info)
-		module_put(atm_clip_ops->owner);
-#endif
 	return seq_release_private(inode, file);
 }
 
@@ -237,7 +226,7 @@
 	return v;
 }
 
-static void pvc_info(struct seq_file *seq, struct atm_vcc *vcc, int clip_info)
+static void pvc_info(struct seq_file *seq, struct atm_vcc *vcc)
 {
 	static const char *class_name[] = { "off","UBR","CBR","VBR","ABR" };
 	static const char *aal_name[] = {
@@ -252,8 +241,7 @@
 	    aal_name[vcc->qos.aal],vcc->qos.rxtp.min_pcr,
 	    class_name[vcc->qos.rxtp.traffic_class],vcc->qos.txtp.min_pcr,
 	    class_name[vcc->qos.txtp.traffic_class]);
-#if defined(CONFIG_ATM_CLIP) || defined(CONFIG_ATM_CLIP_MODULE)
-	if (clip_info && (vcc->push == atm_clip_ops->clip_push)) {
+	if (test_bit(ATM_VF_IS_CLIP, &vcc->flags)) {
 		struct clip_vcc *clip_vcc = CLIP_VCC(vcc);
 		struct net_device *dev;
 
@@ -262,7 +250,6 @@
 		    dev ? dev->name : "none?");
 		seq_printf(seq, "%s", clip_vcc->encap ? "LLC/SNAP" : "None");
 	}
-#endif
 	seq_putc(seq, '\n');
 }
 
@@ -405,7 +392,7 @@
 		struct vcc_state *state = seq->private;
 		struct atm_vcc *vcc = atm_sk(state->sk);
 
-		pvc_info(seq, vcc, state->clip_info);
+		pvc_info(seq, vcc);
 	}
 	return 0;
 }
