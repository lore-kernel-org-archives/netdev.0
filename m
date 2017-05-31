From: Michael =?UTF-8?B?QsO8c2No?= <m@bues.ch>
Subject: Re: [PATCH] b43legacy: Fix a sleep-in-atomic bug in
 b43legacy_attr_interfmode_store
Date: Wed, 31 May 2017 17:17:15 +0200
Message-ID: <20170531171715.58d6c084@wiggum>
References: <1496226547-5921-1-git-send-email-baijiaju1990@163.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/DYF4VkEf44uXT=vJAHo_HLf"; protocol="application/pgp-signature"
Cc: Larry.Finger@lwfinger.net, kvalo@codeaurora.org,
        netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
        b43-dev@lists.infradead.org, linux-kernel@vger.kernel.org
To: Jia-Ju Bai <baijiaju1990@163.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1496226547-5921-1-git-send-email-baijiaju1990@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/DYF4VkEf44uXT=vJAHo_HLf
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 31 May 2017 18:29:07 +0800
Jia-Ju Bai <baijiaju1990@163.com> wrote:

> The driver may sleep under a spin lock, and the function call path is:
> b43legacy_attr_interfmode_store (acquire the lock by spin_lock_irqsave)
>   b43legacy_radio_set_interference_mitigation
>     b43legacy_radio_interference_mitigation_disable
>       b43legacy_calc_nrssi_slope
>         b43legacy_synth_pu_workaround
>           might_sleep and msleep --> may sleep
>=20
> Fixing it may be complex, and a possible way is to remove=20
> spin_lock_irqsave and spin_lock_irqrestore in=20
> b43legacy_attr_interfmode_store, and the code has been protected by
> mutex_lock and mutex_unlock.
>=20
> Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>
> ---
>  drivers/net/wireless/broadcom/b43legacy/sysfs.c |    2 --
>  1 file changed, 2 deletions(-)
>=20
> diff --git a/drivers/net/wireless/broadcom/b43legacy/sysfs.c b/drivers/ne=
t/wireless/broadcom/b43legacy/sysfs.c
> index 2a1da15..9ede143 100644
> --- a/drivers/net/wireless/broadcom/b43legacy/sysfs.c
> +++ b/drivers/net/wireless/broadcom/b43legacy/sysfs.c
> @@ -137,14 +137,12 @@ static ssize_t b43legacy_attr_interfmode_store(stru=
ct device *dev,
>  	}
> =20
>  	mutex_lock(&wldev->wl->mutex);
> -	spin_lock_irqsave(&wldev->wl->irq_lock, flags);
> =20
>  	err =3D b43legacy_radio_set_interference_mitigation(wldev, mode);
>  	if (err)
>  		b43legacyerr(wldev->wl, "Interference Mitigation not "
>  		       "supported by device\n");
>  	mmiowb();
> -	spin_unlock_irqrestore(&wldev->wl->irq_lock, flags);
>  	mutex_unlock(&wldev->wl->mutex);
> =20
>  	return err ? err : count;


Interference mitigation has never been properly implemented and tested.
As such nobody should use it and I would be surprised if anybody uses
this attribute.
So I would suggest to remove this sysfs attribute entirely instead of
having this incorrect fix.

--=20
Michael

--Sig_/DYF4VkEf44uXT=vJAHo_HLf
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEihRzkKVZOnT2ipsS9TK+HZCNiw4FAlku3nsACgkQ9TK+HZCN
iw6XYg/+OL8og6Ss9XLnnaRISragtwTA4A5WefhpXV4eae5oxfHlkpJrs1RZDkGN
tBP7MrGQpCgpuNmEpAKe4OuAI7GXks4SSyWwfbUj/uxCI8UEB10GM4wYKRfSHOdC
ORxxx3/vPInaOF4eQ+5C5hHq7sGJI+7PC7QSVAz/4vJ160R2Y0ZZysu5zhRuNTqO
JwukqhqTGVUeUFc3Ys89cS6teE/GPaEkHmpJrW/2PztyQuMoPa6Qr1y9M9FVHnhl
BCrIR74oGJlC2SYQyykicAMZ/riSTrXKXdTJi4sVYOON4Ih8pAgtGYhqh1FNgF03
msshvjvnb6ILd/q9+7kB7CZ6ZP4qCzXXQ0lU2VPNdY3MFpym6MQEBFAdskF4T1S+
bpqnldFoUH1ER7/4kvdFdDvOnTdKrzjFDx2EmunZmfK0SDVAs/ZrHpPqzyCxL+GA
TYmHvthUGgxy1iq+dLL/DQb1UmGIaT9pii4p5YZhiYF9BqynskNu83CnZiRwe42h
kF9PPaxteApwXD3xhnEXsj3fH80ycUTGGRIPqFZql3GDvED9wP1BH500/6k29u4h
J2J3YEl2r7FWIwG5DbCkzvtAZs4W7M0ZDsu1JX5QggHZc8xRgyeSLAYu0tp3l11b
JkSAPHKZMz4x2sfZH+noaKZgONFeKBukKoYZhCAabaLi7/S+oUs=
=B5GJ
-----END PGP SIGNATURE-----

--Sig_/DYF4VkEf44uXT=vJAHo_HLf--
