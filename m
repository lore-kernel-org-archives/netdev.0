From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] bpf: fix verifier memory corruption
Date: Wed, 15 Apr 2015 18:12:49 +0200
Message-ID: <1429114369.61952.254184949.0F80576C@webmail.messagingengine.com>
References: <1429052233-8252-1-git-send-email-ast@plumgrid.com>
 <1429113575.12070.19.camel@stressinduktion.org>
 <552E8CC8.9070403@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:53321 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932085AbbDOQMv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2015 12:12:51 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id EDEB920A0A
	for <netdev@vger.kernel.org>; Wed, 15 Apr 2015 12:12:49 -0400 (EDT)
In-Reply-To: <552E8CC8.9070403@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 15, 2015, at 18:07, Alexei Starovoitov wrote:
> On 4/15/15 8:59 AM, Hannes Frederic Sowa wrote:
> > On Di, 2015-04-14 at 15:57 -0700, Alexei Starovoitov wrote:
> >> Due to missing bounds check the DAG pass of the BPF verifier can corrupt
> >> the memory which can cause random crashes during program loading:
> >>
> >> [8.449451] BUG: unable to handle kernel paging request at ffffffffffffffff
> >> [8.451293] IP: [<ffffffff811de33d>] kmem_cache_alloc_trace+0x8d/0x2f0
> >> [8.452329] Oops: 0000 [#1] SMP
> >> [8.452329] Call Trace:
> >> [8.452329]  [<ffffffff8116cc82>] bpf_check+0x852/0x2000
> >> [8.452329]  [<ffffffff8116b7e4>] bpf_prog_load+0x1e4/0x310
> >> [8.452329]  [<ffffffff811b190f>] ? might_fault+0x5f/0xb0
> >> [8.452329]  [<ffffffff8116c206>] SyS_bpf+0x806/0xa30
> >>
> >> Fixes: f1bca824dabb ("bpf: add search pruning optimization to verifier")
> >> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
> >> ---
> >> Many things need to align for this crash to be seen, yet I managed to hit it.
> >> In my case JA was last insn, 't' was 255 and explored_states array
> >> had 256 elements. I've double checked other similar paths and all seems clean.
> >>
> >>   kernel/bpf/verifier.c |    3 ++-
> >>   1 file changed, 2 insertions(+), 1 deletion(-)
> >>
> >> diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
> >> index a28e09c7825d..36508e69e92a 100644
> >> --- a/kernel/bpf/verifier.c
> >> +++ b/kernel/bpf/verifier.c
> >> @@ -1380,7 +1380,8 @@ peek_stack:
> >>   			/* tell verifier to check for equivalent states
> >>   			 * after every call and jump
> >>   			 */
> >> -			env->explored_states[t + 1] = STATE_LIST_MARK;
> >> +			if (t + 1 < insn_cnt)
> >> +				env->explored_states[t + 1] = STATE_LIST_MARK;
> >>   		} else {
> >>   			/* conditional jump with two edges */
> >>   			ret = push_insn(t, t + 1, FALLTHROUGH, env);
> >
> > Quick review:
> >
> > We have env->explored_states[t+1] access in the
> >
> >                  } else {
> >                          /* conditional jump with two edges */
> >                          ret = push_insn(t, t + 1, FALLTHROUGH, env);
> >                          if (ret == 1)
> >                                  goto peek_stack;
> >                          else if (ret < 0)
> >                                  goto err_free;
> >
> >>>>                      ret = push_insn(t, t + insns[t].off + 1, BRANCH, env);
> >                          if (ret == 1)
> >                                  goto peek_stack;
> >                          else if (ret < 0)
> >                                  goto err_free;
> >                  }
> >          } else {
> >
> >
> > push_insn call. At this point insn[t].off could be 0, no?
> 
> insn[t].off can be anything, but the first thing that push_insn()
> checks is:
> if (w < 0 || w >= env->prog->len)
> only then it does:
> env->explored_states[w] = STATE_LIST_MARK;
> so we're good there.
> Though thanks for triple checking :)

Sorry, yes. That check was too obvious to me. ;)

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Bye,
Hannes
