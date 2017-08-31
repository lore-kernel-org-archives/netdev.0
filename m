From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH 24/25] net/cdc_ncm: Replace tasklet with softirq hrtimer
Date: Thu, 31 Aug 2017 15:57:04 +0200
Message-ID: <87mv6fzvpr.fsf@miraculix.mork.no>
References: <20170831105725.809317030@linutronix.de>
        <20170831105827.479650817@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: LKML <linux-kernel@vger.kernel.org>,
        Peter Zijlstra <peterz@infradead.org>,
        Ingo Molnar <mingo@redhat.com>,
        Christoph Hellwig <hch@lst.org>, keescook@chromium.org,
        John Stultz <john.stultz@linaro.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Oliver Neukum <oliver@neukum.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: Anna-Maria Gleixner <anna-maria@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170831105827.479650817@linutronix.de> (Anna-Maria Gleixner's
        message of "Thu, 31 Aug 2017 12:23:46 -0000")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Anna-Maria Gleixner <anna-maria@linutronix.de> writes:

> From: Thomas Gleixner <tglx@linutronix.de>
>
> The bh tasklet is used in invoke the hrtimer (cdc_ncm_tx_timer_cb) in
> softirq context. This can be also achieved without the tasklet but with
> CLOCK_MONOTONIC_SOFT as hrtimer base.
>
> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
> Signed-off-by: Anna-Maria Gleixner <anna-maria@linutronix.de>
> Cc: Oliver Neukum <oliver@neukum.org>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: linux-usb@vger.kernel.org
> Cc: netdev@vger.kernel.org
> ---
>  drivers/net/usb/cdc_ncm.c   |   37 ++++++++++++++++---------------------
>  include/linux/usb/cdc_ncm.h |    2 +-
>  2 files changed, 17 insertions(+), 22 deletions(-)
>
> --- a/drivers/net/usb/cdc_ncm.c
> +++ b/drivers/net/usb/cdc_ncm.c
> @@ -61,7 +61,6 @@ static bool prefer_mbim;
>  module_param(prefer_mbim, bool, S_IRUGO | S_IWUSR);
>  MODULE_PARM_DESC(prefer_mbim, "Prefer MBIM setting on dual NCM/MBIM func=
tions");
>=20=20
> -static void cdc_ncm_txpath_bh(unsigned long param);
>  static void cdc_ncm_tx_timeout_start(struct cdc_ncm_ctx *ctx);
>  static enum hrtimer_restart cdc_ncm_tx_timer_cb(struct hrtimer *hr_timer=
);
>  static struct usb_driver cdc_ncm_driver;
> @@ -777,10 +776,9 @@ int cdc_ncm_bind_common(struct usbnet *d
>  	if (!ctx)
>  		return -ENOMEM;
>=20=20
> -	hrtimer_init(&ctx->tx_timer, CLOCK_MONOTONIC, HRTIMER_MODE_REL);
> +	hrtimer_init(&ctx->tx_timer, CLOCK_MONOTONIC_SOFT, HRTIMER_MODE_REL);
>  	ctx->tx_timer.function =3D &cdc_ncm_tx_timer_cb;
> -	ctx->bh.data =3D (unsigned long)dev;
> -	ctx->bh.func =3D cdc_ncm_txpath_bh;
> +	ctx->usbnet =3D dev;
>  	atomic_set(&ctx->stop, 0);
>  	spin_lock_init(&ctx->mtx);
>=20=20
> @@ -967,10 +965,7 @@ void cdc_ncm_unbind(struct usbnet *dev,
>=20=20
>  	atomic_set(&ctx->stop, 1);
>=20=20
> -	if (hrtimer_active(&ctx->tx_timer))
> -		hrtimer_cancel(&ctx->tx_timer);
> -
> -	tasklet_kill(&ctx->bh);
> +	hrtimer_cancel(&ctx->tx_timer);
>=20=20
>  	/* handle devices with combined control and data interface */
>  	if (ctx->control =3D=3D ctx->data)
> @@ -1348,20 +1343,9 @@ static void cdc_ncm_tx_timeout_start(str
>  				HRTIMER_MODE_REL);
>  }
>=20=20
> -static enum hrtimer_restart cdc_ncm_tx_timer_cb(struct hrtimer *timer)
> +static void cdc_ncm_txpath_bh(struct cdc_ncm_ctx *ctx)
>  {
> -	struct cdc_ncm_ctx *ctx =3D
> -			container_of(timer, struct cdc_ncm_ctx, tx_timer);
> -
> -	if (!atomic_read(&ctx->stop))
> -		tasklet_schedule(&ctx->bh);
> -	return HRTIMER_NORESTART;
> -}
> -
> -static void cdc_ncm_txpath_bh(unsigned long param)
> -{
> -	struct usbnet *dev =3D (struct usbnet *)param;
> -	struct cdc_ncm_ctx *ctx =3D (struct cdc_ncm_ctx *)dev->data[0];
> +	struct usbnet *dev =3D ctx->usbnet;
>=20=20
>  	spin_lock_bh(&ctx->mtx);
>  	if (ctx->tx_timer_pending !=3D 0) {
> @@ -1379,6 +1363,17 @@ static void cdc_ncm_txpath_bh(unsigned l
>  	}
>  }
>=20=20
> +static enum hrtimer_restart cdc_ncm_tx_timer_cb(struct hrtimer *timer)
> +{
> +	struct cdc_ncm_ctx *ctx =3D
> +			container_of(timer, struct cdc_ncm_ctx, tx_timer);
> +
> +	if (!atomic_read(&ctx->stop))
> +		cdc_ncm_txpath_bh(ctx);
> +
> +	return HRTIMER_NORESTART;
> +}
> +
>  struct sk_buff *
>  cdc_ncm_tx_fixup(struct usbnet *dev, struct sk_buff *skb, gfp_t flags)
>  {
> --- a/include/linux/usb/cdc_ncm.h
> +++ b/include/linux/usb/cdc_ncm.h
> @@ -92,7 +92,6 @@
>  struct cdc_ncm_ctx {
>  	struct usb_cdc_ncm_ntb_parameters ncm_parm;
>  	struct hrtimer tx_timer;
> -	struct tasklet_struct bh;
>=20=20
>  	const struct usb_cdc_ncm_desc *func_desc;
>  	const struct usb_cdc_mbim_desc *mbim_desc;
> @@ -101,6 +100,7 @@ struct cdc_ncm_ctx {
>=20=20
>  	struct usb_interface *control;
>  	struct usb_interface *data;
> +	struct usbnet *usbnet;
>=20=20
>  	struct sk_buff *tx_curr_skb;
>  	struct sk_buff *tx_rem_skb;




I believe the struct usbnet pointer is redundant.  We already have lots
of pointers back and forth here.  This should work, but is not tested:

	struct usbnet *dev =3D usb_get_intfdata(ctx->control):




Bj=C3=B8rn
