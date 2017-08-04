From: Michael Holzheu <holzheu@linux.vnet.ibm.com>
Subject: Re: [PATCH net 1/2] bpf, s390: fix jit branch offset related to
 ldimm64
Date: Fri, 4 Aug 2017 15:44:20 +0200
Message-ID: <20170804154420.6faae20a@TP-holzheu>
References: <cover.1501848914.git.daniel@iogearbox.net>
        <a63b808ceaa481dfae896bcf611fc489fdc59080.1501848914.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, ast@fb.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:43494 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752153AbdHDNoZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2017 09:44:25 -0400
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v74DiI4c047914
        for <netdev@vger.kernel.org>; Fri, 4 Aug 2017 09:44:24 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2c4r42ypp2-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 04 Aug 2017 09:44:24 -0400
Received: from localhost
        by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <holzheu@linux.vnet.ibm.com>;
        Fri, 4 Aug 2017 14:44:23 +0100
In-Reply-To: <a63b808ceaa481dfae896bcf611fc489fdc59080.1501848914.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Fri,  4 Aug 2017 14:20:54 +0200
schrieb Daniel Borkmann <daniel@iogearbox.net>:

> While testing some other work that required JIT modifications, I
> run into test_bpf causing a hang when JIT enabled on s390. The
> problematic test case was the one from ddc665a4bb4b (bpf, arm64:
> fix jit branch offset related to ldimm64), and turns out that we
> do have a similar issue on s390 as well. In bpf_jit_prog() we
> update next instruction address after returning from bpf_jit_insn()
> with an insn_count. bpf_jit_insn() returns either -1 in case of
> error (e.g. unsupported insn), 1 or 2. The latter is only the
> case for ldimm64 due to spanning 2 insns, however, next address
> is only set to i + 1 not taking actual insn_count into account,
> thus fix is to use insn_count instead of 1. bpf_jit_enable in
> mode 2 provides also disasm on s390:
> 
> Before fix:
> 
>   000003ff800349b6: a7f40003   brc     15,3ff800349bc                 ; target
>   000003ff800349ba: 0000               unknown
>   000003ff800349bc: e3b0f0700024       stg     %r11,112(%r15)
>   000003ff800349c2: e3e0f0880024       stg     %r14,136(%r15)
>   000003ff800349c8: 0db0               basr    %r11,%r0
>   000003ff800349ca: c0ef00000000       llilf   %r14,0
>   000003ff800349d0: e320b0360004       lg      %r2,54(%r11)
>   000003ff800349d6: e330b03e0004       lg      %r3,62(%r11)
>   000003ff800349dc: ec23ffeda065       clgrj   %r2,%r3,10,3ff800349b6 ; jmp
>   000003ff800349e2: e3e0b0460004       lg      %r14,70(%r11)
>   000003ff800349e8: e3e0b04e0004       lg      %r14,78(%r11)
>   000003ff800349ee: b904002e   lgr     %r2,%r14
>   000003ff800349f2: e3b0f0700004       lg      %r11,112(%r15)
>   000003ff800349f8: e3e0f0880004       lg      %r14,136(%r15)
>   000003ff800349fe: 07fe               bcr     15,%r14
> 
> After fix:
> 
>   000003ff80ef3db4: a7f40003   brc     15,3ff80ef3dba
>   000003ff80ef3db8: 0000               unknown
>   000003ff80ef3dba: e3b0f0700024       stg     %r11,112(%r15)
>   000003ff80ef3dc0: e3e0f0880024       stg     %r14,136(%r15)
>   000003ff80ef3dc6: 0db0               basr    %r11,%r0
>   000003ff80ef3dc8: c0ef00000000       llilf   %r14,0
>   000003ff80ef3dce: e320b0360004       lg      %r2,54(%r11)
>   000003ff80ef3dd4: e330b03e0004       lg      %r3,62(%r11)
>   000003ff80ef3dda: ec230006a065       clgrj   %r2,%r3,10,3ff80ef3de6 ; jmp
>   000003ff80ef3de0: e3e0b0460004       lg      %r14,70(%r11)
>   000003ff80ef3de6: e3e0b04e0004       lg      %r14,78(%r11)          ; target
>   000003ff80ef3dec: b904002e   lgr     %r2,%r14
>   000003ff80ef3df0: e3b0f0700004       lg      %r11,112(%r15)
>   000003ff80ef3df6: e3e0f0880004       lg      %r14,136(%r15)
>   000003ff80ef3dfc: 07fe               bcr     15,%r14
> 
> test_bpf.ko suite runs fine after the fix.
> 
> Fixes: 054623105728 ("s390/bpf: Add s390x eBPF JIT compiler backend")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Tested-by: Michael Holzheu <holzheu@linux.vnet.ibm.com>

What about "Cc: stable@vger.kernel.org"?

Michael
