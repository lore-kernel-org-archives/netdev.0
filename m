From: Dave Jones <davej@redhat.com>
Subject: fix broken locking in x25 ioctl error paths
Date: Fri, 28 Jun 2013 11:14:53 -0400
Message-ID: <20130628151453.GA29428@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40045 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750818Ab3F1PPD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Jun 2013 11:15:03 -0400
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r5SFF1Da001763
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 28 Jun 2013 11:15:01 -0400
Received: from gelk.kernelslacker.org (ovpn-113-177.phx2.redhat.com [10.3.113.177])
	by int-mx01.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id r5SFEtaI016527
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 28 Jun 2013 11:15:01 -0400
Received: from gelk.kernelslacker.org (localhost [127.0.0.1])
	by gelk.kernelslacker.org (8.14.7/8.14.5) with ESMTP id r5SFEsnx009766
	for <netdev@vger.kernel.org>; Fri, 28 Jun 2013 11:14:54 -0400
Received: (from davej@localhost)
	by gelk.kernelslacker.org (8.14.7/8.14.7/Submit) id r5SFErPs009703
	for netdev@vger.kernel.org; Fri, 28 Jun 2013 11:14:53 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Two of the x25 ioctl cases have error paths that break out of the function without
unlocking the socket, leading to this warning:


================================================
[ BUG: lock held when returning to user space! ]
3.10.0-rc7+ #36 Not tainted
------------------------------------------------
trinity-child2/31407 is leaving the kernel with locks still held!
1 lock held by trinity-child2/31407:
 #0:  (sk_lock-AF_X25){+.+.+.}, at: [<ffffffffa024b6da>] x25_ioctl+0x8a/0x740 [x25]

Signed-off-by: Dave Jones <davej@redhat.com>

diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index 37ca969..2c1e633 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -1584,10 +1584,11 @@ out_cud_release:
 		rc = -EINVAL;
 		lock_sock(sk);
 		if (sk->sk_state != TCP_CLOSE)
-			break;
+			goto out_callaccpt_release;
 		clear_bit(X25_ACCPT_APPRV_FLAG, &x25->flags);
-		release_sock(sk);
 		rc = 0;
+out_callaccpt_release:
+		release_sock(sk);
 		break;
 	}
 
@@ -1595,14 +1596,15 @@ out_cud_release:
 		rc = -EINVAL;
 		lock_sock(sk);
 		if (sk->sk_state != TCP_ESTABLISHED)
-			break;
+			goto out_sendcallaccpt_release;
 		/* must call accptapprv above */
 		if (test_bit(X25_ACCPT_APPRV_FLAG, &x25->flags))
-			break;
+			goto out_sendcallaccpt_release;
 		x25_write_internal(sk, X25_CALL_ACCEPTED);
 		x25->state = X25_STATE_3;
-		release_sock(sk);
 		rc = 0;
+out_sendcallaccpt_release:
+		release_sock(sk);
 		break;
 	}
 
