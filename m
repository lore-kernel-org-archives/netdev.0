From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v7 0/6] Add eBPF hooks for cgroups
Date: Wed, 26 Oct 2016 20:35:04 -0700
Message-ID: <20161027033502.GA43960@ast-mbp.thefacebook.com>
References: <1477390454-12553-1-git-send-email-daniel@zonque.org>
 <20161026195933.GA2031@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Mack <daniel@zonque.org>, htejun@fb.com,
        daniel@iogearbox.net, ast@fb.com, davem@davemloft.net,
        kafai@fb.com, fw@strlen.de, harald@redhat.com,
        netdev@vger.kernel.org, sargun@sargun.me, cgroups@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34489 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753405AbcJ0DfK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2016 23:35:10 -0400
Content-Disposition: inline
In-Reply-To: <20161026195933.GA2031@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 26, 2016 at 09:59:33PM +0200, Pablo Neira Ayuso wrote:
> On Tue, Oct 25, 2016 at 12:14:08PM +0200, Daniel Mack wrote:
> [...]
> >   Dumping programs once they are installed is problematic because of
> >   the internal optimizations done to the eBPF program during its
> >   lifetime. Also, the references to maps etc. would need to be
> >   restored during the dump.
> > 
> >   Just exposing whether or not a program is attached would be
> >   trivial to do, however, most easily through another bpf(2)
> >   command. That can be added later on though.
> 
> I don't know if anyone told you, but during last netconf, this topic
> took a bit of time of discussion and it was controversial, I would say
> 1/3 of netdev hackers there showed their concerns, and that's
> something that should not be skipped IMO.

Though I attended netconf over hangouts, I think it was pretty
clear that bpf needs 'introspection' of loaded bpf programs and it
was a universal desire of everyone. Not 1/3 of hackers.
As commit log says it's an orthogonal work and over the last
month we've been discussing pros and cons of different approaches.
The audit infra, tracepoints and other ideas.
We kept the discussion in private because, unfortunately, public
discussions are not fruitful due to threads like this one.

The further points below were disputed many times in the past.
Let's address them one more time:

> path. But this is adding hooks to push bpf programs in the middle of
> our generic stack, this is way different domain.

incorrect. look at socket filters, cls_bpf.
bpf was running in the middle of the stack for years.
Even unix pipe and netfilter can be filtered with bpf.

> around this socket code in functions so we can invoke it. I guess
> filtering of UDP and TCP should be good for you at this stage.

DanielM mentioned few times that it's not only about UDP and TCP.

> This
> would require more work though, but this would come with no hooks in
> the stack and packets will not have to consume *lots of cycles* just
> to be dropped before entering the socket queue.

packets don't consume 'lost of cycles'. This is not a typical
n-tuple firewall framework. Not a DoS mitigation either. Please read
the cover letter and earlier submissions.
It's a framework centered around cgroups.
_Nothing_ in the current stack provides cgroup based monitoring
and application protection. Earlier cgroupv1 controllers don't
scale and we really cannot have more of v1 net controllers.
At the same time we've been brainstorming how this patch set
can work with v1. It's not easy. We're not giving up though.
For now it's v2 only.
Note that another two patchsets depend on this core cgroup+bpf framework.
It's not about hooks (socket/skb inspections points).
Both rx and tx hooks _can_ be moved in the future.
Unlike netfilter hooks, the hooks in patches 4 and 5 can be moved
if we find better place for them. It won't affect userspace.
The only assumption of BPF_CGROUP_INET_[E|IN]GRESS is that
there will be some place in packet delivery from nic to userspace
where bpf program can look at L3+ packet only if application is
under particular cgroup. Patches 4 and 5 are the best places so far.
It took months to converge on these points. Please see earlier
discussions on pro/con of every other place we've tried.

> How useful can be to drop lots of unwanted traffic at such a late
> stage? How would the performance numbers to drop packets would look
> like? Extremely bad, I predict.

facts check please. Daniel provided numbers before that show
excellent performance.
