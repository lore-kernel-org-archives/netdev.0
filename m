From: "chas williams (contractor)" <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM]: [atmtcp] fix refcounting and vcc search
Date: Sat, 06 Nov 2004 08:38:19 -0500
Message-ID: <200411061338.iA6DcJTO017887@ginger.cmf.nrl.navy.mil>
Cc: davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

i must have been a bit confused when i originally converted this use
the hash.  please apply to 2.6.

thanks!

Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/11/06 08:21:01-05:00 chas@relax.cmf.nrl.navy.mil 
#   atmtcp.c:
#     [ATM]: [atmtcp] fix refcounting and vcc search
# 
# drivers/atm/atmtcp.c
#   2004/11/06 08:16:23-05:00 chas@relax.cmf.nrl.navy.mil +25 -17
#   [ATM]: [atmtcp] fix refcounting and vcc search
# 
diff -Nru a/drivers/atm/atmtcp.c b/drivers/atm/atmtcp.c
--- a/drivers/atm/atmtcp.c	2004-11-06 08:22:42 -05:00
+++ b/drivers/atm/atmtcp.c	2004-11-06 08:22:42 -05:00
@@ -271,6 +271,28 @@
 		}
 	}
 	read_unlock(&vcc_sklist_lock);
+	module_put(THIS_MODULE);
+}
+
+
+static struct atm_vcc *find_vcc(struct atm_dev *dev, short vpi, int vci)
+{
+        struct hlist_head *head;
+        struct atm_vcc *vcc;
+        struct hlist_node *node;
+        struct sock *s;
+
+        head = &vcc_hash[vci & (VCC_HTABLE_SIZE -1)];
+
+        sk_for_each(s, node, head) {
+                vcc = atm_sk(s);
+                if (vcc->dev == dev &&
+                    vcc->vci == vci && vcc->vpi == vpi &&
+                    vcc->qos.rxtp.traffic_class != ATM_NONE) {
+                                return vcc;
+                }
+        }
+        return NULL;
 }
 
 
@@ -278,11 +300,9 @@
 {
 	struct atm_dev *dev;
 	struct atmtcp_hdr *hdr;
-	struct sock *s;
-	struct hlist_node *node;
-	struct atm_vcc *out_vcc = NULL;
+	struct atm_vcc *out_vcc;
 	struct sk_buff *new_skb;
-	int i, result = 0;
+	int result = 0;
 
 	if (!skb->len) return 0;
 	dev = vcc->dev_data;
@@ -293,19 +313,7 @@
 		goto done;
 	}
 	read_lock(&vcc_sklist_lock);
-	for(i = 0; i < VCC_HTABLE_SIZE; ++i) {
-		struct hlist_head *head = &vcc_hash[i];
-
-		sk_for_each(s, node, head) {
-			out_vcc = atm_sk(s);
-			if (out_vcc->dev != dev)
-				continue;
-			if (out_vcc->vpi == ntohs(hdr->vpi) &&
-			    out_vcc->vci == ntohs(hdr->vci) &&
-			    out_vcc->qos.rxtp.traffic_class != ATM_NONE)
-				break;
-		}
-	}
+	out_vcc = find_vcc(dev, ntohs(hdr->vpi), ntohs(hdr->vci));
 	read_unlock(&vcc_sklist_lock);
 	if (!out_vcc) {
 		atomic_inc(&vcc->stats->tx_err);
