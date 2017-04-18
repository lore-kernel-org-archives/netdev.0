From: David Lebrun <david.lebrun@uclouvain.be>
Subject: Re: net/ipv6: slab-out-of-bounds read in seg6_validate_srh
Date: Tue, 18 Apr 2017 17:16:01 +0200
Message-ID: <bd8d4b77-ee74-73a7-55af-404a1b666460@uclouvain.be>
References: <CAAeHK+zcuT0Y2Xmh0C0JB0Cv9JYoh13tOqw5qKGj+nANZT_axw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature";
        boundary="Kw5bn1u4aEIJnE91782NtxxlDLDAcakaX"
Cc: Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Andrey Konovalov <andreyknvl@google.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:34790 "EHLO
        smtp2.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755869AbdDRPP4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 11:15:56 -0400
In-Reply-To: <CAAeHK+zcuT0Y2Xmh0C0JB0Cv9JYoh13tOqw5qKGj+nANZT_axw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Kw5bn1u4aEIJnE91782NtxxlDLDAcakaX
Content-Type: multipart/mixed; boundary="ns9rO8F4TKf1v192pca9K8KiXARtpEIN2"
From: David Lebrun <david.lebrun@uclouvain.be>
To: Andrey Konovalov <andreyknvl@google.com>,
 "David S. Miller" <davem@davemloft.net>,
 Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, James Morris <jmorris@namei.org>,
 Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
 Patrick McHardy <kaber@trash.net>, netdev <netdev@vger.kernel.org>,
 LKML <linux-kernel@vger.kernel.org>, Cong Wang <xiyou.wangcong@gmail.com>,
 Eric Dumazet <edumazet@google.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>,
 syzkaller <syzkaller@googlegroups.com>
Message-ID: <bd8d4b77-ee74-73a7-55af-404a1b666460@uclouvain.be>
Subject: Re: net/ipv6: slab-out-of-bounds read in seg6_validate_srh
References: <CAAeHK+zcuT0Y2Xmh0C0JB0Cv9JYoh13tOqw5qKGj+nANZT_axw@mail.gmail.com>
In-Reply-To: <CAAeHK+zcuT0Y2Xmh0C0JB0Cv9JYoh13tOqw5qKGj+nANZT_axw@mail.gmail.com>

--ns9rO8F4TKf1v192pca9K8KiXARtpEIN2
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 04/18/2017 04:54 PM, Andrey Konovalov wrote:
> Hi,
>=20
> I've got the following error report while fuzzing the kernel with syzka=
ller.
>=20
> On commit 4f7d029b9bf009fbee76bb10c0c4351a1870d2f3 (4.11-rc7).
>=20
> A reproducer and .config are attached.
>=20
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> BUG: KASAN: slab-out-of-bounds in seg6_validate_srh+0x203/0x220
> net/ipv6/seg6.c:57 at addr ffff88006a759608
> Read of size 1 by task syz-executor4/2627

Thanks for the report. It seems to happen when the trailing data is less
than sizeof(struct sr6_tlv). The following (untested) patch should fix
the issue, I'll test it and submit it properly if it works.

diff --git a/net/ipv6/seg6.c b/net/ipv6/seg6.c
index a855eb3..5f44ffe 100644
--- a/net/ipv6/seg6.c
+++ b/net/ipv6/seg6.c
@@ -53,6 +53,9 @@ bool seg6_validate_srh(struct ipv6_sr_hdr *srh, int len=
)
 		struct sr6_tlv *tlv;=09
 		unsigned int tlv_len;

+		if (trailing < sizeof(*tlv))
+			return false;
+
 		tlv =3D (struct sr6_tlv *)((unsigned char *)srh + tlv_offset);
 		tlv_len =3D sizeof(*tlv) + tlv->len;




--ns9rO8F4TKf1v192pca9K8KiXARtpEIN2--

--Kw5bn1u4aEIJnE91782NtxxlDLDAcakaX
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iF0EARECAB0WIQT8nTbQ2eQR5sQwCJ+NvOfruxnoAwUCWPYtsQAKCRCNvOfruxno
A4S6AJ0d5AhvYyyFP5NVbYERvvo/ulAuhwCdFmCNBemrB8aiMQAU7K1uaWoNH8U=
=5WNd
-----END PGP SIGNATURE-----

--Kw5bn1u4aEIJnE91782NtxxlDLDAcakaX--
