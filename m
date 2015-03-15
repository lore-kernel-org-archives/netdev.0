From: Oleksij Rempel <linux@rempel-privat.de>
Subject: Re: [PATCH] ath9k_htc: check seq number instead of
	cmd id for timeout
Date: Sun, 15 Mar 2015 07:48:17 +0100
Message-ID: <55052B31.4020803@rempel-privat.de>
References: <1426235558-13787-1-git-send-email-fred.chou.nd@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2060691522=="
Cc: netdev@vger.kernel.org, ath9k-devel@lists.ath9k.org,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org
To: Fred Chou <fred.chou.nd@gmail.com>, ath9k-devel@qca.qualcomm.com,
	kvalo@codeaurora.org
Return-path: <ath9k-devel-bounces@lists.ath9k.org>
In-Reply-To: <1426235558-13787-1-git-send-email-fred.chou.nd@gmail.com>
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
--===============2060691522==
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="X2kSjw4swxlVuCG7NEiTi2EEvJ15vbOUK"

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--X2kSjw4swxlVuCG7NEiTi2EEvJ15vbOUK
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hi,

thank you for your patch. Looks good for me. Did you tested it?

Am 13.03.2015 um 09:32 schrieb Fred Chou:
> From: Fred Chou <fred.chou.nd@gmail.com>
>=20
> As the driver may send multiple wmi commands with identical cmd id,
> it is more robust to check seq number for timeout instead.
>=20
> Signed-off-by: Fred Chou <fred.chou.nd@gmail.com>
> ---
>  drivers/net/wireless/ath/ath9k/wmi.c | 12 ++++++------
>  drivers/net/wireless/ath/ath9k/wmi.h |  2 +-
>  2 files changed, 7 insertions(+), 7 deletions(-)
>=20
> diff --git a/drivers/net/wireless/ath/ath9k/wmi.c b/drivers/net/wireles=
s/ath/ath9k/wmi.c
> index 65c8894..aba909f 100644
> --- a/drivers/net/wireless/ath/ath9k/wmi.c
> +++ b/drivers/net/wireless/ath/ath9k/wmi.c
> @@ -224,7 +224,7 @@ static void ath9k_wmi_ctrl_rx(void *priv, struct sk=
_buff *skb,
> =20
>  	/* Check if there has been a timeout. */
>  	spin_lock(&wmi->wmi_lock);
> -	if (cmd_id !=3D wmi->last_cmd_id) {
> +	if (be16_to_cpu(hdr->seq_no) !=3D wmi->last_seq_id) {
>  		spin_unlock(&wmi->wmi_lock);
>  		goto free_skb;
>  	}
> @@ -272,11 +272,16 @@ static int ath9k_wmi_cmd_issue(struct wmi *wmi,
>  			       enum wmi_cmd_id cmd, u16 len)
>  {
>  	struct wmi_cmd_hdr *hdr;
> +	unsigned long flags;
> =20
>  	hdr =3D (struct wmi_cmd_hdr *) skb_push(skb, sizeof(struct wmi_cmd_hd=
r));
>  	hdr->command_id =3D cpu_to_be16(cmd);
>  	hdr->seq_no =3D cpu_to_be16(++wmi->tx_seq_id);
> =20
> +	spin_lock_irqsave(&wmi->wmi_lock, flags);
> +	wmi->last_seq_id =3D wmi->tx_seq_id;
> +	spin_unlock_irqrestore(&wmi->wmi_lock, flags);
> +
>  	return htc_send_epid(wmi->htc, skb, wmi->ctrl_epid);
>  }
> =20
> @@ -292,7 +297,6 @@ int ath9k_wmi_cmd(struct wmi *wmi, enum wmi_cmd_id =
cmd_id,
>  	struct sk_buff *skb;
>  	u8 *data;
>  	int time_left, ret =3D 0;
> -	unsigned long flags;
> =20
>  	if (ah->ah_flags & AH_UNPLUGGED)
>  		return 0;
> @@ -320,10 +324,6 @@ int ath9k_wmi_cmd(struct wmi *wmi, enum wmi_cmd_id=
 cmd_id,
>  	wmi->cmd_rsp_buf =3D rsp_buf;
>  	wmi->cmd_rsp_len =3D rsp_len;
> =20
> -	spin_lock_irqsave(&wmi->wmi_lock, flags);
> -	wmi->last_cmd_id =3D cmd_id;
> -	spin_unlock_irqrestore(&wmi->wmi_lock, flags);
> -
>  	ret =3D ath9k_wmi_cmd_issue(wmi, skb, cmd_id, cmd_len);
>  	if (ret)
>  		goto out;
> diff --git a/drivers/net/wireless/ath/ath9k/wmi.h b/drivers/net/wireles=
s/ath/ath9k/wmi.h
> index 0db37f2..2aad6dc 100644
> --- a/drivers/net/wireless/ath/ath9k/wmi.h
> +++ b/drivers/net/wireless/ath/ath9k/wmi.h
> @@ -143,7 +143,7 @@ struct wmi {
>  	enum htc_endpoint_id ctrl_epid;
>  	struct mutex op_mutex;
>  	struct completion cmd_wait;
> -	enum wmi_cmd_id last_cmd_id;
> +	u16 last_seq_id;
>  	struct sk_buff_head wmi_event_queue;
>  	struct tasklet_struct wmi_event_tasklet;
>  	u16 tx_seq_id;
>=20


--=20
Regards,
Oleksij


--X2kSjw4swxlVuCG7NEiTi2EEvJ15vbOUK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iF4EAREIAAYFAlUFKzEACgkQHwImuRkmbWkNgwD/b/oInlkxkZwK1QmPiUN90viv
SvwBtELSyKVcpx2nmA8A/0S1HTNkfPPTsV5OWi7gnH6yq69m6+XzczUhEITXsagk
=NHS5
-----END PGP SIGNATURE-----

--X2kSjw4swxlVuCG7NEiTi2EEvJ15vbOUK--

--===============2060691522==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
ath9k-devel mailing list
ath9k-devel@lists.ath9k.org
https://lists.ath9k.org/mailman/listinfo/ath9k-devel

--===============2060691522==--
