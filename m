From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH v6 01/12] bpf: add XDP prog type for early driver filter
Date: Sat, 9 Jul 2016 10:14:03 +0200
Message-ID: <20160709101403.1ed7d021@redhat.com>
References: <1467944124-14891-1-git-send-email-bblanco@plumgrid.com>
	<1467944124-14891-2-git-send-email-bblanco@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Martin KaFai Lau <kafai@fb.com>, Ari Saha <as754m@att.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Or Gerlitz <gerlitz.or@gmail.com>, john.fastabend@gmail.com,
	hannes@stressinduktion.org, Thomas Graf <tgraf@suug.ch>,
	Tom Herbert <tom@herbertland.com>,
	Daniel Borkmann <daniel@iogearbox.net>, brouer@redhat.com
To: Brenden Blanco <bblanco@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38105 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750948AbcGIIOQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jul 2016 04:14:16 -0400
In-Reply-To: <1467944124-14891-2-git-send-email-bblanco@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  7 Jul 2016 19:15:13 -0700
Brenden Blanco <bblanco@plumgrid.com> wrote:

> Add a new bpf prog type that is intended to run in early stages of the
> packet rx path. Only minimal packet metadata will be available, hence a
> new context type, struct xdp_md, is exposed to userspace. So far only
> expose the packet start and end pointers, and only in read mode.
> 
> An XDP program must return one of the well known enum values, all other
> return codes are reserved for future use. Unfortunately, this
> restriction is hard to enforce at verification time, so take the
> approach of warning at runtime when such programs are encountered. The
> driver can choose to implement unknown return codes however it wants,
> but must invoke the warning helper with the action value.

I believe we should define a stronger semantics for unknown/future
return codes than the once stated above:
 "driver can choose to implement unknown return codes however it wants"

The mlx4 driver implementation in:
 [PATCH v6 04/12] net/mlx4_en: add support for fast rx drop bpf program

On Thu,  7 Jul 2016 19:15:16 -0700 Brenden Blanco <bblanco@plumgrid.com> wrote:

> +		/* A bpf program gets first chance to drop the packet. It may
> +		 * read bytes but not past the end of the frag.
> +		 */
> +		if (prog) {
> +			struct xdp_buff xdp;
> +			dma_addr_t dma;
> +			u32 act;
> +
> +			dma = be64_to_cpu(rx_desc->data[0].addr);
> +			dma_sync_single_for_cpu(priv->ddev, dma,
> +						priv->frag_info[0].frag_size,
> +						DMA_FROM_DEVICE);
> +
> +			xdp.data = page_address(frags[0].page) +
> +							frags[0].page_offset;
> +			xdp.data_end = xdp.data + length;
> +
> +			act = bpf_prog_run_xdp(prog, &xdp);
> +			switch (act) {
> +			case XDP_PASS:
> +				break;
> +			default:
> +				bpf_warn_invalid_xdp_action(act);
> +			case XDP_DROP:
> +				goto next;
> +			}
> +		}

Thus, mlx4 choice is to drop packets for unknown/future return codes.

I think this is the wrong choice.  I think the choice should be
XDP_PASS, to pass the packet up the stack.

I find "XDP_DROP" problematic because it happen so early in the driver,
that we lost all possibilities to debug what packets gets dropped.  We
get a single kernel log warning, but we cannot inspect the packets any
longer.  By defaulting to XDP_PASS all the normal stack tools (e.g.
tcpdump) is available.


I can also imagine that, defaulting to XDP_PASS, can be an important
feature in the future.

In the future we will likely have features, where XDP can "offload"
packet delivery from the normal stack (e.g. delivery into a VM).  On a
running production system you can then load your XDP program.  If the
driver was too old defaulting to XDP_DROP, then you lost your service,
instead if defaulting to XDP_PASS, your service would survive, falling
back to normal delivery.

(For the VM delivery use-case, there will likely be a need for having a
fallback delivery method in place, when the XDP program is not active,
in-order to support VM migration).



> diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
> index c14ca1c..5b47ac3 100644
> --- a/include/uapi/linux/bpf.h
> +++ b/include/uapi/linux/bpf.h
[...]
>  
> +/* User return codes for XDP prog type.
> + * A valid XDP program must return one of these defined values. All other
> + * return codes are reserved for future use. Unknown return codes will result
> + * in driver-dependent behavior.
> + */
> +enum xdp_action {
> +	XDP_DROP,
> +	XDP_PASS,
> +};
> +
[...]
>  #endif /* _UAPI__LINUX_BPF_H__ */
> diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
> index e206c21..a8d67d0 100644
> --- a/kernel/bpf/verifier.c
> +++ b/kernel/bpf/verifier.c
[...]
> +void bpf_warn_invalid_xdp_action(int act)
> +{
> +	WARN_ONCE(1, "\n"
> +		     "*****************************************************\n"
> +		     "**   NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE   **\n"
> +		     "**                                               **\n"
> +		     "** XDP program returned unknown value %-10u **\n"
> +		     "**                                               **\n"
> +		     "** XDP programs must return a well-known return  **\n"
> +		     "** value. Invalid return values will result in   **\n"
> +		     "** undefined packet actions.                     **\n"
> +		     "**                                               **\n"
> +		     "**   NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE   **\n"
> +		     "*****************************************************\n",
> +		  act);
> +}
> +EXPORT_SYMBOL_GPL(bpf_warn_invalid_xdp_action);
> +


-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
