From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 3/5] virtio: Don't expose legacy net features when
 VIRTIO_NET_NO_LEGACY defined.
Date: Mon, 16 Feb 2015 06:14:35 +0100
Message-ID: <20150216051435.GA14616@redhat.com>
References: <1423199216-2094-1-git-send-email-rusty@rustcorp.com.au>
 <1423199216-2094-4-git-send-email-rusty@rustcorp.com.au>
 <20150208105908.GI3185@redhat.com>
 <87fvag3qv3.fsf@rustcorp.com.au>
 <87twytb9by.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lkml <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87twytb9by.fsf@rustcorp.com.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>  	struct virtio_net_hdr hdr;
>  	__virtio16 num_buffers;	/* Number of merged rx buffers */
>  };
> +#else /* ... VIRTIO_NET_NO_LEGACY */
> +/*
> + * This header comes first in the scatter-gather list.  If you don't
> + * specify GSO or CSUM features, you can simply ignore the header.
> + *
> + * This is bitwise-equivalent to the legacy struct virtio_net_hdr_mrg_rxbuf.

I would add "but with all fields squashed into the main structure".

> + */
> +struct virtio_net_hdr_v1 {
> +#define VIRTIO_NET_HDR_F_NEEDS_CSUM	1	/* Use csum_start, csum_offset */
> +#define VIRTIO_NET_HDR_F_DATA_VALID	2	/* Csum is valid */
> +	__u8 flags;
> +#define VIRTIO_NET_HDR_GSO_NONE		0	/* Not a GSO frame */
> +#define VIRTIO_NET_HDR_GSO_TCPV4	1	/* GSO frame, IPv4 TCP (TSO) */
> +#define VIRTIO_NET_HDR_GSO_UDP		3	/* GSO frame, IPv4 UDP (UFO) */
> +#define VIRTIO_NET_HDR_GSO_TCPV6	4	/* GSO frame, IPv6 TCP */
> +#define VIRTIO_NET_HDR_GSO_ECN		0x80	/* TCP has ECN set */
> +	__u8 gso_type;
> +	__virtio16 hdr_len;	/* Ethernet + IP + tcp/udp hdrs */
> +	__virtio16 gso_size;	/* Bytes to append to hdr_len per frame */
> +	__virtio16 csum_start;	/* Position to start checksumming from */
> +	__virtio16 csum_offset;	/* Offset after that to place checksum */
> +	__virtio16 num_buffers;	/* Number of merged rx buffers */
> +};
> +#endif /* ...VIRTIO_NET_NO_LEGACY */

I note that this way host code can't be structured like this:


	struct virtio_net_hdr_v1 modern;
	/* handle modern guests */
	....

#ifndef VIRTIO_NET_NO_LEGACY
	struct virtio_net_hdr_mrg_rxbuf mrg;
	/* handle legacy guests */
	
#endif


Define virtio_net_hdr_v1 unconditionally?










>  /*
>   * Control virtqueue data structures
