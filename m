From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [RFC 06/12] nfp: add hardware cls_bpf offload
Date: Wed, 1 Jun 2016 14:51:48 -0700
Message-ID: <20160601215146.GA24671@ast-mbp.thefacebook.com>
References: <1464799814-4453-1-git-send-email-jakub.kicinski@netronome.com>
 <1464799814-4453-7-git-send-email-jakub.kicinski@netronome.com>
 <574F43A6.7000804@iogearbox.net>
 <20160601205159.GB22759@ast-mbp.thefacebook.com>
 <20160601221557.3772482d@jkicinski-Precision-T1700>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
	ast@kernel.org, dinan.gunawardena@netronome.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34592 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932119AbcFAVvz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 17:51:55 -0400
Received: by mail-pf0-f196.google.com with SMTP id c84so5420038pfc.1
        for <netdev@vger.kernel.org>; Wed, 01 Jun 2016 14:51:54 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160601221557.3772482d@jkicinski-Precision-T1700>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 01, 2016 at 10:15:57PM +0100, Jakub Kicinski wrote:
> On Wed, 1 Jun 2016 13:52:01 -0700, Alexei Starovoitov wrote:
> > On Wed, Jun 01, 2016 at 10:20:54PM +0200, Daniel Borkmann wrote:
> > > On 06/01/2016 06:50 PM, Jakub Kicinski wrote:  
> > > >Add hardware cls_bpf offload on our smart NICs.  Detect if
> > > >capable firmware is loaded and use it to load the code JITed
> > > >with just added translator onto programmable engines.
> > > >
> > > >Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> > > >Reviewed-by: Dinan Gunawardena <dgunawardena@netronome.com>
> > > >Reviewed-by: Simon Horman <simon.horman@netronome.com>  
> > > [...]  
> > > >+static int
> > > >+nfp_net_bpf_offload_prepare(struct nfp_net *nn,
> > > >+			    struct tc_cls_bpf_offload *cls_bpf,
> > > >+			    struct nfp_bpf_result *res,
> > > >+			    void **code, dma_addr_t *dma_addr, u16 max_instr)
> > > >+{
> > > >+	unsigned int code_sz = max_instr * sizeof(u64);
> > > >+	u16 start_off, tgt_out, tgt_abort;
> > > >+	const struct tc_action *a;
> > > >+	int err;
> > > >+
> > > >+	if (tc_no_actions(cls_bpf->exts))
> > > >+		return -EINVAL;
> > > >+
> > > >+	tc_for_each_action(a, cls_bpf->exts) {
> > > >+		if (!is_tcf_gact_shot(a))
> > > >+			return -EINVAL;
> > > >+	}
> > > >+
> > > >+	if (cls_bpf->exts_integrated)
> > > >+		return -EINVAL;  
> > > 
> > > So cls_bpf has two working modes as mentioned: da (direct-action) and non-da.
> > > Direct-action is I would say the most typical way to run cls_bpf as it allows
> > > you to more naturally and efficiently code programs in the sense that classification
> > > and action is already combined in a single program, so there's no additional
> > > overhead of a linear action chain required, and a single program can already
> > > have multiple action code outcomes (TC_ACT_OK, TC_ACT_SHOT, ...), so that it is
> > > usually enough to run a single cls_bpf instance, for example, on sch_clsact
> > > ingress or egress parent, nothing more than that to get the job done. I think
> > > the cls_bpf->exts_integrated test could probably come first and if it's false,
> > > we'd need to walk the actions?  
> > 
> > I think it makes sense to offload da mode only. Doing tc_for_each_action
> > walk like above is ok, but the number of bpf programs with only separate
> > gact is diminishingly small and we don't recommend to use it anymore.
> > That's the stuff we used when da wasn't available.
>  
> Let me make sure I understand - to get da offloaded I would have to
> check that all return values are either OK or SHOT?  That was my

yes, but jit need to check all return values anyway and do even
more checks depending on how actions are configured, what is default
result, then re-jit the whole thing if default and/or act is changed, etc.
imo da is actually much simpler to jit.
