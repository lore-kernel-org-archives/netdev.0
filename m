From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] af_unix: Only allow recv on connected seqpacket
 sockets.
Date: Sun, 24 Apr 2011 12:05:19 -0700 (PDT)
Message-ID: <20110424.120519.226767465.davem@davemloft.net>
References: <m1zkngse02.fsf@fess.ebiederm.org>
	<BANLkTimrOs2T_bnbSJDgppAAh_MUWt_erg@mail.gmail.com>
	<m1sjt7sw32.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xemul@openvz.org, dan@aloni.org,
	stable@kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44429
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755028Ab1DXTFx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Apr 2011 15:05:53 -0400
In-Reply-To: <m1sjt7sw32.fsf_-_@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Sun, 24 Apr 2011 04:54:57 -0700

> +static int unix_seqpacket_recvmsg(struct kiocb *iocb, struct socket *sock,
> +			      struct msghdr *msg, size_t size,
> +			      int flags)
> +{
> +	struct sock *sk = sock->sk;
> +
> +	if (sk->sk_state != TCP_ESTABLISHED)
> +		return -ENOTCONN;

As for unix_seqpacket_sendmsg(), you need to add a check for sock_error()
or similar here otherwise -ECONNRESET is not reported correctly.

In fact, recvmsg() is even harder than sendmsg() to handle correctly,
because we have to also properly report EOF on seqpacket sockets which
have RCV_SHUTDOWN set.

So a lot more work has to go into this change to make it fix the bug
without also breaking existing semantics.

Anyways, see:

commit 6e14891f4d16f8a9e0bc3a8408f73b3aed93ab0a
Author: James Morris <jmorris@redhat.com>
Date:   Fri Nov 19 07:02:41 2004 -0800

    [AF_UNIX]: Don't lose ECONNRESET in unix_seqpacket_sendmsg()
    
    The fix for SELinux w/SOCK_SEQPACKET had an error,
    noted by Alan Cox.  This fixes it.
    
    Signed-off-by: James Morris <jmorris@redhat.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 16faa9d..8902c4a 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1513,13 +1513,18 @@ out_err:
 static int unix_seqpacket_sendmsg(struct kiocb *kiocb, struct socket *sock,
 				  struct msghdr *msg, size_t len)
 {
+	int err;
 	struct sock *sk = sock->sk;
 	
+	err = sock_error(sk);
+	if (err)
+		return err;
+
 	if (sk->sk_state != TCP_ESTABLISHED)
 		return -ENOTCONN;
 
-	if (msg->msg_name || msg->msg_namelen)
-		return -EINVAL;
+	if (msg->msg_namelen)
+		msg->msg_namelen = 0;
 
 	return unix_dgram_sendmsg(kiocb, sock, msg, len);
 }
