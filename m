From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net] packet: Do not call fanout_release from atomic
 contexts
Date: Wed, 15 Feb 2017 09:41:11 -0800
Message-ID: <1487180471.1311.26.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1487177030-2980-1-git-send-email-anoob.soman@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Anoob Soman <anoob.soman@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33094 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750905AbdBORlN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2017 12:41:13 -0500
Received: by mail-pf0-f195.google.com with SMTP id e4so9201619pfg.0
        for <netdev@vger.kernel.org>; Wed, 15 Feb 2017 09:41:13 -0800 (PST)
In-Reply-To: <1487177030-2980-1-git-send-email-anoob.soman@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-02-15 at 16:43 +0000, Anoob Soman wrote:

> 
>  net/packet/af_packet.c | 29 ++++++++++++++++++++++-------
>  1 file changed, 22 insertions(+), 7 deletions(-)
> 
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index d56ee46..af29510 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -1497,6 +1497,8 @@ static void __fanout_link(struct sock *sk, struct packet_sock *po)
>  	f->arr[f->num_members] = sk;
>  	smp_wmb();
>  	f->num_members++;
> +	if (f->num_members == 1)
> +		dev_add_pack(&f->prot_hook);
>  	spin_unlock(&f->lock);
>  }
>  
> @@ -1513,6 +1515,8 @@ static void __fanout_unlink(struct sock *sk, struct packet_sock *po)
>  	BUG_ON(i >= f->num_members);
>  	f->arr[i] = f->arr[f->num_members - 1];
>  	f->num_members--;
> +	if (f->num_members == 0)
> +		__dev_remove_pack(&f->prot_hook);
>  	spin_unlock(&f->lock);
>  }
>  
> @@ -1687,7 +1691,6 @@ static int fanout_add(struct sock *sk, u16 id, u16 type_flags)
>  		match->prot_hook.func = packet_rcv_fanout;
>  		match->prot_hook.af_packet_priv = match;
>  		match->prot_hook.id_match = match_fanout_group;
> -		dev_add_pack(&match->prot_hook);
>  		list_add(&match->list, &fanout_list);
>  	}
>  	err = -EINVAL;
> @@ -1712,10 +1715,16 @@ static int fanout_add(struct sock *sk, u16 id, u16 type_flags)
>  	return err;
>  }
>  
> -static void fanout_release(struct sock *sk)
> +/* If pkt_sk(sk)->fanout->sk_ref is zero, this functuon removes
> + * pkt_sk(sk)->fanout from fanout_list and returns pkt_sk(sk)->fanout.
> + * It is the responsibility of the caller to call fanout_release_data() and
> + * free the returned packet_fanout (after synchronize_net())
> + */
> +static struct packet_fanout *fanout_release(struct sock *sk)
>  {
>  	struct packet_sock *po = pkt_sk(sk);
>  	struct packet_fanout *f;
> +	bool ret_fanout = false;

No need for this new variable.

>  
>  	f = po->fanout;
>  	if (!f)
> @@ -1726,14 +1735,14 @@ static void fanout_release(struct sock *sk)
>  
>  	if (atomic_dec_and_test(&f->sk_ref)) {
>  		list_del(&f->list);
> -		dev_remove_pack(&f->prot_hook);
> -		fanout_release_data(f);
> -		kfree(f);
> +		ret_fanout = true;
>  	}

} else {
     f = NULL;
}

>  	mutex_unlock(&fanout_mutex);
>  
>  	if (po->rollover)
>  		kfree_rcu(po->rollover, rcu);
> +
> +	return ret_fanout ? f : NULL;

return f;

>  }
>  
>  

Otherwise, this look good.

But make sure to respin your patch based on latest net tree.

af_packet.c got a recent fix.

Thanks
