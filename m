From: Pavel Machek <pavel@ucw.cz>
Subject: Re: stmmac ethernet in kernel 4.9-rc6: coalescing related pauses.
Date: Fri, 2 Dec 2016 13:32:41 +0100
Message-ID: <20161202123241.GA5869@amd>
References: <20161123105125.GA26394@amd>
 <20161124085506.GA25007@amd>
 <20161124.110416.198867271899443489.davem@davemloft.net>
 <20161124212540.GA24796@amd>
 <b6ac7a3c-6774-9568-1cc0-97074eaa928f@st.com>
 <20161202084511.GA32294@amd>
 <3192a4b6-1e97-048f-a0dd-bfc0f3d96ed8@st.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="FCuugMFkClbJLl1L"
Cc: alexandre.torgue@st.com, David Miller <davem@davemloft.net>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <3192a4b6-1e97-048f-a0dd-bfc0f3d96ed8@st.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--FCuugMFkClbJLl1L
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> >Well, if you have a workload that sends and receive packets, it tends
> >to work ok, as you do tx_clean() in stmmac_poll(). My workload is not
> >like that -- it is "sending packets at 3MB/sec, receiving none". So
> >the stmmac_tx_timer() is rescheduled and rescheduled and rescheduled,
> >and then we run out of transmit descriptors, and then 40msec passes,
> >and then we clean them. Bad.
> >
> >And that's why low-res timers do not cut it.
>=20
> in that case, I expect that the tuning of the driver could help you.
> I mean, by using ethtool, it could be enough to set the IC bit on all
> the descriptors. You should touch the tx_coal_frames.
>=20
> Then you can use ethtool -S to monitor the status.

Yes, I did something similar. Unfortnunately that meant crash within
minutes, at least with 4.4 kernel. (If you know what was fixed between
4.4 and 4.9, that would be helpful).

> We had experimented this tuning on STB IP where just datagrams
> had to send externally. To be honest, although we had seen
> better results w/o any timer, we kept this approach enabled
> because the timer was fast enough to cover our tests on SH4 boxes.

Please reply to David, and explain how it is supposed to
work... because right now it does not. 40 msec delays are not
acceptable in default configuration.

> >>In the ring, some descriptors can raise the irq (according to a
> >>threshold) and set the IC bit. In this path, the NAPI  poll will be
> >>scheduled.
> >
> >Not NAPI poll but stmmac_tx_timer(), right?
>=20
> in the xmit according the the threshold the timer is started or the
> interrupt is set inside the descriptor.
> Then stmmac_tx_clean will be always called and, if you see the flow,
> no irqlock protection is needed!

Agreed that no irqlock protection is needed if we rely on napi and timers.

> >>Concerning the lock protection, we had reviewed long time ago and
> >>IIRC, no raise condition should be present. Open to review it,
> >>again!
=2E..
> >There's nothing that protect stmmac_poll() from running concurently
> >with stmmac_dma_interrupt(), right?
>=20
> This is not necessary.

dma_interrupt accesses shared priv->xstats; variables are of type
unsigned long (not atomic_t), yet they are accesssed from interrupt
context and from stmmac_ethtool without any locking. That can result
in broken statistics AFAICT.

Please take another look. As far as I can tell, you can have two cpus
at #1 and #2 in the code, at the same time. It looks like napi_... has
some atomic opertions inside so that looks safe at the first look. But
I'm not sure if they also include enough memory barriers to make it
safe...?


static void stmmac_dma_interrupt(struct stmmac_priv *priv)
{
=2E..
        status =3D priv->hw->dma->dma_interrupt(priv->ioaddr, &priv->xstats=
);
        if (likely((status & handle_rx)) || (status & handle_tx)) {
                if (likely(napi_schedule_prep(&priv->napi))) {
#1
                        stmmac_disable_dma_irq(priv);
                        __napi_schedule(&priv->napi);
                }
        }


static int stmmac_poll(struct napi_struct *napi, int budget)
{
        struct stmmac_priv *priv =3D container_of(napi, struct stmmac_priv,=
 napi);
        int work_done =3D 0;

        priv->xstats.napi_poll++;
        stmmac_tx_clean(priv);

        work_done =3D stmmac_rx(priv, budget);
	if (work_done < budget) {
                napi_complete(napi);
#2
	        stmmac_enable_dma_irq(priv);
        }
        return work_done;
}


Best regards,
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--FCuugMFkClbJLl1L
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlhBaekACgkQMOfwapXb+vJGxQCZAZWKSaPl4T68lMQWTxU9Ya1F
PgEAoKf5Zoplj+0GoNV7bUgQyVape/VH
=KRU4
-----END PGP SIGNATURE-----

--FCuugMFkClbJLl1L--
