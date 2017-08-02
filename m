From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC 1/1] constify tcp congestion
Date: Wed, 02 Aug 2017 00:56:03 -0700
Message-ID: <1501660563.25002.13.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170802024943.7517-1-sthemmin@microsoft.com>
         <20170802024943.7517-2-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:36234 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750725AbdHBH4J (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 03:56:09 -0400
Received: by mail-pg0-f50.google.com with SMTP id v77so12522458pgb.3
        for <netdev@vger.kernel.org>; Wed, 02 Aug 2017 00:56:09 -0700 (PDT)
In-Reply-To: <20170802024943.7517-2-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-08-01 at 19:49 -0700, Stephen Hemminger wrote:
> Split the TCP congestion ops structure into const and mutable portions.
> Put the list pointers, key and a copy of the flags in new tcp_congestion_entry
> structure.

...

> -void tcp_unregister_congestion_control(struct tcp_congestion_ops *ca)
> +void tcp_unregister_congestion_control(const struct tcp_congestion_ops *ca)
>  {
> +	struct tcp_congestion_entry *e;
> +
>  	spin_lock(&tcp_cong_list_lock);
> -	list_del_rcu(&ca->list);
> +	list_for_each_entry_rcu(e, &tcp_cong_list, list) {
> +		if (e->ops == ca) {
> +			list_del_rcu(&e->list);
> +			kfree_rcu(e, rcu);
> +			break;
> +		}
> +	}
>  	spin_unlock(&tcp_cong_list_lock);
>  


Since you switched to kfree_rcu(), you could remove the
synchronize_rcu() from tcp_unregister_congestion_control()

Otherwise, no need for kfree_rcu() and the rcu head added in struct
tcp_congestion_entry :
 - You could do a kfree() after the synchronize_rcu().

Also, I am not convinced this would be a good move, since you added an
extra structure which is not const anyway.
