From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH vringh 2/2] caif_virtio: Introduce caif over virtio
Date: Mon, 11 Feb 2013 17:27:43 +1030
Message-ID: <87vc9zfic8.fsf@rustcorp.com.au>
References: <1360494273-27889-1-git-send-email-sjur.brandeland@stericsson.com> <1360494273-27889-3-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sjur@brendeland.net, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org,
	Dmitry Tarnyagin <dmitry.tarnyagin@stericsson.com>,
	Linus Walleij <linus.walleij@linaro.org>,
	Erwan Yvin <erwan.yvin@stericsson.com>,
	Vikram ARV <vikram.arv@stericsson.com>,
	Sjur =?utf-8?Q?Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>,
	Ido Yariv <ido@wizery.com>
To: sjur.brandeland@stericsson.com,
	"David S. Miller" <davem@davemloft.net>,
	Ohad Ben-Cohen <ohad@wizery.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1360494273-27889-3-git-send-email-sjur.brandeland@stericsson.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

sjur.brandeland@stericsson.com writes:
> From: Vikram ARV <vikram.arv@stericsson.com>
>
> Add the the Virtio shared memory driver for STE Modems.
> caif_virtio is implemented utilizing the virtio framework
> for data transport and is managed with the remoteproc frameworks.
>
> The Virtio queue is used for transmitting data to the modem, and
> the new vringh implementation is receiving data over the vring.

OK, let's refine vringh now we can see another user:

> + * @head: Last descriptor ID we received from vringh_getdesc_kern.
> + *	  We use this to put descriptor back on the used ring. USHRT_MAX is
> + *	  used to indicate invalid head-id.

> + */
> +struct cfv_napi_context {
> +	struct vringh_kiov riov;
> +	unsigned short head;
> +};

Usually we use an int, and -1.  I imagine it'll take no more space,
due to padding.

> +static inline void ctx_prep_iov(struct cfv_napi_context *ctx)
> +{
> +	if (ctx->riov.allocated) {
> +		kfree(ctx->riov.iov);
> +		ctx->riov.iov = NULL;
> +		ctx->riov.allocated = false;
> +	}
> +	ctx->riov.iov = NULL;
> +	ctx->riov.i = 0;
> +	ctx->riov.max = 0;
> +}

Hmm, we should probably make sure you don't have to do this: that if
allocated once, you can simply reuse it by setting i = 0.

(This requires some care in the error handling paths, so we don't
free it from under you)...

And you probably want to free this up in cfv_remove() instead?

I'll create and test a patch now.

> +		if (riov->i == riov->max) {
> +			if (cfv->ctx.head != USHRT_MAX) {
> +				vringh_complete_kern(cfv->vr_rx,
> +						     cfv->ctx.head,
> +						     0);
> +				cfv->ctx.head = USHRT_MAX;
> +			}
> +
> +			ctx_prep_iov(&cfv->ctx);
> +			err = vringh_getdesc_kern(
> +				cfv->vr_rx,
> +				riov,
> +				&wiov,
> +				&cfv->ctx.head,
> +				GFP_ATOMIC);
> +
> +			if (err <= 0)
> +				goto out;
> +
> +			if (wiov.max != 0) {
> +				/* CAIF does not use write descriptors */
> +				err = -EPROTO;
> +				goto out;
> +			}

This is probably a common case, so we should generate this error inside
vringh_getdesc (if wiov is NULL).

I'll do that too...

> +module_driver(caif_virtio_driver, register_virtio_driver,
> +	      unregister_virtio_driver);
> +MODULE_DEVICE_TABLE(virtio, id_table);

The comment on module_driver says:

 * Use this macro to construct bus specific macros for registering
 * drivers, and do not use it on its own.

Want to send me a patch to define module_virtio_driver?

Thanks!
Rusty.
