From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 1/5] bpf: Track alignment of register values in the verifier.
Date: Thu, 11 May 2017 14:41:16 +0200
Message-ID: <59145BEC.9040804@iogearbox.net>
References: <20170510.150942.1969073633182798014.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:45311 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754975AbdEKMlY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 11 May 2017 08:41:24 -0400
In-Reply-To: <20170510.150942.1969073633182798014.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/10/2017 09:09 PM, David Miller wrote:
>
> Currently if we add only constant values to pointers we can fully
> validate the alignment, and properly check if we need to reject the
> program on CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS architectures.

Should say: !CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS

> However, once an unknown value is introduced we only allow byte sized
> memory accesses which is too restrictive.
>
> Add logic to track the known minimum alignment of register values,
> and propagate this state into registers containing pointers.
>
> The most common paradigm that makes use of this new logic is computing
> the transport header using the IP header length field.  For example:
>
> 	struct ethhdr *ep = skb->data;
> 	struct iphdr *iph = (struct iphdr *) (ep + 1);
> 	struct tcphdr *th;
>   ...
> 	n = iph->ihl;
> 	th = ((void *)iph + (n * 4));
> 	port = th->dest;
>
> The existing code will reject the load of th->dport because it cannot

s/th->dport/th->dest/

> validate that the alignment is at least 2 once "n * 4" is added the
> the packet pointer.
>
> In the new code, the register holding "n * 4" will have a reg->min_align
> value of 4, because any value multiplied by 4 will be at least 4 byte
> aligned.  (actually, the eBPF code emitted by the compiler in this case
> is most likely to use a shift left by 2, but the end result is identical)
>
> At the critical addition:
>
> 	th = ((void *)iph + (n * 4));
>
> The register holding 'th' will start with reg->off value of 14.  The
> pointer addition will transform that reg into something that looks like:
>
> 	reg->aux_off = 14
> 	reg->aux_off_align = 4
>
> Next, the verifier will look at the th->dest load, and it will see
> a load offset of 2, and first check:
>
> 	if (reg->aux_off_align % size)
>
> which will pass because aux_off_align is 4.  reg_off will be computed:
>
> 	reg_off = reg->off;
>   ...
> 		reg_off += reg->aux_off;
>
> plus we have off==2, and it will thus check:
>
> 	if ((NET_IP_ALIGN + reg_off + off) % size != 0)
>
> which evaluates to:
>
> 	if ((NET_IP_ALIGN + 14 + 2) % size != 0)
>
> On strict alignment architectures, NET_IP_ALIGN is 2, thus:
>
> 	if ((2 + 14 + 2) % size != 0)
>
> which passes.
>
> These pointer transformations and checks work regardless of whether
> the constant offset or the variable with known alignment is added
> first to the pointer register.
>
> Signed-off-by: David S. Miller <davem@davemloft.net>

In adjust_reg_min_max_vals(), don't we also need to call
reset_reg_align() in the 'default' case for the cases where
we use have ALU ops that we don't bother tracking (mod, div,
endianess ops, etc)?

Likewise, for other cases where we do reset_reg_range_values()
which is BPF_LD as class and for the BPF_MOV in check_alu_op(),
which I think, is only relevant when we move reg A to reg B
in 32 bit mode. Perhaps it makes sense to consolidate the reset
on alignment with the reset of min/max values, or do we have
cases where this is undesirable (not that I'm currently aware
of ...)?

But other than that:

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
