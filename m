From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next] tcp: add a tracepoint for tcp_retransmit_skb()
Date: Tue, 10 Oct 2017 14:37:11 -0700
Message-ID: <CAM_iQpU9TAU-SbjTyfp3xZUjpdrz=WWobHiAhoZ2zeF0oonYXg@mail.gmail.com>
References: <20171010053547.21162-1-xiyou.wangcong@gmail.com> <20171010173821.6djxyvrggvaivqec@ast-mbp.dhcp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Neal Cardwell <ncardwell@google.com>,
        Martin KaFai Lau <kafai@fb.com>,
        Brendan Gregg <brendan.d.gregg@gmail.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Song Liu <songliubraving@fb.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35199 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754212AbdJJVhc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 17:37:32 -0400
Received: by mail-pf0-f193.google.com with SMTP id i23so38530580pfi.2
        for <netdev@vger.kernel.org>; Tue, 10 Oct 2017 14:37:32 -0700 (PDT)
In-Reply-To: <20171010173821.6djxyvrggvaivqec@ast-mbp.dhcp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 10, 2017 at 10:38 AM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
>
> I'm happy to see new tracepoints being added to tcp stack, but I'm concerned
> with practical usability of them.
> Like the above tracepoint definition makes it not very useful from bpf point of view,
> since 'sk' pointer is not recored by as part of the tracepoint.
> In bpf/tracing world we prefer tracepoints to have raw pointers recorded
> in TP_STRUCT__entry() and _not_ printed in TP_printk()
> (since pointers are useless for userspace).
> Like trace_kfree_skb() tracepoint records raw 'skb' pointer and we can
> walk whatever sk_buff fields we need inside the program.
> Such approach allows tracepoint to be usable in many more scenarios, since
> bpf program can examine kernel datastructures.


Sure, I am happy to add them for BPF. The current version is merely
for our own use case, other use cases like this are always welcome!


> Over the last few years we've been running tcp statistics framework (similar to web10g)
> using 8 kprobes in tcp stack with bpf programs extracting the data and now we're
> ready to share this experience with the community. Right now we're working on a set
> of tracepoints for tcp stack to make the interface more accurate, faster and more stable.
> We're planning to send an RFC patch with these new tracepoints in the comming weeks.

Great! Looking forward to it!

>
> More concrete, if you can make this trace_tcp_retransmit_skb() to record
> sk, skb pointers and err code at the end of __tcp_retransmit_skb() it will solve
> our need as well.


Note, currently I only call trace_tcp_retransmit_skb() for successful
retransmissions, since you mentioned err code, I guess you want it
for failures too? I am not sure if tracing unsuccessful TCP retransmissions
is meaningful here, I guess it's needed for BPF to track TCP states?

It doesn't harm to add it, at least we can filter out err!=0 since we
only care about successful ones.


>
> So far our list of kprobes is:
> int kprobe__tcp_validate_incoming
> int kprobe__tcp_send_active_reset
> int kprobe__tcp_v4_send_reset
> int kprobe__tcp_v6_send_reset
> int kprobe__tcp_v4_destroy_sock
> int kprobe__tcp_set_state
> int kprobe__tcp_retransmit_skb
> int kprobe__tcp_rtx_synack
>
> with tracepoints we can consolidate two of them into one and drop
> another one for sure. Notice that tcp_retransmit_skb is on our list too
> and currently we're doing extra work inside the program to make it more
> accurate which will be unnecessary if this tracepoint is at the end
> of __tcp_retransmit_skb().

Yeah, with these tracepoints we would be able to trace more TCP
state changes.

Thanks!
