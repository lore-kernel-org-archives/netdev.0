From: "chas williams (contractor)" <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM]: use RCV_SHUTDOWN to exit skb_recv_datagram()
Date: Mon, 18 Oct 2004 16:56:22 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200410182056.i9IKuL2s022173@ginger.cmf.nrl.navy.mil>
Reply-To: chas3@users.sourceforge.net
Cc: davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

this patch makes the svc socket protocol act a little more like
a connection oriented protocol.  please apply to 2.6.

thanks!

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/10/06 17:12:52-04:00 chas@relax.cmf.nrl.navy.mil 
#   [ATM]: use RCV_SHUTDOWN to exit skb_recv_datagram()
# 
# net/atm/signaling.c
#   2004/10/06 17:12:36-04:00 chas@relax.cmf.nrl.navy.mil +2 -6
#   [ATM]: use RCV_SHUTDOWN to exit skb_recv_datagram()
# 
# net/atm/common.c
#   2004/10/06 17:12:36-04:00 chas@relax.cmf.nrl.navy.mil +2 -0
#   [ATM]: use RCV_SHUTDOWN to exit skb_recv_datagram()
# 
diff -Nru a/net/atm/common.c b/net/atm/common.c
--- a/net/atm/common.c	2004-10-18 16:13:32 -04:00
+++ b/net/atm/common.c	2004-10-18 16:13:32 -04:00
@@ -178,6 +178,7 @@
 	struct atm_vcc *vcc = atm_sk(sk);
 	struct sk_buff *skb;
 
+	set_bit(ATM_VF_CLOSE, &vcc->flags);
 	clear_bit(ATM_VF_READY, &vcc->flags);
 	if (vcc->dev) {
 		if (vcc->dev->ops->close)
@@ -216,6 +217,7 @@
 void vcc_release_async(struct atm_vcc *vcc, int reply)
 {
 	set_bit(ATM_VF_CLOSE, &vcc->flags);
+	vcc->sk->sk_shutdown |= RCV_SHUTDOWN;
 	vcc->sk->sk_err = -reply;
 	clear_bit(ATM_VF_WAITING, &vcc->flags);
 	vcc->sk->sk_state_change(vcc->sk);
diff -Nru a/net/atm/signaling.c b/net/atm/signaling.c
--- a/net/atm/signaling.c	2004-10-18 16:13:32 -04:00
+++ b/net/atm/signaling.c	2004-10-18 16:13:32 -04:00
@@ -147,9 +147,7 @@
 			return 0;
 		case as_close:
 			set_bit(ATM_VF_RELEASED,&vcc->flags);
-			clear_bit(ATM_VF_READY,&vcc->flags);
-			vcc->sk->sk_err = -msg->reply;
-			clear_bit(ATM_VF_WAITING, &vcc->flags);
+			vcc_release_async(vcc, msg->reply);
 			break;
 		case as_modify:
 			modify_qos(vcc,msg);
@@ -205,9 +203,7 @@
 	if (vcc->sk->sk_family == PF_ATMSVC &&
 	    !test_bit(ATM_VF_META,&vcc->flags)) {
 		set_bit(ATM_VF_RELEASED,&vcc->flags);
-		vcc->sk->sk_err = EUNATCH;
-		clear_bit(ATM_VF_WAITING, &vcc->flags);
-		vcc->sk->sk_state_change(vcc->sk);
+		vcc_release_async(vcc, -EUNATCH);
 	}
 }
 
