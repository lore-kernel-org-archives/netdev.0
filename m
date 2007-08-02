From: Simon Arlott <simon@fire.lp0.eu>
Subject: Re: strange tcp behavior
Date: Thu, 02 Aug 2007 19:58:03 +0100
Message-ID: <46B2293B.3020406@simon.arlott.org.uk>
References: <56697.212.93.96.73.1186035546.squirrel@mail.screen.lv> <20070802095550.GA27226@2ka.mipt.ru> <20070802101655.GA14749@2ka.mipt.ru> <36758.simon.1186054739@5ec7c279.invalid> <46860.212.93.96.73.1186055105.squirrel@mail.screen.lv> <48738.simon.1186056932@5ec7c279.invalid> <46B21148.2090004@simon.arlott.org.uk> <20070802180842.GA6864@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: john@screen.lv, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxima.lp0.eu ([85.158.45.36]:54859 "EHLO proxima.lp0.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755338AbXHBS63 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Aug 2007 14:58:29 -0400
In-Reply-To: <20070802180842.GA6864@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/08/07 19:08, Evgeniy Polyakov wrote:
> On Thu, Aug 02, 2007 at 06:15:52PM +0100, Simon Arlott (simon@fire.lp0.eu) wrote:
>> 17:33:45.351273 IP 192.168.7.4.50000 > 192.168.7.8.2500: R 1385353596:1385353596(0) win 1500
>> 17:33:45.360878 IP 192.168.7.8.48186 > 192.168.7.4.50000: R 1388203103:1388203103(0) ack 1385353596 win 14360
> 
> Problem is not in tcp_send_active_reset(), when socket is being released
> it is already damaged.
> Problem is that inet_autobind() function is called for socket, which is
> already dead, but not yet completely - it smells bad (since it has its
> port freed), but stil alive (accessible via send()), so for its last
> word inet_sendmsg() tries to bind it again, and only after that time it
> will be eventually closed and freed completely.
> 
> So, following patch fixes problem for me.
> Another solution might not to release port until socket is being
> released, but that can lead to performance degradation.
> Correct me if sk_err can be reset.

19:24:32.897071 IP 192.168.7.4.50000 > 192.168.7.8.2500: S 705362199:705362199(0) win 1500
19:24:32.897211 IP 192.168.7.8.2500 > 192.168.7.4.50000: S 4159455228:4159455228(0) ack 705362200 win 14360 <mss 7180>
19:24:32.920784 IP 192.168.7.4.50000 > 192.168.7.8.2500: . ack 1 win 1500
19:24:32.921732 IP 192.168.7.4.50000 > 192.168.7.8.2500: P 1:17(16) ack 1 win 1500
19:24:32.921795 IP 192.168.7.8.2500 > 192.168.7.4.50000: . ack 17 win 14360
19:24:32.922881 IP 192.168.7.4.50000 > 192.168.7.8.2500: R 705362216:705362216(0) win 1500
19:24:34.927717 IP 192.168.7.8.2500 > 192.168.7.4.50000: R 1:1(0) ack 17 win 14360

According to RFC 793, the RST from .4 means that the connection 
is CLOSED.

  Reset Processing

  The receiver of a RST first validates it, then changes state.  If the
  receiver was in the LISTEN state, it ignores it.  If the receiver was
  in SYN-RECEIVED state and had previously been in the LISTEN state,
  then the receiver returns to the LISTEN state, otherwise the receiver
  aborts the connection and goes to the CLOSED state.  If the receiver
  was in any other state, it aborts the connection and advises the user
  and goes to the CLOSED state.


So when the call to close() is made without reading:

      Abort

        Format:  ABORT (local connection name)

        This command causes all pending SENDs and RECEIVES to be
        aborted, the TCB to be removed, and a special RESET message to
        be sent to the TCP on the other side of the connection.

Isn't there no other side of the connection to send the RESET too?


> Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
> 
> diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
> index 06c08e5..6790b23 100644
> --- a/net/ipv4/af_inet.c
> +++ b/net/ipv4/af_inet.c
> @@ -168,8 +169,14 @@ void inet_sock_destruct(struct sock *sk)
>  static int inet_autobind(struct sock *sk)
>  {
>  	struct inet_sock *inet;
> +
>  	/* We may need to bind the socket. */
>  	lock_sock(sk);
> +	if (sk->sk_err) {
> +		release_sock(sk);
> +		return sk->sk_err;
> +	}
> +
>  	inet = inet_sk(sk);
>  	if (!inet->num) {
>  		if (sk->sk_prot->get_port(sk, 0)) {
> @@ -686,8 +703,11 @@ int inet_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
>  	struct sock *sk = sock->sk;
>  
>  	/* We may need to bind the socket. */
> -	if (!inet_sk(sk)->num && inet_autobind(sk))
> -		return -EAGAIN;
> +	if (!inet_sk(sk)->num) {
> +		int err = inet_autobind(sk);
> +		if (err)
> +			return err;
> +	}
>  
>  	return sk->sk_prot->sendmsg(iocb, sk, msg, size);
>  }
> @@ -698,8 +718,11 @@ static ssize_t inet_sendpage(struct socket *sock, struct page *page, int offset,
>  	struct sock *sk = sock->sk;
>  
>  	/* We may need to bind the socket. */
> -	if (!inet_sk(sk)->num && inet_autobind(sk))
> -		return -EAGAIN;
> +	if (!inet_sk(sk)->num) {
> +		int err = inet_autobind(sk);
> +		if (err)
> +			return err;
> +	}
>  
>  	if (sk->sk_prot->sendpage)
>  		return sk->sk_prot->sendpage(sk, page, offset, size, flags);
> 


-- 
Simon Arlott


