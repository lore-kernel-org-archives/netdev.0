From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCHv2] net: bpf: reject invalid shifts
Date: Tue, 12 Jan 2016 11:53:57 -0800
Message-ID: <20160112195356.GA34598@ast-mbp.thefacebook.com>
References: <20160112185121.GA34045@ast-mbp.thefacebook.com>
 <1452626228-15742-1-git-send-email-rabin@rab.in>
 <1452628118.1223.25.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rabin Vincent <rabin@rab.in>, davem@davemloft.net,
	netdev@vger.kernel.org, ast@kernel.org, daniel@iogearbox.net,
	linux-arm-kernel@lists.infradead.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:36827 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751156AbcALTyC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2016 14:54:02 -0500
Received: by mail-pa0-f44.google.com with SMTP id yy13so252101253pab.3
        for <netdev@vger.kernel.org>; Tue, 12 Jan 2016 11:54:01 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1452628118.1223.25.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 12, 2016 at 11:48:38AM -0800, Eric Dumazet wrote:
> On Tue, 2016-01-12 at 20:17 +0100, Rabin Vincent wrote:
> > On ARM64, a BUG() is triggered in the eBPF JIT if a filter with a
> > constant shift that can't be encoded in the immediate field of the
> > UBFM/SBFM instructions is passed to the JIT.  Since these shifts
> > amounts, which are negative or >= regsize, are invalid, reject them in
> > the eBPF verifier and the classic BPF filter checker, for all
> > architectures.
> > 
> 
> Hmm...
> 
> > diff --git a/net/core/filter.c b/net/core/filter.c
> > index 672eefbfbe99..37157c4c1a78 100644
> > --- a/net/core/filter.c
> > +++ b/net/core/filter.c
> > @@ -777,6 +777,11 @@ static int bpf_check_classic(const struct sock_filter *filter,
> >  			if (ftest->k == 0)
> >  				return -EINVAL;
> >  			break;
> > +		case BPF_ALU | BPF_LSH | BPF_K:
> > +		case BPF_ALU | BPF_RSH | BPF_K:
> > +			if (ftest->k >= 32)
> > +				return -EINVAL;
> > +			break;
> >  		case BPF_LD | BPF_MEM:
> >  		case BPF_LDX | BPF_MEM:
> >  		case BPF_ST:
> 
> These weak filters used to have undefined behavior, maybe in a never
> taken branch, and will now fail hard, possibly breaking old
> applications.
> 
> I believe we should add a one time warning to give a clue to poor users
> hitting this problem.

you mean like warn_on_once() here?
Makes sense I guess.

> Not everybody has perfect BPF filters, since most of the time they were
> hand coded.

yep and we all know who was able to code hundreds of cBPF insns by hand ;)
But I'm sure that code doesn't have such broken shifts. :)))
