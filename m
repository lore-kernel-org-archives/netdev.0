From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH PKT_SCHED 17/22]: tc actions: remove unnecessary locking for
 refcnt changes
Date: Mon, 10 Jan 2005 20:38:12 +0100
Message-ID: <41E2D9A4.6050004@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060200080706030502010007"
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060200080706030502010007
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

BTW: This part in pkt_act.h looks kind of strange:

tcf_hash_check:
                if (bind) {
                        p->bindcnt++;
                        p->refcnt++;
                }

but tcf_hash_release:
                if (bind) {
                        p->bindcnt--;
                }
                p->refcnt--;

Shouldn't refcnt be incremented unconditionally ?


--------------060200080706030502010007
Content-Type: text/x-patch;
 name="17.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="17.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/10 03:14:38+01:00 kaber@coreworks.de 
#   [PKT_SCHED]: tc actions: remove unnecessary locking for refcnt changes
#   
#   refcnt/bindcnt are only used in user context under the rtnl, no additional
#   locking is necessary. Besides it was only done in some places, so kill it.
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/police.c
#   2005/01/10 03:14:31+01:00 kaber@coreworks.de +0 -2
#   [PKT_SCHED]: tc actions: remove unnecessary locking for refcnt changes
#   
#   refcnt/bindcnt are only used in user context under the rtnl, no additional
#   locking is necessary. Besides it was only done in some places, so kill it.
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# include/net/pkt_act.h
#   2005/01/10 03:14:31+01:00 kaber@coreworks.de +1 -3
#   [PKT_SCHED]: tc actions: remove unnecessary locking for refcnt changes
#   
#   refcnt/bindcnt are only used in user context under the rtnl, no additional
#   locking is necessary. Besides it was only done in some places, so kill it.
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/include/net/pkt_act.h b/include/net/pkt_act.h
--- a/include/net/pkt_act.h	2005-01-10 06:22:58 +01:00
+++ b/include/net/pkt_act.h	2005-01-10 06:22:58 +01:00
@@ -222,13 +222,11 @@
 {
 	struct tcf_st *p = NULL;
 	if (index && (p = tcf_hash_lookup(index)) != NULL) {
-		spin_lock(&p->lock);
 		if (bind) {
 			p->bindcnt++;
 			p->refcnt++;
 		}
-		spin_unlock(&p->lock);
-		a->priv = (void *) p;
+		a->priv = p;
 	}
 	return p;
 }
diff -Nru a/net/sched/police.c b/net/sched/police.c
--- a/net/sched/police.c	2005-01-10 06:22:58 +01:00
+++ b/net/sched/police.c	2005-01-10 06:22:58 +01:00
@@ -189,12 +189,10 @@
 
 	if (parm->index && (p = tcf_police_lookup(parm->index)) != NULL) {
 		a->priv = p;
-		spin_lock(&p->lock);
 		if (bind) {
 			p->bindcnt += 1;
 			p->refcnt += 1;
 		}
-		spin_unlock(&p->lock);
 		if (ovr)
 			goto override;
 		return ret;

--------------060200080706030502010007--
