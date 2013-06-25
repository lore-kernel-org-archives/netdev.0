From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net-next 5/6] net: sctp: decouple cleaning some socket
 data from endpoint
Date: Tue, 25 Jun 2013 11:32:28 -0400
Message-ID: <51C9B80C.6070905@gmail.com>
References: <1372173221-15244-1-git-send-email-dborkman@redhat.com> <1372173221-15244-6-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f177.google.com ([209.85.216.177]:49853 "EHLO
	mail-qc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751817Ab3FYPce (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jun 2013 11:32:34 -0400
In-Reply-To: <1372173221-15244-6-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/25/2013 11:13 AM, Daniel Borkmann wrote:
> Rather instead of having the endpoint clean the garbage from the
> socket, use a sk_destruct handler sctp_destruct_sock(), that does
> the job for that when there are no more references on the socket.
> At least do this for our crypto transform through crypto_free_hash()
> that is allocated when in listening state. Also, for now, move the
> sctp_put_port() into the sk if body.

This sentence is hard to parse without looking at the patch.  Can
you rephrase.  May be say that we perform sctp_put_port() only when
sk is valid.

> At a later point in time we
> can still determine if there's an option of placing this into
> unhash() or sctp_endpoint_free() without any races. For now, leave
> it in sctp_endpoint_destroy() though.
>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> ---
>   net/sctp/endpointola.c | 18 +++++++++---------
>   net/sctp/socket.c      | 16 +++++++++++++++-
>   2 files changed, 24 insertions(+), 10 deletions(-)
>
> diff --git a/net/sctp/endpointola.c b/net/sctp/endpointola.c
> index a8b2674..8ad7781 100644
> --- a/net/sctp/endpointola.c
> +++ b/net/sctp/endpointola.c
> @@ -247,10 +247,9 @@ void sctp_endpoint_free(struct sctp_endpoint *ep)
>   /* Final destructor for endpoint.  */
>   static void sctp_endpoint_destroy(struct sctp_endpoint *ep)
>   {
> -	SCTP_ASSERT(ep->base.dead, "Endpoint is not dead", return);
> +	struct sock *sk;
>
> -	/* Free up the HMAC transform. */
> -	crypto_free_hash(sctp_sk(ep->base.sk)->hmac);
> +	SCTP_ASSERT(ep->base.dead, "Endpoint is not dead", return);
>
>   	/* Free the digest buffer */
>   	kfree(ep->digest);
> @@ -271,13 +270,14 @@ static void sctp_endpoint_destroy(struct sctp_endpoint *ep)
>
>   	memset(ep->secret_key, 0, sizeof(ep->secret_key));
>
> -	/* Remove and free the port */
> -	if (sctp_sk(ep->base.sk)->bind_hash)
> -		sctp_put_port(ep->base.sk);
> -
>   	/* Give up our hold on the sock. */
> -	if (ep->base.sk)
> -		sock_put(ep->base.sk);
> +	if ((sk = ep->base.sk)) {

Can you either split the above into separate assignment and test (this 
is what checkpatchs.pl recommends) or at least comment that you mean to 
do assign and test in the above statement.

-vlad
> +		/* Remove and free the port */
> +		if (sctp_sk(sk)->bind_hash)
> +			sctp_put_port(sk);
> +
> +		sock_put(sk);
> +	}
>
>   	kfree(ep);
>   	SCTP_DBG_OBJCNT_DEC(ep);
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index 4c47e55..ba9359c 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -93,6 +93,7 @@ static int sctp_wait_for_packet(struct sock * sk, int *err, long *timeo_p);
>   static int sctp_wait_for_connect(struct sctp_association *, long *timeo_p);
>   static int sctp_wait_for_accept(struct sock *sk, long timeo);
>   static void sctp_wait_for_close(struct sock *sk, long timeo);
> +static void sctp_destruct_sock(struct sock *sk);
>   static struct sctp_af *sctp_sockaddr_af(struct sctp_sock *opt,
>   					union sctp_addr *addr, int len);
>   static int sctp_bindx_add(struct sock *, struct sockaddr *, int);
> @@ -3966,6 +3967,8 @@ static int sctp_init_sock(struct sock *sk)
>
>   	sp->hmac = NULL;
>
> +	sk->sk_destruct = sctp_destruct_sock;
> +
>   	SCTP_DBG_OBJCNT_INC(sock);
>
>   	local_bh_disable();
> @@ -4008,6 +4011,17 @@ static void sctp_destroy_sock(struct sock *sk)
>   	local_bh_enable();
>   }
>
> +/* Triggered when there are no references on the socket anymore */
> +static void sctp_destruct_sock(struct sock *sk)
> +{
> +	struct sctp_sock *sp = sctp_sk(sk);
> +
> +	/* Free up the HMAC transform. */
> +	crypto_free_hash(sp->hmac);
> +
> +	inet_sock_destruct(sk);
> +}
> +
>   /* API 4.1.7 shutdown() - TCP Style Syntax
>    *     int shutdown(int socket, int how);
>    *
> @@ -6848,7 +6862,7 @@ void sctp_copy_sock(struct sock *newsk, struct sock *sk,
>   	newsk->sk_reuse = sk->sk_reuse;
>
>   	newsk->sk_shutdown = sk->sk_shutdown;
> -	newsk->sk_destruct = inet_sock_destruct;
> +	newsk->sk_destruct = sctp_destruct_sock;
>   	newsk->sk_family = sk->sk_family;
>   	newsk->sk_protocol = IPPROTO_SCTP;
>   	newsk->sk_backlog_rcv = sk->sk_prot->backlog_rcv;
>
