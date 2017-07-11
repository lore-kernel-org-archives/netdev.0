From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [PATCH v3 net-next 3/4] tls: kernel TLS support
Date: Tue, 11 Jul 2017 13:24:02 -0700
Message-ID: <20170711202402.GA48524@gmail.com>
References: <cover.1497465295.git.davejwatson@fb.com>
 <20170614183739.GA80368@davejwatson-mba.dhcp.thefacebook.com>
 <20170711062953.GE2631@secunet.com>
 <20170711185311.GA200@davejwatson-mba.dhcp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
        Ilya Lesokhin <ilyal@mellanox.com>,
        Aviad Yehezkel <aviadye@mellanox.com>,
        Boris Pismenny <borisp@mellanox.com>,
        Liran Liss <liranl@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        Tom Herbert <tom@herbertland.com>, herbert@gondor.apana.org.au,
        linux-crypto@vger.kernel.org,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        nmav@gnutls.org, fridolin.pokorny@gmail.com
To: Dave Watson <davejwatson@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35905 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932577AbdGKUYF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Jul 2017 16:24:05 -0400
Content-Disposition: inline
In-Reply-To: <20170711185311.GA200@davejwatson-mba.dhcp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 11, 2017 at 11:53:11AM -0700, Dave Watson wrote:
> On 07/11/17 08:29 AM, Steffen Klassert wrote:
> > Sorry for replying to old mail...
> > > +int tls_set_sw_offload(struct sock *sk, struct tls_context *ctx)
> > > +{
> > 
> > ...
> > 
> > > +
> > > +	if (!sw_ctx->aead_send) {
> > > +		sw_ctx->aead_send = crypto_alloc_aead("gcm(aes)", 0, 0);
> > > +		if (IS_ERR(sw_ctx->aead_send)) {
> > > +			rc = PTR_ERR(sw_ctx->aead_send);
> > > +			sw_ctx->aead_send = NULL;
> > > +			goto free_rec_seq;
> > > +		}
> > > +	}
> > > +
> > 
> > When I look on how you allocate the aead transformation, it seems
> > that you should either register an asynchronous callback with
> > aead_request_set_callback(), or request for a synchronous algorithm.
> > 
> > Otherwise you will crash on an asynchronous crypto return, no?
> 
> The intention is for it to be synchronous, and gather directly from
> userspace buffers.  It looks like calling
> crypto_alloc_aead("gcm(aes)", 0, CRYPTO_ALG_ASYNC) is the correct way
> to request synchronous algorithms only?
> 

Yes, that means the CRYPTO_ALG_ASYNC bit is required to be 0, i.e. the algorithm
must be synchronous.  Currently it's requesting either a synchronous or
asynchronous algorithm, and it will crash if it gets an async one.

Also I think even with a synchronous algorithm, tls_do_encryption() still needs
to call aead_request_set_callback(), passing NULL for the callback and data, so
that the request flags are initialized.

Eric
