From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCH v2 net-next 8/9] bpf: nfp: Report bpf_prog ID during
 XDP_QUERY_PROG
Date: Tue, 13 Jun 2017 19:19:50 -0700
Message-ID: <20170613191950.054195e6@cakuba.netronome.com>
References: <20170613210841.509578-1-kafai@fb.com>
        <20170613210841.509578-9-kafai@fb.com>
        <20170613165232.73a1a005@cakuba.netronome.com>
        <20170614003750.4wzq3quy7elmziy3@dhcp-172-26-110-210.dhcp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>, <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:33141 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751448AbdFNCTy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 22:19:54 -0400
Received: by mail-pf0-f173.google.com with SMTP id 83so76394082pfr.0
        for <netdev@vger.kernel.org>; Tue, 13 Jun 2017 19:19:54 -0700 (PDT)
In-Reply-To: <20170614003750.4wzq3quy7elmziy3@dhcp-172-26-110-210.dhcp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 13 Jun 2017 17:37:50 -0700, Martin KaFai Lau wrote:
> On Tue, Jun 13, 2017 at 04:52:32PM -0700, Jakub Kicinski wrote:
> > On Tue, 13 Jun 2017 14:08:40 -0700, Martin KaFai Lau wrote:  
> > > -	case XDP_QUERY_PROG:
> > > -		xdp->prog_attached = !!nn->dp.xdp_prog;
> > > +	case XDP_QUERY_PROG: {
> > > +		const struct bpf_prog *xdp_prog;
> > > +
> > > +		xdp_prog = nn->dp.xdp_prog;
> > > +		if (xdp_prog) {
> > > +			xdp->prog_id = xdp_prog->aux->id;
> > > +			xdp->prog_attached = true;
> > > +		} else {
> > > +			xdp->prog_id = 0;
> > > +			xdp->prog_attached = false;
> > > +		}
> > >  		return 0;
> > > +	}  
> >
> > I'm sorry to nit pick but it could be done on a single line:
> >
> > 	case XDP_QUERY_PROG:
> > 		xdp->prog_attached = !!nn->dp.xdp_prog;
> > +		xdp->prog_id = nn->dp.xdp_prog ? nn->dp.xdp_prog->aux->id : 0;
> >  		return 0;
> >  	default:
> >  		return -EINVAL;  
> OK...
> 
> >
> >
> > What would be even cooler is a helper like this:
> >
> > static inline u32 bpf_prog_id(struct bpf_prog *prog)
> > {
> > 	if (!prog)
> > 		return 0;
> > 	return prog->aux->id;
> > }
> >
> > in linux/bpf.h.
> Good idea.

You may actually have to add that into a source file, because bpf.h
does not know the definition of struct bpf_prog :(

> I had been thinking I may not need to change all the
> drivers now.  I did that in v1 because I wanted to remove
> prog_attached which is redundant.  With prog_attached reserved,
> prog_id is optional.
> 
> Considering I don't have all the hardwares to test it,  I think
> it may make more sense for me to only change the HW that I have?

Coccinelle to the rescue?

@@
expression ex;
@@
		xdp->prog_attached = !!(ex);
+		xdp->prog_id = bpf_prog_id(ex);

> > In patch 1 I would be tempted to add a new command for getting the prog
> > id, instead of muxing through query to avoid the output parameter?  But
> > I'm OK with the code as is, its just a preference rather than an objection :)  
> Have one command to query a new field?  I think it is overkilled.

Perhaps.  I was just trying to come up with a way of avoiding the
output parameter.  It seems hard to do unless we stop using
__dev_xdp_attached() for filling in the netlink attributes.  I'm OK
with leaving the code as is..
