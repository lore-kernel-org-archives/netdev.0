From: Mike Keehan <mike_keehan@yahoo.com>
Subject: Re: e100 NETDEV WATCHDOG transmit timeout since 2.6.4
Date: Wed, 21 Apr 2004 06:20:17 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040421132017.68243.qmail@web12305.mail.yahoo.com>
References: <Pine.LNX.4.58.0404201559290.7794@snichols-desk.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Scott Feldman <scott.feldman@intel.com>
In-Reply-To: <Pine.LNX.4.58.0404201559290.7794@snichols-desk.amr.corp.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

HI Scott,

That's a lot better. =20

I've been running OK for about four hours on the half duplex network.
The only time that the wathcdog timed out was when I was using
KDE's Konqueror to look at files on a SMB mounted directory
(from an NT 4 system).

Previously the network connection would fail within minutes when
using ssh or ftp to another Linux box.  Now, they have worked
consistently for hours.

Cheers,

   Mike.

--- Scott Feldman <scott.feldman@intel.com> wrote:
>=20
>=20
> On Tue, 20 Apr 2004, Mike Keehan wrote:
>=20
> > I am getting these too in recent kernels, but only on a
> > 10Mhz half-duplex network. I have to manually down
> > and up the interface to recover.
> >
> > On a 100Mhz switched network, the e100 is OK (at least 12hours+).
>=20
>=20
> Mike/Eamonn,
>=20
> Give this patch a try.  This adds a required workaround for ICH when
> working at 10/Half.  (Guessing you have an ICH system).
>=20
> --- linux-2.5/drivers/net/e100.c	2004-04-20 15:52:24.000000000 -0700
> +++ linux-2.5/drivers/net/e100.c.mod	2004-04-20 15:55:32.000000000
> -0700
> @@ -287,6 +287,7 @@ enum scb_cmd_hi {
>  };
>=20
>  enum scb_cmd_lo {
> +	cuc_nop        =3D 0x00,
>  	ruc_start      =3D 0x01,
>  	ruc_load_base  =3D 0x06,
>  	cuc_start      =3D 0x10,
> @@ -514,10 +515,11 @@ struct nic {
>  	/* End: frequently used values: keep adjacent for cache effect */
>=20
>  	enum {
> -		ich           =3D (1 << 0),
> -		promiscuous   =3D (1 << 1),
> -		multicast_all =3D (1 << 2),
> -		wol_magic     =3D (1 << 3),
> +		ich                =3D (1 << 0),
> +		promiscuous        =3D (1 << 1),
> +		multicast_all      =3D (1 << 2),
> +		wol_magic          =3D (1 << 3),
> +		ich_10h_workaround =3D (1 << 4),
>  	} flags					____cacheline_aligned;
>=20
>  	enum mac mac;
> @@ -1225,6 +1227,12 @@ static void e100_watchdog(unsigned long
>  		/* Issue a multicast command to workaround a 557 lock up */
>  		e100_set_multicast_list(nic->netdev);
>=20
> +	if(nic->flags & ich && cmd.speed=3D=3DSPEED_10 &&
> cmd.duplex=3D=3DDUPLEX_HALF)
> +		/* Need SW workaround for ICH[x] 10Mbps/half duplex Tx hang. */
> +		nic->flags |=3D ich_10h_workaround;
> +	else
> +		nic->flags &=3D ~ich_10h_workaround;
> +
>  	mod_timer(&nic->watchdog, jiffies + E100_WATCHDOG_PERIOD);
>  }
>=20
> @@ -1244,7 +1252,17 @@ static inline void e100_xmit_prepare(str
>  static int e100_xmit_frame(struct sk_buff *skb, struct net_device
> *netdev)
>  {
>  	struct nic *nic =3D netdev->priv;
> -	int err =3D e100_exec_cb(nic, skb, e100_xmit_prepare);
> +	int err;
> +
> +	if(nic->flags & ich_10h_workaround) {
> +		/* SW workaround for ICH[x] 10Mbps/half duplex Tx hang.
> +		   Issue a NOP command followed by a 1us delay before
> +		   issuing the Tx command. */
> +		e100_exec_cmd(nic, cuc_nop, 0);
> +		udelay(1);
> +	}
> +
> +	err =3D e100_exec_cb(nic, skb, e100_xmit_prepare);
>=20
>  	switch(err) {
>  	case -ENOSPC:
>=20



=09
	=09
__________________________________
Do you Yahoo!?
Yahoo! Photos: High-quality 4x6 digital prints for 25=A2
http://photos.yahoo.com/ph/print_splash
