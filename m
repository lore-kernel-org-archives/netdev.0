From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH v2 2/5] net: add ndo to set bpf prog in adapter rx
Date: Fri, 8 Apr 2016 11:38:58 +0200
Message-ID: <20160408113858.4d39b274@redhat.com>
References: <1460090930-11219-1-git-send-email-bblanco@plumgrid.com>
	<1460090930-11219-2-git-send-email-bblanco@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, tom@herbertland.com,
	alexei.starovoitov@gmail.com, ogerlitz@mellanox.com,
	daniel@iogearbox.net, eric.dumazet@gmail.com, ecree@solarflare.com,
	john.fastabend@gmail.com, tgraf@suug.ch, johannes@sipsolutions.net,
	eranlinuxmellanox@gmail.com, lorenzo@google.com, brouer@redhat.com
To: Brenden Blanco <bblanco@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56138 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758004AbcDHJjV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Apr 2016 05:39:21 -0400
In-Reply-To: <1460090930-11219-2-git-send-email-bblanco@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu,  7 Apr 2016 21:48:47 -0700 Brenden Blanco <bblanco@plumgrid.com> wrote:

> Add two new set/get netdev ops for drivers implementing the
> BPF_PROG_TYPE_PHYS_DEV filter.
> 
> Signed-off-by: Brenden Blanco <bblanco@plumgrid.com>
[...]
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index cb4e508..3acf732 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
[...]
> @@ -1102,6 +1103,14 @@ struct tc_to_netdev {
>   *	appropriate rx headroom value allows avoiding skb head copy on
>   *	forward. Setting a negative value resets the rx headroom to the
>   *	default value.
> + * int  (*ndo_bpf_set)(struct net_device *dev, struct bpf_prog *prog);
> + *	This function is used to set or clear a bpf program used in the
> + *	earliest stages of packet rx. The prog will have been loaded as
> + *	BPF_PROG_TYPE_PHYS_DEV. The callee is responsible for calling
> + *	bpf_prog_put on any old progs that are stored, but not on the passed
> + *	in prog.
> + * bool (*ndo_bpf_get)(struct net_device *dev);
> + *	This function is used to check if a bpf program is set on the device.
>   *

This interface for the entire device, right.  I can imagine that users
want to attach a eBPF program per RX queue.  Can we adapt the interface
to support this? (could default to adding it all queues)


I'm also wondering if we should add a "flags" parameter.  Or maybe we
can extend 'struct bpf_prog' with I have in mind.

When the eBPF program is attached to a RX queue, I want to know if the
program want to modify packet-data, up-front.

The problem is that most drivers use dma_sync, which means that data is
considered 'read-only' (the "considered" part depend on DMA engine, and
we might find a DMA loop-hole for some configs).
  If the program want to write, the driver have the option of
reconfiguring the driver routine to use dma_unmap, before handing over
the page.  Or driver can also choose to realloc the specific RX ring
queue pages as single pages (using dma_map/unmap consistently).
 This also allow us to give a return code indicating given driver does
not support writable packet-pages (rejecting program).

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
