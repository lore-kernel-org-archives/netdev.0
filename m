From: Wolfgang Walter <linux@stwm.de>
Subject: Re: kernel >= 4.0: crashes when using traceroute6 with isatap
Date: Thu, 07 May 2015 02:04:46 +0200
Message-ID: <357742496.VPxjz4tqdT@h2o.as.studentenwerk.mhn.de>
References: <1770409.aMESoOv08f@h2o.as.studentenwerk.mhn.de> <2723870.nq54KKjWkm@h2o.as.studentenwerk.mhn.de> <1430952158.14545.97.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1430952158.14545.97.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Mittwoch, 6. Mai 2015, 15:42:38 schrieben Sie:
> On Thu, 2015-05-07 at 00:04 +0200, Wolfgang Walter wrote:
> > Am Mittwoch, 6. Mai 2015, 12:10:00 schrieb Eric Dumazet:
> > > On Wed, 2015-05-06 at 11:15 -0700, Cong Wang wrote:
> > > > (Cc'ing netdev.)
> > > >=20
> > > > On Sat, May 2, 2015 at 5:29 AM, Wolfgang Walter <linux@stwm.de>=
 wrote:
> > > > > Am Samstag, 2. Mai 2015, 02:16:36 schrieb Wolfgang Walter:
> > > > >> Hello,
> > > > >>=20
> > > > >> kernel 4.0 (and 4.0.1) crashes immediately when I use tracer=
oute6
> > > > >> with
> > > > >> an
> > > > >> isatap-tunnel.
> > > > >=20
> > > > > I did some further tests. To trigger the crash you need
> > > > >=20
> > > > > * isatap-tunnel (probably any sit-tunnel will do it)
> > > > > * raw-socket
> > > > > * udp
> > > > >=20
> > > > > Using icmpv6 or tcp i.e. does not trigger it.
> > > >=20
> > > > Do you have a script to reproduce it?
> > > >=20
> > > >=20
> > > > Thanks for the bug report!
> > > > --
> > >=20
> > > Please Wolfgang try to revert 32dce968dd987adfb0c00946d78dad9154f=
64759
> > > ("ipv6: Allow for partial checksums on non-ufo packets")
> >=20
> > Indeed, that fixes the problem.
>=20
> Yes, setting skb->csum to 0 is clearly wrong for CHECKSUM_PARTIAL
>=20
> Would you try :
>=20
> diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
> index
> 7fde1f265c90e90f16291e6c861b6e242111c25b..694ae630e1ca67e25ab1e5f6dd0=
b3597d
> b3669b0 100644 --- a/net/ipv6/ip6_output.c
> +++ b/net/ipv6/ip6_output.c
> @@ -1416,6 +1416,10 @@ alloc_new_skb:
>  			data +=3D fragheaderlen;
>  			skb->transport_header =3D (skb->network_header +
>  						 fragheaderlen);
> +			if (csummode =3D=3D CHECKSUM_PARTIAL) {
> +				skb->csum_start =3D skb_transport_header(skb) - skb->head;
> +				skb->csum_offset =3D offsetof(struct udphdr, check);
> +			}
>  			if (fraggap) {
>  				skb->csum =3D skb_copy_and_csum_bits(
>  					skb_prev, maxfraglen,

This patch fixes 4.0.1 (and 4.0.2).

Thanks Eric,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
