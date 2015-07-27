From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: netns refcnt leak for kernel accept sock
Date: Mon, 27 Jul 2015 12:40:27 -0500
Message-ID: <87h9op5wj8.fsf@x220.int.ebiederm.org>
References: <20150727142146.GC16447@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:51445 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752187AbbG0RrC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 13:47:02 -0400
In-Reply-To: <20150727142146.GC16447@oracle.com> (Sowmini Varadhan's message
	of "Mon, 27 Jul 2015 16:21:46 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


sock_create_kern and friends are specialied interfaces for special
purposes.  At a quick read through I don't think we have a single in
tree user doing with them what you are trying to do.

Without seeing code using the interfaces in the way are trying to use
them I do not have enough information to comment intelligently.

Eric

Sowmini Varadhan <sowmini.varadhan@oracle.com> writes:
> I'm running into a netns refcnt issue, and I suspect that 
> eeb1bd5c has something to do with it (perhaps we need an 
> additional change in sk_clone_lock() after eeb1bd5c). 
> Here's the problem:
>
> When we create an syn_recv sock based on a kernel listen sock, we
> take a get_net() ref  with a stack similar to the one shown below.
> Note that the parent (kernel, listen) sock itself has not taken
> a get_net() ref, because it explicitly calls sock_create_kern().
>
>   get_net /* for the newsk */
>   sk_clone_lock
>   inet_csk_clone_lock
>   tcp_create_openreq_child
>   tcp_v4_syn_recv_sock
>   tcp_check_req
>   tcp_v4_do_rcv
>   tcp_v4_rcv 
>    :
>
> But it's not clear to me where this refcnt will be released: 
> in my case, I expect to create/cleanup kernel sockets as part 
> of ->init/->exit for my module, but because the accept socket 
> has a netns refcnt, it blocks cleanup_net(), thus my ->exit 
> pernet_subsys op cannot run and clean this up, and we have a leak.
>
> I think that sk_clone_lock() should only do a get_net() if the parent
> is not a kernel socket (making this similar to sk_alloc()), i.e.,
>
> diff --git a/net/core/sock.c b/net/core/sock.c
> index 08f16db..371d1b7 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -1497,7 +1497,8 @@ struct sock *sk_clone_lock(const struct sock *sk, const gf
>                 sock_copy(newsk, sk);
>
>                 /* SANITY */
> -               get_net(sock_net(newsk));
> +               if (likely(newsk->sk_net_refcnt))
> +                       get_net(sock_net(newsk));
>                 sk_node_init(&newsk->sk_node);
>                 sock_lock_init(newsk);
>                 bh_lock_sock(newsk);
>
> Does this sound right?
>
> --Sowmini
