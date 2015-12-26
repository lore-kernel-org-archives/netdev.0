From: Craig Gallek <kraigatgoog@gmail.com>
Subject: Re: [PATCH net-next 3/4] soreuseport: setsockopt SO_ATTACH_REUSEPORT_[CE]BPF
Date: Sat, 26 Dec 2015 14:05:57 -0500
Message-ID: <CAEfhGiwWYtJqzkDAiptkd9NE+j6wquFBnoWmzNipALGUDH0kHg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:34173 "EHLO
	mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751159AbbLZTGA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Dec 2015 14:06:00 -0500
Received: by mail-lf0-f66.google.com with SMTP id n70so834796lfn.1
        for <netdev@vger.kernel.org>; Sat, 26 Dec 2015 11:05:59 -0800 (PST)
Received: from mail-lf0-f47.google.com (mail-lf0-f47.google.com. [209.85.215.47])
        by smtp.gmail.com with ESMTPSA id m64sm9129498lfd.45.2015.12.26.11.05.57
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 26 Dec 2015 11:05:57 -0800 (PST)
Received: by mail-lf0-f47.google.com with SMTP id p203so184904357lfa.0
        for <netdev@vger.kernel.org>; Sat, 26 Dec 2015 11:05:57 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 24, 2015 at 11:36 AM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Tue, Dec 22, 2015 at 03:05:09PM -0500, Craig Gallek wrote:
>> From: Craig Gallek <kraig@google.com>
>>
>> Expose socket options for setting a classic or extended BPF program
>> for use when selecting sockets in an SO_REUSEPORT group.  These options
>> can be used on the first socket to belong to a group before bind or
>> on any socket in the group after bind.
>>
>> This change includes refactoring of the existing sk_filter code to
>> allow reuse of the existing BPF filter validation checks.
>>
>> Signed-off-by: Craig Gallek <kraig@google.com>
>
> interesting stuff.
>
>> +static struct sock *run_bpf(struct sock_reuseport *reuse, u16 socks,
>> +                         struct bpf_prog *prog, struct sk_buff *skb,
>> +                         int hdr_len)
>> +{
>> +     struct sk_buff *nskb = NULL;
>> +     u32 index;
>> +
>> +     if (skb_shared(skb)) {
>> +             nskb = skb_clone(skb, GFP_ATOMIC);
>> +             if (!nskb)
>> +                     return NULL;
>> +             skb = nskb;
>> +     }
>
> what is the typical case here skb_shared or not?
I _think_ most of code paths that lead here will be not shared.  I
haven't finished examining all of the TCP cases yet, but in the common
UDP case the skb is not yet shared here.

>> +     /* temporarily advance data past protocol header */
>> +     if (skb_headlen(skb) < hdr_len || !skb_pull_inline(skb, hdr_len)) {
>
> though bpf core will read just fine past linear part of the packet,
> here we're limiting this feature only to packets where udp header is
> part of headlen. Will it make it somewhat unreliable?
> May be we can avoid doing this pull/push and use negative load
> instructions with SKF_NET_OFF ? Something like:
> load_word(skb, SKF_NET_OFF + sizeof(struct udphdr)));
This is an excellent point and will be even more relevant for TCP.
I'll try to get this to work for v2.

>>  /**
>>   *  reuseport_select_sock - Select a socket from an SO_REUSEPORT group.
>>   *  @sk: First socket in the group.
>> - *  @hash: Use this hash to select.
>> + *  @hash: When no BPF filter is available, use this hash to select.
>> + *  @skb: skb to run through BPF filter.
>> + *  @hdr_len: BPF filter expects skb data pointer at payload data.  If
>> + *    the skb does not yet point at the payload, this parameter represents
>> + *    how far the pointer needs to advance to reach the payload.
>
> what is the use case of this?
> Do you expect programs to be stateful?
I was trying to approximate the semantics of the existing BPF socket
filters.  When those programs are run, the skb data pointer has been
advanced passed the network headers.  I assumed that the location of
the existing socket filter execution was chosen because of the state
of the data pointer (to avoid leaking the headers to user space,
though this was just a guess).   These new filters must be run while
choosing the socket, before the protocol headers have been popped.  If
it's safe to send the skb to the program with the protocol header,
then this field is not strictly necessary (it may still be desired to
uniformly present packets to a program in a protocol-agnostic way).

I imagine that some programs may have some state in the form of BPF
maps, but the simpler ones will just do packet steering based on cpu
core id, numa node or something similar.  There is currently an
outstanding patch to do controlled shutdown of reuseport sockets
(SO_REUSEPORT_LISTEN_OFF).  I could imagine using this BPF approach to
implement those semantics as well.

>> +                             sk2 = reuseport_select_sock(sk, hash, NULL, 0);
> ...
>> +                             sk2 = reuseport_select_sock(sk, hash, skb,
>> +                                                     sizeof(struct udphdr));
>
> these are the cases that comment is trying to explain?
> Meaning the bpf program needs to understand well enough when udp stack
> is calling it ?
There are some call paths that involve selecting a socket without
having an skb.  These obviously won't work with a BPF program, so the
code falls back to using a hash of some other data.  The real reason
for the hdr_len parameter is to support advancing past both UDP or TCP
headers.  If the data pointer is always moved to the payload, the same
program could be used for any protocol (assuming it doesn't need to
care about the protocol).

> Will do more careful review of bpf bits once I'm back from PTO.
I appreciate the initial comments, enjoy your time off.
