From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: Prevent multiple NAPI instances co-existing in the
 list
Date: Thu, 08 Jan 2015 16:04:08 +0300
Message-ID: <54AE8048.6040105@cogentembedded.com>
References: <CA+U0gVh+TyEUJ+qmg+FE=UhvvQywfNxcouCyv1sutZ3fav5FAw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Dennis Chen <kernel.org.gnu@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:45083 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754653AbbAHNEN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 08:04:13 -0500
Received: by mail-lb0-f178.google.com with SMTP id u14so2705128lbd.9
        for <netdev@vger.kernel.org>; Thu, 08 Jan 2015 05:04:11 -0800 (PST)
In-Reply-To: <CA+U0gVh+TyEUJ+qmg+FE=UhvvQywfNxcouCyv1sutZ3fav5FAw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 1/8/2015 11:22 AM, Dennis Chen wrote:

> Some drivers may clear the NAPI_STATE_SCHED bit upon the state of the
> NAPI instance after exhaust the budget in the poll function, which
> will open a window for next device interrupt handler to insert a same
> instance to the list after calling list_add_tail(&n->poll_list,
> repoll) if we don't set this bit.

> Signed-off-by: Dennis Chen <kernel.org.gnu@gmail.com>
> ---
>   net/core/dev.c |    8 ++++++++
>   1 file changed, 8 insertions(+)

> diff --git a/net/core/dev.c b/net/core/dev.c
> index 683d493..b3107ac 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -4619,6 +4619,14 @@ static int napi_poll(struct napi_struct *n,
> struct list_head *repoll)
>                               n->dev ? n->dev->name : "backlog");
>                  goto out_unlock;
>          }
> +
> +       /* Some drivers may exit the polling mode when exhaust the

    s/exhaust/exhausting/.

> +        * budget. Set the NAPI_STATE_SCHED bit to prevent multiple NAPI
> +        * instances in the list in case of next device interrupt raised.
> +        */
> +       if (unlikely(!test_and_set_bit(NAPI_STATE_SCHED, &n->state)))
> +               pr_warn_once("%s: exit polling mode after exhaust the budget\n",

    Likewise. And s/exit/exiting/.

WBR, Sergei
