From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net] sock_diag: invert socket destroy broadcast check
Date: Fri, 24 Jun 2016 15:41:05 -0500
Message-ID: <8737o2721q.fsf@x220.int.ebiederm.org>
References: <1466798630-40553-1-git-send-email-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, davem@davemloft.net, kraig@google.com,
	eric.dumazet@gmail.com, Willem de Bruijn <willemb@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:41936 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751308AbcFXUxR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2016 16:53:17 -0400
In-Reply-To: <1466798630-40553-1-git-send-email-willemdebruijn.kernel@gmail.com>
	(Willem de Bruijn's message of "Fri, 24 Jun 2016 16:03:50 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Willem de Bruijn <willemdebruijn.kernel@gmail.com> writes:

> From: Willem de Bruijn <willemb@google.com>
>
> Socket destruction is only broadcast for a socket sk if a diag
> listener is registered and sk is not a kernel socket.
>
> Invert the test to not even check for listeners for kernel sockets.
>
> The sock_diag_has_destroy_listeners invocation dereferences
> sock_net(sk), which for kernel sockets can be invalid as they do not
> take a reference on the network namespace.

No.  That isn't so.  A kernel socket for a network namespace must be
destroyed in the network namespace teardown.

Therefore sock_net(sk) should always be valid.  If sock_net(sk) is not
valid something very broken is going on.

Eric

> Fixes: b922622ec6ef ("sock_diag: don't broadcast kernel sockets")
> Fixes: 26abe14379f8 ("net: Modify sk_alloc to not reference count the
>                       netns of kernel sockets.")
> Signed-off-by: Willem de Bruijn <willemb@google.com>
>
> ---
>
> This patch fixes this immediate codepath. A broader issue of live
> kernel sockets pointing to deleted namespaces may persist.
>
> I observed skbs queued on a device queue in another namespace from
> a kernel socket in SOCK_DEAD state with dangling sock_net(sk). Socket
> refcnt is zero, but sk_wmem_alloc is not. (This was on an older
> kernel, have not yet tried to reproduce on net).
>
> It seems that we may need to reintroduce namespace reference counting
> for kernel sockets (with two-stage deletion to avoid the circular
> reference), scrub packets between namespaces, or reparent kernel
> sockets to init_net on namespace destruction.
> ---
>  net/core/sock.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/core/sock.c b/net/core/sock.c
> index 08bf97e..ba082b4 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -1473,7 +1473,7 @@ void sk_destruct(struct sock *sk)
>  
>  static void __sk_free(struct sock *sk)
>  {
> -	if (unlikely(sock_diag_has_destroy_listeners(sk) && sk->sk_net_refcnt))
> +	if (unlikely(sk->sk_net_refcnt && sock_diag_has_destroy_listeners(sk)))
>  		sock_diag_broadcast_destroy(sk);
>  	else
>  		sk_destruct(sk);
