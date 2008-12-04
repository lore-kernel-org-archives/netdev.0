From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH] ATM: CVE-2008-5079: multiple listen()s on same socket corrupts the vcc table
Date: Thu, 04 Dec 2008 12:25:05 -0500
Message-ID: <200812041725.mB4HP5rS031103@cmf.nrl.navy.mil>
Cc: davem@davemloft.net, Eugene Teo <eteo@redhat.com>,
	stable@kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:53594 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758200AbYLDRlK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2008 12:41:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

please apply to net-next-2.6 and consider for net-2.6 if possible.

thanks!

commit 8c5629cfd33e2e8275aae98bbf62a98bf59bc7e8
Author: Chas Williams - CONTRACTOR <chas@relax.cmf.nrl.navy.mil>
Date:   Thu Dec 4 12:14:42 2008 -0500

    ATM: CVE-2008-5079: duplicate listen() on socket corrupts the vcc table
    
    As reported by Hugo Dias that it is possible to cause a local denial
    of service attack by calling the svc_listen function twice on the same
    socket and reading /proc/net/atm/*vc
    
    Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>

diff --git a/net/atm/svc.c b/net/atm/svc.c
index de1e4f2..8fb54dc 100644
--- a/net/atm/svc.c
+++ b/net/atm/svc.c
@@ -293,7 +293,10 @@ static int svc_listen(struct socket *sock,int backlog)
 		error = -EINVAL;
 		goto out;
 	}
-	vcc_insert_socket(sk);
+	if (test_bit(ATM_VF_LISTEN, &vcc->flags)) {
+		error = -EADDRINUSE;
+		goto out;
+        }
 	set_bit(ATM_VF_WAITING, &vcc->flags);
 	prepare_to_wait(sk->sk_sleep, &wait, TASK_UNINTERRUPTIBLE);
 	sigd_enq(vcc,as_listen,NULL,NULL,&vcc->local);
@@ -307,6 +310,7 @@ static int svc_listen(struct socket *sock,int backlog)
 		goto out;
 	}
 	set_bit(ATM_VF_LISTEN,&vcc->flags);
+	vcc_insert_socket(sk);
 	sk->sk_max_ack_backlog = backlog > 0 ? backlog : ATM_BACKLOG_DEFAULT;
 	error = -sk->sk_err;
 out:
