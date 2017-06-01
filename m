From: Michael =?UTF-8?B?QsO8c2No?= <m@bues.ch>
Subject: Re: [PATCH] b43legacy: Fix a sleep-in-atomic bug in
 b43legacy_op_bss_info_changed
Date: Thu, 1 Jun 2017 07:31:36 +0200
Message-ID: <20170601073136.0b35368e@wiggum>
References: <1496225353-5544-1-git-send-email-baijiaju1990@163.com>
        <877f0xnwyk.fsf@kamboji.qca.qualcomm.com>
        <20170531173107.25eeda48@wiggum>
        <284d6d5d-d548-9e05-eafd-a6b521af5a04@lwfinger.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/BNa10aK/GYtxshAwCI0T3ht"; protocol="application/pgp-signature"
Cc: Kalle Valo <kvalo@codeaurora.org>,
        Jia-Ju Bai <baijiaju1990@163.com>, netdev@vger.kernel.org,
        linux-wireless@vger.kernel.org, b43-dev@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <284d6d5d-d548-9e05-eafd-a6b521af5a04@lwfinger.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/BNa10aK/GYtxshAwCI0T3ht
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Wed, 31 May 2017 19:07:15 -0500
Larry Finger <Larry.Finger@lwfinger.net> wrote:

> On 05/31/2017 10:32 AM, Michael B=C3=BCsch wrote:
> > On Wed, 31 May 2017 13:26:43 +0300
> > Kalle Valo <kvalo@codeaurora.org> wrote:
> >  =20
> >> Jia-Ju Bai <baijiaju1990@163.com> writes:
> >> =20
> >>> The driver may sleep under a spin lock, and the function call path is:
> >>> b43legacy_op_bss_info_changed (acquire the lock by spin_lock_irqsave)
> >>>    b43legacy_synchronize_irq
> >>>      synchronize_irq --> may sleep
> >>>
> >>> To fix it, the lock is released before b43legacy_synchronize_irq, and=
 the
> >>> lock is acquired again after this function.
> >>>
> >>> Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>
> >>> ---
> >>>   drivers/net/wireless/broadcom/b43legacy/main.c |    2 ++
> >>>   1 file changed, 2 insertions(+)
> >>>
> >>> diff --git a/drivers/net/wireless/broadcom/b43legacy/main.c b/drivers=
/net/wireless/broadcom/b43legacy/main.c
> >>> index f1e3dad..31ead21 100644
> >>> --- a/drivers/net/wireless/broadcom/b43legacy/main.c
> >>> +++ b/drivers/net/wireless/broadcom/b43legacy/main.c
> >>> @@ -2859,7 +2859,9 @@ static void b43legacy_op_bss_info_changed(struc=
t ieee80211_hw *hw,
> >>>   	b43legacy_write32(dev, B43legacy_MMIO_GEN_IRQ_MASK, 0);
> >>>  =20
> >>>   	if (changed & BSS_CHANGED_BSSID) {
> >>> +		spin_unlock_irqrestore(&wl->irq_lock, flags);
> >>>   		b43legacy_synchronize_irq(dev);
> >>> +		spin_lock_irqsave(&wl->irq_lock, flags); =20
> >>
> >> To me this looks like a fragile workaround and not a real fix. You can
> >> easily add new race conditions with releasing the lock like this.
> >> =20
> >=20
> >=20
> > I think releasing the lock possibly is fine. It certainly is better than
> > sleeping with a lock held.
> > We disabled the device interrupts just before this line.
> >=20
> > However I think the synchronize_irq should be outside of the
> > conditional right after the write to B43legacy_MMIO_GEN_IRQ_MASK. (So
> > two lines above)
> > I don't think it makes sense to only synchronize if BSS_CHANGED_BSSID
> > is set.
> >=20
> >=20
> > On the other hand b43 does not have this irq-disabling foobar anymore.
> > So somebody must have removed it. Maybe you can find the commit that
> > removed this stuff from b43 and port it to b43legacy?
> >=20
> >=20
> > So I would vote for moving the synchronize_irq up outside of the
> > conditional and put the unlock/lock sequence around it.
> > And as a second patch on top of that try to remove this stuff
> > altogether like b43 did. =20
>=20
> The patch that removed it in b43 is
>=20
> commit 36dbd9548e92268127b0c31b0e121e63e9207108
> Author: Michael Buesch <mb@bu3sch.de>
> Date:   Fri Sep 4 22:51:29 2009 +0200

Damn it :D

>      b43: Use a threaded IRQ handler
>=20
>      Use a threaded IRQ handler to allow locking the mutex and
>      sleeping while executing an interrupt.
>      This removes usage of the irq_lock spinlock, but introduces
>      a new hardirq_lock, which is _only_ used for the PCI/SSB lowlevel
>      hard-irq handler. Sleeping busses (SDIO) will use mutex instead.
>=20
>      Signed-off-by: Michael Buesch <mb@bu3sch.de>
>      Tested-by: Larry Finger <Larry.Finger@lwfinger.net>
>      Signed-off-by: John W. Linville <linville@tuxdriver.com>
>=20
> I vaguely remember this patch. Although it is roughly a 1000-line fix, I =
will=20
> try to port it to b43legacy. I still have an old BCM4306 PCMCIA card that=
 I can=20
> test in a PowerBook G4.
>=20
> I agree with Michael that this is the way to go. Both of Jia-Ju's patches=
 should=20
> be rejected.


I'm not sure if it's worth it. There is a risk that this would
introduce new bugs.
But sure, please feel free to try it. This way we can find out how big
this change becomes.

--=20
Michael

--Sig_/BNa10aK/GYtxshAwCI0T3ht
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEihRzkKVZOnT2ipsS9TK+HZCNiw4FAlkvprgACgkQ9TK+HZCN
iw61QA/+KQAxV3h295YF4SmDpwPp70J7kbff2o3xTm7RoJ/9Z1D6vI/fMkHStXaP
wPAXBnGdYuygyv5JsbvcV3HJa8P2bNSVd/HiEe6bgGEWIxrboMRkhYX/wumJxqCU
MatL1Ggrps8v/O4VqzGU2V7Y+43su2D9OKGxo2kVtBP+mfO2dZpoTByo3ZP3qVyB
mhw+IpRbeB5eQRro0/uUjvflyIraD41TigyfcLQe+986WTo5snHRC2dtO1Yd5E5y
7Tszic+JMv5lxa+zl4MW+DPZL+aNI2ozLVMfVQUIZwHNf7gzZfqTGkgCTgV9v/JL
J7LXT92eyFEUgyO5e7kqZrsxcuounR1nAMNkOABCWgGbUD9LqmkC885VJyulyvg+
6F8MRM/dYh3rNxLvo1pLWVQC4Os1XL/4pjcD8Gc2y+f0wtQ+5HeBuPKMwn1Is5yw
5BhT7VTasjR9Zw+Y2vXMNSDs0CKq7D7FlhVAgdM1gjK9UYi/eLiy4192S3MHCE/P
FJH/nNtB20qn1VScFGRpR0CjK5ecvM7LS4FOvfZzh2ztpbtagtEjpjwf5BDEeHuH
U36oDz4tobRAvJVZiCGCwBRgAl69Hsguk8qhWYYII3CxBzLljOBYcD61nkq/GeD7
KW2/yLHi3qRdeaUtENoeLv3tdk8YkBIvRlWqCcpP0yI8AEIgAWw=
=djbR
-----END PGP SIGNATURE-----

--Sig_/BNa10aK/GYtxshAwCI0T3ht--
