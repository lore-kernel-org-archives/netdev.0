From: Michael =?UTF-8?B?QsO8c2No?= <m@bues.ch>
Subject: Re: [PATCH] b43legacy: Fix a sleep-in-atomic bug in
 b43legacy_op_bss_info_changed
Date: Thu, 1 Jun 2017 07:29:15 +0200
Message-ID: <20170601072839.2ca1b791@wiggum>
References: <1496225353-5544-1-git-send-email-baijiaju1990@163.com>
 <877f0xnwyk.fsf@kamboji.qca.qualcomm.com>
 <20170531173107.25eeda48@wiggum>
 <878tlcmixj.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/Fy4IExmBx0Pu=.YHT.z005I"; protocol="application/pgp-signature"
Cc: Jia-Ju Bai <baijiaju1990@163.com>, netdev@vger.kernel.org,
        linux-wireless@vger.kernel.org, b43-dev@lists.infradead.org,
        linux-kernel@vger.kernel.org, Larry.Finger@lwfinger.net
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <878tlcmixj.fsf@kamboji.qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/Fy4IExmBx0Pu=.YHT.z005I
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Thu, 01 Jun 2017 07:27:20 +0300
Kalle Valo <kvalo@codeaurora.org> wrote:

> Michael B=C3=BCsch <m@bues.ch> writes:
>=20
> >> > --- a/drivers/net/wireless/broadcom/b43legacy/main.c
> >> > +++ b/drivers/net/wireless/broadcom/b43legacy/main.c
> >> > @@ -2859,7 +2859,9 @@ static void b43legacy_op_bss_info_changed(stru=
ct ieee80211_hw *hw,
> >> >  	b43legacy_write32(dev, B43legacy_MMIO_GEN_IRQ_MASK, 0);
> >> > =20
> >> >  	if (changed & BSS_CHANGED_BSSID) {
> >> > +		spin_unlock_irqrestore(&wl->irq_lock, flags);
> >> >  		b43legacy_synchronize_irq(dev);
> >> > +		spin_lock_irqsave(&wl->irq_lock, flags);   =20
> >>=20
> >> To me this looks like a fragile workaround and not a real fix. You can
> >> easily add new race conditions with releasing the lock like this.
> >>  =20
> >
> >
> > I think releasing the lock possibly is fine. It certainly is better than
> > sleeping with a lock held. =20
>=20
> Sure, but IMHO in general I think the practise of releasing the lock
> like this in a middle of function is dangerous as one can easily miss
> that upper and lower halves of the function are not actually atomic
> anymore. And in this case that it's under a conditional makes it even
> worse.
>=20


Yes in general I agree. Releasing and re-acquiring a lock is dangerous.
But I think in this special case here it might be harmless.
The irq_lock is used mostly (if not exclusively; I don't fully
remember) to protect against the IRQ top and bottom half.
But we disabled the device IRQs a line above and the purpose of this
synchronize is to make sure the handler will finish and thus make
dropping the lock save.
Of course it does not make sense to do this with the lock held :)

--=20
Michael

--Sig_/Fy4IExmBx0Pu=.YHT.z005I
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEihRzkKVZOnT2ipsS9TK+HZCNiw4FAlkvpisACgkQ9TK+HZCN
iw4B2xAAq9OX19qlK1kp+DCJaqkipfO2eyNPOay9FK959w3IW5hJ60F/t9KHQLlK
Xf2rThwvyjgawfg2Ep3Dd3Vr8BLLMo4XA3F3MmUd0+79nDugLah3zKD5bfmFoOz+
rOhChMtU0gwPMvxwqitJAnCbxASekGQ9fvD4bqkXyQnXvqpNWzXBjw/sxkmeMOcD
nJsgsh+1PMLmLhSNmdwcy/Xd1rWzARNkSZrbyFpJ3na/6VBif9luIQ4nuvTIs1fB
Z9CSKB+t1r081e3QHalLH6m0Wi/eeZs0q2ro2QotHmSTajZIeDmZr6jknm8r2tcA
ednfzCLNvNdvRXm7CRqPqu4nz6O5lFZkkQxIKH1++sJd+Ox7LKbwKKGBmABZOTL9
ySUNi29F4sLtz6SVDsPU3nIxrhy4tY44SCANqzIB/dtVH0dC1S9+QtubaQVlJmKg
rVAWjF/NYA+iXQxbXB7XdJq+wXRDsgPR0zqtydMM2N388g3+/u952ewEG8IoYuWB
VWHUyI+o9RyTyiMiQTTlaUji8Bpu/CeLlW7twWM2MopepbRXK3HbowvjZISbvwy8
klv9MfMJp3wqOXA/vDRhRCBXOrKOJUPh6XcA5gr1eG7o39K1/ElGKcevg4KN74np
o+XWorgnCQJCI8KeQM4hBwOL2Ohs/bCz+cgfffZJyQvlnH8ZjZA=
=6iBW
-----END PGP SIGNATURE-----

--Sig_/Fy4IExmBx0Pu=.YHT.z005I--
