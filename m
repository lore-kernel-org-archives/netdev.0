From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [PATCH v4 3/3] VSOCK: Add virtio vsock vsockmon hooks
Date: Thu, 20 Apr 2017 11:32:06 +0100
Message-ID: <20170420103206.GB28129@stefanha-x1.localdomain>
References: <20170413161811.8953-1-stefanha@redhat.com>
 <20170413161811.8953-4-stefanha@redhat.com>
 <20170413214410-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="A6N2fC+uXW/VQSAv"
Cc: netdev@vger.kernel.org, Zhu Yanjun <zyjzyj2000@gmail.com>,
        Gerard Garcia <ggarcia@abra.uab.cat>,
        Jorgen Hansen <jhansen@vmware.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60744 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S942223AbdDTKcV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Apr 2017 06:32:21 -0400
Content-Disposition: inline
In-Reply-To: <20170413214410-mutt-send-email-mst@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--A6N2fC+uXW/VQSAv
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Apr 13, 2017 at 09:47:08PM +0300, Michael S. Tsirkin wrote:
> On Thu, Apr 13, 2017 at 05:18:11PM +0100, Stefan Hajnoczi wrote:
> > diff --git a/net/vmw_vsock/virtio_transport_common.c b/net/vmw_vsock/vi=
rtio_transport_common.c
> > index af087b4..aae60c1 100644
> > --- a/net/vmw_vsock/virtio_transport_common.c
> > +++ b/net/vmw_vsock/virtio_transport_common.c
> > @@ -16,6 +16,7 @@
> >  #include <linux/virtio_ids.h>
> >  #include <linux/virtio_config.h>
> >  #include <linux/virtio_vsock.h>
> > +#include <uapi/linux/vsockmon.h>
> > =20
> >  #include <net/sock.h>
> >  #include <net/af_vsock.h>
> > @@ -85,6 +86,63 @@ virtio_transport_alloc_pkt(struct virtio_vsock_pkt_i=
nfo *info,
> >  	return NULL;
> >  }
> > =20
> > +/* Packet capture */
> > +void virtio_transport_deliver_tap_pkt(struct virtio_vsock_pkt *pkt)
> > +{
> > +	struct sk_buff *skb;
> > +	struct af_vsockmon_hdr *hdr;
> > +	unsigned char *t_hdr, *payload;
> > +
> > +	skb =3D alloc_skb(sizeof(*hdr) + sizeof(pkt->hdr) + pkt->len,
> > +			GFP_ATOMIC);
> > +	if (!skb)
> > +		return; /* nevermind if we cannot capture the packet */
> > +
> > +	hdr =3D (struct af_vsockmon_hdr *)skb_put(skb, sizeof(*hdr));
> > +
> > +	/* pkt->hdr is little-endian so no need to byteswap here */
>=20
> Comment does not seem to make sense. Drop it?

All fields in pkt->hdr are little-endian.  All fields in the
af_vsockmon_hdr are little-endian too.

Normally code operating on either of these structs byteswaps the fields.
Therefore it seemed worth a comment to clarify that it's okay to omit
byteswaps.  The comment will help anyone auditing the code for
endianness bugs.

Why do you say it doesn't make sense?

> > +	hdr->src_cid =3D pkt->hdr.src_cid;
> > +	hdr->src_port =3D pkt->hdr.src_port;
> > +	hdr->dst_cid =3D pkt->hdr.dst_cid;
> > +	hdr->dst_port =3D pkt->hdr.dst_port;
> > +
> > +	hdr->transport =3D cpu_to_le16(AF_VSOCK_TRANSPORT_VIRTIO);
> > +	hdr->len =3D cpu_to_le16(sizeof(pkt->hdr));
> > +	hdr->reserved[0] =3D hdr->reserved[1] =3D 0;
> > +
> > +	switch(cpu_to_le16(pkt->hdr.op)) {
>=20
> I'd expect this to be le16_to_cpu.
> Does this pass check build?

You are right, make C=3D2 warns about this and it should be le16_to_cpu().
I'll run check builds from now on.

--A6N2fC+uXW/VQSAv
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJY+I4mAAoJEJykq7OBq3PIzw0H/236+jigwdt58+xh2z1D7gRy
e3CPekZPrV7dch1i1g2WpybdkYiB+KndhqTW/Va6K/a2c6bcZMePXD3x6x+nSDjG
nTkwhmiArTx9Sqkzv0W47kqLxH/RWiAnlPFUWNhPBFBlSjiklRnKLmlWeWln8YaV
xpDtzK1Vjbb04KMAzzjpR0WEBGrqNb9Wo6yFNi9+Ol37D36WGzCeQRVaTTQqXqKt
hmU0kx38QzbQ7TksMg8hgVXwmKITN0vr+jXFgEgjQDxyaTRtvtlatGuPw/c5Ms7A
fC7c55KGK+SesKEUOUfLno4TC7rUQXOHcM3Yfq4UowuZ/iKvSbMo4mAXsvip22g=
=PdWb
-----END PGP SIGNATURE-----

--A6N2fC+uXW/VQSAv--
