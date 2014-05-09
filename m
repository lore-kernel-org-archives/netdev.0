From: Xufeng Zhang <xufeng.zhang@windriver.com>
Subject: [RFC][PATCH] af_key: return error when meet errors on sendmsg() syscall
Date: Fri, 9 May 2014 13:47:35 +0800
Message-ID: <1399614455-10551-1-git-send-email-xufeng.zhang@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: <steffen.klassert@secunet.com>, <herbert@gondor.apana.org.au>,
	<davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Current implementation for pfkey_sendmsg() always return success
no matter whether or not error happens during this syscall,
this is incompatible with the general send()/sendmsg() API:
  man send
    RETURN VALUE
      On success, these calls return the number of characters sent.
      On error, -1 is returned, and errno is set appropriately.

One side effect this problem introduces is that we can't determine
when to resend the message when the previous send() fails because
it was interrupted by signals.
We detect such a problem when racoon is sending SADBADD message to
add SAD entry in the kernel, but sometimes kernel is responding with
"Interrupted system call"(-EINTR) error.

Check the send implementation of strongswan, it has below logic:
  pfkey_send_socket()
  {
  	...
  	while (TRUE)
  	{
        	len = send(socket, in, in_len, 0);

  		if (len != in_len)
  		{
  			case EINTR:
  				/* interrupted, try again */
  				continue;
  			...
  		}
  	}
  	...
}
So it makes sense to return errors for send() syscall.      

Signed-off-by: Xufeng Zhang <xufeng.zhang@windriver.com>
---
 net/key/af_key.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/key/af_key.c b/net/key/af_key.c
index f3c8307..9e4bc8c 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -335,7 +335,7 @@ static int pfkey_error(const struct sadb_msg *orig, int err, struct sock *sk)
 
 	pfkey_broadcast(skb, GFP_KERNEL, BROADCAST_ONE, sk, sock_net(sk));
 
-	return 0;
+	return -err;
 }
 
 static const u8 sadb_ext_min_len[] = {
@@ -3644,8 +3644,8 @@ static int pfkey_sendmsg(struct kiocb *kiocb,
 	mutex_unlock(&net->xfrm.xfrm_cfg_mutex);
 
 out:
-	if (err && hdr && pfkey_error(hdr, err, sk) == 0)
-		err = 0;
+	if (err && hdr)
+		err = pfkey_error(hdr, err, sk);
 	kfree_skb(skb);
 
 	return err ? : len;
-- 
1.7.0.2
