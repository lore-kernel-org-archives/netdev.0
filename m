From: Michal Ostrowski <mostrows@earthlink.net>
Subject: Re: [PATCH 4/4] PPPoE: race between interface going down and
	release()
Date: Sun, 11 Mar 2007 13:17:16 -0500
Message-ID: <1173637036.24373.23.camel@kdsk1.austin.ibm.com>
References: <20070311044143.GD17712@florz.florz.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Florian Zumbiehl <florz@florz.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from igw2.watson.ibm.com ([129.34.20.6]:58380 "EHLO
	igw2.watson.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933955AbXCKSR3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Mar 2007 14:17:29 -0400
In-Reply-To: <20070311044143.GD17712@florz.florz.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I need some more time to think about this one; there are some problem
I'm seeing here but I can't look at it right now.  I'll send out my
version of a patch for this tomorrow and we can discuss more.

Regarding the previous three patches, they seem fine after a first pass.
However, I'd like to ask you to please use a "Signed-off-by" statement.
That why I can ack it and push it upstream without hesitation.



-- 
Michal Ostrowski <mostrows@earthlink.net>



On Sun, 2007-03-11 at 05:41 +0100, Florian Zumbiehl wrote:
> Hi,
> 
> below you find the last patch for now. It (hopefully) fixes a race
> between a socket being release()d and the interface it's using going
> down. As pppoe_release() didn't lock the socket, and pppoe_flush_dev()
> did the locking in the wrong place, pppoe_flush_dev() could set
> po->pppoe_dev to NULL, which would then cause pppoe_release() to not
> dev_put() the interface, but to still mark the socket as DEAD,
> which in turn would cause pppoe_flush_dev() to not dev_put() the
> interface, effectively leaking one reference to the device, thus making it
> impossible to remove (ignoring the possibility of overflowing the reference
> counter by repeated use of this race ;-).
> 
> The thing I'm not quite sure about is whether the "outer"
> 
> |                        if (po->pppoe_dev == dev) {
> 
> is actually reliable this way on SMP systems, as far as cache consistency
> is concerned. I left it that way for now, as any alternative locking
> strategies that would lock the socket before doing this comparison seemed
> to be pretty complicated to implement because of the need to drop the
> hash table lock before trying to acquire the socket lock, so I'd rather
> be sure that this actually is a problem before I try to solve it ;-)
> 
> Florian
> 
> ---------------------------------------------------------------------------
> diff --git a/drivers/net/pppoe.c b/drivers/net/pppoe.c
> index 1aeac2c..f5abfff 100644
> --- a/drivers/net/pppoe.c
> +++ b/drivers/net/pppoe.c
> @@ -253,7 +253,6 @@ static void pppoe_flush_dev(struct net_device *dev)
>  				struct sock *sk = sk_pppox(po);
>  
>  				sock_hold(sk);
> -				po->pppoe_dev = NULL;
>  
>  				/* We hold a reference to SK, now drop the
>  				 * hash table lock so that we may attempt
> @@ -263,12 +262,15 @@ static void pppoe_flush_dev(struct net_device *dev)
>  
>  				lock_sock(sk);
>  
> -				if (sk->sk_state &
> -				    (PPPOX_CONNECTED | PPPOX_BOUND)) {
> -					pppox_unbind_sock(sk);
> +				if(po->pppoe_dev==dev){
>  					dev_put(dev);
> -					sk->sk_state = PPPOX_ZOMBIE;
> -					sk->sk_state_change(sk);
> +					po->pppoe_dev = NULL;
> +					if (sk->sk_state &
> +					    (PPPOX_CONNECTED | PPPOX_BOUND)) {
> +						pppox_unbind_sock(sk);
> +						sk->sk_state = PPPOX_ZOMBIE;
> +						sk->sk_state_change(sk);
> +					}
>  				}
>  
>  				release_sock(sk);
> @@ -504,8 +506,11 @@ static int pppoe_release(struct socket *sock)
>  	if (!sk)
>  		return 0;
>  
> -	if (sock_flag(sk, SOCK_DEAD))
> +	lock_sock(sk);
> +	if (sock_flag(sk, SOCK_DEAD)){
> +		release_sock(sk);
>  		return -EBADF;
> +	}
>  
>  	pppox_unbind_sock(sk);
>  
> @@ -526,6 +531,7 @@ static int pppoe_release(struct socket *sock)
>  	sock->sk = NULL;
>  
>  	skb_queue_purge(&sk->sk_receive_queue);
> +	release_sock(sk);
>  	sock_put(sk);
>  
>  	return 0;
> 

