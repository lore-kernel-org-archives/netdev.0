From: "Jorgen S. Hansen" <jhansen@vmware.com>
Subject: Re: [PATCH v5 3/3] VSOCK: Add virtio vsock vsockmon hooks
Date: Fri, 21 Apr 2017 14:41:30 +0000
Message-ID: <35F88D8F-5705-4B8C-AF6A-FEBE072FC8D9@vmware.com>
References: <20170421091046.5599-1-stefanha@redhat.com>
 <20170421091046.5599-4-stefanha@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Zhu Yanjun <zyjzyj2000@gmail.com>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Gerard Garcia <ggarcia@abra.uab.cat>
To: Stefan Hajnoczi <stefanha@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0072.outbound.protection.outlook.com ([104.47.34.72]:53366
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1041386AbdDUQji (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 21 Apr 2017 12:39:38 -0400
In-Reply-To: <20170421091046.5599-4-stefanha@redhat.com>
Content-Language: en-US
Content-ID: <AE9C5BEC9B27C64CB292A764DC9F6368@namprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Apr 21, 2017, at 11:10 AM, Stefan Hajnoczi <stefanha@redhat.com> wrote=
:
>=20
> From: Gerard Garcia <ggarcia@deic.uab.cat>
>=20
> The virtio drivers deal with struct virtio_vsock_pkt.  Add
> virtio_transport_deliver_tap_pkt(pkt) for handing packets to the
> vsockmon device.
>=20
> We call virtio_transport_deliver_tap_pkt(pkt) from
> net/vmw_vsock/virtio_transport.c and drivers/vhost/vsock.c instead of
> common code.  This is because the drivers may drop packets before
> handing them to common code - we still want to capture them.
>=20
> Signed-off-by: Gerard Garcia <ggarcia@deic.uab.cat>
> Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
> ---
> v5:
> * s/cpu_to_le16(pkt->hdr.op)/le16_to_cpu(pkt->hdr.op)/ [Michael]
> * checkpatch.pl fixes
> v3:
> * Hook virtio_transport.c (guest driver), not just
>   drivers/vhost/vsock.c (host driver)
> ---
> include/linux/virtio_vsock.h            |  1 +
> drivers/vhost/vsock.c                   |  8 +++++
> net/vmw_vsock/virtio_transport.c        |  3 ++
> net/vmw_vsock/virtio_transport_common.c | 64 ++++++++++++++++++++++++++++=
+++++
> 4 files changed, 76 insertions(+)
>=20
> diff --git a/include/linux/virtio_vsock.h b/include/linux/virtio_vsock.h
> index 584f9a6..ab13f07 100644
> --- a/include/linux/virtio_vsock.h
> +++ b/include/linux/virtio_vsock.h
> @@ -153,5 +153,6 @@ void virtio_transport_free_pkt(struct virtio_vsock_pk=
t *pkt);
> void virtio_transport_inc_tx_pkt(struct virtio_vsock_sock *vvs, struct vi=
rtio_vsock_pkt *pkt);
> u32 virtio_transport_get_credit(struct virtio_vsock_sock *vvs, u32 wanted=
);
> void virtio_transport_put_credit(struct virtio_vsock_sock *vvs, u32 credi=
t);
> +void virtio_transport_deliver_tap_pkt(struct virtio_vsock_pkt *pkt);
>=20
> #endif /* _LINUX_VIRTIO_VSOCK_H */
> diff --git a/drivers/vhost/vsock.c b/drivers/vhost/vsock.c
> index 44eed8e..d939ac1 100644
> --- a/drivers/vhost/vsock.c
> +++ b/drivers/vhost/vsock.c
> @@ -176,6 +176,11 @@ vhost_transport_do_send_pkt(struct vhost_vsock *vsoc=
k,
> 				restart_tx =3D true;
> 		}
>=20
> +		/* Deliver to monitoring devices all correctly transmitted
> +		 * packets.
> +		 */
> +		virtio_transport_deliver_tap_pkt(pkt);
> +
> 		virtio_transport_free_pkt(pkt);
> 	}
> 	if (added)
> @@ -383,6 +388,9 @@ static void vhost_vsock_handle_tx_kick(struct vhost_w=
ork *work)
>=20
> 		len =3D pkt->len;
>=20
> +		/* Deliver to monitoring devices all received packets */
> +		virtio_transport_deliver_tap_pkt(pkt);
> +
> 		/* Only accept correctly addressed packets */
> 		if (le64_to_cpu(pkt->hdr.src_cid) =3D=3D vsock->guest_cid)
> 			virtio_transport_recv_pkt(pkt);
> diff --git a/net/vmw_vsock/virtio_transport.c b/net/vmw_vsock/virtio_tran=
sport.c
> index 68675a1..9dffe02 100644
> --- a/net/vmw_vsock/virtio_transport.c
> +++ b/net/vmw_vsock/virtio_transport.c
> @@ -144,6 +144,8 @@ virtio_transport_send_pkt_work(struct work_struct *wo=
rk)
> 		list_del_init(&pkt->list);
> 		spin_unlock_bh(&vsock->send_pkt_list_lock);
>=20
> +		virtio_transport_deliver_tap_pkt(pkt);
> +
> 		reply =3D pkt->reply;
>=20
> 		sg_init_one(&hdr, &pkt->hdr, sizeof(pkt->hdr));
> @@ -370,6 +372,7 @@ static void virtio_transport_rx_work(struct work_stru=
ct *work)
> 			}
>=20
> 			pkt->len =3D len - sizeof(pkt->hdr);
> +			virtio_transport_deliver_tap_pkt(pkt);
> 			virtio_transport_recv_pkt(pkt);
> 		}
> 	} while (!virtqueue_enable_cb(vq));
> diff --git a/net/vmw_vsock/virtio_transport_common.c b/net/vmw_vsock/virt=
io_transport_common.c
> index af087b4..18e2479 100644
> --- a/net/vmw_vsock/virtio_transport_common.c
> +++ b/net/vmw_vsock/virtio_transport_common.c
> @@ -16,6 +16,7 @@
> #include <linux/virtio_ids.h>
> #include <linux/virtio_config.h>
> #include <linux/virtio_vsock.h>
> +#include <uapi/linux/vsockmon.h>
>=20
> #include <net/sock.h>
> #include <net/af_vsock.h>
> @@ -85,6 +86,69 @@ virtio_transport_alloc_pkt(struct virtio_vsock_pkt_inf=
o *info,
> 	return NULL;
> }
>=20
> +/* Packet capture */
> +static struct sk_buff *virtio_transport_build_skb(void *opaque)
> +{
> +	struct virtio_vsock_pkt *pkt =3D opaque;
> +	unsigned char *t_hdr, *payload;
> +	struct af_vsockmon_hdr *hdr;
> +	struct sk_buff *skb;
> +
> +	skb =3D alloc_skb(sizeof(*hdr) + sizeof(pkt->hdr) + pkt->len,
> +			GFP_ATOMIC);
> +	if (!skb)
> +		return NULL;
> +
> +	hdr =3D (struct af_vsockmon_hdr *)skb_put(skb, sizeof(*hdr));
> +
> +	/* pkt->hdr is little-endian so no need to byteswap here */
> +	hdr->src_cid =3D pkt->hdr.src_cid;
> +	hdr->src_port =3D pkt->hdr.src_port;
> +	hdr->dst_cid =3D pkt->hdr.dst_cid;
> +	hdr->dst_port =3D pkt->hdr.dst_port;
> +
> +	hdr->transport =3D cpu_to_le16(AF_VSOCK_TRANSPORT_VIRTIO);
> +	hdr->len =3D cpu_to_le16(sizeof(pkt->hdr));
> +	memset(hdr->reserved, 0, sizeof(hdr->reserved));
> +
> +	switch (le16_to_cpu(pkt->hdr.op)) {
> +	case VIRTIO_VSOCK_OP_REQUEST:
> +	case VIRTIO_VSOCK_OP_RESPONSE:
> +		hdr->op =3D cpu_to_le16(AF_VSOCK_OP_CONNECT);
> +		break;
> +	case VIRTIO_VSOCK_OP_RST:
> +	case VIRTIO_VSOCK_OP_SHUTDOWN:
> +		hdr->op =3D cpu_to_le16(AF_VSOCK_OP_DISCONNECT);
> +		break;
> +	case VIRTIO_VSOCK_OP_RW:
> +		hdr->op =3D cpu_to_le16(AF_VSOCK_OP_PAYLOAD);
> +		break;
> +	case VIRTIO_VSOCK_OP_CREDIT_UPDATE:
> +	case VIRTIO_VSOCK_OP_CREDIT_REQUEST:
> +		hdr->op =3D cpu_to_le16(AF_VSOCK_OP_CONTROL);
> +		break;
> +	default:
> +		hdr->op =3D cpu_to_le16(AF_VSOCK_OP_UNKNOWN);
> +		break;
> +	}
> +
> +	t_hdr =3D skb_put(skb, sizeof(pkt->hdr));
> +	memcpy(t_hdr, &pkt->hdr, sizeof(pkt->hdr));
> +
> +	if (pkt->len) {
> +		payload =3D skb_put(skb, pkt->len);
> +		memcpy(payload, pkt->buf, pkt->len);
> +	}
> +
> +	return skb;
> +}
> +
> +void virtio_transport_deliver_tap_pkt(struct virtio_vsock_pkt *pkt)
> +{
> +	vsock_deliver_tap(virtio_transport_build_skb, pkt);
> +}
> +EXPORT_SYMBOL_GPL(virtio_transport_deliver_tap_pkt);
> +
> static int virtio_transport_send_pkt_info(struct vsock_sock *vsk,
> 					  struct virtio_vsock_pkt_info *info)
> {
> --=20
> 2.9.3
>=20

Reviewed-by: Jorgen Hansen <jhansen@vmware.com>
