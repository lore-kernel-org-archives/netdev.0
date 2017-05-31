From: Michael =?UTF-8?B?QsO8c2No?= <m@bues.ch>
Subject: Re: [PATCH] b43legacy: Fix a sleep-in-atomic bug in
 b43legacy_op_bss_info_changed
Date: Wed, 31 May 2017 17:32:15 +0200
Message-ID: <20170531173107.25eeda48@wiggum>
References: <1496225353-5544-1-git-send-email-baijiaju1990@163.com>
 <877f0xnwyk.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/bJgH0wfHcTj06dYHMXr80o9"; protocol="application/pgp-signature"
Cc: Jia-Ju Bai <baijiaju1990@163.com>, netdev@vger.kernel.org,
        linux-wireless@vger.kernel.org, b43-dev@lists.infradead.org,
        linux-kernel@vger.kernel.org, Larry.Finger@lwfinger.net
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <877f0xnwyk.fsf@kamboji.qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/bJgH0wfHcTj06dYHMXr80o9
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 31 May 2017 13:26:43 +0300
Kalle Valo <kvalo@codeaurora.org> wrote:

> Jia-Ju Bai <baijiaju1990@163.com> writes:
>=20
> > The driver may sleep under a spin lock, and the function call path is:
> > b43legacy_op_bss_info_changed (acquire the lock by spin_lock_irqsave)
> >   b43legacy_synchronize_irq
> >     synchronize_irq --> may sleep
> >
> > To fix it, the lock is released before b43legacy_synchronize_irq, and t=
he=20
> > lock is acquired again after this function.
> >
> > Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>
> > ---
> >  drivers/net/wireless/broadcom/b43legacy/main.c |    2 ++
> >  1 file changed, 2 insertions(+)
> >
> > diff --git a/drivers/net/wireless/broadcom/b43legacy/main.c b/drivers/n=
et/wireless/broadcom/b43legacy/main.c
> > index f1e3dad..31ead21 100644
> > --- a/drivers/net/wireless/broadcom/b43legacy/main.c
> > +++ b/drivers/net/wireless/broadcom/b43legacy/main.c
> > @@ -2859,7 +2859,9 @@ static void b43legacy_op_bss_info_changed(struct =
ieee80211_hw *hw,
> >  	b43legacy_write32(dev, B43legacy_MMIO_GEN_IRQ_MASK, 0);
> > =20
> >  	if (changed & BSS_CHANGED_BSSID) {
> > +		spin_unlock_irqrestore(&wl->irq_lock, flags);
> >  		b43legacy_synchronize_irq(dev);
> > +		spin_lock_irqsave(&wl->irq_lock, flags); =20
>=20
> To me this looks like a fragile workaround and not a real fix. You can
> easily add new race conditions with releasing the lock like this.
>=20


I think releasing the lock possibly is fine. It certainly is better than
sleeping with a lock held.
We disabled the device interrupts just before this line.

However I think the synchronize_irq should be outside of the
conditional right after the write to B43legacy_MMIO_GEN_IRQ_MASK. (So
two lines above)
I don't think it makes sense to only synchronize if BSS_CHANGED_BSSID
is set.


On the other hand b43 does not have this irq-disabling foobar anymore.
So somebody must have removed it. Maybe you can find the commit that
removed this stuff from b43 and port it to b43legacy?


So I would vote for moving the synchronize_irq up outside of the
conditional and put the unlock/lock sequence around it.
And as a second patch on top of that try to remove this stuff
altogether like b43 did.

--=20
Michael

--Sig_/bJgH0wfHcTj06dYHMXr80o9
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEihRzkKVZOnT2ipsS9TK+HZCNiw4FAlku4f8ACgkQ9TK+HZCN
iw64Kw/+N0S9zSacevNX4mgwvqPGIDwN7o8izrkRy/kxsRiTvbUvi9yZj0ffI/9V
pHNNWY/ib1OdV0upbDxW0Rqq5V2OnS5/6hQHNvKKEv+RB70kbpq0sTZi/jLqLedT
NM/YqKO/OACjAbT1jx0YlZzeKQkfp5lvd1avL1wwVkFcjSFVAJ/9TnR/4cOWst2R
G2zT5SveEAMpOhxlYN/4SA1vpszdW9CzQqBwviVzDA18uRAisrLY+pvIUfRKaj0e
GuWpeBC2uFy99ovaaLBk7teEcnRMrqDCgaZOCUsm7ilfkcPxmUPrzBC6aJhGwkRk
ge5DyyC98Nn5fY+o6ExUd7a7Cfcug990gjSx1TkJxTGujHP/FSJbZ+glstueQ9Yl
BAuUEfI7r/W+J6eid3u+T+bYZrY1E5Mc8DrNOR9u8+pmm8Hjp4nucTdZJ436SYW3
3PpC+WhsyGtlPl7sOHLdv98itsGMB2qU2T2loi9+4LfxCrJrTpzEgt07lusCWje5
01Oh6ilj6kBXL93633/ynLab2rt0zFnvx9Y/2OSRofSxIe9p6b1fcsmmiJNra7WV
3c1ExJphTV0u+UTZpn5fVAYGT8mt6bMjbAdmnbW8iQIsc86BEmIbAf63yUC4rwSU
PYggfb7vC69BZjHZsizfo070RqCu5b8t4F/8KtVAVEGv1SBMlb4=
=0/6l
-----END PGP SIGNATURE-----

--Sig_/bJgH0wfHcTj06dYHMXr80o9--
