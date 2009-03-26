From: Adam Richter <adam_richter2004@yahoo.com>
Subject: Re: 2.6.29 forcedeth hang W/O NAPI enabled
Date: Wed, 25 Mar 2009 22:24:42 -0700 (PDT)
Message-ID: <985285.87214.qm@web57701.mail.re3.yahoo.com>
References: <20090326033658.GA14592@gondor.apana.org.au>
Reply-To: adam_richter2004@yahoo.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, berkley@cs.wustl.edu
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web57701.mail.re3.yahoo.com ([68.142.236.53]:25124 "HELO
	web57701.mail.re3.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753943AbZCZFYp convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Mar 2009 01:24:45 -0400
In-Reply-To: <20090326033658.GA14592@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--- On Wed, 3/25/09, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> Hi Adam:
>=20
> Any chance you can test this patch instead of the previous
> one?

OK.  I tried your patch.  It seems fine.  I was able to do "ping -f" fo=
r five minutes with no problems, and surf the web during that time.

I preserving the rest of your message below, just to be clear about whi=
ch patch I tested.

Adam


>=20
> net: Fix netpoll lockup in legacy receive path
>=20
> When I fixed the GRO crash in the legacy receive path I
> used
> napi_complete to replace __napi_complete.  Unfortunately
> they're
> not the same when NETPOLL is enabled, which may result in
> us
> not calling __napi_complete at all.
>=20
> What's more, we really do need to keep the
> __napi_complete call
> within the IRQ-off section since in theory an IRQ can occur
> in
> between and fill up the backlog to the maximum, causing us
> to
> lock up.
>=20
> This patch fixes this by essentially open-coding
> __napi_complete.
>=20
> Note we no longer need the memory barrier because this
> function
> is per-cpu.
>=20
> Signed-off-by: Herbert Xu
> <herbert@gondor.apana.org.au>
>=20
> diff --git a/net/core/dev.c b/net/core/dev.c
> index e3fe5c7..2a7f6b3 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2588,9 +2588,10 @@ static int process_backlog(struct
> napi_struct *napi, int quota)
>  		local_irq_disable();
>  		skb =3D __skb_dequeue(&queue->input_pkt_queue);
>  		if (!skb) {
> +			list_del(&napi->poll_list);
> +			clear_bit(NAPI_STATE_SCHED, &napi->state);
>  			local_irq_enable();
> -			napi_complete(napi);
> -			goto out;
> +			break;
>  		}
>  		local_irq_enable();
> =20
> @@ -2599,7 +2600,6 @@ static int process_backlog(struct
> napi_struct *napi, int quota)
> =20
>  	napi_gro_flush(napi);
> =20
> -out:
>  	return work;
>  }
>=20
> Thanks,
> --=20
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu =E8=AE=B8=E5=BF=97=E5=A3=AC
> <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/=EF=BF=BDherbert/
> PGP Key: http://gondor.apana.org.au/=EF=BF=BDherbert/pubkey.txt


     =20
