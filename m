From: Oleksij Rempel <linux@rempel-privat.de>
Subject: Re: [PATCHv2] ath9k_htc: add adaptive usb receive
 flow control to repair soft lockup with monitor mode
Date: Mon, 16 Feb 2015 13:25:08 +0100
Message-ID: <54E1E1A4.4020803@rempel-privat.de>
References: <1423528464-8433-1-git-send-email-yuweizheng@139.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0877317292=="
Cc: netdev@vger.kernel.org
To: Yuwei Zheng <yuweizheng@139.com>, linux-kernel@vger.kernel.org,
	ath9k-devel@lists.ath9k.org, linux-wireless@vger.kernel.org,
	kvalo@codeaurora.org, ath9k-devel@qca.qualcomm.com
Return-path: <ath9k-devel-bounces@lists.ath9k.org>
In-Reply-To: <1423528464-8433-1-git-send-email-yuweizheng@139.com>
List-Unsubscribe: <https://lists.ath9k.org/mailman/listinfo/ath9k-devel>,
	<mailto:ath9k-devel-request@lists.ath9k.org?subject=unsubscribe>
List-Archive: <http://lists.ath9k.org/pipermail/ath9k-devel>
List-Post: <mailto:ath9k-devel@lists.ath9k.org>
List-Help: <mailto:ath9k-devel-request@lists.ath9k.org?subject=help>
List-Subscribe: <https://lists.ath9k.org/mailman/listinfo/ath9k-devel>,
	<mailto:ath9k-devel-request@lists.ath9k.org?subject=subscribe>
Mime-version: 1.0
Sender: ath9k-devel-bounces@lists.ath9k.org
Errors-To: ath9k-devel-bounces@lists.ath9k.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--===============0877317292==
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="FIRdOUuKBjApOvdxWa1cDEbI3iSV1HjHV"

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--FIRdOUuKBjApOvdxWa1cDEbI3iSV1HjHV
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Do every one OK with this patch? I think this one is the last version?

Am 10.02.2015 um 01:34 schrieb Yuwei Zheng:
> The ath9k_hif_usb_rx_cb function excute on  the interrupt context, and =
ath9k_rx_tasklet excute
> on the soft irq context. In other words, the ath9k_hif_usb_rx_cb have m=
ore chance to excute than
> ath9k_rx_tasklet.  So in the worst condition,  the rx.rxbuf receive lis=
t is always full,
> and the do {}while(true) loop will not be break. The kernel get a soft =
lockup panic.=20
> =20
> [59011.007210] BUG: soft lockup - CPU#0 stuck for 23s!
> [kworker/0:0:30609]
> [59011.030560] BUG: scheduling while atomic: kworker/0:0/30609/0x400101=
00
> [59013.804486] BUG: scheduling while atomic: kworker/0:0/30609/0x400101=
00
> [59013.858522] Kernel panic - not syncing: softlockup: hung tasks
> =20
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
> =20
> This bug can be see with low performance board, such as uniprocessor be=
agle bone board. Add some debug=20
> message in the ath9k_hif_usb_rx_cb function may trigger this bug quickl=
y.
> =20
> Signed-off-by: Yuwei Zheng <yuweizheng@139.com>
> ---
> Changes since v1:
> - Add aurfc_active flag to stop delayed submit while ath9k_hif_usb_deal=
loc_rx_urbs called.
> - Add spinlock aurfc_lock to protect aurfc_delayed_work and aurfc_activ=
e.
> - Add mod_delayed_work to trigger aurfc_submit_handler excuted immediat=
ely while rx_buf list is empty.=20
> - Add flush_delayed_work to wait the aurfc_submit_handler finish.
>=20
>  drivers/net/wireless/ath/ath9k/hif_usb.c       | 78 ++++++++++++++++++=
+++++---
>  drivers/net/wireless/ath/ath9k/hif_usb.h       | 13 +++++
>  drivers/net/wireless/ath/ath9k/htc.h           | 19 +++++++
>  drivers/net/wireless/ath/ath9k/htc_drv_debug.c | 53 +++++++++++++++++
>  drivers/net/wireless/ath/ath9k/htc_drv_txrx.c  | 58 ++++++++++++++++++=
+
>  5 files changed, 214 insertions(+), 7 deletions(-)
>=20
> diff --git a/drivers/net/wireless/ath/ath9k/hif_usb.c b/drivers/net/wir=
eless/ath/ath9k/hif_usb.c
> index 8e7153b..2e73e19 100644
> --- a/drivers/net/wireless/ath/ath9k/hif_usb.c
> +++ b/drivers/net/wireless/ath/ath9k/hif_usb.c
> @@ -640,6 +640,7 @@ static void ath9k_hif_usb_rx_cb(struct urb *urb)
>  	struct hif_device_usb *hif_dev =3D
>  		usb_get_intfdata(usb_ifnum_to_if(urb->dev, 0));
>  	int ret;
> +	int delay;
> =20
>  	if (!skb)
>  		return;
> @@ -658,7 +659,6 @@ static void ath9k_hif_usb_rx_cb(struct urb *urb)
>  	default:
>  		goto resubmit;
>  	}
> -
>  	if (likely(urb->actual_length !=3D 0)) {
>  		skb_put(skb, urb->actual_length);
>  		ath9k_hif_usb_rx_stream(hif_dev, skb);
> @@ -667,12 +667,23 @@ static void ath9k_hif_usb_rx_cb(struct urb *urb)
>  resubmit:
>  	skb_reset_tail_pointer(skb);
>  	skb_trim(skb, 0);
> -
> -	usb_anchor_urb(urb, &hif_dev->rx_submitted);
> -	ret =3D usb_submit_urb(urb, GFP_ATOMIC);
> -	if (ret) {
> -		usb_unanchor_urb(urb);
> -		goto free;
> +	spin_lock(&hif_dev->aurfc_lock);
> +	/* submit the urb more slowly for flow control */
> +	if (atomic_read(&hif_dev->aurfc_submit_delay) > 0 &&
> +	    hif_dev->aurfc_active =3D=3D 1) {
> +		usb_anchor_urb(urb, &hif_dev->rx_delayed_submitted);
> +		delay =3D atomic_read(&hif_dev->aurfc_submit_delay);
> +		schedule_delayed_work(&hif_dev->aurfc_delayed_work,
> +				      msecs_to_jiffies(delay));
> +		spin_unlock(&hif_dev->aurfc_lock);
> +	} else {
> +		spin_unlock(&hif_dev->aurfc_lock);
> +		usb_anchor_urb(urb, &hif_dev->rx_submitted);
> +		ret =3D usb_submit_urb(urb, GFP_ATOMIC);
> +		if (ret) {
> +			usb_unanchor_urb(urb);
> +			goto free;
> +		}
>  	}
> =20
>  	return;
> @@ -818,9 +829,53 @@ err:
>  	return -ENOMEM;
>  }
> =20
> +static void aurfc_submit_handler(struct work_struct *work)
> +{
> +	struct hif_device_usb *hif_dev =3D
> +		container_of(work,
> +			     struct hif_device_usb,
> +			     aurfc_delayed_work.work);
> +	struct urb *urb =3D NULL;
> +	struct sk_buff *skb =3D NULL;
> +	int ret;
> +	int loop_times =3D 0;
> +
> +	AURFC_STAT_INC(aurfc_called);
> +	while (true) {
> +		loop_times++;
> +		if (loop_times > MAX_RX_URB_NUM)
> +			atomic_add(AURFC_STEP,
> +				   &hif_dev->aurfc_submit_delay);
> +
> +		urb =3D usb_get_from_anchor(
> +				&hif_dev->rx_delayed_submitted);
> +		if (urb) {
> +			skb =3D (struct sk_buff *)urb->context;
> +			ret =3D usb_submit_urb(urb, GFP_KERNEL);
> +			if (ret !=3D 0) {
> +				usb_unanchor_urb(urb);
> +				dev_kfree_skb_any(skb);
> +				urb->context =3D NULL;
> +			}
> +		} else {
> +			break;
> +		}
> +	}
> +}
> +
>  static void ath9k_hif_usb_dealloc_rx_urbs(struct hif_device_usb *hif_d=
ev)
>  {
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&hif_dev->aurfc_lock, flags);
> +	hif_dev->aurfc_active =3D 0;
> +	/* excute the last queued work immediately */
> +	mod_delayed_work(system_wq, &hif_dev->aurfc_delayed_work, 0);
> +	spin_unlock_irqrestore(&hif_dev->aurfc_lock, flags);
> +	/* wait the last work finish, otherwise kill urbs may deadlock*/
> +	flush_delayed_work(&hif_dev->aurfc_delayed_work);
>  	usb_kill_anchored_urbs(&hif_dev->rx_submitted);
> +	usb_kill_anchored_urbs(&hif_dev->rx_delayed_submitted);
>  }
> =20
>  static int ath9k_hif_usb_alloc_rx_urbs(struct hif_device_usb *hif_dev)=

> @@ -830,8 +885,17 @@ static int ath9k_hif_usb_alloc_rx_urbs(struct hif_=
device_usb *hif_dev)
>  	int i, ret;
> =20
>  	init_usb_anchor(&hif_dev->rx_submitted);
> +	init_usb_anchor(&hif_dev->rx_delayed_submitted);
> +
>  	spin_lock_init(&hif_dev->rx_lock);
> =20
> +	/* add for adaptive usb receive flow control*/
> +	atomic_set(&hif_dev->aurfc_submit_delay, 0);
> +	INIT_DELAYED_WORK(&hif_dev->aurfc_delayed_work,
> +			  aurfc_submit_handler);
> +	spin_lock_init(&hif_dev->aurfc_lock);
> +	hif_dev->aurfc_active =3D 1;
> +
>  	for (i =3D 0; i < MAX_RX_URB_NUM; i++) {
> =20
>  		/* Allocate URB */
> diff --git a/drivers/net/wireless/ath/ath9k/hif_usb.h b/drivers/net/wir=
eless/ath/ath9k/hif_usb.h
> index 51496e7..2ff59be 100644
> --- a/drivers/net/wireless/ath/ath9k/hif_usb.h
> +++ b/drivers/net/wireless/ath/ath9k/hif_usb.h
> @@ -41,6 +41,7 @@
>  #define MAX_RX_URB_NUM  8
>  #define MAX_RX_BUF_SIZE 16384
>  #define MAX_PKT_NUM_IN_TRANSFER 10
> +#define AURFC_STEP 70  /* millisecond */
> =20
>  #define MAX_REG_OUT_URB_NUM  1
>  #define MAX_REG_IN_URB_NUM   64
> @@ -98,9 +99,21 @@ struct hif_device_usb {
>  	struct hif_usb_tx tx;
>  	struct usb_anchor regout_submitted;
>  	struct usb_anchor rx_submitted;
> +	/* anchor delayed urb */
> +	struct usb_anchor rx_delayed_submitted;
>  	struct usb_anchor reg_in_submitted;
>  	struct usb_anchor mgmt_submitted;
>  	struct sk_buff *remain_skb;
> +
> +	/* adaptive usb receive flow control */
> +	struct delayed_work aurfc_delayed_work;
> +	/* to protect the delayed work */
> +	spinlock_t aurfc_lock;
> +	/* urb submit delay, in millisecond */
> +	atomic_t  aurfc_submit_delay;
> +	/* set to 1, if the urb can be delayed submit */
> +	int aurfc_active;
> +
>  	const char *fw_name;
>  	int rx_remain_len;
>  	int rx_pkt_len;
> diff --git a/drivers/net/wireless/ath/ath9k/htc.h b/drivers/net/wireles=
s/ath/ath9k/htc.h
> index 9dde265..1586bd2 100644
> --- a/drivers/net/wireless/ath/ath9k/htc.h
> +++ b/drivers/net/wireless/ath/ath9k/htc.h
> @@ -331,6 +331,13 @@ static inline struct ath9k_htc_tx_ctl *HTC_SKB_CB(=
struct sk_buff *skb)
> =20
>  #define TX_QSTAT_INC(q) (priv->debug.tx_stats.queue_stats[q]++)
> =20
> +#define AURFC_STAT_INC(c) \
> +	(hif_dev->htc_handle->drv_priv->debug.aurfc_stats.c++)
> +#define AURFC_STAT_ADD(c, a) \
> +	(hif_dev->htc_handle->drv_priv->debug.aurfc_stats.c +=3D a)
> +#define AURFC_STAT_SET(c, a) \
> +	(hif_dev->htc_handle->drv_priv->debug.aurfc_stats.c =3D a)
> +
>  void ath9k_htc_err_stat_rx(struct ath9k_htc_priv *priv,
>  			   struct ath_rx_status *rs);
> =20
> @@ -352,11 +359,20 @@ struct ath_skbrx_stats {
>  	u32 skb_dropped;
>  };
> =20
> +struct ath_aurfc_stats {
> +	u32 aurfc_highwater;
> +	u32 aurfc_lowwater;
> +	u32 aurfc_wm_triggered;
> +	u32 aurfc_submit_delay;
> +	u32 aurfc_called;
> +};
> +
>  struct ath9k_debug {
>  	struct dentry *debugfs_phy;
>  	struct ath_tx_stats tx_stats;
>  	struct ath_rx_stats rx_stats;
>  	struct ath_skbrx_stats skbrx_stats;
> +	struct ath_aurfc_stats aurfc_stats;
>  };
> =20
>  void ath9k_htc_get_et_strings(struct ieee80211_hw *hw,
> @@ -377,6 +393,9 @@ void ath9k_htc_get_et_stats(struct ieee80211_hw *hw=
,
> =20
>  #define TX_QSTAT_INC(c) do { } while (0)
> =20
> +#define AURFC_STAT_INC(c) do {} while (0)
> +#define AURFC_STAT_ADD(c, a) do {} while (0)
> +#define AURFC_STAT_SET(c, a) do {} while (0)
>  static inline void ath9k_htc_err_stat_rx(struct ath9k_htc_priv *priv,
>  					 struct ath_rx_status *rs)
>  {
> diff --git a/drivers/net/wireless/ath/ath9k/htc_drv_debug.c b/drivers/n=
et/wireless/ath/ath9k/htc_drv_debug.c
> index 8cef1ed..a6be9be 100644
> --- a/drivers/net/wireless/ath/ath9k/htc_drv_debug.c
> +++ b/drivers/net/wireless/ath/ath9k/htc_drv_debug.c
> @@ -286,6 +286,54 @@ static const struct file_operations fops_skb_rx =3D=
 {
>  	.llseek =3D default_llseek,
>  };
> =20
> +static ssize_t read_file_aurfc(struct file *file,
> +			       char __user *user_buf,
> +			       size_t count, loff_t *ppos)
> +{
> +	struct ath9k_htc_priv *priv =3D file->private_data;
> +	char *buf;
> +	unsigned int len =3D 0, size =3D 1500;
> +	ssize_t retval =3D 0;
> +
> +	buf =3D kzalloc(size, GFP_KERNEL);
> +	if (!buf)
> +		return -ENOMEM;
> +
> +	len +=3D scnprintf(buf + len, size - len,
> +			"%20s : %10u\n", "High watermark",
> +			priv->debug.aurfc_stats.aurfc_highwater);
> +	len +=3D scnprintf(buf + len, size - len,
> +			"%20s : %10u\n", "Low watermark",
> +			priv->debug.aurfc_stats.aurfc_lowwater);
> +
> +	len +=3D scnprintf(buf + len, size - len,
> +			"%20s : %10u\n", "WM triggered",
> +			priv->debug.aurfc_stats.aurfc_wm_triggered);
> +
> +	len +=3D scnprintf(buf + len, size - len,
> +			"%20s : %10u\n", "Handler called",
> +			priv->debug.aurfc_stats.aurfc_called);
> +
> +	len +=3D scnprintf(buf + len, size - len,
> +			"%20s : %10u\n", "Submit delay",
> +			priv->debug.aurfc_stats.aurfc_submit_delay);
> +	if (len > size)
> +		len =3D size;
> +
> +	retval =3D simple_read_from_buffer(user_buf, count,
> +					 ppos, buf, len);
> +	kfree(buf);
> +
> +	return retval;
> +}
> +
> +static const struct file_operations fops_aurfc =3D {
> +	.read =3D read_file_aurfc,
> +	.open =3D simple_open,
> +	.owner =3D THIS_MODULE,
> +	.llseek =3D default_llseek,
> +};
> +
>  static ssize_t read_file_slot(struct file *file, char __user *user_buf=
,
>  			      size_t count, loff_t *ppos)
>  {
> @@ -518,7 +566,12 @@ int ath9k_htc_init_debug(struct ath_hw *ah)
>  	debugfs_create_file("skb_rx", S_IRUSR, priv->debug.debugfs_phy,
>  			    priv, &fops_skb_rx);
> =20
> +	debugfs_create_file("aurfc_stats", S_IRUSR,
> +			    priv->debug.debugfs_phy,
> +			    priv, &fops_aurfc);
> +
>  	ath9k_cmn_debug_recv(priv->debug.debugfs_phy, &priv->debug.rx_stats);=

> +
>  	ath9k_cmn_debug_phy_err(priv->debug.debugfs_phy, &priv->debug.rx_stat=
s);
> =20
>  	debugfs_create_file("slot", S_IRUSR, priv->debug.debugfs_phy,
> diff --git a/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c b/drivers/ne=
t/wireless/ath/ath9k/htc_drv_txrx.c
> index a0f58e2..1c8ebc5 100644
> --- a/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c
> +++ b/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c
> @@ -1061,7 +1061,31 @@ void ath9k_rx_tasklet(unsigned long data)
>  	unsigned long flags;
>  	struct ieee80211_hdr *hdr;
> =20
> +	/* add for adaptive usb receive flow control*/
> +	int looptimes =3D 0;
> +	int highwatermark =3D ATH9K_HTC_RXBUF*3/4;
> +	int lowwatermark =3D ATH9K_HTC_RXBUF/32;
> +	unsigned int delay =3D 0;
> +
> +	struct htc_target *htc =3D priv->htc;
> +	struct hif_device_usb *hif_dev =3D htc->hif_dev;
> +
> +	AURFC_STAT_SET(aurfc_highwater, highwatermark);
> +	AURFC_STAT_SET(aurfc_lowwater, lowwatermark);
> +
>  	do {
> +		looptimes++;
> +		/* when trigger high wartermark, tell the
> +		 * urb callback to submit more slowlly.
> +		 */
> +		if (looptimes > highwatermark) {
> +			delay =3D looptimes*AURFC_STEP;
> +			atomic_set(&hif_dev->aurfc_submit_delay,
> +				   delay);
> +			AURFC_STAT_INC(aurfc_wm_triggered);
> +			AURFC_STAT_SET(aurfc_submit_delay, delay);
> +		}
> +
>  		spin_lock_irqsave(&priv->rx.rxbuflock, flags);
>  		list_for_each_entry(tmp_buf, &priv->rx.rxbuf, list) {
>  			if (tmp_buf->in_process) {
> @@ -1072,6 +1096,29 @@ void ath9k_rx_tasklet(unsigned long data)
> =20
>  		if (rxbuf =3D=3D NULL) {
>  			spin_unlock_irqrestore(&priv->rx.rxbuflock, flags);
> +			spin_lock_irqsave(&hif_dev->aurfc_lock,
> +					  flags);
> +			/* the rxbuf list is empty now, the
> +			 * queued work could be scheduled
> +			 * to submit urbs immediately.
> +			 */
> +			if (atomic_read(
> +				&hif_dev->aurfc_submit_delay) > 0 &&
> +			    hif_dev->aurfc_active > 0)
> +				mod_delayed_work(system_wq,
> +					&hif_dev->aurfc_delayed_work,
> +						 0);
> +			spin_unlock_irqrestore(&hif_dev->aurfc_lock,
> +					       flags);
> +			/* reset submit delay to guaranteed
> +			 * usb receive performance.
> +			 */
> +			if (looptimes < lowwatermark) {
> +				atomic_set(&hif_dev->aurfc_submit_delay
> +					   , 0);
> +				AURFC_STAT_SET(aurfc_submit_delay,
> +					       0);
> +			}
>  			break;
>  		}
> =20
> @@ -1114,6 +1161,10 @@ void ath9k_htc_rxep(void *drv_priv, struct sk_bu=
ff *skb,
>  	struct ath_common *common =3D ath9k_hw_common(ah);
>  	struct ath9k_htc_rxbuf *rxbuf =3D NULL, *tmp_buf =3D NULL;
> =20
> +	struct htc_target *htc =3D priv->htc;
> +	struct hif_device_usb *hif_dev =3D htc->hif_dev;
> +	int delay =3D ATH9K_HTC_RXBUF * AURFC_STEP;
> +
>  	spin_lock(&priv->rx.rxbuflock);
>  	list_for_each_entry(tmp_buf, &priv->rx.rxbuf, list) {
>  		if (!tmp_buf->in_process) {
> @@ -1124,6 +1175,13 @@ void ath9k_htc_rxep(void *drv_priv, struct sk_bu=
ff *skb,
>  	spin_unlock(&priv->rx.rxbuflock);
> =20
>  	if (rxbuf =3D=3D NULL) {
> +		/* The rxbuf list is full now, tell the urb callback
> +		 * to submit more slowly. Otherwise, the soft lockup
> +		 * may be triggerd immediately.
> +		 */
> +		atomic_set(&hif_dev->aurfc_submit_delay, delay);
> +		AURFC_STAT_INC(aurfc_wm_triggered);
> +		AURFC_STAT_SET(aurfc_submit_delay, delay);
>  		ath_dbg(common, ANY, "No free RX buffer\n");
>  		goto err;
>  	}
>=20


--=20
Regards,
Oleksij


--FIRdOUuKBjApOvdxWa1cDEbI3iSV1HjHV
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iF4EAREIAAYFAlTh4aQACgkQHwImuRkmbWlWGQD/bRaxoX0REtcB522sf6P72DUq
Y8EI/gwL46TvbDEy8VAA/i8ChWWiBSSGp5x/UAGAh10Wp9o+c5wZMT4ze6sV+N6r
=FCot
-----END PGP SIGNATURE-----

--FIRdOUuKBjApOvdxWa1cDEbI3iSV1HjHV--

--===============0877317292==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
ath9k-devel mailing list
ath9k-devel@lists.ath9k.org
https://lists.ath9k.org/mailman/listinfo/ath9k-devel

--===============0877317292==--
