From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH v7 0/6] Add eBPF hooks for cgroups
Date: Sun, 30 Oct 2016 00:34:39 +0900
Message-ID: <CAKD1Yr3QfL-biSjQfFgzjMFNoLV7FP9DSB=KNbp+_KyxyQmVMg@mail.gmail.com>
References: <1477390454-12553-1-git-send-email-daniel@zonque.org>
 <20161026195933.GA2031@salvia> <c9683122-d770-355b-e275-7c446e6d1d0f@zonque.org>
 <CAKD1Yr2aRDNUxX8onReZyURufphxGoSTek=Fjk3Wswq9WOVp4w@mail.gmail.com>
 <20161029045107.GA61294@ast-mbp.thefacebook.com> <CAKD1Yr2pMk52h7BdRwTvGwnP5+ONmr4ac6cyUBoZ9P+Kt-B8jw@mail.gmail.com>
 <20161029062442.GA61550@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Mack <daniel@zonque.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>, htejun@fb.com,
        Daniel Borkmann <daniel@iogearbox.net>, ast@fb.com,
        David Miller <davem@davemloft.net>, kafai@fb.com,
        Florian Westphal <fw@strlen.de>, harald@redhat.com,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Sargun Dhillon <sargun@sargun.me>, cgroups@vger.kernel.org
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f54.google.com ([209.85.214.54]:37731 "EHLO
        mail-it0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751352AbcJ2PfB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Oct 2016 11:35:01 -0400
Received: by mail-it0-f54.google.com with SMTP id u205so29347591itc.0
        for <netdev@vger.kernel.org>; Sat, 29 Oct 2016 08:35:00 -0700 (PDT)
In-Reply-To: <20161029062442.GA61550@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 29, 2016 at 3:24 PM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> it could be solved by swapping the order of cgroup_bpf_run_filter()
> and NF_INET_POST_ROUTING in patch 5. It was proposed some time back, but
> the current patch, I think, is more symmetrical.
> cgroup+bpf runs after nf hook on rx and runs before it on tx.
> imo it's more consistent.

I guess what I was trying to say was: what does doing this filtering
in ip_output give you over running this from the netfilter hooks?
Doing this filtering in netfilter is much more general because there
can be complex rules both before and after the filtering is applied. I
hadn't thought of the scalability issue you note below though.

For accounting you probably want to run after the hooks, both for
ingress and for egress, because the hooks can do all sorts of stuff
like drop packets, change packet sizes, reroute them to different
interfaces, etc. Do you see use cases where you want to run before the
hooks?

> Regardless of this choice... are you going to backport cgroupv2 to
> android? Because this set is v2 only.

Certainly anything that can't easily be backported to, say,
android-4.4 is not really feasible in the short term. I don't think we
use network cgroups at all, so if v2 network cgroups can coexist with
v1 cgroups of other types (which what little I've read seems to
indicate) then that should be possible.

> yes. that's certainly doable, but sooner or later such approach will hit
> scalability issue when number of cgroups is large. Same issue we saw
> with cls_bpf and bpf_skb_under_cgroup(). Hence this patch set was needed
> that is centered around cgroups instead of hooks. Note, unlike, tc and nf
> there is no way to attach to a hook. The bpf program is attached to a cgroup.
> It's an important distinction vs everything that currently exists in the stack.

Ah, I see. Out of curiosity, what was the first scaling limitation you
hit? eBPF program length? eBPF map size?
