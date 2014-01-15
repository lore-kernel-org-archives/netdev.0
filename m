From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next V4 1/3] net: Add GRO support for UDP
 encapsulating protocols
Date: Tue, 14 Jan 2014 16:50:29 -0800
Message-ID: <1389747029.31367.297.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1389715212-14504-1-git-send-email-ogerlitz@mellanox.com>
	 <1389715212-14504-2-git-send-email-ogerlitz@mellanox.com>
	 <CA+mtBx_R+J3UMtdOkfQQjdBN+JMLzrbY6q3r+VaHxJEDrSzt1g@mail.gmail.com>
	 <CAJZOPZ+1JrMiuh3csp8P56NJ5LphszneO_zwmShut3KxFuxaTQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Jerry Chu <hkchu@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Yan Burman <yanb@mellanox.com>,
	Shlomo Pongratz <shlomop@mellanox.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f47.google.com ([209.85.213.47]:63148 "EHLO
	mail-yh0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751892AbaAOAuc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 19:50:32 -0500
Received: by mail-yh0-f47.google.com with SMTP id c41so347972yho.6
        for <netdev@vger.kernel.org>; Tue, 14 Jan 2014 16:50:31 -0800 (PST)
In-Reply-To: <CAJZOPZ+1JrMiuh3csp8P56NJ5LphszneO_zwmShut3KxFuxaTQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-01-14 at 23:51 +0200, Or Gerlitz wrote:

> >> +       rcu_read_lock();
> >> +
> >> +       uo_priv = rcu_dereference(udp_offload_base);
> >> +       for (; uo_priv != NULL; uo_priv = rcu_dereference(uo_priv->next)) {
> >> +               if (uo_priv->offload->port == uh->dest &&
> >> +                   uo_priv->offload->callbacks.gro_complete)
> >> +                       goto found;
> >> +       }
> >> +
> >> +       rcu_read_unlock();
> >> +       return err;
> >> +
> >> +found:
> >> +       atomic_inc(&uo_priv->refcount);
> >
> > This is an expensive operation in the critical path.
> 
> I know, but I don't see how to get away without having the ref/unref
> wrapping, ideas welcome
> 
> > Can uo_priv be protected by rcu also?
> 
> uo_priv is the actual element which is rcu protected, not sure to
> follow on your question.
> 

Seems pretty easy : unlock rcu after calling gro_complete() as in :

found:
       err = uo_priv->offload->callbacks.gro_complete(skb, nhoff + sizeof(struct udphdr));
       rcu_read_unlock();
       return err;
