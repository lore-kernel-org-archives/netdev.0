From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [RFCv2 03/16] net: cls_bpf: limit hardware offload by
 software-only flag
Date: Mon, 29 Aug 2016 17:15:31 +0200
Message-ID: <20160829171531.3031b100@laptop>
References: <1472234775-29453-1-git-send-email-jakub.kicinski@netronome.com>
        <1472234775-29453-4-git-send-email-jakub.kicinski@netronome.com>
        <57C44F7A.5060501@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>,
        netdev@vger.kernel.org, ast@kernel.org,
        dinan.gunawardena@netronome.com, jiri@resnulli.us,
        john.fastabend@gmail.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.12]:55912 "EHLO mx4.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757584AbcH2PPk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 29 Aug 2016 11:15:40 -0400
In-Reply-To: <57C44F7A.5060501@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 29 Aug 2016 17:06:34 +0200, Daniel Borkmann wrote:
> On 08/26/2016 08:06 PM, Jakub Kicinski wrote:
> > [...]
> > @@ -372,6 +377,7 @@ static int cls_bpf_modify_existing(struct net *net, struct tcf_proto *tp,
> >   {
> >   	bool is_bpf, is_ebpf, have_exts = false;
> >   	struct tcf_exts exts;
> > +	u32 gen_flags = 0;
> >   	int ret;
> >
> >   	is_bpf = tb[TCA_BPF_OPS_LEN] && tb[TCA_BPF_OPS];
> > @@ -396,8 +402,16 @@ static int cls_bpf_modify_existing(struct net *net, struct tcf_proto *tp,
> >
> >   		have_exts = bpf_flags & TCA_BPF_FLAG_ACT_DIRECT;
> >   	}
> > +	if (tb[TCA_BPF_FLAGS_GEN]) {
> > +		gen_flags = nla_get_u32(tb[TCA_BPF_FLAGS_GEN]);
> > +		/* Make sure dump doesn't report back flags we don't handle */
> > +		gen_flags &= CLS_BPF_SUPPORTED_GEN_FLAGS;  
> 
> Instead of above rather ...
> 
> 	if (gen_flags & ~CLS_BPF_SUPPORTED_GEN_FLAGS) {
> 		ret = -EINVAL;
> 		goto errout;
> 	}
> 
> ... so that we can handle further additions properly like we do with
> tb[TCA_BPF_FLAGS]?

Sure!

> > +		if (!tc_flags_valid(gen_flags))
> > +			return -EINVAL;  
> 
> Shouldn't we: goto errout?

Ugh, right!  I'm missing:

	tcf_exts_destroy(&exts);

Thanks!
