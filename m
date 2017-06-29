From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next v4 01/16] bpf: BPF support for sock_ops
Date: Thu, 29 Jun 2017 11:46:11 +0200
Message-ID: <5954CC63.7010707@iogearbox.net>
References: <20170628173124.3299500-1-brakmo@fb.com> <20170628173124.3299500-2-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kernel Team <kernel-team@fb.com>, Blake Matheny <bmatheny@fb.com>,
        Alexei Starovoitov <ast@fb.com>,
        David Ahern <dsa@cumulusnetworks.com>
To: Lawrence Brakmo <brakmo@fb.com>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:45099 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751696AbdF2JqN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 05:46:13 -0400
In-Reply-To: <20170628173124.3299500-2-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/28/2017 07:31 PM, Lawrence Brakmo wrote:
> Created a new BPF program type, BPF_PROG_TYPE_SOCK_OPS, and a corresponding
> struct that allows BPF programs of this type to access some of the
> socket's fields (such as IP addresses, ports, etc.). It uses the
> existing bpf cgroups infrastructure so the programs can be attached per
> cgroup with full inheritance support. The program will be called at
> appropriate times to set relevant connections parameters such as buffer
> sizes, SYN and SYN-ACK RTOs, etc., based on connection information such
> as IP addresses, port numbers, etc.
[...]
> Currently there are two types of ops. The first type expects the BPF
> program to return a value which is then used by the caller (or a
> negative value to indicate the operation is not supported). The second
> type expects state changes to be done by the BPF program, for example
> through a setsockopt BPF helper function, and they ignore the return
> value.
>
> The reply fields of the bpf_sockt_ops struct are there in case a bpf
> program needs to return a value larger than an integer.
>
> Signed-off-by: Lawrence Brakmo <brakmo@fb.com>

For BPF bits:

Acked-by: Daniel Borkmann <daniel@iogearbox.net>

> @@ -3379,6 +3409,140 @@ static u32 xdp_convert_ctx_access(enum bpf_access_type type,
>   	return insn - insn_buf;
>   }
>
> +static u32 sock_ops_convert_ctx_access(enum bpf_access_type type,
> +				       const struct bpf_insn *si,
> +				       struct bpf_insn *insn_buf,
> +				       struct bpf_prog *prog)
> +{
> +	struct bpf_insn *insn = insn_buf;
> +	int off;
> +
> +	switch (si->off) {
[...]
> +	case offsetof(struct bpf_sock_ops, remote_ip4):
> +		BUILD_BUG_ON(FIELD_SIZEOF(struct sock_common, skc_daddr) != 4);
> +
> +		*insn++ = BPF_LDX_MEM(BPF_FIELD_SIZEOF(
> +						struct bpf_sock_ops_kern, sk),
> +				      si->dst_reg, si->src_reg,
> +				      offsetof(struct bpf_sock_ops_kern, sk));
> +		*insn++ = BPF_LDX_MEM(BPF_W, si->dst_reg, si->dst_reg,
> +				      offsetof(struct sock_common, skc_daddr));
> +		*insn++ = BPF_ENDIAN(BPF_FROM_BE, si->dst_reg, 32);
> +		break;
> +
> +	case offsetof(struct bpf_sock_ops, local_ip4):
> +		BUILD_BUG_ON(FIELD_SIZEOF(struct sock_common, skc_rcv_saddr) != 4);
> +
> +		*insn++ = BPF_LDX_MEM(BPF_FIELD_SIZEOF(
> +					      struct bpf_sock_ops_kern, sk),
> +				      si->dst_reg, si->src_reg,
> +				      offsetof(struct bpf_sock_ops_kern, sk));
> +		*insn++ = BPF_LDX_MEM(BPF_W, si->dst_reg, si->dst_reg,
> +				      offsetof(struct sock_common,
> +					       skc_rcv_saddr));
> +		*insn++ = BPF_ENDIAN(BPF_FROM_BE, si->dst_reg, 32);
> +		break;
> +
> +	case offsetof(struct bpf_sock_ops, remote_ip6[0]) ...
> +	     offsetof(struct bpf_sock_ops, remote_ip6[3]):
> +#if IS_ENABLED(CONFIG_IPV6)
> +		BUILD_BUG_ON(FIELD_SIZEOF(struct sock_common,
> +					  skc_v6_daddr.s6_addr32[0]) != 4);
> +
> +		off = si->off;
> +		off -= offsetof(struct bpf_sock_ops, remote_ip6[0]);
> +		*insn++ = BPF_LDX_MEM(BPF_FIELD_SIZEOF(
> +						struct bpf_sock_ops_kern, sk),
> +				      si->dst_reg, si->src_reg,
> +				      offsetof(struct bpf_sock_ops_kern, sk));
> +		*insn++ = BPF_LDX_MEM(BPF_W, si->dst_reg, si->dst_reg,
> +				      offsetof(struct sock_common,
> +					       skc_v6_daddr.s6_addr32[0]) +
> +				      off);
> +		*insn++ = BPF_ENDIAN(BPF_FROM_BE, si->dst_reg, 32);
> +#else
> +		*insn++ = BPF_MOV32_IMM(si->dst_reg, 0);
> +#endif
> +		break;
> +
> +	case offsetof(struct bpf_sock_ops, local_ip6[0]) ...
> +	     offsetof(struct bpf_sock_ops, local_ip6[3]):
> +#if IS_ENABLED(CONFIG_IPV6)
> +		BUILD_BUG_ON(FIELD_SIZEOF(struct sock_common,
> +					  skc_v6_rcv_saddr.s6_addr32[0]) != 4);
> +
> +		off = si->off;
> +		off -= offsetof(struct bpf_sock_ops, local_ip6[0]);
> +		*insn++ = BPF_LDX_MEM(BPF_FIELD_SIZEOF(
> +						struct bpf_sock_ops_kern, sk),
> +				      si->dst_reg, si->src_reg,
> +				      offsetof(struct bpf_sock_ops_kern, sk));
> +		*insn++ = BPF_LDX_MEM(BPF_W, si->dst_reg, si->dst_reg,
> +				      offsetof(struct sock_common,
> +					       skc_v6_rcv_saddr.s6_addr32[0]) +
> +				      off);
> +		*insn++ = BPF_ENDIAN(BPF_FROM_BE, si->dst_reg, 32);
> +#else
> +		*insn++ = BPF_MOV32_IMM(si->dst_reg, 0);
> +#endif
> +		break;
> +
> +	case offsetof(struct bpf_sock_ops, remote_port):
> +		BUILD_BUG_ON(FIELD_SIZEOF(struct sock_common, skc_dport) != 2);
> +
> +		*insn++ = BPF_LDX_MEM(BPF_FIELD_SIZEOF(
> +						struct bpf_sock_ops_kern, sk),
> +				      si->dst_reg, si->src_reg,
> +				      offsetof(struct bpf_sock_ops_kern, sk));
> +		*insn++ = BPF_LDX_MEM(BPF_H, si->dst_reg, si->dst_reg,
> +				      offsetof(struct sock_common, skc_dport));
> +		*insn++ = BPF_ENDIAN(BPF_FROM_BE, si->dst_reg, 16);
> +		break;
> +
> +	case offsetof(struct bpf_sock_ops, local_port):
> +		BUILD_BUG_ON(FIELD_SIZEOF(struct sock_common, skc_num) != 2);
> +
> +		*insn++ = BPF_LDX_MEM(BPF_FIELD_SIZEOF(
> +						struct bpf_sock_ops_kern, sk),
> +				      si->dst_reg, si->src_reg,
> +				      offsetof(struct bpf_sock_ops_kern, sk));
> +		*insn++ = BPF_LDX_MEM(BPF_H, si->dst_reg, si->dst_reg,
> +				      offsetof(struct sock_common, skc_num));

That one is indeed in host endianness. Makes sense to have remote_port
and local_port in a consistent representation.

I was wondering though whether we should do all the conversion of
BPF_ENDIAN(BPF_FROM_BE, ...) or just leave it to the user whether
he needs the BPF_ENDIAN(BPF_FROM_BE, ...) or process it in network
byte order as-is. In case the user needs to go and undo again via
BPF_ENDIAN(BPF_TO_BE, ...), e.g., to reconstruct a full v6 addr,
then we have two unneeded insns for each of the remote_ip6[X] /
local_ip6[X]. So, not providing it in host byte order, the user can
still always chose to do a BPF_ENDIAN(BPF_FROM_BE, ...) by himself,
if this representation is preferred. Wdyt?

> +		break;
> +	}
> +	return insn - insn_buf;
> +}
> +
>   const struct bpf_verifier_ops sk_filter_prog_ops = {
>   	.get_func_proto		= sk_filter_func_proto,
[...]
