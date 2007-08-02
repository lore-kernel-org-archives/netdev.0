From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: strange tcp behavior
Date: Thu, 2 Aug 2007 22:08:42 +0400
Message-ID: <20070802180842.GA6864@2ka.mipt.ru>
References: <56697.212.93.96.73.1186035546.squirrel@mail.screen.lv> <20070802095550.GA27226@2ka.mipt.ru> <20070802101655.GA14749@2ka.mipt.ru> <36758.simon.1186054739@5ec7c279.invalid> <46860.212.93.96.73.1186055105.squirrel@mail.screen.lv> <48738.simon.1186056932@5ec7c279.invalid> <46B21148.2090004@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: john@screen.lv, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Simon Arlott <simon@fire.lp0.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:44834 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753255AbXHBSJn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Aug 2007 14:09:43 -0400
Content-Disposition: inline
In-Reply-To: <46B21148.2090004@simon.arlott.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 02, 2007 at 06:15:52PM +0100, Simon Arlott (simon@fire.lp0.eu) wrote:
> 17:33:45.351273 IP 192.168.7.4.50000 > 192.168.7.8.2500: R 1385353596:1385353596(0) win 1500
> 17:33:45.360878 IP 192.168.7.8.48186 > 192.168.7.4.50000: R 1388203103:1388203103(0) ack 1385353596 win 14360
> 
> Seems to be losing the source port information when it decides to send 
> that final RST|ACK. It's going through the "TCPAbortOnClose" path:
> 
> tcp_close:
> 	-> tcp_set_state(sk, TCP_CLOSE)
> 		-> inet_put_port(&tcp_hashinfo, sk)
> 		Perhaps it's losing the port information here?
> 	-> tcp_send_active_reset(sk, GFP_KERNEL)
> 
> "TCP_CLOSE       socket is finished"
> Should these two calls be the other way round?
> 
> 
> Also, I don't think it should be sending a RST after the other side has 
> sent one - the connection no longer exists so there is nothing on the 
> other side to reset.

Problem is not in tcp_send_active_reset(), when socket is being released
it is already damaged.
Problem is that inet_autobind() function is called for socket, which is
already dead, but not yet completely - it smells bad (since it has its
port freed), but stil alive (accessible via send()), so for its last
word inet_sendmsg() tries to bind it again, and only after that time it
will be eventually closed and freed completely.

So, following patch fixes problem for me.
Another solution might not to release port until socket is being
released, but that can lead to performance degradation.
Correct me if sk_err can be reset.

Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 06c08e5..6790b23 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -168,8 +169,14 @@ void inet_sock_destruct(struct sock *sk)
 static int inet_autobind(struct sock *sk)
 {
 	struct inet_sock *inet;
+
 	/* We may need to bind the socket. */
 	lock_sock(sk);
+	if (sk->sk_err) {
+		release_sock(sk);
+		return sk->sk_err;
+	}
+
 	inet = inet_sk(sk);
 	if (!inet->num) {
 		if (sk->sk_prot->get_port(sk, 0)) {
@@ -686,8 +703,11 @@ int inet_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
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
@@ -698,8 +718,11 @@ static ssize_t inet_sendpage(struct socket *sock, struct page *page, int offset,
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
