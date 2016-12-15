From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH v2 2/2] net: ethernet: stmmac: remove private tx queue
 lock
Date: Thu, 15 Dec 2016 23:03:53 +0100
Message-ID: <20161215220353.GA15619@amd>
References: <1481241343-18062-1-git-send-email-LinoSanfilippo@gmx.de>
 <1481241343-18062-3-git-send-email-LinoSanfilippo@gmx.de>
 <20161215094517.GA406@amd>
 <626fc3ef-ba18-ed99-aea1-2f737425b199@gmx.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="qMm9M+Fa2AknHoGS"
Cc: bh74.an@samsung.com, ks.giri@samsung.com, vipul.pandya@samsung.com,
        peppe.cavallaro@st.com, alexandre.torgue@st.com,
        romieu@fr.zoreil.com, davem@davemloft.net,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <626fc3ef-ba18-ed99-aea1-2f737425b199@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--qMm9M+Fa2AknHoGS
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> >> The driver uses a private lock for synchronization of the xmit functio=
n and
> >> the xmit completion handler, but since the NETIF_F_LLTX flag is not se=
t,
> >> the xmit function is also called with the xmit_lock held.
> >>=20
> >> On the other hand the completion handler uses the reverse locking orde=
r by
> >> first taking the private lock and (in case that the tx queue had been
> >> stopped) then the xmit_lock.
> >>=20
> >> Improve the locking by removing the private lock and using only the
> >> xmit_lock for synchronization instead.
> >=20
> > Do you have stmmac hardware to test on?
> >=20
>=20
> Unfortunately not (I mentioned that the patch I send was only compile tes=
ted in=20
> the first version but I think I forgot to do so in the last
> version).

:-(.


> > I believe something is very wrong with the locking there. In
> > particular... scheduling the stmmac_tx_timer() function to run often
> > should not do anything bad if locking is correct... but it breaks the
> > driver rather quickly. [Example patch below, needs applying to two
> > places in net-next.]
> >=20
>=20
> Do you get this result only after the private lock is removed? Or has thi=
s problem
> been there before? And how exactly does the failure look like?

I believe I was getting very similar fun even with the private lock. I
re-applied the private lock, and the result is the same.

Also.. locking does seems to work. I added checks to see if the
stmmac_tx_clean() and stmmac_xmit() run at the same time, and they
don't seem to. So my best guess at the moment is missing cache flush
or mb() somewhere.

Failure looks like this:

root@wagabuibui:~# mount /dev/mmcblk0p4 /mnt
o 1000000 > /proc/sys/net/core/wmeroot@wagabuibui:~# chroot /mnt
/bin/bash
root@wagabuibui:/# mount /proc000 100 30
root@wagabuibui:/# #echo 1000000 > /proc/sys/net/core/wmem_default
root@wagabuibui:/# cd /data/tmp/udpt
root@wagabuibui:/data/tmp/udpt# ifconfig eth0 10.0.0.170 up
[   18.358072] socfpga-dwmac ff702000.ethernet eth0: IEEE 1588-2008
Advanced Timestamp supported
[   18.366836] socfpga-dwmac ff702000.ethernet eth0: registered PTP
clock
root@wagabuibui:/data/tmp/udpt# ./udp-test raw 10.0.0.6 1234 1000 100
30
Sending 100 packets (1000b each) at an interval of 30ms, expected data
rate:3333333b/s (3373333b/s incl udp overhead)
[   20.453538] socfpga-dwmac ff702000.ethernet eth0: Link is Up -
100Mbps/Full - flow control rx/tx
[   20.581826] Link is Up - 100/Full
Sending UDP packet took >10ms: 5205162us
This would lead to a lost frame!
Sending UDP packet took >10ms: 40010us
This would lead to a lost frame!
Sending UDP packet took >10ms: 6366084us
This would lead to a lost frame!
Sending UDP packet took >10ms: 36971us
This would lead to a lost frame!
[   42.084940] ------------[ cut here ]------------
[   42.089577] WARNING: CPU: 0 PID: 0 at net/sched/sch_generic.c:316
dev_watchdog+0x254/0x26c
[   42.097821] NETDEV WATCHDOG: eth0 (socfpga-dwmac): transmit queue 0
timed out
[   42.104935] Modules linked in:

Best regards,
									Pavel

--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--qMm9M+Fa2AknHoGS
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlhTE0kACgkQMOfwapXb+vJTBQCgggAK3q9PP3GX0msdfzYL5xH0
DzoAnRY9QMNpcnxG1JI9Yye/DVDDV3hr
=kdnU
-----END PGP SIGNATURE-----

--qMm9M+Fa2AknHoGS--
