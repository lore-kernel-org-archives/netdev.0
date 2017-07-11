From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH v3 net-next 3/4] tls: kernel TLS support
Date: Tue, 11 Jul 2017 08:29:53 +0200
Message-ID: <20170711062953.GE2631@secunet.com>
References: <cover.1497465295.git.davejwatson@fb.com>
 <20170614183739.GA80368@davejwatson-mba.dhcp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Ilya Lesokhin <ilyal@mellanox.com>,
        Aviad Yehezkel <aviadye@mellanox.com>,
        Boris Pismenny <borisp@mellanox.com>,
        Liran Liss <liranl@mellanox.com>,
        "Matan Barak" <matanb@mellanox.com>,
        David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Tom Herbert <tom@herbertland.com>,
        <herbert@gondor.apana.org.au>, <linux-crypto@vger.kernel.org>,
        "Hannes Frederic Sowa" <hannes@stressinduktion.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        <nmav@gnutls.org>, <fridolin.pokorny@gmail.com>
To: Dave Watson <davejwatson@fb.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170614183739.GA80368@davejwatson-mba.dhcp.thefacebook.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sorry for replying to old mail...

On Wed, Jun 14, 2017 at 11:37:39AM -0700, Dave Watson wrote:
> +static int tls_do_encryption(struct tls_context *tls_ctx,
> +			     struct tls_sw_context *ctx, size_t data_len,
> +			     gfp_t flags)
> +{
> +	unsigned int req_size = sizeof(struct aead_request) +
> +		crypto_aead_reqsize(ctx->aead_send);
> +	struct aead_request *aead_req;
> +	int rc;
> +
> +	aead_req = kmalloc(req_size, flags);
> +	if (!aead_req)
> +		return -ENOMEM;
> +
> +	ctx->sg_encrypted_data[0].offset += tls_ctx->prepend_size;
> +	ctx->sg_encrypted_data[0].length -= tls_ctx->prepend_size;
> +
> +	aead_request_set_tfm(aead_req, ctx->aead_send);
> +	aead_request_set_ad(aead_req, TLS_AAD_SPACE_SIZE);
> +	aead_request_set_crypt(aead_req, ctx->sg_aead_in, ctx->sg_aead_out,
> +			       data_len, tls_ctx->iv);
> +	rc = crypto_aead_encrypt(aead_req);
> +
> +	ctx->sg_encrypted_data[0].offset -= tls_ctx->prepend_size;
> +	ctx->sg_encrypted_data[0].length += tls_ctx->prepend_size;
> +
> +	kfree(aead_req);
> +	return rc;
> +}

...

> +int tls_set_sw_offload(struct sock *sk, struct tls_context *ctx)
> +{

...

> +
> +	if (!sw_ctx->aead_send) {
> +		sw_ctx->aead_send = crypto_alloc_aead("gcm(aes)", 0, 0);
> +		if (IS_ERR(sw_ctx->aead_send)) {
> +			rc = PTR_ERR(sw_ctx->aead_send);
> +			sw_ctx->aead_send = NULL;
> +			goto free_rec_seq;
> +		}
> +	}
> +

When I look on how you allocate the aead transformation, it seems
that you should either register an asynchronous callback with
aead_request_set_callback(), or request for a synchronous algorithm.

Otherwise you will crash on an asynchronous crypto return, no?

Also, it seems that you have your scatterlists on a per crypto
transformation base istead of per crypto request. Is this intentional?
