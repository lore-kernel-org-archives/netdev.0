From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH][5 of 7][ATM]: avoid race between svc_disconnect and sigd exiting
Date: Tue, 18 Jan 2005 14:09:20 -0500
Message-ID: <200501181909.j0IJ9KO8022381@ginger.cmf.nrl.navy.mil>
Cc: davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.6.

thanks!

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/14 08:47:48-05:00 chas@relax.cmf.nrl.navy.mil 
#   [ATM]: avoid race between svc_disconnect and sigd exiting
#
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
# net/atm/svc.c
#   2005/01/14 08:47:31-05:00 chas@relax.cmf.nrl.navy.mil +4 -7
#   [ATM]: avoid race between svc_disconnect and sigd exiting
#
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
diff -Nru a/net/atm/svc.c b/net/atm/svc.c
--- a/net/atm/svc.c	2005-01-14 08:49:39 -05:00
+++ b/net/atm/svc.c	2005-01-14 08:49:39 -05:00
@@ -71,9 +71,7 @@
 		sigd_enq2(NULL,as_reject,vcc,NULL,NULL,&vcc->qos,0);
 		dev_kfree_skb(skb);
 	}
-	clear_bit(ATM_VF_REGIS,&vcc->flags);
-	clear_bit(ATM_VF_RELEASED,&vcc->flags);
-	clear_bit(ATM_VF_CLOSE,&vcc->flags);
+	clear_bit(ATM_VF_REGIS, &vcc->flags);
 	/* ... may retry later */
 }
 
@@ -90,10 +88,8 @@
 		/* VCC pointer is used as a reference, so we must not free it
 		   (thereby subjecting it to re-use) before all pending connections
 	           are closed */
-		sock_hold(sk);
-		vcc_release(sock);
 		svc_disconnect(vcc);
-		sock_put(sk);
+		vcc_release(sock);
 	}
 	return 0;
 }
@@ -286,7 +282,8 @@
  */
 	if (!(error = vcc_connect(sock, vcc->itf, vcc->vpi, vcc->vci)))
 		sock->state = SS_CONNECTED;
-	else (void) svc_disconnect(vcc);
+	else
+		(void) svc_disconnect(vcc);
 out:
 	release_sock(sk);
 	return error;
