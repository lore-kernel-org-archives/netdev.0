From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net v2] packet: fix use after free race in send path
 when dev is released
Date: Thu, 21 Nov 2013 06:40:42 -0800
Message-ID: <1385044842.10637.41.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1385027235-2217-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Salam Noureddine <noureddine@aristanetworks.com>,
	Ben Greear <greearb@candelatech.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:64750 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751609Ab3KUOkr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Nov 2013 09:40:47 -0500
Received: by mail-pa0-f52.google.com with SMTP id ld10so7110754pab.11
        for <netdev@vger.kernel.org>; Thu, 21 Nov 2013 06:40:46 -0800 (PST)
In-Reply-To: <1385027235-2217-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-11-21 at 10:47 +0100, Daniel Borkmann wrote:

> +static void packet_dev_put_deferred(struct rcu_head *head)
> +{
> +	struct packet_sock *po = container_of(head, struct packet_sock, rcu);
> +	struct sock *sk = &po->sk;
> +
> +	spin_lock(&po->bind_lock);
> +	po->ifindex = -1;
> +
> +	if (po->prot_hook.dev) {
> +		dev_put(po->prot_hook.dev);
> +		po->prot_hook.dev = NULL;
> +	}
> +
> +	spin_unlock(&po->bind_lock);
> +	sock_put(sk);
> +}

I dont think this is needed.

>  
>  static int packet_notifier(struct notifier_block *this,
>  			   unsigned long msg, void *ptr)
> @@ -3325,13 +3354,13 @@ static int packet_notifier(struct notifier_block *this,
>  					if (!sock_flag(sk, SOCK_DEAD))
>  						sk->sk_error_report(sk);
>  				}
> +				spin_unlock(&po->bind_lock);
> +
>  				if (msg == NETDEV_UNREGISTER) {
> -					po->ifindex = -1;
> -					if (po->prot_hook.dev)
> -						dev_put(po->prot_hook.dev);
> -					po->prot_hook.dev = NULL;
> +					sock_hold(sk);
> +					call_rcu(&po->rcu,
> +						 packet_dev_put_deferred);
>  				}
> -				spin_unlock(&po->bind_lock);
>  			}

Its not needed because you now take a reference on dev
in packet_cached_dev_get()

Otherwise, patch looks good !
