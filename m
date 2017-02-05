From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATHv3 net-next] bpf: enable verifier to add 0 to packet ptr
Date: Sat, 4 Feb 2017 18:53:47 -0800
Message-ID: <20170205025345.GB73775@ast-mbp.thefacebook.com>
References: <1486226249-1851-1-git-send-email-u9012063@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Mihai Budiu <mbudiu@vmware.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <ast@kernel.org>
To: William Tu <u9012063@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34420 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751453AbdBECxw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2017 21:53:52 -0500
Received: by mail-pf0-f194.google.com with SMTP id y143so4324411pfb.1
        for <netdev@vger.kernel.org>; Sat, 04 Feb 2017 18:53:51 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1486226249-1851-1-git-send-email-u9012063@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 04, 2017 at 08:37:29AM -0800, William Tu wrote:
> The patch fixes the case when adding a zero value to the packet
> pointer.  The zero value could come from src_reg equals type
> BPF_K or CONST_IMM.  The patch fixes both, otherwise the verifer
> reports the following error:
>   [...]
>     R0=imm0,min_value=0,max_value=0
>     R1=pkt(id=0,off=0,r=4)
>     R2=pkt_end R3=fp-12
>     R4=imm4,min_value=4,max_value=4
>     R5=pkt(id=0,off=4,r=4)
>   269: (bf) r2 = r0     // r2 becomes imm0
>   270: (77) r2 >>= 3
>   271: (bf) r4 = r1     // r4 becomes pkt ptr
>   272: (0f) r4 += r2    // r4 += 0
>   addition of negative constant to packet pointer is not allowed
> 
> Signed-off-by: William Tu <u9012063@gmail.com>
> Signed-off-by: Mihai Budiu <mbudiu@vmware.com>
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Cc: Alexei Starovoitov <ast@kernel.org>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>
...
> +		"direct packet access: test14 (pkt_ptr += 0, CONST_IMM, good access)",
> +		.insns = {
> +			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
> +				    offsetof(struct __sk_buff, data)),
> +			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
> +				    offsetof(struct __sk_buff, data_end)),
> +			BPF_MOV64_REG(BPF_REG_0, BPF_REG_2),
> +			BPF_ALU64_IMM(BPF_ADD, BPF_REG_0, 22),
> +			BPF_JMP_REG(BPF_JGT, BPF_REG_0, BPF_REG_3, 7),
> +			BPF_MOV64_IMM(BPF_REG_5, 12),
> +			BPF_ALU64_IMM(BPF_RSH, BPF_REG_5, 4),
> +			BPF_MOV64_REG(BPF_REG_6, BPF_REG_2),
> +			BPF_ALU64_REG(BPF_ADD, BPF_REG_6, BPF_REG_5),
> +			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_6, 0),

Now looks great. Thanks!
Acked-by: Alexei Starovoitov <ast@kernel.org>
