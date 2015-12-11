From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [PATCH v3 1/4] VSOCK: Introduce virtio-vsock-common.ko
Date: Fri, 11 Dec 2015 10:51:06 +0800
Message-ID: <20151211025106.GA6367@stefanha-x1.localdomain>
References: <1449662633-26623-1-git-send-email-stefanha@redhat.com>
	<1449662633-26623-2-git-send-email-stefanha@redhat.com>
	<87k2omppzw.fsf@linaro.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4312551810150489156=="
Cc: kvm@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
	netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	Matt Benjamin <mbenjamin@redhat.com>, Asias He <asias@redhat.com>,
	Christoffer Dall <christoffer.dall@linaro.org>, matt.ma@linaro.org
To: Alex =?iso-8859-1?Q?Benn=E9e?= <alex.bennee@linaro.org>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <87k2omppzw.fsf@linaro.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org


--===============4312551810150489156==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="zYM0uCDKw75PZbzx"
Content-Disposition: inline


--zYM0uCDKw75PZbzx
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Dec 10, 2015 at 10:17:07AM +0000, Alex Benn=E9e wrote:
> Stefan Hajnoczi <stefanha@redhat.com> writes:
>=20
> > From: Asias He <asias@redhat.com>
> >
> > This module contains the common code and header files for the following
> > virtio-vsock and virtio-vhost kernel modules.
>=20
> General comment checkpatch has a bunch of warnings about 80 character
> limits, extra braces and BUG_ON usage.

Will fix in the next verison.

> > diff --git a/include/linux/virtio_vsock.h b/include/linux/virtio_vsock.h
> > new file mode 100644
> > index 0000000..e54eb45
> > --- /dev/null
> > +++ b/include/linux/virtio_vsock.h
> > @@ -0,0 +1,203 @@
> > +/*
> > + * This header, excluding the #ifdef __KERNEL__ part, is BSD licensed =
so
> > + * anyone can use the definitions to implement compatible
> > drivers/servers:
>=20
> Is anything in here actually exposed to userspace or the guest? The
> #ifdef __KERNEL__ statement seems redundant for this file at least.

You are right.  I think the header was copied from a uapi file.

I'll compare against other virtio code and apply an appropriate header.

> > +void virtio_vsock_dumppkt(const char *func,  const struct virtio_vsock=
_pkt *pkt)
> > +{
> > +	pr_debug("%s: pkt=3D%p, op=3D%d, len=3D%d, %d:%d---%d:%d, len=3D%d\n",
> > +		 func, pkt,
> > +		 le16_to_cpu(pkt->hdr.op),
> > +		 le32_to_cpu(pkt->hdr.len),
> > +		 le32_to_cpu(pkt->hdr.src_cid),
> > +		 le32_to_cpu(pkt->hdr.src_port),
> > +		 le32_to_cpu(pkt->hdr.dst_cid),
> > +		 le32_to_cpu(pkt->hdr.dst_port),
> > +		 pkt->len);
> > +}
> > +EXPORT_SYMBOL_GPL(virtio_vsock_dumppkt);
>=20
> Why export this at all? The only users are in this file so you could
> make it static.

I'll make it static.

> > +u32 virtio_transport_get_credit(struct virtio_transport *trans, u32 cr=
edit)
> > +{
> > +	u32 ret;
> > +
> > +	mutex_lock(&trans->tx_lock);
> > +	ret =3D trans->peer_buf_alloc - (trans->tx_cnt - trans->peer_fwd_cnt);
> > +	if (ret > credit)
> > +		ret =3D credit;
> > +	trans->tx_cnt +=3D ret;
> > +	mutex_unlock(&trans->tx_lock);
> > +
> > +	pr_debug("%s: ret=3D%d, buf_alloc=3D%d, peer_buf_alloc=3D%d,"
> > +		 "tx_cnt=3D%d, fwd_cnt=3D%d, peer_fwd_cnt=3D%d\n", __func__,
>=20
> I think __func__ is superfluous here as the dynamic print code already
> has it and can print it when required. Having said that there seems to
> be plenty of code already in the kernel that uses __func__ :-/

I'll convert most printks to tracepoints in the next revision.

> > +u64 virtio_transport_get_max_buffer_size(struct vsock_sock *vsk)
> > +{
> > +	struct virtio_transport *trans =3D vsk->trans;
> > +
> > +	return trans->buf_size_max;
> > +}
> > +EXPORT_SYMBOL_GPL(virtio_transport_get_max_buffer_size);
>=20
> All these accesses functions seem pretty simple. Maybe they should be
> inline header functions or even #define macros?

They are used as struct vsock_transport function pointers.  What is the
advantage to inlining them?

> > +int virtio_transport_notify_send_post_enqueue(struct vsock_sock *vsk,
> > +	ssize_t written, struct vsock_transport_send_notify_data *data)
> > +{
> > +	return 0;
> > +}
> > +EXPORT_SYMBOL_GPL(virtio_transport_notify_send_post_enqueue);
>=20
> This makes me wonder if the calling code should be having
> if(transport->fn) checks rather than filling stuff out will null
> implementations but I guess that's a question better aimed at the
> maintainers.

I've considered it too.  I'll try to streamline this in the next
revision.

> > +/* We are under the virtio-vsock's vsock->rx_lock or
> > + * vhost-vsock's vq->mutex lock */
> > +void virtio_transport_recv_pkt(struct virtio_vsock_pkt *pkt)
> > +{
> > +	struct virtio_transport *trans;
> > +	struct sockaddr_vm src, dst;
> > +	struct vsock_sock *vsk;
> > +	struct sock *sk;
> > +
> > +	vsock_addr_init(&src, le32_to_cpu(pkt->hdr.src_cid), le32_to_cpu(pkt-=
>hdr.src_port));
> > +	vsock_addr_init(&dst, le32_to_cpu(pkt->hdr.dst_cid), le32_to_cpu(pkt-=
>hdr.dst_port));
> > +
> > +	virtio_vsock_dumppkt(__func__, pkt);
> > +
> > +	if (le16_to_cpu(pkt->hdr.type) !=3D VIRTIO_VSOCK_TYPE_STREAM) {
> > +		/* TODO send RST */
>=20
> TODO's shouldn't make it into final submissions.
>=20
> > +		goto free_pkt;
> > +	}
> > +
> > +	/* The socket must be in connected or bound table
> > +	 * otherwise send reset back
> > +	 */
> > +	sk =3D vsock_find_connected_socket(&src, &dst);
> > +	if (!sk) {
> > +		sk =3D vsock_find_bound_socket(&dst);
> > +		if (!sk) {
> > +			pr_debug("%s: can not find bound_socket\n", __func__);
> > +			virtio_vsock_dumppkt(__func__, pkt);
> > +			/* Ignore this pkt instead of sending reset back */
> > +			/* TODO send a RST unless this packet is a RST
> > (to avoid infinite loops) */
>=20
> Ditto.

Thanks, I'll complete the RST code in the next revision.

--zYM0uCDKw75PZbzx
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJWajoaAAoJEJykq7OBq3PICiwH/0qtmNM1Bx/iQQWj0K135qYF
hrX2HZXOBOQfLIQdnxBX/uryAJuXn7rHluJKQywMrXQr/oXvYQQFMKCluBfrpt0h
MNJTkTn+xwufX8/8SSsSQ2TheyAs7ZiGA6xye0QV7f/DS9f+Gcq7BCegNnsnDtYh
o8htx5vgAJXyq/Zx1Lga3WksyVr4TGJlB30o53u8501BSJfdE525oQwe2xuXKk7E
325PABgH8+Lefcqu6M34K3KVJZS4biGD1jLyp5GIp3kN7M/upMpI4BHoFwFEWAEL
G+edTArxccb/K/ZBgzxRtyd2SY86K36nkimi1/g2RLMMr/9m7/6LtMY4qBgAhnA=
=YuOQ
-----END PGP SIGNATURE-----

--zYM0uCDKw75PZbzx--

--===============4312551810150489156==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Virtualization mailing list
Virtualization@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/virtualization
--===============4312551810150489156==--
