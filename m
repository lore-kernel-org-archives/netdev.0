From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next] tcp: add tracepoint
 trace_tcp_retransmit_synack()
Date: Fri, 27 Oct 2017 13:58:03 -0700
Message-ID: <876c1022-7922-b7b5-8b1f-95f013ed6097@fb.com>
References: <20171024235709.2186047-1-songliubraving@fb.com>
 <CAMXgnP7y7Pi21aeFqsRntDakb2bj0ke+F9X54D84rjdLi+tryw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <alexei.starovoitov@gmail.com>, <kafai@fb.com>,
        <netdev@vger.kernel.org>, <liu.song.a23@gmail.com>
To: Alban Crequy <alban.crequy@gmail.com>,
        Song Liu <songliubraving@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:48634 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S932329AbdJ0U6S (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 16:58:18 -0400
In-Reply-To: <CAMXgnP7y7Pi21aeFqsRntDakb2bj0ke+F9X54D84rjdLi+tryw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/27/17 1:38 PM, Alban Crequy wrote:
> Hi,
>
> On 25 October 2017 at 01:57, Song Liu <songliubraving@fb.com> wrote:
>> This tracepoint can be used to trace synack retransmits. It maintains
>> pointer to struct request_sock.
>>
>> We cannot simply reuse trace_tcp_retransmit_skb() here, because the
>> sk here is the LISTEN socket. The IP addresses and ports should be
>> extracted from struct request_sock.
>>
>> Signed-off-by: Song Liu <songliubraving@fb.com>
>> ---
>>  include/trace/events/tcp.h | 56 ++++++++++++++++++++++++++++++++++++++++++++++
>>  net/ipv4/tcp_output.c      |  1 +
>>  2 files changed, 57 insertions(+)
>>
>> diff --git a/include/trace/events/tcp.h b/include/trace/events/tcp.h
>> index 03699ba..07cccca 100644
>> --- a/include/trace/events/tcp.h
>> +++ b/include/trace/events/tcp.h
>> @@ -237,6 +237,62 @@ TRACE_EVENT(tcp_set_state,
>>                   show_tcp_state_name(__entry->newstate))
>>  );
>>
>> +TRACE_EVENT(tcp_retransmit_synack,
>> +
>> +       TP_PROTO(const struct sock *sk, const struct request_sock *req),
>> +
>> +       TP_ARGS(sk, req),
>> +
>> +       TP_STRUCT__entry(
>> +               __field(const void *, skaddr)
>> +               __field(const void *, req)
>> +               __field(__u16, sport)
>> +               __field(__u16, dport)
>> +               __array(__u8, saddr, 4)
>> +               __array(__u8, daddr, 4)
>> +               __array(__u8, saddr_v6, 16)
>> +               __array(__u8, daddr_v6, 16)
>
> Would it make sense to add the inode of the network namespace that
> owns the socket? (along with the major/minor of the nsfs)

We cannot do this.
netns ino is not unique identifier of netns.
we can do such hack only inside programs by
walking skb->dev->nd_net->net with bpf_probe_read() and realizing
that this is unstable interface and not technically correct.

> If the kernel later gains tracepoints for TCP connect, accept, close
> including the netns ino, then I might be able to replace some
> ebpf-kprobes code by ebpf-tracepoints code :)

What is the use case for tracepoints in connect/accept/close ?
Just because some _useful_ bcc script is using kprobe in particular
kernel function it doesn't mean yet that we need a tracepoint in there.
imo the general rule for tracepoints is to only add them when it's 100%
certain that this is the right place for it and kprobe approach
is not enough or not possible.
In the case of recent addition of tcp tracepoints the main thing
they achieve (vs our old kprobe approach) is that they are accurate.
In this particular patch the kprobe on tcp_rtx_synack() is not
the same as trace_tcp_retransmit_synack(), since it incorrectly
counts failed send_synack(). It's solvable via kretprobe
on tcp_rtx_synack() and checking %rax inside the bpf program,
but kretprobes add runtime overhead and much slower than tracepoints.
