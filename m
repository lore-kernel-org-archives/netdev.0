From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next] bpf: fix verifier issue at check_packet_ptr_add
Date: Thu, 2 Feb 2017 22:19:22 -0800
Message-ID: <20170203061920.GB80764@ast-mbp.thefacebook.com>
References: <1486065553-5074-1-git-send-email-u9012063@gmail.com>
 <5893C4DD.9000701@iogearbox.net>
 <CALDO+SZCn452+Tp6cBjMb_J9Mu=08Em=0+jsKpa31b3Eoy-0SQ@mail.gmail.com>
 <20170203034636.GA68213@ast-mbp.thefacebook.com>
 <CALDO+SZrm3KpDDRrC6H9jkaMVxiwUPEFp+1vBaZbSvTdH8=09w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: William Tu <u9012063@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:33577 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752230AbdBCGT0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 01:19:26 -0500
Received: by mail-pf0-f182.google.com with SMTP id y143so3550401pfb.0
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 22:19:25 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CALDO+SZrm3KpDDRrC6H9jkaMVxiwUPEFp+1vBaZbSvTdH8=09w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 02, 2017 at 09:31:06PM -0800, William Tu wrote:
> 
> Yes, this is auto-generated. We want to use P4 2016 as front end to
> generate ebpf for XDP.

P4 2016 front-end ? is it public? Is there a 2017 version? ;)
just curious.

> >
> > The line 272 is r4 += r2
> > where R4=imm4 and R2=pkt_end
> 
> R2 is no longer pkt_end, it's R2 == R0 == 0
> 269: (bf) r2 = r0
> 270: (77) r2 >>= 3
> 271: (bf) r4 = r1
> 272: (0f) r4 += r2
> 
> So at line 272, it's pkt_ptr = pkt_ptr + 0
> thus the following fix works for us.
> -               if (imm <= 0) {
> +               if (imm < 0) {

got it. I forgot that we have:
  if (src_reg->type == CONST_IMM) {
          /* pkt_ptr += reg where reg is known constant */
          imm = src_reg->imm;
          goto add_imm;
  }
and got confused by if (BPF_SRC(insn->code) == BPF_K) bit.
Thanks for explaining!
Could you respin with the extra test for it in the test_verifier.c ?
Since it's a rare case, would be good to keep it working.
