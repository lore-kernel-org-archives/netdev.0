From: Tom Herbert <therbert@google.com>
Subject: Re: GRO with non napi driver: BUG in __napi_complete
Date: Fri, 27 Mar 2009 12:05:30 -0700
Message-ID: <65634d660903271205v2c82469en6d71e08077202900@mail.gmail.com>
References: <49BF60C9.1080100@linux.vnet.ibm.com>
	 <20090317102244.GB23396@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Frank Blaschka <blaschka@linux.vnet.ibm.com>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:19075 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751494AbZC0TFn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2009 15:05:43 -0400
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id n2RJ5boO032606
	for <netdev@vger.kernel.org>; Fri, 27 Mar 2009 19:05:38 GMT
Received: from qw-out-2122.google.com (qwe3.prod.google.com [10.241.194.3])
	by wpaz1.hot.corp.google.com with ESMTP id n2RJ5Z3j029332
	for <netdev@vger.kernel.org>; Fri, 27 Mar 2009 12:05:35 -0700
Received: by qw-out-2122.google.com with SMTP id 3so892988qwe.17
        for <netdev@vger.kernel.org>; Fri, 27 Mar 2009 12:05:35 -0700 (PDT)
In-Reply-To: <20090317102244.GB23396@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On the legacy netif_rx path, I incorrectly tried to optimise
>
> the napi_complete call by using __napi_complete before we reenable
> IRQs. =A0This simply doesn't work since we need to flush the held
> GRO packets first.
>
> This patch fixes it by doing the obvious thing of reenabling
> IRQs first and then calling napi_complete.

Does this fix generate a race condition for a non-NAPI device?=A0 If
netif_rx runs immediately after local_irq_enable it would queue a
packet on the backlog queue and try to schedule napi (the latter has
no effect because napi has not completed).=A0 On return from interrupt,
napi_complete is done leaving a packet in the input queue but napi is
not scheduled to process it.

Thanks,
Tom

>
> Reported-by: Frank Blaschka <blaschka@linux.vnet.ibm.com>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index f112970..2565f6d 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2588,9 +2588,9 @@ static int process_backlog(struct napi_struct *=
napi, int quota)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0local_irq_disable();
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0skb =3D __skb_dequeue(&queue->input_pk=
t_queue);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!skb) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __napi_complete(napi);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0local_irq_enable();
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 napi_complete(napi);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0local_irq_enable();
>
> @@ -2599,6 +2599,7 @@ static int process_backlog(struct napi_struct *=
napi, int quota)
>
> =A0 =A0 =A0 =A0napi_gro_flush(napi);
>
> +out:
> =A0 =A0 =A0 =A0return work;
> =A0}
>
> Thanks,
> --
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
