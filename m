From: Alexei Starovoitov <ast@fb.com>
Subject: Re: LLVM 4.0 code generation bug
Date: Mon, 1 May 2017 19:39:33 -0700
Message-ID: <e75404e5-c68d-6f08-afdc-e57174b88a32@fb.com>
References: <20170501.223136.1311890506697006266.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <daniel@iogearbox.net>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:36624 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750847AbdEBCjw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 22:39:52 -0400
In-Reply-To: <20170501.223136.1311890506697006266.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/1/17 7:31 PM, David Miller wrote:
>
> If the last BPF instruction before exit is a ldimm64, branches to the
> exit point at the wrong location.
>
> Here is what I get from test_pkt_access.c on sparc:
>
> 0000000000000000 <process>:
>    0:	b7 00 00 00 00 00 00 02 	mov	r0, 2
>    8:	61 21 00 50 00 00 00 00 	ldw	r2, [r1+80]
>   10:	61 11 00 4c 00 00 00 00 	ldw	r1, [r1+76]
>   18:	bf 41 00 00 00 00 00 00 	mov	r4, r1
>   20:	07 40 00 00 00 00 00 0e 	add	r4, 14
>   28:	2d 42 00 25 00 00 00 00 	jgt	r4, r2, 148 <LBB0_11>
>  ...
> 0000000000000148 <LBB0_11>:
>  148:	18 00 00 00 ff ff ff ff 	ldimm64	r0, 4294967295
>  150:	00 00 00 00 00 00 00 00
>
> 0000000000000158 <LBB0_12>:
>  158:	95 00 00 00 00 00 00 00 	exit	
>
> The offset field in the "jgt" instruction is 0x25 which multiplied by
> 8 is 0x128, add 0x128 to the instruction location which is 0x28, and
> we get 0x150, which is the second 64-bit chunk of the ldimm64
> instruction.

looks fine to me. it jumps to 0x158,
since offset 0 is the next insn after jump which is 0x30
That's how classic bpf defined jumps.
