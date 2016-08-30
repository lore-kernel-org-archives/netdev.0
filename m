From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [RFCv2 07/16] bpf: enable non-core use of the verfier
Date: Tue, 30 Aug 2016 12:48:54 +0200
Message-ID: <20160830124854.76e5a1c3@laptop>
References: <1472234775-29453-1-git-send-email-jakub.kicinski@netronome.com>
        <1472234775-29453-8-git-send-email-jakub.kicinski@netronome.com>
        <20160826232904.GA28873@ast-mbp.thefacebook.com>
        <20160827124004.43728202@jkicinski-Precision-T1700>
        <20160827173250.GA38477@ast-mbp>
        <57C4976C.4010501@iogearbox.net>
        <57C49846.1080608@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        netdev@vger.kernel.org, ast@kernel.org,
        dinan.gunawardena@netronome.com, jiri@resnulli.us,
        john.fastabend@gmail.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.wp.pl ([212.77.101.10]:16927 "EHLO mx3.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753282AbcH3KtB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 30 Aug 2016 06:49:01 -0400
In-Reply-To: <57C49846.1080608@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 29 Aug 2016 22:17:10 +0200, Daniel Borkmann wrote:
> On 08/29/2016 10:13 PM, Daniel Borkmann wrote:
> > On 08/27/2016 07:32 PM, Alexei Starovoitov wrote:  
> >> On Sat, Aug 27, 2016 at 12:40:04PM +0100, Jakub Kicinski wrote:  
> >> probably array_of_insn_aux_data[num_insns] should do it.
> >> Unlike reg_state that is forked on branches, this array
> >> is only one.  
> >
> > This would be for struct nfp_insn_meta, right? So, struct
> > bpf_ext_parser_ops could become:
> >
> > static const struct bpf_ext_parser_ops nfp_bpf_pops = {
> >      .insn_hook = nfp_verify_insn,
> >      .insn_size = sizeof(struct nfp_insn_meta),
> > };
> >
> > ... where bpf_parse() would prealloc that f.e. in env->insn_meta[].  

Hm.. this is tempting, I will have to store the pointer type in
nfp_insn_meta soon, anyway.

> (Well, actually everything can live in env->private_data.)

We are discussing changing the place verifier keep its pointer type
annotation, I don't think we could put that in the private_data.

> > Agree, was also my concern when I read patch 5 and 6. It would
> > not only be related to types, but also different imm values,
> > where the memcmp() could fail on. Potentially the latter can be
> > avoided by only checking types which should be sufficient. Hmm,
> > maybe only bpf_parse() should go through this stricter mode since
> > only relevant for drivers (otoh downside would be that bugs
> > would end up less likely to be found).

I don't want only checking types because it would defeat my exit code
validation :)  I was thinking about doing a lazy evaluation -
registering branches to explored_states with UNKNOWN and only upgrading
to CONST when someone actually needed the imm value.  I'm not sure the
complexity would be justified, though.

Having two modes seems more straight forward and I think we would only
need to pay attention in the LD_IMM64 case, I don't think I've seen
LLVM generating XORs, it's just the cBPF -> eBPF conversion.

> >> I see. Indeed then you'd need the verifier to walk all paths
> >> to make sure constant return values.  
> >
> > I think this would still not cover the cases where you'd fetch
> > a return value/verdict from a map, but this should be ignored/
> > rejected for now, also since majority of programs are not written
> > in such a way.
> >  
> >> If you only need yes/no check then such info can probably be
> >> collected unconditionally during initial program load.
> >> Like prog->cb_access flag.  
> >
> > One other comment wrt the header, when you move these things
> > there, would be good to prefix with bpf_* so that this doesn't
> > clash in future with other header files.  

Good point!
