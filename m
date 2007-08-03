From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: strange tcp behavior
Date: Fri, 3 Aug 2007 12:22:42 +0400
Message-ID: <20070803082242.GA25582@2ka.mipt.ru>
References: <46B21148.2090004@simon.arlott.org.uk> <20070802180842.GA6864@2ka.mipt.ru> <20070802184840.GA8901@2ka.mipt.ru> <20070802.192134.107254907.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: simon@fire.lp0.eu, john@screen.lv, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:39546 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751974AbXHCIX0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Aug 2007 04:23:26 -0400
Content-Disposition: inline
In-Reply-To: <20070802.192134.107254907.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 02, 2007 at 07:21:34PM -0700, David Miller (davem@davemloft.net) wrote:
> > On Thu, Aug 02, 2007 at 10:08:42PM +0400, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> > > So, following patch fixes problem for me.
> > 
> > Or this one. Essentially the same though.
> > 
> > Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
> 
> So, this bug got introduced partly in 2.3.15, which is when
> we SMP threaded the networking stack.
> 
> The error check was present in inet_sendmsg() previously, it
> looked like this:
> 
> int inet_sendmsg(struct socket *sock, struct msghdr *msg, int size,
> 		 struct scm_cookie *scm)
> {
> 	struct sock *sk = sock->sk;
> 
> 	if (sk->shutdown & SEND_SHUTDOWN) {
> 		if (!(msg->msg_flags&MSG_NOSIGNAL))
> 			send_sig(SIGPIPE, current, 1);
> 		return(-EPIPE);
> 	}

This one would caught our problem.

> 	if (sk->prot->sendmsg == NULL) 
> 		return(-EOPNOTSUPP);
> 	if(sk->err)
> 		return sock_error(sk);

And this one too.

> 	/* We may need to bind the socket. */
> 	if (inet_autobind(sk) != 0)
> 		return -EAGAIN;
> 
> 	return sk->prot->sendmsg(sk, msg, size);
> }
> 
> I believe the idea was to move the sk->err check down into
> tcp_sendmsg().
> 
> But this raises a major issue.
> 
> What in the world are we doing allowing stream sockets to autobind?
> That is totally bogus.  Even if we autobind, that won't make a connect
> happen.

For accepted socket it is perfectly valid assumption - we could autobind 
it during the first send. Or may bind it during accept. Its a matter of
taste I think. Autobinding during first sending can end up being a 
protection against DoS in some obscure rare case...

> There is logic down in TCP to handle all of these details properly
> as long as we don't do this bogus autobind stuff.

Yes, TCP sending function will catch this problems.

> do_tcp_sendpages() and tcp_sendmsg() both invoke sk_stream_wait_connect()
> if TCP is in a state where data sending is not possible.  Inside of
> sk_stream_wait_connect() it handles socket errors as first priority,
> then if no socket errors are pending it checks if we are trying to
> connect currently and if not returns -EPIPE.  It is exactly what we
> want under these circumstances.
> 
> So the bug is purely that autobind is attempted for TCP sockets at
> all.
> 
> TCP's sendpage handles this correctly already, it calls directly down
> into tcp_sendpage(), inet_sendpage() is not used at all.
> 
> So the fix is to make tcp_sendmsg() direct as well, that bypasses all
> of this autobind madness.  The error checking and state verification
> in TCP's sendmsg() and sendpage() implementations will do the right
> thing.
> 
> Comments?
>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index c209361..185c7ec 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -281,7 +281,7 @@ extern int			tcp_v4_remember_stamp(struct sock *sk);
>  
>  extern int		    	tcp_v4_tw_remember_stamp(struct inet_timewait_sock *tw);
>  
> -extern int			tcp_sendmsg(struct kiocb *iocb, struct sock *sk,
> +extern int			tcp_sendmsg(struct kiocb *iocb, struct socket *sock,
>  					    struct msghdr *msg, size_t size);

Maybe recvmsg should be changed too for symmetry?

-- 
	Evgeniy Polyakov
