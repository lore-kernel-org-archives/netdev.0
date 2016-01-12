From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCHv2] net: bpf: reject invalid shifts
Date: Tue, 12 Jan 2016 12:46:21 -0800
Message-ID: <20160112204620.GA35080@ast-mbp.thefacebook.com>
References: <20160112185121.GA34045@ast-mbp.thefacebook.com>
 <1452626228-15742-1-git-send-email-rabin@rab.in>
 <1452628118.1223.25.camel@edumazet-glaptop2.roam.corp.google.com>
 <20160112195356.GA34598@ast-mbp.thefacebook.com>
 <5695653F.6030001@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Rabin Vincent <rabin@rab.in>, davem@davemloft.net,
	netdev@vger.kernel.org, ast@kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:35724 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752404AbcALUqY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2016 15:46:24 -0500
Received: by mail-pa0-f54.google.com with SMTP id ho8so84579502pac.2
        for <netdev@vger.kernel.org>; Tue, 12 Jan 2016 12:46:24 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <5695653F.6030001@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 12, 2016 at 09:42:39PM +0100, Daniel Borkmann wrote:
> On 01/12/2016 08:53 PM, Alexei Starovoitov wrote:
> >On Tue, Jan 12, 2016 at 11:48:38AM -0800, Eric Dumazet wrote:
> >>On Tue, 2016-01-12 at 20:17 +0100, Rabin Vincent wrote:
> >>>On ARM64, a BUG() is triggered in the eBPF JIT if a filter with a
> >>>constant shift that can't be encoded in the immediate field of the
> >>>UBFM/SBFM instructions is passed to the JIT.  Since these shifts
> >>>amounts, which are negative or >= regsize, are invalid, reject them in
> >>>the eBPF verifier and the classic BPF filter checker, for all
> >>>architectures.
> >>>
> >>
> >>Hmm...
> >>
> >>>diff --git a/net/core/filter.c b/net/core/filter.c
> >>>index 672eefbfbe99..37157c4c1a78 100644
> >>>--- a/net/core/filter.c
> >>>+++ b/net/core/filter.c
> >>>@@ -777,6 +777,11 @@ static int bpf_check_classic(const struct sock_filter *filter,
> >>>  			if (ftest->k == 0)
> >>>  				return -EINVAL;
> >>>  			break;
> >>>+		case BPF_ALU | BPF_LSH | BPF_K:
> >>>+		case BPF_ALU | BPF_RSH | BPF_K:
> >>>+			if (ftest->k >= 32)
> >>>+				return -EINVAL;
> >>>+			break;
> >>>  		case BPF_LD | BPF_MEM:
> >>>  		case BPF_LDX | BPF_MEM:
> >>>  		case BPF_ST:
> >>
> >>These weak filters used to have undefined behavior, maybe in a never
> >>taken branch, and will now fail hard, possibly breaking old
> >>applications.
> >>
> >>I believe we should add a one time warning to give a clue to poor users
> >>hitting this problem.
> >
> >you mean like warn_on_once() here?
> >Makes sense I guess.
> 
> Hmm, WARN_ON_ONCE() would then throw a stack trace also for unprived users,
> I doubt we want to scare admins. ;)
> 
> Or, you mean pr_warn_once()?

yes. there is no need for stack trace of course.

> >>Not everybody has perfect BPF filters, since most of the time they were
> >>hand coded.
> >
> >yep and we all know who was able to code hundreds of cBPF insns by hand ;)
> >But I'm sure that code doesn't have such broken shifts. :)))
> 
> libpcap certainly supports raw filters now thanks to Chema [1]. Alternative
> could be to just mask them here, but not in eBPF verifier, but that would be
> even more inconsistent (on the other hand, we also allow holes in BPF but not
> in eBPF, so wouldn't be the first time we make things different), hmm.

I would rather see broken classic bpf program fixed instead of continue
running them with undefined behavior.
