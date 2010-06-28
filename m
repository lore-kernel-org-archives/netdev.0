From: Antonio Ospite <ospite@studenti.unina.it>
Subject: Re: [PATCH 1/1] Bluetooth: hidp: Add support for hidraw
 HIDIOCGFEATURE and HIDIOCSFEATURE
Date: Mon, 28 Jun 2010 13:14:37 +0200
Message-ID: <20100628131437.bde782b6.ospite@studenti.unina.it>
References: <1276467601-9066-1-git-send-email-alan@signal11.us>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Mon__28_Jun_2010_13_14_37_+0200_OQk=OOM=ZhgZ4zM+"
Cc: Marcel Holtmann <marcel@holtmann.org>,
	David S Miller <davem@davemloft.net>,
	Jiri Kosina <jkosina@suse.cz>,
	Michael Poole <mdpoole@troilus.org>,
	Bastien Nocera <hadess@hadess.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	linux-bluetooth@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Alan Ott <alan@signal11.us>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1276467601-9066-1-git-send-email-alan@signal11.us>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__28_Jun_2010_13_14_37_+0200_OQk=OOM=ZhgZ4zM+
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, 13 Jun 2010 18:20:01 -0400
Alan Ott <alan@signal11.us> wrote:

> This patch adds support or getting and setting feature reports for blueto=
oth
> HID devices from HIDRAW.
>=20
> Signed-off-by: Alan Ott <alan@signal11.us>
> ---

Ping.

>  net/bluetooth/hidp/core.c |  121 +++++++++++++++++++++++++++++++++++++++=
++++--
>  net/bluetooth/hidp/hidp.h |    8 +++
>  2 files changed, 125 insertions(+), 4 deletions(-)
>=20
> diff --git a/net/bluetooth/hidp/core.c b/net/bluetooth/hidp/core.c
> index bfe641b..0f068a0 100644
> --- a/net/bluetooth/hidp/core.c
> +++ b/net/bluetooth/hidp/core.c
> @@ -36,6 +36,7 @@
>  #include <linux/file.h>
>  #include <linux/init.h>
>  #include <linux/wait.h>
> +#include <linux/mutex.h>
>  #include <net/sock.h>
> =20
>  #include <linux/input.h>
> @@ -313,6 +314,93 @@ static int hidp_send_report(struct hidp_session *ses=
sion, struct hid_report *rep
>  	return hidp_queue_report(session, buf, rsize);
>  }
> =20
> +static int hidp_get_raw_report(struct hid_device *hid,
> +		unsigned char report_number,
> +		unsigned char *data, size_t count,
> +		unsigned char report_type)
> +{
> +	struct hidp_session *session =3D hid->driver_data;
> +	struct sk_buff *skb;
> +	size_t len;
> +	int numbered_reports =3D hid->report_enum[report_type].numbered;
> +
> +	switch (report_type) {
> +	case HID_FEATURE_REPORT:
> +		report_type =3D HIDP_TRANS_GET_REPORT | HIDP_DATA_RTYPE_FEATURE;
> +		break;
> +	case HID_INPUT_REPORT:
> +		report_type =3D HIDP_TRANS_GET_REPORT | HIDP_DATA_RTYPE_INPUT;
> +		break;
> +	case HID_OUTPUT_REPORT:
> +		report_type =3D HIDP_TRANS_GET_REPORT | HIDP_DATA_RTYPE_OUPUT;
> +		break;
> +	default:
> +		return -EINVAL;
> +	}
> +
> +	if (mutex_lock_interruptible(&session->report_mutex))
> +		return -ERESTARTSYS;
> +
> +	/* Set up our wait, and send the report request to the device. */
> +	session->waiting_report_type =3D report_type & HIDP_DATA_RTYPE_MASK;
> +	session->waiting_report_number =3D numbered_reports ? report_number : -=
1;
> +	set_bit(HIDP_WAITING_FOR_RETURN, &session->flags);
> +	data[0] =3D report_number;
> +	if (hidp_send_ctrl_message(hid->driver_data, report_type, data, 1))
> +		goto err_eio;
> +
> +	/* Wait for the return of the report. The returned report
> +	   gets put in session->report_return.  */
> +	while (test_bit(HIDP_WAITING_FOR_RETURN, &session->flags)) {
> +		int res;
> +
> +		res =3D wait_event_interruptible_timeout(session->report_queue,
> +			!test_bit(HIDP_WAITING_FOR_RETURN, &session->flags),
> +			5*HZ);
> +		if (res =3D=3D 0) {
> +			/* timeout */
> +			goto err_eio;
> +		}
> +		if (res < 0) {
> +			/* signal */
> +			goto err_restartsys;
> +		}
> +	}
> +
> +	skb =3D session->report_return;
> +	if (skb) {
> +		if (numbered_reports) {
> +			/* Strip off the report number. */
> +			size_t rpt_len =3D skb->len-1;
> +			len =3D rpt_len < count ? rpt_len : count;
> +			memcpy(data, skb->data+1, len);
> +		} else {
> +			len =3D skb->len < count ? skb->len : count;
> +			memcpy(data, skb->data, len);
> +		}
> +
> +		kfree_skb(skb);
> +		session->report_return =3D NULL;
> +	} else {
> +		/* Device returned a HANDSHAKE, indicating  protocol error. */
> +		len =3D -EIO;
> +	}
> +
> +	clear_bit(HIDP_WAITING_FOR_RETURN, &session->flags);
> +	mutex_unlock(&session->report_mutex);
> +
> +	return len;
> +
> +err_restartsys:
> +	clear_bit(HIDP_WAITING_FOR_RETURN, &session->flags);
> +	mutex_unlock(&session->report_mutex);
> +	return -ERESTARTSYS;
> +err_eio:
> +	clear_bit(HIDP_WAITING_FOR_RETURN, &session->flags);
> +	mutex_unlock(&session->report_mutex);
> +	return -EIO;
> +}
> +
>  static int hidp_output_raw_report(struct hid_device *hid, unsigned char =
*data, size_t count,
>  		unsigned char report_type)
>  {
> @@ -367,6 +455,10 @@ static void hidp_process_handshake(struct hidp_sessi=
on *session,
>  	case HIDP_HSHK_ERR_INVALID_REPORT_ID:
>  	case HIDP_HSHK_ERR_UNSUPPORTED_REQUEST:
>  	case HIDP_HSHK_ERR_INVALID_PARAMETER:
> +		if (test_bit(HIDP_WAITING_FOR_RETURN, &session->flags)) {
> +			clear_bit(HIDP_WAITING_FOR_RETURN, &session->flags);
> +			wake_up_interruptible(&session->report_queue);
> +		}
>  		/* FIXME: Call into SET_ GET_ handlers here */
>  		break;
> =20
> @@ -403,9 +495,11 @@ static void hidp_process_hid_control(struct hidp_ses=
sion *session,
>  	}
>  }
> =20
> -static void hidp_process_data(struct hidp_session *session, struct sk_bu=
ff *skb,
> +/* Returns true if the passed-in skb should be freed by the caller. */
> +static int hidp_process_data(struct hidp_session *session, struct sk_buf=
f *skb,
>  				unsigned char param)
>  {
> +	int done_with_skb =3D 1;
>  	BT_DBG("session %p skb %p len %d param 0x%02x", session, skb, skb->len,=
 param);
> =20
>  	switch (param) {
> @@ -417,7 +511,6 @@ static void hidp_process_data(struct hidp_session *se=
ssion, struct sk_buff *skb,
> =20
>  		if (session->hid)
>  			hid_input_report(session->hid, HID_INPUT_REPORT, skb->data, skb->len,=
 0);
> -
>  		break;
> =20
>  	case HIDP_DATA_RTYPE_OTHER:
> @@ -429,12 +522,27 @@ static void hidp_process_data(struct hidp_session *=
session, struct sk_buff *skb,
>  		__hidp_send_ctrl_message(session,
>  			HIDP_TRANS_HANDSHAKE | HIDP_HSHK_ERR_INVALID_PARAMETER, NULL, 0);
>  	}
> +
> +	if (test_bit(HIDP_WAITING_FOR_RETURN, &session->flags) &&
> +				param =3D=3D session->waiting_report_type) {
> +		if (session->waiting_report_number < 0 ||
> +		    session->waiting_report_number =3D=3D skb->data[0]) {
> +			/* hidp_get_raw_report() is waiting on this report. */
> +			session->report_return =3D skb;
> +			done_with_skb =3D 0;
> +			clear_bit(HIDP_WAITING_FOR_RETURN, &session->flags);
> +			wake_up_interruptible(&session->report_queue);
> +		}
> +	}
> +
> +	return done_with_skb;
>  }
> =20
>  static void hidp_recv_ctrl_frame(struct hidp_session *session,
>  					struct sk_buff *skb)
>  {
>  	unsigned char hdr, type, param;
> +	int free_skb =3D 1;
> =20
>  	BT_DBG("session %p skb %p len %d", session, skb, skb->len);
> =20
> @@ -454,7 +562,7 @@ static void hidp_recv_ctrl_frame(struct hidp_session =
*session,
>  		break;
> =20
>  	case HIDP_TRANS_DATA:
> -		hidp_process_data(session, skb, param);
> +		free_skb =3D hidp_process_data(session, skb, param);
>  		break;
> =20
>  	default:
> @@ -463,7 +571,8 @@ static void hidp_recv_ctrl_frame(struct hidp_session =
*session,
>  		break;
>  	}
> =20
> -	kfree_skb(skb);
> +	if (free_skb)
> +		kfree_skb(skb);
>  }
> =20
>  static void hidp_recv_intr_frame(struct hidp_session *session,
> @@ -797,6 +906,7 @@ static int hidp_setup_hid(struct hidp_session *sessio=
n,
>  	hid->dev.parent =3D hidp_get_device(session);
>  	hid->ll_driver =3D &hidp_hid_driver;
> =20
> +	hid->hid_get_raw_report =3D hidp_get_raw_report;
>  	hid->hid_output_raw_report =3D hidp_output_raw_report;
> =20
>  	err =3D hid_add_device(hid);
> @@ -857,6 +967,9 @@ int hidp_add_connection(struct hidp_connadd_req *req,=
 struct socket *ctrl_sock,
>  	skb_queue_head_init(&session->ctrl_transmit);
>  	skb_queue_head_init(&session->intr_transmit);
> =20
> +	mutex_init(&session->report_mutex);
> +	init_waitqueue_head(&session->report_queue);
> +
>  	session->flags   =3D req->flags & (1 << HIDP_BLUETOOTH_VENDOR_ID);
>  	session->idle_to =3D req->idle_to;
> =20
> diff --git a/net/bluetooth/hidp/hidp.h b/net/bluetooth/hidp/hidp.h
> index 8d934a1..00e71dd 100644
> --- a/net/bluetooth/hidp/hidp.h
> +++ b/net/bluetooth/hidp/hidp.h
> @@ -80,6 +80,7 @@
>  #define HIDP_VIRTUAL_CABLE_UNPLUG	0
>  #define HIDP_BOOT_PROTOCOL_MODE		1
>  #define HIDP_BLUETOOTH_VENDOR_ID	9
> +#define	HIDP_WAITING_FOR_RETURN		10
> =20
>  struct hidp_connadd_req {
>  	int   ctrl_sock;	// Connected control socket
> @@ -154,6 +155,13 @@ struct hidp_session {
>  	struct sk_buff_head ctrl_transmit;
>  	struct sk_buff_head intr_transmit;
> =20
> +	/* Used in hidp_get_raw_report() */
> +	int waiting_report_type; /* HIDP_DATA_RTYPE_* */
> +	int waiting_report_number; /* -1 for not numbered */
> +	struct mutex report_mutex;
> +	struct sk_buff *report_return;
> +	wait_queue_head_t report_queue;
> +
>  	/* Report descriptor */
>  	__u8 *rd_data;
>  	uint rd_size;
> --=20
> 1.7.0.4
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-bluetooth=
" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20


--=20
Antonio Ospite
http://ao2.it

PGP public key ID: 0x4553B001

A: Because it messes up the order in which people normally read text.
   See http://en.wikipedia.org/wiki/Posting_style
Q: Why is top-posting such a bad thing?
A: Top-posting.
Q: What is the most annoying thing in e-mail?

--Signature=_Mon__28_Jun_2010_13_14_37_+0200_OQk=OOM=ZhgZ4zM+
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAkwohB0ACgkQ5xr2akVTsAE1PACeI6ztolqbLXMmvfjfbwcT71yg
3GkAn1LnmR0uasFV7E5pCz6OzlPGv6hN
=clQF
-----END PGP SIGNATURE-----

--Signature=_Mon__28_Jun_2010_13_14_37_+0200_OQk=OOM=ZhgZ4zM+--
