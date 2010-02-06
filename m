From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: [PATCH v2 net-next-2.6] packet: Add GSO/csum offload support.
Date: Fri, 5 Feb 2010 17:20:12 -0700
Message-ID: <EA929A9653AAE14F841771FB1DE5A1365FDFE68A89@rrsmsx501.amr.corp.intel.com>
References: <1265239340.5600.21.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev <netdev@vger.kernel.org>
To: Sridhar Samudrala <sri@us.ibm.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:16242 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755923Ab0BFAUP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2010 19:20:15 -0500
In-Reply-To: <1265239340.5600.21.camel@w-sridhar.beaverton.ibm.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sridhar Samudrala wrote:
> This patch adds GSO/checksum offload to af_packet sockets using
> virtio_net_hdr. Based on Rusty's patch to add this support to tun.
> It allows GSO/checksum offload to be enabled when using raw socket
> backend with virtio_net.
> Adds PACKET_VNET_HDR socket option to prepend virtio_net_hdr in the
> receive path and process/skip virtio_net_hdr in the send path. This
> option is only allowed with SOCK_RAW sockets attached to ethernet
> type devices.
> 
> v2 updates
> ----------
> Michael's Comments
> - Perform length check in packet_snd() when GSO is off even when
>   vnet_hdr is present.
> - Check for SKB_GSO_FCOE type and return -EINVAL
> - don't allow tx/rx ring when vnet_hdr is enabled.
> Herbert's Comments
> - Removed ethernet specific code.
> - protocol value is assumed to be passed in by the caller.
> 
> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
> 

<snip>

> @@ -1826,6 +1968,22 @@ packet_setsockopt(struct socket *sock, int
>  		level, int optname, char __user *optv po->origdev = !!val;
>  		return 0;
>  	}
> +	case PACKET_VNET_HDR:
> +	{
> +		int val;
> +
> +		if (sock->type != SOCK_RAW)
> +			return -EINVAL;
> +		if (po->rx_ring.pg_vec || po->tx_ring.pg_vec)

I am seeing a build failure on one of my systems that has kernel with CONFIG_PACKET_MMAP disabled, which appears to be caused by this patch:

net/packet/af_packet.c: In function 'packet_setsockopt':
net/packet/af_packet.c:1977: error: 'struct packet_sock' has no member named 'rx_ring'
net/packet/af_packet.c:1977: error: 'struct packet_sock' has no member named 'tx_ring'

Thanks,
Emil

