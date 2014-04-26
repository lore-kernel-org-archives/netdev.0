From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] ipv6: Set flow label to skb_hash on transmit
Date: Sat, 26 Apr 2014 16:40:06 -0700
Message-ID: <1398555606.29914.111.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.DEB.2.02.1404261553180.15772@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:47708 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751716AbaDZXkI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Apr 2014 19:40:08 -0400
Received: by mail-pa0-f42.google.com with SMTP id bj1so1163773pad.15
        for <netdev@vger.kernel.org>; Sat, 26 Apr 2014 16:40:08 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.02.1404261553180.15772@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-04-26 at 16:00 -0700, Tom Herbert wrote:
>  
> +static inline __be32 ip6_make_flowlabel(struct net *net, struct sk_buff *skb,
> +					__be32 flowlabel)
> +{
> +	__be32 hash;
> +
> +	if (flowlabel || !net->ipv6.sysctl.auto_flowlabels)
> +		return flowlabel;
> +
> +	hash = skb->sk && skb->sk->sk_hash ? skb->sk->sk_hash :
> +					     skb_get_hash_raw(skb);
> +
> +	return hash & IPV6_FLOWLABEL_MASK;
> +}

Hmm... 

We use jhash and a random perturb to generate sk_hash which serves as
our input to locate sockets in hash table.

If we leak sk_hash, an attacker can easily target one hash slot.

You could simply use :

hash = skb->sk ? hash_ptr(skb->sk, 20) : skb_get_hash_raw(skb);

But even with this, we could leak sensitive information...

So I would rather use a separate sk->sk_flowhash value, and put a
completely random value in it.
