From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCH v2 net-next 8/9] bpf: nfp: Report bpf_prog ID during
 XDP_QUERY_PROG
Date: Tue, 13 Jun 2017 20:43:00 -0700
Message-ID: <20170613204300.38580ec2@cakuba.netronome.com>
References: <20170613210841.509578-1-kafai@fb.com>
        <20170613210841.509578-9-kafai@fb.com>
        <20170613165232.73a1a005@cakuba.netronome.com>
        <20170614003750.4wzq3quy7elmziy3@dhcp-172-26-110-210.dhcp.thefacebook.com>
        <20170613191950.054195e6@cakuba.netronome.com>
        <20170614031953.5jcbtlcwetcjqodj@kridsdale-mbp.DHCP.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>, <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:35265 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752854AbdFNDnD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 23:43:03 -0400
Received: by mail-pg0-f43.google.com with SMTP id k71so69321753pgd.2
        for <netdev@vger.kernel.org>; Tue, 13 Jun 2017 20:43:03 -0700 (PDT)
In-Reply-To: <20170614031953.5jcbtlcwetcjqodj@kridsdale-mbp.DHCP.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 13 Jun 2017 20:19:53 -0700, Martin KaFai Lau wrote:
> On Tue, Jun 13, 2017 at 07:19:50PM -0700, Jakub Kicinski wrote:
> > On Tue, 13 Jun 2017 17:37:50 -0700, Martin KaFai Lau wrote:  
> > > On Tue, Jun 13, 2017 at 04:52:32PM -0700, Jakub Kicinski wrote:  
> > > > On Tue, 13 Jun 2017 14:08:40 -0700, Martin KaFai Lau wrote:  
> > > > > -	case XDP_QUERY_PROG:
> > > > > -		xdp->prog_attached = !!nn->dp.xdp_prog;
> > > > > +	case XDP_QUERY_PROG: {
> > > > > +		const struct bpf_prog *xdp_prog;
> > > > > +
> > > > > +		xdp_prog = nn->dp.xdp_prog;
> > > > > +		if (xdp_prog) {
> > > > > +			xdp->prog_id = xdp_prog->aux->id;
> > > > > +			xdp->prog_attached = true;
> > > > > +		} else {
> > > > > +			xdp->prog_id = 0;
> > > > > +			xdp->prog_attached = false;
> > > > > +		}
> > > > >  		return 0;
> > > > > +	}  
> > > >
> > > > I'm sorry to nit pick but it could be done on a single line:
> > > >
> > > > 	case XDP_QUERY_PROG:
> > > > 		xdp->prog_attached = !!nn->dp.xdp_prog;
> > > > +		xdp->prog_id = nn->dp.xdp_prog ? nn->dp.xdp_prog->aux->id : 0;
> > > >  		return 0;
> > > >  	default:
> > > >  		return -EINVAL;  
> > > OK...
> > >  
> > > >
> > > >
> > > > What would be even cooler is a helper like this:
> > > >
> > > > static inline u32 bpf_prog_id(struct bpf_prog *prog)
> > > > {
> > > > 	if (!prog)
> > > > 		return 0;
> > > > 	return prog->aux->id;
> > > > }
> > > >
> > > > in linux/bpf.h.  
> > > Good idea.  
> >
> > You may actually have to add that into a source file, because bpf.h
> > does not know the definition of struct bpf_prog :(  
> Yeah. filter.h seems not working well either.
> It looks good to me at the first thought.  After a second thought,
> in the future, I am not so sure having a getter for every fields
> in bpf_prog.

Yes, if it's not a static inline it's far less appealing...
 
> I can put bpf_prog_id() in nfp_net_common.c only.
> or do 'xdp->prog_id = nn->dp.xdp_prog ? nn->dp.xdp_prog->aux->id : 0;'
> as you suggested earlier also.
> I am fine either way.  Your call ;)

OK, let's do the ternary operator version then :)  Sorry for leading you
into this dead end.
