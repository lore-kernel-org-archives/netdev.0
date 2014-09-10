From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net] ipv6: clean up anycast when an interface is destroyed
Date: Wed, 10 Sep 2014 10:15:01 -0700
Message-ID: <CAHA+R7ODewXP69ULsR0RD+c3BEfMa90zATRjHF3dC9Dkv7jgZw@mail.gmail.com>
References: <20140910102714.GB21267@kria>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Miller <davem@davemloft.net>
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:63519 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751344AbaIJRPD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2014 13:15:03 -0400
Received: by mail-lb0-f174.google.com with SMTP id n15so11316759lbi.19
        for <netdev@vger.kernel.org>; Wed, 10 Sep 2014 10:15:01 -0700 (PDT)
In-Reply-To: <20140910102714.GB21267@kria>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 10, 2014 at 3:27 AM, Sabrina Dubroca <sd@queasysnail.net> wrote:
> diff --git a/net/ipv6/anycast.c b/net/ipv6/anycast.c
> index ff2de7d9d8e6..a1bf80574bfe 100644
> --- a/net/ipv6/anycast.c
> +++ b/net/ipv6/anycast.c
> @@ -351,6 +351,28 @@ static int ipv6_dev_ac_dec(struct net_device *dev, const struct in6_addr *addr)
>         return __ipv6_dev_ac_dec(idev, addr);
>  }
>
> +/* Device is being destroyed: clean up */

This comment is useless.

> +void ipv6_ac_destroy_dev(struct inet6_dev *idev)
> +{
> +       struct ifacaddr6 *aca;
> +
> +       write_lock_bh(&idev->lock);
> +       while ((aca = idev->ac_list) != NULL) {
> +               idev->ac_list = aca->aca_next;
> +               write_unlock_bh(&idev->lock);
> +
> +               addrconf_leave_solict(idev, &aca->aca_addr);
> +
> +               dst_hold(&aca->aca_rt->dst);
> +               ip6_del_rt(aca->aca_rt);
> +
> +               aca_put(aca);
> +
> +               write_lock_bh(&idev->lock);
> +       }
> +       write_unlock_bh(&idev->lock);
> +}
> +

I think you can probably refactor the code out of __ipv6_dev_ac_dec()
so that you don't have to kinda duplicate the code?
