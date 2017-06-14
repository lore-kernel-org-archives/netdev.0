From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH v2 net-next 8/9] bpf: nfp: Report bpf_prog ID during
 XDP_QUERY_PROG
Date: Tue, 13 Jun 2017 17:37:50 -0700
Message-ID: <20170614003750.4wzq3quy7elmziy3@dhcp-172-26-110-210.dhcp.thefacebook.com>
References: <20170613210841.509578-1-kafai@fb.com>
 <20170613210841.509578-9-kafai@fb.com>
 <20170613165232.73a1a005@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>, <kernel-team@fb.com>
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:51036 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752259AbdFNAiJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 20:38:09 -0400
Content-Disposition: inline
In-Reply-To: <20170613165232.73a1a005@cakuba.netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 13, 2017 at 04:52:32PM -0700, Jakub Kicinski wrote:
> On Tue, 13 Jun 2017 14:08:40 -0700, Martin KaFai Lau wrote:
> > -	case XDP_QUERY_PROG:
> > -		xdp->prog_attached = !!nn->dp.xdp_prog;
> > +	case XDP_QUERY_PROG: {
> > +		const struct bpf_prog *xdp_prog;
> > +
> > +		xdp_prog = nn->dp.xdp_prog;
> > +		if (xdp_prog) {
> > +			xdp->prog_id = xdp_prog->aux->id;
> > +			xdp->prog_attached = true;
> > +		} else {
> > +			xdp->prog_id = 0;
> > +			xdp->prog_attached = false;
> > +		}
> >  		return 0;
> > +	}
>
> I'm sorry to nit pick but it could be done on a single line:
>
> 	case XDP_QUERY_PROG:
> 		xdp->prog_attached = !!nn->dp.xdp_prog;
> +		xdp->prog_id = nn->dp.xdp_prog ? nn->dp.xdp_prog->aux->id : 0;
>  		return 0;
>  	default:
>  		return -EINVAL;
OK...

>
>
> What would be even cooler is a helper like this:
>
> static inline u32 bpf_prog_id(struct bpf_prog *prog)
> {
> 	if (!prog)
> 		return 0;
> 	return prog->aux->id;
> }
>
> in linux/bpf.h.
Good idea.



I had been thinking I may not need to change all the
drivers now.  I did that in v1 because I wanted to remove
prog_attached which is redundant.  With prog_attached reserved,
prog_id is optional.

Considering I don't have all the hardwares to test it,  I think
it may make more sense for me to only change the HW that I have?

>
> In patch 1 I would be tempted to add a new command for getting the prog
> id, instead of muxing through query to avoid the output parameter?  But
> I'm OK with the code as is, its just a preference rather than an objection :)
Have one command to query a new field?  I think it is overkilled.
