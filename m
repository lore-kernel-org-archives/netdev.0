From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tun, bpf: fix suspicious RCU usage in
 tun_{attach,detach}_filter
Date: Thu, 31 Mar 2016 15:36:30 -0400 (EDT)
Message-ID: <20160331.153630.1640223846173244431.davem@davemloft.net>
References: <56FD1512.70409@iogearbox.net>
	<20160331.152149.396188904137423987.davem@davemloft.net>
	<56FD795C.9090903@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, eric.dumazet@gmail.com,
	alexei.starovoitov@gmail.com, mkubecek@suse.cz,
	sasha.levin@oracle.com, jslaby@suse.cz, mst@redhat.com,
	netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57922 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757415AbcCaTgc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 15:36:32 -0400
In-Reply-To: <56FD795C.9090903@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Thu, 31 Mar 2016 21:24:12 +0200

> diff --git a/net/core/filter.c b/net/core/filter.c
> index 4b81b71171b4ce..8ab270d5ce5507 100644
> --- a/net/core/filter.c
> +++ b/net/core/filter.c
> @@ -1166,7 +1166,8 @@ static int __sk_attach_prog(struct bpf_prog
> *prog, struct sock *sk)
>  	}
> 
>  	old_fp = rcu_dereference_protected(sk->sk_filter,
> -					   sock_owned_by_user(sk));
> +					   lockdep_rtnl_is_held() ||
> +					   lockdep_sock_is_held(sk));
>  	rcu_assign_pointer(sk->sk_filter, fp);
> 
>  	if (old_fp)

I have the same objections Daniel did.

Not all socket filter clients use RTNL as the synchornization
mechanism.  The caller, or some descriptive element, should tell us
what that synchronizing element is.

Yes, I understand how these RTNL checks can pass "accidently" but
the opposite is true too.  A socket locking synchornizing user,
who didn't lock the socket, might now pass because RTNL happens
to be held elsewhere.

Constraining the test properly, based upon the user, makes this less
likely to happen.  And that's desirable.
