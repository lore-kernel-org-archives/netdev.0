From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v3 2/3] VSOCK: Add vsockmon device
Date: Wed, 12 Apr 2017 19:43:20 +0300
Message-ID: <20170412193827-mutt-send-email-mst@kernel.org>
References: <20170412160825.21037-1-stefanha@redhat.com>
 <20170412160825.21037-3-stefanha@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Zhu Yanjun <zyjzyj2000@gmail.com>,
        Gerard Garcia <ggarcia@abra.uab.cat>,
        Jorgen Hansen <jhansen@vmware.com>
To: Stefan Hajnoczi <stefanha@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42320 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754805AbdDLQnX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 12 Apr 2017 12:43:23 -0400
Content-Disposition: inline
In-Reply-To: <20170412160825.21037-3-stefanha@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 12, 2017 at 05:08:24PM +0100, Stefan Hajnoczi wrote:
> From: Gerard Garcia <ggarcia@deic.uab.cat>
> 
> Add vsockmon virtual network device that receives packets from the vsock
> transports and exposes them to user space.
> 
> Based on the nlmon device.
> 
> Signed-off-by: Gerard Garcia <ggarcia@deic.uab.cat>
> Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
> ---
> v3:
>  * Fix DEFAULT_MTU macro definition [Zhu Yanjun]
>  * Rename af_vsockmon_hdr->t field ->transport for clarity
>  * Update .ndo_get_stats64() return type since it has changed
> ---
>  drivers/net/Makefile          |   1 +
>  include/uapi/linux/vsockmon.h |  57 ++++++++++++++
>  drivers/net/vsockmon.c        | 167 ++++++++++++++++++++++++++++++++++++++++++
>  drivers/net/Kconfig           |   8 ++
>  include/uapi/linux/Kbuild     |   1 +
>  5 files changed, 234 insertions(+)
>  create mode 100644 include/uapi/linux/vsockmon.h
>  create mode 100644 drivers/net/vsockmon.c
> 
> diff --git a/drivers/net/Makefile b/drivers/net/Makefile
> index 98ed4d9..2d54930 100644
> --- a/drivers/net/Makefile
> +++ b/drivers/net/Makefile
> @@ -30,6 +30,7 @@ obj-$(CONFIG_GENEVE) += geneve.o
>  obj-$(CONFIG_GTP) += gtp.o
>  obj-$(CONFIG_NLMON) += nlmon.o
>  obj-$(CONFIG_NET_VRF) += vrf.o
> +obj-$(CONFIG_VSOCKMON) += vsockmon.o
>  
>  #
>  # Networking Drivers
> diff --git a/include/uapi/linux/vsockmon.h b/include/uapi/linux/vsockmon.h
> new file mode 100644
> index 0000000..484e59e
> --- /dev/null
> +++ b/include/uapi/linux/vsockmon.h
> @@ -0,0 +1,57 @@
> +#ifndef _UAPI_VSOCKMON_H
> +#define _UAPI_VSOCKMON_H
> +
> +#include <linux/virtio_vsock.h>
> +
> +/*
> + * vsockmon is the AF_VSOCK packet capture device.  Packets captured have the
> + * following layout:
> + *
> + *   +-----------------------------------+
> + *   |           vsockmon header         |
> + *   |      (struct af_vsockmon_hdr)     |
> + *   +-----------------------------------+
> + *   |          transport header         |
> + *   | (af_vsockmon_hdr->len bytes long) |
> + *   +-----------------------------------+
> + *   |              payload              |
> + *   |       (until end of packet)       |
> + *   +-----------------------------------+
> + *
> + * The vsockmon header is a transport-independent description of the packet.
> + * It duplicates some of the information from the transport header so that
> + * no transport-specific knowledge is necessary to process packets.
> + *
> + * The transport header is useful for low-level transport-specific packet
> + * analysis.  Transport type is given in af_vsockmon_hdr->transport and
> + * transport header length is given in af_vsockmon_hdr->len.
> + *
> + * If af_vsockmon_hdr->op is AF_VSOCK_OP_PAYLOAD then the payload follows the
> + * transport header.  Other ops do not have a payload.
> + */
> +
> +struct af_vsockmon_hdr {
> +	__le64 src_cid;
> +	__le64 dst_cid;
> +	__le32 src_port;
> +	__le32 dst_port;
> +	__le16 op;			/* enum af_vsockmon_op */
> +	__le16 transport;		/* enum af_vsockmon_transport */
> +	__le16 len;			/* Transport header length */
> +} __attribute__((packed));

I'd add a 2 byte padding here and then you do not need to pack it.
