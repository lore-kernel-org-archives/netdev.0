From: "chas williams (contractor)" <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM]: don't leak skb on as_indicate failure; don't wakeup twice on as_close
Date: Wed, 27 Oct 2004 10:32:54 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200410271432.i9REWql8004243@ginger.cmf.nrl.navy.mil>
Cc: davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.6.

thanks!

Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/10/27 09:58:17-04:00 chas@relax.cmf.nrl.navy.mil 
#   [ATM]: don't leak skb on as_indicate failure; don't wakeup twice on as_close
# 
# net/atm/signaling.c
#   2004/10/27 09:58:00-04:00 chas@relax.cmf.nrl.navy.mil +3 -1
#   [ATM]: don't leak skb on as_indicate failure; don't wakeup twice on as_close
# 
diff -Nru a/net/atm/signaling.c b/net/atm/signaling.c
--- a/net/atm/signaling.c	2004-10-27 10:30:12 -04:00
+++ b/net/atm/signaling.c	2004-10-27 10:30:12 -04:00
@@ -136,6 +136,7 @@
 			if (vcc->sk->sk_ack_backlog ==
 			    vcc->sk->sk_max_ack_backlog) {
 				sigd_enq(NULL,as_reject,vcc,NULL,NULL);
+				dev_kfree_skb(skb);
 				goto as_indicate_complete;
 			}
 			vcc->sk->sk_ack_backlog++;
@@ -148,7 +149,7 @@
 		case as_close:
 			set_bit(ATM_VF_RELEASED,&vcc->flags);
 			vcc_release_async(vcc, msg->reply);
-			break;
+			goto out;
 		case as_modify:
 			modify_qos(vcc,msg);
 			break;
@@ -163,6 +164,7 @@
 			return -EINVAL;
 	}
 	vcc->sk->sk_state_change(vcc->sk);
+out:
 	dev_kfree_skb(skb);
 	return 0;
 }
