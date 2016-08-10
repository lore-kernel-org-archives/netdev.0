From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [PATCH 3/3] vsockmon: Add virtio vsock hooks
Date: Wed, 10 Aug 2016 12:59:18 +0100
Message-ID: <20160810115918.GC10461@stefanha-x1.localdomain>
References: <20160808161442.16038-1-ggarcia@deic.uab.cat>
 <20160808161442.16038-4-ggarcia@deic.uab.cat>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="UPT3ojh+0CqEDtpF"
Cc: netdev@vger.kernel.org, jhansen@vmware.com, mst@redhat.com
To: ggarcia@abra.uab.cat
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48576 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934086AbcHJTHH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Aug 2016 15:07:07 -0400
Content-Disposition: inline
In-Reply-To: <20160808161442.16038-4-ggarcia@deic.uab.cat>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--UPT3ojh+0CqEDtpF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Aug 08, 2016 at 06:14:42PM +0200, ggarcia@abra.uab.cat wrote:
> +static struct sk_buff *
> +virtio_vsock_pkt_vsockmon_to_vsockmon_skb(struct virtio_vsock_pkt *pkt)
> +{
> +	struct sk_buff *skb;
> +	struct af_vsockmon_hdr *hdr;
> +	void *payload;
> +
> +	u32 skb_len = sizeof(struct af_vsockmon_hdr) + pkt->len;
> +
> +	skb = alloc_skb(skb_len, GFP_ATOMIC);
> +	if (!skb)
> +		return NULL;
> +
> +	hdr = (struct af_vsockmon_hdr *) skb_put(skb, sizeof(*hdr));
> +
> +	hdr->src_cid = pkt->hdr.src_cid;
> +	hdr->src_port = pkt->hdr.src_port;
> +	hdr->dst_cid = pkt->hdr.dst_cid;
> +	hdr->dst_port = pkt->hdr.dst_port;
> +	hdr->t = cpu_to_le16(AF_VSOCK_T_VIRTIO);
> +	hdr->len = cpu_to_le16(sizeof(hdr->t_hdr));
> +
> +	switch(pkt->hdr.op) {

Missing le16_to_cpu()

> +	case VIRTIO_VSOCK_OP_REQUEST:
> +	case VIRTIO_VSOCK_OP_RESPONSE:
> +		hdr->op = cpu_to_le16(AF_VSOCK_OP_CONNECT);
> +		break;
> +	case VIRTIO_VSOCK_OP_RST:
> +	case VIRTIO_VSOCK_OP_SHUTDOWN:
> +		hdr->op = cpu_to_le16(AF_VSOCK_OP_DISCONNECT);
> +		break;
> +	case VIRTIO_VSOCK_OP_RW:
> +		hdr->op = cpu_to_le16(AF_VSOCK_OP_PAYLOAD);
> +		break;
> +	case VIRTIO_VSOCK_OP_CREDIT_UPDATE:
> +	case VIRTIO_VSOCK_OP_CREDIT_REQUEST:
> +		hdr->op = cpu_to_le16(AF_VSOCK_OP_CONTROL);
> +		break;
> +	default:
> +		hdr->op = cpu_to_le16(AF_VSOCK_OP_UNKNOWN);
> +		break;
> +	}
> +
> +	hdr->t_hdr.virtio_hdr = pkt->hdr;
> +
> +	if (pkt->len) {
> +		payload = skb_put(skb, pkt->len);
> +		memcpy(payload, pkt->buf, pkt->len);
> +	}
> +
> +	return skb;
> +}
> +
> +static void vsock_deliver_tap_pkt(struct virtio_vsock_pkt *pkt)
> +{
> +	struct sk_buff *skb = virtio_vsock_pkt_to_vsockmon_skb(pkt);
> +	if (skb) {
> +		vsock_deliver_tap(skb);
> +		kfree_skb(skb);

Should this be consume_skb()?  The function's doc comment says:

 *	Functions identically to kfree_skb, but kfree_skb assumes that the frame
 *	is being dropped after a failure and notes that

This isn't a failure case so kfree_skb() is not the right function.

--UPT3ojh+0CqEDtpF
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJXqxcWAAoJEJykq7OBq3PIJC8H/icmw9mEGsayWgIf7u1xl6k4
n8C6cMQBAiqUmqekRtC+JJavV5I472IFidEVPirzA/2UCDjcWaEvCVXLEuWQVdjI
TGj7VZktm4pwVkxygwyyYh2GzefZcZ2UecZtwitYaAvFLV6csvXY3+AAzFCgS206
LLaUHcqnGRWT1w+PqVpudMxPpKdXNOGNJGZlJF2b7zmeyk3FbvPuYxUknK7JfYQu
/kA+Cj0QUjylU1Ys6pllSiPWw/juGsrn02OfuzNP1wThkVtovz1JyvDWELnH0GIN
UIHklUNAKjDcaq/Kb2Li/wgCW3EhKSHzmzeoed7IeMBUVDuIb0B/b2AsGzO36G0=
=Eznx
-----END PGP SIGNATURE-----

--UPT3ojh+0CqEDtpF--
