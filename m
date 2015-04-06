From: Oleksij Rempel <linux-YEK0n+YFykbzxQdaRaTXBw@public.gmane.org>
Subject: Re: [PATCH] ath9k_htc: check seq number instead of cmd id for timeout
Date: Mon, 06 Apr 2015 12:01:28 +0200
Message-ID: <55225978.6050903@rempel-privat.de>
References: <1426235558-13787-1-git-send-email-fred.chou.nd@gmail.com> <552228AB.8060000@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="VFEVunLR3NdP5bRgi3e7UFcRc052OnrGG"
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ath9k-devel-xDcbHBWguxHbcTqmT+pZeQ@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Fred Chou <fred.chou.nd-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, ath9k-devel-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org,
	kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <552228AB.8060000-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--VFEVunLR3NdP5bRgi3e7UFcRc052OnrGG
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hi Kalle,

can you please apply this patch.

Am 06.04.2015 um 08:33 schrieb Fred Chou:
> Hi all,
>=20
> May I have an update on the patch status please?
>=20
> Thanks and regards,
> Fred
>=20
> On 13/3/2015 4:32 PM, Fred Chou wrote:
>> From: Fred Chou <fred.chou.nd-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>>
>> As the driver may send multiple wmi commands with identical cmd id,
>> it is more robust to check seq number for timeout instead.
>>
>> Signed-off-by: Fred Chou <fred.chou.nd-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> ---
>>  drivers/net/wireless/ath/ath9k/wmi.c | 12 ++++++------
>>  drivers/net/wireless/ath/ath9k/wmi.h |  2 +-
>>  2 files changed, 7 insertions(+), 7 deletions(-)
>>
>> diff --git a/drivers/net/wireless/ath/ath9k/wmi.c b/drivers/net/wirele=
ss/ath/ath9k/wmi.c
>> index 65c8894..aba909f 100644
>> --- a/drivers/net/wireless/ath/ath9k/wmi.c
>> +++ b/drivers/net/wireless/ath/ath9k/wmi.c
>> @@ -224,7 +224,7 @@ static void ath9k_wmi_ctrl_rx(void *priv, struct s=
k_buff *skb,
>> =20
>>  	/* Check if there has been a timeout. */
>>  	spin_lock(&wmi->wmi_lock);
>> -	if (cmd_id !=3D wmi->last_cmd_id) {
>> +	if (be16_to_cpu(hdr->seq_no) !=3D wmi->last_seq_id) {
>>  		spin_unlock(&wmi->wmi_lock);
>>  		goto free_skb;
>>  	}
>> @@ -272,11 +272,16 @@ static int ath9k_wmi_cmd_issue(struct wmi *wmi,
>>  			       enum wmi_cmd_id cmd, u16 len)
>>  {
>>  	struct wmi_cmd_hdr *hdr;
>> +	unsigned long flags;
>> =20
>>  	hdr =3D (struct wmi_cmd_hdr *) skb_push(skb, sizeof(struct wmi_cmd_h=
dr));
>>  	hdr->command_id =3D cpu_to_be16(cmd);
>>  	hdr->seq_no =3D cpu_to_be16(++wmi->tx_seq_id);
>> =20
>> +	spin_lock_irqsave(&wmi->wmi_lock, flags);
>> +	wmi->last_seq_id =3D wmi->tx_seq_id;
>> +	spin_unlock_irqrestore(&wmi->wmi_lock, flags);
>> +
>>  	return htc_send_epid(wmi->htc, skb, wmi->ctrl_epid);
>>  }
>> =20
>> @@ -292,7 +297,6 @@ int ath9k_wmi_cmd(struct wmi *wmi, enum wmi_cmd_id=
 cmd_id,
>>  	struct sk_buff *skb;
>>  	u8 *data;
>>  	int time_left, ret =3D 0;
>> -	unsigned long flags;
>> =20
>>  	if (ah->ah_flags & AH_UNPLUGGED)
>>  		return 0;
>> @@ -320,10 +324,6 @@ int ath9k_wmi_cmd(struct wmi *wmi, enum wmi_cmd_i=
d cmd_id,
>>  	wmi->cmd_rsp_buf =3D rsp_buf;
>>  	wmi->cmd_rsp_len =3D rsp_len;
>> =20
>> -	spin_lock_irqsave(&wmi->wmi_lock, flags);
>> -	wmi->last_cmd_id =3D cmd_id;
>> -	spin_unlock_irqrestore(&wmi->wmi_lock, flags);
>> -
>>  	ret =3D ath9k_wmi_cmd_issue(wmi, skb, cmd_id, cmd_len);
>>  	if (ret)
>>  		goto out;
>> diff --git a/drivers/net/wireless/ath/ath9k/wmi.h b/drivers/net/wirele=
ss/ath/ath9k/wmi.h
>> index 0db37f2..2aad6dc 100644
>> --- a/drivers/net/wireless/ath/ath9k/wmi.h
>> +++ b/drivers/net/wireless/ath/ath9k/wmi.h
>> @@ -143,7 +143,7 @@ struct wmi {
>>  	enum htc_endpoint_id ctrl_epid;
>>  	struct mutex op_mutex;
>>  	struct completion cmd_wait;
>> -	enum wmi_cmd_id last_cmd_id;
>> +	u16 last_seq_id;
>>  	struct sk_buff_head wmi_event_queue;
>>  	struct tasklet_struct wmi_event_tasklet;
>>  	u16 tx_seq_id;
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20


--=20
Regards,
Oleksij


--VFEVunLR3NdP5bRgi3e7UFcRc052OnrGG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iF4EAREIAAYFAlUiWYEACgkQHwImuRkmbWlS3wD/Xf9kTClFI6u+5CkwfMyL7h/y
e9/QrlTRxWALplSddoUA/2vfqYV92JCSzQFNW3ZPFLWjtAE9Xu7q/qfXb8bglEz/
=PyJZ
-----END PGP SIGNATURE-----

--VFEVunLR3NdP5bRgi3e7UFcRc052OnrGG--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
