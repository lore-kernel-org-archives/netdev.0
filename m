From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: prog ID and next steps. Was: [RFC net-next 0/2] Introduce bpf_prog
 ID and iteration
Date: Sun, 30 Apr 2017 04:36:41 +0200
Message-ID: <1493519801.4128467.960663496.16C1F5A1@webmail.messagingengine.com>
References: <20170427062449.80290-1-kafai@fb.com>
 <e81805c8-0499-a0a5-b788-0168947d9b8c@stressinduktion.org>
 <40cf6893-4702-4773-1aaa-7dfdc51c6212@fb.com>
 <44cdb2d2-9f5c-5d28-2966-3e43e6d2a2ef@stressinduktion.org>
 <7f7e86bb-6475-3971-42a6-6f8f6b74979f@fb.com>
 <cc962035-4374-b6c1-b350-c4dda9bf095c@stressinduktion.org>
 <b3dbda71-df4c-7e92-76aa-2c2252266cbc@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>, kernel-team@fb.com,
        "David S. Miller" <davem@davemloft.net>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        John Fastabend <john.fastabend@gmail.com>,
        Thomas Graf <tgraf@suug.ch>
To: Alexei Starovoitov <ast@fb.com>, Martin KaFai Lau <kafai@fb.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:42435 "EHLO
        out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S969675AbdD3Cgm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Apr 2017 22:36:42 -0400
In-Reply-To: <b3dbda71-df4c-7e92-76aa-2c2252266cbc@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

just quickly, because I am on a run:

On Sun, Apr 30, 2017, at 04:06, Alexei Starovoitov wrote:
> On 4/28/17 2:13 PM, Hannes Frederic Sowa wrote:
> >
> > Let's assume the following program with a constant key lookup and
> > different tables:
> >
> > action = bpf_map_lookup_elem(&actions, 0);
> > if (!*action)
> > 	return XDP_DROP;
> > else
> > 	return bpf_redirect(skb->ifindex, 0);
> >
> > It does something completely different depending on the map being used.
> > That is the reason why I see it makes sense to be specific which program
> > gets used if you try to analyze a program interactively.
> 
> Instead of two exactly the same programs accessing different
> maps it could have been one program accessing one map.
> The end result is the same.
> Depending on contents of the map and the input bytes of the packet
> the program will do arbitrary decisions. I still don't see how printing
> prog ID can help debugging.

Because during live inspection/debugging you get the relationship chain
in order:

n bpf-programs with same tag : loaded at m hooks : using z maps

You trace bpf_redirect and get back only the bpf tag.

You inspect all hooks and get back a bpf program identified by either or
all of filedescriptor, tag or prog_id. This doesn't solve the ambiguity
which program just actually was traced. Thus you have to consider all of
the programs. Each program can reference different maps.

So you extract all bpf programs and attributes and take the union of all
referenced maps, which you actually would have to inspect. If you had
the prog_id available, you could clearly figure out which maps are
referenced by the traced program.

I do see this as a prolem, because lot's of policy scripts might be
absolutely the same (thus also same tag) but might use different maps in
the end. We might not be able to correlate traces back to the maps.
Imagine a lot of bpf-lwt programs loaded, all the same, doing decisions
based on labels in the maps. It would be nice to see which specific map
also caused the behavior and to trace it back to user space and where
and why it was generated.

> >> The programs gets unloaded too and this 'perf record' and stack
> >> traces come from the past, hence the need for stable prog_tag.
> >
> > perf only stores addresses in perf.data. That said, if the program isn't
> > loaded, it won't give you any tag. If another program is reusing the
> > same address, if will give you any other random name for the function in
> > the calltrace.
> 
> This issue is well understood. We discussed it with Arnaldo and
> the plan is to emit PERF_RECORD_MMAP that will contain the address
> of JITed bpf program, so perf.data will contain all the info necessary
> for later analysis.

I think you meant to say "will contain the *name*" of the JITed bpf
program?

If so, that is cool.

> > If you store the perf script output or have kallsyms handy, certainly, yes.
> 
> right now 'perf script' doesn't work for short lived programs either.
> The stack trace IPs may be already gone from kallsyms.
> PERF_RECORD_MMAP is the right solution to that as well.

Absolutely ack.

> > Most of the time I was debugging interactively. Developers would
> > probably also enjoy to have a way to trace the program to the exact
> > identity. I have no problem keeping the tag in place and append just the
> > prog_id for the specific reason that the program might be loaded
> > multiple times with different tags in place. I was concerned about the
> > space for function names in kallsyms.
> 
> developers enjoy 'exact identity of the program' with program tag.
> Dynamic prog ID doesn't provide additional info to the user.
> Like when you write brand new kernel module, do you care what
> order it's loaded in lsmod ?
> Or if system crashed, do you care that veth0 had ifindex 10 or 20?
> Or PID of segfaulted program was 3256 ?

I do care which data structures my kernel module or program used,
because I might want to reference exactly those for debugging. ;)

> > I have to think more about it. Maybe there is a way to achieve both
> > without too much hassle.
> 
> It seems we agree on 80+% of topics discussed in this thread, so
> I suggest we implement, review and land these key pieces and later
> resolve the contentious points. By that time we will likely
> see each other arguments in different light :)

I agree with that. Maybe better ideas come up.

I was a bit pushy here, because I fear that kallsym name changes could
have uapi impact.

Thanks,
Hannes
