From: Stefan Hajnoczi <stefanha@gmail.com>
Subject: Re: [Qemu-devel] TCP performance problems - GSO/TSO, MSS, 8139cp
 related
Date: Mon, 14 Nov 2016 16:25:05 +0000
Message-ID: <20161114162505.GD26664@stefanha-x1.localdomain>
References: <20161111210500.GE1041@n2100.armlinux.org.uk>
 <1478899423.3892.7.camel@infradead.org>
 <20161111224427.GG1041@n2100.armlinux.org.uk>
 <20161114092947.GB2031@work-vm>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="rqzD5py0kzyFAOWN"
Cc: jasowang@redhat.com, vyasevic@redhat.com, stefanha@redhat.com,
        netdev@vger.kernel.org, qemu-devel@nongnu.org,
        igor.v.kovalenko@gmail.com, dgilbert@redhat.com
To: Russell King - ARM Linux <linux@armlinux.org.uk>,
        David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33449 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932583AbcKNQZJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2016 11:25:09 -0500
Received: by mail-wm0-f68.google.com with SMTP id u144so16708297wmu.0
        for <netdev@vger.kernel.org>; Mon, 14 Nov 2016 08:25:08 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20161114092947.GB2031@work-vm>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--rqzD5py0kzyFAOWN
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Nov 14, 2016 at 09:29:48AM +0000, Dr. David Alan Gilbert wrote:
> * Russell King - ARM Linux (linux@armlinux.org.uk) wrote:
> > On Fri, Nov 11, 2016 at 09:23:43PM +0000, David Woodhouse wrote:
> > > It's also *fairly* unlikely that the kernel in the guest has developed
> > > a bug and isn't setting gso_size sanely. I'm more inclined to suspect
> > > that qemu isn't properly emulating those bits. But at first glance at
> > > the code, it looks like *that's* been there for the last decade too...
> >=20
> > I take issue with that, having looked at the qemu rtl8139 code:
> >=20
> >                 if ((txdw0 & CP_TX_LGSEN) && ip_protocol =3D=3D IP_PROT=
O_TCP)
> >                 {
> >                     int large_send_mss =3D (txdw0 >> 16) & CP_TC_LGSEN_=
MSS_MASK;
> >=20
> >                     DPRINTF("+++ C+ mode offloaded task TSO MTU=3D%d IP=
 data %d "
> >                         "frame data %d specified MSS=3D%d\n", ETH_MTU,
> >                         ip_data_len, saved_size - ETH_HLEN, large_send_=
mss);
> >=20
> > That's the only reference to "large_send_mss" there, other than that,
> > the MSS value that gets stuck into the field by 8139cp.c is completely
> > unused.  Instead, qemu does this:
> >=20
> >                 eth_payload_data =3D saved_buffer + ETH_HLEN;
> >                 eth_payload_len  =3D saved_size   - ETH_HLEN;
> >=20
> >                 ip =3D (ip_header*)eth_payload_data;
> >=20
> >                     hlen =3D IP_HEADER_LENGTH(ip);
> >                     ip_data_len =3D be16_to_cpu(ip->ip_len) - hlen;
> >=20
> >                     tcp_header *p_tcp_hdr =3D (tcp_header*)(eth_payload=
_data + hlen);
> >                     int tcp_hlen =3D TCP_HEADER_DATA_OFFSET(p_tcp_hdr);
> >=20
> >                     /* ETH_MTU =3D ip header len + tcp header len + pay=
load */
> >                     int tcp_data_len =3D ip_data_len - tcp_hlen;
> >                     int tcp_chunk_size =3D ETH_MTU - hlen - tcp_hlen;
> >=20
> >                     for (tcp_send_offset =3D 0; tcp_send_offset < tcp_d=
ata_len; tcp_send_offset +=3D tcp_chunk_size)
> >                     {
> >=20
> > It uses a fixed value of ETH_MTU to calculate the size of the TCP
> > data chunks, and this is not surprisingly the well known:
> >=20
> > #define ETH_MTU     1500
> >=20
> > Qemu seems to be buggy - it ignores the MSS value, and always tries to
> > send 1500 byte frames.
>=20
> cc'ing in Stefan who last touched that code and Jason and Vlad who
> know the net code.

CCing Igor Kovalenko who implemented "fixed for TCP segmentation
offloading - removed dependency on slirp.h" in 2006.  I don't actually
expect him to remember this from 10 years ago though :).

Looking at the history the large_send_mss variable was never used for
anything beyond the debug printf.

The datasheet for this NIC is here:
http://realtek.info/pdf/rtl8139cp.pdf.  See 9.2.1 Transmit.

Does this untested patch work for you?

diff --git a/hw/net/rtl8139.c b/hw/net/rtl8139.c
index f05e59c..a3f1af5 100644
--- a/hw/net/rtl8139.c
+++ b/hw/net/rtl8139.c
@@ -2167,9 +2167,13 @@ static int rtl8139_cplus_transmit_one(RTL8139State *=
s)
                     goto skip_offload;
                 }
=20
-                /* ETH_MTU =3D ip header len + tcp header len + payload */
+                /* MSS too small */
+                if (tcp_hlen + hlen >=3D large_send_mss) {
+                    goto skip_offload;
+                }
+
                 int tcp_data_len =3D ip_data_len - tcp_hlen;
-                int tcp_chunk_size =3D ETH_MTU - hlen - tcp_hlen;
+                int tcp_chunk_size =3D large_send_mss - hlen - tcp_hlen;
=20
                 DPRINTF("+++ C+ mode TSO IP data len %d TCP hlen %d TCP "
                     "data len %d TCP chunk size %d\n", ip_data_len,

--rqzD5py0kzyFAOWN
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJYKeVhAAoJEJykq7OBq3PIE2QIAJsBhIeBpFxJ/HXRfrpM6RRl
w8Cpd611taV8EXvruawF0ff22C5bHAu8Fbn2DKMWAGR8N+s2zJFHdLX+YH9TrFA/
PptOEWQcHHfr3t8qTzZKiZHq79YyntROLbu28jwULlV4A0Y2xZXHSIrM+HLPpYe5
Dx0cw2MaKdrSYk+XzpIwo9LUCa7ef3xYk9yT4+92c5hBRfttxBGMDajrp5tlWIzP
Nn0QcnhKYYY39utfs6BmhD7aPM8P5oHMINuigPpIOsdN/iI1GnKcTWZbiaRvI/yM
aXePI+4+GRvUJ7xBvdCGUeOrFuuLMwS+IvT+l48OS064RcHDPbI/DnOwp8Ru71U=
=QA/7
-----END PGP SIGNATURE-----

--rqzD5py0kzyFAOWN--
