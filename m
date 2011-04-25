From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] af_unix: Only allow recv on connected seqpacket sockets.
Date: Mon, 25 Apr 2011 07:26:27 -0700
Message-ID: <m1tydmo19o.fsf@fess.ebiederm.org>
References: <m1zkngse02.fsf@fess.ebiederm.org>
	<BANLkTimrOs2T_bnbSJDgppAAh_MUWt_erg@mail.gmail.com>
	<m1sjt7sw32.fsf_-_@fess.ebiederm.org>
	<20110424.120519.226767465.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, xemul@openvz.org, dan@aloni.org,
	stable@kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:58599 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758152Ab1DYO0f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2011 10:26:35 -0400
In-Reply-To: <20110424.120519.226767465.davem@davemloft.net> (David Miller's
	message of "Sun, 24 Apr 2011 12:05:19 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Sun, 24 Apr 2011 04:54:57 -0700
>
>> +static int unix_seqpacket_recvmsg(struct kiocb *iocb, struct socket *sock,
>> +			      struct msghdr *msg, size_t size,
>> +			      int flags)
>> +{
>> +	struct sock *sk = sock->sk;
>> +
>> +	if (sk->sk_state != TCP_ESTABLISHED)
>> +		return -ENOTCONN;
>
> As for unix_seqpacket_sendmsg(), you need to add a check for sock_error()
> or similar here otherwise -ECONNRESET is not reported correctly.
>
> In fact, recvmsg() is even harder than sendmsg() to handle correctly,
> because we have to also properly report EOF on seqpacket sockets which
> have RCV_SHUTDOWN set.
>
> So a lot more work has to go into this change to make it fix the bug
> without also breaking existing semantics.

Really?

When I read through the code I am failing to see the issues you are
seeing.

When the other socket in an established connection calls unix_shutdown
or unix_release_sock.  sk->sk_shutdown is changed, but sk_state is
left at TCP_ESTABLISHED.  Therefore we do not need a special
case in unix_seqpacket_recvmsg to handle the RCV_SHUTDOWN case
because in any case where that applies we will be in TCP_ESTABLISHED
and we will simply call unix_dgram_recvmsg.

As for ECONNRESET when I look a look at the code it appears to be
another variant of the other side calling shutdown or close.   So if
it applies we should remain in TCP_ESTABLISHED, and
unix_seqpacket_recvmsg should not need to do anything.

So looking at this the only times I can see that sk_state would
not be TCP_ESTABLISHED in a unix domain seqpacket socket are.
- On a listening socket, where calling recvmsg is what this
  patch is meant to address.
- Before we call connect or listen.
  Which appears to be equally broken today.  The only errors
  I can see happening in the case we are not connected today
  are blocking forever or returning -EINTR if we timeout.

Adding sock_error() handling into the new unix_seqpacket_recvmsg makes a
fair amount of sense but adding a new call to sock_error in that path
seems marginally more likely to change error codes and break existing
apps.  We already have a few other unconditional error codes before
we check sk_err in unix_dgram_recvmsg. 


> Anyways, see:
>
> commit 6e14891f4d16f8a9e0bc3a8408f73b3aed93ab0a
> Author: James Morris <jmorris@redhat.com>
> Date:   Fri Nov 19 07:02:41 2004 -0800
>
>     [AF_UNIX]: Don't lose ECONNRESET in unix_seqpacket_sendmsg()
>     
>     The fix for SELinux w/SOCK_SEQPACKET had an error,
>     noted by Alan Cox.  This fixes it.
>     
>     Signed-off-by: James Morris <jmorris@redhat.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>

Looking into it.  That patch appears to have been unnecessary.
We never transition out of the state TCP_ESTABLISHED once we get
there, and we can never get ECONNRESET unless we are connected.

Arguably we could reduce unix_seqpacket_sendmsg to simply 

static int unix_seqpacket_sendmsg(struct kiocb *kiocb, struct socket *sock,
  				  struct msghdr *msg, size_t len)
{
	if (msg->msgnamelen)
        	msg->msgnamelen = 0;
        return unix_dgram_sendmsg(kiocb, sock, msg, len);
}

But I think having the explicit TCP_ESTABLISHED check makes for better
maintainability, of unix_dgram_sendmesg.

So having gone through all of that it looks like my patch needs a
comment saying that once we are in TCP_ESTABLISHED we cannot leave,
and that nothing can happen before we are TCP_ESTABLISHED.

We can use sock_error to check sk_err, as it seems good hygiene
but it also appears pointless.  Especially for recvmsg where ECONNRESET
never applies.

Eric


> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
> index 16faa9d..8902c4a 100644
> --- a/net/unix/af_unix.c
> +++ b/net/unix/af_unix.c
> @@ -1513,13 +1513,18 @@ out_err:
>  static int unix_seqpacket_sendmsg(struct kiocb *kiocb, struct socket *sock,
>  				  struct msghdr *msg, size_t len)
>  {
> +	int err;
>  	struct sock *sk = sock->sk;
>  	
> +	err = sock_error(sk);
> +	if (err)
> +		return err;
> +
>  	if (sk->sk_state != TCP_ESTABLISHED)
>  		return -ENOTCONN;
>  
> -	if (msg->msg_name || msg->msg_namelen)
> -		return -EINVAL;
> +	if (msg->msg_namelen)
> +		msg->msg_namelen = 0;
>  
>  	return unix_dgram_sendmsg(kiocb, sock, msg, len);
>  }
