From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net-next 4/5] net: sctp: decouple cleaning socket data
 from endpoint
Date: Thu, 20 Jun 2013 10:35:38 -0400
Message-ID: <51C3133A.4000707@gmail.com>
References: <1371545720-22950-1-git-send-email-dborkman@redhat.com> <1371545720-22950-5-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f179.google.com ([209.85.216.179]:48267 "EHLO
	mail-qc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965258Ab3FTOfm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jun 2013 10:35:42 -0400
In-Reply-To: <1371545720-22950-5-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/18/2013 04:55 AM, Daniel Borkmann wrote:
> Rather instead of having the endpoint clean the garbage for the
> socket, use a sk_destruct handler sctp_destruct_sock(), that does
> the job for that when there are no more references on the socket.
>

With this patch it is possible to run sctp_put_port while the socket
is not locked.

The flow goes something like this:

sctp_close()
   sk_bh_lock_sock();
   sk_common_release()
     sctp_destroy_sock()
       endpoint_put()
         endpoint_destroy() <-- This is where we used to do sctp_put_port
   sk_bh_unlock_sock();
   sock_put()
     sk_free()
       __sk_free()
         sctp_destruct_sock()
           sctp_put_port()


I haven't found any race conditions yet, but that doesn't mean they 
don't exist.

I think an easy solution would be to do sctp_put_port in sctp_unhash(),
but I haven't traced all the paths.

Daniel, please take a look at this.

Thanks
-vlad


> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> ---
>   net/sctp/endpointola.c |  7 -------
>   net/sctp/socket.c      | 20 +++++++++++++++++++-
>   2 files changed, 19 insertions(+), 8 deletions(-)
>
> diff --git a/net/sctp/endpointola.c b/net/sctp/endpointola.c
> index a8b2674..9a9ebd2 100644
> --- a/net/sctp/endpointola.c
> +++ b/net/sctp/endpointola.c
> @@ -249,9 +249,6 @@ static void sctp_endpoint_destroy(struct sctp_endpoint *ep)
>   {
>   	SCTP_ASSERT(ep->base.dead, "Endpoint is not dead", return);
>
> -	/* Free up the HMAC transform. */
> -	crypto_free_hash(sctp_sk(ep->base.sk)->hmac);
> -
>   	/* Free the digest buffer */
>   	kfree(ep->digest);
>
> @@ -271,10 +268,6 @@ static void sctp_endpoint_destroy(struct sctp_endpoint *ep)
>
>   	memset(ep->secret_key, 0, sizeof(ep->secret_key));
>
> -	/* Remove and free the port */
> -	if (sctp_sk(ep->base.sk)->bind_hash)
> -		sctp_put_port(ep->base.sk);
> -
>   	/* Give up our hold on the sock. */
>   	if (ep->base.sk)
>   		sock_put(ep->base.sk);
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index 68a6b70..67f721e 100644
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
> @@ -4002,6 +4005,21 @@ static void sctp_destroy_sock(struct sock *sk)
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
> +	/* Remove and free the port */
> +	if (sp->bind_hash)
> +		sctp_put_port(sk);
> +
> +	inet_sock_destruct(sk);
> +}
> +
>   /* API 4.1.7 shutdown() - TCP Style Syntax
>    *     int shutdown(int socket, int how);
>    *
> @@ -6842,7 +6860,7 @@ void sctp_copy_sock(struct sock *newsk, struct sock *sk,
>   	newsk->sk_reuse = sk->sk_reuse;
>
>   	newsk->sk_shutdown = sk->sk_shutdown;
> -	newsk->sk_destruct = inet_sock_destruct;
> +	newsk->sk_destruct = sctp_destruct_sock;
>   	newsk->sk_family = sk->sk_family;
>   	newsk->sk_protocol = IPPROTO_SCTP;
>   	newsk->sk_backlog_rcv = sk->sk_prot->backlog_rcv;
>
