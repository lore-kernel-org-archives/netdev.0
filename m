From: chas williams (contractor) <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH][ATM]: better behavior for sendmsg/recvmsg during async closes
Date: Thu, 15 Jan 2004 22:03:29 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401160303.i0G33RRr017352@ginger.cmf.nrl.navy.mil>
References: <20040115001921.5d3edcbc.davem@redhat.com>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-reply-to: Your message of "Thu, 15 Jan 2004 00:19:21 PST."
             <20040115001921.5d3edcbc.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In message <20040115001921.5d3edcbc.davem@redhat.com>,"David S. Miller" writes:
>I applied the 2.6.x version, the 2.4.x version did not apply cleanly at all.
>Please regenerate the 2.4.x patch for me, thanks Chas.

looks like my local 2.4 tree has diverged too much.  here is something
that is more likely to be useful when patching 2.4:

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1383  -> 1.1384 
#	    net/atm/common.c	1.27    -> 1.28   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 04/01/15	chas@relax.cmf.nrl.navy.mil	1.1384
# [ATM]: better behavior for sendmsg/recvmsg during async closes
# --------------------------------------------
#
diff -Nru a/net/atm/common.c b/net/atm/common.c
--- a/net/atm/common.c	Thu Jan 15 12:28:21 2004
+++ b/net/atm/common.c	Thu Jan 15 12:28:21 2004
@@ -510,9 +510,8 @@
  		return -EOPNOTSUPP;
   	vcc = ATM_SD(sock);
  	if (test_bit(ATM_VF_RELEASED,&vcc->flags) ||
- 	    test_bit(ATM_VF_CLOSE,&vcc->flags))
- 		return vcc->reply;
- 	if (!test_bit(ATM_VF_READY, &vcc->flags))
+ 	    test_bit(ATM_VF_CLOSE, &vcc->flags) ||
+ 	    !test_bit(ATM_VF_READY, &vcc->flags))
  		return 0;
  
  	skb = skb_recv_datagram(sk, flags, flags & MSG_DONTWAIT, &error);
@@ -568,12 +567,10 @@
   	size = m->msg_iov->iov_len;
   	vcc = ATM_SD(sock);
  	if (test_bit(ATM_VF_RELEASED, &vcc->flags) ||
- 	    test_bit(ATM_VF_CLOSE, &vcc->flags)) {
- 		error = vcc->reply;
- 		goto out;
- 	}
- 	if (!test_bit(ATM_VF_READY, &vcc->flags)) {
+ 	    test_bit(ATM_VF_CLOSE, &vcc->flags) ||
+ 	    !test_bit(ATM_VF_READY, &vcc->flags)) {
  		error = -EPIPE;
+ 		send_sig(SIGPIPE, current, 0);
  		goto out;
  	}
  	if (!size) {
@@ -601,12 +598,10 @@
 			break;
 		}
 		if (test_bit(ATM_VF_RELEASED,&vcc->flags) ||
-		    test_bit(ATM_VF_CLOSE,&vcc->flags)) {
-			error = vcc->reply;
-			break;
-		}
-		if (!test_bit(ATM_VF_READY,&vcc->flags)) {
+		    test_bit(ATM_VF_CLOSE, &vcc->flags) ||
+		    !test_bit(ATM_VF_READY, &vcc->flags)) {
 			error = -EPIPE;
+			send_sig(SIGPIPE, current, 0);
 			break;
 		}
 	}
