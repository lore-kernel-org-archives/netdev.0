From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 1/2] net: ethernet: sxgbe: remove private tx queue lock
Date: Sun, 11 Dec 2016 21:11:04 +0100
Message-ID: <20161211201104.GB20574@amd>
References: <1481141138-19466-1-git-send-email-LinoSanfilippo@gmx.de>
 <1481141138-19466-2-git-send-email-LinoSanfilippo@gmx.de>
 <20161207231534.GB5889@electric-eye.fr.zoreil.com>
 <051e3043-8b58-0591-36e3-99e2267f67f4@gmx.de>
 <20161208231943.GA13102@electric-eye.fr.zoreil.com>
 <20161209112142.GA22710@amd>
 <c76124b9-6376-42b9-2821-b5a8185f5034@gmx.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="U+BazGySraz5kW0T"
Cc: Francois Romieu <romieu@fr.zoreil.com>, bh74.an@samsung.com,
        ks.giri@samsung.com, vipul.pandya@samsung.com,
        peppe.cavallaro@st.com, alexandre.torgue@st.com,
        davem@davemloft.net, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <c76124b9-6376-42b9-2821-b5a8185f5034@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--U+BazGySraz5kW0T
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> On 09.12.2016 12:21, Pavel Machek wrote:
> > On Fri 2016-12-09 00:19:43, Francois Romieu wrote:
> >> Lino Sanfilippo <LinoSanfilippo@gmx.de> :
> >> [...]
> >> > OTOH Pavel said that he actually could produce a deadlock. Now I won=
der if
> >> > this is caused by that locking scheme (in a way I have not figured o=
ut yet)
> >> > or if it is a different issue.
> >>=20
> >> stmmac_tx_err races with stmmac_xmit.
> >=20
> > Umm, yes, that looks real.
> >=20
> > And that means that removing tx_lock will not be completely trivial
> > :-(. Lino, any ideas there?
> >=20
>=20
> Ok, the race is there but it looks like a problem that is not related to=
=20
> the use or removal of the private lock.

Well, removal of the private lock will make it trickier to fix :-(.

> By a glimpse into other drivers (e.g sky2 or e1000), a possible way to ha=
ndle a=20
> tx error is to start a separate task and restart the tx path in that task=
 instead
> the irq handler (or timer in case of the watchdog).
>=20
> In that task we could do:
> 1. deactivate napi
> 2. deactivate irqs
> 3. wait for running napi/irqs do complete (_sync)
> 4. call stmmac_tx_err()
> 5. reenable napi
> 6. reenable irqs
>=20
> We have to ensure that no xmit() is executing while stmmac_tx_err() does =
the cleanup,
> so stmmac_tx_err() should IMO rather call netif_tx_disable() instead of n=
etif_stop_queue()
> (the former grabs the xmit lock before it sets __QUEUE_STATE_DRV_XOFF to =
disable
> the queue).

Do you understand what stmmac_tx_err(priv); is supposed to do? In
particular, if it is called while the driver is working ok -- should
the driver survive that?

Because it does not currently, and I don't know how to test that
code. Unplugging the cable does not provoke that.

I tried

        } else if (unlikely(status =3D=3D tx_hard_error))
                stmmac_tx_err(priv);
+
+       {
+               static int i;
+               i++;
+               if (i=3D=3D1000) {
+                       i =3D 0;
+                       printk("Simulated error\n");
+                       stmmac_tx_err(priv);
+               }
+       }
 }

but the driver does not survive that :-(.

Best regards,
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--U+BazGySraz5kW0T
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlhNstgACgkQMOfwapXb+vJYOQCfaBoeISBQCM2FYQkh9/ivtoRb
rAMAmwV4W7y/RvQyzPx/k/gxywqA8QnK
=43+8
-----END PGP SIGNATURE-----

--U+BazGySraz5kW0T--
