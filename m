From: Dave Watson <davejwatson@fb.com>
Subject: Re: [PATCH v3 net-next 3/4] tls: kernel TLS support
Date: Tue, 11 Jul 2017 11:53:11 -0700
Message-ID: <20170711185311.GA200@davejwatson-mba.dhcp.thefacebook.com>
References: <cover.1497465295.git.davejwatson@fb.com>
 <20170614183739.GA80368@davejwatson-mba.dhcp.thefacebook.com>
 <20170711062953.GE2631@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Ilya Lesokhin <ilyal@mellanox.com>,
        Aviad Yehezkel <aviadye@mellanox.com>,
        Boris Pismenny <borisp@mellanox.com>,
        Liran Liss <liranl@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Tom Herbert <tom@herbertland.com>,
        <herbert@gondor.apana.org.au>, <linux-crypto@vger.kernel.org>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        <nmav@gnutls.org>, <fridolin.pokorny@gmail.com>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:53544 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1756440AbdGKSyD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Jul 2017 14:54:03 -0400
Content-Disposition: inline
In-Reply-To: <20170711062953.GE2631@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/11/17 08:29 AM, Steffen Klassert wrote:
> Sorry for replying to old mail...
> > +int tls_set_sw_offload(struct sock *sk, struct tls_context *ctx)
> > +{
> 
> ...
> 
> > +
> > +	if (!sw_ctx->aead_send) {
> > +		sw_ctx->aead_send = crypto_alloc_aead("gcm(aes)", 0, 0);
> > +		if (IS_ERR(sw_ctx->aead_send)) {
> > +			rc = PTR_ERR(sw_ctx->aead_send);
> > +			sw_ctx->aead_send = NULL;
> > +			goto free_rec_seq;
> > +		}
> > +	}
> > +
> 
> When I look on how you allocate the aead transformation, it seems
> that you should either register an asynchronous callback with
> aead_request_set_callback(), or request for a synchronous algorithm.
> 
> Otherwise you will crash on an asynchronous crypto return, no?

The intention is for it to be synchronous, and gather directly from
userspace buffers.  It looks like calling
crypto_alloc_aead("gcm(aes)", 0, CRYPTO_ALG_ASYNC) is the correct way
to request synchronous algorithms only?

> Also, it seems that you have your scatterlists on a per crypto
> transformation base istead of per crypto request. Is this intentional?

We hold the socket lock and only one crypto op can happen at a time,
so we reuse the scatterlists.
