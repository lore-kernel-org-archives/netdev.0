From: chas williams (contractor) <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM]: better behavior for sendmsg/recvmsg during async closes
Date: Wed, 14 Jan 2004 23:16:28 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401150416.i0F4GRRr028875@ginger.cmf.nrl.navy.mil>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

2.6 version of the same 2.4 patch

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1513  -> 1.1514 
#	    net/atm/common.c	1.61    -> 1.62   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 04/01/14	chas@relax.cmf.nrl.navy.mil	1.1514
# [ATM]: better behavior for sendmsg/recvmsg during async closes
# --------------------------------------------
#
diff -Nru a/net/atm/common.c b/net/atm/common.c
--- a/net/atm/common.c	Wed Jan 14 23:06:24 2004
+++ b/net/atm/common.c	Wed Jan 14 23:06:24 2004
@@ -476,9 +476,8 @@
 		return -EOPNOTSUPP;
 	vcc = ATM_SD(sock);
 	if (test_bit(ATM_VF_RELEASED,&vcc->flags) ||
-	    test_bit(ATM_VF_CLOSE,&vcc->flags))
-		return -sk->sk_err;
-	if (!test_bit(ATM_VF_READY, &vcc->flags))
+	    test_bit(ATM_VF_CLOSE,&vcc->flags) ||
+	    !test_bit(ATM_VF_READY, &vcc->flags))
 		return 0;
 
 	skb = skb_recv_datagram(sk, flags, flags & MSG_DONTWAIT, &error);
@@ -530,12 +529,10 @@
 	size = m->msg_iov->iov_len;
 	vcc = ATM_SD(sock);
 	if (test_bit(ATM_VF_RELEASED, &vcc->flags) ||
-	    test_bit(ATM_VF_CLOSE, &vcc->flags)) {
-		error = -sk->sk_err;
-		goto out;
-	}
-	if (!test_bit(ATM_VF_READY, &vcc->flags)) {
+	    test_bit(ATM_VF_CLOSE, &vcc->flags) ||
+	    !test_bit(ATM_VF_READY, &vcc->flags)) {
 		error = -EPIPE;
+		send_sig(SIGPIPE, current, 0);
 		goto out;
 	}
 	if (!size) {
@@ -561,12 +558,10 @@
 			break;
 		}
 		if (test_bit(ATM_VF_RELEASED,&vcc->flags) ||
-		    test_bit(ATM_VF_CLOSE,&vcc->flags)) {
-			error = -sk->sk_err;
-			break;
-		}
-		if (!test_bit(ATM_VF_READY,&vcc->flags)) {
+		    test_bit(ATM_VF_CLOSE,&vcc->flags) ||
+		    !test_bit(ATM_VF_READY,&vcc->flags)) {
 			error = -EPIPE;
+			send_sig(SIGPIPE, current, 0);
 			break;
 		}
 		prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
