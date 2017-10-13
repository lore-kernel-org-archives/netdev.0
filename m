From: Brendan Gregg <brendan.d.gregg@gmail.com>
Subject: Re: [Patch net-next v3] tcp: add a tracepoint for tcp retransmission
Date: Fri, 13 Oct 2017 16:58:44 -0700
Message-ID: <CAE40pdczqgFh=062s7-ZDB6+Yr=R+qy=QtX2=TG8G5aNoKZS-Q@mail.gmail.com>
References: <20171013200316.28561-1-xiyou.wangcong@gmail.com>
 <CAE40pdcdcLw9pdDkVEPFKvCLe0FcQzsV4vU0K-3YbNr1gS0Y6g@mail.gmail.com> <20171013220937.qoyu5heijjsr6z6p@ast-mbp>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org,
        Eric Dumazet <edumazet@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Neal Cardwell <ncardwell@google.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:46150 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753089AbdJMX7Q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 19:59:16 -0400
Received: by mail-wm0-f67.google.com with SMTP id m72so24121895wmc.1
        for <netdev@vger.kernel.org>; Fri, 13 Oct 2017 16:59:15 -0700 (PDT)
In-Reply-To: <20171013220937.qoyu5heijjsr6z6p@ast-mbp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 13, 2017 at 3:09 PM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Fri, Oct 13, 2017 at 01:50:44PM -0700, Brendan Gregg wrote:
>> On Fri, Oct 13, 2017 at 1:03 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>> > We need a real-time notification for tcp retransmission
>> > for monitoring.
>> >
>> > Of course we could use ftrace to dynamically instrument this
>> > kernel function too, however we can't retrieve the connection
>> > information at the same time, for example perf-tools [1] reads
>> > /proc/net/tcp for socket details, which is slow when we have
>> > a lots of connections.
>> >
>> > Therefore, this patch adds a tracepoint for __tcp_retransmit_skb()
>> > and exposes src/dst IP addresses and ports of the connection.
>> > This also makes it easier to integrate into perf.
>> >
>> > Note, I expose both IPv4 and IPv6 addresses at the same time:
>> > for a IPv4 socket, v4 mapped address is used as IPv6 addresses,
>> > for a IPv6 socket, LOOPBACK4_IPV6 is already filled by kernel.
>> > Also, add sk and skb pointers as they are useful for BPF.
>>
>> Thanks, a TCP retransmit tracepoint would be great. (tcp_set_state
>> would be highly useful too, which Alexei already has in his list).
>>
>> Should skp->__sk_common.skc_state be included in the format string, so
>> we don't have to always dig it out of the skaddr? For retransmits I
>> always want to know the TCP state, to determine if it is ESTABLISHED
>> (packet drop) or SYN_SENT (backlog full) or something else.
>
> let's not expose internal socket fields into tp fields.
> Few people still believe that tp fields are abi, so to be safe
> no such fields should be exposed.
> It's trivial enough to read sk_state from bpf program
> with bpf_probe_read().

Ah, right, the number mapping for TCP_ESTABLISHED and friends is a
Linux implementation detail, and not from the RFCs. Ok, I can dig it
from the skp instead.

>
>> We probably need a tracepoint for tcp_send_loss_probe() (TLP) as well,
>> for tracing at the same time as retransmits (like my tools do), but
>> that can be added later.
>
> hmm. why?
> This single tracepoint will cover both cases of retransmits.

I don't think tcp_send_loss_probe() TLP goes through
__tcp_retransmit_skb(): look at the path to bumping
LINUX_MIB_TCPLOSSPROBES. I was thinking that later on we might want to
add a tcp:tcp_send_tlp tracepoint, in addition to this
tcp:tcp_retransmit_skb tracepoint, for investigating the same kind of
issues: packet loss. This existing tcp:tcp_retransmit_skb tracepoint
patch is ok.

Acked-by: Brendan Gregg <bgregg@netflix.com>

(with or without %pI6c)

Brendan
