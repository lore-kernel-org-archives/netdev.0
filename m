From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH PKT_SCHED 12/17]: Fix missing unlock in ipt action error path
Date: Thu, 30 Dec 2004 04:40:33 +0100
Message-ID: <41D378B1.40202@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090101090800040307030702"
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090101090800040307030702
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Fix missing unlock in ipt action error path.


--------------090101090800040307030702
Content-Type: text/x-patch;
 name="12.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="12.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/12/30 03:02:56+01:00 kaber@coreworks.de 
#   [PKT_SCHED]: Fix missing unlock in ipt action error path
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/ipt.c
#   2004/12/30 02:57:03+01:00 kaber@coreworks.de +6 -4
#   [PKT_SCHED]: Fix missing unlock in ipt action error path
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/sched/ipt.c b/net/sched/ipt.c
--- a/net/sched/ipt.c	2004-12-30 04:01:46 +01:00
+++ b/net/sched/ipt.c	2004-12-30 04:01:46 +01:00
@@ -248,9 +248,11 @@
 	p->bstats.bytes += skb->len;
 	p->bstats.packets++;
 
-	if (skb_cloned(skb) ) {
-		if (pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
-			return -1;
+	if (skb_cloned(skb)) {
+		if (unlikely(pskb_expand_head(skb, 0, 0, GFP_ATOMIC))) {
+			result = -1;
+			goto out_unlock;
+		}
 	}
 	/* yes, we have to worry about both in and out dev
 	 worry later - danger - this API seems to have changed
@@ -275,9 +277,9 @@
 		result = TC_POLICE_OK;
 		break;
 	}
+out_unlock:
 	spin_unlock(&p->lock);
 	return result;
-
 }
 
 static int

--------------090101090800040307030702--
