From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH PKT_SCHED 13/22]: mirred action: fix multiple bugs in init
 path
Date: Mon, 10 Jan 2005 20:38:05 +0100
Message-ID: <41E2D99D.5000102@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080007020007070900030002"
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080007020007070900030002
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit



--------------080007020007070900030002
Content-Type: text/x-patch;
 name="13.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="13.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/10 02:19:52+01:00 kaber@coreworks.de 
#   [PKT_SCHED]: mirred action: fix multiple bugs in init path
#   
#   - Return proper error codes
#   - Attribute sizes are not checked
#   - rta may by NULL
#   - The action is inserted into the hash before its parameters are set
#   - action in hash is freed on error path
#   - action is modified outside of the locked section
#   
#   This patch makes replacement atomic, so the old action is either
#   replaced entirely or not touched at all.
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/mirred.c
#   2005/01/10 02:19:45+01:00 kaber@coreworks.de +43 -45
#   [PKT_SCHED]: mirred action: fix multiple bugs in init path
#   
#   - Return proper error codes
#   - Attribute sizes are not checked
#   - rta may by NULL
#   - The action is inserted into the hash before its parameters are set
#   - action in hash is freed on error path
#   - action is modified outside of the locked section
#   
#   This patch makes replacement atomic, so the old action is either
#   replaced entirely or not touched at all.
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/sched/mirred.c b/net/sched/mirred.c
--- a/net/sched/mirred.c	2005-01-10 06:22:39 +01:00
+++ b/net/sched/mirred.c	2005-01-10 06:22:39 +01:00
@@ -81,36 +81,22 @@
 	struct tc_mirred *parm;
 	struct tcf_mirred *p;
 	struct net_device *dev = NULL;
-	int size = sizeof(*p), new = 0;
+	int ret = 0;
+	int ok_push = 0;
 
-	if (rtattr_parse(tb, TCA_MIRRED_MAX, RTA_DATA(rta),
-	                 RTA_PAYLOAD(rta)) < 0) {
-		DPRINTK("tcf_mirred_init BUG in user space couldnt parse "
-		        "properly\n");
-		return -1;
-	}
-
-	if (tb[TCA_MIRRED_PARMS - 1] == NULL) {
-		DPRINTK("BUG: tcf_mirred_init called with NULL params\n");
-		return -1;
-	}
-
-	parm = RTA_DATA(tb[TCA_MIRRED_PARMS - 1]);
-
-	p = tcf_hash_check(parm, a, ovr, bind);
-	if (p == NULL) { /* new */
-		p = tcf_hash_create(parm, est, a, size, ovr, bind);
-		if (p == NULL)
-			return -1;
-		new = 1;
-	}
+	if (rta == NULL || rtattr_parse(tb, TCA_MIRRED_MAX, RTA_DATA(rta),
+	                                RTA_PAYLOAD(rta)) < 0)
+		return -EINVAL;
+
+	if (tb[TCA_MIRRED_PARMS-1] == NULL ||
+	    RTA_PAYLOAD(tb[TCA_MIRRED_PARMS-1]) < sizeof(*parm))
+		return -EINVAL;
+	parm = RTA_DATA(tb[TCA_MIRRED_PARMS-1]);
 
 	if (parm->ifindex) {
-		dev = dev_get_by_index(parm->ifindex);
-		if (dev == NULL) {
-			printk("BUG: tcf_mirred_init called with bad device\n");
-			return -1;
-		}
+		dev = __dev_get_by_index(parm->ifindex);
+		if (dev == NULL)
+			return -ENODEV;
 		switch (dev->type) {
 			case ARPHRD_TUNNEL:
 			case ARPHRD_TUNNEL6:
@@ -118,36 +104,48 @@
 			case ARPHRD_IPGRE:
 			case ARPHRD_VOID:
 			case ARPHRD_NONE:
-				p->ok_push = 0;
+				ok_push = 0;
 				break;
 			default:
-				p->ok_push = 1;
+				ok_push = 1;
 				break;
 		}
-	} else {
-		if (new) {
-			kfree(p);
-			return -1;
-		}	
 	}
 
-	if (new || ovr) {
-		spin_lock(&p->lock);
-		p->action = parm->action;
-		p->eaction = parm->eaction;
-		if (parm->ifindex) {
-			p->ifindex = parm->ifindex;
-			if (ovr)
-				dev_put(p->dev);
-			p->dev = dev;
+	p = tcf_hash_check(parm->index, a, ovr, bind);
+	if (p == NULL) {
+		if (!parm->ifindex)
+			return -EINVAL;
+		p = tcf_hash_create(parm->index, est, a, sizeof(*p), ovr, bind);
+		if (p == NULL)
+			return -ENOMEM;
+		ret = ACT_P_CREATED;
+	} else {
+		if (!ovr) {
+			tcf_mirred_release(p, bind);
+			return -EEXIST;
 		}
-		spin_unlock(&p->lock);
 	}
 
+	spin_lock(&p->lock);
+	p->action = parm->action;
+	p->eaction = parm->eaction;
+	if (parm->ifindex) {
+		p->ifindex = parm->ifindex;
+		if (ret != ACT_P_CREATED)
+			dev_put(p->dev);
+		p->dev = dev;
+		dev_hold(dev);
+		p->ok_push = ok_push;
+	}
+	spin_unlock(&p->lock);
+	if (ret == ACT_P_CREATED)
+		tcf_hash_insert(p);
+
 	DPRINTK("tcf_mirred_init index %d action %d eaction %d device %s "
 	        "ifindex %d\n", parm->index, parm->action, parm->eaction,
 	        dev->name, parm->ifindex);
-	return new;
+	return ret;
 }
 
 static int

--------------080007020007070900030002--
