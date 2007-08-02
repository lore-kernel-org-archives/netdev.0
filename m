From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: strange tcp behavior
Date: Thu, 2 Aug 2007 22:48:42 +0400
Message-ID: <20070802184840.GA8901@2ka.mipt.ru>
References: <56697.212.93.96.73.1186035546.squirrel@mail.screen.lv> <20070802095550.GA27226@2ka.mipt.ru> <20070802101655.GA14749@2ka.mipt.ru> <36758.simon.1186054739@5ec7c279.invalid> <46860.212.93.96.73.1186055105.squirrel@mail.screen.lv> <48738.simon.1186056932@5ec7c279.invalid> <46B21148.2090004@simon.arlott.org.uk> <20070802180842.GA6864@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: john@screen.lv, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Simon Arlott <simon@fire.lp0.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:40295 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757707AbXHBSts (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Aug 2007 14:49:48 -0400
Content-Disposition: inline
In-Reply-To: <20070802180842.GA6864@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 02, 2007 at 10:08:42PM +0400, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> So, following patch fixes problem for me.

Or this one. Essentially the same though.

Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 06c08e5..7c47ef5 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -168,8 +168,14 @@ void inet_sock_destruct(struct sock *sk)
 static int inet_autobind(struct sock *sk)
 {
 	struct inet_sock *inet;
+
 	/* We may need to bind the socket. */
 	lock_sock(sk);
+	if (sk->sk_err || (sk->sk_state == TCP_CLOSE)) {
+		release_sock(sk);
+		return sk->sk_err;
+	}
+
 	inet = inet_sk(sk);
 	if (!inet->num) {
 		if (sk->sk_prot->get_port(sk, 0)) {
@@ -686,8 +692,11 @@ int inet_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 	struct sock *sk = sock->sk;
 
 	/* We may need to bind the socket. */
-	if (!inet_sk(sk)->num && inet_autobind(sk))
-		return -EAGAIN;
+	if (!inet_sk(sk)->num) {
+		int err = inet_autobind(sk);
+		if (err)
+			return err;
+	}
 
 	return sk->sk_prot->sendmsg(iocb, sk, msg, size);
 }
@@ -698,8 +707,11 @@ static ssize_t inet_sendpage(struct socket *sock, struct page *page, int offset,
 	struct sock *sk = sock->sk;
 
 	/* We may need to bind the socket. */
-	if (!inet_sk(sk)->num && inet_autobind(sk))
-		return -EAGAIN;
+	if (!inet_sk(sk)->num) {
+		int err = inet_autobind(sk);
+		if (err)
+			return err;
+	}
 
 	if (sk->sk_prot->sendpage)
 		return sk->sk_prot->sendpage(sk, page, offset, size, flags);

-- 
	Evgeniy Polyakov
