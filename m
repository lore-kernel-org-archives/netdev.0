From: Corinna Vinschen <vinschen@redhat.com>
Subject: Re: [Intel-wired-lan] [PATCH] igb: use igb_adapter->io_addr instead
 of e1000_hw->hw_addr
Date: Thu, 10 Nov 2016 10:35:49 +0100
Message-ID: <20161110093549.GA24351@calimero.vinschen.de>
References: <1478588780-24480-1-git-send-email-caoj.fnst@cn.fujitsu.com>
 <20161108164214.GF31855@calimero.vinschen.de>
 <alpine.NEB.2.20.17.1611080910530.6177@chris.i8u.org>
 <20161108183739.GA3744@calimero.vinschen.de>
 <CAKgT0UeaoGfOOC1=h4pGk+=FDd5EqvgRGAdk1StLuiW1-M8tVA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="G4iJoqBmSsgzjUCe"
Cc: Hisashi T Fujinaka <htodd@twofifty.com>,
        Cao jin <caoj.fnst@cn.fujitsu.com>,
        Netdev <netdev@vger.kernel.org>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        =?utf-8?B?SXp1bWksIFRha3Uv5rOJIOaLkw==?=
        <izumi.taku@jp.fujitsu.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAKgT0UeaoGfOOC1=h4pGk+=FDd5EqvgRGAdk1StLuiW1-M8tVA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--G4iJoqBmSsgzjUCe
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Nov  8 11:33, Alexander Duyck wrote:
> On Tue, Nov 8, 2016 at 10:37 AM, Corinna Vinschen <vinschen@redhat.com> w=
rote:
> > On Nov  8 09:16, Hisashi T Fujinaka wrote:
> >> On Tue, 8 Nov 2016, Corinna Vinschen wrote:
> >> > On Nov  8 15:06, Cao jin wrote:
> >> > > When running as guest, under certain condition, it will oops as fo=
llowing.
> >> > > writel() in igb_configure_tx_ring() results in oops, because hw->h=
w_addr
> >> > > is NULL. While other register access won't oops kernel because the=
y use
> >> > > wr32/rd32 which have a defense against NULL pointer.
> >> > > [...]
> >> >
> >> > Incidentally we're just looking for a solution to that problem too.
> >> > Do three patches to fix the same problem at rougly the same time alr=
eady
> >> > qualify as freak accident?
> >> >
> >> > FTR, I attached my current patch, which I was planning to submit aft=
er
> >> > some external testing.
> >> >
> >> > However, all three patches have one thing in common:  They workaround
> >> > a somewhat dubious resetting of the hardware address to NULL in case
> >> > reading from a register failed.
> >> >
> >> > That makes me wonder if setting the hardware address to NULL in
> >> > rd32/igb_rd32 is really such a good idea.  It's performed in a funct=
ion
> >> > which return value is *never* tested for validity in the calling
> >> > functions and leads to subsequent crashes since no tests for hw_addr=
 =3D=3D
> >> > NULL are performed.
> >> >
> >> > Maybe commit 22a8b2915 should be reconsidered?  Isn't there some more
> >> > graceful way to handle the "surprise removal"?
> >>
> >> Answering this from my home account because, well, work is Outlook.
> >>
> >> "Reconsidering" would be great. In fact, revert if if you'd like. I'm
> >> uncertain that the surprise removal code actually works the way I
> >> thought previously and I think I took a lot of it out of my local code.
> >>
> >> Unfortuantely I don't have any equipment that I can use to reproduce
> >> surprise removal any longer so that means I wouldn't be able to test
> >> anything. I have to defer to you or Cao Jin.
> >
> > I'm not too keen to rip out a PCIe NIC under power from my locale
> > desktop machine, but I think an actual surprise removal is not the
> > problem.
> >
> > As described in my git log entry, the error condition in igb_rd32 can be
> > triggered during a suspend.  The HW has been put into a sleep state but
> > some register read requests are apparently not guarded against that
> > situation.  Reading a register in this state returns -1, thus a suspend
> > is erroneously triggering the "surprise removal" sequence.
>=20
> The question I would have is what is reading the device when it is in
> this state.  The watchdog and any other functions that would read the
> device should be disabled.
>=20
> One possibility could be a race between a call to igb_close and the
> igb_suspend function.  We have seen some of those pop up recently on
> ixgbe and it looks like igb has the same bug.  We should probably be
> using the rtnl_lock to guarantee that netif_device_detach and the call
> to __igb_close are completed before igb_close could possibly be called
> by the network stack.

Do you have a pointer to the related ixgbe patch, by any chance?

> > Here's a raw idea:
> >
> > - Note that device is suspended in e1000_hw struct.  Don't trigger
> >   error sequence in igb_rd32 if so (...and return a 0 value???)
>=20
> The thing is that a suspended device should not be accessed at all.
> If we are accessing it while it is suspended then that is a bug.  If
> you could throw a WARN_ON call in igb_rd32 to capture where this is
> being triggered that might be useful.
>=20
> > - Otherwise assume it's actually a surprise removal.  In theory that
> >   should somehow trigger a device removal sequence, kind of like
> >   calling igb_remove, no?
>=20
> Well a read of the MMIO region while suspended is more of a surprise
> read since there shouldn't be anything going on.  We need to isolate
> where that read is coming from and fix it.

That would be ideal, but the problem couldn't be reproduced yet apart
=66rom at a customer's customer site.  It's not clear yet if we can access
the machine for further testing.


Corinna

--G4iJoqBmSsgzjUCe
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJYJD91AAoJEPU2Bp2uRE+gLL4P/jT8Nit7wrmbLuaVmPfhaBU9
FgM8FK4jtY3CMcepOI8sJ7fwxAXK/Q3Xiu1vU0Rg1uXOTpnp7RkEncJ6llFuqjjT
EUfK/px1Cg3GYEEkxxss3xB2HbztPhje3NA2HeW3PBtsiKmQfSLLENbOZsnmJg56
DOycx19cmzyW9td1JD/hd9cU1IkNctr4uqI0a/fhGSp8fbn+y6boUGdeGZHMJRbG
LBMO63w+/sbEUenWmpOOlsbtIWoWSt/RDstDkm3n/wHv/3Huk2pVaJ2M1tAZw1F5
oXlSoA4Oqq3IbjC+Slbs3CwahIXec6QUDlT6y7LcijUoAF3dsz7x3r7e9++fMx2r
XzAdleVSvzXFG9BQBFdFqciHpqnM96qQAgSlU/3Om3xQj4O6lgszF5/zfPc2jjac
RndjybtNBwsSURNEHePFRlr0G+3mR7124YUi2kdUlal99HkI6kjw3NF17/ZieOGQ
ru7oj1kAsLoe9JbLzpxzxe1YrG08/W9Ycg88QANNgo6pdhIlRB2u18uwTlu0+YVp
xeIeDNQRPNIZf4eUNDoHqH+M5V+pda5fVKrlRWXxYgxUca+zFealgjPfDGcLu9Xg
IbOIMDiIkPj1lIMzwV36lBbKx7xaO4mCu9JIp1RQM11w2YSXS75E/IsAXg2UFeL0
cBwHfoLpSnfulil3vwBF
=Ureh
-----END PGP SIGNATURE-----

--G4iJoqBmSsgzjUCe--
