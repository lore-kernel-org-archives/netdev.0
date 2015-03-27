From: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Subject: Re: [PATCH net-next] tc: bpf: generalize pedit action
Date: Fri, 27 Mar 2015 11:42:45 +0100
Message-ID: <55153425.2070502@iogearbox.net>
References: <1427424837-7757-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>, Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1427424837-7757-1-git-send-email-ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 03/27/2015 03:53 AM, Alexei Starovoitov wrote:
> existing TC action 'pedit' can munge any bits of the packet.
> Generalize it for use in bpf programs attached as cls_bpf and act_bpf via
> bpf_skb_store_bytes() helper function.
>
> Signed-off-by: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>

I like it.

> pedit is limited to 32-bit masked rewrites. Here let it be flexible.
>
> ptr = skb_header_pointer(skb, offset, len, buf);
> memcpy(ptr, from, len);
> if (ptr == buf)
>    skb_store_bits(skb, offset, ptr, len);
>
> ^^ logic is the same as in pedit.
> shifts, mask, invert style of rewrite is easily done by the program.
> Just like arbitrary parsing of the packet and applying rewrites on demand.
...
> +static u64 bpf_skb_store_bytes(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
> +{
> +	struct sk_buff *skb = (struct sk_buff *) (long) r1;
> +	unsigned int offset = (unsigned int) r2;
> +	void *from = (void *) (long) r3;
> +	unsigned int len = (unsigned int) r4;
> +	char buf[16];
> +	void *ptr;
> +
> +	/* bpf verifier guarantees that:
> +	 * 'from' pointer points to bpf program stack
> +	 * 'len' bytes of it were initialized
> +	 * 'len' > 0
> +	 * 'skb' is a valid pointer to 'struct sk_buff'
> +	 *
> +	 * so check for invalid 'offset' and too large 'len'
> +	 */
> +	if (offset > 0xffff || len > sizeof(buf))
> +		return -EFAULT;

Could you elaborate on the hard-coded 0xffff? Hm, perhaps better u16, or
do you see any issues with wrong widening?

This check should probably be also unlikely().

Ok, the sizeof(buf) could still be increased in future if truly necessary.

> +	if (skb_cloned(skb) && !skb_clone_writable(skb, offset + len))
> +		return -EFAULT;
> +
> +	ptr = skb_header_pointer(skb, offset, len, buf);
> +	if (unlikely(!ptr))
> +		return -EFAULT;
> +
> +	skb_postpull_rcsum(skb, ptr, len);
> +
> +	memcpy(ptr, from, len);
> +
> +	if (ptr == buf)
> +		/* skb_store_bits cannot return -EFAULT here */
> +		skb_store_bits(skb, offset, ptr, len);
> +
> +	if (skb->ip_summed == CHECKSUM_COMPLETE)
> +		skb->csum = csum_add(skb->csum, csum_partial(ptr, len, 0));

For egress, I think that CHECKSUM_PARTIAL does not need to be dealt
with since the skb length doesn't change. Do you see an issue when
cls_bpf/act_bpf would be attached to the ingress qdisc?

I was also thinking if it's worth it to split off the csum correction
as a separate function if there are not too big performance implications?

That way, an action may also allow to intentionally test corruption of
a part of the skb data together with the recent prandom function.

> +	return 0;
> +}
> +
> +const struct bpf_func_proto bpf_skb_store_bytes_proto = {
> +	.func		= bpf_skb_store_bytes,
> +	.gpl_only	= false,
> +	.ret_type	= RET_INTEGER,
> +	.arg1_type	= ARG_PTR_TO_CTX,
> +	.arg2_type	= ARG_ANYTHING,
> +	.arg3_type	= ARG_PTR_TO_STACK,
> +	.arg4_type	= ARG_CONST_STACK_SIZE,
> +};
