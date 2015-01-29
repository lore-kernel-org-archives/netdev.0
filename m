From: Oleksij Rempel <linux@rempel-privat.de>
Subject: Re: [ath9k-devel] [PATCH] Repair soft lockup with monitor mode of
 ath9k_htc card
Date: Thu, 29 Jan 2015 11:52:11 +0100
Message-ID: <54CA10DB.3070903@rempel-privat.de>
References: <1422504583-17839-1-git-send-email-zhengyuwei@360.cn>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="8udgjjvRtgR13A9GKIEKwH1BmPiB4otg5"
Cc: netdev@vger.kernel.org
To: zhengyuwei@360.cn, linux-kernel@vger.kernel.org,
	ath9k-devel@venema.h4ckr.net, linux-wireless@vger.kernel.org,
	kvalo@codeaurora.org, ath9k-devel@qca.qualcomm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1422504583-17839-1-git-send-email-zhengyuwei@360.cn>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--8udgjjvRtgR13A9GKIEKwH1BmPiB4otg5
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Am 29.01.2015 um 05:09 schrieb zhengyuwei@360.cn:
> From: Yuwei Zheng <zhengyuwei@360.cn>
>=20
> In the environment with heavy wifi traffic, set the ar9271 into monitor=
 mode, will
> trigger a deadloop panic.=20
>=20
> The ath9k_hif_usb_rx_cb function excute on  the interrupt context, and =
ath9k_rx_tasklet excute
> on the soft irq context. In other words, the ath9k_hif_usb_rx_cb have m=
ore chance to excute than
> ath9k_rx_tasklet.  So in the worst condition,  the rx.rxbuf receive lis=
t is always full,
> and the do {}while(true) loop will not be break. The kernel get a soft =
lockup panic. =20
>  =20
> [59011.007210] BUG: soft lockup - CPU#0 stuck for 23s!=20
> [kworker/0:0:30609]
> [59011.030560] BUG: scheduling while atomic: kworker/0:0/30609/0x400101=
00
> [59013.804486] BUG: scheduling while atomic: kworker/0:0/30609/0x400101=
00
> [59013.858522] Kernel panic - not syncing: softlockup: hung tasks
>=20
> [59014.038891] Exception stack(0xdf4bbc38 to 0xdf4bbc80)
> [59014.046834] bc20:                                                   =
    de57b950 60000113
> [59014.059579] bc40: 00000000 bb32bb32 60000113 de57b948 de57b500 dc7bb=
440 df4bbcd0 00000000
> [59014.072337] bc60: de57b950 60000113 df4bbcd0 df4bbc80 c04c259d c04c2=
5a0 60000133 ffffffff
> [59014.085233] [<c04c28db>] (__irq_svc+0x3b/0x5c) from [<c04c25a0>] (_r=
aw_spin_unlock_irqrestore+0xc/0x10)
> [59014.100437] [<c04c25a0>] (_raw_spin_unlock_irqrestore+0xc/0x10) from=
 [<bf9c2089>] (ath9k_rx_tasklet+0x290/0x490 [ath9k_htc])
> [59014.118267] [<bf9c2089>] (ath9k_rx_tasklet+0x290/0x490 [ath9k_htc]) =
from [<c0036d23>] (tasklet_action+0x3b/0x98)
> [59014.134132] [<c0036d23>] (tasklet_action+0x3b/0x98) from [<c0036709>=
] (__do_softirq+0x99/0x16c)
> [59014.147784] [<c0036709>] (__do_softirq+0x99/0x16c) from [<c00369f7>]=
 (irq_exit+0x5b/0x5c)
> [59014.160653] [<c00369f7>] (irq_exit+0x5b/0x5c) from [<c000cfc3>] (han=
dle_IRQ+0x37/0x78)
> [59014.173124] [<c000cfc3>] (handle_IRQ+0x37/0x78) from [<c00085df>] (o=
map3_intc_handle_irq+0x5f/0x68)
> [59014.187225] [<c00085df>] (omap3_intc_handle_irq+0x5f/0x68) from [<c0=
4c28db>](__irq_svc+0x3b/0x5c)
>=20
> This bug can be see with low performance board, such as uniprocessor be=
agle bone board.
> Signed-off-by: Yuwei Zheng <zhengyuwei@360.cn>
>=20
> ---
>  drivers/net/wireless/ath/ath9k/hif_usb.c       | 53 ++++++++++++++++++=
++++----
>  drivers/net/wireless/ath/ath9k/hif_usb.h       |  5 +++
>  drivers/net/wireless/ath/ath9k/htc.h           | 13 +++++++
>  drivers/net/wireless/ath/ath9k/htc_drv_debug.c | 49 ++++++++++++++++++=
++++++
>  drivers/net/wireless/ath/ath9k/htc_drv_txrx.c  | 26 +++++++++++++
>  5 files changed, 139 insertions(+), 7 deletions(-)

First of all, thank you for you work! :D

Please run ./scripts/checkpatch.pl yourpatch_path
i get:
total: 139 errors, 12 warnings, 2 checks, 231 lines checked

You use tasklet_hrtimer_start. So far i know, there is no this kind of
hrtimer which is actually hidden behind this word on this SoC.
Especially if requested value is any way in 1 millisecond range you
probably can and should use normal priority tasklet. (correct me if i'm
wrong)

> diff --git a/drivers/net/wireless/ath/ath9k/hif_usb.c b/drivers/net/wir=
eless/ath/ath9k/hif_usb.c
> index 8e7153b..febea5e 100644
> --- a/drivers/net/wireless/ath/ath9k/hif_usb.c
> +++ b/drivers/net/wireless/ath/ath9k/hif_usb.c
> @@ -658,7 +658,6 @@ static void ath9k_hif_usb_rx_cb(struct urb *urb)
>  	default:
>  		goto resubmit;
>  	}
> -
>  	if (likely(urb->actual_length !=3D 0)) {
>  		skb_put(skb, urb->actual_length);
>  		ath9k_hif_usb_rx_stream(hif_dev, skb);
> @@ -667,12 +666,18 @@ static void ath9k_hif_usb_rx_cb(struct urb *urb)
>  resubmit:
>  	skb_reset_tail_pointer(skb);
>  	skb_trim(skb, 0);
> -
> -	usb_anchor_urb(urb, &hif_dev->rx_submitted);
> -	ret =3D usb_submit_urb(urb, GFP_ATOMIC);
> -	if (ret) {
> -		usb_unanchor_urb(urb);
> -		goto free;
> +	if (atomic_read(&hif_dev->rx_urb_submit_delay) > 0) {
> +		usb_anchor_urb(urb, &hif_dev->rx_delayed_submitted);
> +		ret =3D tasklet_hrtimer_start(&hif_dev->rx_submit_timer,
> +					    ktime_set(0, atomic_read(&hif_dev->rx_urb_submit_delay)*1000)=
,
> +					    HRTIMER_MODE_REL);
> +	} else {
> +		usb_anchor_urb(urb, &hif_dev->rx_submitted);
> +		ret =3D usb_submit_urb(urb, GFP_ATOMIC);
> +		if (ret) {
> +			usb_unanchor_urb(urb);
> +			goto free;
> +		}
>  	}
> =20
>  	return;
> @@ -818,9 +823,37 @@ err:
>  	return -ENOMEM;
>  }
> =20
> +static enum hrtimer_restart rx_urb_submit_timer_handler(struct hrtimer=
 *me)
> +{
> +	struct tasklet_hrtimer *thr =3D container_of(me, struct tasklet_hrtim=
er, timer);
> +	struct  hif_device_usb *hif_dev =3D container_of(thr, struct hif_devi=
ce_usb, rx_submit_timer);
> +	struct urb *urb =3D NULL;
> +	struct sk_buff *skb =3D NULL;
> +	int ret;
> +
> +	while (true) {
> +		urb =3D usb_get_from_anchor(&hif_dev->rx_delayed_submitted);
> +		if (urb !=3D NULL) {
> +			skb =3D (struct sk_buff *)urb->context;
> +			ret =3D usb_submit_urb(urb, GFP_ATOMIC);
> +			if (ret !=3D -EBUSY) {
> +				usb_unanchor_urb(urb);
> +				dev_kfree_skb_any(skb);
> +				urb->context =3D NULL;
> +			}
> +		} else {
> +			break;
> +		}
> +	}
> +
> +	return HRTIMER_NORESTART;
> +}
> +
>  static void ath9k_hif_usb_dealloc_rx_urbs(struct hif_device_usb *hif_d=
ev)
>  {
>  	usb_kill_anchored_urbs(&hif_dev->rx_submitted);
> +	usb_kill_anchored_urbs(&hif_dev->rx_delayed_submitted);
> +	tasklet_hrtimer_cancel(&hif_dev->rx_submit_timer);
>  }
> =20
>  static int ath9k_hif_usb_alloc_rx_urbs(struct hif_device_usb *hif_dev)=

> @@ -830,6 +863,8 @@ static int ath9k_hif_usb_alloc_rx_urbs(struct hif_d=
evice_usb *hif_dev)
>  	int i, ret;
> =20
>  	init_usb_anchor(&hif_dev->rx_submitted);
> +	init_usb_anchor(&hif_dev->rx_delayed_submitted);
> +
>  	spin_lock_init(&hif_dev->rx_lock);
> =20
>  	for (i =3D 0; i < MAX_RX_URB_NUM; i++) {
> @@ -871,6 +906,10 @@ static int ath9k_hif_usb_alloc_rx_urbs(struct hif_=
device_usb *hif_dev)
>  		usb_free_urb(urb);
>  	}
> =20
> +	/* add for flow control*/
> +	atomic_set(&hif_dev->rx_urb_submit_delay, 0);
> +	tasklet_hrtimer_init(&hif_dev->rx_submit_timer, rx_urb_submit_timer_h=
andler, CLOCK_MONOTONIC, HRTIMER_MODE_REL);
> +
>  	return 0;
> =20
>  err_submit:
> diff --git a/drivers/net/wireless/ath/ath9k/hif_usb.h b/drivers/net/wir=
eless/ath/ath9k/hif_usb.h
> index 51496e7..56d6be8 100644
> --- a/drivers/net/wireless/ath/ath9k/hif_usb.h
> +++ b/drivers/net/wireless/ath/ath9k/hif_usb.h
> @@ -98,9 +98,14 @@ struct hif_device_usb {
>  	struct hif_usb_tx tx;
>  	struct usb_anchor regout_submitted;
>  	struct usb_anchor rx_submitted;
> +	struct usb_anchor rx_delayed_submitted; /* delayed submit anchor */
>  	struct usb_anchor reg_in_submitted;
>  	struct usb_anchor mgmt_submitted;
>  	struct sk_buff *remain_skb;
> +
> +	struct tasklet_hrtimer  rx_submit_timer;/* delayed submit hrtimer */
> +	atomic_t  rx_urb_submit_delay; /*us*/
> +
>  	const char *fw_name;
>  	int rx_remain_len;
>  	int rx_pkt_len;
> diff --git a/drivers/net/wireless/ath/ath9k/htc.h b/drivers/net/wireles=
s/ath/ath9k/htc.h
> index 9dde265..453d0a8 100644
> --- a/drivers/net/wireless/ath/ath9k/htc.h
> +++ b/drivers/net/wireless/ath/ath9k/htc.h
> @@ -331,6 +331,10 @@ static inline struct ath9k_htc_tx_ctl *HTC_SKB_CB(=
struct sk_buff *skb)
> =20
>  #define TX_QSTAT_INC(q) (priv->debug.tx_stats.queue_stats[q]++)
> =20
> +#define TASKLETRX_STAT_INC(c) (hif_dev->htc_handle->drv_priv->debug.ta=
skletrx_stats.c++)
> +#define TASKLETRX_STAT_ADD(c, a) (hif_dev->htc_handle->drv_priv->debug=
=2Etaskletrx_stats.c +=3D a)
> +#define TASKLETRX_STAT_SET(c, a) (hif_dev->htc_handle->drv_priv->debug=
=2Etaskletrx_stats.c =3D a)
> +
>  void ath9k_htc_err_stat_rx(struct ath9k_htc_priv *priv,
>  			   struct ath_rx_status *rs);
> =20
> @@ -352,11 +356,20 @@ struct ath_skbrx_stats {
>  	u32 skb_dropped;
>  };
> =20
> +struct ath_taskletrx_stats {
> +	u32 taskletrx_looptimes;
> +	u32 taskletrx_highwater;
> +	u32 taskletrx_lowwater;
> +	u32 taskletrx_watermark_triggered;
> +	u32 taskletrx_urb_submit_delay;
> +};
> +
>  struct ath9k_debug {
>  	struct dentry *debugfs_phy;
>  	struct ath_tx_stats tx_stats;
>  	struct ath_rx_stats rx_stats;
>  	struct ath_skbrx_stats skbrx_stats;
> +	struct ath_taskletrx_stats taskletrx_stats;
>  };
> =20
>  void ath9k_htc_get_et_strings(struct ieee80211_hw *hw,
> diff --git a/drivers/net/wireless/ath/ath9k/htc_drv_debug.c b/drivers/n=
et/wireless/ath/ath9k/htc_drv_debug.c
> index 8cef1ed..7c8322e 100644
> --- a/drivers/net/wireless/ath/ath9k/htc_drv_debug.c
> +++ b/drivers/net/wireless/ath/ath9k/htc_drv_debug.c
> @@ -286,6 +286,51 @@ static const struct file_operations fops_skb_rx =3D=
 {
>  	.llseek =3D default_llseek,
>  };
> =20
> +static ssize_t read_file_tasklet_rx(struct file *file, char __user *us=
er_buf,
> +				    size_t count, loff_t *ppos)
> +{
> +	struct ath9k_htc_priv *priv =3D file->private_data;
> +	char *buf;
> +	unsigned int len =3D 0, size =3D 1500;
> +	ssize_t retval =3D 0;
> +
> +	buf =3D kzalloc(size, GFP_KERNEL);
> +	if (buf =3D=3D NULL)
> +		return -ENOMEM;
> +
> +	len +=3D scnprintf(buf + len, size - len,
> +			"%20s : %10u\n", "Loop times",
> +			priv->debug.taskletrx_stats.taskletrx_looptimes);
> +	len +=3D scnprintf(buf + len, size - len,
> +			"%20s : %10u\n", "High watermark",
> +			priv->debug.taskletrx_stats.taskletrx_highwater);
> +	len +=3D scnprintf(buf + len, size - len,
> +			"%20s : %10u\n", "Low watermark",
> +			priv->debug.taskletrx_stats.taskletrx_lowwater);
> +
> +	len +=3D scnprintf(buf + len, size - len,
> +			"%20s : %10u\n", "WM triggered",
> +			priv->debug.taskletrx_stats.taskletrx_watermark_triggered);
> +
> +	len +=3D scnprintf(buf + len, size - len,
> +			"%20s : %10u\n", "URB delay",
> +			priv->debug.taskletrx_stats.taskletrx_urb_submit_delay);
> +	if (len > size)
> +		len =3D size;
> +
> +	retval =3D simple_read_from_buffer(user_buf, count, ppos, buf, len);
> +	kfree(buf);
> +
> +	return retval;
> +}
> +
> +static const struct file_operations fops_tasklet_rx =3D {
> +	.read =3D read_file_tasklet_rx,
> +	.open =3D simple_open,
> +	.owner =3D THIS_MODULE,
> +	.llseek =3D default_llseek,
> +};
> +
>  static ssize_t read_file_slot(struct file *file, char __user *user_buf=
,
>  			      size_t count, loff_t *ppos)
>  {
> @@ -518,7 +563,11 @@ int ath9k_htc_init_debug(struct ath_hw *ah)
>  	debugfs_create_file("skb_rx", S_IRUSR, priv->debug.debugfs_phy,
>  			    priv, &fops_skb_rx);
> =20
> +	debugfs_create_file("tasklet_rx", S_IRUSR, priv->debug.debugfs_phy,
> +			    priv, &fops_tasklet_rx);
> +
>  	ath9k_cmn_debug_recv(priv->debug.debugfs_phy, &priv->debug.rx_stats);=

> +
>  	ath9k_cmn_debug_phy_err(priv->debug.debugfs_phy, &priv->debug.rx_stat=
s);
> =20
>  	debugfs_create_file("slot", S_IRUSR, priv->debug.debugfs_phy,
> diff --git a/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c b/drivers/ne=
t/wireless/ath/ath9k/htc_drv_txrx.c
> index a0f58e2..f5e6217 100644
> --- a/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c
> +++ b/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c
> @@ -1061,7 +1061,28 @@ void ath9k_rx_tasklet(unsigned long data)
>  	unsigned long flags;
>  	struct ieee80211_hdr *hdr;
> =20
> +	/* add for adaptive flow control*/
> +	int looptimes =3D 0;
> +	int highwatermark =3D ATH9K_HTC_RXBUF*3/4;
> +	int lowwatermark =3D ATH9K_HTC_RXBUF/4;
> +	unsigned int delay =3D 0;
> +
> +	struct htc_target *htc =3D priv->htc;
> +	struct hif_device_usb *hif_dev =3D htc->hif_dev;
> +
> +	TASKLETRX_STAT_SET(taskletrx_highwater, highwatermark);
> +	TASKLETRX_STAT_SET(taskletrx_lowwater, lowwatermark);
> +
>  	do {
> +		looptimes++;
> +		TASKLETRX_STAT_SET(taskletrx_looptimes, looptimes);
> +		if (looptimes > highwatermark) {
> +			delay =3D looptimes*10;
> +			atomic_set(&hif_dev->rx_urb_submit_delay, delay);
> +			TASKLETRX_STAT_INC(taskletrx_watermark_triggered);
> +			TASKLETRX_STAT_SET(taskletrx_urb_submit_delay, delay);
> +		}
> +
>  		spin_lock_irqsave(&priv->rx.rxbuflock, flags);
>  		list_for_each_entry(tmp_buf, &priv->rx.rxbuf, list) {
>  			if (tmp_buf->in_process) {
> @@ -1072,6 +1093,11 @@ void ath9k_rx_tasklet(unsigned long data)
> =20
>  		if (rxbuf =3D=3D NULL) {
>  			spin_unlock_irqrestore(&priv->rx.rxbuflock, flags);
> +			if (looptimes < lowwatermark) {
> +				atomic_set(&hif_dev->rx_urb_submit_delay, 0);
> +				TASKLETRX_STAT_SET(taskletrx_urb_submit_delay, 0);
> +			}
> +
>  			break;
>  		}
> =20
>=20


--=20
Regards,
Oleksij


--8udgjjvRtgR13A9GKIEKwH1BmPiB4otg5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iF4EAREIAAYFAlTKEN8ACgkQHwImuRkmbWnoAwD7Brjn9WRalg+8bALx1EOtSe/w
+DIOziG3b4eXYI1gwbgA/Azmua3pKY0JVQijFn09M4kb+td946w5BDg2V2PAMdVB
=QNNZ
-----END PGP SIGNATURE-----

--8udgjjvRtgR13A9GKIEKwH1BmPiB4otg5--
