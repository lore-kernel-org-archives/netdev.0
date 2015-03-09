From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 6/6] tcp_metrics: Use a single hash table for
 all network namespaces.
Date: Mon, 09 Mar 2015 11:47:08 -0700
Message-ID: <1425926828.8261.7.camel@edumazet-glaptop2.roam.corp.google.com>
References: <871tlxtbhd.fsf_-_@x220.int.ebiederm.org>
	 <CANn89iJ2auNoChr3FuFh-AGaPaw5_wwqfjZrtup1+xu6reVHMA@mail.gmail.com>
	 <87d25hrv9m.fsf@x220.int.ebiederm.org>
	 <20150219.144929.1003473344851168804.davem@davemloft.net>
	 <87h9tu114z.fsf_-_@x220.int.ebiederm.org>
	 <8761aayqdd.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, edumazet@google.com,
	netdev@vger.kernel.org, stephen@networkplumber.org,
	nicolas.dichtel@6wind.com, roopa@cumulusnetworks.com,
	hannes@stressinduktion.org, ddutt@cumulusnetworks.com,
	vipin@cumulusnetworks.com, shmulik.ladkani@gmail.com,
	dsahern@gmail.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:43370 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750741AbbCISrL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 14:47:11 -0400
Received: by iecrp18 with SMTP id rp18so37987216iec.10
        for <netdev@vger.kernel.org>; Mon, 09 Mar 2015 11:47:10 -0700 (PDT)
In-Reply-To: <8761aayqdd.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-03-09 at 13:31 -0500, Eric W. Biederman wrote:

> @@ -1167,17 +1173,22 @@ static void __net_exit tcp_net_metrics_exit(struct net *net)
>  {
>  	unsigned int i;
>  
> -	for (i = 0; i < (1U << net->ipv4.tcp_metrics_hash_log) ; i++) {
> +	if (net != &init_net) {
> +		tcp_metrics_flush_all(net);
> +		return;
> +	}

Note this _very_ unlikely (read: not possible) that
tcp_net_metrics_exit() will ever be called on init_net

So I would remove all this code.

> +
> +	for (i = 0; i < (1U << tcp_metrics_hash_log) ; i++) {
>  		struct tcp_metrics_block *tm, *next;
>  
> -		tm = rcu_dereference_protected(net->ipv4.tcp_metrics_hash[i].chain, 1);
> +		tm = rcu_dereference_protected(tcp_metrics_hash[i].chain, 1);
>  		while (tm) {
>  			next = rcu_dereference_protected(tm->tcpm_next, 1);
>  			kfree(tm);
>  			tm = next;
>  		}
>  	}
> -	kvfree(net->ipv4.tcp_metrics_hash);
> +	kvfree(tcp_metrics_hash);
>  }
>  
