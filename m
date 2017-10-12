From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCH net-next 01/12] bpf: verifier: set reg_type on context
 accesses in second pass
Date: Thu, 12 Oct 2017 13:56:32 -0700
Message-ID: <20171012135632.1fa408bc@cakuba.netronome.com>
References: <20171012173418.4029-1-jakub.kicinski@netronome.com>
        <20171012173418.4029-2-jakub.kicinski@netronome.com>
        <59DFD3DE.9050907@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        alexei.starovoitov@gmail.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f175.google.com ([209.85.220.175]:48957 "EHLO
        mail-qk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754770AbdJLU4g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 16:56:36 -0400
Received: by mail-qk0-f175.google.com with SMTP id d67so2742397qkg.5
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 13:56:36 -0700 (PDT)
In-Reply-To: <59DFD3DE.9050907@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 12 Oct 2017 22:43:10 +0200, Daniel Borkmann wrote:
> On 10/12/2017 07:34 PM, Jakub Kicinski wrote:
> > Use a simplified is_valid_access() callback when verifier
> > is used for program analysis by non-host JITs.  This allows
> > us to teach the verifier about packet start and packet end
> > offsets for direct packet access.
> >
> > We can extend the callback as needed but for most packet
> > processing needs there isn't much more the offloads may
> > require.
> >
> > Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> > Reviewed-by: Simon Horman <simon.horman@netronome.com>
> > ---
> > CC: alexei.starovoitov@gmail.com
> > CC: daniel@iogearbox.net
> >
> >   kernel/bpf/verifier.c | 43 +++++++++++++++++++++++++++++++++++++------
> >   1 file changed, 37 insertions(+), 6 deletions(-)
> >
> > diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
> > index 2cdbcc4f8f6b..9755279d94cb 100644
> > --- a/kernel/bpf/verifier.c
> > +++ b/kernel/bpf/verifier.c
> > @@ -813,6 +813,36 @@ static int check_packet_access(struct bpf_verifier_env *env, u32 regno, int off,
> >   	return err;
> >   }
> >
> > +static bool analyzer_is_valid_access(struct bpf_verifier_env *env, int off,
> > +				     struct bpf_insn_access_aux *info)
> > +{
> > +	switch (env->prog->type) {
> > +	case BPF_PROG_TYPE_XDP:
> > +		switch (off) {
> > +		case offsetof(struct xdp_buff, data):
> > +			info->reg_type = PTR_TO_PACKET;
> > +			return true;
> > +		case offsetof(struct xdp_buff, data_end):
> > +			info->reg_type = PTR_TO_PACKET_END;
> > +			return true;
> > +		}
> > +		return false;
> > +	case BPF_PROG_TYPE_SCHED_CLS:
> > +		switch (off) {
> > +		case offsetof(struct sk_buff, data):
> > +			info->reg_type = PTR_TO_PACKET;
> > +			return true;
> > +		case offsetof(struct sk_buff, cb) +
> > +		     offsetof(struct bpf_skb_data_end, data_end):
> > +			info->reg_type = PTR_TO_PACKET_END;
> > +			return true;
> > +		}
> > +		return false;
> > +	default:
> > +		return false;
> > +	}
> > +}
> > +
> >   /* check access to 'struct bpf_context' fields.  Supports fixed offsets only */
> >   static int check_ctx_access(struct bpf_verifier_env *env, int insn_idx, int off, int size,
> >   			    enum bpf_access_type t, enum bpf_reg_type *reg_type)
> > @@ -821,12 +851,13 @@ static int check_ctx_access(struct bpf_verifier_env *env, int insn_idx, int off,
> >   		.reg_type = *reg_type,
> >   	};
> >
> > -	/* for analyzer ctx accesses are already validated and converted */
> > -	if (env->analyzer_ops)
> > -		return 0;
> > -
> > -	if (env->prog->aux->ops->is_valid_access &&
> > -	    env->prog->aux->ops->is_valid_access(off, size, t, &info)) {
> > +	if (env->analyzer_ops) {
> > +		if (analyzer_is_valid_access(env, off, &info)) {
> > +			*reg_type = info.reg_type;  
> 
> Is there some specific issue with the is_valid_access() callbacks that you
> need to do this (I couldn't parse that out of the commit message)?

Do you mean why not just call is_valid_access()?  The offsets are
translated, so is_valid_access() will use user space __sk_buff's
offsets while we have the kernel's sk_buff offsets here...

> It would be nice to keep the reg_type setting in one place, meaning
> the callbacks themselves, so we wouldn't need to maintain this in
> multiple places.

Hm.. I though this was the smallest and simplest change.  I could
translate the offsets but that seems wobbly.  Or try to consolidate the
call into the same if () branch?  Not sure..

As a bonus info I discovered there is a bug in -net with how things are
converted.  We allow arithmetic on context pointers but then only
look at the insn.off in the converter...  I'm working on a fix.
