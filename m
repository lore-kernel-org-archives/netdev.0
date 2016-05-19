From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH] net/atm: sk_err_soft must be positive
Date: Wed, 18 May 2016 17:42:13 -0700
Message-ID: <1463618533-7098-1-git-send-email-stefanha@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Stefan Hajnoczi <stefanha@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60130 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750736AbcESAmS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 May 2016 20:42:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The sk_err and sk_err_soft fields are positive errno values and
userspace applications rely on this when using getsockopt(SO_ERROR).

ATM code places an -errno into sk_err_soft in sigd_send() and returns it
from svc_addparty()/svc_dropparty().

Although I am not familiar with ATM code I came to this conclusion
because:

1. sigd_send() msg->type cases as_okay and as_error both have:

   sk->sk_err = -msg->reply;

   while the as_addparty and as_dropparty cases have:

   sk->sk_err_soft = msg->reply;

   This is the source of the inconsistency.

2. svc_addparty() returns an -errno and assumes sk_err_soft is also an
   -errno:

       if (flags & O_NONBLOCK) {
           error = -EINPROGRESS;
           goto out;
       }
       ...
       error = xchg(&sk->sk_err_soft, 0);
   out:
       release_sock(sk);
       return error;

   This shows that sk_err_soft is indeed being treated as an -errno.

This patch ensures that sk_err_soft is always a positive errno.

Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
This patch is untested and potentially affects the getsockopt(SO_ERROR) ABI for
a specific case in ATM.  I leave it to the maintainer to decide whether this
inconsistency should be fixed or not.

 net/atm/signaling.c | 2 +-
 net/atm/svc.c       | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/atm/signaling.c b/net/atm/signaling.c
index 4fd6af4..adb6e3d 100644
--- a/net/atm/signaling.c
+++ b/net/atm/signaling.c
@@ -124,7 +124,7 @@ as_indicate_complete:
 		break;
 	case as_addparty:
 	case as_dropparty:
-		sk->sk_err_soft = msg->reply;
+		sk->sk_err_soft = -msg->reply;
 					/* < 0 failure, otherwise ep_ref */
 		clear_bit(ATM_VF_WAITING, &vcc->flags);
 		break;
diff --git a/net/atm/svc.c b/net/atm/svc.c
index 3fa0a9e..878563a 100644
--- a/net/atm/svc.c
+++ b/net/atm/svc.c
@@ -546,7 +546,7 @@ static int svc_addparty(struct socket *sock, struct sockaddr *sockaddr,
 		schedule();
 	}
 	finish_wait(sk_sleep(sk), &wait);
-	error = xchg(&sk->sk_err_soft, 0);
+	error = -xchg(&sk->sk_err_soft, 0);
 out:
 	release_sock(sk);
 	return error;
@@ -573,7 +573,7 @@ static int svc_dropparty(struct socket *sock, int ep_ref)
 		error = -EUNATCH;
 		goto out;
 	}
-	error = xchg(&sk->sk_err_soft, 0);
+	error = -xchg(&sk->sk_err_soft, 0);
 out:
 	release_sock(sk);
 	return error;
-- 
2.5.5
