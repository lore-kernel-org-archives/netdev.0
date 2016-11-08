From: Corinna Vinschen <vinschen@redhat.com>
Subject: Re: [Intel-wired-lan] [PATCH] igb: use igb_adapter->io_addr instead
 of e1000_hw->hw_addr
Date: Tue, 8 Nov 2016 19:37:39 +0100
Message-ID: <20161108183739.GA3744@calimero.vinschen.de>
References: <1478588780-24480-1-git-send-email-caoj.fnst@cn.fujitsu.com>
 <20161108164214.GF31855@calimero.vinschen.de>
 <alpine.NEB.2.20.17.1611080910530.6177@chris.i8u.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="Nq2Wo0NMKNjxTN9z"
Cc: Cao jin <caoj.fnst@cn.fujitsu.com>, netdev@vger.kernel.org,
        intel-wired-lan@lists.osuosl.org, linux-kernel@vger.kernel.org,
        izumi.taku@jp.fujitsu.com
To: Hisashi T Fujinaka <htodd@twofifty.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.NEB.2.20.17.1611080910530.6177@chris.i8u.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--Nq2Wo0NMKNjxTN9z
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Nov  8 09:16, Hisashi T Fujinaka wrote:
> On Tue, 8 Nov 2016, Corinna Vinschen wrote:
> > On Nov  8 15:06, Cao jin wrote:
> > > When running as guest, under certain condition, it will oops as follo=
wing.
> > > writel() in igb_configure_tx_ring() results in oops, because hw->hw_a=
ddr
> > > is NULL. While other register access won't oops kernel because they u=
se
> > > wr32/rd32 which have a defense against NULL pointer.
> > > [...]
> >=20
> > Incidentally we're just looking for a solution to that problem too.
> > Do three patches to fix the same problem at rougly the same time already
> > qualify as freak accident?
> >=20
> > FTR, I attached my current patch, which I was planning to submit after
> > some external testing.
> >=20
> > However, all three patches have one thing in common:  They workaround
> > a somewhat dubious resetting of the hardware address to NULL in case
> > reading from a register failed.
> >=20
> > That makes me wonder if setting the hardware address to NULL in
> > rd32/igb_rd32 is really such a good idea.  It's performed in a function
> > which return value is *never* tested for validity in the calling
> > functions and leads to subsequent crashes since no tests for hw_addr =
=3D=3D
> > NULL are performed.
> >=20
> > Maybe commit 22a8b2915 should be reconsidered?  Isn't there some more
> > graceful way to handle the "surprise removal"?
>=20
> Answering this from my home account because, well, work is Outlook.
>=20
> "Reconsidering" would be great. In fact, revert if if you'd like. I'm
> uncertain that the surprise removal code actually works the way I
> thought previously and I think I took a lot of it out of my local code.
>=20
> Unfortuantely I don't have any equipment that I can use to reproduce
> surprise removal any longer so that means I wouldn't be able to test
> anything. I have to defer to you or Cao Jin.

I'm not too keen to rip out a PCIe NIC under power from my locale
desktop machine, but I think an actual surprise removal is not the
problem.

As described in my git log entry, the error condition in igb_rd32 can be
triggered during a suspend.  The HW has been put into a sleep state but
some register read requests are apparently not guarded against that
situation.  Reading a register in this state returns -1, thus a suspend
is erroneously triggering the "surprise removal" sequence.

Here's a raw idea:

- Note that device is suspended in e1000_hw struct.  Don't trigger
  error sequence in igb_rd32 if so (...and return a 0 value???)

- Otherwise assume it's actually a surprise removal.  In theory that
  should somehow trigger a device removal sequence, kind of like
  calling igb_remove, no?


Thanks,
Corinna

--Nq2Wo0NMKNjxTN9z
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJYIhtzAAoJEPU2Bp2uRE+gzYQP/iQKBTT1H1uzPdaWqoiD3D6U
gHB9YgKu8DAU5jH8spbwL/qHblpztml527tm1CDiZHlr9ItLAFt9MhRMWI0cSmrT
rI9g0Sx2kC0xm6W70AXkSJ9arZ9tZMBJcEMVGMmY17+3p5mE1ELnYXy/oWAVhC/2
Aey+RV5/wtAALGZl/dkw7v4l/tvot+5jGne7NS9ghi1j2O9knc3cT89TrMv0IoP+
vJHk5g7Yxl+/B8unWT/do/M4ZJyk86p0eq/A/Y93fUy7drKNPKBxs7JIX8/y6XgH
uYi6SUk/XCfnWn5FVNH4M06P87YvxQJVqWwXj3+qKIBPdfyCK7bD+cvC+WM6UnKT
lF0KfeGmz1sPcqg4SCUrhZ3al3ShHjX8If49Ml56wdGRauDjiycf5tr8Eth6sTgE
eWbfOy3yCGYO1OSGB+DuZhjVey5ZLCdjGsJ3EpSN0eDsVInSuy1c5pH+8TgPrQgT
v7reiq1LUbkmPMNKm3mbq54ac1rQ/MetfBBSgi/nwNw/hK2Yy3fzcfTDDIVHP4tI
5ZyAnSIVmS7EibpxUOrzqU6Q6iMGBq6nSyjITuZ0TXCJ6kyLJnruI7ny4jmfhxS4
WVGB4UQdW56ZslR+si6ro6YIugBAnrMaBB98K0OPMwBcuAWA08Ww4uJ6maCPUyvp
6c7DVN6pvcyekG7Pg3G3
=m3P4
-----END PGP SIGNATURE-----

--Nq2Wo0NMKNjxTN9z--
