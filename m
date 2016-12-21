From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 3/5 net-next] inet: don't check for bind conflicts twice
 when searching for a port
Date: Wed, 21 Dec 2016 16:08:32 +0100
Message-ID: <1482332912.2260.8.camel@stressinduktion.org>
References: <1482264424-15439-1-git-send-email-jbacik@fb.com>
         <1482264424-15439-4-git-send-email-jbacik@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Josef Bacik <jbacik@fb.com>, davem@davemloft.net,
        kraigatgoog@gmail.com, eric.dumazet@gmail.com, tom@herbertland.com,
        netdev@vger.kernel.org, kernel-team@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:54382 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750919AbcLUPIh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2016 10:08:37 -0500
In-Reply-To: <1482264424-15439-4-git-send-email-jbacik@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-12-20 at 15:07 -0500, Josef Bacik wrote:
> --- a/net/ipv4/inet_connection_sock.c
> +++ b/net/ipv4/inet_connection_sock.c
> @@ -92,7 +92,7 @@ int inet_csk_get_port(struct sock *sk, unsigned short snum)
>  {
>  	bool reuse = sk->sk_reuse && sk->sk_state != TCP_LISTEN;
>  	struct inet_hashinfo *hinfo = sk->sk_prot->h.hashinfo;
> -	int ret = 1, attempts = 5, port = snum;
> +	int ret = 1, port = snum;
>  	struct inet_bind_hashbucket *head;
>  	struct net *net = sock_net(sk);
>  	int i, low, high, attempt_half;
> @@ -100,6 +100,7 @@ int inet_csk_get_port(struct sock *sk, unsigned short snum)
>  	kuid_t uid = sock_i_uid(sk);
>  	u32 remaining, offset;
>  	bool reuseport_ok = !!snum;
> +	bool empty_tb = true;
>  
>  	if (port) {
>  		head = &hinfo->bhash[inet_bhashfn(net, port,
> @@ -111,7 +112,6 @@ int inet_csk_get_port(struct sock *sk, unsigned short snum)
>  
>  		goto tb_not_found;
>  	}
> -again:
>  	attempt_half = (sk->sk_reuse == SK_CAN_REUSE) ? 1 : 0;
>  other_half_scan:
>  	inet_get_local_port_range(net, &low, &high);
> @@ -148,8 +148,12 @@ other_parity_scan:
>  		spin_lock_bh(&head->lock);
>  		inet_bind_bucket_for_each(tb, &head->chain)
>  			if (net_eq(ib_net(tb), net) && tb->port == port) {
> -				if (!inet_csk_bind_conflict(sk, tb, false, reuseport_ok))
> -					goto tb_found;
> +				if (hlist_empty(&tb->owners))
> +					goto success;
> +				if (!inet_csk_bind_conflict(sk, tb, false, reuseport_ok)) {
> +					empty_tb = false;
> +					goto success;
> +				}
>  				goto next_port;
>  			}
>  		goto tb_not_found;
> @@ -184,23 +188,12 @@ tb_found:
>  		      !rcu_access_pointer(sk->sk_reuseport_cb) &&
>  		      sk->sk_reuseport && uid_eq(tb->fastuid, uid)))
>  			goto success;
> -		if (inet_csk_bind_conflict(sk, tb, true, reuseport_ok)) {
> -			if ((reuse ||
> -			     (tb->fastreuseport > 0 &&
> -			      sk->sk_reuseport &&
> -			      !rcu_access_pointer(sk->sk_reuseport_cb) &&
> -			      uid_eq(tb->fastuid, uid))) && !snum &&
> -			    --attempts >= 0) {
> -				spin_unlock_bh(&head->lock);
> -				goto again;
> -			}
> +		if (inet_csk_bind_conflict(sk, tb, true, reuseport_ok))
>  			goto fail_unlock;
> -		}
> -		if (!reuse)
> -			tb->fastreuse = 0;
> -		if (!sk->sk_reuseport || !uid_eq(tb->fastuid, uid))
> -			tb->fastreuseport = 0;
> -	} else {
> +		empty_tb = false;
> +	}
> +success:
> +	if (empty_tb) {


I would fine it even more simple to read, if you redo the hlist_empty
check here instead of someone has to review all the paths where this
might get set. hlist_empty is a very quick test.


Thanks,
Hannes
