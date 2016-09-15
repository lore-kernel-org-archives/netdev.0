From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCHv3 net-next 05/15] bpf: enable non-core use of the
 verfier
Date: Thu, 15 Sep 2016 08:52:51 +0100
Message-ID: <20160915085251.4de090a1@jkicinski-Precision-T1700>
References: <1473879623-15382-1-git-send-email-jakub.kicinski@netronome.com>
        <1473879623-15382-6-git-send-email-jakub.kicinski@netronome.com>
        <20160914230549.GB60248@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@kernel.org, daniel@iogearbox.net,
        jiri@resnulli.us, john.fastabend@gmail.com, kubakici@wp.pl
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:38903 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933877AbcIOHw4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 03:52:56 -0400
Received: by mail-wm0-f48.google.com with SMTP id 1so75841361wmz.1
        for <netdev@vger.kernel.org>; Thu, 15 Sep 2016 00:52:55 -0700 (PDT)
In-Reply-To: <20160914230549.GB60248@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 14 Sep 2016 16:05:51 -0700, Alexei Starovoitov wrote:
> On Wed, Sep 14, 2016 at 08:00:13PM +0100, Jakub Kicinski wrote:
> > Advanced JIT compilers and translators may want to use
> > eBPF verifier as a base for parsers or to perform custom
> > checks and validations.
> > 
> > Add ability for external users to invoke the verifier
> > and provide callbacks to be invoked for every intruction
> > checked.  For now only add most basic callback for
> > per-instruction pre-interpretation checks is added.  More
> > advanced users may also like to have per-instruction post
> > callback and state comparison callback.
> > 
> > Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> > ---
> >  include/linux/bpf_parser.h |  89 ++++++++++++++++++++++++++++++
> >  kernel/bpf/verifier.c      | 134 +++++++++++++++++++++++----------------------
> >  2 files changed, 158 insertions(+), 65 deletions(-)
> >  create mode 100644 include/linux/bpf_parser.h
> > 
> > diff --git a/include/linux/bpf_parser.h b/include/linux/bpf_parser.h
> > new file mode 100644
> > index 000000000000..daa53b204f4d
> > --- /dev/null
> > +++ b/include/linux/bpf_parser.h  
> 
> 'bpf parser' is a bit misleading name, since it can be interpreted
> as parser written in bpf.
> Also the header file containes verifier bits, therefore I think
> the better name would be bpf_verifier.h ?
> 
> > +#define MAX_USED_MAPS 64 /* max number of maps accessed by one eBPF program */
> > +
> > +struct verifier_env;
> > +struct bpf_ext_parser_ops {
> > +	int (*insn_hook)(struct verifier_env *env,
> > +			 int insn_idx, int prev_insn_idx);
> > +};  
> 
> How about calling this bpf_ext_analyzer_ops
> and main entry bpf_analyzer() ?
> I think it will better convey what it's doing.
> 
> > +
> > +/* single container for all structs
> > + * one verifier_env per bpf_check() call
> > + */
> > +struct verifier_env {
> > +	struct bpf_prog *prog;		/* eBPF program being verified */
> > +	struct verifier_stack_elem *head; /* stack of verifier states to be processed */
> > +	int stack_size;			/* number of states to be processed */
> > +	struct verifier_state cur_state; /* current verifier state */
> > +	struct verifier_state_list **explored_states; /* search pruning optimization */
> > +	const struct bpf_ext_parser_ops *pops; /* external parser ops */
> > +	void *ppriv; /* pointer to external parser's private data */  
> 
> a bit hard to review, since move and addition is in one patch.

Agreed, I'll do move+prefix with bpf_ to one patch since they're both
"no functional changes" and additions to a separate one.

> I think ppriv and pops are too obscure names.
> May be analyzer_ops and analyzer_priv ?

I'll rename everything as suggested.
 
> Conceptually looks good.

Thanks!
