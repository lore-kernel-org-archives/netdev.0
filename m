From: chas williams (contractor) <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM]: better behavior for sendmsg/recvmsg during async closes
Date: Wed, 14 Jan 2004 23:16:09 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401150416.i0F4G8Rr028870@ginger.cmf.nrl.navy.mil>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

sendmsg() should probably just return -EPIPE (and send SIGPIPE) instead
of returning the error from sigd during an asynchronus close. often 
the error code is 0 when the other side cleanly terminates the svc 
since its likely the other side closed the svc without a 'hard' error.

recvmsg() shouldnt return EPIPE (this isnt a 'valid' return code for
recvmsg).  returning 0 (end of file) seems the best idea when the remote
side has closed first.

please apply to 2.4

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1168  -> 1.1169 
#	    net/atm/common.c	1.36    -> 1.37   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 04/01/14	chas@relax.cmf.nrl.navy.mil	1.1169
# [ATM]: better behavior for sendmsg/recvmsg during async closes
# --------------------------------------------
#
diff -Nru a/net/atm/common.c b/net/atm/common.c
--- a/net/atm/common.c	Wed Jan 14 22:13:22 2004
+++ b/net/atm/common.c	Wed Jan 14 22:13:22 2004
@@ -629,11 +629,10 @@
  	if (flags & ~MSG_DONTWAIT)		/* only handle MSG_DONTWAIT */
  		return -EOPNOTSUPP;
   	vcc = ATM_SD(sock);
- 	if (test_bit(ATM_VF_RELEASED,&vcc->flags) ||
- 	    test_bit(ATM_VF_CLOSE,&vcc->flags))
- 		return -sk->err;
- 	if (!test_bit(ATM_VF_READY, &vcc->flags))
- 		return 0;
+ 	if (test_bit(ATM_VF_RELEASED, &vcc->flags) ||
+ 	    test_bit(ATM_VF_CLOSE, &vcc->flags) ||
+ 	    !test_bit(ATM_VF_READY, &vcc->flags))
+ 		return 0;			/* end of file */
  
  	skb = skb_recv_datagram(sk, flags, flags & MSG_DONTWAIT, &error);
  	if (!skb)
@@ -688,12 +687,10 @@
   	size = m->msg_iov->iov_len;
   	vcc = ATM_SD(sock);
  	if (test_bit(ATM_VF_RELEASED, &vcc->flags) ||
- 	    test_bit(ATM_VF_CLOSE, &vcc->flags)) {
- 		error = -sk->err;
- 		goto out;
- 	}
- 	if (!test_bit(ATM_VF_READY, &vcc->flags)) {
- 		error = -EPIPE;
+ 	    test_bit(ATM_VF_CLOSE, &vcc->flags) ||
+ 	    !test_bit(ATM_VF_READY, &vcc->flags)) {
+		error = -EPIPE;
+		send_sig(SIGPIPE, current, 0);
  		goto out;
  	}
  	if (!size) {
@@ -721,12 +718,10 @@
 			break;
 		}
 		if (test_bit(ATM_VF_RELEASED,&vcc->flags) ||
-		    test_bit(ATM_VF_CLOSE,&vcc->flags)) {
-			error = -sk->err;
-			break;
-		}
-		if (!test_bit(ATM_VF_READY,&vcc->flags)) {
+		    test_bit(ATM_VF_CLOSE,&vcc->flags) ||
+		    !test_bit(ATM_VF_READY,&vcc->flags)) {
 			error = -EPIPE;
+			send_sig(SIGPIPE, current, 0);
 			break;
 		}
 	}
