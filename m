From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [Patch net-next v3] tcp: add a tracepoint for tcp retransmission
Date: Fri, 13 Oct 2017 15:09:39 -0700
Message-ID: <20171013220937.qoyu5heijjsr6z6p@ast-mbp>
References: <20171013200316.28561-1-xiyou.wangcong@gmail.com>
 <CAE40pdcdcLw9pdDkVEPFKvCLe0FcQzsV4vU0K-3YbNr1gS0Y6g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org,
        Eric Dumazet <edumazet@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Neal Cardwell <ncardwell@google.com>
To: Brendan Gregg <brendan.d.gregg@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:51868 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751081AbdJMWJp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 18:09:45 -0400
Received: by mail-pg0-f67.google.com with SMTP id k70so1186098pgc.8
        for <netdev@vger.kernel.org>; Fri, 13 Oct 2017 15:09:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAE40pdcdcLw9pdDkVEPFKvCLe0FcQzsV4vU0K-3YbNr1gS0Y6g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 13, 2017 at 01:50:44PM -0700, Brendan Gregg wrote:
> On Fri, Oct 13, 2017 at 1:03 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> > We need a real-time notification for tcp retransmission
> > for monitoring.
> >
> > Of course we could use ftrace to dynamically instrument this
> > kernel function too, however we can't retrieve the connection
> > information at the same time, for example perf-tools [1] reads
> > /proc/net/tcp for socket details, which is slow when we have
> > a lots of connections.
> >
> > Therefore, this patch adds a tracepoint for __tcp_retransmit_skb()
> > and exposes src/dst IP addresses and ports of the connection.
> > This also makes it easier to integrate into perf.
> >
> > Note, I expose both IPv4 and IPv6 addresses at the same time:
> > for a IPv4 socket, v4 mapped address is used as IPv6 addresses,
> > for a IPv6 socket, LOOPBACK4_IPV6 is already filled by kernel.
> > Also, add sk and skb pointers as they are useful for BPF.
> 
> Thanks, a TCP retransmit tracepoint would be great. (tcp_set_state
> would be highly useful too, which Alexei already has in his list).
> 
> Should skp->__sk_common.skc_state be included in the format string, so
> we don't have to always dig it out of the skaddr? For retransmits I
> always want to know the TCP state, to determine if it is ESTABLISHED
> (packet drop) or SYN_SENT (backlog full) or something else.

let's not expose internal socket fields into tp fields.
Few people still believe that tp fields are abi, so to be safe
no such fields should be exposed.
It's trivial enough to read sk_state from bpf program
with bpf_probe_read().

> We probably need a tracepoint for tcp_send_loss_probe() (TLP) as well,
> for tracing at the same time as retransmits (like my tools do), but
> that can be added later.

hmm. why?
This single tracepoint will cover both cases of retransmits.

For the patch:
Acked-by: Alexei Starovoitov <ast@kernel.org>

I believe it will fit our use case perfectly.
